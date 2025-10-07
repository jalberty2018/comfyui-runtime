# syntax=docker/dockerfile:1.7
# Base Ubuntu image with pythorch and cuda support.
FROM ls250824/pytorch-cuda-ubuntu-runtime:01102025 AS base

# Set working directory
WORKDIR /

# Copy and set up Civitai downloader with appropriate permissions
COPY civitai_environment.py /usr/local/bin/civitai
RUN chmod +x /usr/local/bin/civitai

# Pin ORT-GPU to 1.22.* so and numpy.
RUN printf "numpy<2\nonnxruntime-gpu==1.22.*\nonnxruntime==0\n" > /constraints.txt

# Download wheels
RUN wget -q https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.1.0/flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl && \
    wget -q https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.1.0/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl

RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir -c /constraints.txt \
      ./flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl \
      ./sageattention-2.2.0-cp311-cp311-linux_x86_64.whl \
      "onnxruntime-gpu==1.22.*" "huggingface_hub[cli]" comfy-cli && \
    rm -f flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl \
          sageattention-2.2.0-cp311-cp311-linux_x86_64.whl

# Install ComfyUI
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=cache,target=/root/.cache/git \
    git clone --depth=1 --filter=blob:none https://github.com/comfyanonymous/ComfyUI.git /ComfyUI && \
    cd /ComfyUI && \
    python -m pip install --no-cache-dir -r requirements.txt -c /constraints.txt

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Labels
LABEL org.opencontainers.image.title="Base ComfyUI + code-server + downloaders" \
      org.opencontainers.image.description="ComfyUI + flash-attn + sageattention + onnxruntime-gpu + code-server + civitai downloader + huggingface_hub" \
      org.opencontainers.image.source="https://hub.docker.com/r/ls250824/comfyui-venv-runtime" \
      org.opencontainers.image.licenses="MIT"

# Test
RUN python -c "import torch, torchvision, torchaudio, triton; \
print(f'Torch: {torch.__version__}\\nTorchvision: {torchvision.__version__}\\nTorchaudio: {torchaudio.__version__}\\nTriton: {triton.__version__}\\nCUDA available: {torch.cuda.is_available()}\\nCUDA version: {torch.version.cuda}')"