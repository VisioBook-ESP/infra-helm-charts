setup:
	@echo "Configuration de l'environnement de développement..."
	@$(MAKE) setup-minikube
	@$(MAKE) setup-helm
	@$(MAKE) setup-argocd
	@$(MAKE) setup-k9s

setup-minikube:
	./scripts/install_minikube.sh && echo "Minikube a été configuré."

setup-helm:
	./scripts/install_helm.sh && echo "Helm a été configuré."

setup-argocd:
	./scripts/install_argocd.sh && echo "ArgoCD a été installé."

setup-k9s:
	./scripts/install_k9s.sh && echo "K9s a été installé."
