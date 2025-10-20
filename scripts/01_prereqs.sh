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
for ext in aro monitor connectedk8s k8s-configuration k8s-extension security sentinel; do
  az extension add --name "$ext" --upgrade || true
done

echo "==> Prereqs complete."
