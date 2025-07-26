#!/bin/bash

set -e

# Check if K9s is already installed
if command -v k9s >/dev/null 2>&1; then
    echo "K9s already installed: $(k9s version --short 2>/dev/null || k9s version 2>/dev/null | head -1)"
else
    echo "Installing K9s..."
    
    # Download the latest version of K9s (for Linux AMD64)
    curl -LO https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
    
    # Extract the archive
    tar -xzf k9s_Linux_amd64.tar.gz
    
    # Install the binary in /usr/local/bin
    sudo install k9s /usr/local/bin/
    
    # Cleanup
    rm -f k9s k9s_Linux_amd64.tar.gz LICENSE README.md
    
    echo "K9s installed: $(k9s version --short 2>/dev/null || k9s version 2>/dev/null | head -1)"
fi