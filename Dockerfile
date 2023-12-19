# this Dockerfile is based on the cytopia/docker-bind Dockerfile at https://github.com/cytopia/docker-bind/blob/master/Dockerfiles/Dockerfile.stable
# so this is going to be an all-in-one Dockerfile containiner:
#   - bind
#   - some very tiny webserver
#   - cron ?
#   - perl
# but could probably split those out into separate containers later 

FROM debian:stable-slim
LABEL org.opencontainers.image.authors="cytopia@everythingcli.org"

ENV \
    USER=bind \
    GROUP=bind

# Install bind
RUN set -eux \
    && apt update \
    && apt install --no-install-recommends --no-install-suggests -y \
        bind9 perl mini-httpd \
    && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && mkdir /var/log/named \
    && chown bind:bind /var/log/named \
    && chmod 0755 /var/log/named

RUN set -eux \
    && apt install --no-install-recommends --no-install-suggests -y \
        wget vim procps cron

# Install ddserver

RUN set -eux \
    && apt install --no-install-recommends --no-install-suggests -y \
        libwww-perl libcgi-pm-perl libjson-perl libjavascript-minifier-perl

RUN mkdir -p /var/www/ddserver \
   && mkdir -p /etc/bind/dynamic

# && rm -r /var/lib/apt/lists/* \
  
COPY ./ddserver.pl /var/www/ddserver/ddserver.pl
COPY ./ddserver.json.sample /var/www/ddserver/ddserver.json
RUN  ln -s /var/www/ddserver/ddserver.pl /var/www/ddserver/nic

COPY ./docker/index.html /var/www/ddserver/index.html
COPY ./docker/ddserver-cron /etc/cron.d/ddserver-cron

RUN 
RUN chmod 0644 /etc/cron.d/ddserver-cron
RUN crontab /etc/cron.d/ddserver-cron
RUN touch /var/log/cron.log

# Run the command on container startup
# CMD cron && tail -f /var/log/cron.log


COPY ./docker/docker-entrypoint.sh /

# bind ports
EXPOSE 53
EXPOSE 53/udp

# mini-httpd ports
EXPOSE 80

# Entrypoint

ENTRYPOINT ["/docker-entrypoint.sh"]