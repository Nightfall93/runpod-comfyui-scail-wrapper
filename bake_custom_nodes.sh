#!/usr/bin/env bash
set -euo pipefail

COMFY_BAKED="/opt/comfyui-baked"
CUSTOM_NODES="$COMFY_BAKED/custom_nodes"
CONSTRAINTS="/opt/comfyui-runtime-constraints.txt"

mkdir -p "$CUSTOM_NODES"

install_pinned_node() {
  local repo="$1"
  local name="$2"
  local commit="$3"
  local target="$CUSTOM_NODES/$name"
  local staging="/tmp/${name}.bake"

  echo "Baking custom node: $repo @ $commit"
  rm -rf "$staging"
  git init "$staging"
  git -C "$staging" remote add origin "$repo"
  git -C "$staging" fetch --depth 1 origin "$commit"
  git -C "$staging" checkout --detach FETCH_HEAD

  if [ -f "$staging/requirements.txt" ]; then
    echo "Baking Python requirements for: $name"
    if [ -f "$CONSTRAINTS" ]; then
      python3 -m pip install --no-cache-dir -c "$CONSTRAINTS" \
        -r "$staging/requirements.txt"
    else
      python3 -m pip install --no-cache-dir -r "$staging/requirements.txt"
    fi
  fi

  rm -rf "$staging/.git" "$target"
  mv "$staging" "$target"
}

# This is the pinned union needed by the SCAIL and WAN 2.2 templates. Runtime
# setup scripts retain fallback installers so older wrapper images still work.
install_pinned_node "https://github.com/pixaroma/ComfyUI-Pixaroma.git" \
  "ComfyUI-Pixaroma" "2b3f90645906b556e0bb466ffd8005ca33a06dd0"
install_pinned_node "https://github.com/city96/ComfyUI-GGUF.git" \
  "ComfyUI-GGUF" "6ea2651e7df66d7585f6ffee804b20e92fb38b8a"
install_pinned_node "https://github.com/yolain/ComfyUI-Easy-Use.git" \
  "ComfyUI-Easy-Use" "54d080bf6a4f52da287e984f305243c10db097f5"
install_pinned_node "https://github.com/rgthree/rgthree-comfy.git" \
  "rgthree-comfy" "27b4f4cdcf3b127c29d5d8135ac1536ecbd4c383"
install_pinned_node "https://github.com/vrgamegirl19/comfyui-vrgamedevgirl.git" \
  "comfyui-vrgamedevgirl" "930874103d9ab6b9bf98bc108b0483b4fb2ada4e"
install_pinned_node "https://github.com/cubiq/ComfyUI_essentials.git" \
  "ComfyUI_essentials" "9d9f4bedfc9f0321c19faf71855e228c93bd0dc9"
install_pinned_node "https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git" \
  "ComfyUI-Frame-Interpolation" "26545cc2dd95bc3d27f056016300673bdeee78f5"
install_pinned_node "https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git" \
  "ComfyUI_UltimateSDUpscale" "a5547db9e1d07d3318bb21e9e9c474f4c1e9c8df"
install_pinned_node "https://github.com/wallish77/wlsh_nodes.git" \
  "wlsh_nodes" "97807467bf7ff4ea01d529fcd6e666758f34e3c1"
install_pinned_node "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git" \
  "ComfyUI-VideoHelperSuite" "4ee72c065db22c9d96c2427954dc69e7b908444b"
install_pinned_node "https://github.com/kijai/ComfyUI-KJNodes.git" \
  "ComfyUI-KJNodes" "e27a505b3ba6ce42687fe00500deda103d9d6071"
install_pinned_node "https://github.com/ClownsharkBatwing/RES4LYF.git" \
  "RES4LYF" "419de2d7c78f415dde9aa352a7231820ebfc17a4"

echo "Pinned SCAIL/WAN custom-node union baked successfully."
