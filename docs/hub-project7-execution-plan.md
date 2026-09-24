# Hub Project #7 execution plan

Source: roadmap/roadmap.json + docs/plan/status.md at origin/dev (2026-09-24). **Sub-issue counts unavailable**: GitHub API rate limit exceeded for every list_issues call; rerun to fill the open/closed columns.

## Goals

| Goal | P | Milestone | Blocked by | Sub-issues o/c | Live-ops signals | Human-decision signals | Gap |
|---|---|---|---|---|---|---|---|
| Milestone 0 walking skeleton (`walking-skeleton`) | P0 | M0 | - | n/a | gpu | - | Manual gateway → GPU → credits path not yet proven end to end |
| All Hub repositories operational on dev (`dev-operational`) | P0 | M1 | registries-republished | n/a | - | review | Dev CI is red on most indexed repositories (architecture/reviews/HUB-ARCHITECTURE-REVIEW-2026-09-23-R2.md) |
| CLP v1 released to dev (entire Hub) (`clp-v1-dev`) | P0 | M1 | registries-republished, dev-operational, dev-deployed-live | n/a | deploy, publish | - | No single release record shows every Hub repository installed, built, tested, published and deployed on dev together as  |
| Tenant-scoped checkpoint snapshot (`tenant-scoped-checkpoint-snapshot`) | P1 | M2 | - | n/a | live | - | Live storage/RLS, full suites and complete runtime journey remain unproved |
| Full Intelligence verification admission (`full-intelligence-verification-admission`) | P1 | M2 | - | n/a | verifier | - | R2 frozen workspace installation failed; later concurrent root pin correction is not a successful full rerun |
| Secret-scan gate integrity (`secret-scan-gate-integrity`) | P0 | M2 | - | n/a | - | disposition | Historical credential and PTY findings need individual disposition; runtime/build readiness remains separate |
| Preserved-evidence scan coverage (`preserved-evidence-scan-coverage`) | P0 | M2 | - | n/a | - | - | Preserved patches may contain both false positives and real credentials; blanket exclusions are not remediation |
| Default secret detector policy (`default-secret-detector-policy`) | P0 | M2 | - | n/a | - | review, disposition | Historical JWT findings need reviewed disposition and complete scanner evidence |
| Mandatory CMS release verification (`mandatory-cms-release-verification`) | P1 | M2 | - | n/a | deploy | - | Canonical Base locale input is missing from standalone release verification; deployed credential issue requires recheck |
| Chat/Work golden journey (`chat-work-golden-journey`) | P1 | M2 | - | n/a | - | - | No complete correlated authenticated journey recorded |
| Durable workflow execution (`durable-workflow-execution`) | P1 | M2 | - | n/a | - | review | Prior duplicate workflow runtime was de-admitted; existing checkpoint/DAG semantics need whole-path review |
| Reality-grounded planning (`reality-grounded-planning`) | P1 | M2 | - | n/a | - | - | Prior audit reported missing versioned projection and non-atomic replanning |
| Workforce delegation and supervision (`workforce-delegation-and-supervision`) | P1 | M2 | - | n/a | - | - | Authenticated assignment/delegation graph evidence incomplete |
| Factory certification (`factory-certification`) | P1 | M2 | capability-graph-reconciled | n/a | - | - | Evidence producers and per-capability correlation not reconciled estate-wide |
| SCOS cognition runtimes (`scos-cognition-runtimes`) | P1 | M2 | - | n/a | - | - | Previous L0 assessment is historical, not current runtime proof |
| Evaluation lineage (`evaluation-lineage`) | P1 | M2 | - | n/a | - | - | Same-run/artifact judgment lineage unproved |
| CLQ specialist capabilities (`clq-specialist-capabilities`) | P2 | M2 | - | n/a | - | - | Numerical/provider/software boundaries and governed execution incomplete |
| CLD specialist capabilities (`cld-specialist-capabilities`) | P2 | M2 | - | n/a | live | - | Provider and live transaction/finality evidence not established |
| CLN specialist capabilities (`cln-specialist-capabilities`) | P2 | M2 | - | n/a | - | - | Earlier documentation-only label may be stale; inspect current packages |
| CLX specialist capabilities (`clx-specialist-capabilities`) | P2 | M2 | - | n/a | - | - | Spatial workload, contracts and consuming path not qualified |
| CLO specialist capabilities (`clo-specialist-capabilities`) | P2 | M2 | - | n/a | - | approv | Optical workload/provider admission not qualified |
| CLM specialist capabilities (`clm-specialist-capabilities`) | P2 | M2 | - | n/a | - | approv | Molecular/DNA workload and consuming path not qualified |
| Request identity and semantic-response reuse (`request-identity-and-semantic-response-reuse`) | P1 | M2 | - | n/a | revocation, live | revocation | Live policy/provider/revocation, distributed cache and complete Work journey remain unqualified |
| Immutable Intelligence source graph (`immutable-intelligence-source-graph`) | P1 | M2 | - | n/a | - | - | Required PR blocked generated-lock publication; full runtime gate remains open |
| Learning transition Promise contract (`learning-transition-promise-contract`) | P1 | M2 | - | n/a | - | approv | Approved publication and full runtime verification required |
| Historical-fixture secret scan (`historical-fixture-secret-scan`) | P0 | M2 | - | n/a | - | - | Other repository/enterprise gates and inherited exceptions not requalified |
| Compute historical finding disposition (`compute-historical-finding-disposition`) | P0 | M2 | - | n/a | secret, rotation, revocation | review, rotation, revocation | GH_CLIENT_SECRET revocation/rotation unverified |
| Context-compaction trust and instruction preservation (`context-compaction-trust-and-instruction-preservation`) | P0 | M2 | - | n/a | - | review | Required review blocks publication; full runtime, provider and Work E2E remain unqualified |
| Hub registries production-ready and verified for consumers (`registries-republished`) | P0 | M1 | - | n/a | publish | - | All four *-registry repositories resolve packages from source; published versions on GitHub Packages are not current or  |
| Every service deployed to dev and live-checked (`dev-deployed-live`) | P0 | M1 | dev-operational, registries-republished | n/a | deploy | - | A green build is not proof a service is running |
| Capability graph and OS model reconciled (`capability-graph-reconciled`) | P1 | M2 | - | n/a | - | - | Generated graph omits 23 federation declarations; OS capability model reports 42 unresolved owners (reports/hub-capabili |
| Business app runs on the AI OS (`business-app-on-os`) | P1 | M3 | registries-republished, dev-deployed-live, any-task-execution, model-backed-agent-harness | n/a | publish | - | No application outside the platform has yet run end to end through the public SDKs |
| Governed execution of any task (`any-task-execution`) | P1 | M3 | durable-workflow-execution, model-backed-agent-harness | n/a | - | approv | Arbitrary task execution needs sandboxing, approval gates, idempotency and recovery proven together |
| Promotion to staging and main (`promotion-staging-main`) | P2 | M4 | dev-deployed-live | n/a | - | approv | staging and main are protected and only take pull requests; nothing is promoted yet |
| Production readiness sign-off (`production-readiness`) | P2 | M4 | promotion-staging-main, compute-historical-finding-disposition, context-compaction-trust-and-instruction-preservation, default-secret-detector-policy, historical-fixture-secret-scan, preserved-evidence-scan-coverage, secret-scan-gate-integrity | n/a | publish | review | SLOs, recovery drills, security review and on-call are not established |
| Model-backed agent harness (`model-backed-agent-harness`) | P1 | M3 | walking-skeleton | n/a | - | - | No single agent loop yet runs model → tool call → sandboxed execution → result → next step with context management, perm |
| H-Stg: All Hub repositories on staging (`h-stg`) | P1 | M4 | dev-operational | n/a | - | - | No Hub repository has passed the staging rung yet. |
| H-Prod: Hub live on main (`h-prod`) | P1 | M4 | h-stg | n/a | - | approv | No Hub repository has passed the prod rung yet. |
| Digital humans and avatars qualified (`digital-humans-avatars`) | P2 | M3 | - | n/a | publish | - | clp-avatars (versioned asset collection for digital humans and spatial environment templates) is PROTOTYPE with no LLD a |
| Connectors and MCP tools through the governed kernel (`connectors-mcp`) | P1 | M3 | - | n/a | live | - | Connector catalog exists as metadata (base-registry catalogs/connectors) and a CLP Admin configuration binding; OAuth ha |
| Plugins and skills in the Semantic Hub (`plugins-skills-semantic-hub`) | P1 | M3 | - | n/a | - | - | The Semantic Hub (clp-hub, GET /hub/resources) lists capabilities, templates, skills, prompts and snippets but has no pl |
| Shells integrated with delivery: GitHub and Factory evidence (`shells-delivery-integration`) | P2 | M3 | - | n/a | deploy, verifier | - | No shell integrates with GitHub issues, pull requests, projects or Actions; workbench-shell has only generic Git UI; Fac |

## Wave plan (dependency depth; goals in one wave run in parallel)

### Wave 0
- P0 Milestone 0 walking skeleton (M0)
- P0 Secret-scan gate integrity (M2)
- P0 Preserved-evidence scan coverage (M2)
- P0 Default secret detector policy (M2)
- P0 Historical-fixture secret scan (M2)
- P0 Compute historical finding disposition (M2)
- P0 Context-compaction trust and instruction preservation (M2)
- P0 Hub registries production-ready and verified for consumers (M1)
- P1 Tenant-scoped checkpoint snapshot (M2)
- P1 Full Intelligence verification admission (M2)
- P1 Mandatory CMS release verification (M2)
- P1 Chat/Work golden journey (M2)
- P1 Durable workflow execution (M2)
- P1 Reality-grounded planning (M2)
- P1 Workforce delegation and supervision (M2)
- P1 SCOS cognition runtimes (M2)
- P1 Evaluation lineage (M2)
- P1 Request identity and semantic-response reuse (M2)
- P1 Immutable Intelligence source graph (M2)
- P1 Learning transition Promise contract (M2)
- P1 Capability graph and OS model reconciled (M2)
- P1 Connectors and MCP tools through the governed kernel (M3)
- P1 Plugins and skills in the Semantic Hub (M3)
- P2 CLQ specialist capabilities (M2)
- P2 CLD specialist capabilities (M2)
- P2 CLN specialist capabilities (M2)
- P2 CLX specialist capabilities (M2)
- P2 CLO specialist capabilities (M2)
- P2 CLM specialist capabilities (M2)
- P2 Digital humans and avatars qualified (M3)
- P2 Shells integrated with delivery: GitHub and Factory evidence (M3)

### Wave 1
- P0 All Hub repositories operational on dev (M1)
- P1 Factory certification (M2)
- P1 Model-backed agent harness (M3)

### Wave 2
- P0 Every service deployed to dev and live-checked (M1)
- P1 Governed execution of any task (M3)
- P1 H-Stg: All Hub repositories on staging (M4)

### Wave 3
- P0 CLP v1 released to dev (entire Hub) (M1)
- P1 Business app runs on the AI OS (M3)
- P1 H-Prod: Hub live on main (M4)
- P2 Promotion to staging and main (M4)

### Wave 4
- P2 Production readiness sign-off (M4)

## Critical path to M1 Dev operational

1. **registries-republished** (code: registry builds; ops: publish to GitHub Packages; consumer install test). Within it: base-registry first, then clp/spokes/one-registry in parallel.
2. **dev-operational**: CI green on every Hub repo (code), then H-Dev rungs base-registry -> other registries -> clp services -> gateway. Parallel sidecar: clp-gates health/smoke contract and promotion gates (no blockers, start now).
3. **dev-deployed-live**: deploy each service to dev, verifier smoke 24h green (ops: deploy, DNS, secrets, verifier matrix in clp-infra, which is blocked by the health-smoke contract).
4. **clp-v1-dev**: single release record across all 41 repos (human release approval).

Off-path, start immediately in Wave 0: walking-skeleton (M0, GPU), all P0 secret-scan goals (human dispositions), capability-graph-reconciled.

## Human-only blockers
- GH_CLIENT_SECRET revocation/rotation (compute-historical-finding-disposition).
- Per-finding disposition of historical credentials/JWT/PTY findings (secret-scan-gate-integrity, default-secret-detector-policy, preserved-evidence-scan-coverage).
- Required reviews blocking publication (context-compaction, immutable source graph, learning Promise contract).
- Dev secrets/DNS/GPU provisioning for deploys; CMS deployed-credential recheck.
- CLP v1 release approval; specialist-plane applicability rationales (CLQ/CLD/CLN/CLX/CLO/CLM).
