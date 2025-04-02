#!/bin/bash

NODE_IP="192.168.56.110"               # Static IP address of the k3s node
DOMAINS=(app1.com app2.com app3.com)   # Domains to map to the local node in /etc/hosts

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

update_hosts
