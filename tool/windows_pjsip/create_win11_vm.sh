#!/usr/bin/env bash
set -euo pipefail

VM_NAME="${VM_NAME:-pjsip-win11}"
ISO_PATH="${ISO_PATH:-/Users/galaxybook/Downloads/Win11_25H2_Chinese_Simplified_x64_v2.iso}"
VM_BASE="${VM_BASE:-/Users/galaxybook/VirtualBox VMs}"
DISK_SIZE_MB="${DISK_SIZE_MB:-81920}"
MEMORY_MB="${MEMORY_MB:-8192}"
CPUS="${CPUS:-4}"
BRIDGE_IF="${BRIDGE_IF:-en0: Wi-Fi}"
PROJECT_DIR="${PROJECT_DIR:-/Users/galaxybook/Desktop/ldt/pjsip_lib}"

VM_DIR="${VM_BASE}/${VM_NAME}"
DISK_PATH="${VM_DIR}/${VM_NAME}.vdi"

if ! command -v VBoxManage >/dev/null 2>&1; then
  echo "VBoxManage not found. Install VirtualBox first."
  exit 1
fi

if [[ ! -f "${ISO_PATH}" ]]; then
  echo "ISO not found: ${ISO_PATH}"
  exit 1
fi

mkdir -p "${VM_BASE}"

if ! VBoxManage showvminfo "${VM_NAME}" >/dev/null 2>&1; then
  VBoxManage createvm \
    --name "${VM_NAME}" \
    --ostype Windows11_64 \
    --basefolder "${VM_BASE}" \
    --register
fi

VBoxManage modifyvm "${VM_NAME}" \
  --memory "${MEMORY_MB}" \
  --cpus "${CPUS}" \
  --firmware efi \
  --chipset ich9 \
  --ioapic on \
  --pae on \
  --nestedpaging on \
  --graphicscontroller vboxsvga \
  --vram 128 \
  --clipboard bidirectional \
  --draganddrop bidirectional \
  --audio-driver coreaudio \
  --audio-enabled on \
  --audio-controller hda \
  --audio-in on \
  --audio-out on \
  --nic1 bridged \
  --bridgeadapter1 "${BRIDGE_IF}" \
  --boot1 dvd \
  --boot2 disk

# Windows 11 needs TPM 2.0. VirtualBox 7 supports this flag; if a local build
# does not, continue and let the GUI show the available TPM option.
VBoxManage modifyvm "${VM_NAME}" --tpm-type 2.0 >/dev/null 2>&1 || true

if [[ ! -f "${DISK_PATH}" ]]; then
  VBoxManage createmedium disk \
    --filename "${DISK_PATH}" \
    --size "${DISK_SIZE_MB}" \
    --format VDI
fi

if ! VBoxManage showvminfo "${VM_NAME}" --machinereadable | grep -q '^storagecontrollername0='; then
  VBoxManage storagectl "${VM_NAME}" \
    --name "SATA" \
    --add sata \
    --controller IntelAhci \
    --bootable on
fi

VBoxManage storageattach "${VM_NAME}" \
  --storagectl "SATA" \
  --port 0 \
  --device 0 \
  --type hdd \
  --medium "${DISK_PATH}"

VBoxManage storageattach "${VM_NAME}" \
  --storagectl "SATA" \
  --port 1 \
  --device 0 \
  --type dvddrive \
  --medium "${ISO_PATH}"

VBoxManage sharedfolder add "${VM_NAME}" \
  --name pjsip_lib \
  --hostpath "${PROJECT_DIR}" \
  --automount \
  --auto-mount-point Z: >/dev/null 2>&1 || true

echo "VM is ready: ${VM_NAME}"
echo "Start it with:"
echo "  VBoxManage startvm \"${VM_NAME}\""
echo ""
echo "After Windows is installed, install Guest Additions, Flutter, and Visual Studio."
echo "Inside Windows, the shared project should appear as Z:\\ or under \\\\VBOXSVR\\pjsip_lib."
