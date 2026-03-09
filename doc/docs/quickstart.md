# Quickstart Guide

Follow the instructions below to plan and execute trajectories in simulation or on the real robot.

## Common Steps 

### 1. Clone this Repo

```bash
git clone https://github.com/td-code/asd-turtlebot4-base.git .
cd asd-turtlebot4-base
```

### 2. Install docker
The entire dev. environment is based on a docker container. If you running **Ubuntu** and you don't have docker installed, run the following script.
```bash
./scripts/docker_installation.sh
```

If you are running a **Mac**, install [Docker Desktop on Mac](https://docs.docker.com/desktop/setup/install/mac-install/).

And for **Windows users**, install [Docker Desktop on Windows](https://docs.docker.com/desktop/setup/install/windows-install/)

### 3. Choose your docker image

The default docker image should run on amd64 and arm64 platforms. You can also select and run a docker image with NVidia GPU support, or use a locally build docker image. All of these three options are described in the [devcontainer README](../../.devcontainer/README.md).

### 4. Choose your GUI
We offer two different options for displaying the graphical user interface: xpra or VNC. Both are different and have their specific use cases.

* The VNC option enables viewing an entire Ubuntu Desktop within your browser. Useful in case you are running this project on a local machine. Refer [VCN setup](howToVNC.md) for details and configuration. **This is the recommended method for the ASD lab.**

* The xpra option enables forwarding single X11 windows from your terminal. Its a bit more lightweight and useful if you are running this project on a remote machine. It requires your user to be ported into the docker container, however. This might not work on all configurations. Refer [Xpra setup](howToXpra.md) for details and configuration.


Once you have configured your preferred GUI type, proceed with either [the simulation](simulation.md) or [real turtlebots](real_turtlebot.md).
