#!/usr/bin/env bash
set -euo pipefail

# === Global Environment ===
# Adjust to your preferences before running scripts.

export LOCATION="${LOCATION:-eastus}"
export RESOURCE_GROUP="${RESOURCE_GROUP:-migrate-innovate-rg}"
export RANDOM_ID="${RANDOM_ID:-$RANDOM}"
export VNET_NAME="${VNET_NAME:-aro-vnet}"
export MASTER_SUBNET="${MASTER_SUBNET:-master-subnet}"
export WORKER_SUBNET="${WORKER_SUBNET:-worker-subnet}"

# ARO settings
export ARO_CLUSTER="${ARO_CLUSTER:-ai-ready-cluster}"
export WORKER_SIZE="${WORKER_SIZE:-Standard_D4s_v5}"
export WORKER_COUNT="${WORKER_COUNT:-3}"
# Optional pull secret file from Red Hat (recommended for Operators)
export PULL_SECRET_FILE="${PULL_SECRET_FILE:-./pull-secret.txt}"

# RHEL VM settings
export RHEL_VM_NAME="${RHEL_VM_NAME:-legacy-rhel}"
export RHEL_VM_SIZE="${RHEL_VM_SIZE:-Standard_D2s_v5}"
export ADMIN_USERNAME="${ADMIN_USERNAME:-azureuser}"

# Logging / Security
export LOG_ANALYTICS_WS="${LOG_ANALYTICS_WS:-aiops-law-$RANDOM_ID}"

# Arc onboarding service principal (least privilege for onboarding)
export ARC_SP_NAME="${ARC_SP_NAME:-arc-onboarder-$RANDOM_ID}"

# Convenience
export SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
export TENANT_ID="${TENANT_ID:-$(az account show --query tenantId -o tsv)}"

mkdir -p ../outputs

echo "Environment loaded."
echo "SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo "TENANT_ID      : $TENANT_ID"
