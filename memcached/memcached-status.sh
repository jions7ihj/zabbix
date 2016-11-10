#!/bin/bash
 
item=$1
ip=10.26.161.453
port=22121
(echo "stats";sleep 1) | telnet $ip $port 2>/dev/null | grep "STAT $item\b" | awk '{print $3}'
