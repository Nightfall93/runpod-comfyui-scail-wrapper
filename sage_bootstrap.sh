#!/usr/bin/env bash
set -euo pipefail

echo "=== SageAttention bootstrap starting ==="

COMFY="/workspace/runpod-slim/ComfyUI"
PYTHON_BIN="$COMFY/.venv-cu128/bin/python"
ARGS_FILE="/workspace/runpod-slim/comfyui_args.txt"

disable_sage_attention() {
  mkdir -p "$(dirname "$ARGS_FILE")"
  [ -f "$ARGS_FILE" ] || return 0
  sed -i -E \
    's/(^|[[:space:]])--use-sage-attention([[:space:]]|$)/ /g' \
    "$ARGS_FILE"
}

enable_sage_attention() {
  mkdir -p "$(dirname "$ARGS_FILE")"
  touch "$ARGS_FILE"
  sed -i 's/--use-flash-attention//g' "$ARGS_FILE"
  if ! grep -q -- "--use-sage-attention" "$ARGS_FILE"; then
    echo " --use-sage-attention" >> "$ARGS_FILE"
  fi
  if ! grep -q -- "--preview-method none" "$ARGS_FILE"; then
    echo " --preview-method none" >> "$ARGS_FILE"
  fi
}

if [ "${ENABLE_SAGE_ATTENTION:-1}" != "1" ]; then
  echo "ENABLE_SAGE_ATTENTION is disabled, skipping SageAttention."
  disable_sage_attention
  exit 0
fi

if [ ! -x "$PYTHON_BIN" ]; then
  echo "ComfyUI venv not found; skipping SageAttention."
  disable_sage_attention
  exit 0
fi

if ! GPU_CC=$("$PYTHON_BIN" - <<'PY' 2>/dev/null
import torch
if not torch.cuda.is_available():
    raise RuntimeError("CUDA is unavailable")
major, minor = torch.cuda.get_device_capability(0)
print(f"{major}.{minor}")
PY
); then
  echo "No usable CUDA GPU detected; skipping SageAttention."
  disable_sage_attention
  exit 0
fi

echo "Detected GPU compute capability: $GPU_CC"

case "$GPU_CC" in
  8.6|8.9|12.0) ;;
  *)
    echo "GPU compute capability $GPU_CC is unsupported; skipping SageAttention."
    disable_sage_attention
    exit 0
    ;;
esac

if "$PYTHON_BIN" -c "import sageattention" >/dev/null 2>&1; then
  enable_sage_attention
  echo "Baked SageAttention is available and enabled for ComfyUI."
else
  echo "Baked SageAttention cannot be imported; continuing without it."
  disable_sage_attention
fi

echo "=== SageAttention bootstrap finished ==="
