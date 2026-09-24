# Connecting other tools to a spoke

Every spoke (cyberlegion, a8i, chyper, dgidgi, stelargate) can be used from AI
assistants, CI pipelines and scripts through its **branded CLI**. The CLI
signs in as your tenant and only ever talks to the spoke's public API
(`https://api.<spoke-domain>`). Nothing here reaches internal systems.

| You want to use a spoke from… | Use |
|---|---|
| Claude Desktop, Claude Code, Cursor, VS Code, other MCP clients | `<spoke> mcp` (below) |
| GitHub Actions | `CyberLegionLtd/.github/actions/spoke-run` |
| GitLab CI | `ci-templates/gitlab-spoke-run.yml` |
| Jenkins | `ci-templates/Jenkinsfile.spoke-run` |
| Azure DevOps | `ci-templates/azure-pipelines.spoke-run.yml` |
| Scripts | the CLI directly: `<spoke> run <capability> --input-json '{…}'` |

All of them read the same three settings, prefixed with the spoke name in
upper case (`DGIDGI_…`, `A8I_…`, `CYBERLEGION_…`):

| Variable | Value |
|---|---|
| `<SPOKE>_API_URL` | `https://api.<spoke-domain>` |
| `<SPOKE>_API_TOKEN` | your tenant token (keep it secret) |
| `<SPOKE>_API_TIMEOUT_MS` | `30000` |

## AI assistants (MCP)

`<spoke> mcp` runs a local Model Context Protocol server over stdio. The
assistant gets these tools, each one a call on the spoke's own API:

| Tool | Effect |
|---|---|
| `session`, `list_tenants` | who you are, which tenants you can use |
| `list_apps`, `get_app`, `get_capability`, `list_starters`, `get_starter`, `get_plan` | read |
| `run_capability` | submit one governed run (returns the run id) |
| `get_run`, `get_run_status` | follow a run |
| `cancel_run` | cancel a run (marked destructive, so clients ask first) |
| `chat` | talk to the spoke assistant |

**Claude Desktop / Cursor** (`claude_desktop_config.json`, `.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "dgidgi": {
      "command": "dgidgi",
      "args": ["mcp"],
      "env": {
        "DGIDGI_API_URL": "https://api.dgidgi.io",
        "DGIDGI_API_TOKEN": "<tenant token>",
        "DGIDGI_API_TIMEOUT_MS": "30000"
      }
    }
  }
}
```

**Claude Code:**

```bash
claude mcp add dgidgi \
  -e DGIDGI_API_URL=https://api.dgidgi.io \
  -e DGIDGI_API_TOKEN=<tenant token> \
  -e DGIDGI_API_TIMEOUT_MS=30000 \
  -- dgidgi mcp
```

**VS Code** (`.vscode/mcp.json`):

```json
{
  "servers": {
    "dgidgi": {
      "type": "stdio",
      "command": "dgidgi",
      "args": ["mcp"],
      "env": { "DGIDGI_API_URL": "https://api.dgidgi.io", "DGIDGI_API_TOKEN": "${input:dgidgi-token}", "DGIDGI_API_TIMEOUT_MS": "30000" }
    }
  },
  "inputs": [{ "id": "dgidgi-token", "type": "promptString", "description": "dgidgi tenant token", "password": true }]
}
```

ChatGPT and Claude.ai connect to remote MCP servers over HTTPS with OAuth
sign-in. That needs the hosted `https://api.<spoke-domain>/mcp` endpoint,
which is not built yet (see "Not available yet").

## GitHub Actions

```yaml
- uses: CyberLegionLtd/.github/actions/spoke-run@main
  id: scan
  with:
    spoke: dgidgi
    api-url: https://api.dgidgi.io
    token: ${{ secrets.DGIDGI_API_TOKEN }}
    capability: domain.action
    input: '{"target": "example"}'
    download-base-url: https://<release-channel>
- run: echo '${{ steps.scan.outputs.result }}' | jq .
```

The step installs the CLI, verifies its SHA-256 checksum, submits the run,
waits for it (`wait: false` returns as soon as it is admitted), and fails the
job unless the run completes. Outputs: `run-id`, `status`, `result`.

## Not available yet

| Gap | Needed for |
|---|---|
| A public download channel for the signed CLI binaries (today they are private CI artifacts) | installing the CLI outside the organisation; every CI template takes its URL as `download-base-url` |
| Token exchange for CI (GitHub/GitLab OIDC → short-lived tenant token) | pipelines without a stored token |
| Hosted MCP endpoint with OAuth 2.1 sign-in | ChatGPT, Claude.ai and other remote-only assistants |
| Workforce invocation and a listing of callable workforces | `workforce` tools and commands; no workforce API exists yet |
| Webhooks and a public OpenAPI document | Zapier, Make, n8n, Slack and generated SDKs in other languages |
