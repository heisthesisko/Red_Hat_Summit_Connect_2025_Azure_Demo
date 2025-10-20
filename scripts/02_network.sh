#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_env.sh"

echo "==> Creating resource group"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" >/dev/null

echo "==> Creating virtual network and subnets for ARO"
az network vnet create -g "$RESOURCE_GROUP" -n "$VNET_NAME" --address-prefixes 10.0.0.0/22 >/dev/null

az network vnet subnet create -g "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" -n "$MASTER_SUBNET" \
  --address-prefixes 10.0.0.0/23 --service-endpoints Microsoft.ContainerRegistry >/dev/null

az network vnet subnet create -g "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" -n "$WORKER_SUBNET" \
  --address-prefixes 10.0.2.0/23 --service-endpoints Microsoft.ContainerRegistry >/dev/null

echo "==> Disabling private link service network policies on master subnet (ARO requirement)"
az network vnet subnet update -g "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" -n "$MASTER_SUBNET" \
  --disable-private-link-service-network-policies true >/dev/null

echo "==> Network complete."
