#!/bin/bash
set -euo pipefail
gidForDockerHost=$(cat /etc/group_host | grep docker | cut -d':' -f3)
sudo groupadd -f -g $gidForDockerHost docker-host
sudo usermod -a -G $gidForDockerHost jenkins
echo "Running Jenkins build agent"
/opt/bin/entry_point.sh /usr/local/bin/jenkins-slave "$@"
