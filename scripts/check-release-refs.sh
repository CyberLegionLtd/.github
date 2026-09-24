#!/usr/bin/env bash
# Every reference this repository makes to itself, and every reference its
# docs and templates hand to consumers, must name the same release tag. The
# reusable workflows and the actions they call are published together by
# tagging one commit; a mixed reference would pair a workflow with an action
# from a different release.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
expected="${1:-$(cat "$root/RELEASE_TAG")}"

mapfile -t refs < <(
  grep -rhoE 'CyberLegionLtd/\.github/[A-Za-z0-9._/-]+@[A-Za-z0-9._-]+|CyberLegionLtd/\.github/[A-Za-z0-9._-]+/ci-templates' \
    "$root/.github" "$root/actions" "$root/workflow-templates" "$root/docs" "$root/ci-templates" "$root/README.md" 2>/dev/null
)

bad=0
for ref in "${refs[@]}"; do
  if [[ "$ref" == */ci-templates ]]; then
    tag="$(sed -E 's#^CyberLegionLtd/\.github/([^/]+)/ci-templates$#\1#' <<<"$ref")"
  else
    tag="${ref##*@}"
  fi
  if [ "$tag" != "$expected" ]; then
    echo "::error::$ref does not use release tag $expected"
    bad=1
  fi
done
[ "${#refs[@]}" -gt 0 ] || { echo "::error::no self references found"; exit 1; }
[ "$bad" -eq 0 ] && echo "release refs: ${#refs[@]} references use $expected"
exit "$bad"
