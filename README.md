# RunPod ComfyUI SCAIL Wrapper

This is a tiny wrapper image based on `runpod/comfyui:cuda12.8`.

It replaces the container ENTRYPOINT so a setup script can run before the original RunPod ComfyUI `/start.sh`.

The SageAttention images also bake the tested Pixaroma custom node at commit
`2b3f90645906b556e0bb466ffd8005ca33a06dd0`.

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
