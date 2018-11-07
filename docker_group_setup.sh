#!/bin/bash
set -euo pipefail
sudo usermod -a -G $(cat /etc/group_host | grep docker | cut -d':' -f3) jenkins
echo "Running Jenkins build agent"
/opt/bin/entry_point.sh /usr/local/bin/jenkins-slave
