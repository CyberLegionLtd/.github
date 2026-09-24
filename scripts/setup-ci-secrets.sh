#!/usr/bin/env bash
# Set the canonical CI secrets and variables described in
# docs/ci-secrets-and-variables.md. Requires `gh auth login` as an org admin.
# Values are read with `read -s` and passed on stdin; nothing is written to disk.
# Leave a prompt empty to skip that item.
#
#   scripts/setup-ci-secrets.sh            # create environments, set canonical values
#   scripts/setup-ci-secrets.sh --cleanup  # delete legacy names (asks before each one)
set -euo pipefail

ORG="${ORG:-CyberLegionLtd}"
ENVS=(dev staging production)
FLY_REPOS=(clp-infra cyberlegion-api a8i-api chyper-api stelargate-api)
DEPLOY_REPOS=("${FLY_REPOS[@]}" clp-gateway)
# Retired cross-repo token names; GH_PAT replaces all of them.
RETIRED=(RELEASE_PUSH_TOKEN PACKAGE_REGISTRY_TOKEN SOURCE_READ_TOKEN CLP_HOSTS_READ_TOKEN GH_PACKAGES_READ_TOKEN NODE_AUTH_TOKEN)
ALL_REPOS=(a8i-api chyper-api cyberlegion-api stelargate-api clp-client-host-extension clp-client-host-mobile
  clp-compute hub base-registry clp-infra clp-gates clp-kernel)

ask() { local v; read -r -s -p "$1: " v; echo >&2; printf '%s' "$v"; }
confirm() { local a; read -r -p "$1 [yes/N] " a; [ "$a" = "yes" ]; }

org_secret() {
  local name="$1" v; v="$(ask "org secret $name (empty = skip)")"
  [ -z "$v" ] && return 0
  printf '%s' "$v" | gh secret set "$name" --org "$ORG" --visibility all
}

org_var() {
  gh variable set "$1" --org "$ORG" --visibility all --body "$2"
}

# Environments that share one value. clp-infra's audit job still binds the
# legacy environment name `prod`, so its production values are written to both
# `production` and `prod` until that job is migrated.
envs_for() {
  local repo="$1" env="$2"
  if [ "$repo" = clp-infra ] && [ "$env" = production ]; then echo "production prod"; else echo "$env"; fi
}

env_secret() {
  local repo="$1" env="$2" name="$3" v target
  v="$(ask "$repo [$env] secret $name (empty = skip)")"
  [ -z "$v" ] && return 0
  for target in $(envs_for "$repo" "$env"); do
    printf '%s' "$v" | gh secret set "$name" --repo "$ORG/$repo" --env "$target"
  done
}

# Names only; values are never readable through the API.
has_env_secret() {
  gh secret list --repo "$ORG/$1" --env "$2" --json name --jq '.[].name' 2>/dev/null | grep -qx "$3"
}
has_repo_secret() {
  gh secret list --repo "$ORG/$1" --json name --jq '.[].name' 2>/dev/null | grep -qx "$2"
}
has_org_secret() {
  gh secret list --org "$ORG" --json name --jq '.[].name' 2>/dev/null | grep -qx "$1"
}

delete_repo_secret() {
  local repo="$1" name="$2"
  has_repo_secret "$repo" "$name" || return 0
  confirm "delete $repo secret $name?" && gh secret delete "$name" --repo "$ORG/$repo"
}
delete_org_secret() {
  has_org_secret "$1" || return 0
  confirm "delete org secret $1?" && gh secret delete "$1" --org "$ORG"
}
delete_var() {
  local repo="$1" name="$2"
  gh variable list --repo "$ORG/$repo" --json name --jq '.[].name' 2>/dev/null | grep -qx "$name" || return 0
  confirm "delete $repo variable $name?" && gh variable delete "$name" --repo "$ORG/$repo"
}

# Delete a suffixed secret only once the environment-scoped canonical value exists.
# Deleting it earlier would let a repo-level (dev) value reach that environment.
retire_suffixed() {
  local repo="$1" env="$2" canonical="$3" legacy="$4"
  has_repo_secret "$repo" "$legacy" || return 0
  if ! has_env_secret "$repo" "$env" "$canonical"; then
    echo "KEEP $repo $legacy: $env/$canonical is not set yet" >&2
    return 0
  fi
  delete_repo_secret "$repo" "$legacy"
}

cleanup() {
  echo "== Legacy suffixed secrets (guarded)"
  retire_suffixed clp-infra production FLY_API_TOKEN FLY_API_TOKEN_PROD
  retire_suffixed clp-infra staging SUPABASE_URL SUPABASE_URL_STAGING
  retire_suffixed clp-infra production SUPABASE_URL SUPABASE_URL_PROD
  retire_suffixed clp-infra staging SUPABASE_SERVICE_ROLE_KEY SUPABASE_SERVICE_ROLE_KEY_STAGING
  retire_suffixed clp-infra production SUPABASE_SERVICE_ROLE_KEY SUPABASE_SERVICE_ROLE_KEY_PROD

  echo "== Retired tokens (all replaced by GH_PAT)"
  if ! has_org_secret GH_PAT; then
    echo "KEEP retired tokens: org GH_PAT is not set" >&2
  else
    echo "NOTE: clp-registry and spokes-registry still read SOURCE_READ_TOKEN / PACKAGE_REGISTRY_TOKEN until migrated." >&2
    for name in "${RETIRED[@]}"; do
      delete_org_secret "$name"
      for repo in "${ALL_REPOS[@]}"; do delete_repo_secret "$repo" "$name"; done
    done
  fi

  echo "== Legacy clp-gates App names"
  if has_org_secret GATES_APP_ID && has_org_secret GATES_APP_PRIVATE_KEY; then
    delete_org_secret CLP_GATES_APP_ID
    delete_org_secret CLP_GATES_APP_PRIVATE_KEY
  else
    echo "KEEP CLP_GATES_APP_*: org GATES_APP_* are not set" >&2
  fi

  echo "== Legacy variables"
  delete_var clp-infra PLATFORM_ARTIFACT_REGISTRY
  delete_var clp-infra PLATFORM_DEPLOYMENT_HEALTH_TIMEOUT_SECONDS
  delete_var clp-infra PLATFORM_DEPLOYMENT_HEALTH_POLL_SECONDS
  delete_repo_secret clp-infra IDENTITY_JWKS_URL

}

if [ "${1:-}" = "--cleanup" ]; then cleanup; exit 0; fi

echo "== Org-level"
org_secret GH_PAT
echo "GH_PAT: fine-grained token from a dedicated bot account, with an expiry. Contents RW, Pull requests RW, Packages RW, Metadata R (+ Workflows RW only if pushes touch .github/workflows)."
echo "Optional: GATES_APP_ID / GATES_APP_PRIVATE_KEY (clp-gates prefers the App when set)."
org_secret GATES_APP_ID
org_secret GATES_APP_PRIVATE_KEY
org_var PACKAGE_REGISTRY_URL "https://npm.pkg.github.com"

echo "== Environments"
for repo in "${DEPLOY_REPOS[@]}"; do
  for env in "${ENVS[@]}"; do
    for target in $(envs_for "$repo" "$env"); do
      gh api -X PUT "repos/$ORG/$repo/environments/$target" >/dev/null
    done
  done
done

for env in "${ENVS[@]}"; do
  for repo in "${FLY_REPOS[@]}"; do
    env_secret "$repo" "$env" FLY_API_TOKEN
  done
  env_secret clp-infra "$env" SUPABASE_URL
  env_secret clp-infra "$env" SUPABASE_SERVICE_ROLE_KEY
done

echo "Done. Protect the 'production' environment with required reviewers in each repo's Settings → Environments."
echo "clp-infra: production values were also written to the legacy 'prod' environment used by its audit job; remove 'prod' once that job binds 'production'."
