setup:
	@echo "Configuration de l'environnement de développement..."
	@$(MAKE) setup-minikube
	@$(MAKE) clean-and-start-minikube
	@$(MAKE) setup-helm
	@$(MAKE) setup-k9s
	@$(MAKE) setup-argocd
	@$(MAKE) setup-argocd-image-updater


clean-and-start-minikube:
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
