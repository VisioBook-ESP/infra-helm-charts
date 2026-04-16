# Accès API Kubernetes depuis la CI (GitHub Actions)

## Prérequis

- Accès SSH au VPS OVH
- `kubectl` configuré sur le VPS
- Accès admin au repo GitHub (pour les secrets)

---

## 1. Appliquer les manifests

```bash
kubectl apply -f ci-deployer-sa.yaml
```

Vérifier que tout est créé :

```bash
kubectl get sa ci-deployer -n visiobook-namespace
kubectl get clusterrolebinding ci-deployer-binding
kubectl get secret ci-deployer-token -n visiobook-namespace
```

---

## 2. Récupérer le token

```bash
kubectl get secret ci-deployer-token -n visiobook-namespace \
  -o jsonpath='{.data.token}' | base64 -d
```

Copier la valeur affichée, elle sera utilisée comme secret GitHub.

---

## 3. Exposer l'API server (port-forward systemd)

Créer le service systemd :

```bash
sudo tee /etc/systemd/system/kube-api-forward.service <<EOF
[Unit]
Description=Port forward Kubernetes API server
After=network.target

[Service]
ExecStart=/usr/local/bin/kubectl port-forward -n default svc/kubernetes 6443:443 --address=0.0.0.0
Restart=always
RestartSec=5
User=debian

[Install]
WantedBy=multi-user.target
EOF
```

Activer et démarrer :

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now kube-api-forward
sudo systemctl status kube-api-forward
```

---

## 4. Ouvrir le firewall

```bash
# Ouvrir le port 6443
sudo ufw allow 6443/tcp

# Vérifier
sudo ufw status
```

> **Optionnel** : restreindre aux IPs des runners GitHub Actions pour plus de sécurité.
> Les plages IP sont listées sur https://api.github.com/meta (clé `actions`).

---

## 5. Tester la connexion

Depuis une machine externe (pas le VPS) :

```bash
TOKEN="<token-de-l-étape-2>"
VPS_IP="<ip-du-vps>"

curl -k -H "Authorization: Bearer $TOKEN" https://$VPS_IP:6443/api/v1/namespaces
```

Résultat attendu : JSON avec la liste des namespaces.

---

## 6. Configurer les secrets GitHub

Aller dans **Settings > Secrets and variables > Actions** du repo et ajouter :

| Nom du secret  | Valeur                      |
| -------------- | --------------------------- |
| `K8S_TOKEN`    | Le token de l'étape 2       |
| `K8S_SERVER`   | `https://<ip-vps>:6443`     |

---

## 7. Utilisation dans un workflow GitHub Actions

```yaml
- name: Setup kubectl
  uses: azure/setup-kubectl@v3

- name: Configure kubeconfig
  run: |
    kubectl config set-cluster vps \
      --server=${{ secrets.K8S_SERVER }} \
      --insecure-skip-tls-verify
    kubectl config set-credentials ci \
      --token=${{ secrets.K8S_TOKEN }}
    kubectl config set-context ci \
      --cluster=vps \
      --user=ci \
      --namespace=visiobook-namespace
    kubectl config use-context ci

- name: Verify connection
  run: kubectl get nodes
```

---

## Dépannage

| Problème | Solution |
| --- | --- |
| `connection refused` sur 6443 | Vérifier `systemctl status kube-api-forward` et `ufw status` |
| `Unauthorized` | Vérifier que le token est correct et que le Secret est bien lié au SA |
| Port-forward qui tombe | Le service systemd redémarre automatiquement (`Restart=always`) |
| Timeout | Vérifier que le port 6443 est ouvert côté hébergeur (panel OVH) |
