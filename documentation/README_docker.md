# comfyui-runtime

A lightweight runtime Docker base image for ComfyUI.

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- [comfy-cli](https://github.com/Comfy-Org/comfy-cli)
- [Code server](https://github.com/coder/code-server)
- [HuggingFace cli](https://huggingface.co/docs/huggingface_hub/guides/cli)
- [Flash attention](https://github.com/Dao-AILab/flash-attention)
- [Sage attention](https://github.com/thu-ml/SageAttention)
- [Onnxruntime-gpu](https://pypi.org/project/onnxruntime-gpu/)

## Setup

## Setup

| Component | Version              |
|-----------|----------------------|
| OS        | `Ubuntu 22.x x86_64` |
| Python    | `3.11.x`             |
| PyTorch   | `2.8.0`              |
| CUDA      | `12.9`               |
| Triton    | `3.x`                |
| onnxruntime-gpu | `>=1.20.0` |
| ComfyUI | Latest |
| CodeServer | Latest |

## Installed Attentions

| Package        | Version  |
|-----------------|----------|
| flash_attn     | 2.8.3    |
| sageattention   | 2.2.0    |