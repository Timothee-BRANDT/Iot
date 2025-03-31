#!/bin/bash

confirm() {
    echo ""
    read -p "Continue with $1? y/Y  " choice
    case "$choice" in
        y|Y)
            return 0
            ;;
        *)
            echo "Skipping..."
            return 1
            ;;
    esac
}

# TODO: add source
if confirm "SETTING UP K3D cluster"; then
    k3d cluster create iot -p 8080:80@loadbalancer --agents 2
fi

if confirm "CREATE ARGO CD"; then
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
fi

if confirm "MAKE DEV NAMESAPCE"; then
    kubectl create namespace dev
fi


# launch argo cd port forward

# get argocd password

# connect argocd commandline

# 
