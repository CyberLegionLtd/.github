# Project #8 — estate board

`configure.mjs` sets up https://github.com/orgs/CyberLegionLtd/projects/8 as one board for every spoke:

- **Fields:** `Spoke` (a8i, chyper, cyberlegion, dgidgi, stelargate, one, clq, clp, estate), `Repo Type`
  (hub, api, console, docs, landing, status, support, marketplace, shop, registry, platform-service,
  capability, org). The built-in `Repository` field covers the repo.
- **Roadmap fields:** `Size` (XS–XL), `Start date`, `Target date`. Priority, Estimate and Iteration already exist on the project. Use `--fields-only` to create fields without touching items.
- **Repos:** links every non-archived org repo to the project.
- **Items:** adds every open issue and PR and sets `Spoke` and `Repo Type`.

The spokes come from `CyberLegionLtd/spokes` → `spokes.json`. Repos are classified by name prefix
(`<spoke>-<surface|capability>`). `clp-*` is the platform layer. `spokes`, `spokes-registry`,
`base-registry`, `hub` and `.github` are `estate`.

## Run

```sh
PROJECT_TOKEN=<classic PAT: project, repo, read:org> node project-8/configure.mjs --dry-run
PROJECT_TOKEN=... node project-8/configure.mjs
```

The daily **Project 8 sync** workflow lives in `CyberLegionLtd/spokes` and uses the `PROJECT_TOKEN` secret from its `dev` environment.

## Views (manual step; the API can't create views)

| View | Layout | Group / filter |
|------|--------|----------------|
| By spoke | Board | Column: Status, group by `Spoke` |
| Spoke repos | Table | Group by `Spoke`, then sort by `Repo Type` |
| Platform (clp) | Table | Filter `Spoke:clp` |
| Surfaces | Table | Filter `Repo Type:api,console,docs,landing,status,support,marketplace,shop` |
| Open PRs | Table | Filter `is:pr is:open`, group by `Repository` |
