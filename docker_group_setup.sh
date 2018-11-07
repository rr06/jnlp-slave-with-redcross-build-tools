#!/bin/bash
set -euo pipefail

echo "Getting GID for host docker group"
gidForDockerHost=$(cat /etc/group_host | grep docker | cut -d':' -f3)
echo "Host docker group GID: ${gidForDockerHost}"

echo "Creating group and adding jenkins user"
sudo groupadd -f -g $gidForDockerHost docker-host
sudo usermod -a -G $gidForDockerHost jenkins

echo "Running Jenkins build agent"
export jnlpArgs=$@

# Super important to know what you're doing before changing this. Key points are:
# 1. We start the entry point of the FROM image (cloudbees/jnlp-slave-with-java-build-tools)
#    as jenkins
# 2. We make sure the args provided to this script get passed along to entry_point.sh
# If either of these conditions are broken, the container won't do its job of allowing access
# to docker commands
# The tricky part is making sure jenkins is added to a group with a GID matching the 
# host docker group. 
# Up to this point, the script is running as root. The line below switches to jenkins
# If you know a better way to have the whole script run as jenkins (USER jenkins in Dockerfile)
# that will ensure jenkins has the host docker group GID visible, please share!
# There must be a better way to do this. I just haven't figured it out yet.
sudo -E -H -u jenkins bash -c 'echo "Container command args: $jnlpArgs" ; /opt/bin/entry_point.sh /usr/local/bin/jenkins-slave $jnlpArgs'
