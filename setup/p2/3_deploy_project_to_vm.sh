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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_PROJECT_PATH="${SCRIPT_DIR}/p2"
REMOTE_DESTINATION="~/"

###############################################################################
# Validation
###############################################################################

if [ ! -d "$LOCAL_PROJECT_PATH" ]; then
  echo "[!] Error: 'p2' directory not found in the script's location: $SCRIPT_DIR"
  exit 1
fi

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

copy_project_files() {
  echo "[+] Copying 'p2' project directory to remote host..."

  scp -r "$LOCAL_PROJECT_PATH" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DESTINATION}"

  echo "[✓] Project directory copied to ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DESTINATION}"
}

open_interactive_ssh() {
  echo "[+] Connecting to remote host ($REMOTE_HOST)..."
  ssh "${REMOTE_USER}@${REMOTE_HOST}"
}

###############################################################################
# Main execution sequence
###############################################################################

wait_for_vm_ip
wait_for_ssh
copy_project_files
open_interactive_ssh
