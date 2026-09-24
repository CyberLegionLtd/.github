# CI secrets and variables

This is the single inventory of the secrets and variables that CyberLegionLtd workflows read. Each purpose has one name. Values that differ per environment live in GitHub **Environments** (`dev`, `staging`, `production`) under the same name, and deploying jobs declare `environment:`.

Workflow changes are on branch `claude/ci-secrets-consolidation` in each repo. During the migration every workflow reads `CANONICAL || LEGACY`, so nothing breaks before the new values are set.

## Canonical names

### Org-level secrets

| Secret | Purpose | Access |
|---|---|---|
| `GH_PAT` | Cross-repo **read**: checking out sibling repos and reading private `@cyberlegionltd/*` packages. | Contents: read and Packages: read on all repos. A GitHub App token is better. |
| `GATES_APP_ID` / `GATES_APP_PRIVATE_KEY` | The clp-gates GitHub App. Used to mint read tokens for clp-gates and clp-registry, and metadata for the inventory. | App: Contents: read and Metadata: read. |
| `RELEASE_PUSH_TOKEN` | The only **write** secret. It pushes release and version commits, opens promotion PRs, and pushes cross-repo migrations. | Contents: write and Pull requests: write, only on the repos that need them (see the open decisions). |

Publishing to GitHub Packages uses the built-in `github.token` with job `permissions: packages: write`, so it needs no secret.

### Org-level variables

| Variable | Value |
|---|---|
| `PACKAGE_REGISTRY_URL` | `https://npm.pkg.github.com` |

### Environment-scoped values

The name is the same in every environment. Only the value differs.

| Name | Kind | Repos |
|---|---|---|
| `FLY_API_TOKEN` | secret | clp-infra, cyberlegion-api, a8i-api, chyper-api, stelargate-api |
| `SUPABASE_URL` | secret | clp-infra |
| `SUPABASE_SERVICE_ROLE_KEY` | secret | clp-infra |
| `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` | secret | clp-infra, clp-gateway (repo-level today; move to environments only if the accounts differ) |

### Repo-specific names (unchanged)

- **clp-infra:**
  - Secrets: `PROVENANCE_SIGNING_PRIVATE_KEY_BASE64`, `OPENSANDBOX_MIRROR_TOKEN`, `OPENSANDBOX_MIRROR_USERNAME`, `ORIGIN_ACCESS_SERVICE_TOKEN_ID`.
  - Variables: `IDENTITY_JWKS_URL` (a variable, with a legacy secret fallback), `CLP_ARTIFACT_REGISTRY`, `CLP_DEPLOYMENT_HEALTH_*`, `CLP_RELEASE_TRUSTED_KEYS_JSON`, `CLOUDFLARE_API_BASE_URL`, `OPENSANDBOX_MIRROR_*`, `PLATFORM_*` (admin, operator and identity settings), `*_RUNTIME_MAX_*`, `UNDERSTANDING_MIN_CONFIDENCE`.
  - `APP_ROUTER_DNS_TARGET_DEV` / `_STAGING` / `_PROD` stay for now. See the open decisions.
- **clp-gateway:** `ORIGIN_ACCESS_CLIENT_ID`, `ORIGIN_ACCESS_CLIENT_SECRET`.
- **clp-registry:** `CLP_RUNTIME_OBSERVATION_BEARER_TOKEN` and the `CLP_RUNTIME_OBSERVATION_*` variables.

## Old name to new name

Delete each old secret only after its canonical replacement is set. The fallback in the workflows keeps things running until then.

| Old name | New name | Where it was read | Remove after |
|---|---|---|---|
| `SOURCE_READ_TOKEN` | `GH_PAT` | clp-gates (secret input), hub, clp-compute, base-registry, clp-registry\*, spokes-registry\* | the org `GH_PAT` is set as read-only and clp-registry and spokes-registry are migrated |
| `CLP_HOSTS_READ_TOKEN` | `GH_PAT` | clp-client-host-extension, clp-client-host-mobile | `GH_PAT` is set |
| `GH_PACKAGES_READ_TOKEN` | `GH_PAT` | clp-infra `reusable-deploy-app.yml` (secret input) | every caller passes `GH_PAT` |
| `NODE_AUTH_TOKEN` (a secret, for reading) | `GH_PAT` | cyberlegion-api, a8i-api, chyper-api, stelargate-api (Docker `node_auth_token` build secret) | `GH_PAT` is set |
| `PACKAGE_REGISTRY_TOKEN` (for reading) | `GH_PAT` | clp-gates (secret input) | `GH_PAT` is set |
| `PACKAGE_REGISTRY_TOKEN` (for publishing) | `github.token` + `packages: write` | base-registry publish workflows, clp-registry\*, spokes-registry\* | each package grants the publishing repo **Write** under Package settings → Manage Actions access (see below) |
| `CLP_GATES_APP_ID` / `CLP_GATES_APP_PRIVATE_KEY` | `GATES_APP_ID` / `GATES_APP_PRIVATE_KEY` | clp-gates (secret inputs of every reusable workflow) | the org `GATES_APP_*` are set and no external caller passes the old input names |
| `GH_PAT` (when used for writing) | `RELEASE_PUSH_TOKEN` | hub `SOURCE_WRITE_TOKEN` (migration pushes), base-registry promotion PRs | `RELEASE_PUSH_TOKEN` can reach those repos, **and** `GH_PAT` has been reduced to read-only |
| `FLY_API_TOKEN_PROD` | `FLY_API_TOKEN` in the `production` environment | clp-infra | `production`/`FLY_API_TOKEN` is set in clp-infra |
| `SUPABASE_URL_STAGING` / `_PROD` | `SUPABASE_URL` in the `staging` / `production` environment | clp-infra | the environment values are set |
| `SUPABASE_SERVICE_ROLE_KEY_STAGING` / `_PROD` | `SUPABASE_SERVICE_ROLE_KEY` in the `staging` / `production` environment | clp-infra | the environment values are set |
| variable `PLATFORM_ARTIFACT_REGISTRY` | variable `CLP_ARTIFACT_REGISTRY` | clp-infra | `CLP_ARTIFACT_REGISTRY` is set |
| variables `PLATFORM_DEPLOYMENT_HEALTH_*` | variables `CLP_DEPLOYMENT_HEALTH_*` | clp-infra (fallback already existed) | `CLP_*` are set |
| secret `IDENTITY_JWKS_URL` | variable `IDENTITY_JWKS_URL` | clp-infra (fallback already existed) | the variable is set |

\* Not migrated yet: those clones had uncommitted work from another agent, so this change skipped them.

### Fallback order and the production safety rule

- **Read and app secrets:** `secrets.CANONICAL || secrets.OLD`.
- **Environment-suffixed secrets in staging and production:** the order is reversed: `secrets.X_PROD || secrets.X`. Until the Environments exist, a repo-level `FLY_API_TOKEN` holds the **dev** value. If it came first, it would shadow `FLY_API_TOKEN_PROD` in a production job. With the legacy suffixed secret first, a dev credential can never reach a production deploy. `tests/workflow-secret-selection.test.mjs` in clp-infra enforces this.
- **The flip needs no code change.** Once `production`/`FLY_API_TOKEN` is set, delete `FLY_API_TOKEN_PROD` and the expression falls through to the environment-scoped value.
- **Order matters.** Never delete a suffixed secret before its environment-scoped value exists. Otherwise the job would fall back to the repo-level (dev) value.

### Publishing with `github.token`

`github.token` can publish a GitHub Packages npm package only when the package is linked to the publishing repo, or when the package grants that repo **Write** under *Manage Actions access*. Some `@cyberlegionltd/*` packages were first published from other repos (hub and the older monorepos). For those packages `PACKAGE_REGISTRY_TOKEN` is still needed, so it stays as the first choice: `secrets.PACKAGE_REGISTRY_TOKEN || github.token`. Once every package grants the publishing registry repo Write access, delete the `PACKAGE_REGISTRY_TOKEN` secret and publishing falls through to `github.token` with no workflow change.

`base-registry/publish-dev-snapshot.yml` still reads `PACKAGE_REGISTRY_TOKEN || GH_PAT || github.token`. The owner has to decide on this (see the open decisions) because another agent is changing that file right now.

## Reusable-workflow secret interfaces

Secret input names are a cross-repo contract. New canonical inputs were added as optional, and none were removed.

| Workflow | Legacy inputs (kept) | New canonical inputs | Resolution inside |
|---|---|---|---|
| clp-gates `gates.yml` and every family workflow (`ai`, `accessibility`, `contracts`, `deployment-verification`, `functional`, `governance`, `privacy`, `regression`, `release-verification`, `scheduled`, `security`, `source`, `supply-chain`, `verify-required-gates`) | `CLP_GATES_APP_ID`, `CLP_GATES_APP_PRIVATE_KEY`, `SOURCE_READ_TOKEN`, `PACKAGE_REGISTRY_TOKEN` | `GATES_APP_ID`, `GATES_APP_PRIVATE_KEY`, `GH_PAT` | `GATES_APP_ID \|\| CLP_GATES_APP_ID`; `GH_PAT \|\| SOURCE_READ_TOKEN` for checkout; `GH_PAT \|\| PACKAGE_REGISTRY_TOKEN` for npm |
| clp-infra `reusable-deploy-app.yml` | `GH_PACKAGES_READ_TOKEN` | `GH_PAT` | `GH_PAT \|\| GH_PACKAGES_READ_TOKEN \|\| GITHUB_TOKEN` |
| clp-registry `reusable-enterprise-assurance.yml` | `SOURCE_READ_TOKEN`, ... | (not migrated yet: the clone was dirty) | |

Callers that pin an **older** clp-gates SHA must keep passing the legacy input keys. The template and shim do this, taking values from the canonical secrets: `CLP_GATES_APP_ID: ${{ secrets.GATES_APP_ID || secrets.CLP_GATES_APP_ID }}`. That pattern works with any pinned version.

## Per-environment matrix (repo × environment × name)

| Repo | Job → environment | `dev` | `staging` | `production` |
|---|---|---|---|---|
| cyberlegion-api, a8i-api, chyper-api, stelargate-api | `deploy`: `main`→`production`, `staging`→`staging`, else `dev` | `FLY_API_TOKEN` | `FLY_API_TOKEN` | `FLY_API_TOKEN` |
| clp-infra `deploy-smart.yml` | `dev` (dev-only) | `FLY_API_TOKEN` | – | – (legacy branch `FLY_API_TOKEN_PROD \|\| FLY_API_TOKEN`) |
| clp-infra `audit-platform-environments.yml` | matrix: `dev`, `staging`, **`prod`** | `FLY_API_TOKEN`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` | same names (legacy `_STAGING` first) | same names (legacy `_PROD` first) |
| clp-infra `disable-nondev-exposure.yml` | `dev`, `staging` | `CLOUDFLARE_API_TOKEN` (repo-level today) | `CLOUDFLARE_API_TOKEN` | – |

In the four API repos the canonical `FLY_API_TOKEN` was already the only name. Declaring `environment:` means the value set in each Environment wins over the repo or org secret.

## Setup

Run `scripts/setup-ci-secrets.sh` with an authenticated `gh` CLI (org admin). It asks for each value without echoing it and never writes values to disk. It creates the Environments and sets the canonical org secrets and environment secrets. Leave a prompt empty to skip that item.

## Post-migration cleanup

1. Set every canonical value (run the setup script).
2. Merge each repo's `claude/ci-secrets-consolidation` branch and confirm that one run of each deploy, gates and publish workflow passes.
3. Run `scripts/setup-ci-secrets.sh --cleanup`. It lists every legacy secret and variable the workflows no longer need and deletes it only after you type `yes` for each one. It never deletes a suffixed secret whose environment-scoped replacement is missing.
4. Remove the `|| secrets.OLD` fallbacks and the legacy reusable-workflow inputs in a follow-up change once no caller passes them. For clp-gates, that means after every caller has bumped its pin past the version with the canonical inputs.
5. Protect the `production` environment with required reviewers in each deploying repo.

## Open decisions for the owner

1. **`GH_PAT` is used for writing today.** hub's migration workflows and base-registry's promotion PRs use it with write access. They now prefer `RELEASE_PUSH_TOKEN`, so `RELEASE_PUSH_TOKEN` must be an org secret that reaches hub, base-registry, clp-kernel and clp-registry before `GH_PAT` can become read-only. Promotion PRs need a PAT or App token, not `github.token`, so that CI runs on the PR.
2. **clp-infra environment names.** `audit-platform-environments.yml` uses the environment `prod`, and `opensandbox-supply-chain.yml` defaults to `development`. The canonical names are `production` and `dev`. Renaming would hide any secrets already stored in `prod`/`development`, so the names were left as they are. Copy those values into `production`/`dev` first, then rename.
3. **`APP_ROUTER_DNS_TARGET_*`.** `scripts/ensure-app-host-dns.mjs` writes DNS records for all three environments in a single run, so it needs all three values at once. A single job can bind only one environment. To consolidate, change the script to handle one environment per run (the job would bind `environment: <target_environment>`). Until then the suffixed variables stay.
4. **`PACKAGE_REGISTRY_TOKEN` for publishing.** Grant each `@cyberlegionltd/*` package Write access for its publishing repo, then delete the secret. Also decide whether `publish-dev-snapshot.yml` should drop `GH_PAT` from its publish chain. It has to once `GH_PAT` is read-only.
5. **Skipped repos.** clp-registry and spokes-registry had uncommitted changes and were not migrated. They still read `SOURCE_READ_TOKEN` and `PACKAGE_REGISTRY_TOKEN`.
