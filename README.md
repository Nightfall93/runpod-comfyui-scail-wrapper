# RunPod ComfyUI SCAIL Wrapper

This is a tiny wrapper image based on `runpod/comfyui:cuda12.8`.

It replaces the container ENTRYPOINT so a setup script can run before the original RunPod ComfyUI `/start.sh`.

## RunPod environment variables

Set these in your RunPod template:

- `SETUP_SCRIPT_URL` = raw GitHub Gist URL for your setup/download script
- `FILEBROWSER_USERNAME` = admin or your preferred username
- `FILEBROWSER_PASSWORD` = at least 12 characters
- `JUPYTER_PASSWORD` = your Jupyter password/token
- `HF_TOKEN` = optional, only needed for gated/private Hugging Face files

## RunPod template

Use the current stable image:

`YOUR_DOCKERHUB_USERNAME/comfyui-scail-wrapper:latest`

The SageAttention 2 test image is published separately and supports RTX 30-,
40-, and 50-series GPUs:

`YOUR_DOCKERHUB_USERNAME/comfyui-scail-wrapper:sage2`

Leave Container start command empty.
