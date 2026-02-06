# Guide d'installation complet

## Étape 1 : Installer l'opérateur CloudNativePG

### Option A : Via kubectl (rapide)

```bash
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.0.yaml
```

### Option B : Via Helm (recommandé pour production)

```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg
```

### Vérification

```bash
# Attendre que l'opérateur soit prêt
kubectl wait --for=condition=Available \
  deployment/cnpg-controller-manager \
  -n cnpg-system \
  --timeout=300s

# Vérifier les CRDs
kubectl get crd | grep postgresql.cnpg.io
```

Vous devriez voir :
```
backups.postgresql.cnpg.io
clusters.postgresql.cnpg.io
poolers.postgresql.cnpg.io
scheduledbackups.postgresql.cnpg.io
```

## Étape 2 : Installer le cluster PostgreSQL

```bash
# Installation simple
helm install postgres ./pgsql-simple

# OU avec configuration personnalisée
helm install postgres ./pgsql-simple \
  --set database.password=mon-password \
  --set cluster.instances=3
```

## Étape 3 : Vérifier le déploiement

```bash
# État du cluster
kubectl get cluster

# Devrait afficher :
# NAME       AGE   INSTANCES   READY   STATUS                     PRIMARY
# postgres   30s   1           1       Cluster in healthy state   postgres-1

# Vérifier les pods
kubectl get pods
```

## Étape 4 : Se connecter

```bash
# Port-forward
kubectl port-forward svc/postgres-rw 5432:5432 &

# Connexion avec psql
psql postgresql://appuser:changeme@localhost:5432/app
```

## Commandes de diagnostic

```bash
# Logs de l'opérateur
kubectl logs -n cnpg-system deployment/cnpg-controller-manager -f

# Logs du cluster PostgreSQL
kubectl logs -l cnpg.io/cluster=postgres -f

# Description complète du cluster
kubectl describe cluster postgres

# Events
kubectl get events --sort-by='.lastTimestamp'
```

## Désinstallation complète

```bash
# 1. Supprimer le cluster
helm uninstall postgres

# 2. Supprimer les PVC
kubectl delete pvc -l cnpg.io/cluster=postgres

# 3. (Optionnel) Supprimer l'opérateur
kubectl delete -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.0.yaml
# OU
helm uninstall cnpg -n cnpg-system
```
