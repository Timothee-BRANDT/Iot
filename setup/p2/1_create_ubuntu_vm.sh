#!/bin/bash
set -euo pipefail

###############################################################################
# Configuration variables
###############################################################################

VM_NAME="ubuntu-vm"
VM_DISK="/var/lib/libvirt/images/${VM_NAME}.qcow2" # To change for "sgoinfre" directory instead
VM_RAM=8192
VM_VCPUS=4
VM_DISK_SIZE="20G"
ISO_URL="https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
ISO_PATH="/var/lib/libvirt/boot/ubuntu-22.04.iso" # To change for "sgoinfre" directory instead

###############################################################################
# Functions
###############################################################################

install_dependencies() {
  echo "[+] Installing virt-manager and required packages..."
  sudo apt update
  sudo apt install -y virt-manager qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils wget
}

prepare_iso() {
  echo "[+] Ensuring ISO directory exists..."
  sudo mkdir -p "$(dirname "$ISO_PATH")"

  if [ ! -f "$ISO_PATH" ]; then
    echo "[+] Downloading Ubuntu ISO..."
    sudo wget -O "$ISO_PATH" "$ISO_URL"
  else
    echo "[✓] ISO already exists at $ISO_PATH"
  fi
}

create_vm_disk() {
  echo "[+] Creating new VM disk image..."
  sudo qemu-img create -f qcow2 "$VM_DISK" "$VM_DISK_SIZE"
}

install_vm() {
  echo "[+] Starting VM installation..."
  sudo virt-install \
    --name "$VM_NAME" \
    --ram "$VM_RAM" \
    --vcpus "$VM_VCPUS" \
    --disk path="$VM_DISK",format=qcow2 \
    --cdrom "$ISO_PATH" \
    --os-variant ubuntu22.04 \
    --network network=default \
    --graphics spice \
    --boot cdrom,hd,menu=on \
    --noautoconsole
}

launch_virt_manager() {
  echo "[+] Launching virt-manager GUI..."
  if command -v virt-manager &>/dev/null; then
    virt-manager &
    echo "[✓] virt-manager started in background."
  else
    echo "[!] virt-manager not found. Please install it and launch manually."
  fi
}

###############################################################################
# Main execution sequence
###############################################################################

install_dependencies
prepare_iso
create_vm_disk
install_vm

echo "[✓] All setup tasks completed successfully! You can now continue installation via graphical interface."

launch_virt_manager

###############################################################################
# Post-installation instructions
###############################################################################

cat <<EOF
============================================================
🖥️  VM Installation Instructions (Graphical Mode)
------------------------------------------------------------
1. Once virt-manager opens, double-click on the VM named '${VM_NAME}'.

2. Proceed through the installation wizard by selecting "Continue" or "Done",
   **unless** the following options appear:

   - When asked to "Choose the type of installation", select:
     → **Ubuntu Server (minimized)**

   - At the "SSH configuration" step, be sure to select:
     → **Install OpenSSH server**

3. After the installation is complete, select the "Reboot" option. After rebooting,
   relaunch the VM in virt-manager by right-clicking on it and selecting "Run".

4. Once the VM has rebooted, launch the second script using bash.
============================================================
EOF

