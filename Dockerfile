#
# UniFi Network Controller Dockerfile
# Copyright (C) 2019 James T. Lee
#

FROM ubuntu:16.04

RUN apt-get update \
 && apt-get install -y wget openjdk-8-jre-headless \
 && wget --progress=dot:mega https://dl.ubnt.com/unifi/5.10.17/unifi_sysvinit_all.deb \
 && apt install -y ./unifi_sysvinit_all.deb \
 && rm -f unifi_sysvinit_all.deb \
 && apt-get remove --purge --auto-remove -y wget \
 && rm -rf /var/cache/apt/lists/*

# Containers don't run syslog
RUN sed -i 's@-outfile SYSLOG@-outfile /dev/stdout@; s@-errfile SYSLOG@-errfile /dev/stderr@' /etc/init.d/unifi

# Log to our data volume
RUN mv -f /var/log/unifi /var/lib/unifi/logs \
 && ln -s /var/lib/unifi/logs /var/log/unifi

COPY init /

CMD ["/init"]
