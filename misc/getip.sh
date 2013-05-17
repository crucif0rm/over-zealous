#!/bin/bash
#
# Grabs your external ip via $IP = $REMOTE_ADDR;


IP=$( curl -s http://ip.crucif0rm.com )
echo "Your public IP is: $IP"
exit 0
