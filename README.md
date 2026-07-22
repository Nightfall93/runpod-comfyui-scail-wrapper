# Shared RunPod ComfyUI SCAIL/WAN Wrapper

This wrapper image is based on `runpod/comfyui:cuda12.8`. Despite the legacy
repository name, it is the common Docker runtime for the SCAIL and WAN 2.2
RunPod templates.

It replaces the container ENTRYPOINT so a setup script can run before the original RunPod ComfyUI `/start.sh`.

The SageAttention images bake the pinned union of custom nodes and Python
requirements used by both templates. Runtime setup scripts preserve these
installations and act as fallbacks for older images. Model files remain runtime
downloads and are not included in the image.

See [TEMPLATE_SHARING.md](TEMPLATE_SHARING.md) before changing the shared image,
node pins or base-image digest.

## RunPod environment variables

Set these in your RunPod template:

- `SETUP_SCRIPT_URL` = raw GitHub Gist URL for your setup/download script
- `FILEBROWSER_USERNAME` = admin or your preferred username
- `FILEBROWSER_PASSWORD` = at least 12 characters
- `JUPYTER_PASSWORD` = your Jupyter password/token
- `HF_TOKEN` = optional, only needed for gated/private Hugging Face files
- `SCAIL_DOWNLOAD_JOBS` = optional SCAIL transfer concurrency, defaults to `2`
- `WAN22_DOWNLOAD_JOBS` = optional WAN transfer concurrency, defaults to `2`

## RunPod template

Use the current stable image:

`YOUR_DOCKERHUB_USERNAME/comfyui-scail-wrapper:latest`

SageAttention 2 images are published separately for each GPU generation:

- RTX 30-series: `YOUR_DOCKERHUB_USERNAME/comfyui-scail-wrapper:sage2-ampere`
- RTX 40-series: `YOUR_DOCKERHUB_USERNAME/comfyui-scail-wrapper:sage2-ada`
- RTX 50-series: `YOUR_DOCKERHUB_USERNAME/comfyui-scail-wrapper:sage2-blackwell`

The Dockerfile pins the RunPod CUDA 12.8 base by immutable digest. Git release
tags publish permanent image aliases such as:

- `YOUR_DOCKERHUB_USERNAME/comfyui-scail-wrapper:sage2-ampere-v1.0.0`
- `YOUR_DOCKERHUB_USERNAME/comfyui-scail-wrapper:sage2-ada-v1.0.0`
- `YOUR_DOCKERHUB_USERNAME/comfyui-scail-wrapper:sage2-blackwell-v1.0.0`

Use a versioned tag for a production template that must never change. Use the
short generation tag when you want the latest tested build.

Leave Container start command empty.
