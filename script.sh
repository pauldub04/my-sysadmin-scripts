#!/usr/bin/env bash

INTERVAL=5

if (( $# > 1 )) || [[ -n ${1-} && ${1-} != --once ]]; then
    echo "Usage: $0 [--once]" >&2
    exit 2
fi

LOG_FILE="${LOG_FILE:-$(dirname -- "$0")/monitor.log}" || exit 1
trap 'echo "Stopped" >&2; exit 0' INT TERM

snapshot() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S') || return 1
    printf '\n--- %s ---\n' "$timestamp" || return 1
    free -h || return 1
    df -h || return 1
    uptime
}

while true; do
    if ! snapshot >> "$LOG_FILE"; then
        echo "Could not write a snapshot to $LOG_FILE" >&2
        exit 1
    fi

    [[ ${1-} == --once ]] && break
    sleep "$INTERVAL" || exit 1
done

