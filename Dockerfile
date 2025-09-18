# Use a specific, stable image to avoid future issues with updates
FROM ls250824/pytorch-cuda-ubuntu-runtime:22082025 AS base

# Set working directory
WORKDIR /

# Copy and set up Civitai downloader with appropriate permissions
COPY civitai_environment.py /usr/local/bin/civitai
RUN chmod +x /usr/local/bin/civitai

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Copy and set up Civitai downloader with appropriate permissions
COPY civitai_environment.py /usr/local/bin/civitai
RUN chmod +x /usr/local/bin/civitai

# Clone ComfyUI and setup
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && \
    pip3 install --no-cache-dir -r requirements.txt

# Download the wheel for flash_attn
RUN wget https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.1.0/flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl

# Download and the wheel for sageattention
RUN wget https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.1.0/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl 

# Install wheels
RUN pip3 install --no-cache-dir -U "huggingface_hub[cli]" comfy-cli \
    flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl \
    sageattention-2.2.0-cp311-cp311-linux_x86_64.whl \
    onnxruntime-gpu --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/  && \
    rm -f flash_attn-2.8.3-cp311-cp311-linux_x86_64.whl sageattention-2.2.0-cp311-cp311-linux_x86_64.whl