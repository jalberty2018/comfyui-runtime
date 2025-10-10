[![Docker Image Version](https://img.shields.io/docker/v/ls250824/comfyui-runtime)](https://hub.docker.com/r/ls250824/comfyui-runtime)

# comfyui-runtime

Base Docker base image for ComfyUI, Code-Server and downloaders.

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- [comfy-cli](https://github.com/Comfy-Org/comfy-cli)
- [Code server](https://github.com/coder/code-server)
- [HuggingFace cli](https://huggingface.co/docs/huggingface_hub/guides/cli)
- [Flash attention](https://github.com/Dao-AILab/flash-attention)
- [Sage attention](https://github.com/thu-ml/SageAttention)
- [Onnxruntime-gpu](https://pypi.org/project/onnxruntime-gpu/)
- [Triton](https://triton-lang.org/main/index.html)

## Setup

| Component | Version              |
|-----------|----------------------|
| OS        | `Ubuntu 24.04 x86_64`|
| Python    | `3.11.x`             |
| PyTorch   | `2.8.0`              |
| CUDA      | `12.9.x`             |
| Triton    | `3.4.x`              |
| onnxruntime-gpu | `1.22.x` |
| ComfyUI | Latest |
| CodeServer | Latest |

## Installed Attentions

| Package        | Version  |
|----------------|----------|
| flash_attn     | 2.8.3    |
| sageattention  | 2.2.0    |

## Building constrains (/constraints.txt)

```txt
numpy<2
onnxruntime-gpu==1.22.*
onnxruntime==0
```

## Available Images

### Base Images 

#### ls250824/pytorch-cuda-ubuntu-runtime
	
[![Docker Image Version](https://img.shields.io/docker/v/ls250824/pytorch-cuda-ubuntu-runtime)](https://hub.docker.com/r/ls250824/pytorch-cuda-ubuntu-runtime)

### Custom Build: 

```bash
docker pull ls250824/comfyui-runtime:<version>
```

## Building the Docker Image

You can build and push the image to Docker Hub using the `build-docker.py` script.

### `build-docker.py` Script Options

| Option         | Description                                         | Default                |
|----------------|-----------------------------------------------------|------------------------|
| `--username`   | Docker Hub username                                 | Current user           |
| `--tag`        | Tag to use for the image                            | Today's date           |
| `--latest`     | If specified, also tags and pushes as `latest`      | Not enabled by default |

### Build & Push Command

Run the following command to clone the repository and build the image:

```bash
git clone https://github.com/jalberty2018/comfyui-runtime.git
cp comfyui-runtime/build-docker.py ..

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

python3 build-docker.py \
--username=<your_dockerhub_username> \
--tag=<custom_tag> \ 
comfyui-runtime
```

Note: If you want to push the image with the latest tag, add the --latest flag at the end.

