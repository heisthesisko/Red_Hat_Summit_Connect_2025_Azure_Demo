#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_env.sh"

echo "==> Creating Log Analytics Workspace"
LAW_ID=$(az monitor log-analytics workspace create -g "$RESOURCE_GROUP" -n "$LOG_ANALYTICS_WS" -l "$LOCATION" --query "customerId" -o tsv)
LAW_KEY=$(az monitor log-analytics workspace get-shared-keys -g "$RESOURCE_GROUP" -n "$LOG_ANALYTICS_WS" --query "primarySharedKey" -o tsv)
echo "$LAW_ID" > ../outputs/law_id.txt

echo "==> Onboarding RHEL VM to Log Analytics (legacy OMS agent for simplicity)"
az vm extension set -g "$RESOURCE_GROUP" -n OmsAgentForLinux --publisher Microsoft.EnterpriseCloud.Monitoring \
  --vm-name "$RHEL_VM_NAME" \
  --settings "{"workspaceId":"$LAW_ID"}" \
  --protected-settings "{"workspaceKey":"$LAW_KEY"}" >/dev/null

echo "==> (Optional) Forward OpenShift logs to Azure Monitor via ClusterLogForwarder"
echo "Requires Cluster Logging operator. Applying subscription and forwarder."
# Install Cluster Logging operator
oc whoami >/dev/null 2>&1 && {
  oc apply -f ../manifests/cluster-logging-subscription.yaml
  CUSTOMER_ID="$LAW_ID" SHARED_KEY="$LAW_KEY" envsubst < ../manifests/clusterlogforwarder-azure.yaml.tmpl | oc apply -f -
} || {
  echo "Skipping OpenShift log forwarder: please 'oc login' then re-run this script."
}

echo "==> Monitoring configured. Query logs in Log Analytics."
