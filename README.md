# Inception of Things

[Kubernetes](https://kubernetes.io/) aka k8s and using [k3s](https://k3s.io/) with [k3d](https://k3d.io/), it's a dev ops project.

## VM quickstart

> :warning: `ctrl` + `alt` to relase the mouse/keyboard from the vm

On the school computers create a vm with Virtual Machine Manager. You need to downlaod the ubuntu LTS to goinfre: 

```bash
cd ~/goinfre && wget https://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-desktop-amd64.iso
```

Launch VMM, create a new volume on groinfre (goinfre is the local disc, the vm will be more responsive), 20 gigs is fine. Then create a virtual machine using this new volume and the downloaded iso. Follow ubuntu instrution to complete installation.


# Part 1

AUTO-SCALE : Need more containers ? Just deploy more machine

HIGH-AVAILABILITY : One machine is down ? Instant replace with a new one

CLUSTER : System deployed on Kubernetes

CONTROL-PLANE : API that can handle internal and external requests to manage the nodes cluster, got his own key value database
called etcd that store information about running the cluster

Each node is running a kubelet (app that communicate back with the main control plane)

Inside of each node, we have multiple pods (docker container)

k3s = kubernetes distribution (3 is more than 8, mean it's more approchable and less complex than k8s)
k3s default ingress controller = traefik
1 container runtime at installation time - containerd
virtual networking - flannel
cluster service discovery - CoreDNS
Embedded load balander - Klipper-lb

Difference with classic k8s : cloud provider-specific code (replaced by Cloud Control Manager)
third party-specific storage drivers (replaced by Container Storage Interface)

Nodes in k3s can also perform work (maybe that's why in the Part 2 of the project, we can run the applications with only 1 VM)

 It is STRONGLY advised to allow only the bare minimum in terms of resources: 1 CPU, 512 MB of RAM (or 1024). The machines must be run using Vagrant. (This rule in the subject i guess is to prevent adding any work on the node, you can run k3s with that amount of ressources because it's the amount required for the control plane function to work, not more)

Any type of other kubernetes distribution would need at least double of that ressources to run. (how ? k3s is packaged as a single binary)

K8S -> Every node got his own control plane
K3S -> One control plane, n nodes

How to check K3s is running ? 
sudo systemctl status k3s (server node)
sudo systemctl status k3s-agent (worker node)

## Resources


- https://portal.cloud.hashicorp.com/vagrant/discover/bento/ubuntu-22.04

- https://medium.com/@dharsannanantharaman/create-a-high-availabilty-lightweight-kubernetes-k3s-cluster-using-vagrant-822a1e025855

- https://docs.k3s.io/architecture

- https://docs.k3s.io/cluster-access

- https://kubernetes.io/docs/reference/networking/ports-and-protocols/

---

# Part 2

---

# Part 3 

## Usefull commands

```bash
# configs
kubectl config view

kubectl apply  -f file.yaml -n namespace

kubectl delete -f file.yaml -n namespace

kubectl get namespaces

k3d cluster delte somename

argocd app [list|delete|..etc]
```

## Setup

- Install [k3d](https://k3d.io/stable/#releases) which is a wrapper to run k3s in docker and k3s is a lightweight k8s runtime. Basically test Kubernetes stuff on your laptop without spinning up a nuclear reactor.

- Install vscode extension [vscode-k3d](https://github.com/inercia/vscode-k3d/) to make managing everything easier.

## Resources

- https://kubernetes.io/docs/concepts/overview/components/

- https://www.sokube.io/blog/k3s-k3d-k8s-a-new-perfect-match-for-dev-and-test

- https://www.sokube.io/blog/gitops-on-a-laptop-with-k3d-and-argocd

- https://helm.sh/docs/intro/using_helm/

- https://kubernetes.io/docs/reference/kubectl/quick-reference/#kubectl-context-and-configuration


