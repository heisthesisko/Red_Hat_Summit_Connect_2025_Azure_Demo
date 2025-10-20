#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_env.sh"

echo "==> Creating ARO cluster (this can take 30–45 minutes)"
PULL_ARG=""
if [ -f "$PULL_SECRET_FILE" ]; then
  PULL_ARG="--pull-secret @$PULL_SECRET_FILE"
else
  echo "NOTE: No pull-secret file found at $PULL_SECRET_FILE. Continuing without it."
fi

az aro create -g "$RESOURCE_GROUP" -n "$ARO_CLUSTER" \
  --vnet "$VNET_NAME" --master-subnet "$MASTER_SUBNET" --worker-subnet "$WORKER_SUBNET" \
  --worker-vm-size "$WORKER_SIZE" --worker-count "$WORKER_COUNT" $PULL_ARG

echo "==> Fetching ARO endpoints and credentials"
API_URL="$(az aro show -g "$RESOURCE_GROUP" -n "$ARO_CLUSTER" --query "apiserverProfile.url" -o tsv)"
CONSOLE_URL="$(az aro show -g "$RESOURCE_GROUP" -n "$ARO_CLUSTER" --query "consoleProfile.url" -o tsv)"
KUBEADMIN_PASS="$(az aro list-credentials -g "$RESOURCE_GROUP" -n "$ARO_CLUSTER" --query "kubeadminPassword" -o tsv)"

cat > ../outputs/aro-credentials.txt <<EOF
API_URL=$API_URL
CONSOLE_URL=$CONSOLE_URL
KUBEADMIN_USER=kubeadmin
KUBEADMIN_PASS=$KUBEADMIN_PASS
EOF

cat > ../outputs/aro.env <<EOF
export API_URL=$API_URL
export CONSOLE_URL=$CONSOLE_URL
export KUBEADMIN_USER=kubeadmin
export KUBEADMIN_PASS=$KUBEADMIN_PASS
EOF

echo "ARO API:     $API_URL"
echo "ARO Console: $CONSOLE_URL"
echo "Credentials saved to outputs/aro-credentials.txt"
echo "To log in with oc:"
echo "  source outputs/aro.env"
echo "  oc login $API_URL -u kubeadmin -p $KUBEADMIN_PASS"
