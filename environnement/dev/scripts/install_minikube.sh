#!/bin/bash

set -e

# Install kubectl if not present
if ! command -v kubectl >/dev/null 2>&1; then
    echo "Installing kubectl..."
    sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    sudo rm -rf kubectl kubectl.sha256
    echo "kubectl installed: $(kubectl version --client --short)"
else
    echo "kubectl already installed: $(kubectl version --client --short)"
fi

# Install minikube if not present
if ! command -v minikube >/dev/null 2>&1; then
    echo "Installing minikube..."
    sudo curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    sudo rm minikube-linux-amd64
    echo "minikube installed: $(minikube version --short)"
else
    echo "minikube already installed: $(minikube version --short)"
fi
