# comfyui-runtime

## Information

- Docker base image for ComfyUI inference with GPU (CUDA) acceleration.
- This image does not start any service use ls250824/run-x
- Based on ls250824/pytorch-cuda-ubuntu-runtime<[![Docker Image Version](https://img.shields.io/docker/v/ls250824/pytorch-cuda-ubuntu-runtime)](https://hub.docker.com/r/ls250824/pytorch-cuda-ubuntu-runtime)>.

## Websites	

- [ComfyUI](https://github.com/Comfy-Org/ComfyUI)
- [comfy-cli](https://github.com/Comfy-Org/comfy-cli)
- [Code server](https://github.com/coder/code-server)
- [HuggingFace cli](https://huggingface.co/docs/huggingface_hub/guides/cli)
- [Flash attention](https://github.com/Dao-AILab/flash-attention)
- [Sage attention](https://github.com/thu-ml/SageAttention)
- [Onnxruntime-gpu](https://pypi.org/project/onnxruntime-gpu/)
- [Triton](https://triton-lang.org/main/index.html)
- [torch_generic_nms](https://github.com/ronghanghu/torch_generic_nms)
- [llama-cpp](https://github.com/ggml-org/llama.cpp)

## Images on Docker 

- If the image is **less then one day old** it is possible that it is not tested or will be updated.

## Setup image latest image

### Image

| Component | Version              |
|-----------|----------------------|
| OS        | `Ubuntu 22.04 x86_64` |
| Python    | `3.11.x`             |
| PyTorch   | `2.9.1`              |
| CUDA      | `12.8`             |
| Triton    | `3.5.1`               |
| onnxruntime-gpu | `1.22.x` |
| ComfyUI | `0.9.2`  | 
| CodeServer |  `Latest` |

### Wheels

| Package        | Version  |
|----------------|----------|
| flash_attn     | `2.8.3`    |
| sageattention  |  `2.2.0`   |
| torch_generic_nms | `0.1` |
| llmama-cpp | `0.3.16` |

### Optimised

| Family | Compute Capability | Processor example | SM |
|------------|---------|--------|-----------|
| Ampere  | 8.6 |  A40   | sm_86 |
| Ada Lovelace | 8.9 | L40S  | sm_89 |

## Building constrains (/constraints.txt)

```txt
numpy<2
onnxruntime-gpu==1.22.*
onnxruntime==0
llmama-cpp==0.3.16
```

## Adding comfyui-manager internal version instead of legacy

```bash
WORKDIR /ComfyUI
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install --no-cache-dir --root-user-action ignore -c /constraints.txt \
    matrix-nio \
    -r manager_requirements.txt
```

## Docker speed up

```bash
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
```
