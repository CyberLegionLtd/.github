# POLICY: Dependency Management

**Status:** Active.  **Effective:** 2026-05-17.  **Scope:** Every repository in `CyberLegionLtd`.

## What is enforced

| Control | Setting |
|---|---|
| Dependency graph | ON for all new repos (org default) |
| Dependabot vulnerability alerts | ON for all new repos (org default), confirmed on 330/331 active repos |
| Dependabot security updates (auto-PR) | ON for all new repos (org default) |
| Dependency Review (PR-time blocking check) | Available via workflow template `dependency-review` |

## What contributors must do

1. **Use lockfiles.** `package-lock.json` / `pnpm-lock.yaml` / `Cargo.lock` / `go.sum` — commit them. Lockfiles are what Dependabot scans.
2. **Update dependencies via PR**, never via direct push. Dependabot opens these automatically for vulnerable transitive deps.
3. **Review the Dependency Review PR comment** before merging any PR that changes lockfiles. It surfaces newly-introduced CVEs.
4. **Pin GitHub Actions to SHA**, not floating tag (see [POLICY-ACTIONS.md](POLICY-ACTIONS.md) — enforced by `sha_pinning_required`).
5. **Pin Docker images by digest** for production runtimes (`@sha256:…`).

## Dependabot configuration

A baseline `dependabot.yml` is suggested per repo:

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: npm
    directory: "/"
    schedule: { interval: weekly }
    open-pull-requests-limit: 10
    groups:
      minor-and-patch:
        update-types: [minor, patch]
  - package-ecosystem: github-actions
    directory: "/"
    schedule: { interval: weekly }
```

The org maintains a private GitHub App PAT for Dependabot access to private spoke registry packages. See `reference_dependabot_private_packages_gotcha_2026_05_08` for details.

## What is NOT yet enforced

- **Required Dependency Review check on every PR.** Available as `.github/workflow-templates/dependency-review.yml`; per-repo opt-in.
- **SBOM generation on every release.** Available as `.github/workflow-templates/sbom.yml`; per-repo opt-in. Will become mandatory for `tier-platform` repos.
- **License-allowlist enforcement.** Currently lax; PRs introducing GPL-incompatible deps are reviewed but not blocked.

## How to verify

```bash
gh api repos/{owner}/{repo} --jq '.security_and_analysis | {secret_scanning, dependabot_security_updates, code_security}'
gh api repos/{owner}/{repo}/dependabot/alerts --jq 'map({number, state, severity: .security_advisory.severity})'
```

## Related

- [POLICY-ACTIONS.md](POLICY-ACTIONS.md)
- [POLICY-SECRETS.md](POLICY-SECRETS.md)
- Workflow templates: `.github/workflow-templates/dependency-review.yml`, `.github/workflow-templates/sbom.yml`
