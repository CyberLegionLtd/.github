# POLICY: GitHub Actions

**Status:** Active.  **Effective:** 2026-05-17.  **Scope:** Enterprise `cyberlegion` and org `CyberLegionLtd`.

## What is allowed

Workflows in any org repo may use Actions from:

1. **GitHub-owned actions** — anything in `github.com/actions/*`, `github.com/github/*`. Auto-allowlisted.
2. **Verified-creator actions** — actions published by GitHub-verified organisations. Auto-allowlisted.
3. **Cyber Legion-owned actions** — pattern `CyberLegionLtd/*`. Explicitly allowlisted.

Anything else fails policy. To request a new allowlist entry, open a PR adding the pattern to this doc + update the enterprise Actions policy.

## Token + permission policy

| Setting | Value |
|---|---|
| `enabled_organizations` (enterprise) | `all` |
| `enabled_repositories` (org) | `all` |
| `allowed_actions` | `selected` |
| `sha_pinning_required` | **`true`** — Actions must be referenced by 40-char commit SHA, not floating tag |
| `default_workflow_permissions` | `read` — default `GITHUB_TOKEN` is read-only; workflows must explicitly request write |
| `can_approve_pull_request_reviews` | `false` — `GITHUB_TOKEN` cannot approve PRs (prevents auto-approval loops) |

## What this means in practice

**Pinning:** Every `uses:` line must include a full 40-char SHA. Example:

```yaml
# ✓ allowed
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1

# ✗ blocked at runtime
- uses: actions/checkout@v4
```

**Token scope:** Workflows that need write access must declare permissions explicitly:

```yaml
permissions:
  contents: write    # only if you need to push back
  pull-requests: write
  packages: write
```

Default if omitted = `contents: read` and nothing else.

**Fork PRs:** Workflows triggered by `pull_request` from forks run with the **base** repo's `GITHUB_TOKEN` set to read-only. Use `pull_request_target` only when you understand the security implications.

## What is NOT yet enforced

- **Required reusable workflows.** The `.github/workflow-templates/` folder in this repo offers starter templates (dependency-review, artifact-attestation, sbom) but none are required.
- **Self-hosted runners.** Disabled by absence (no runner groups configured).
- **Workflow approval for first-time contributors.** Default GitHub behaviour applies; not explicitly tightened.

## How to verify

```bash
gh api enterprises/cyberlegion/actions/permissions
gh api enterprises/cyberlegion/actions/permissions/selected-actions
gh api orgs/CyberLegionLtd/actions/permissions/workflow
```

## Related

- [POLICY-BRANCH-PROTECTION.md](POLICY-BRANCH-PROTECTION.md)
- [POLICY-SECRETS.md](POLICY-SECRETS.md)
- Workflow templates: `.github/workflow-templates/`
