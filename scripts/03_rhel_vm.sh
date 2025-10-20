#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_env.sh"

echo "==> Creating RHEL VM"
az vm create -g "$RESOURCE_GROUP" -n "$RHEL_VM_NAME" \
  --image RedHat:RHEL:9-lvm-gen2:latest \
  --size "$RHEL_VM_SIZE" \
  --admin-username "$ADMIN_USERNAME" --generate-ssh-keys \
  --public-ip-sku Standard 1>/dev/null

VM_IP="$(az vm list-ip-addresses -g "$RESOURCE_GROUP" -n "$RHEL_VM_NAME" --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)"
echo "$VM_IP" > ../outputs/rhel_public_ip.txt

echo "==> Opening port 80 (HTTP) for demo (Apache test page)"
az vm open-port -g "$RESOURCE_GROUP" -n "$RHEL_VM_NAME" --port 80 --priority 1001 >/dev/null

echo "RHEL VM created. Public IP: $VM_IP"
