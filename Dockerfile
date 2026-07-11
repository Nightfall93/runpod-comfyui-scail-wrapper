FROM runpod/comfyui:cuda12.8

COPY entrypoint.sh /entrypoint.sh
COPY sage_bootstrap.sh /sage_bootstrap.sh

RUN chmod +x /entrypoint.sh /sage_bootstrap.sh

ENTRYPOINT ["/entrypoint.sh"]
