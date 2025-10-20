#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_env.sh"
source ../outputs/aro.env || { echo "Run 04_aro_cluster.sh first."; exit 1; }

echo "==> Ensuring 'oc' is logged in (kubeadmin)"
oc whoami >/dev/null 2>&1 || oc login "$API_URL" -u "$KUBEADMIN_USER" -p "$KUBEADMIN_PASS"

echo "==> Discovering OAuth route host"
OAUTH_HOST="$(oc -n openshift-authentication get route oauth-openshift -o jsonpath='{.spec.host}')"
echo "OAuth host: $OAUTH_HOST"

echo "==> Creating Entra ID (Azure AD) App Registration with redirect URI"
APP_NAME="${ARO_CLUSTER}-oauth"
REDIRECT_URI="https://${OAUTH_HOST}/oauth2callback/Azure"
APP_JSON="$(az ad app create --display-name "$APP_NAME" --enable-id-token-issuance true --sign-in-audience AzureADMyOrg --web-redirect-uris "$REDIRECT_URI")"
APP_ID="$(echo "$APP_JSON" | jq -r .appId)"
echo "$APP_JSON" > ../outputs/aad_app.json

echo "==> Creating client secret"
SECRET_JSON="$(az ad app credential reset --id "$APP_ID" --display-name 'ocp-oauth-secret' --years 1)"
CLIENT_SECRET="$(echo "$SECRET_JSON" | jq -r .password)"
echo "$SECRET_JSON" > ../outputs/aad_secret.json

echo "==> Storing client secret in OpenShift"
oc -n openshift-config create secret generic azure-aad-client-secret \
  --from-literal=clientSecret="$CLIENT_SECRET" \
  --dry-run=client -o yaml | oc apply -f -

echo "==> Applying OAuth configuration"
TENANT_ID="$(az account show --query tenantId -o tsv)"
export AAD_CLIENT_ID="$APP_ID"
export TENANT_ID

envsubst < ../manifests/oauth-azure-ad.yaml.tmpl | oc apply -f -

echo "==> Waiting for oauth rollout and testing login via console:"
echo "Console: $CONSOLE_URL"
echo "Look for 'Log in with Azure' button."
