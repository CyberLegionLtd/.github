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
| `actions/spoke-run`, `ci-templates/` | Run a spoke capability from GitHub Actions, GitLab CI, Jenkins or Azure DevOps ([docs/SPOKE-INTEGRATIONS.md](docs/SPOKE-INTEGRATIONS.md)) |

## Releasing the shared automation

Consumers reference one release tag (`RELEASE_TAG`, currently `v1`), never a
branch. The reusable workflows call actions from this repository at that same
tag, so a workflow and the actions it depends on always come from one commit.

1. Merge to `main` with `scripts/check-release-refs.sh` passing.
2. Tag the merge commit with the value in `RELEASE_TAG` (`git tag v1 <sha>`;
   for later compatible fixes, move the tag with `git tag -f v1 <sha>` and
   push with `--force`).
3. A breaking change bumps `RELEASE_TAG` (for example to `v2`), updates every
   reference in the same change, and leaves the old tag in place for existing
   consumers.

Until step 2 has happened nothing that references `@v1` can run.
