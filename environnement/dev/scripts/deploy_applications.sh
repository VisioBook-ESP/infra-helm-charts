#!/bin/bash

# ISTIO
kubectl create namespace istio-system
cd app/configs/istio
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

# GATEWAY
./apply-gateway.sh

# CNPG
## install cnpg operator (download first to catch network errors)
echo "Downloading CNPG operator manifest..."
curl -sSfL -o /tmp/cnpg-1.24.0.yaml https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.0.yaml || { echo "ERROR: Failed to download CNPG manifest"; exit 1; }
echo "Installing CNPG operator..."
kubectl apply --server-side -f /tmp/cnpg-1.24.0.yaml || { echo "ERROR: Failed to install CNPG operator"; exit 1; }

# Wait for CNPG CRDs to be available before deploying ArgoCD apps
echo "Waiting for CNPG CRDs..."
kubectl wait --for=condition=Established crd/clusters.postgresql.cnpg.io --timeout=60s || { echo "ERROR: CNPG CRDs not ready"; exit 1; }
cd ..
# Secret is managed by ArgoCD (sync-wave -1), no need to pre-create
kubectl apply -f argocd/app-project.yml
# kubectl apply -f argocd/argo-configmap.yml


# Lance les helms charts
kubectl apply -f argocd/application-visiobook.yml


