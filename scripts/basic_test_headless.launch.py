# Copyright (c) 2026, Thao Dang, University of Applied Sciences Esslingen, Germany
# SPDX-License-Identifier: BSD-3-Clause

from pathlib import Path

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription, SetEnvironmentVariable
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.actions import Node


def generate_launch_description():
    turtlebot_bringup = Path(get_package_share_directory('turtlebot4_gz_bringup'))
    create_bringup = Path(get_package_share_directory('irobot_create_gz_bringup'))
    turtlebot_description = Path(get_package_share_directory('turtlebot4_description'))
    create_description = Path(get_package_share_directory('irobot_create_description'))
    gz_sim = Path(get_package_share_directory('ros_gz_sim'))

    return LaunchDescription([
        SetEnvironmentVariable(
            name='GZ_SIM_RESOURCE_PATH',
            value=':'.join([
                str(turtlebot_bringup / 'worlds'),
                str(create_bringup / 'worlds'),
                str(turtlebot_description.parent),
                str(create_description.parent),
            ]),
        ),
        IncludeLaunchDescription(
            PythonLaunchDescriptionSource(str(gz_sim / 'launch' / 'gz_sim.launch.py')),
            launch_arguments={
                'gz_args': 'warehouse.sdf -r -v 4 -s --headless-rendering '
                           '--render-engine-server ogre2',
                'on_exit_shutdown': 'true',
            }.items(),
        ),
        Node(
            package='ros_gz_bridge',
            executable='parameter_bridge',
            name='clock_bridge',
            output='screen',
            arguments=['/clock@rosgraph_msgs/msg/Clock[gz.msgs.Clock'],
        ),
        IncludeLaunchDescription(
            PythonLaunchDescriptionSource(
                str(turtlebot_bringup / 'launch' / 'turtlebot4_spawn.launch.py')
            ),
        ),
    ])
