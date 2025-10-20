#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_env.sh"

echo "==> Enable Microsoft Defender for Cloud plans (VMs, K8s, Container Registry)"
az security pricing create --name VirtualMachines --tier Standard >/dev/null
az security pricing create --name KubernetesService --tier Standard >/dev/null
az security pricing create --name ContainerRegistry --tier Standard >/dev/null

echo "==> Link Defender to the Log Analytics workspace"
WS_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/$LOG_ANALYTICS_WS"
az security workspace-setting create --name default --target-workspace "$WS_ID" >/dev/null || true

echo "==> Onboard Microsoft Sentinel to the workspace"
# Use REST as CLI coverage can vary across versions
az rest --method PUT \
  --url "https://management.azure.com$WS_ID/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2022-11-01-preview" \
  --body '{"properties":{"onboardingState":"Onboarded"}}' >/dev/null || true

echo "==> Defender & Sentinel baseline enabled."
