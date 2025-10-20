#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_env.sh"
source ../outputs/aro.env || { echo "Run 04_aro_cluster.sh first."; exit 1; }

oc whoami >/dev/null 2>&1 || oc login "$API_URL" -u "$KUBEADMIN_USER" -p "$KUBEADMIN_PASS"

echo "==> Creating project 'ai-demo'"
oc new-project ai-demo 2>/dev/null || oc project ai-demo

echo "==> Creating binary build for iris-api"
oc get bc iris-api >/dev/null 2>&1 || oc new-build --name=iris-api --binary --strategy=docker

echo "==> Starting build from local source (ai/iris-api)"
pushd ../ai/iris-api >/dev/null
oc start-build iris-api --from-dir=. --follow
popd >/dev/null

echo "==> Creating app from built image and exposing route"
oc get deploy iris-model-api >/dev/null 2>&1 || oc new-app --image-stream=iris-api:latest --name=iris-model-api
oc expose svc/iris-model-api >/dev/null 2>&1 || true

ROUTE="$(oc get route iris-model-api -o jsonpath='{.spec.host}')"
echo "Route: $ROUTE" | tee ../outputs/ai_route.txt

echo "==> Sample inference:"
echo "curl -s -X POST -H 'Content-Type: application/json' \\"
echo "  -d '{"features":[5.1,3.5,1.4,0.2]}' http://$ROUTE/predict"
