#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_env.sh"

echo "==> Registering resource providers (idempotent)"
for ns in Microsoft.RedHatOpenShift \
 Microsoft.Compute Microsoft.Network Microsoft.OperationalInsights \
 Microsoft.Security Microsoft.SecurityInsights Microsoft.Kubernetes \
 Microsoft.KubernetesConfiguration Microsoft.HybridCompute Microsoft.GuestConfiguration; do
  az provider register --namespace "$ns" --wait || true
done

echo "==> Installing Azure CLI extensions (idempotent)"

# Known good and supported extensions
EXTS=(
  aro
  connectedk8s
  k8s-configuration
  k8s-extension
  sentinel
)

for ext in "${EXTS[@]}"; do
  if ! az extension show --name "$ext" >/dev/null 2>&1; then
    echo "🔹 Installing extension: $ext"
    az extension add --name "$ext" --upgrade --allow-preview true || echo "⚠️ Failed to install $ext, continuing..."
  else
    echo "🔹 Updating extension: $ext"
    az extension update --name "$ext" || echo "⚠️ Failed to update $ext, continuing..."
  fi
done

echo "==> Extension installation complete."

echo "==> Prereqs complete."
