# Iot

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
