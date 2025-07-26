#!/bin/bash

set -e

# Check if Helm is already installed
if command -v helm >/dev/null 2>&1; then
    echo "Helm already installed: $(helm version --short)"
else
    echo "Installing Helm..."
    
    # Download and extract Helm
    sudo wget https://get.helm.sh/helm-v3.17.4-linux-amd64.tar.gz
    sudo tar -zxvf helm-v3.17.4-linux-amd64.tar.gz
    sudo mv linux-amd64/helm /usr/local/bin/helm
    
    # Clean up downloaded files
    sudo rm -rf helm-v3.17.4-linux-amd64.tar.gz linux-amd64
    
    # Alternative installation method (cleanup after)
    sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    sudo chmod 700 get_helm.sh
    sudo ./get_helm.sh
    sudo rm -f get_helm.sh
    
    echo "Helm installed: $(helm version --short)"
fi