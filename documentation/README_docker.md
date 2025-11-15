# comfyui-runtime

Docker base image for ComfyUI, Code-Server and downloaders based on ls250824/pytorch-cuda-ubuntu-runtime.
This image does not start any service use ls250824/run-x

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- [comfy-cli](https://github.com/Comfy-Org/comfy-cli)
- [Code server](https://github.com/coder/code-server)
- [HuggingFace cli](https://huggingface.co/docs/huggingface_hub/guides/cli)
- [Flash attention](https://github.com/Dao-AILab/flash-attention)
- [Sage attention](https://github.com/thu-ml/SageAttention)
- [Onnxruntime-gpu](https://pypi.org/project/onnxruntime-gpu/)
- [Triton](https://triton-lang.org/main/index.html)

## Setup latest image

| Component | Version              |
|-----------|----------------------|
| OS        | `Ubuntu 22.04 x86_64` |
| Python    | `3.11.x`             |
| PyTorch   | `2.9.0`              |
| CUDA      | `12.8`             |
| Triton    | `3.4.0`               |
| onnxruntime-gpu | `1.22.x` |
| ComfyUI | `0.3.68`  | 
| CodeServer | Latest |

## Installed Attentions latest image

### Wheels

| Package        | Version  |
|----------------|----------|
| flash_attn     | `2.8.3`    |
| sageattention  |  `2.2.0`   |

### Build for

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