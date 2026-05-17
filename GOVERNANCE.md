# Governance

This repository (`CyberLegionLtd/.github`) is the **org-wide source of truth** for governance, policy, and reusable infrastructure. Files in this repo apply by fallback to every repository in `CyberLegionLtd` that does not provide its own equivalent.

## Inheritance fallbacks

| If a repo has its own… | …it wins | …else falls back to this repo |
|---|---|---|
| `SECURITY.md` | ✓ | `SECURITY.md` |
| `CODE_OF_CONDUCT.md` | ✓ | `CODE_OF_CONDUCT.md` |
| `.github/CODEOWNERS` or `CODEOWNERS` | ✓ | `CODEOWNERS` |
| `CONTRIBUTING.md` | ✓ | `CONTRIBUTING.md` |
| `SUPPORT.md` | ✓ | `SUPPORT.md` |
| `profile/README.md` | ✓ (own profile) | `profile/README.md` (org profile) |

## What is enforced where

| Layer | Control | Source |
|---|---|---|
| **Enterprise `cyberlegion`** | 2FA mandate, Actions allowlist (`github_owned, verified, CyberLegionLtd/*`), `sha_pinning_required`, default workflow permissions = `read`, members-can-delete-repos = OFF, members-can-invite-outside = OFF, members-can-make-purchases = OFF | Set in enterprise Settings via GraphQL mutations |
| **Enterprise ruleset 16500430** | All non-archived repos × default branch: `deletion` blocked, `non_fast_forward` blocked, `required_linear_history`, `pull_request` with 1 review, dismiss stale, last-push approval, thread resolution; merge methods = `squash, rebase` only | `enterprises/cyberlegion/rulesets/16500430` |
| **Org `CyberLegionLtd`** | New-repo defaults: GHAS (`code_security`), Dependabot alerts + security updates, secret scanning + push protection + validity checks, web commit signoff, public-pages blocked | `orgs/CyberLegionLtd` settings |
| **Per-repo** | Merge button (`squash + rebase` only, no merge commits), auto-merge enabled, delete-branch-on-merge enabled, `code_security` retro-applied, `secret_scanning_ai_detection` enabled | PATCH on each repo |
| **Org-wide repo files** | `SECURITY.md`, `CODE_OF_CONDUCT.md`, `CODEOWNERS` (fallback) | This repo |

## What is NOT yet enforced (deferred)

- Required signed commits (cryptographic GPG/SSH) — deferred until artifact-signing toolchain matures. Will be rolled out tier-aware starting with `tier-platform` repos.
- SAML/SSO + SCIM — deferred until ≥2 active members.
- IP allow list — deferred.
- Audit-log streaming destination — key provisioned, no destination yet.
- Notification delivery restriction with verified domains — deferred until a `@cyberlegion.io` mailbox replaces `@gmail.com` as the primary GitHub email.

## How to change governance

1. Open a PR against `CyberLegionLtd/.github` modifying the relevant `POLICY-*.md` or `GOVERNANCE.md`.
2. PR requires 1 approval (per enterprise ruleset 16500430).
3. After merge, if the change requires API actions (e.g., new ruleset, new org setting), open a tracking issue describing the API command and run it.

## Repository taxonomy (topics)

Each repo carries three classification topics applied 2026-05-17:

- **tier-{platform|spoke|console|landing|app|docs|service|infra|archive|other}** — what kind of artifact this is
- **spoke-{cyberlegion|chyper|dgidgi|stelargate|shared}** — which product line
- **kind-{runtime|sdk|docs|migrations|worker|registry|data|cli|config}** — additional functional descriptors

See `workspace/docs/governance-matrix.md` for the full per-repo classification.

## Audit history

| Date | Event |
|---|---|
| 2026-05-17 | Initial governance baseline. Full audit + hardening across enterprise + org + 387 repos. Report: `workspace/docs/github-config-audit-2026-05-17.md` |
