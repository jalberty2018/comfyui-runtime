# Base Ubuntu image with pythorch and cuda support.
FROM ls250824/pytorch-cuda-ubuntu-runtime:22082025 AS base

# Set working directory
WORKDIR /

# Copy and set up Civitai downloader with appropriate permissions
COPY civitai_environment.py /usr/local/bin/civitai
RUN chmod +x /usr/local/bin/civitai

# Copy and set up Civitai downloader with appropriate permissions
COPY civitai_environment.py /usr/local/bin/civitai
RUN chmod +x /usr/local/bin/civitai

# Download, install and remove the wheels for flash_attn & sageattention
RUN wget https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.1.0/flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl && \
    wget https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.1.0/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl && \
	pip3 install --no-cache-dir -U "huggingface_hub[cli]" comfy-cli \
    flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl \
    sageattention-2.2.0-cp311-cp311-linux_x86_64.whl \
    onnxruntime-gpu --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/  && \
    rm -f flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl sageattention-2.2.0-cp311-cp311-linux_x86_64.whl

# Install onnx-gpu 	
RUN pip3 install --no-cache-dir onnx onnxruntime-gpu>=1.20

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Clone ComfyUI and Setup
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && \
    pip3 install --no-cache-dir -r requirements.txt