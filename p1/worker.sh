#!/bin/bash
# Get the master node's IP from the arguments
MASTER_IP=$1

# https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-22-04
# Create a 1GB swap file if one doesn't exist
# Important on low-memory systems (<1GB RAM)
if [ ! -f /swapfile ]; then
  echo "[+] Creating 1GB swap file..."
  fallocate -l 1G /swapfile             # Allocate a 1GB file for swap space
  chmod 600 /swapfile                   # Restrict file permissions (read/write for root only)
  mkswap /swapfile                      # Format the file as swap
  swapon /swapfile                      # Enable the swap file
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab  # Make swap persistent on reboot
else
  echo "[✓] Swap file already exists."
fi

# Wait until the token file is available and non-empty
while [ ! -s /vagrant/token ]; do
    echo "Waiting for token file to be available..."
    sleep 2
done

# Get the token from the shared folder
TOKEN=$(cat /vagrant/token)

# Update packages and install curl
sudo apt-get update && sudo apt-get install -y curl

# https://kubernetes.io/docs/reference/networking/ports-and-protocols/
# Install K3s agent (worker) and join the master node
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$TOKEN INSTALL_K3S_EXEC="--flannel-iface=eth1" sh -
