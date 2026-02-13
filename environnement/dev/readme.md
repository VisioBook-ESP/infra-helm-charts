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
sudo tee  argocd-portforward.service <<EOF
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



# test de la gateway pour creer un user
curl -X POST http://10.97.9.39/api/v1/auth/register/   -H "Content-Type: application/json"   -d '{
    "email": "user@example.com",
    "password": "SecurePassword123!",
    "username": "myusername"
  }'