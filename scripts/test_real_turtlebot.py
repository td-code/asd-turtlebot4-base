#!/usr/bin/env python3

# Test if turtlebot is moving.
#
# Usage:
#   # switch to your turtlebot
#   cd /workspace 
#   source scripts/enable_turtlebot.sh 11
#
#   # run script and check scan message and rotation of turtlebot
#   scripts/test_real_turtlebot.py

import rclpy
from rclpy.node import Node
from rclpy.qos import qos_profile_sensor_data
from geometry_msgs.msg import TwistStamped
from sensor_msgs.msg import LaserScan

class RotateAndCheckScanNode(Node):
    def __init__(self):
        super().__init__('rotate_and_check_scan_node')
        
        # Status-Flag für die /scan-Nachricht
        self.scan_received = False
        
        # 1. Subscriber für /scan (nutzt Sensor-QoS, wichtig für TurtleBot LiDAR!)
        self.scan_sub = self.create_subscription(
            LaserScan,
            '/scan',
            self.scan_callback,
            qos_profile_sensor_data
        )
        
        # 2. Publisher für /cmd_vel
        self.cmd_vel_pub = self.create_publisher(TwistStamped, '/cmd_vel', 10)
        
        # Timer für die Drehung (alle 2.0 Sekunden = 0.5 Hz)
        self.move_timer = self.create_timer(2.0, self.move_callback)
        
        # Optionaler Timer, der alle 2 Sekunden erinnert, falls noch kein Scan da ist
        self.status_timer = self.create_timer(2.0, self.status_callback)
        
        self.get_logger().info('Node gestartet. Roboter dreht sich. Warte auf erste /scan-Nachricht...')

    def scan_callback(self, msg):
        # Wird aufgerufen, sobald eine Nachricht auf /scan ankommt
        if not self.scan_received:
            self.scan_received = True
            self.get_logger().info('STATUS-UPDATE: Erste /scan-Nachricht ist jetzt da!')

    def status_callback(self):
        # Gibt nur so lange eine Info aus, bis der erste Scan eingetroffen ist
        if not self.scan_received:
            self.get_logger().warn('STATUS: Noch keine /scan-Nachricht verfügbar...')
        else:
            # Timer stoppen, sobald der Scan einmal empfangen wurde
            self.status_timer.cancel()

    def move_callback(self):
        # Sendet unabhängig vom Scan-Status alle 2 Sekunden den Dreh-Befehl
        msg = TwistStamped()
        msg.header.stamp = self.get_clock().now().to_msg()
        msg.header.frame_id = 'base_link'
        
        msg.twist.linear.x = 0.0
        msg.twist.linear.y = 0.0
        msg.twist.linear.z = 0.0
        
        msg.twist.angular.x = 0.0
        msg.twist.angular.y = 0.0
        msg.twist.angular.z = 0.2
        
        self.cmd_vel_pub.publish(msg)

def main(args=None):
    rclpy.init(args=args)
    node = RotateAndCheckScanNode()
    
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        # Roboter beim Beenden (Strg+C) sicher anhalten
        stop_msg = TwistStamped()
        stop_msg.header.stamp = node.get_clock().now().to_msg()
        node.cmd_vel_pub.publish(stop_msg)
        
        node.destroy_node()
        rclpy.shutdown()

if __name__ == '__main__':
    main()
