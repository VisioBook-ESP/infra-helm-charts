# Guide de déploiement CNPG via ArgoCD

## 📋 Résumé des changements

Le chart CloudNativePG a été complètement retravaillé pour résoudre les problèmes de volumes et d'intégration ArgoCD.

### Améliorations apportées:

✅ **Configuration des volumes corrigée**
- Template PVC explicite avec storageClass configurable
- Support du WAL storage séparé (optionnel)
- AccessModes configurables
- volumeMode explicite

✅ **Intégration ArgoCD optimisée**
- Sync waves configurées (Secret: wave 1, Cluster: wave 2)
- Annotations ArgoCD correctes
- Support ServerSideApply

✅ **Monitoring Prometheus activé**
- PodMonitor enabled
- Métriques exposées sur port 9187
- Configuration Prometheus mise à jour avec permissions RBAC

✅ **Configuration PostgreSQL optimisée**
- Paramètres de performance ajustés
- Ressources CPU/Mémoire configurables
- Health checks configurés

## 🚀 Déploiement

### Option 1: Via ArgoCD (Recommandé)

Le chart est déjà configuré dans `application-visiobook.yml`:

```bash
# Appliquer l'Application ArgoCD
kubectl apply -f /home/debian/visioBook/infra-helm-charts/environnement/dev/app/configs/argocd/application-visiobook.yml

# Vérifier le déploiement dans ArgoCD UI
# ou via CLI:
argocd app get application-visiobook
argocd app sync application-visiobook
```

### Option 2: Test en local avec Helm

Pour tester avant de pusher sur Git:

```bash
cd /home/debian/visioBook/infra-helm-charts/environnement/dev/charts/cloud-native-postgres

# Tester le chart
./test-chart.sh

# Installer directement
helm install postgres . -n visiobook-namespace --create-namespace

# Voir les ressources créées
kubectl get all,pvc,secret -n visiobook-namespace -l app=postgres
```

## 🔍 Vérification du déploiement

### 1. Vérifier l'opérateur CNPG

```bash
# L'opérateur devrait être dans le namespace cnpg-system ou dans votre namespace
kubectl get pods -A | grep cnpg

# Logs de l'opérateur
kubectl logs -n cnpg-system -l app.kubernetes.io/name=cloudnative-pg -f
```

### 2. Vérifier le cluster PostgreSQL

```bash
# Voir le statut du cluster
kubectl get cluster -n visiobook-namespace
kubectl describe cluster postgres -n visiobook-namespace

# Voir les pods
kubectl get pods -n visiobook-namespace -l app=postgres

# Voir les PVC (les volumes)
kubectl get pvc -n visiobook-namespace
```

### 3. Vérifier les volumes

```bash
# Les PVC devraient être en état "Bound"
kubectl get pvc -n visiobook-namespace -o wide

# Si les PVC sont en "Pending", vérifier:
# 1. Le StorageClass existe
kubectl get storageclass

# 2. Les events pour voir l'erreur
kubectl get events -n visiobook-namespace --sort-by='.lastTimestamp' | grep -i pvc

# 3. Les provisioners de storage fonctionnent
kubectl get pods -n kube-system | grep -i provisioner
```

### 4. Tester la connexion PostgreSQL

```bash
# Se connecter au pod PostgreSQL
kubectl exec -it -n visiobook-namespace postgres-1 -- psql -U appuser -d app

# Ou via port-forward
kubectl port-forward -n visiobook-namespace svc/postgres-rw 5432:5432
psql -h localhost -U appuser -d app
# Password: MySecurePassword123!
```

### 5. Vérifier le monitoring Prometheus

```bash
# Vérifier que le PodMonitor est créé
kubectl get podmonitor -n visiobook-namespace

# Voir les métriques
kubectl port-forward -n visiobook-namespace pod/postgres-1 9187:9187
curl http://localhost:9187/metrics | grep cnpg_
```

## 🔧 Troubleshooting

### Problème: Les PVC ne se créent pas

**Symptôme**: Les pods restent en `Pending`, PVC en `Pending`

**Solutions**:

1. **Vérifier le StorageClass**:
   ```bash
   kubectl get storageclass
   # Si aucun n'est "default", en définir un:
   kubectl patch storageclass <nom-du-storageclass> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
   ```

2. **Ou spécifier un StorageClass dans values.yaml**:
   ```yaml
   cluster:
     storage:
       storageClass: "standard"  # ou "gp2", "fast-ssd", etc.
   ```

3. **Vérifier les quotas de namespace**:
   ```bash
   kubectl describe quota -n visiobook-namespace
   ```

### Problème: Le cluster ne démarre pas

**Symptôme**: Les pods crashent ou ne démarrent pas

**Solutions**:

1. **Vérifier les logs**:
   ```bash
   kubectl logs -n visiobook-namespace postgres-1 -c postgres
   ```

2. **Vérifier le secret**:
   ```bash
   kubectl get secret postgres-app-user -n visiobook-namespace -o yaml
   ```

3. **Vérifier les ressources disponibles**:
   ```bash
   kubectl describe node
   # Vérifier "Allocated resources"
   ```

### Problème: ArgoCD ne synchronise pas

**Symptôme**: ArgoCD affiche "OutOfSync" ou erreurs

**Solutions**:

1. **Vérifier les sync waves**:
   - Secret doit être créé avant (wave 1)
   - Cluster après (wave 2)

2. **Forcer une synchronisation**:
   ```bash
   argocd app sync application-visiobook --force
   ```

3. **Voir les détails de l'erreur**:
   ```bash
   argocd app get application-visiobook
   kubectl get events -n visiobook-namespace --sort-by='.lastTimestamp'
   ```

### Problème: Prometheus ne récupère pas les métriques

**Solutions**:

1. **Vérifier que le PodMonitor est activé**:
   ```bash
   kubectl get podmonitor -n visiobook-namespace
   ```

2. **Vérifier les permissions RBAC de Prometheus**:
   ```bash
   kubectl get clusterrole prometheus -o yaml | grep -A 5 monitoring.coreos.com
   ```

3. **Redémarrer Prometheus**:
   ```bash
   kubectl rollout restart deployment prometheus -n istio-system
   ```

## 📊 Services créés

Après le déploiement, CNPG crée automatiquement ces services:

- **`postgres-rw`**: Service Read-Write (pointe vers le primary)
  - Pour toutes les opérations de lecture/écriture
  - Port: 5432

- **`postgres-ro`**: Service Read-Only (pointe vers les replicas)
  - Pour les lectures uniquement
  - Load-balancé entre les replicas
  - Port: 5432

- **`postgres-r`**: Service pour toutes les instances
  - Pour accès direct à n'importe quelle instance
  - Port: 5432

## 🔐 Informations de connexion

Par défaut (à changer en production!):

- **Host**: `postgres-rw.visiobook-namespace.svc.cluster.local`
- **Port**: `5432`
- **Database**: `app`
- **User**: `appuser`
- **Password**: `MySecurePassword123!`

### Chaîne de connexion PostgreSQL:

```
postgresql://appuser:MySecurePassword123!@postgres-rw.visiobook-namespace.svc.cluster.local:5432/app
```

## 📁 Structure du chart

```
cloud-native-postgres/
├── Chart.yaml                          # Métadonnées du chart
├── values.yaml                         # Configuration par défaut
├── templates/
│   ├── secret.yaml                     # Secret pour les credentials
│   └── cluster.yaml                    # Définition du cluster CNPG
├── test-chart.sh                       # Script de test
├── argocd-application-example.yaml     # Exemple d'Application ArgoCD
├── DEPLOYMENT.md                       # Ce fichier
└── README.md                           # Documentation complète

```

## 🎯 Prochaines étapes

1. **Pousser les changements sur Git**:
   ```bash
   cd /home/debian/visioBook
   git add infra-helm-charts/environnement/dev/charts/cloud-native-postgres/
   git add infra-helm-charts/environnement/dev/app/configs/argocd/application-visiobook.yml
   git add infra-helm-charts/environnement/dev/app/configs/istio/istio-addons/prometheus.yaml
   git commit -m "fix: Rework CNPG chart with proper volume configuration for ArgoCD"
   git push origin HEAD
   ```

2. **Synchroniser dans ArgoCD**:
   - Soit automatique si `automated: true`
   - Soit manuel via UI ou CLI

3. **Configurer les backups** (optionnel mais recommandé):
   - Ajouter la configuration de backup dans le cluster
   - Configurer un bucket S3 ou stockage compatible

4. **Mettre en place le monitoring**:
   - Vérifier que Grafana affiche les dashboards CNPG
   - Configurer des alertes sur Prometheus

5. **Sécuriser les credentials**:
   - Utiliser un secret externe (Vault, Sealed Secrets, etc.)
   - Changer le mot de passe par défaut

## 📚 Ressources

- [Documentation CNPG](https://cloudnative-pg.io/)
- [GitHub CNPG](https://github.com/cloudnative-pg/cloudnative-pg)
- [Helm Charts CNPG](https://github.com/cloudnative-pg/charts)
