
 az aks get-credentials -g rg-aks -n aks-basic --admin

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

kubectl port-forward svc/argocd-server -n argocd 8080:80
kubectl -n istio-system port-forward svc/kiali 20001:20001


 terraform destroy  -auto-approve
 terraform apply -target=azurerm_kubernetes_cluster.aks -auto-approve
 terraform apply -auto-approve