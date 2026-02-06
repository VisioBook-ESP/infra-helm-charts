# PostgreSQL Helm Chart Minimal

Chart Helm minimaliste pour déployer PostgreSQL cloud-native sur Kubernetes avec un Deployment.

## Installation

```bash
helm install mon-pgsql ./pgsql-chart
```

## Configuration

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `replicaCount` | Nombre de replicas | `1` |
| `image.repository` | Image Docker | `postgres` |
| `image.tag` | Tag de l'image | `16-alpine` |
| `auth.database` | Nom de la base | `app` |
| `auth.username` | Utilisateur | `appuser` |
| `auth.password` | Mot de passe | `changeme` |
| `persistence.enabled` | Activer la persistence | `true` |
| `persistence.size` | Taille du volume | `1Gi` |
| `resources.limits.memory` | Limite mémoire | `256Mi` |
| `resources.limits.cpu` | Limite CPU | `500m` |

## Connexion

```bash
kubectl port-forward svc/mon-pgsql-pgsql 5432:5432
psql -h localhost -U appuser -d app
```

## Désinstallation

```bash
helm uninstall mon-pgsql
```
