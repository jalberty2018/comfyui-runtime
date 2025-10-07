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