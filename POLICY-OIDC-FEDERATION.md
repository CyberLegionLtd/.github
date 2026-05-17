# POLICY: OIDC Federation (preparation phase)

**Status:** Preparation. NOT fully implemented.  **Drafted:** 2026-05-17.  **Owner of decision authority:** EnterpriseOwner.

## Why OIDC federation matters

Every long-lived deploy credential in your org is a permanent attack surface. `FLY_API_TOKEN`, `CLOUDFLARE_API_TOKEN`, `SUPABASE_SERVICE_ROLE` — once leaked, they remain valid until manually rotated. OIDC federation replaces them with **short-lived, audience-scoped tokens** minted at workflow runtime from GitHub's OIDC issuer.

The win: zero stored deploy secrets. The cost: per-target trust chain setup.

This is **Stage 5** in the CyberLegion maturity ladder. The supply-chain primitives in [POLICY-ACTIONS.md](POLICY-ACTIONS.md) (SHA pinning, default `read` token) are the prerequisite layer; OIDC federation is the next layer.

## Trust chain

```
GitHub Actions workflow
   │
   ├─ permissions: id-token: write
   │
   ▼
GitHub OIDC issuer (token.actions.githubusercontent.com)
   │
   │  Token carries claims:
   │    iss   = https://token.actions.githubusercontent.com
   │    sub   = repo:CyberLegionLtd/<repo>:environment:<env>
   │    aud   = (target-specified audience)
   │    job_workflow_ref, ref, run_id, repository_id, ...
   │
   ▼
Target provider (Fly / AWS / GCP / Azure / Cloudflare)
   │
   │  Trust policy validates iss + sub claim
   │
   ▼
Short-lived target credential (15-60 min)
   │
   ▼
Deploy / read / write
```

## Per-target maturity

| Target | OIDC support | What's needed |
|---|---|---|
| **AWS** | First-class | Create IAM role + trust policy referencing `repo:CyberLegionLtd/*:environment:production`. Workflow uses `aws-actions/configure-aws-credentials@*` with `role-to-assume`. |
| **GCP** | First-class | Workload Identity Federation pool + provider. Workflow uses `google-github-actions/auth@*` with `workload_identity_provider`. |
| **Azure** | First-class | Federated credential on Service Principal. Workflow uses `azure/login@*` with `client-id` + `tenant-id`. |
| **Fly.io** | Native (via macaroons + OIDC) | Configure Fly OIDC trust (Fly Dashboard → Tokens → OIDC), set `subject_claim_template`. Workflow uses `superfly/flyctl-actions@*`. |
| **Cloudflare** | **Not yet first-class** for Workers/Pages | Workaround: GitHub OIDC → AWS IAM role → AWS Secrets Manager → CF API token. Or wait for CF native OIDC roadmap. |
| **Supabase** | **Not yet first-class** | Workaround: GitHub OIDC → AWS/GCP role → Supabase service_role from secret store. |
| **Vercel** | First-class via OIDC | `vercel/action@*` with team-level OIDC config. |
| **NPM** | First-class (provenance) | `npm publish --provenance` uses workflow OIDC automatically; npm token still needed for publish auth. |

## Workflow patterns (templates seeded)

This `.github` repo provides OIDC-ready starter workflows. They are NOT auto-applied — repos opt in via the GitHub UI's "New workflow → starter workflows".

| Template | File |
|---|---|
| Fly.io deploy (OIDC-ready) | `.github/workflow-templates/deploy-fly-oidc.yml` |
| Cloudflare Workers deploy (OIDC-ready, API-token-today) | `.github/workflow-templates/deploy-cloudflare.yml` |
| Artifact attestation (provenance signing) | `.github/workflow-templates/artifact-attestation.yml` |
| SBOM generation + attestation | `.github/workflow-templates/sbom.yml` |
| Dependency review on PRs | `.github/workflow-templates/dependency-review.yml` |

All templates declare `permissions: id-token: write` where applicable and gate deploys behind GitHub Environments with required reviewers.

## Migration order (when ready to execute)

Per `project-github-as-governance-control-plane-2026-05-17` priority order, the deployment-target rollout is:

1. **Cloudflare** first (highest credential volume; CF tokens are the most numerous long-lived secret today). Initially via the AWS-role workaround until CF ships native OIDC.
2. **Fly.io** second (Fly has native OIDC; clean wins).
3. **Supabase** last (no native OIDC; via AWS-role workaround).

Each migration is its own session. Order per spoke: 1 pilot repo → verify trust chain → roll out to siblings.

## Forbidden anchors

- ❌ `FLY_API_TOKEN`, `CLOUDFLARE_API_TOKEN`, etc. as long-lived org-level secrets once the OIDC chain is live for that target. Migrate them to ephemeral mints.
- ❌ OIDC trust policies broader than `repo:CyberLegionLtd/<exact-repo>:environment:<exact-env>`. Never use `repo:CyberLegionLtd/*:*` — that gives every workflow in every repo the deploy role.
- ❌ Skipping the GitHub Environment gate. Deploys without environment = no required reviewers, no protection rules. Always gate.

## Correct anchors

- ✅ Per-environment IAM roles / service principals / Fly tokens with audience-scoped trust.
- ✅ `permissions: id-token: write` declared at workflow level (not repo default).
- ✅ Required-reviewer protection on `production` environment in each repo.
- ✅ Audit log streaming captures OIDC token issuance for forensic timeline.

## Verification

When a target migration completes:

```bash
# Confirm no API token secret used in deploy workflow:
gh secret list --repo CyberLegionLtd/<repo> | grep -E 'FLY_API|CLOUDFLARE_API|SUPABASE_SERVICE'  # should be empty

# Confirm OIDC permission declared:
gh api repos/CyberLegionLtd/<repo>/contents/.github/workflows/deploy.yml \
  --jq '.content' | base64 -d | grep -E 'id-token: write'

# Confirm trust audit in target provider's logs
```

## Cross-refs

- [POLICY-ACTIONS.md](POLICY-ACTIONS.md) — Actions allowlist + SHA pinning (prerequisite)
- [GOVERNANCE.md](GOVERNANCE.md) — overall governance map
- `workspace/docs/cyberlegion-ai-os-model.md` — Stage 5/6 supply-chain primitives
- `reference_cyberlegion_ai_os_model_2026_05_17` (memory)
