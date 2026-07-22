# SCAIL and WAN 2.2 template sharing map

The Docker repository retains its original `scail-wrapper` name, but its Sage
image is the common runtime foundation for both RunPod templates.

## Actually shared

Changes to these components affect both SCAIL and WAN 2.2 after a new wrapper
image is built and the templates launch that image:

| Component | Location | Effect |
| --- | --- | --- |
| RunPod ComfyUI CUDA 12.8 base and digest | `Dockerfile` | ComfyUI, PyTorch, CUDA runtime, `/start.sh`, FileBrowser and Jupyter for both templates |
| SageAttention build and GPU-generation tags | `Dockerfile`, `sage_bootstrap.sh`, GitHub Actions | Ampere, Ada and Blackwell acceleration for both templates |
| Wrapper startup handoff | `entrypoint.sh` | Downloads and runs each template's selected setup script, then starts the shared services |
| Baked custom nodes and Python packages | `bake_custom_nodes.sh` | The pinned union is copied into every new container for both templates |
| Docker Hub tags | `sage2-ampere`, `sage2-ada`, `sage2-blackwell` | Both templates currently refer to these mutable generation tags |

Because the generation tags are shared and mutable, publishing a new wrapper
build changes the image used by newly created pods for both templates. An
already-running pod is unchanged. Use a versioned image tag when one template
must remain frozen.

## Similar behavior, but not shared source

The two setup scripts contain independent copies of CUDA preflight, resumable
curl downloads, slow-transfer reconnection, ntfy support and `/start.sh`
FileBrowser credential patching. Editing one copy does **not** update the other.

| SCAIL copy | WAN 2.2 copy |
| --- | --- |
| `scail2video_download_setup.sh` in the setup Gist | `wan22_download_setup.sh` in `runpod-comfyui-wan22` |

They now both default to two simultaneous downloads, but use separate controls:

- SCAIL: `SCAIL_DOWNLOAD_JOBS` (default `2`)
- WAN 2.2: `WAN22_DOWNLOAD_JOBS` (default `2`)

## SCAIL-only

- SCAIL setup Gist and `Scail 2 Video - Compact.json`
- SCAIL model, Wan 2.1 LightX LoRA, CLIP vision, text encoder and VAE URLs
- All required assets block startup; there is no optional background model pair
- `SCAIL_DOWNLOAD_JOBS`
- Pixaroma workflow behavior

## WAN 2.2-only

- `runpod-comfyui-wan22` repository
- WAN 2.2 frame-to-frame workflow and model-pair switch node
- Q8 and FP8 high/low model pairs and WAN 2.2 LightX LoRAs
- Q8/shared foreground stage followed by optional FP8 background downloads
- `WAN22_DOWNLOAD_JOBS`, `WAN22_FP8_BACKGROUND`, `WAN22_WORKFLOW_URL` and
  `WAN22_SWITCH_NODE_URL`

## Practical change rules

1. Editing the wrapper Dockerfile, Sage bootstrap, entrypoint, baked node list or
   base-image pin potentially affects both templates.
2. Editing a setup script, workflow, model URL or template-specific environment
   variable affects only the template whose `SETUP_SCRIPT_URL` selects it.
3. Baking a newer custom-node commit is a shared compatibility change even when
   only one workflow currently uses that node, because every node is imported by
   ComfyUI at startup.
4. Models remain runtime downloads and are not stored in the Docker image.
5. The small WAN model-pair switch stays in the WAN repository because it is
   template-specific; the external node packs and their Python dependencies are
   baked into the shared image.
