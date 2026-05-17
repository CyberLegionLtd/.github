# Domain portfolio (Cloudflare)

Cyber Legion operates 62 active zones on Cloudflare, grouped by product line. All zones are on Cloudflare Free plan, type `full`, no development-mode enabled, none paused (snapshot 2026-05-17).

> Detailed inventory: `workspace/docs/cloudflare-domain-inventory-2026-05-17.md`.

## Canonical domains per product

These are the **primary** domains for each product line — the ones that should appear in marketing, code, and trust posture (verified domains in GitHub, primary HTTPS targets, etc.).

| Product | Primary | Status |
|---|---|---|
| Cyber Legion | `cyberlegion.io` | Active |
| Cyber Legion (legal) | `cyberlegion.co.uk` | Active |
| Chyper | `chyper.io` | Active |
| dgidgi | `dgidgi.io` | Active |
| Stelargate | `stelargate.io` | Active |
| a8i | `a8i.io` | Active |

## Full zone list (62)

### Cyber Legion (14 zones)
`cyberlegion.ai`, `cyberlegion.ch`, `cyberlegion.co.uk`, `cyberlegion.dev`, `cyberlegion.es`, `cyberlegion.in`, **`cyberlegion.io`**, `cyberlegion.me`, `cyberlegion.net`, `cyberlegion.nl`, `cyberlegion.one`, `cyberlegion.pro`, `cyberlegion.us`, `cyberlegion.vip`

### Chyper (18 zones)
`chyper.ai`, `chyper.app`, `chyper.cloud`, `chyper.co`, `chyper.dev`, `chyper.es`, `chyper.eu`, **`chyper.io`**, `chyper.live`, `chyper.me`, `chyper.net`, `chyper.org`, `chyper.pro`, `chyper.space`, `chyper.tech`, `chyper.uno`, `chyper.vip`, `chyper.world`

### dgidgi (27 zones)
`dgidgi.ai`, `dgidgi.app`, `dgidgi.art`, `dgidgi.biz`, `dgidgi.cloud`, `dgidgi.club`, `dgidgi.co`, `dgidgi.co.uk`, `dgidgi.dev`, `dgidgi.digital`, `dgidgi.es`, `dgidgi.eu`, `dgidgi.info`, **`dgidgi.io`**, `dgidgi.live`, `dgidgi.me`, `dgidgi.net`, `dgidgi.one`, `dgidgi.org`, `dgidgi.pro`, `dgidgi.shop`, `dgidgi.store`, `dgidgi.tv`, `dgidgi.uno`, `dgidgi.vip`, `dgidgi.world`, `dgidgi.xyz`

### Stelargate (1 zone)
**`stelargate.io`**

### a8i (2 zones)
`a8i.eu`, **`a8i.io`**

## TLD governance reminder

Per memory `feedback_tld_governance_locked_2026_05_14` (revised 2026-05-17):

| Use | TLD |
|---|---|
| Internal / control plane | `.co.uk` |
| Execution + tenant consoles | `.io` |
| AI products + public marketing | `.ai` |
| Business / commercial | `.one` |
| Geo / intelligence | `.world` |

Consoles are migrating to `.io` (was `.ai`). `.ai` becomes marketing-only.

## What's NOT enforced (yet)

- **Verified domains in GitHub** — GitHub UI-only feature, not API-configurable. Verification would unlock notification-domain restriction and tenant-attribution badges. Manual setup required for the 7 canonical domains above.
- **TLS/security baselines per zone** — auditing requires `Zone Settings: Read` scope (current wrangler OAuth token only has `zone:read`). To run the audit, mint a fresh CF API token with that scope and re-run `workspace/docs/_github-audit-2026-05-17/cf-audit.sh`.
- **Domain expiry monitoring** — all registered via GoDaddy / Go Canada Domains. No central renewal alerts beyond registrar emails.

## How to verify

```bash
# CF zones (requires CF API token with zone:read)
curl --ssl-no-revoke -H "Authorization: Bearer $CF_API_TOKEN" \
  'https://api.cloudflare.com/client/v4/zones?per_page=50' | jq '.result | map({name, status, plan: .plan.name})'
```
