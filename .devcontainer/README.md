# Dev Container for TurtleBot 4 Simulation and Development Suite 

General info on how to use devcontainers in this project are given in [VNC setup](../doc/docs/howToVNC.md).

## Selecting docker images

There are three relevant modes of operation:

1. Running the devcontainer without GPU support:

   Leave everything as is in ``devcontainer.json``, i.e. use 
   ```bash
   "image": "tdcode/asd-turtlebot4-docker", 
   ```
   
2. Running the devcontainer with GPU support:
   
   TBD

3. Running a locally built docker image:
   
   In ``devcontainer.json``, replace the line 
   ```bash
   "image": "tdcode/asd-turtlebot4-docker", 
   ```
   by
   ```bash
   "dockerFile": "Dockerfile",
   ```
   and run "Rebuild and reopen in container" in vscode.

## Rebuilding und uploading the docker images

To build a multi-arch docker image (without GPU), use 

```bash
cd .devcontainer
docker buildx build --platform linux/amd64,linux/arm64 -t tdcode/asd-turtlebot4-docker --push .
```
(Note: make sure to run this from standard MacOS, not within devcontainer/docker.)