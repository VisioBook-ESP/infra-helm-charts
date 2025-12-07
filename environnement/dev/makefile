setup:
	@echo "Configuration de l'environnement de développement..."
	@$(MAKE) setup-minikube
	@$(MAKE) clean-minikube
	@$(MAKE) setup-helm
	@$(MAKE) setup-k9s
	@$(MAKE) setup-argocd
	@$(MAKE) setup-argocd-image-updater
	@$(MAKE) setup-istioctl
	@$(MAKE) deploy-applications

setup-k8s:
	@echo "Configuration de l'environnement de développement..."
	@$(MAKE) setup-storage
	@$(MAKE) setup-k9s
	@$(MAKE) setup-argocd
	@$(MAKE) setup-argocd-image-updater
	@$(MAKE) setup-istioctl
	@$(MAKE) deploy-applications

setup-ci:
	@echo "Configuration de l'environnement de développement..."
	@$(MAKE) setup-minikube
	@$(MAKE) clean-minikube
	@$(MAKE) setup-helm
	@$(MAKE) setup-k9s
	@$(MAKE) setup-argocd
	@$(MAKE) setup-argocd-image-updater
	@$(MAKE) setup-istioctl
	@$(MAKE) deploy-applications
	@$(MAKE) test-connectivity

clean-minikube:
	@echo "Nettoyage de Minikube..."
	minikube delete --all && echo "Minikube a été nettoyé."
	minikube start && echo "Minikube a été démarré."

setup-minikube:
	./scripts/install_minikube.sh && echo "Minikube a été configuré."

setup-helm:
	./scripts/install_helm.sh && echo "Helm a été configuré."

setup-argocd:
	./scripts/install_argocd.sh && echo "ArgoCD a été installé."

setup-k9s:
	./scripts/install_k9s.sh && echo "K9s a été installé."

setup-argocd-image-updater:
	./scripts/install_argo_image_updater.sh && echo "Argocd Image Updater a été installé."

setup-istioctl:
	./scripts/installIstioCtl.sh && echo "Istioctl a été installé."

deploy-applications:
	./scripts/deploy_applications.sh && echo "L'application a été déployée."

wait:
	sleep 400

test-connectivity:
	./scripts/test_connectivity.sh && echo "Tests de connectivité terminés."

clean-k8s:
	@echo "Nettoyage du cluster Kubernetes..."
	@echo "Suppression des namespaces..."
	@kubectl delete namespace argocd --ignore-not-found=true --wait=false
	@kubectl delete namespace database --ignore-not-found=true --wait=false
	@kubectl delete namespace backend --ignore-not-found=true --wait=false
	@kubectl delete namespace istio-system --ignore-not-found=true --wait=false
	@echo "Forçage de la suppression des finalizers..."
	@kubectl get namespace argocd -o json 2>/dev/null | jq '.spec.finalizers = []' | kubectl replace --raw /api/v1/namespaces/argocd/finalize -f - 2>/dev/null || true
	@kubectl get namespace database -o json 2>/dev/null | jq '.spec.finalizers = []' | kubectl replace --raw /api/v1/namespaces/database/finalize -f - 2>/dev/null || true
	@kubectl get namespace backend -o json 2>/dev/null | jq '.spec.finalizers = []' | kubectl replace --raw /api/v1/namespaces/backend/finalize -f - 2>/dev/null || true
	@kubectl get namespace istio-system -o json 2>/dev/null | jq '.spec.finalizers = []' | kubectl replace --raw /api/v1/namespaces/istio-system/finalize -f - 2>/dev/null || true
	@echo "Attente de la suppression complète..."
	@sleep 3
	@kubectl wait --for=delete namespace/argocd --timeout=30s 2>/dev/null || echo "✓ argocd supprimé"
	@kubectl wait --for=delete namespace/database --timeout=30s 2>/dev/null || echo "✓ database supprimé"
	@kubectl wait --for=delete namespace/backend --timeout=30s 2>/dev/null || echo "✓ backend supprimé"
	@kubectl wait --for=delete namespace/istio-system --timeout=30s 2>/dev/null || echo "✓ istio-system supprimé"
	@echo "✓ Cluster nettoyé"

clean-all-k8s:
	@echo "⚠️  ATTENTION: Réinitialisation complète du cluster K8s..."
	@read -p "Êtes-vous sûr? Cela va TOUT supprimer [y/N]: " confirm && [ "$$confirm" = "y" ]
	sudo kubeadm reset -f
	sudo rm -rf /etc/cni /etc/kubernetes /var/lib/kubelet /var/lib/etcd ~/.kube
	sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
	@echo "Cluster complètement réinitialisé. Relancez l'installation avec kubeadm init."

setup-storage:
	@echo "Configuration du stockage persistant..."
	./scripts/setup-storage.sh
	@echo "✓ Stockage configuré"