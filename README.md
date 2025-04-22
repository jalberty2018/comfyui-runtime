# comfyui-runtime

A lightweight runtime Docker base image for ComfyUI and Code Server.

## Base Image

This image is built on top of a custom build pytorch-cuda-ubuntu-runtime image

## Available Images

### Image

Base Image: ls250824/pytorch-cuda-ubuntu-runtime:19012025

#### Custom Build: 

```bash
docker pull ls250824/comfyui-runtime:21042025
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

python3 comfyui-runtime/build-docker.py \
--username=<your_dockerhub_username> \
--tag=<custom_tag> \ 
comfyui-runtime
```

Note: If you want to push the image with the latest tag, add the --latest flag at the end.

## Related projects

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- [Code server](https://github.com/coder/code-server)
- [HuggingFace cli](https://huggingface.co/docs/huggingface_hub/guides/cli)

