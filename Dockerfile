FROM debian:stable-slim
LABEL org.opencontainers.image.authors="cytopia@everythingcli.org"

ENV \
    USER=bind \
    GROUP=bind

# Install bind
RUN set -eux \
    && apt update \
    && apt install --no-install-recommends --no-install-suggests -y \
        bind9 perl lighttpd cron \
    && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && mkdir /var/log/named \
    && chown bind:bind /var/log/named \
    && chmod 0755 /var/log/named

# few misc utilities when things go wrong
RUN set -eux \
    && apt install --no-install-recommends --no-install-suggests -y \
        wget curl vim procps less dnsutils iputils-ping

# Install ddserver

RUN set -eux \
    && apt install --no-install-recommends --no-install-suggests -y \
        libwww-perl libcgi-pm-perl libjson-perl libjavascript-minifier-perl

RUN mkdir -p /var/www/ddserver \
   && mkdir -p /etc/bind/dynamic \
   && mkdir -p /etc/bind/dynamic.old \
   && chmod 777 /etc/bind/dynamic \
   && chmod 777 /etc/bind/dynamic.old \
   && touch /var/log/ddserver.log \
   && chown www-data:www-data /var/log/ddserver.log \
   && touch /etc/bind/dynamic/zones.conf \
   && chown www-data:www-data /etc/bind/dynamic/zones.conf

# && rm -r /var/lib/apt/lists/* \
  
COPY ./ddserver.pl /var/www/html/ddserver.pl
COPY ./ddserver.json.sample /var/www/html/ddserver.json
COPY ./docker/index.html /var/www/html/index.html

COPY ./docker/20-ddserver.conf /etc/lighttpd/conf-enabled/20-ddserver.conf

COPY ./docker/ddserver-cron /etc/cron.d/ddserver-cron

COPY ./docker/named.conf.local /etc/bind/named.conf.local
COPY ./docker/named.conf.logging /etc/bind/named.conf.logging
COPY ./docker/named.conf.options /etc/bind/named.conf.options

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