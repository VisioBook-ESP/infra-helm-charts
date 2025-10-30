# 🐘 Helm Chart – PostgreSQL

## 📘 Description

Ce chart Helm déploie une instance **PostgreSQL** sur un cluster **Kubernetes**.  
Il permet de gérer facilement la base de données, sa persistance, et sa configuration via un fichier `values.yaml`.

---

## 📂 Structure du Chart
```
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── NOTES.txt
│   ├── pvc.yaml
│   ├── secret.yaml
│   ├── serviceaccount.yaml
│   ├── service.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
```
## ⚙️ Installation

### Installer le Chart
```bash
    helm install <nom-release> .environnement/dev/charts/postgresql-db
```
### Installation avec des valeurs personnalisées
```bash
    helm install <nom-release> .environnement/dev/charts/postgresql-db -f <chemin-vers-values.yaml>
```
