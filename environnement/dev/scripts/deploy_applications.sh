#!/bin/bash

kubectl apply -f scripts/configs/argocd/nginx-test-app.yaml -n argocd


#Istio
kubectl create namespace istio-system

kubectl apply -f scripts/configs/argocd/istio-base-app.yaml -n argocd
kubectl apply -f scripts/configs/argocd/istio-control-plane-app.yaml -n argocd
kubectl apply -f scripts/configs/argocd/istio-gateway-app.yaml -n argocd