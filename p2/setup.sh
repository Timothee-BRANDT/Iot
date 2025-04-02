#!/bin/bash
set -euo pipefail
# Exit on any error (-e), treat unset variables as errors (-u), and fail on errors in pipelines (-o pipefail)

###############################################################################
# Configuration variables
###############################################################################

NODE_IP="192.168.56.110"               # Static IP address of the k3s node
KUBECONFIG="/etc/rancher/k3s/k3s.yaml" # Path to the k3s kubeconfig file
DEPLOY_DIR="/vagrant/deploy"           # Directory containing Kubernetes YAML files
HOSTS="/etc/hosts"                     # System hosts file
DOMAINS=(app1.com app2.com app3.com)   # Domains to map to the local node in /etc/hosts

###############################################################################
# Functions
###############################################################################

# Update package index and install curl
install_curl() {
  apt-get update
  apt-get install -y curl
}

# Create a 1GB swap file if one doesn't exist
# Important on low-memory systems (<2GB RAM) as K3s may fail to start or apply resources without it
setup_swap() {
  if [ ! -f /swapfile ]; then
    echo "[+] Creating 1GB swap file..."

    fallocate -l 1G /swapfile         # Allocate a 1GB file for swap space
    chmod 600 /swapfile               # Restrict file permissions (read/write for root only)
    mkswap /swapfile                  # Format the file as swap
    swapon /swapfile                  # Enable the swap file
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab  # Make the swap file persistent on reboot

  else
    echo "[✓] Swap file already exists."
  fi
}

# Install K3s (a lightweight Kubernetes distribution) with a custom node IP and Traefik disabled
install_k3s() {
  echo "Installing K3s (node IP ${NODE_IP}, Traefik disabled)..."

  curl -sfL https://get.k3s.io | \
    INSTALL_K3S_EXEC="--disable traefik --node-ip ${NODE_IP}" sh -
}

# Set permissions for the kubeconfig file and export it for kubectl
config_kube() {
  chmod 644 "$KUBECONFIG" # Set read/write for owner and read-only for others
  export KUBECONFIG       # Export so kubectl uses the correct config
}

# Wait for the Kubernetes API to become available
wait_k8s() {
  echo "Waiting for Kubernetes API..."
  until kubectl get nodes &>/dev/null; do # Loop until "kubectl get nodes" succeeds
    sleep 2
  done
  echo "Kubernetes API ready."
}

# Apply Kubernetes resources: deployments, services, and ingress
apply_resources() {
  echo "Applying resources..."
  mkdir -p "$DEPLOY_DIR"
  for file in hello-apps.yaml services.yaml ingress.yaml; do
    kubectl apply --filename "$DEPLOY_DIR/$file"
  done
}

# Install Helm (Kubernetes package manager) if it is not already installed
install_helm() {
  if ! command -v helm &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  fi
}

# Install Traefik as the Ingress Controller using Helm
# Traefik routes external HTTP requests (e.g. app1.com) to the correct services in the cluster
install_traefik() {
  helm repo add traefik https://traefik.github.io/charts
  helm repo update

  kubectl get ns traefik &>/dev/null || kubectl create namespace traefik

  # Install Traefik with:
  # - host networking enabled (binds directly to the node's network interface)
  # - adjusted DNS policy for host networking
  helm install traefik traefik/traefik --namespace traefik \
    --set deployment.hostNetwork=true \
    --set deployment.dnsPolicy=ClusterFirstWithHostNet
}

# Add domain entries to /etc/hosts if they are not already present
update_hosts() {
  echo "Updating /etc/hosts..."
  for domain in "${DOMAINS[@]}"; do
    if ! grep -q "$domain" "$HOSTS"; then
      echo "${NODE_IP} ${domain}" >> "$HOSTS"
      echo "Added: ${NODE_IP} ${domain}"
    else
      echo "Entry for ${domain} already exists."
    fi
  done
}

###############################################################################
# Main execution sequence
###############################################################################

install_curl    # Update package index and install curl
# setup_swap      # Create swap file to prevent K3s from failing on low-memory systems
install_k3s     # Install k3s with custom options
config_kube     # Set permissions and export kubeconfig
wait_k8s        # Wait for Kubernetes API to become ready
apply_resources # Apply app resources: deployments, services, ingress
install_helm    # Install Helm if it's not already installed
install_traefik # Install Traefik Ingress Controller
update_hosts    # Add local domain entries to /etc/hosts

echo "Setup completed!"
