# Contributing

Most repositories under `CyberLegionLtd` are private. The notes below apply when you are working inside the org — either as an employee, contractor, or invited collaborator.

## Branch model

- `main` — the single permanent branch and the repository default. It is protected: no direct pushes, no force pushes, linear history, PR required.
- Short-lived branches only (`feature/`, `fix/`, `security/`, `chore/<short-description>`). They are merged into `main` by PR and deleted; they never become permanent lines.
- `dev` and `staging` are **deployment environments**, not source branches, and are retired per repository after cutover. Do not create them in a new repository.
- `main` is authoritative; the repository's own GitHub settings remain the final check. Repositories still carrying legacy `dev`/`staging` branches follow their declared migration state until cut over.

### Promotion model

Code is promoted by merge. Artifacts are promoted by environment — one signed digest moves DEV → staging → production and is never rebuilt. Packages are promoted by distribution channel (`dev` integration, optional `rc`/`next` candidate, `latest` stable) using registry dist-tags, never Git branches. Configuration is scoped by environment (variables, secrets, URLs, IAM). Source must not change between environments.

## Workflow

1. Branch off `main`. Naming: `<type>/<issue>-<short-description>` e.g. `fix/412-clerk-callback`. One task per branch.
2. Commit small, semantically named commits. We do not require cryptographic signatures yet (this is on the deferred list), but the org requires DCO-style sign-off (`Signed-off-by:` on every commit) — enforced by `web_commit_signoff_required`.
3. Open a PR against the default branch.
4. PR requires:
   - ≥ 1 approval
   - Stale reviews dismissed on push
   - Last-push approval (a fresh review after the most recent change)
   - All review threads resolved
   - Squash or rebase merge (merge commits are disabled org-wide)
5. After merge, the head branch is deleted automatically.

## Code quality

The platform's binding ruleset is `POLICY.md` in `workspace/`. Read it before writing code inside `platform/` or `spokes/`. The 41-rule constitution is enforced by:

- PreToolUse hooks on Edit/Write/MultiEdit during development (Claude Code workspaces)
- Pre-commit grep audit (`policy-pre-commit.sh`)
- CI gate on every PR

Common rejections:
- `NOT_IMPLEMENTED` without `// guard:` annotation
- `mock-${Date.now()}` / fabricated IDs outside tests
- Hardcoded `localhost:NNNN`, secrets, or `API_KEY` literals
- Empty `catch {}`
- `console.log` in platform / spokes source
- `pgTable(` outside `platform-schema/`

## Issue reporting

- Security issues → see [SECURITY.md](SECURITY.md) — do **not** open public issues for vulnerabilities.
- Bugs and feature requests → open an issue on the affected repository.

## Support

See [SUPPORT.md](SUPPORT.md).
