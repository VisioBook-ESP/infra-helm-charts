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
