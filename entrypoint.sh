#!/bin/bash
set -e

echo "=== Custom SCAIL/ComfyUI wrapper started ==="

if [ -n "$SETUP_SCRIPT_URL" ]; then
  echo "Downloading setup script from: $SETUP_SCRIPT_URL"
  curl -L --fail -o /tmp/scail2video_setup.sh "$SETUP_SCRIPT_URL"
  chmod +x /tmp/scail2video_setup.sh

  echo "Running setup script..."
  bash /tmp/scail2video_setup.sh
else
  echo "No SETUP_SCRIPT_URL set, skipping external setup script."
fi

echo "Running SageAttention bootstrap..."
bash /sage_bootstrap.sh

echo "Starting original ComfyUI base startup..."
exec /start.sh
