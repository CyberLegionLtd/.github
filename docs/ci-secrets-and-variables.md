# CI secrets and variables

This is the single inventory of the secrets and variables that CyberLegionLtd workflows read. The goal is one org-level secret per purpose, with per-environment values held in GitHub **Environments** (`dev`, `staging`, `production`). Name suffixes like `_PROD` and `_STAGING` should go away.

## Org-level secrets

Set these once under Org Settings → Secrets and variables → Actions, with repository access **All** (or a selected list).

| Secret | Purpose | Replaces |
|---|---|---|
| `GH_PAT` | Read-only checkout of sibling repos, and reading private `@cyberlegionltd/*` packages. Use a fine-grained token or, better, a GitHub App token with Contents: read and Packages: read. | `SOURCE_READ_TOKEN`, `CLP_HOSTS_READ_TOKEN`, `GH_PACKAGES_READ_TOKEN`, `PACKAGE_REGISTRY_TOKEN` (read use), `NODE_AUTH_TOKEN` (read use) |
| `GATES_APP_ID` / `GATES_APP_PRIVATE_KEY` | clp-gates GitHub App credentials. | `CLP_GATES_APP_ID` / `CLP_GATES_APP_PRIVATE_KEY` |

Publishing to GitHub Packages uses the built-in `GITHUB_TOKEN` with `permissions: packages: write`, so it needs no secret.

## Environment-scoped secrets and variables

Create the Environments `dev`, `staging` and `production` in each deploying repo. Use the **same name** in every environment, each with its own value. Workflows select the value with `environment: <name>` on the job.

| Name | Kind | Repos | Replaces |
|---|---|---|---|
| `FLY_API_TOKEN` | secret | clp-infra, cyberlegion-api, a8i-api, chyper-api, stelargate-api | `FLY_API_TOKEN_PROD` |
| `SUPABASE_URL` | secret | clp-infra | `SUPABASE_URL_PROD`, `SUPABASE_URL_STAGING` |
| `SUPABASE_SERVICE_ROLE_KEY` | secret | clp-infra | `SUPABASE_SERVICE_ROLE_KEY_PROD`, `SUPABASE_SERVICE_ROLE_KEY_STAGING` |
| `APP_ROUTER_DNS_TARGET` | variable | clp-infra | `APP_ROUTER_DNS_TARGET_DEV`, `_STAGING`, `_PROD` |
| `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` | secret | clp-infra, clp-gateway | (per-environment if accounts differ) |
| `ORIGIN_ACCESS_CLIENT_ID`, `ORIGIN_ACCESS_CLIENT_SECRET`, `ORIGIN_ACCESS_SERVICE_TOKEN_ID` | secret | clp-gateway, clp-infra | none |

## Repo-specific, unchanged

- **clp-infra:** `PROVENANCE_SIGNING_PRIVATE_KEY_BASE64`, `OPENSANDBOX_MIRROR_TOKEN`, `OPENSANDBOX_MIRROR_USERNAME`, `IDENTITY_JWKS_URL`, and its operational variables (`PLATFORM_*`, `*_RUNTIME_MAX_*`, `CLP_DEPLOYMENT_*`, `CLP_RELEASE_TRUSTED_KEYS_JSON`, `UNDERSTANDING_MIN_CONFIDENCE`).
- **clp-registry:** `CLP_RUNTIME_OBSERVATION_BEARER_TOKEN`, the `CLP_RUNTIME_OBSERVATION_*` variables, and `RELEASE_PUSH_TOKEN` (the only secret that needs write access; prefer a GitHub App).
- **Registries:** the `PACKAGE_REGISTRY_URL` variable. Set it at org level to `https://npm.pkg.github.com`.

## Setup

Run `scripts/setup-ci-secrets.sh` with an authenticated `gh` CLI (org admin). It asks for each value without echoing it and never writes values to disk.

Migrating the workflows to these names is a separate change per repo. Until then, workflows can read `secrets.NEW || secrets.OLD` so nothing breaks while you move over.
