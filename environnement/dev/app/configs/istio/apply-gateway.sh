#!/bin/bash

echo "🚀 Applying Istio Gateway configurations..."

# Vérifier que Istio est bien installé
echo "📋 Checking Istio installation..."
kubectl get pods -n istio-system

if [ $? -ne 0 ]; then
  echo "❌ Istio not found in istio-system namespace"
  exit 1
fi

# Appliquer la Gateway
echo "🌐 Creating Gateway..."
kubectl apply -f gateway/main-gateway.yaml

# Attendre un peu
sleep 5

# Appliquer les VirtualServices
kubectl apply -f gateway/

echo "🔀 Creating VirtualServices..."
# Appliquer RequestAuthentication
echo "🔐 Configuring JWT authentication..."

# Appliquer AuthorizationPolicy
echo "🛡️  Configuring authorization policies..."

echo ""
echo "✅ Gateway configuration complete!"
echo ""
echo "📊 Checking resources:"
kubectl get gateway -n istio-system
kubectl get virtualservice -n visiobook-namespace
kubectl get requestauthentication -n istio-system
kubectl get authorizationpolicy -n istio-system


sudo systemctl daemon-reload
sudo systemctl enable minikube-tunnel
sudo systemctl start minikube-tunnel

sleep 2

echo ""
echo "🔍 Get LoadBalancer IP:"
kubectl get svc istio-ingress -n istio-system

