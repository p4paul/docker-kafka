# --------------------------------------------------------------------------------
# Docker configuration for Kafka and Zookeeper
# --------------------------------------------------------------------------------

FROM java:openjdk-8-jre

LABEL vendor="Perforce Software"
LABEL maintainer="Paul Allen (pallen@perforce.com)"

# Install Kafka, Zookeeper and other needed things
RUN \
  apt-get update && \
  apt-get install -y zookeeper wget supervisor apt-transport-https vim net-tools && \
  wget -qO - https://packages.confluent.io/deb/5.0/archive.key | apt-key add - && \
  echo "deb [arch=amd64] https://packages.confluent.io/deb/5.0 stable main" >  /etc/apt/sources.list.d/confluent.list && \
  apt-get update

RUN \
  apt-get install -y confluent-platform-oss-2.11

# Supervisor config
ADD files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Hack for reverse-proxy to make Kafka look transparent outside container
RUN sed -i.orig -e 's/#advertised\.listeners.*$/advertised.listeners=PLAINTEXT:\/\/localhost:9092/' /etc/kafka/server.properties


# 2181 is zookeeper, 9092 is kafka and 9001 is supervisord
EXPOSE 2181 9092 9001

CMD ["supervisord", "-n"]
