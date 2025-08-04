#!/bin/bash

kubectl apply -f scripts/configs/argocd/nginx-test-app.yaml -n argocd


#Istio
kubectl create namespace istio-system

kubectl apply -f scripts/configs/argocd/istio-app.yaml -n argocd