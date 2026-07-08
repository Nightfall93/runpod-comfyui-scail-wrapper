#!/usr/bin/env bash
set -euo pipefail

echo "=== Custom SCAIL/ComfyUI wrapper started ==="

# Use SETUP_SCRIPT_URL as the main variable.
# SCAIL_SETUP_SCRIPT_URL is accepted too, in case you prefer that name.
SCRIPT_URL="${SETUP_SCRIPT_URL:-${SCAIL_SETUP_SCRIPT_URL:-}}"

if [ -n "$SCRIPT_URL" ]; then
  echo "Downloading setup script from: $SCRIPT_URL"
  curl -L --fail --retry 5 --retry-delay 5 -o /tmp/scail2video_setup.sh "$SCRIPT_URL"
  chmod +x /tmp/scail2video_setup.sh
  echo "Running setup script..."
  exec /tmp/scail2video_setup.sh
else
  echo "No SETUP_SCRIPT_URL set. Starting original RunPod ComfyUI startup."
  exec /start.sh
fi
