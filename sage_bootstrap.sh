#!/bin/bash
set -e

echo "=== SageAttention bootstrap starting ==="

if [ "${ENABLE_SAGE_ATTENTION:-1}" != "1" ]; then
  echo "ENABLE_SAGE_ATTENTION is disabled, skipping SageAttention."
  exit 0
fi

COMFY="/workspace/runpod-slim/ComfyUI"
PYTHON_BIN="$COMFY/.venv-cu128/bin/python"
ARGS_FILE="/workspace/runpod-slim/comfyui_args.txt"

if [ ! -x "$PYTHON_BIN" ]; then
  echo "ComfyUI venv not found yet at $PYTHON_BIN"
  exit 1
fi

GPU_CC=$("$PYTHON_BIN" - <<'PY'
import torch
major, minor = torch.cuda.get_device_capability(0)
print(f"{major}.{minor}")
PY
)

GPU_MAJOR="${GPU_CC%%.*}"

echo "Detected GPU compute capability: $GPU_CC"

if [ "$GPU_MAJOR" -lt 8 ]; then
  echo "GPU is below Ampere (compute capability < 8.0). Skipping SageAttention."
  exit 0
fi

echo "Installing SageAttention dependencies..."
"$PYTHON_BIN" -m pip install -U packaging psutil ninja triton

if "$PYTHON_BIN" -c "import sageattention" >/dev/null 2>&1; then
  echo "SageAttention already installed."
else
  echo "Installing SageAttention..."
  "$PYTHON_BIN" -m pip install sageattention==2.2.0 --no-build-isolation
fi

mkdir -p /workspace/runpod-slim

if [ -f "$ARGS_FILE" ]; then
  sed -i 's/--use-flash-attention//g' "$ARGS_FILE" || true
  if ! grep -q -- "--use-sage-attention" "$ARGS_FILE"; then
    echo " --use-sage-attention" >> "$ARGS_FILE"
  fi
  if ! grep -q -- "--preview-method none" "$ARGS_FILE"; then
    echo " --preview-method none" >> "$ARGS_FILE"
  fi
else
  echo "--use-sage-attention --preview-method none" > "$ARGS_FILE"
fi

echo "=== SageAttention bootstrap finished ==="
