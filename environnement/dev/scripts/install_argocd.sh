#!/bin/bash

set -e
echo "1. Création du namespace argocd..."
kubectl create namespace argocd || echo "Namespace argocd existe déjà"

echo "2. Installation d'Argo CD via les manifests officiels..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "3. Attente que les pods soient prêts..."
kubectl wait --for=condition=available --timeout=180s deployment/argocd-server -n argocd

echo "4. Patch du service argocd-server en NodePort (pour accès local)..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

echo "5. Installation CLI ArgoCD..."
# Check if ArgoCD CLI is already installed
if command -v argocd >/dev/null 2>&1; then
    echo "ArgoCD CLI already installed: $(argocd version --client --short 2>/dev/null || argocd version --client 2>/dev/null | head -1)"
else
    echo "Installing ArgoCD CLI..."
    
    VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
    chmod +x argocd
    sudo mv argocd /usr/local/bin/
    
    echo "ArgoCD CLI installed: $(argocd version --client --short 2>/dev/null || argocd version --client 2>/dev/null | head -1)"
fi

echo "6. Récupération du mot de passe admin initial..."
PASSWORD=$(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "Mot de passe admin : $PASSWORD"
echo admin | sudo tee argocd_password.txt > /dev/null
echo "$PASSWORD" | sudo tee -a argocd_password.txt > /dev/null

echo "7. Pour accéder à l'interface Web Argo CD :"
NODE_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')



echo "URL : https://${NODE_IP}:${NODE_PORT}"
echo "Utilisateur : admin"
echo "|||||||||||||||||||||||||||||"
echo "Argo CD installé avec succès."
echo "|||||||||||||||||||||||||||||"
# kubectl port-forward svc/argocd-server -n argocd 8080:443
echo "localhost:8080"
