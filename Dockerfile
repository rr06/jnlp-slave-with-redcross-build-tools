FROM cloudbees/jnlp-slave-with-java-build-tools:2.4.0

USER root

ADD scripts /scripts

ENV VER_GRADLE 3.5
ENV VER_DOCKER_COMPOSE 1.24.1

# set for non-interactive install (do not forget to unset in the end)
ENV DEBIAN_FRONTEND noninteractive

RUN \
  # update packages and install docker, mysql, and gradle
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
  apt-get -y update && \
  # make sure sudo is there
  echo  "N" | apt-get -y install sudo && \
  apt-cache policy docker-ce && \
  apt-get -y --no-install-recommends install docker-ce ruby mysql-server && \
  # install gradle
  curl --progress-bar --location --fail --silent --remote-name https://downloads.gradle.org/distributions/gradle-${VER_GRADLE}-bin.zip && \
  mkdir /opt/gradle && \
  unzip -d /opt/gradle gradle-${VER_GRADLE}-bin.zip && \
  ln -s /opt/gradle/gradle-${VER_GRADLE}/bin/gradle /usr/local/bin/gradle

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/${VER_DOCKER_COMPOSE}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
  chmod +x /usr/local/bin/docker-compose

ENV DEBIAN_FRONTEND=""

COPY docker_group_setup.sh /opt/bin/docker_group_setup.sh

RUN chmod 755 /opt/bin/docker_group_setup.sh /scripts/mysql/*.sh

# Ideally, we would switch to the jenkins user at this point. However, there is a challenge 
# I'm struggling with. In order to run docker commands from inside the container, we need to
# have access to /var/run/docker.sock on the host. That means making sure container Jenkins is 
# in a group where the GID matches the GID of the docker group on the host. 
# The most flexible way of getting the right GID is to pull it at run time from the container.
# The specifics are in the docker_group_setup.sh script.
# The challenge is container jenkins user doesn't actually get the new GID until conatiner jenkins
# logs in again. I tried all kinds of different ways to do so to no avail.
# So the compromise, at least for now, is to leave user as root here. The docker_group_setup.sh
# entrypoint will change to user jenkins before starting up the jnlp agent.
# Again, not ideal, but it works for now.
# 
# When problem described above is figured out, uncomment line below
# USER jenkins

VOLUME [ "/etc/group_host" ]

ENTRYPOINT [ "/opt/bin/docker_group_setup.sh" ]
