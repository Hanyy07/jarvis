#!/usr/bin/env bash
# Per-boot startup for the Jarvis AI Assistant.
# Brings up a virtual X display so pyautogui can import and the eel web
# app can run in this headless environment. Idempotent.
set -euo pipefail

DISPLAY_NUM=99
export DISPLAY=":${DISPLAY_NUM}"

if xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
    echo "Virtual display $DISPLAY already running"
    exit 0
fi

# Clean up any stale lock from a previous boot before starting Xvfb.
rm -f "/tmp/.X${DISPLAY_NUM}-lock"
Xvfb "$DISPLAY" -screen 0 1280x800x24 >/tmp/xvfb.log 2>&1 &

for _ in $(seq 1 20); do
    if xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
        echo "Virtual display $DISPLAY is ready"
        exit 0
    fi
    sleep 0.5
done

echo "ERROR: Xvfb failed to start on $DISPLAY" >&2
cat /tmp/xvfb.log >&2 || true
exit 1
