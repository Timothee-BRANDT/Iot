#!/bin/bash
# Get the master node's IP from the arguments
MASTER_IP=$1

# Wait until the token file is available and non-empty
while [ ! -s /vagrant/token ]; do
    echo "Waiting for token file to be available..."
    sleep 2
done

# Get the token from the shared folder
TOKEN=$(cat /vagrant/token)

# https://kubernetes.io/docs/reference/networking/ports-and-protocols/
# Install K3s agent (worker) and join the master node
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$TOKEN INSTALL_K3S_EXEC="--flannel-iface=eth1" sh -
