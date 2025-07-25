#!/bin/bash

kubectl delete -f scripts/configs/argocd/nginx-test-app.yaml -n argocd

# Uninstall Image Updater
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/master/manifests/install.yaml

# # Install Argo CD Image Updater
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/master/manifests/install.yaml

kubectl apply -f scripts/configs/argocd/nginx-test-app.yaml -n argocd
