# Third-party software notices

Inventory based on the repository Dockerfile, constraints and documentation,
reviewed on 2026-09-06. Third-party copyrights belong to their respective holders.
These projects retain their own terms; the repository MIT license does not
override them. This is an inventory and source index, not a replacement for
upstream license texts or a complete image SBOM.

## Build inputs

| Component | How it enters the image | License/source reference and verification scope |
| --- | --- | --- |
| Ubuntu, Python, PyTorch, torchvision, torchaudio, Triton and NVIDIA CUDA/cuDNN/NCCL libraries | Inherited from ls250824/pytorch-cuda-ubuntu-runtime:17122025; repository documentation lists Ubuntu 22.04, Python 3.11, PyTorch 2.9.1, CUDA 12.8 and Triton 3.5.1 | Mixed licenses. Inspect the exact base image, OS package copyright files and Python distribution notices. [Base image](https://hub.docker.com/r/ls250824/pytorch-cuda-ubuntu-runtime), [PyTorch](https://github.com/pytorch/pytorch), [NVIDIA CUDA terms](https://docs.nvidia.com/cuda/eula/index.html). The parent image has not been audited here. |
| ComfyUI | Git clone with default COMFYUI_VERSION=v0.34.5 into /ComfyUI | [Upstream GPL v3 text](https://github.com/Comfy-Org/ComfyUI/blob/master/LICENSE). Verify /ComfyUI/LICENSE for the actual resolved tag; the exact tag license was not retrievable during this review. Retain its source and any modifications. |
| ComfyUI Python requirements, including frontend distributions | pip install -r /ComfyUI/requirements.txt | Each distribution has its own terms; ComfyUI's license does not automatically cover these dependencies. Resolve the exact installed versions and their license/NOTICE files. |
| FlashAttention 2.8.3 | Prebuilt flash_attn wheel from run-pytorch-cuda-develop release v1.3.1 | [Upstream source and license files](https://github.com/Dao-AILab/flash-attention). Check the exact wheel and embedded dependencies. |
| llama-cpp-python 0.3.16 | Prebuilt wheel from run-pytorch-cuda-develop release v1.3.1 | [Upstream source](https://github.com/abetlen/llama-cpp-python). Review its bundled llama.cpp and native libraries. This Dockerfile does not install a separate native llama.cpp archive. |
| SageAttention 2.2.0 | Prebuilt wheel from run-pytorch-cuda-develop release v1.3.1 | [Upstream Apache-2.0 license](https://github.com/thu-ml/SageAttention/blob/main/LICENSE). Confirm terms and any required notices in the exact wheel. |
| torch_generic_nms 0.1 | Prebuilt wheel from run-pytorch-cuda-develop release v1.3.1 | [Repository linked by this project](https://github.com/ronghanghu/torch_generic_nms). License and exact wheel provenance remain unverified; do not infer MIT from availability or the hosting repository. |
| ONNX Runtime GPU 1.22.*, ONNX | pip install | [ONNX Runtime](https://github.com/microsoft/onnxruntime), [ONNX](https://github.com/onnx/onnx). Preserve package licenses and bundled third-party notices. |
| Hugging Face Hub / hf | pip install, then hf update | [Upstream source](https://github.com/huggingface/huggingface_hub). Final version is build-dependent; inspect installed distribution notices and dependencies. |
| Typer 0.21.1, Click 8.*, NumPy and other Python dependencies | Direct installation, constraints and dependency resolution | [Typer](https://github.com/fastapi/typer), [Click](https://github.com/pallets/click), [NumPy](https://github.com/numpy/numpy). Constraints are not a complete installed-package inventory. The Civitai scripts also import [Requests](https://github.com/psf/requests). |
| code-server | Unpinned code-server.dev/install.sh | [Upstream MIT license](https://github.com/coder/code-server/blob/main/LICENSE). Bundled VS Code, Node.js and other dependencies retain separate notices; review the actual installed release. |

## Binary artifacts and inherited components

The CPython 3.11 Linux x86_64 wheels come from [run-pytorch-cuda-develop release v1.3.1](https://github.com/jalberty2018/run-pytorch-cuda-develop/releases/tag/v1.3.1).
Hosting metadata or a repository-level license is not proof of the terms for
every uploaded binary. Exact source revisions, patches, build inputs and
embedded license files have not been verified here. Resolve these details,
especially torch_generic_nms provenance, before redistributing those artifacts.

The wheels may contain software beyond their named project.
Inspect Python `.dist-info` license directories, bundled native libraries, the code-server
installation and `/usr/share/doc/*/copyright` in the built image. Preserve
notices already present in inherited layers; add missing required notices from
the matching upstream distribution rather than assigning a blanket license.

The code-server installer, hf update, version ranges and transitive dependencies
can change between builds. An image-specific inventory must use the final built
image, not just this table. Optional ComfyUI-Manager setup in the documentation
adds further dependencies and requires its own review if enabled.

The README links to comfy-cli, but this Dockerfile does not explicitly install it; its presence in the inherited image has not been verified.

See [LICENSING.md](LICENSING.md) for redistribution and source requirements.
