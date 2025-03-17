# comfyui-runtime

## Building the Docker Image

You can build and push the image to Docker Hub using the `build-docker.py` script.

### Build Script Options

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

## Available Images

### Image

Base Image: ls250824/pytorch-cuda-ubuntu-runtime:19012025

#### Custom Build: 

```bash
docker pull ls250824/pytorch-cuda-ubuntu-runtime:17032025
```

## Related projects

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- [Code server](https://github.com/coder/code-server)
