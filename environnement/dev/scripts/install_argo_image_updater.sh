#!/bin/bash

kubectl delete -f scripts/configs/argocd/nginx-test-app.yaml -n argocd

# Uninstall Image Updater
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/master/manifests/install.yaml

# # Install Argo CD Image Updater
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/master/manifests/install.yaml
#kubectl create secret docker-registry ghcr-creds \
#  --namespace=argocd \
#  --docker-server=ghcr.io \
#  --docker-username="$GHCR_USER" \
#  --docker-password="$GHCR_TOKEN" \
#  --docker-email="$GHCR_EMAIL" || echo "Secret GHCR existe déjà"
