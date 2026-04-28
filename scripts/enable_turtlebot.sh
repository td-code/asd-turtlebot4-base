#!/bin/bash

# Prüfen, ob ein Argument übergeben wurde
if [ -z "$1" ]; then
    echo "Fehler: Bitte eine DOMAIN_ID angeben."
    echo "Nutzung: source $0 <ID>"
    echo "Achtung: Das Skript muss mit 'source' ausgeführt werden, damit die Umgebungsvariablen"
    echo "         im aktuellen Shell-Kontext persistent sind."
    echo "Beispiel: source $0 11  # setzt ROS_DOMAIN_ID auf 11, verwendet für TurtleBot svr_tb_1" 

    # Rückkehr statt Exit, falls gesourced wird
    return 1 2>/dev/null || exit 1
fi

# Die übergebene ID zuweisen
DOMAIN_ID=$1

# Die gewünschten Befehle ausführen
source /opt/ros/jazzy/setup.bash
export ROS_DOMAIN_ID=$DOMAIN_ID
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp

if [ -f /workspace/install/setup.bash ]; then
    source /workspace/install/setup.bash
fi

echo "ROS Jazzy konfiguriert: DOMAIN_ID=$ROS_DOMAIN_ID, RMW=$RMW_IMPLEMENTATION"
