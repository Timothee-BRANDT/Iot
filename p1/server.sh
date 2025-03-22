#!/bin/bash
# The $1 will correspond to args: ["192.168.56.110"] passed in the vagrant file when the script runs
SERVER_IP=$1
# Install K3s on the master node
# --bind-address=${SERVER_IP} : we tell k3s to use $1 as the address for the private network
# --flannel-iface=eth1 : eth0 (NAT = Internet access) is used by default, so we need to specify we want to use the private network 
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--bind-address=${SERVER_IP} --flannel-iface=eth1" sh -

# Make sure kubectl is set up for the vagrant user
# Create the kubeclt config directory (-p no error if already exist)
sudo mkdir -p /home/vagrant/.kube
# copy the k3s config to the VM kubectl config directory, allowing the user to run kubectl commands
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
# makes the user and group vagrant owns the kube/config file, since we're connecting in ssh using vagrant ssh
sudo chown -R vagrant:vagrant /home/vagrant/.kube/config

# Get the token for the worker nodes (allowing the worker to join the cluster)
TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# Store the token for the workers to use
echo $TOKEN > /vagrant/token
