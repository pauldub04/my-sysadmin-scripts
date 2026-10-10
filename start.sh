#!/usr/bin/env bash

script.sh --once || exit 1

script.sh &
monitor_pid=$!

python3 -u -m http.server 8080 --bind 0.0.0.0 --directory /data &
http_pid=$!

cleanup() {
    kill "$monitor_pid" "$http_pid" 2>/dev/null || true
    wait "$monitor_pid" "$http_pid" 2>/dev/null || true
}

trap 'cleanup; exit 0' TERM INT

wait -n "$monitor_pid" "$http_pid"
echo "Monitoring or HTTP server stopped unexpectedly" >&2
cleanup
exit 1

