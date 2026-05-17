# Security Policy

Cyber Legion treats security as a first-class concern. If you discover a vulnerability in any Cyber Legion product, please report it privately — not in a public issue.

## Reporting a vulnerability

- **Preferred:** Use GitHub Private Vulnerability Reporting (Security tab → "Report a vulnerability") on the affected repository.
- **Email fallback:** [security@cyberlegion.io](mailto:security@cyberlegion.io) with subject line `[SECURITY] <repo or product>`.

Please include:

- A description of the vulnerability and its impact
- Steps to reproduce (proof-of-concept code or screenshots welcome)
- Affected versions / commits / endpoints
- Your contact details if you would like disclosure credit

## What to expect

- **Acknowledgement** within 2 business days
- **Triage + initial assessment** within 5 business days
- **Fix or mitigation timeline** based on severity (CVSS v3.1):
  - Critical (≥ 9.0) — patched within 7 days
  - High (7.0 – 8.9) — patched within 30 days
  - Medium (4.0 – 6.9) — patched within 60 days
  - Low (< 4.0) — next release cycle

## Scope

**In scope:**
- All repositories under [github.com/CyberLegionLtd](https://github.com/CyberLegionLtd)
- All Cyber Legion-operated services on `cyberlegion.io`, `cyberlegion.ai`, `cyberlegion.co.uk`, and spoke product domains
- Cyber Legion-published packages and Docker images

**Out of scope:**
- Third-party services we depend on (GitHub, Cloudflare, Supabase, Stripe, etc.) — please report to those vendors directly
- Issues in upstream software dependencies — please report upstream
- Denial-of-service via volumetric attacks
- Social engineering, phishing, or physical attacks
- Vulnerabilities requiring physical access to a user's device

## Disclosure policy

We follow coordinated disclosure. Please give us a reasonable window to ship a fix before publishing technical details. We will credit researchers in release notes unless anonymity is requested.

## Safe harbour

If you act in good faith — investigate only as far as needed to demonstrate the issue, avoid privacy violations and service disruption, and report promptly — we will not pursue legal action against you. Public, accidental discoveries by users of the service are equally welcome.
