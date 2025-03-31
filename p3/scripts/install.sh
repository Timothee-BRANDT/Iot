#!/bin/bash

confirm() {
    read -p "Continue with $1? y/Y  " choice
    case "$choice" in
        y|Y)
            echo "Running..."
            return 0
            ;;
        *)
            echo "Skipping..."
            return 1
            ;;
    esac
}

# https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
if confirm "INSTALL docker"; then
    wget -qO get-docker.sh https://get.docker.com
    sudo sh get-docker.sh

# https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
    echo "MANAGE DOCKER AS NON ROOT USER"
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
fi

# https://k3d.io/stable/#install-current-latest-release
if confirm "INSTALL k3d"; then
    wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
if confirm "INSTALL kubectl"; then
    wget -O kubectl "https://dl.k8s.io/release/$(wget -qO- https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

# https://argo-cd.readthedocs.io/en/stable/cli_installation/#download-with-curl
if confirm "INSTALL ARGO CD CLI"; then
    wget -qO argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64
fi

