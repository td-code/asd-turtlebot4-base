# Quickstart Guide

Follow the instructions below to plan and execute trajectories in simulation or on the real Cobot.

## Common Steps 

### 1. Clone this Repo

```bash
git clone https://github.com/robgineer/cobot.git cobot
cd ~/cobot
```

### 2. Install docker
The entire dev. environment is based on a docker container. If you running Ubuntu and you don't have docker installed, run the following script.
```bash
./scripts/docker_installation.sh
```

### 3. Choose your GUI
We offer two different options for displaying the graphical user interface: xpra or VNC. Both are different and have their specific use cases.

* The VNC option enables viewing an entire Ubuntu Desktop within your browser. Useful in case you are running this project on a local machine. Refer [VCN setup](howToVNC.md) for details and configuration.
* The xpra option enables forwarding single X11 windows from your terminal. Its a bit more lightweight and useful if you are running this project on a remote machine. It requires your user to be ported into the docker container, however. This might not work on all configurations. Refer [Xpra setup](howToXpra.md) for details and configuration.


Once you have configured your preferred GUI type, proceed with either the simulation or real control steps.

## Simulation


### 1. Build the project

```bash
source /opt/ros/jazzy/setup.{bash/zsh}
cd ~/cobot
colcon build --merge-install --symlink-install --cmake-args "-DCMAKE_BUILD_TYPE=Release" --packages-select cobot_model cobot_moveit_config demo py_demo
source install/setup.{bash/zsh}
```

#### Colcon build options explained

`merge-install:` Do not create separate `install` folders for each package bur merge everything into one.

`symlink-install:` Do not copy built files into the install folders but create a symlink. Changes in Python files, for example, take effect immediately (no re-building required).

`cmake-args "-DCMAKE_BUILD_TYPE=Release":` Optimize build for speed

`--packages-select cobot_model cobot_moveit_config demo py_demo:` We only need these packages for a simulation.


### 2. Launch Demo

tbd