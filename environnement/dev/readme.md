Port forward systemd

sudo nano /etc/systemd/system/argocd-portforward.service

```
[Unit]
Description=ArgoCD Port Forward
After=network.target

[Service]
Type=simple
User=debian
ExecStart=/usr/bin/kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8080:80
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target

```

sudo systemctl daemon-reload
sudo systemctl enable argocd-portforward
sudo systemctl start argocd-portforward


## Health check automatique (redémarre le port-forward si ArgoCD ne répond plus)

Le `kubectl port-forward` peut se dégrader sans crasher (timeouts silencieux).
Un timer systemd vérifie la connectivité toutes les 2 minutes et redémarre le service si besoin.

sudo nano /etc/systemd/system/argocd-healthcheck.service

```
[Unit]
Description=ArgoCD Port Forward Health Check

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'if ! curl -sf -o /dev/null -m 5 http://localhost:8080; then echo "ArgoCD port-forward unhealthy, restarting..."; systemctl restart argocd-portforward; fi'
```

sudo nano /etc/systemd/system/argocd-healthcheck.timer

```
[Unit]
Description=ArgoCD Port Forward Health Check Timer

[Timer]
OnBootSec=60
OnUnitActiveSec=120

[Install]
WantedBy=timers.target
```

sudo systemctl daemon-reload
sudo systemctl enable --now argocd-healthcheck.timer



# test de la gateway pour creer un user
curl -X POST http://10.97.9.39/api/v1/auth/register/   -H "Content-Type: application/json"   -d '{
    "email": "user@example.com",
    "password": "SecurePassword123!",
    "username": "myusername"
  }'

commande pour stocker le certificat
  ```
  kubectl get secret visiobook-tls-secret -n istio-system -o yaml \
  | grep -v "resourceVersion\|uid\|creationTimestamp\|generation" \
  > ~/app/infra-helm-charts/environnement/dev/app/configs/cert_manager/visiobook-tls-secret-backup.yaml

  ```