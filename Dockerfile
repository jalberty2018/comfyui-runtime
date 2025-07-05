# Use a specific, stable image to avoid future issues with updates
FROM ls250824/pytorch-cuda-ubuntu-runtime:05072025 AS base

# Set working directory
WORKDIR /

# Clone ComfyUI and setup
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && \
    pip3 install --no-cache-dir -r requirements.txt

#Copy and set up Civitai downloader with appropriate permissions
COPY civitai_environment.py /usr/local/bin/civitai
RUN chmod +x /usr/local/bin/civitai

# Install code-server in a single command to minimize image layers
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Hugginface-cli comfy-cli
RUN pip3 install --no-cache-dir --upgrade huggingface_hub comfy-cli triton

# Download and install the wheel for flash_attn
RUN wget https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.0.0/flash_attn-2.7.2-cp311-cp311-linux_x86_64.whl
RUN pip3 install --no-cache-dir flash_attn-2.7.2-cp311-cp311-linux_x86_64.whl

# Download and install the wheel for sageattention
RUN wget https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/download/v1.0.0/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl
RUN pip3 install --no-cache-dir sageattention-2.2.0-cp311-cp311-linux_x86_64.whl
