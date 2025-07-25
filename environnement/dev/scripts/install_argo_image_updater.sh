#!/bin/bash

# set -a
# source ../../.env
# set +a
# echo "GHCR_USER: ${GHCR_USER}"
# echo "GHCR_TOKEN: ${GHCR_TOKEN:0:10}..." # Only show first 10 chars for security
# echo "GHCR_EMAIL: ${GHCR_EMAIL}"


# # Validate required environment variables
# if [[ -z "$GHCR_USER" || -z "$GHCR_TOKEN" || -z "$GHCR_EMAIL" ]]; then
#     echo "Error: Missing required environment variables in .env file"
#     echo "Required: GHCR_USER, GHCR_TOKEN, GHCR_EMAIL"
#     exit 1
# fi
# Uninstall the application
kubectl delete -f scripts/configs/argocd/nginx-test-app.yaml -n argocd

# Uninstall Image Updater
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/master/manifests/install.yaml

# Delete registry secret (if exists)
# # Install Argo CD Image Updater
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/master/manifests/install.yaml
# kubectl create secret docker-registry ghcr-creds \
#   --namespace=argocd \
#   --docker-server=ghcr.io \
#   --docker-username="$GHCR_USER" \
#   --docker-password="$GHCR_TOKEN" \
#   --docker-email="$GHCR_EMAIL" || echo "Secret GHCR existe déjà"

kubectl apply -f scripts/configs/argocd/nginx-test-app.yaml -n argocd
