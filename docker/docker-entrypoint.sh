#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# TODO: copy in files if they don't exist, assuming people are going to put a volume behind this
# maybe.

echo "Starting lighttpd server"
service lighttpd start

echo  "Starting cron"
cron

# echo "Configuring bind"
# echo "include \"/etc/bind/named.conf.zones\";" >> "${NAMED_CONF}"
# touch /etc/bind/named.conf.zones
# chown www-data:www-data /etc/bind/named.conf.zones

echo  "Checking configuration"
named-checkconf -z

echo  "Starting named service"
service named start

sleep infinity