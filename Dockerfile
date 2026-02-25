# syntax=docker/dockerfile:1.7
FROM ls250824/pytorch-cuda-ubuntu-runtime:17122025

# Set working directory
WORKDIR /

# Pin
COPY constraints.txt /constraints.txt

# Download wheels
RUN wget -q https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.3.1/flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl && \
    wget -q https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.3.1/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl && \
	wget -q https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.3.1/torch_generic_nms-0.1-cp311-cp311-linux_x86_64.whl && \
	wget -q https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.3.1/llama_cpp_python-0.3.16-cp311-cp311-linux_x86_64.whl

# Install and remove wheels
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir --root-user-action ignore -c /constraints.txt \
      ./flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl \
      ./sageattention-2.2.0-cp311-cp311-linux_x86_64.whl \
	  ./torch_generic_nms-0.1-cp311-cp311-linux_x86_64.whl \
      "onnxruntime-gpu==1.22.*" onnx "typer==0.21.1" "click==8.*" "huggingface_hub" && \
    rm -f flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl \
          sageattention-2.2.0-cp311-cp311-linux_x86_64.whl \
		  torch_generic_nms-0.1-cp311-cp311-linux_x86_64.whl

RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir --root-user-action ignore -c /constraints.txt \
      ./llama_cpp_python-0.3.16-cp311-cp311-linux_x86_64.whl && \
    rm -f llama_cpp_python-0.3.16-cp311-cp311-linux_x86_64.whl && \
    echo "/opt/conda/lib/python3.11/site-packages/nvidia/cuda_runtime/lib" > /etc/ld.so.conf.d/cuda-runtime.conf  && \
    echo "/opt/conda/lib/python3.11/site-packages/nvidia/cublas/lib" > /etc/ld.so.conf.d/cublas.conf && \
    ldconfig

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Clone ComfyUI
RUN --mount=type=cache,target=/root/.cache/git \
    git clone --depth=1 https://github.com/Comfy-Org/ComfyUI.git /ComfyUI

# ComfyUI
WORKDIR /ComfyUI

# Checkout ComfyUI release version 0.15.0
RUN git fetch --unshallow && git checkout b874bd2b8c324d58cfc37bff0754dd16815a8f3c

# Install ComfyUI requirements
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir --root-user-action ignore -c /constraints.txt \
    -r requirements.txt 

# Set working directory
WORKDIR /

# Copy and set up Civitai downloader with appropriate permissions
COPY civitai_environment.py /usr/local/bin/civitai
RUN chmod +x /usr/local/bin/civitai

# Labels
LABEL org.opencontainers.image.title="Base image ComfyUI 0.15.0 + code-server + downloaders" \
      org.opencontainers.image.description="ComfyUI + flash-attn + sageattention + onnxruntime-gpu + torch_generic_nms + code-server + civitai downloader + huggingface_hub" \
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

# ComfyUI
RUN cat ComfyUI/comfyui_version.py