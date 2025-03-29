#!/bin/bash

# TODO: add source
echo "SETTING UP K3D cluster"
k3d cluster create iot -p 8080:80@loadbalancer --agents 2

echo "MAKE ARGO NAMESPACE" 
kubectl create namespace argocd

echo "APPLY ARGO CD CONFIG"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# after

echo "MAKE DEV NAMESAPCE"
kubectl create namespace dev