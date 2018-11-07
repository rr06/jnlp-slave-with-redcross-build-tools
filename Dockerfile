FROM cloudbees/jnlp-slave-with-java-build-tools

USER root

ADD scripts /scripts

ENV VER_GRADLE 3.5

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

ENV DEBIAN_FRONTEND=""

COPY docker_group_setup.sh /opt/bin/docker_group_setup.sh

RUN chmod 755 /opt/bin/docker_group_setup.sh

USER jenkins

VOLUME [ "/etc/group_host" ]

ENTRYPOINT [ "/opt/bin/docker_group_setup.sh" ]