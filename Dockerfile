# Use a specific, stable image to avoid future issues with updates
FROM ls250824/pytorch-cuda-ubuntu-runtime:02062025 AS base

# Set working directory
WORKDIR /

#Copy and set up Civitai downloader with appropriate permissions
COPY civitai_environment.py /usr/local/bin/civitai
RUN chmod +x /usr/local/bin/civitai

# Install code-server in a single command to minimize image layers
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Hugginface using environment variable HF_TOKEN
RUN pip3 install --no-cache-dir --upgrade huggingface_hub

# Clone ComfyUI and setup
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && \
    pip3 install --no-cache-dir -r requirements.txt