# Deployer l'envrionnement de Dev
Prerequis: ne pas utiliser le user root pour lancer les commandes

## Installer minikub
### Installer kubectl
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check


sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl


kubectl version --client

```
Installer le binaire minikube:
```
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```
Lancer minikub
```
minikube start
```
Ajouter un alias pour minikub:
```
alias kubectl="minikube kubectl --"
```
Verifier que tout fonctionne
```
kubectl get po -A
```

Supprimer le cluster 
```
minikube delete --all
```
## Installer Argocd

## Installer Helm

Télécharger le binaire:
```
sudo wget https://get.helm.sh/helm-v3.17.4-linux-amd64.tar.gz
```
Decomprésser le binaire:
```
sudo tar -zxvf helm-v3.17.4-linux-amd64.tar.gz
```
Déplacer le repo
```
sudo mv linux-amd64/helm /usr/local/bin/helm
```

installer Helm
```
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh
```
## Installer k9s