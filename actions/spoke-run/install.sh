#!/usr/bin/env bash
# Installs one spoke CLI from the release channel and verifies its checksum.
set -euo pipefail

case "$SPOKE" in
  a8i|chyper|cyberlegion|dgidgi|stelargate) ;;
  *) echo "::error::unknown spoke '$SPOKE' (a8i, chyper, cyberlegion, dgidgi, stelargate)"; exit 1 ;;
esac
case "$BASE_URL" in
  https://*) ;;
  *) echo "::error::download-base-url must use https"; exit 1 ;;
esac

case "$RUNNER_OS" in
  Linux) os=linux ;;
  macOS) os=macos ;;
  Windows) os=windows ;;
  *) echo "::error::unsupported runner OS '$RUNNER_OS'"; exit 1 ;;
esac
case "$RUNNER_ARCH" in
  X64) arch=x64 ;;
  ARM64) arch=arm64 ;;
  *) echo "::error::unsupported runner architecture '$RUNNER_ARCH'"; exit 1 ;;
esac
binary="$SPOKE"
[ "$os" = windows ] && binary="$SPOKE.exe"

dir="$RUNNER_TEMP/spoke-cli/$SPOKE"
mkdir -p "$dir"
base="${BASE_URL%/}/$VERSION/$os-$arch"
curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 -o "$dir/$binary" "$base/$binary"
curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 -o "$dir/SHA256SUMS" "$base/SHA256SUMS"

expected="$(awk -v name="$binary" '$2 == name { print $1 }' "$dir/SHA256SUMS")"
if [ -z "$expected" ]; then
  echo "::error::$binary is not listed in SHA256SUMS"
  exit 1
fi
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$dir/$binary" | awk '{ print $1 }')"
else
  actual="$(shasum -a 256 "$dir/$binary" | awk '{ print $1 }')"
fi
if [ "$actual" != "$expected" ]; then
  echo "::error::checksum mismatch for $binary"
  exit 1
fi

chmod +x "$dir/$binary"
echo "$dir" >> "$GITHUB_PATH"
"$dir/$binary" --version
