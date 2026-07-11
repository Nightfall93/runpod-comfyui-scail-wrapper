#!/usr/bin/env bash
set -euo pipefail

echo "=== Custom SCAIL/ComfyUI wrapper started ==="

SCRIPT_URL="${SETUP_SCRIPT_URL:-${SCAIL_SETUP_SCRIPT_URL:-}}"

if [ -n "$SCRIPT_URL" ]; then
  echo "Downloading setup script from: $SCRIPT_URL"
  curl -L --fail --retry 5 --retry-delay 5 \
    -o /tmp/scail2video_setup.sh "$SCRIPT_URL"
  chmod +x /tmp/scail2video_setup.sh

  echo "Running Gist setup script..."
  bash /tmp/scail2video_setup.sh
else
  echo "No setup script URL set, skipping Gist setup."
fi

echo "Running SageAttention bootstrap..."
bash /sage_bootstrap.sh

echo "Starting original ComfyUI base startup..."
exec /start.sh
