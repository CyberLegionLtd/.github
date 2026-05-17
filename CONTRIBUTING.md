# Contributing

Most repositories under `CyberLegionLtd` are private. The notes below apply when you are working inside the org — either as an employee, contractor, or invited collaborator.

## Branch model

- `dev` — default working branch on most repos. PRs land here.
- `main` — production / release branch on most repos. Merges from `dev` via PR with linear history.
- Some repos use `main` as the default branch. The repo's GitHub settings are authoritative; do not assume.

## Workflow

1. Branch off `dev` (or default branch). Naming: `<scope>/<short-description>` e.g. `auth/fix-clerk-callback`.
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

The platform's binding ruleset is `POLICY.md` in `workspace/`. Read it before writing code inside `platform/` or `spokes/`. The 37-rule constitution is enforced by:

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
