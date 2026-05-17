# POLICY: Branch Protection

**Status:** Active.  **Effective:** 2026-05-17.  **Scope:** All non-archived repositories in `CyberLegionLtd`.

## What is enforced

Enterprise ruleset **`16500430`** at `https://github.com/enterprises/cyberlegion/settings/policies/code/16500430` targets every default branch of every non-archived repo:

| Rule | Behaviour |
|---|---|
| `deletion` | Default branches cannot be deleted |
| `non_fast_forward` | Force-push to default branches is blocked |
| `required_linear_history` | Default branches keep linear history (no merge commits) |
| `pull_request` | Changes to default branch must arrive via PR with: 1 approving review, stale reviews dismissed on push, last-push approval required, all review threads resolved |
| `pull_request.allowed_merge_methods` | Only `squash` and `rebase` accepted; merge commits disallowed at ruleset level |

**Bypass:** Enterprise owners can bypass the ruleset (`bypass_mode: always`). No other bypass actors are configured.

## What is NOT yet enforced

- **Required signed commits** (cryptographic GPG/SSH). Deferred — current platform commits are unsigned. Will roll out tier-aware starting with `tier-platform` repos once developer signing toolchain is in place.
- **Required status checks**. Each repo has different CI workflows; cannot enforce uniformly. Repos may add per-repo required checks in their own branch protection.
- **Required code-owner reviews**. Will roll out once meaningful CODEOWNERS exist per repo.

## How to verify

```bash
gh api enterprises/cyberlegion/rulesets/16500430 --jq '{name, enforcement, rules: (.rules | map(.type)), target}'
```

Expected output:
```
{
  "name": "Default-branch protection (Strict, enterprise-wide)",
  "enforcement": "active",
  "rules": ["deletion", "non_fast_forward", "required_linear_history", "pull_request"],
  "target": "branch"
}
```

## Change control

Modifications to this ruleset require:
1. PR against this `POLICY-BRANCH-PROTECTION.md` describing the change and reasoning
2. PATCH to ruleset 16500430 via `gh api -X PUT enterprises/cyberlegion/rulesets/16500430`
3. Verification that the new state matches doc

## Related

- [POLICY-ACTIONS.md](POLICY-ACTIONS.md)
- [POLICY-SECRETS.md](POLICY-SECRETS.md)
- [GOVERNANCE.md](GOVERNANCE.md)
