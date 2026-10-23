#!/bin/bash
# Local-only service qualification. Requires a newly installed, unconfigured Bridge.
set -euo pipefail
prefix=$(brew --prefix)
config="$prefix/etc/hybrid-bridge/controller.env"
state="$prefix/var/lib/hybrid-bridge"
if [[ -e "$config" ]] || [[ -n "$(find "$state" -type f -print -quit)" ]]; then
  echo 'Refusing to test an existing configuration or state directory.' >&2
  exit 1
fi
if lsof -nP -iTCP:29103 -sTCP:LISTEN >/dev/null 2>&1; then
  echo 'Test port 29103 is already occupied.' >&2
  exit 1
fi
# Missing configuration must exit successfully, without starting a fallback daemon.
"$prefix/opt/hybrid-bridge/libexec/start-service" 2>&1 | grep -q 'not configured'
cleanup() {
  brew services stop tripleclabs/tap/hybrid-bridge >/dev/null 2>&1 || true
  rm -f "$config" "$state/test-retention" "$state/edge-app-state.sqlite3" \
    "$state/edge-app-state.sqlite3-wal" "$state/edge-app-state.sqlite3-shm"
}
trap cleanup EXIT
umask 077
cat > "$config" <<'EOF'
HOST=127.0.0.1
PORT=29103
PLATFORM_URL=grpc://127.0.0.1:18443
DISABLE_SENTRY=true
EOF
printf 'keep this data\n' > "$state/test-retention"
before=$(shasum -a 256 "$config" "$state/test-retention")
health() {
  for attempt in {1..30}; do
    if curl --noproxy '*' -sS http://127.0.0.1:29103/health 2>/dev/null | grep -q 'disconnected'; then
      return 0
    fi
    sleep 1
  done
  cat "$prefix/var/log/hybrid-bridge/error.log" >&2
  return 1
}
brew services start tripleclabs/tap/hybrid-bridge
health
brew services restart tripleclabs/tap/hybrid-bridge
health
brew services stop tripleclabs/tap/hybrid-bridge
brew uninstall tripleclabs/tap/hybrid-bridge
[[ "$(shasum -a 256 "$config" "$state/test-retention")" == "$before" ]]
brew install tripleclabs/tap/hybrid-bridge
[[ "$(shasum -a 256 "$config" "$state/test-retention")" == "$before" ]]
brew services start tripleclabs/tap/hybrid-bridge
health
echo 'Missing-config guard, launchd health, restart, uninstall/reinstall and retained data passed.'
