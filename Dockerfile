ARG SAGE_CUDA_ARCH_LIST=8.6
FROM nvidia/cuda:12.8.1-devel-ubuntu24.04 AS cuda-devel

FROM runpod/comfyui:cuda12.8@sha256:498e3c4ac7ef5071214badb1681d82ab3a8f922b1055742ae692fa02cd3b59ff AS sage-builder

ARG SAGE_CUDA_ARCH_LIST
ARG SAGEATTENTION_COMMIT=d1a57a546c3d395b1ffcbeecc66d81db76f3b4b5

ENV CUDA_HOME=/usr/local/cuda \
    TORCH_CUDA_ARCH_LIST=${SAGE_CUDA_ARCH_LIST} \
    MAX_JOBS=1

# The RunPod runtime image includes nvcc but not the CUDA development headers.
# SageAttention's PyTorch extensions include cusparse.h while compiling.
COPY --from=cuda-devel /usr/local/cuda/include/ /usr/local/cuda/include/

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential git ninja-build \
    && rm -rf /var/lib/apt/lists/* \
    && command -v nvcc \
    && nvcc --version

RUN git clone https://github.com/thu-ml/SageAttention.git /tmp/SageAttention \
    && git -C /tmp/SageAttention checkout "$SAGEATTENTION_COMMIT" \
    && python3 -m pip wheel --no-deps --no-build-isolation \
      --wheel-dir /tmp/sage-wheels /tmp/SageAttention

FROM runpod/comfyui:cuda12.8@sha256:498e3c4ac7ef5071214badb1681d82ab3a8f922b1055742ae692fa02cd3b59ff

ARG SAGE_CUDA_ARCH_LIST
ARG PIXAROMA_COMMIT=2b3f90645906b556e0bb466ffd8005ca33a06dd0

ENV SAGE_SUPPORTED_CC=${SAGE_CUDA_ARCH_LIST}

COPY --from=sage-builder /tmp/sage-wheels /tmp/sage-wheels

RUN python3 -m pip install --no-deps /tmp/sage-wheels/sageattention-*.whl \
    && rm -rf /tmp/sage-wheels

RUN git init /opt/comfyui-baked/custom_nodes/ComfyUI-Pixaroma \
    && git -C /opt/comfyui-baked/custom_nodes/ComfyUI-Pixaroma remote add origin \
      https://github.com/pixaroma/ComfyUI-Pixaroma.git \
    && git -C /opt/comfyui-baked/custom_nodes/ComfyUI-Pixaroma fetch \
      --depth 1 origin "$PIXAROMA_COMMIT" \
    && git -C /opt/comfyui-baked/custom_nodes/ComfyUI-Pixaroma \
      checkout --detach FETCH_HEAD \
    && rm -rf /opt/comfyui-baked/custom_nodes/ComfyUI-Pixaroma/.git

COPY entrypoint.sh /entrypoint.sh
COPY sage_bootstrap.sh /sage_bootstrap.sh

RUN chmod +x /entrypoint.sh /sage_bootstrap.sh

ENTRYPOINT ["/entrypoint.sh"]
