# syntax=docker/dockerfile:1.7
FROM ls250824/pytorch-cuda-ubuntu-runtime:15112025

# Set working directory
WORKDIR /

# Copy and set up Civitai downloader with appropriate permissions
COPY civitai_environment.py /usr/local/bin/civitai
RUN chmod +x /usr/local/bin/civitai

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Clone ComfyUI
RUN --mount=type=cache,target=/root/.cache/git \
    git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git /ComfyUI

# Pin ORT-GPU to 1.22.* so , numpy and attentions.
RUN printf "numpy<2\nonnxruntime-gpu==1.22.*\nonnxruntime==0\nflash_attn==2.8.3\nsageattention==2.2.0\n" > /constraints.txt

# Download wheels
RUN wget -q https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.3.1/flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl && \
    wget -q https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.3.1/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl && \
	wget -q https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.3.1/torch_generic_nms-0.1-cp311-cp311-linux_x86_64.whl

# Install and remove wheels
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir --root-user-action ignore -c /constraints.txt \
      ./flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl \
      ./sageattention-2.2.0-cp311-cp311-linux_x86_64.whl \
	  ./torch_generic_nms-0.1-cp311-cp311-linux_x86_64.whl \
      "onnxruntime-gpu==1.22.*" "huggingface_hub[cli]" comfy-cli onnx && \
    rm -f flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl \
          sageattention-2.2.0-cp311-cp311-linux_x86_64.whl \
		  torch_generic_nms-0.1-cp311-cp311-linux_x86_64.whl

# Install ComfyUI requirements
WORKDIR /ComfyUI

RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir --root-user-action ignore -r requirements.txt -c /constraints.txt

# Set working directory
WORKDIR /

# Labels
LABEL org.opencontainers.image.title="Base image ComfyUI 0.3.71 + code-server + downloaders" \
      org.opencontainers.image.description="ComfyUI 0.3.71 + flash-attn + sageattention + onnxruntime-gpu + torch_generic_nms + code-server + civitai downloader + huggingface_hub" \
      org.opencontainers.image.source="https://hub.docker.com/r/ls250824/comfyui-runtime" \
      org.opencontainers.image.licenses="MIT"

# Check
RUN python -c "import torch, torchvision, torchaudio, triton, importlib, importlib.util as iu; \
print(f'Torch: {torch.__version__}'); \
print(f'Torchvision: {torchvision.__version__}'); \
print(f'Torchaudio: {torchaudio.__version__}'); \
print(f'Triton: {triton.__version__}'); \
name = 'onnxruntime_gpu' if iu.find_spec('onnxruntime_gpu') else ('onnxruntime' if iu.find_spec('onnxruntime') else None); \
ver = (importlib.import_module(name).__version__ if name else 'not installed'); \
label = 'ONNXRuntime-GPU' if name=='onnxruntime_gpu' else 'ONNXRuntime'; \
print(f'{label}: {ver}'); \
print('CUDA available:', torch.cuda.is_available()); \
print('CUDA version:', torch.version.cuda); \
print('Device:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU')"