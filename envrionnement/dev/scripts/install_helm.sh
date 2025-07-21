#!/bin/bash

set -e 

sudo wget https://get.helm.sh/helm-v3.17.4-linux-amd64.tar.gz
sudo tar -zxvf helm-v3.17.4-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh
sudo rm -rf helm-v3.17.4-linux-amd64.tar.gz linux-amd64 get_helm.sh
