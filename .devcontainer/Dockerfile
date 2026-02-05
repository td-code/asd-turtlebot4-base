# syntax=docker/dockerfile:1
FROM tiryoh/ros2-desktop-vnc:jazzy

# update apt for further downloads
RUN apt-get update

# install required utilities
RUN apt-get install -y apt-utils software-properties-common x11-apps wget vim curl
# install dev. packages
RUN apt-get install -y git build-essential python-is-python3 python3-tqdm python3-ipykernel python3-venv
# get zsh and zimfw
RUN apt-get install -y zsh && curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

## set locales for ROS2 Jazzy ##
RUN apt-get install -y locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# create turtelobot4 docker image, cf https://github.com/kscottz/turtlebot4_docker/blob/2025/Dockerfile
ARG OVERLAY_WS=/opt/ros/overlay_ws

# Choose from fortress, garden, and harmonic.
ARG GZ_VERSION=harmonic

RUN apt-get update \
    && apt-get install -y lsb-release wget gnupg \
    && rm -rf /var/lib/apt/lists/*

ENV GZ_VERSION=${GZ_VERSION}
# Install Gazeob Harmonic
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null \
    && apt-get update \
    && apt-get install -y "gz-${GZ_VERSION}"  \
    && rm -rf /var/lib/apt/lists/*

# Install the matching ros_gz version, eg. `ros-humble-ros-gzharmonic`.
# For Fortress, a suffix is not necessary, so it would just be `ros-humble-ros-gz`
RUN apt-get update \
    && apt-get install -y "ros-${ROS_DISTRO}-ros-gz" emacs htop byobu python3 pip less ros-${ROS_DISTRO}-teleop-twist-keyboard ros-${ROS_DISTRO}-desktop \
    && rm -rf /var/lib/apt/lists/*

# For colcon to build python packages without errors we'll need
# https://discourse.openrobotics.org/t/rosdep-for-pip-is-broken-on-jazzy/38981/9
ARG PIP_BREAK_SYSTEM_PACKAGES=TRUE
RUN sudo apt install python3-setuptools

# Build turtlebot4 and ros_gz from source
WORKDIR $OVERLAY_WS/src
RUN git clone https://github.com/turtlebot/turtlebot4_simulator -b ${ROS_DISTRO}

WORKDIR $OVERLAY_WS
RUN apt-get update
RUN . /opt/ros/jazzy/setup.sh && \
    rosdep install -y --from-paths src --ignore-src 
RUN rm -rf /var/lib/apt/lists/*

# build overlay source
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    colcon build --symlink-install

# install turtlebot4 simulation packages
RUN apt-get update 
RUN apt-get install -y ros-jazzy-turtlebot4-desktop
RUN apt-get install -y ros-jazzy-turtlebot4-simulator ros-jazzy-irobot-create-nodes
RUN apt-get install -y ros-dev-tools
RUN apt-get install -y ros-jazzy-ros2-control ros-jazzy-ros2-controllers ros-jazzy-gz-ros2-control

# install ROS2 control
#RUN apt-get install -y ros-jazzy-ros2-control ros-jazzy-ros2-controllers
# install Gazebo Hamonic ROS2 control
#RUN apt-get install -y ros-jazzy-gz-ros2-control
# install Turtlebot4 packages
#RUN apt-get install -y ros-jazzy-turtlebot4-simulator ros-jazzy-irobot-create-nodes \
#    ros-jazzy-turtlebot4-desktop ros-jazzy-teleop-twist-keyboard \
#    ros-dev-tools
#RUN apt-get install -y ros-jazzy-rqt
# required for MoveIt2 Task Constructor
#RUN apt-get install -y ros-jazzy-py-binding-tools
# colcon utils
#RUN apt-get install -y python3-colcon-clean python3-colcon-mixin
# pyaudio
#RUN apt-get update
#RUN apt-get install -y python3-pyaudio
# marker detection
#RUN apt-get install -y ros-jazzy-apriltag-ros
# ros2 message converter
#RUN apt-get install -y ros-jazzy-rclpy-message-converter

## install xpra (with latest version) ##
RUN wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc \
    && wget -P /etc/apt/sources.list.d/ https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/noble/xpra.sources \
    && apt-get update \
    && apt-get install -y xpra

## setup venv
RUN python3 -m venv --system-site-packages /opt/ros_venv
RUN /opt/ros_venv/bin/pip install --upgrade \
    pip setuptools wheel \
    colcon-common-extensions \
    numpy==1.26.4 onnxruntime==1.23.2 onnx==1.20.0 onnxruntime-gpu==1.23.2 \
    opencv-python==4.10.0.84 ultralytics==8.3.224 \
    scipy scikit-learn

#################################################
## port current user to container if required ##
#################################################
ARG USERNAME=*IAmNotAUser*
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN if [ "$USERNAME" == "runner" ] ; then \
    echo "Running in GitHub Actions, skipping user creation." ; \
    elif [ "$USERNAME" != "*IAmNotAUser*" ] ; then \
    # create the user
    groupadd --gid $GROUP_ID $USERNAME && \
    useradd --uid $USER_ID --gid $GROUP_ID -m $USERNAME && \
    apt-get update && apt-get install -y sudo && \
    # enable sudo with no password (there is no need for that but its a nice to have)
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    # create directories required for xpra logging
    mkdir -p /run/user/$USER_ID && chown $USERNAME /run/user/$USER_ID ; \
    fi

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sleep", "infinity"]
