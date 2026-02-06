# PostgreSQL CloudNativePG - Installation Simple

Chart Helm minimaliste pour CloudNativePG (CNPG).

## ⚠️ Prérequis : Installer l'opérateur CNPG

L'opérateur CloudNativePG doit être installé **avant** d'utiliser ce chart.

### Installation de l'opérateur (une seule fois par cluster)

```bash
# Via kubectl
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.0.yaml

# OU via Helm
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm install cnpg-operator cnpg/cloudnative-pg
```

### Vérifier l'installation de l'opérateur

```bash
kubectl get deployment -n cnpg-system cnpg-controller-manager
```

## 🚀 Installation du cluster PostgreSQL

Une fois l'opérateur installé :

```bash
helm install postgres ./pgsql-simple
```

## 📝 Configuration

Modifier `values.yaml` ou utiliser `--set` :

```bash
helm install postgres ./pgsql-simple \
  --set cluster.instances=3 \
  --set cluster.storageSize=10Gi \
  --set database.password=mon-password-securise
```

### Paramètres disponibles

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `cluster.name` | Nom du cluster | `postgres` |
| `cluster.instances` | Nombre d'instances | `1` |
| `cluster.storageSize` | Taille stockage | `1Gi` |
| `database.name` | Nom de la BDD | `app` |
| `database.user` | Utilisateur | `appuser` |
| `database.password` | Mot de passe | `changeme` |
| `resources.memory` | Limite mémoire | `256Mi` |
| `resources.cpu` | Limite CPU | `500m` |

## 🔌 Connexion

```bash
# Port-forward
kubectl port-forward svc/postgres-rw 5432:5432

# Connexion
psql -h localhost -U appuser -d app
# Password: changeme (ou celui configuré)
```

## 📊 Commandes utiles

```bash
# État du cluster
kubectl get cluster postgres

# Liste des pods
kubectl get pods -l cnpg.io/cluster=postgres

# Logs
kubectl logs -l cnpg.io/cluster=postgres -f

# Services créés automatiquement
kubectl get svc | grep postgres
# postgres-rw  -> Lecture/Écriture (primary)
# postgres-ro  -> Lecture seule (replicas)
# postgres-r   -> Lecture (all instances)
```

## 🗑️ Désinstallation

```bash
# Supprimer le cluster
helm uninstall postgres

# Supprimer les PVC (ATTENTION: supprime les données)
kubectl delete pvc -l cnpg.io/cluster=postgres
```

## 📦 Structure du chart

```
pgsql-simple/
├── Chart.yaml              # Métadonnées
├── values.yaml             # Configuration
└── templates/
    ├── cluster.yaml        # Resource Cluster CNPG
    └── secret.yaml         # Credentials utilisateur
```

## 🔧 Exemples d'utilisation

### Cluster minimal (dev/test)

```bash
helm install dev-postgres ./pgsql-simple \
  --set cluster.instances=1 \
  --set cluster.storageSize=500Mi
```

### Cluster HA (production)

```bash
helm install prod-postgres ./pgsql-simple \
  --set cluster.name=prod-db \
  --set cluster.instances=3 \
  --set cluster.storageSize=50Gi \
  --set database.password=$(openssl rand -base64 32) \
  --set resources.memory=1Gi \
  --set resources.cpu=1000m
```

## ❓ Troubleshooting

### Erreur: CRD not found

```
Error: CustomResourceDefinition "clusters.postgresql.cnpg.io" not found
```

**Solution**: Installer l'opérateur CNPG (voir section Prérequis)

### Pods en Pending

Vérifier le StorageClass disponible :

```bash
kubectl get storageclass
```

Si nécessaire, créer un PV/PVC manuellement ou utiliser un StorageClass dynamique.

### Connexion refusée

Vérifier que le cluster est prêt :

```bash
kubectl get cluster postgres
# STATUS devrait être "Cluster in healthy state"
```

## 🎯 Avantages CloudNativePG

- ✅ **Haute disponibilité** : Failover automatique
- ✅ **Réplication** : Streaming natif PostgreSQL
- ✅ **Backups** : Support WAL archiving et PITR
- ✅ **Monitoring** : Métriques Prometheus
- ✅ **Rolling updates** : Mises à jour sans downtime
- ✅ **Connection pooling** : PgBouncer intégré

## 📚 Documentation

- [CloudNativePG Docs](https://cloudnative-pg.io)
- [API Reference](https://cloudnative-pg.io/documentation/current/api_reference/)
