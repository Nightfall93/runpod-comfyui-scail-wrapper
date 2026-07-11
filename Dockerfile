FROM runpod/comfyui:cuda12.8 AS sage-builder

ARG SAGEATTENTION_COMMIT=d1a57a546c3d395b1ffcbeecc66d81db76f3b4b5

ENV CUDA_HOME=/usr/local/cuda \
    TORCH_CUDA_ARCH_LIST="8.6;8.9;12.0" \
    MAX_JOBS=4

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential git ninja-build \
    && rm -rf /var/lib/apt/lists/* \
    && command -v nvcc \
    && nvcc --version

RUN git clone https://github.com/thu-ml/SageAttention.git /tmp/SageAttention \
    && git -C /tmp/SageAttention checkout "$SAGEATTENTION_COMMIT" \
    && python3 -m pip wheel --no-deps --no-build-isolation \
      --wheel-dir /tmp/sage-wheels /tmp/SageAttention

FROM runpod/comfyui:cuda12.8

COPY --from=sage-builder /tmp/sage-wheels /tmp/sage-wheels

RUN python3 -m pip install --no-deps /tmp/sage-wheels/sageattention-*.whl \
    && rm -rf /tmp/sage-wheels

COPY entrypoint.sh /entrypoint.sh
COPY sage_bootstrap.sh /sage_bootstrap.sh

RUN chmod +x /entrypoint.sh /sage_bootstrap.sh

ENTRYPOINT ["/entrypoint.sh"]
