#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_env.sh"

echo "==> Creating SP for Azure Arc onboarding (RG scope)"
SP_JSON="$(az ad sp create-for-rbac -n "$ARC_SP_NAME" \
  --role "Azure Connected Machine Onboarding" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP")"
SP_APPID="$(echo "$SP_JSON" | jq -r .appId)"
SP_PASS="$(echo "$SP_JSON" | jq -r .password)"
echo "$SP_JSON" > ../outputs/arc_sp.json

echo "==> Installing Arc agent and connecting RHEL VM via RunCommand"
VM_SCRIPT=$(cat <<'EOS'
set -eux
if ! command -v azcmagent >/dev/null 2>&1; then
  curl -L https://aka.ms/azcmagent | sudo bash
fi
sudo azcmagent connect \
  --service-principal-id "${SP_APPID}" \
  --service-principal-secret "${SP_PASS}" \
  --resource-group "${RESOURCE_GROUP}" \
  --tenant-id "${TENANT_ID}" \
  --location "${LOCATION}" \
  --subscription-id "${SUBSCRIPTION_ID}" \
  --tags "Environment=Demo"
EOS
)

# run on VM
az vm run-command invoke -g "$RESOURCE_GROUP" -n "$RHEL_VM_NAME" \
  --command-id RunShellScript \
  --scripts "$VM_SCRIPT" \
  --parameters SP_APPID="$SP_APPID" SP_PASS="$SP_PASS" RESOURCE_GROUP="$RESOURCE_GROUP" \
              TENANT_ID="$TENANT_ID" LOCATION="$LOCATION" SUBSCRIPTION_ID="$SUBSCRIPTION_ID" >/dev/null || true

echo "==> (Optional) Connect ARO cluster to Arc (requires 'oc login')"
echo "If already logged in to the cluster context:"
echo "  az connectedk8s connect -g $RESOURCE_GROUP -n $ARO_CLUSTER --distribution openshift"
