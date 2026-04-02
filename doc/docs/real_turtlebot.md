# Running the TurtleBot4 in hardware

This project can be run on a PC in the same network as the TurtleBot. The instructions given here are tailored to the Ubuntu 24.04 PCs in the SVR-Lab.

Two things need to be prepared:
1. The docker container should share the host's network.
2. You may want to use your GPU on the client (if available).
2. The PC needs should have the same ROS_DOMAIN_ID as the TurtleBot.

## 1. Sharing the host's network

Modify ``.devcontainer/devcontainer.json``:

```bash
    "runArgs": [
        "--hostname=ros2-vnc-docker",
        "--shm-size=512m",
        "--init",
        "--network", << added
        "host",      << added
        ...
    ],
```

This will also prevent the VNC display port to be forwarded from the devcontainer. However, since the lab PCs are Ubuntu PCs, all GUIs can be rendered directly without any VNC or xpra. For this, change the DISPLAY env variable in ``.devcontainer/devcontainer.json``:
```bash
    "containerEnv": {
        "DISPLAY": "${localEnv:DISPLAY}"
    }
```

## 2. Enable GPU

   In ``devcontainer.json``, replace the line 
   ```bash
   "image": "tdcode/asd-turtlebot4-docker:latest", 
   ```
   by
   ```bash
   "image": "tdcode/asd-turtlebot4-docker:gpu", 
   ```
   and run "Rebuild and reopen in container" in vscode.

## 3. ROS_DOMAIN_ID

To separate the different TurtleBots in the lab, each TurtleBot has a different ros domain ID, e.g. ``svr_tb_1`` has domain ID 11.

To switch to the same domain ID, run:
```bash
(ros_venv) ubuntu@ros2-vnc-docker:/workspace$ source scripts/enable_turtlebot.sh 11
```
Dann ändert sich der command line prompt:
```bash
[ROS:11] (ros_venv) ubuntu@ros2-vnc-docker:/workspace$ 
```

