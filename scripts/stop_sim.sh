#!/bin/bash
echo "Beende ROS 2 Launch und Gazebo..."
pkill -2 -f "ros2 launch"
sleep 3
# Falls noch einzelne ROS-Nodes oder Gazebo-Reste hängen:
pkill -9 -f "/opt/ros/jazzy/|gz sim|ruby"
ros2 daemon stop 2>/dev/null
echo "Alle Simulationsprozesse beendet."