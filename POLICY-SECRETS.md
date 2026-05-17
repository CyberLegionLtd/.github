# POLICY: Secrets

**Status:** Active.  **Effective:** 2026-05-17.  **Scope:** Every repository in `CyberLegionLtd`.

## What is enforced at GitHub level

| Control | Setting | Where |
|---|---|---|
| Secret scanning | ON for all active repos (331/331) | Org default + per-repo |
| Push protection | ON for all active repos | Org default + per-repo |
| Validity checks | ON for all active repos | Org default |
| AI detection | ON for all active repos (post-2026-05-17 retro-enable) | Per-repo `secret_scanning_ai_detection` |
| Non-provider patterns | ON for repos with `code_security` enabled | Per-repo |
| Push-protection custom link | Available | Org setting |

## What contributors must do

1. **Never commit secrets.** Push protection will block the push with a clear error. Do not attempt to bypass without sign-off (bypass is audited).
2. **Use `.env.example` for placeholder values.** Use the literal string `xxxxxxxxxxxxxxxxxxxxxxxxxxxx` or `<placeholder>` — never a real-shaped secret.
3. **Real secrets go in environment variables**, GitHub Actions secrets (org or repo), Fly secrets, Cloudflare Worker secrets, or the platform's secret-namespace hierarchy (see `workspace/CLAUDE.md`).
4. **Source files reading secrets** must use `process.env.NAME` (or equivalent). Hardcoded literals fail POLICY Rule 15.5 and will trigger secret scanning.
5. **If a secret leaks** — even if just a placeholder format that triggers scanning:
   - Treat it as compromised until proven otherwise
   - Rotate in the provider (Stripe, Supabase, Cloudflare, Anthropic, etc.)
   - Update all consumers
   - Mark the GitHub alert resolved with the resolution reason

## Known outstanding alerts (2026-05-17)

| # | Repo | Path | Type | Status |
|---|---|---|---|---|
| 1 | `platform-compute` | `.env:17` | Supabase service_role JWT | Open — deferred per business decision |
| 2 | `platform-gateway` | `.env.example:239` | Stripe whsec placeholder | Resolved (false_positive) |
| 3 | `chyper-io` | `.env.example:239` | Stripe whsec placeholder | Resolved (false_positive) 2026-05-17 |
| 4 | `cyberlegion-console` | `scripts/sync_github_secrets.cjs` (blob f3f67dbe…) | Stripe whsec real | Open — **rotation pending in Stripe Dashboard** |
| 5 | `cyberlegion-console` | same script, second secret | Stripe whsec real | Open — same |

## What contributors should NEVER do

- Push real `whsec_…` Stripe signing secrets, `eyJ…` service-role JWTs, `xoxb-…` Slack tokens, `ghp_…` PATs, `AKIA…` AWS keys, or any provider-shaped credential. Push protection blocks these.
- Use `git filter-branch` or `git filter-repo` to rewrite history without coordinating with org admin — rewrites break dependent clones and CI artifact SHAs.
- Add `# noqa` or comment annotations attempting to hide a secret from scanners.

## How to verify

```bash
gh api orgs/CyberLegionLtd/secret-scanning/alerts --jq 'map({number, repo: .repository.full_name, type: .secret_type, state})'
```

## Related

- [POLICY-DEPENDENCY-MANAGEMENT.md](POLICY-DEPENDENCY-MANAGEMENT.md)
- [SECURITY.md](SECURITY.md)
