#!/usr/bin/env bash
# Submits one governed capability run and, optionally, waits for it to finish.
set -euo pipefail

prefix="$(printf '%s' "$SPOKE" | tr '[:lower:]-' '[:upper:]_')"
export "${prefix}_API_URL=$API_URL"
export "${prefix}_API_TOKEN=$API_TOKEN"
export "${prefix}_API_TIMEOUT_MS=30000"
echo "::add-mask::$API_TOKEN"

if [ -n "$INPUT_FILE" ]; then
  submitted="$("$SPOKE" run "$CAPABILITY" --input-file "$INPUT_FILE")"
else
  submitted="$("$SPOKE" run "$CAPABILITY" --input-json "$INPUT_JSON")"
fi

run_id="$(printf '%s' "$submitted" | jq -r '.result.runId // .runId // .data.runId // empty')"
if [ -z "$run_id" ]; then
  echo "::error::the API did not return a run id"
  printf '%s\n' "$submitted"
  exit 1
fi
echo "run-id=$run_id" >> "$GITHUB_OUTPUT"
echo "Admitted run $run_id"

emit_result() {
  local document="$1"
  local delimiter="EOF_$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')"
  {
    echo "result<<$delimiter"
    printf '%s\n' "$document"
    echo "$delimiter"
  } >> "$GITHUB_OUTPUT"
}

if [ "$WAIT" != "true" ]; then
  echo "status=queued" >> "$GITHUB_OUTPUT"
  emit_result "$submitted"
  exit 0
fi

deadline=$(( $(date +%s) + TIMEOUT_SECONDS ))
status=""
while :; do
  status="$("$SPOKE" run-status "$run_id" | jq -r '.status // .data.status // empty')"
  case "$status" in
    completed|failed|cancelled|blocked|paused) break ;;
  esac
  if [ "$(date +%s)" -ge "$deadline" ]; then
    echo "::error::run $run_id did not finish within ${TIMEOUT_SECONDS}s (last status: ${status:-unknown}); it may still be running"
    echo "status=${status:-unknown}" >> "$GITHUB_OUTPUT"
    exit 1
  fi
  sleep "$POLL_SECONDS"
done

document="$("$SPOKE" run-get "$run_id")"
echo "status=$status" >> "$GITHUB_OUTPUT"
emit_result "$document"
{
  echo "### $SPOKE run \`$run_id\`"
  echo
  echo "Capability \`$CAPABILITY\` finished with status **$status**."
} >> "$GITHUB_STEP_SUMMARY"

if [ "$status" != "completed" ]; then
  echo "::error::run $run_id ended with status '$status'"
  exit 1
fi
