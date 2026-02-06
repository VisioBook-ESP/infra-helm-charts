#!/bin/bash

Istio
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

kubectl create namespace visiobook-namespace
kubectl label namespace visiobook-namespace istio-injection=enabled

/usr/bin apply-gateway.sh
# kubectl create namespace database
# kubectl label namespace database istio-injection=enabled
# kubectl create namespace backend
# kubectl label namespace backend istio-injection=enabled
# kubectl create namespace frontend
# kubectl label namespace frontend istio-injection=enabled


# install cnpg operator
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.0.yaml



cd ..
# kubectl create namespace cnpg-operator
# kubectl apply -f argocd/cnpg-operator.yml
kubectl apply -f argocd/app-project.yml
# kubectl apply -f argocd/argo-configmap.yml

kubectl apply -f argocd/application-visiobook.yml


