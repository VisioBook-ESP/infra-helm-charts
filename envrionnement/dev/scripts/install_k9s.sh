# Télécharge la dernière version de K9s (pour Linux AMD64)
sudo curl -LO https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz

# Décompresse l'archive
sudo tar -xzf k9s_Linux_amd64.tar.gz

# Installe le binaire dans /usr/local/bin
sudo install k9s /usr/local/bin/

# Nettoyage
sudo rm k9s k9s_Linux_amd64.tar.gz
