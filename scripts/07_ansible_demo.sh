#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_env.sh"

echo "==> Generating Ansible inventory from VM public IP"
VM_IP="$(az vm list-ip-addresses -g "$RESOURCE_GROUP" -n "$RHEL_VM_NAME" --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)"
echo "[rhel_servers]" > ../ansible/hosts.ini
echo "legacyhost ansible_host=${VM_IP} ansible_user=${ADMIN_USERNAME}" >> ../ansible/hosts.ini

echo "==> Running Ansible playbook to install Apache"
cd ../ansible
ansible-playbook -i hosts.ini install_httpd.yml
echo "==> Test in browser: http://${VM_IP}"
