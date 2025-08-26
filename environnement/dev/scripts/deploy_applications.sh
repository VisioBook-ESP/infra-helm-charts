#!/bin/bash

kubectl apply -f scripts/configs/argocd/nginx-test-app.yaml -n argocd


#Istio
kubectl create namespace istio-system
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.85.0/bundle.yaml

kubectl apply -f scripts/configs/argocd/istio-app.yaml -n argocd
# kubectl apply -f scripts/configs/argocd/kiali-app.yaml -n argocd
# kubectl apply -f scripts/configs/argocd/prometheus-app.yaml -n argocd
