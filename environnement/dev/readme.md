Port forward systemd

sudo nano /etc/systemd/system/argocd-portforward.service

```
[Unit]
Description=ArgoCD Port Forward
After=network.target

[Service]
Type=simple
User=debian
ExecStart=/usr/bin/kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8080:443
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target

```

sudo systemctl daemon-reload
sudo systemctl enable argocd-portforward
sudo systemctl start argocd-portforward


# Créer le service systemd pour minikube tunnel (donne une ip au LB)
sudo tee /etc/systemd/system/minikube-tunnel.service <<EOF
[Unit]
Description=Minikube Tunnel
After=network.target

[Service]
Type=simple
User=debian
ExecStart=/usr/local/bin/minikube tunnel
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable minikube-tunnel
sudo systemctl start minikube-tunnel


# test de la gateway pour creer un user
curl -X POST http://10.97.102.235/api/v1/users/   -H "Content-Type: application/json"   -d '{
    "email": "user@example.com",
    "password": "SecurePassword123!",
    "username": "myusername"
  }'