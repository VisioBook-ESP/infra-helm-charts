#!/bin/bash

#kubectl apply -f scripts/configs/argocd/nginx-test-app.yaml -n argocd


#Istio
kubectl create namespace istio-system

pwd
ls
cd app/configs/istio

pwd

kubectl apply -f istio-base.yaml -n istio-system
kubectl apply -f istiod.yaml --validate=false -n istio-system --wait
kubectl apply -f istio-ingress.yaml -n istio-system

sleep 60

kubectl apply -f istio-addons/prometheus.yaml -n istio-system
kubectl apply -f istio-addons/grafana.yaml -n istio-system
kubectl apply -f istio-addons/kiali.yaml -n istio-system
kubectl apply -f istio-addons/jaeger.yaml -n istio-system

kubectl create namespace database

kubectl apply -f istio-gateway/ecommerce-gateway.yaml