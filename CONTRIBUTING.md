# Contributing

Most repositories under `CyberLegionLtd` are private. The notes below apply when you are working inside the org — either as an employee, contractor, or invited collaborator.

## Branch model

- `dev` — default working branch on most repos. PRs land here.
- `main` — production / release branch on most repos. Merges from `dev` via PR with linear history.
- Some repos use `main` as the default branch. The repo's GitHub settings are authoritative; do not assume.

## Workflow

1. Branch off `dev` (or default branch). Naming: `<scope>/<short-description>` e.g. `auth/fix-clerk-callback`.
2. Commit small, semantically named commits. The org requires DCO-style sign-off (`Signed-off-by:` on every commit).
3. Open a PR against the default branch.
4. PR requires:
   - ≥ 1 approval
   - Stale reviews dismissed on push
   - Last-push approval (a fresh review after the most recent change)
   - All review threads resolved
   - Squash or rebase merge (merge commits are disabled org-wide)
5. After merge, the head branch is deleted automatically.

## Code quality

Each repository carries its own coding standards, enforced through local pre-commit checks and CI gates. Follow the conventions of the repository you are working in, keep changes focused, and ensure checks pass before requesting review.

## Issue reporting

- Security issues → see [SECURITY.md](SECURITY.md) — do **not** open public issues for vulnerabilities.
- Bugs and feature requests → open an issue on the affected repository.

## Support

See [SUPPORT.md](SUPPORT.md).
