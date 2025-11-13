# 🛠️ Commandes utiles pour l'environnement de Dev

Cette page liste les **commandes pratiques** pour travailler avec l’environnement de développement (Minikube, Helm, K9s, ArgoCD…).

---

## 🚀 Déployer l’environnement de Dev
Pour configurer l’environnement de développement, exécutez la commande suivante à la racine du projet :

```bash
  cd <racine du repo>/environnement/dev
  make setup
```

**👉 La documentation complète de cette commande est disponible sur cette page. [Déployer l’environnement de Dev](./setup-makefile.md).**

---

## 📦 Minikube – Commandes utiles

Ajouter un alias pour utiliser kubectl via Minikube :
```bash
  alias kubectl="minikube kubectl --"
```
### Démarrer Minikube :
```bash
  minikube start
```
### Vérifier l'état des pods :
```bash
  kubectl get pods -A
```
### Supprimer le cluster Minikube :
```bash
  minikube delete --all
```
---
## ⛵ Helm – Commandes utiles 
### Installer les charts Helm :
```bash
  helm install <nom-release> <chart>
```
### Mettre à jour une release Helm existante :
```bash
  helm upgrade <nom-release> <chart>
```
### Désinstaller une release Helm :
```bash
  helm uninstall <nom-release>
```
### Lister les releases Helm installées :
```bash
    helm list
```
### Afficher les valeurs configurées d'une release Helm :
```bash
  helm get values <nom-release>
```
### Travailler avec un fichier `values.yaml` personnalisé :
```bash
  helm install <nom-release> <chart> -f <chemin-vers-values.yaml>
```
### Générer les templates Kubernetes sans déployer :
Cette commande permet de visualiser dans un terminal, les ressources Kubernetes qui seraient créées par le chart Helm, sans réellement les déployer dans le cluster.
```bash
  helm template <chart> -f myvalues.yaml
```

---
## 🖥️ K9s – Commandes utiles
Lancer K9s pour administrer le cluster :
```bash
  k9s
```
## Commandes utiles argocd-image-updater

voir les logs
```
kubectl logs -n argocd deployment/argocd-image-updater
```
