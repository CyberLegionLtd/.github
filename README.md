# .github

Org-wide defaults for CyberLegionLtd: SECURITY policy, profile README,
CODE_OF_CONDUCT, and the shared automation every product repository can use.

## Shared client builds

Build any product as mobile apps and browser extensions from a single client
descriptor. See [docs/CLIENT-DISTRIBUTION.md](docs/CLIENT-DISTRIBUTION.md).

| Path | What it is |
|---|---|
| `.github/workflows/clp-client-mobile.yml` | Reusable workflow: iOS and Android apps via `clp-client-host-mobile` |
| `.github/workflows/clp-client-extension.yml` | Reusable workflow: Chrome, Edge, Firefox and Safari extensions via `clp-client-host-extension` |
| `actions/setup-client-host` | Composite action: checks out a client host and the descriptor contract, then installs dependencies |
| `workflow-templates/` | Starter workflows shown under **Actions → New workflow** in every org repository |
