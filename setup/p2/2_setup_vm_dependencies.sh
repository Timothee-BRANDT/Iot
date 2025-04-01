#!/bin/bash
set -euo pipefail

###############################################################################
# Prompt user
###############################################################################

read -rp "Enter the remote SSH username: " REMOTE_USER
read -rsp "Enter the remote sudo password: " SUDO_PASS
echo

###############################################################################
# Configuration variables
###############################################################################

VM_NAME="ubuntu-vm"

###############################################################################
# Functions
###############################################################################

wait_for_vm_ip() {
  echo "[+] Waiting for VM '$VM_NAME' to obtain an IP address..."

  for i in {1..30}; do
    IP=$(sudo virsh domifaddr "$VM_NAME" | awk '/ipv4/ { print $4 }' | cut -d/ -f1)
    if [[ -n "$IP" ]]; then
      echo "[✓] Found VM IP: $IP"
      export REMOTE_HOST="$IP"
      return 0
    fi
    sleep 10
  done

  echo "[!] Failed to detect VM IP address after timeout."
  exit 1
}

wait_for_ssh() {
  echo "[+] Waiting for remote host ($REMOTE_HOST) to accept SSH connections..."

  for i in {1..30}; do
    if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "${REMOTE_USER}@${REMOTE_HOST}" 'echo "[✓] SSH is up."' 2>/dev/null; then
      return 0
    fi
    sleep 10
  done

  echo "[!] SSH connection to $REMOTE_HOST failed after timeout."
  exit 1
}

generate_and_copy_ssh_key() {
  if [[ ! -f "$HOME/.ssh/id_rsa.pub" ]]; then
    echo "[+] SSH key not found. Generating one..."
    ssh-keygen -t rsa -b 4096 -N "" -f "$HOME/.ssh/id_rsa"
  fi

  echo "[+] Copying SSH public key to remote host ($REMOTE_HOST)..."
  ssh-copy-id -o StrictHostKeyChecking=no "${REMOTE_USER}@${REMOTE_HOST}"
}

install_virtualbox_and_vagrant() {
  echo "[+] Connecting to remote host to install VirtualBox, Vagrant, Git, and dependencies..."

  ssh -o ConnectTimeout=5 "${REMOTE_USER}@${REMOTE_HOST}" "export SUDO_PASS='$SUDO_PASS'; bash -s" <<'EOF'
set -euo pipefail

echo "[+] Adding VirtualBox GPG key and repository..."
echo "$SUDO_PASS" | sudo -S curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc -o /tmp/oracle_vbox_2016.asc
echo "$SUDO_PASS" | sudo -S gpg --dearmor -o /usr/share/keyrings/vbox.gpg /tmp/oracle_vbox_2016.asc

echo "[+] Adding VirtualBox apt source..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vbox.gpg] https://download.virtualbox.org/virtualbox/debian jammy contrib" | sudo -S tee /etc/apt/sources.list.d/virtualbox.list

echo "[+] Updating packages..."
echo "$SUDO_PASS" | sudo -S apt update

echo "[+] Installing VirtualBox 7.0..."
echo "$SUDO_PASS" | sudo -S apt install -y virtualbox-7.0

echo "[+] Installing Vagrant..."
echo "$SUDO_PASS" | sudo -S apt install -y vagrant

echo "[+] Installing Git..."
echo "$SUDO_PASS" | sudo -S apt install -y git

echo "[+] Installing libvirt dependencies..."
echo "$SUDO_PASS" | sudo -S apt install -y libvirt-daemon-system libvirt-clients

echo "[+] Adding user to 'libvirt' group..."
echo "$SUDO_PASS" | sudo -S usermod -a -G libvirt "$USER"

echo "[✓] VirtualBox, Vagrant, Git, and dependencies installation complete."

echo "[+] Rebooting the remote host..."
echo "$SUDO_PASS" | nohup sudo -S reboot &>/dev/null &
EOF
}

###############################################################################
# Main execution sequence
###############################################################################

wait_for_vm_ip
wait_for_ssh
generate_and_copy_ssh_key
install_virtualbox_and_vagrant

echo "[✓] All setup tasks completed successfully!"

###############################################################################
# Post-installation instructions
###############################################################################

cat <<EOF
============================================================
🔑 Final Step: Add SSH Key to GitHub/GitLab
------------------------------------------------------------
To use your system with Git-based tools like GitHub or GitLab,
you should generate a new ECDSA SSH key and add it to your profile.

Follow these steps after connecting to the VM via SSH:

1. Generate an ECDSA SSH key:
   → ssh-keygen -t ecdsa

2. Display the public key:
   → cat ~/.ssh/id_ecdsa.pub

3. Copy the key and go to your Git provider (e.g., GitHub):
   → In GitHub, go to:
     Settings → SSH and GPG Keys → New SSH key

4. Paste your key there and save.

💡 This allows passwordless Git interactions and improves security.
============================================================
EOF
