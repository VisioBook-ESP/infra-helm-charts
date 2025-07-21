#!/bin/bash

set -e

# Add Argo Helm repo
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install Argo CD into 'argocd' namespace
helm install argocd argo/argo-cd --namespace argocd --create-namespace && true 

# Get NodePort and IP
NODE_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "URL : https://${NODE_IP}:${NODE_PORT}"
echo "Utilisateur : admin"

# Get initial password
echo "Mot de passe initial :"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

