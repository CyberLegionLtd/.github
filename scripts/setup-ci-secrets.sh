#!/usr/bin/env bash
# Set the consolidated CI secrets/variables described in
# docs/ci-secrets-and-variables.md. Requires `gh auth login` as an org admin.
# Values are read with `read -s` and passed on stdin; nothing is written to disk.
# Leave a prompt empty to skip that item.
set -euo pipefail

ORG="${ORG:-CyberLegionLtd}"
ENVS=(dev staging production)
DEPLOY_REPOS=(clp-infra clp-gateway cyberlegion-api a8i-api chyper-api stelargate-api)

ask() { local v; read -r -s -p "$1: " v; echo >&2; printf '%s' "$v"; }

org_secret() {
  local name="$1" v; v="$(ask "org secret $name (empty = skip)")"
  [ -z "$v" ] && return 0
  printf '%s' "$v" | gh secret set "$name" --org "$ORG" --visibility all
}

org_var() {
  gh variable set "$1" --org "$ORG" --visibility all --body "$2"
}

env_secret() {
  local repo="$1" env="$2" name="$3" v
  v="$(ask "$repo [$env] secret $name (empty = skip)")"
  [ -z "$v" ] && return 0
  printf '%s' "$v" | gh secret set "$name" --repo "$ORG/$repo" --env "$env"
}

echo "== Org-level"
org_secret GH_PAT
org_secret GATES_APP_ID
org_secret GATES_APP_PRIVATE_KEY
org_var PACKAGE_REGISTRY_URL "https://npm.pkg.github.com"

echo "== Environments"
for repo in "${DEPLOY_REPOS[@]}"; do
  for env in "${ENVS[@]}"; do
    gh api -X PUT "repos/$ORG/$repo/environments/$env" >/dev/null
  done
done

for env in "${ENVS[@]}"; do
  for repo in clp-infra cyberlegion-api a8i-api chyper-api stelargate-api; do
    env_secret "$repo" "$env" FLY_API_TOKEN
  done
  env_secret clp-infra "$env" SUPABASE_URL
  env_secret clp-infra "$env" SUPABASE_SERVICE_ROLE_KEY
  for repo in clp-infra clp-gateway; do
    env_secret "$repo" "$env" CLOUDFLARE_API_TOKEN
    env_secret "$repo" "$env" CLOUDFLARE_ACCOUNT_ID
  done
done

echo "Done. Protect the 'production' environment with required reviewers in each repo's Settings → Environments."
