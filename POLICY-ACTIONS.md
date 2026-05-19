# POLICY: GitHub Actions

**Status:** Active.  **Effective:** 2026-05-17 (baseline).  **Revised:** 2026-05-19 (post-incident, tightened).  **Scope:** Enterprise `cyberlegion` and org `CyberLegionLtd`.

## Principle

> **First-party first.** Use native `gh api` / `curl` / `npm install -g` / `npx` whenever the capability is a single REST call or a script installer. Only add a third-party publisher to the allowlist when the action wraps real, hard-to-replicate complexity (BuildKit setup, OIDC token exchange, signature verification, multi-step release orchestration).

Every entry on the allowlist expands the supply-chain trust surface. The allowlist is a budget, not a default.

## Enterprise-wide settings

| Setting | Value | Reason |
|---|---|---|
| `allowed_actions` | `selected` | enumerated allowlist below; no implicit verified-creator pass-through |
| `sha_pinning_required` | **`true`** | every `uses:` must be a 40-char commit SHA |
| `default_workflow_permissions` | `read` | `GITHUB_TOKEN` is read-only by default; workflows opt-in to write |
| `can_approve_pull_request_reviews` | `false` | `GITHUB_TOKEN` cannot approve PRs |

`github_owned_allowed: true` and `verified_allowed: true` are set as defense-in-depth, but **do not rely on them** — GitHub's enforcement of these flags is inconsistent. The `patterns_allowed` list is what actually decides.

## Allowlist (6 patterns)

```
CyberLegionLtd/*
docker/*
sigstore/*
google-github-actions/*
hashicorp/*
changesets/*
```

### Why each pattern is kept

| Pattern | Used for | Why no native replacement |
|---|---|---|
| `CyberLegionLtd/*` | Our own reusable workflows + actions | Self-trust |
| `docker/*` | `setup-buildx-action`, `build-push-action`, `login-action` | BuildKit setup, multi-platform builds, registry auth flows |
| `sigstore/*` | `cosign-installer` | Signature verification of the installer itself — replacing with `curl` would weaken the chain |
| `google-github-actions/*` | `auth` (GCP OIDC) | OIDC token exchange with GCP IAM is non-trivial; the action handles short-lived credential injection |
| `hashicorp/*` | `setup-terraform` | Terraform CLI install + wrapper for predictable arg passing |
| `changesets/*` | `action` | Multi-step release-PR orchestration: parses changesets, opens or merges release PR, runs publish |

## Banned patterns and their native replacements

These were on the allowlist between 2026-05-17 and 2026-05-19 and have been removed. **Do not add them back without a Rule 16 justification (real consumer, production-ready in this PR, no native equivalent).**

### `pnpm/action-setup` → `corepack`

```yaml
# Banned
- uses: pnpm/action-setup@b906affcce14559ad1aafd4ab0e942779e9f58b1  # v4
  with:
    version: 9

# Use instead
- name: Setup pnpm
  run: |
    corepack enable
    corepack prepare pnpm@9 --activate
```

### `superfly/flyctl-actions/setup-flyctl` → `curl` install

```yaml
# Banned
- uses: superfly/flyctl-actions/setup-flyctl@ed8efb33836e8b2096c7fd3ba1c8afe303ebbff1  # master

# Use instead
- name: Setup flyctl
  run: |
    curl -L https://fly.io/install.sh | sh
    echo "$HOME/.fly/bin" >> $GITHUB_PATH
```

For a pinned version: prepend `FLYCTL_VERSION=v0.x.y` to the curl line.

### `supabase/setup-cli` → `npm install -g`

```yaml
# Banned
- uses: supabase/setup-cli@cd9b0fd6c9b461031b64e97090fcbdec9ba23711  # v1
  with:
    version: latest

# Use instead
- name: Setup Supabase CLI
  run: npm install -g supabase
```

For a pinned version: `npm install -g supabase@<version>`.

### `cloudflare/wrangler-action` → `npx wrangler`

```yaml
# Banned
- uses: cloudflare/wrangler-action@9acf94ace14e7dc412b076f2c5c20b8ce93c79cd  # v3
  with:
    apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
    command: pages deploy dist/ --project-name=foo

# Use instead
- name: Deploy to Cloudflare Pages
  env:
    CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
  run: npx wrangler@4 pages deploy dist/ --project-name=foo
```

### `peter-evans/repository-dispatch` → `gh api`

```yaml
# Banned
- uses: peter-evans/repository-dispatch@ff45666b9427631e3450c54a1bcbee4d9ff4d7c0  # v3
  with:
    token: ${{ secrets.GH_PAT }}
    repository: CyberLegionLtd/platform-cloud
    event-type: deploy-dev
    client-payload: '{"source":"x","ref":"${{ github.sha }}"}'

# Use instead
- name: Dispatch deploy
  env:
    GH_TOKEN: ${{ secrets.GH_PAT || secrets.GITHUB_TOKEN }}
  run: |
    gh api --method POST repos/CyberLegionLtd/platform-cloud/dispatches --input - <<JSON
    {"event_type":"deploy-dev","client_payload":{"source":"x","ref":"${{ github.sha }}"}}
    JSON
```

## SHA pinning

Every `uses:` line must be a 40-char commit SHA. Floating refs (`@v4`, `@main`, `@master`) fail at workflow startup.

Preserve the tag as a trailing comment for human readability:

```yaml
# ✓ allowed
- uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5  # v4

# ✗ blocked at runtime
- uses: actions/checkout@v4
```

When upgrading an action version: resolve the new tag's SHA via `gh api repos/<owner>/<repo>/git/refs/tags/<tag>` and update the SHA + comment together in the same PR.

## Token + permission policy

Workflows that need write access must declare permissions explicitly:

```yaml
permissions:
  contents: write       # only if you need to push back
  pull-requests: write
  packages: write
  id-token: write       # for OIDC federation
```

Default if omitted = `contents: read` and nothing else.

**Fork PRs:** Workflows triggered by `pull_request` from forks run with the **base** repo's `GITHUB_TOKEN` set to read-only. Use `pull_request_target` only when you understand the security implications.

## How to add a new pattern

A new vendor pattern is a supply-chain trust expansion. To propose one:

1. Open a PR to this repo modifying the allowlist section of this doc + adding the rationale row to the "Why each pattern is kept" table.
2. Demonstrate the native replacement is infeasible (link to docs / show why `gh api` / `curl` / `npx` doesn't cover the capability).
3. Confirm the action's source repo has tagged releases and a reasonable maintenance signal (recent commits, real maintainers).
4. After PR merge: apply the new pattern via `gh api --method PUT enterprises/cyberlegion/actions/permissions/selected-actions`. Read back with `gh api enterprises/cyberlegion/actions/permissions/selected-actions` to confirm.

Adding a pattern is reversible — if the action is later rewritten away (e.g., the upstream gets a one-shot REST endpoint), remove the pattern in the same PR as the rewrite.

## How to verify the current policy

```bash
# Enterprise level (needs admin:enterprise)
gh api enterprises/cyberlegion/actions/permissions
gh api enterprises/cyberlegion/actions/permissions/selected-actions

# Repo level (reflects the effective cascaded policy)
gh api repos/<owner>/<repo>/actions/permissions/selected-actions
```

## What is NOT yet enforced

- **Required reusable workflows.** The `.github/workflow-templates/` folder in this repo offers starter templates (dependency-review, artifact-attestation, sbom) but none are required at the ruleset level.
- **Self-hosted runners.** Disabled by absence (no runner groups configured).
- **Workflow approval for first-time contributors.** Default GitHub behaviour applies; not explicitly tightened.

## History

- **2026-05-17** — Initial governance baseline. `sha_pinning_required: true` and `allowed_actions: selected` flipped enterprise-wide via ruleset #16500430. `patterns_allowed` set to `["CyberLegionLtd/*"]` only. Verified-creator pass-through assumed sufficient.
- **2026-05-18** — Incident: 311 repos hitting `startup_failure` because (a) workflows used floating refs (`@v4`, `@master`) violating `sha_pinning_required`, and (b) verified-creator pass-through was not actually enforced. SHA-pin sweep landed across all affected repos.
- **2026-05-19** — Allowlist expanded to 11 patterns (the vendor orgs actually in use). Then first-party-first sweep replaced 657 vendor-action uses with native equivalents across 310 repos. Allowlist re-tightened to the current 6 patterns.

## Related

- [POLICY-BRANCH-PROTECTION.md](POLICY-BRANCH-PROTECTION.md)
- [POLICY-SECRETS.md](POLICY-SECRETS.md)
- [POLICY-OIDC-FEDERATION.md](POLICY-OIDC-FEDERATION.md)
- [POLICY-DEPENDENCY-MANAGEMENT.md](POLICY-DEPENDENCY-MANAGEMENT.md)
- Workflow templates: `.github/workflow-templates/`
