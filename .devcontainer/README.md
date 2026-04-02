# Dev Container for TurtleBot 4 Simulation and Development Suite 

General info on how to use devcontainers in this project are given in [VNC setup](../doc/docs/howToVNC.md).

## Selecting docker images

There are three relevant modes of operation:

1. Running the devcontainer **without GPU** support:

   Leave everything as is in ``devcontainer.json``, i.e. use 
   ```bash
   "image": "tdcode/asd-turtlebot4-docker:latest", 
   ```
   
2. Running the devcontainer **with GPU** support:
   
   In ``devcontainer.json``, replace the line 
   ```bash
   "image": "tdcode/asd-turtlebot4-docker:latest", 
   ```
   by
   ```bash
   "image": "tdcode/asd-turtlebot4-docker:gpu", 
   ```
   and run "Rebuild and reopen in container" in vscode.

3. Running a **locally built docker image**:
   
   In ``devcontainer.json``, replace the line 
   ```bash
   "image": "tdcode/asd-turtlebot4-docker:latest", 
   ```
   by
   ```bash
   "dockerFile": "Dockerfile",
   ```
   and run "Rebuild and reopen in container" in vscode.

## Rebuilding und uploading the docker images

Go to https://github.com/td-code/asd-turtlebot4-docker, update the Dockerfile stored there, and push the new version. This will trigger a Github Action that builds new images.