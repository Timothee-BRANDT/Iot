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
    k3d cluster create iot -p 8080:80@loadbalancer -p 8888:8888@loadbalancer --agents 2 --k3s-arg "--disable=traefik@server:0"
fi


# https://argo-cd.readthedocs.io/en/stable/getting_started/#3-access-the-argo-cd-api-server
if confirm "CREATE ARGO CD"; then
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    echo "...sleeping for 30 seconds"
    sleep 30
    echo  "applying loadbalancer patch"
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
    echo "...sleeping for 10 seconds"
    sleep 10
fi

if confirm "GET PASSWORD & LOGIN"; then
    PASSWORD="$(argocd admin initial-password -n argocd | head -n 1)"
    echo $PASSWORD
    yes | argocd login localhost:8080 --username admin --password "$PASSWORD"
fi

if confirm "MAKE DEV NAMESAPCE"; then
    kubectl create namespace dev
fi

if confirm "CREATE APP"; then
    #kubectl config set-context --current --namespace=argocd
    argocd app create wil --repo https://github.com/znichola/tbrandt.git --path manifest --dest-server https://kubernetes.default.svc --dest-namespace dev
    sleep 5
    arogcd app get wil
fi

if confirm "SYNC APP"; then
    argocd app sync wil
    argocd app set wil --sync-policy automated --self-heal
fi


# if confirm "PORTFORWARD will app"; then
#    kubectl port-forward deployments/wil-deployment 8888:8888 -n dev
# fi

# launch argo cd port forward

# get argocd password

# connect argocd commandline

#
