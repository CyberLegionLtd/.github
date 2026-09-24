# CI secrets and variables

This is the single inventory of the secrets and variables that CyberLegionLtd workflows read. Each purpose has one name. Values that differ per environment live in GitHub **Environments** (`dev`, `staging`, `production`) under the same name, and deploying jobs declare `environment:`.

Workflow changes are on branch `claude/ci-secrets-consolidation` in each repo. During the migration every workflow reads `CANONICAL || LEGACY`, so nothing breaks before the new values are set.

## Canonical names

### Org-level secrets

| Secret | Purpose | Access |
|---|---|---|
| `GH_PAT` | **The one cross-repo token, for reads and writes.** Checks out sibling repos, reads private `@cyberlegionltd/*` packages, publishes packages, pushes release and version commits, opens promotion PRs, and pushes cross-repo migrations. | Fine-grained token on the org's repos with: Contents **read and write**, Pull requests **read and write**, Packages **read and write**, Metadata **read**. Add Workflows **read and write** only if a push changes files under `.github/workflows`. |
| `GATES_APP_ID` / `GATES_APP_PRIVATE_KEY` | Optional. The clp-gates GitHub App. When it is set, clp-gates uses it (not `GH_PAT`) to mint read tokens for clp-gates and clp-registry, and metadata for the inventory. | App: Contents: read and Metadata: read. |

Create `GH_PAT` under a dedicated machine (bot) account, not a person's account, and give it an expiry date. Put a reminder in the calendar to rotate it before it expires.

Publishing to GitHub Packages uses `secrets.GH_PAT || secrets.PACKAGE_REGISTRY_TOKEN || github.token`, and the job keeps `permissions: packages: write` so that the `github.token` fallback still works.

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
| `SOURCE_READ_TOKEN` | `GH_PAT` | clp-gates (secret input), hub, clp-compute, base-registry, clp-registry\*, spokes-registry\* | the org `GH_PAT` is set and clp-registry and spokes-registry are migrated |
| `CLP_HOSTS_READ_TOKEN` | `GH_PAT` | clp-client-host-extension, clp-client-host-mobile | `GH_PAT` is set |
| `GH_PACKAGES_READ_TOKEN` | `GH_PAT` | clp-infra `reusable-deploy-app.yml` (secret input) | every caller passes `GH_PAT` |
| `NODE_AUTH_TOKEN` (a secret, for reading) | `GH_PAT` | cyberlegion-api, a8i-api, chyper-api, stelargate-api (Docker `node_auth_token` build secret) | `GH_PAT` is set |
| `PACKAGE_REGISTRY_TOKEN` (for reading) | `GH_PAT` | clp-gates (secret input) | `GH_PAT` is set |
| `PACKAGE_REGISTRY_TOKEN` (for publishing) | `GH_PAT` | base-registry publish workflows, clp-registry\*, spokes-registry\* | `GH_PAT` is set with Packages: read and write, and clp-registry and spokes-registry are migrated |
| `CLP_GATES_APP_ID` / `CLP_GATES_APP_PRIVATE_KEY` | `GATES_APP_ID` / `GATES_APP_PRIVATE_KEY` | clp-gates (secret inputs of every reusable workflow) | the org `GATES_APP_*` are set and no external caller passes the old input names |
| `RELEASE_PUSH_TOKEN` | `GH_PAT` | hub `SOURCE_WRITE_TOKEN` (migration pushes), base-registry promotion PRs | `GH_PAT` is set with Contents and Pull requests: read and write |
| `FLY_API_TOKEN_PROD` | `FLY_API_TOKEN` in the `production` environment | clp-infra | `production`/`FLY_API_TOKEN` is set in clp-infra |
| `SUPABASE_URL_STAGING` / `_PROD` | `SUPABASE_URL` in the `staging` / `production` environment | clp-infra | the environment values are set |
| `SUPABASE_SERVICE_ROLE_KEY_STAGING` / `_PROD` | `SUPABASE_SERVICE_ROLE_KEY` in the `staging` / `production` environment | clp-infra | the environment values are set |
| variable `PLATFORM_ARTIFACT_REGISTRY` | variable `CLP_ARTIFACT_REGISTRY` | clp-infra | `CLP_ARTIFACT_REGISTRY` is set |
| variables `PLATFORM_DEPLOYMENT_HEALTH_*` | variables `CLP_DEPLOYMENT_HEALTH_*` | clp-infra (fallback already existed) | `CLP_*` are set |
| secret `IDENTITY_JWKS_URL` | variable `IDENTITY_JWKS_URL` | clp-infra (fallback already existed) | the variable is set |

\* Not migrated yet: those clones had uncommitted work from another agent, so this change skipped them.

### Fallback order and the production safety rule

- **Cross-repo tokens (read and write) and app secrets:** `secrets.GH_PAT || secrets.OLD` (for publishing, `|| github.token` last).
- **Environment-suffixed secrets in staging and production:** the order is reversed: `secrets.X_PROD || secrets.X`. Until the Environments exist, a repo-level `FLY_API_TOKEN` holds the **dev** value. If it came first, it would shadow `FLY_API_TOKEN_PROD` in a production job. With the legacy suffixed secret first, a dev credential can never reach a production deploy. `tests/workflow-secret-selection.test.mjs` in clp-infra enforces this.
- **The flip needs no code change.** Once `production`/`FLY_API_TOKEN` is set, delete `FLY_API_TOKEN_PROD` and the expression falls through to the environment-scoped value.
- **Order matters.** Never delete a suffixed secret before its environment-scoped value exists. Otherwise the job would fall back to the repo-level (dev) value.

### Publishing

Publishing reads `secrets.GH_PAT || secrets.PACKAGE_REGISTRY_TOKEN || github.token` in `base-registry` `publish-packages.yml` and `publish-dev-snapshot.yml`. `GH_PAT` needs Packages: read and write. `github.token` is only the last fallback. It can publish a package only when the package is linked to the publishing repo, or grants that repo **Write** under *Manage Actions access*.

`publish-dev-snapshot.yml` is also being changed on the `claude/registry-readiness` branch, so the two branches may conflict on that line when they merge. Keep the `GH_PAT`-first order.

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

1. **Decided: one token.** `GH_PAT` is the single org secret for cross-repo reads and writes. `RELEASE_PUSH_TOKEN`, `PACKAGE_REGISTRY_TOKEN`, `SOURCE_READ_TOKEN`, `CLP_HOSTS_READ_TOKEN`, `GH_PACKAGES_READ_TOKEN` and the `NODE_AUTH_TOKEN` secret are retired and remain only as fallbacks. Promotion PRs need a PAT or App token, not `github.token`, so that CI runs on the PR.
2. **clp-infra environment names.** `audit-platform-environments.yml` uses the environment `prod`, and `opensandbox-supply-chain.yml` defaults to `development`. The canonical names are `production` and `dev`. Renaming would hide any secrets already stored in `prod`/`development`, so the names were left as they are. Copy those values into `production`/`dev` first, then rename.
3. **`APP_ROUTER_DNS_TARGET_*`.** `scripts/ensure-app-host-dns.mjs` writes DNS records for all three environments in a single run, so it needs all three values at once. A single job can bind only one environment. To consolidate, change the script to handle one environment per run (the job would bind `environment: <target_environment>`). Until then the suffixed variables stay.
4. **Skipped repos.** clp-registry and spokes-registry had uncommitted changes and were not migrated. They still read `SOURCE_READ_TOKEN` and `PACKAGE_REGISTRY_TOKEN`.
