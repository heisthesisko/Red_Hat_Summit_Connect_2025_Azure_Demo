#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_env.sh"
source ../outputs/aro.env || { echo "Run 04_aro_cluster.sh first."; exit 1; }

oc whoami >/dev/null 2>&1 || oc login "$API_URL" -u "$KUBEADMIN_USER" -p "$KUBEADMIN_PASS"

echo "==> Installing OpenShift Virtualization (CNV) Operator"
oc apply -f ../manifests/openshift-virt-subscription.yaml

echo "==> Creating HyperConverged CR (enables virtualization)"
oc apply -f ../manifests/hyperconverged-cr.yaml

echo "==> (Optional) Create a sample Fedora VM"
oc apply -f ../manifests/kubevirt-vm-fedora.yaml
echo "VM will start with spec.running=true; check with:"
echo "  oc get vm"
