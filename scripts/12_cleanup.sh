#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_env.sh"

read -rp "This will DELETE resource group $RESOURCE_GROUP and all resources. Are you sure? (y/N) " yn
if [[ "${yn:-N}" =~ ^[Yy]$ ]]; then
  az group delete -n "$RESOURCE_GROUP" --yes --no-wait
  echo "Delete initiated."
else
  echo "Aborted."
fi
