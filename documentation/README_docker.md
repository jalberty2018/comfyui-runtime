# comfyui-runtime

## Information

- Docker base image for ComfyUI inference.
- This image does not start any service use ls250824/run-x
- Based on ls250824/pytorch-cuda-ubuntu-runtime<[![Docker Image Version](https://img.shields.io/docker/v/ls250824/pytorch-cuda-ubuntu-runtime)](https://hub.docker.com/r/ls250824/pytorch-cuda-ubuntu-runtime)>.

## Websites	

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- [comfy-cli](https://github.com/Comfy-Org/comfy-cli)
- [Code server](https://github.com/coder/code-server)
- [HuggingFace cli](https://huggingface.co/docs/huggingface_hub/guides/cli)
- [Flash attention](https://github.com/Dao-AILab/flash-attention)
- [Sage attention](https://github.com/thu-ml/SageAttention)
- [Onnxruntime-gpu](https://pypi.org/project/onnxruntime-gpu/)
- [Triton](https://triton-lang.org/main/index.html)
- [torch_generic_nms](https://github.com/ronghanghu/torch_generic_nms)

## Images on Docker 

- If the image is **less then one day old** it is possible that it is not tested or will be updated.

## Setup image 25112025

### Image

| Component | Version              |
|-----------|----------------------|
| OS        | `Ubuntu 22.04 x86_64` |
| Python    | `3.11.x`             |
| PyTorch   | `2.9.1`              |
| CUDA      | `12.8`             |
| Triton    | `3.5.1`               |
| onnxruntime-gpu | `1.22.x` |
| ComfyUI | `0.3.76`  | 
| CodeServer |  `Latest` |

### Wheels

| Package        | Version  |
|----------------|----------|
| flash_attn     | `2.8.3`    |
| sageattention  |  `2.2.0`   |
| torch_generic_nms | `0.1` |

### Optimised

| Processor | Compute Capability | SM |
|------------|-----------------|-----------|
| A40  | 8.6 | sm_86 |
| L40S | 8.9 | sm_89 |

## Building constrains (/constraints.txt)

```txt
numpy<2
onnxruntime-gpu==1.22.*
onnxruntime==0
```

## Docker speed up

```bash
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
```
