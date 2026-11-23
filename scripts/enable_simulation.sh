#!/bin/bash

# Copyright (c) 2026, Thao Dang, University of Applied Sciences Esslingen, Germany
# SPDX-License-Identifier: BSD-3-Clause
#
# Konfiguration eines PCs für lokale ROS-2-Simulation.
#
# Nutzung:
#   source enable_simulation.sh [Domain-ID]
#
# Ohne Argument wird PC_STANDALONE_DOMAIN_ID (aus /etc/turtlebot4/setup.bash) verwendet.
#
# Beispiele:
#   source enable_simulation.sh
#   source enable_simulation.sh 101
#   source enable_simulation.sh 103
#
# Vorgesehene Domain-IDs:
#   labsv-itpc3301 -> 101
#   labsv-itpc3302 -> 102
#   labsv-itpc3303 -> 103
#   labsv-itpc3304 -> 104
#   labsv-itpc3305 -> 105
#   labsv-itpc3306 -> 106

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "Fehler: Dieses Skript muss mit 'source' ausgeführt werden."
  echo "Beispiel: source $0 101"
  exit 1
fi

if [ -z "$1" ] && [ -z "$PC_STANDALONE_DOMAIN_ID" ]; then
  echo "Fehler: Keine Domain-ID angegeben und PC_STANDALONE_DOMAIN_ID ist nicht gesetzt."
  echo "Nutzung: source ${BASH_SOURCE[0]} [101..106]"
  echo "         (Standard: PC_STANDALONE_DOMAIN_ID aus /etc/turtlebot4/setup.bash)"
  return 1
fi

DOMAIN_ID="${1:-$PC_STANDALONE_DOMAIN_ID}"

if [ -n "$PC_STANDALONE_DOMAIN_ID" ] && [ "$DOMAIN_ID" != "$PC_STANDALONE_DOMAIN_ID" ]; then
  echo "Warnung: Domain-ID $DOMAIN_ID weicht von der Standard-ID dieses PCs ($PC_STANDALONE_DOMAIN_ID) ab."
fi

case "$DOMAIN_ID" in
  101|102|103|104|105|106)
    ;;
  *)
    echo "Fehler: Ungültige Simulations-Domain-ID '$DOMAIN_ID'."
    echo "Erlaubt sind die Domain-IDs 101 bis 106."
    return 1
    ;;
esac

source /opt/ros/jazzy/setup.bash

if [ -f /workspace/install/setup.bash ]; then
  source /workspace/install/setup.bash
fi

export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
export ROS_DOMAIN_ID="$DOMAIN_ID"

# Reiner lokaler Simulationsbetrieb: keine Remote-Discovery
unset ROS_DISCOVERY_SERVER
unset ROS_STATIC_PEERS
unset ROS_LOCALHOST_ONLY
# Super Client nie in der Shell setzen (Nav2 startet sonst nicht, siehe ros_super_client_issue.md)
unset ROS_SUPER_CLIENT
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
# Gazebo transport nur auf Loopback (behebt den Fuel-Asset-Download in der Simulation)
export GZ_IP=127.0.0.1

# Daemon neu starten, damit er keine Einstellungen aus dem Roboterbetrieb behält
ros2 daemon stop >/dev/null 2>&1
ros2 daemon start >/dev/null 2>&1

echo "Lokaler Simulationsbetrieb aktiviert:"
echo "  ROS_DOMAIN_ID:                  $ROS_DOMAIN_ID"
echo "  ROS_AUTOMATIC_DISCOVERY_RANGE: $ROS_AUTOMATIC_DISCOVERY_RANGE"
echo "  ROS_DISCOVERY_SERVER:          ${ROS_DISCOVERY_SERVER:-nicht gesetzt}"
echo "  ROS_STATIC_PEERS:              ${ROS_STATIC_PEERS:-nicht gesetzt}"
echo "  ROS_SUPER_CLIENT:              ${ROS_SUPER_CLIENT:-nicht gesetzt}"
echo "  RMW_IMPLEMENTATION:            $RMW_IMPLEMENTATION"

echo
if ros2 topic list >/tmp/enable_simulation_topics.txt 2>/tmp/enable_simulation_topics.err; then
  TOPIC_COUNT=$(grep -c '^/' /tmp/enable_simulation_topics.txt 2>/dev/null || echo 0)
  echo "Kurztest: OK, aktuell sichtbare Topics: $TOPIC_COUNT"
else
  echo "Kurztest: WARNUNG, 'ros2 topic list' konnte nicht ausgeführt werden."
  head -n 10 /tmp/enable_simulation_topics.err | sed 's/^/    /'
fi
