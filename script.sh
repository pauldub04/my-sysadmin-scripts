#!/usr/bin/env bash

INTERVAL=5
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
LOG_FILE="$SCRIPT_DIR/monitor.log"

while true; do
    {
        printf '\n--- %s ---\n' "$(date '+%Y-%m-%d %H:%M:%S')"
        free -h
        df -h
        uptime
    } >> "$LOG_FILE"
    sleep "$INTERVAL"
done

