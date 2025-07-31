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
➡️ (À compléter selon les besoins spécifiques : ajout de repo, installation de charts, etc.)

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
