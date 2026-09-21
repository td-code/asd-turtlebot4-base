#!/bin/bash

# Copyright (c) 2025, Thao Dang, University of Applied Sciences Esslingen, Germany
# SPDX-License-Identifier: BSD-3-Clause

# Nutzung:
#   source enable_turtlebot.sh <1..5 | 11..15> [--self-test]
#
# Beispiele:
#   source enable_turtlebot.sh 1
#   source enable_turtlebot.sh 11
#   source enable_turtlebot.sh 3 --self-test
#
# Bedeutung:
#   1..5   = TurtleBot-Nummer
#   11..15 = direkte ROS_DOMAIN_ID
#
# Dieses Skript ist für das Labor-Setup gedacht mit:
# - einem Onboard Discovery Server je TurtleBot
# - keiner Verwendung von Robot-Namespaces
# - einer eigenen ROS_DOMAIN_ID pro TurtleBot

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "Fehler: Dieses Skript muss mit 'source' ausgeführt werden."
  echo "Beispiel: source $0 1 --self-test"
  exit 1
fi

if [ -z "$1" ]; then
  echo "Fehler: Bitte TurtleBot-Nummer (1..5) oder Domain-ID (11..15) angeben."
  echo "Nutzung: source ${BASH_SOURCE[0]} <1..5 | 11..15> [--self-test]"
  return 1
fi

ARG="$1"
SELF_TEST="false"

if [ "$2" = "--self-test" ] || [ "$2" = "-t" ]; then
  SELF_TEST="true"
fi

case "$ARG" in
  1|11)
    TB_NAME="svr_tb_1"
    ROBOT_IP="192.168.60.11"
    DOMAIN_ID="11"
    ;;
  2|12)
    TB_NAME="svr_tb_2"
    ROBOT_IP="192.168.60.12"
    DOMAIN_ID="12"
    ;;
  3|13)
    TB_NAME="svr_tb_3"
    ROBOT_IP="192.168.60.13"
    DOMAIN_ID="13"
    ;;
  4|14)
    TB_NAME="svr_tb_4"
    ROBOT_IP="192.168.60.14"
    DOMAIN_ID="14"
    ;;
  5|15)
    TB_NAME="svr_tb_5"
    ROBOT_IP="192.168.60.15"
    DOMAIN_ID="15"
    ;;
  *)
    echo "Fehler: Ungültige Eingabe '$ARG'. Erlaubt sind 1..5 oder 11..15."
    return 1
    ;;
esac

source /opt/ros/jazzy/setup.bash
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
export ROS_DOMAIN_ID="$DOMAIN_ID"

# Fast DDS discovery-server mode expects the server list to be indexed by server ID.
# Mirror the TurtleBot setup tool so the user PC connects to the intended robot server.
ROS_DISCOVERY_SERVER=""
for ((i=0; i<DOMAIN_ID; i++)); do
  ROS_DISCOVERY_SERVER+=";"
done
ROS_DISCOVERY_SERVER+="${ROBOT_IP}:11811;"
export ROS_DISCOVERY_SERVER

export ROS_SUPER_CLIENT=True

# Wechsel aus Simulationsmodus zurück in den Roboterbetrieb:
unset ROS_LOCALHOST_ONLY
unset ROS_STATIC_PEERS
export ROS_AUTOMATIC_DISCOVERY_RANGE=SUBNET

if [ -f /workspace/install/setup.bash ]; then
  source /workspace/install/setup.bash
fi

ros2 daemon stop >/dev/null 2>&1
ros2 daemon start >/dev/null 2>&1

echo "TurtleBot aktiviert:"
echo "  Name:                          $TB_NAME"
echo "  IP:                            $ROBOT_IP"
echo "  ROS_DOMAIN_ID:                 $ROS_DOMAIN_ID"
echo "  ROS_DISCOVERY_SERVER:          $ROS_DISCOVERY_SERVER"
echo "  ROS_SUPER_CLIENT:              $ROS_SUPER_CLIENT"
echo "  ROS_AUTOMATIC_DISCOVERY_RANGE: $ROS_AUTOMATIC_DISCOVERY_RANGE"
echo "  RMW_IMPLEMENTATION:            $RMW_IMPLEMENTATION"

if [ "$SELF_TEST" = "true" ]; then
  echo
  echo "Selbsttest gestartet ..."

  echo
  echo "[1/3] Netzwerktest (ping)"
  if ping -c 1 -W 1 "$ROBOT_IP" >/dev/null 2>&1; then
    echo "  OK: $ROBOT_IP ist erreichbar."
  else
    echo "  WARNUNG: $ROBOT_IP ist nicht per ping erreichbar."
    echo "           Bitte Netzwerk, Stromversorgung und WLAN/LAN prüfen."
  fi

  echo
  echo "[2/3] ROS-2-Umgebung"
  echo "  ROS_DOMAIN_ID=$ROS_DOMAIN_ID"
  echo "  ROS_DISCOVERY_SERVER=$ROS_DISCOVERY_SERVER"
  echo "  ROS_AUTOMATIC_DISCOVERY_RANGE=$ROS_AUTOMATIC_DISCOVERY_RANGE"
  echo "  RMW_IMPLEMENTATION=$RMW_IMPLEMENTATION"

  echo
  echo "[3/3] ROS-Graph-Test (ros2 topic list)"
  if ros2 topic list >/tmp/enable_turtlebot_topics.txt 2>/tmp/enable_turtlebot_topics.err; then
    TOPIC_COUNT=$(grep -c '^/' /tmp/enable_turtlebot_topics.txt 2>/dev/null || echo 0)
    echo "  OK: ros2 topic list erfolgreich. Gefundene Topics: $TOPIC_COUNT"
    echo "  Erste Topics:"
    head -n 10 /tmp/enable_turtlebot_topics.txt | sed 's/^/    /'
  else
    echo "  FEHLER: ros2 topic list fehlgeschlagen."
    if [ -s /tmp/enable_turtlebot_topics.err ]; then
      echo "  Ausgabe:"
      head -n 10 /tmp/enable_turtlebot_topics.err | sed 's/^/    /'
    fi
    echo "  Bitte ROS-Umgebung, Domain-ID, Discovery-Server und Roboterstatus prüfen."
  fi
fi
