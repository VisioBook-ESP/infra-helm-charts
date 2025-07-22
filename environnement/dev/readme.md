# Deployer l'envrionnement de Dev

Prerequis:
Le repo doit etre stocker chez un user non-root
Les commandes doivent etre lancées avec un user non-root
Avoir docker installé
Le user utilisé doit avoir le groupe docker

Pour lancer/installer kubernetes,minikube,helm,argocd et k9s:

```
cd <racine du repo>/environnement/dev
make setup
```

## Commandes utiles minikub

Ajouter un alias pour minikub:
```
alias kubectl="minikube kubectl --"
```

Lancer minikub
```
minikube start
```

Verifier que tout fonctionne
```
kubectl get pods -A
```

Supprimer le cluster
```
minikube delete --all
```


## Commandes utiles Helm


## Commandes utiles k9s

```
k9s
```
