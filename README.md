# ddserver.pl

There's a nice long blog post about this over at http://www.randomnoun.com/wp/2013/07/08/a-dead-simple-dynamic-dns-server/

# NAME

ddserver.pl - A script that replicates the functionality of dyndns.org, back before they
started charging people to use it. It writes a bind9-compatible named.conf(5) zone file 
and flags the server to reload (using an external cron job to reduce flapping during
multiple updates)

# SYNOPSIS

Access this script via a web browser or command-line HTTP user agent:

    http://ddserver.pl
    http://ddserver.pl/update?hostname=movingtarget.example.com
    http://ddserver.pl/update?hostname=movingtarget.example.com&myip=1.2.3.4

This script can be tested from the command-line: 

    perl ddserver.pl

    # get Basic encoding of credentials
    perl -e 'use MIME::Base64; print MIME::Base64::encode("admin:admin");'
    
    # simulate Basic authorization headers (no web server required)
    HTTP_AUTHORIZATION="Basic YWRtaW46YWRtaW4=" \
    REMOTE_ADDR=127.0.0.1 \
    perl ddserver.pl /update? hostname=movingtarget.example.com

    # override myip value
    HTTP_AUTHORIZATION="Basic YWRtaW46YWRtaW4=" \
    perl ddserver.pl /update? hostname=movingtarget.example.com myip=1.2.3.4

    # plaintext authorisation
    perl ddserver.pl /update? hostname=movingtarget.example.com myip=1.2.3.4 username=admin password=admin

    # test via web server
    wget -O- -q --auth-no-challenge --http-user=admin --http-password=admin \
      'http://localhost/ddserver/update?hostname=movingtarget.example.com&myip=1.2.3.4'

Static resources:

    perl ddserver.pl /ddserver.js?
    perl ddserver.pl /ddserver.css?
    perl ddserver.pl /bootstrap.min.js?
    perl ddserver.pl /bootstrap.min.css?
    perl ddserver.pl /image/server.gif?

Note that the trailing '?' characters are only required on the command-line
to trigger correct pathInfo/queryString handling; they are not required when
accessed via HTTP.

# HTML INTERFACE

Something about this

# DYNDNS INTERFACE

The **ddserver.pl** script will ...

When in **update** mode, the following parameters (or arguments) are recognised:

- **hostname** fqdn 

    The name of the host as a fully qualified domain name

- **myip** ip-address 

    A dot-quadded ipv4 address, or the value "NOCHG"

- **mx** ip-address 

    A dot-quadded ipv4 address, or the value "NOCHG". This parameter is currently ignored.

- **backmx** ip-address 

    The value "ON", "OFF" or "NOCHG". This parameter is currently ignored.

- **wildcard** ip-address 

    The value "ON", "OFF" or "NOCHG". This parameter is currently ignored.

This script attempts to stay parameter-compatible with the dyndns service.
(see http://dyn.com/support/developers/api/perform-update/ )

# INSTALLATION

Copy it into an executable web directory

Configure ddserver.json, which I will describe in detail somewhere

If running multiple nameservers, configure ddserver-hostname.conf, which I will describe in detail somewhere

Create the folders and log files used by the script:

        sudo mkdir /etc/bind/dynamic; sudo chown www-data:bind /etc/bind/dynamic
        sudo mkdir /etc/bind/dynamic.old; sudo chown www-data:bind /etc/bind/dynamic.old
        sudo touch /var/log/ddserver.log; sudo chown www-data:www-data /var/log/ddserver.log

Create /etc/cron.d/ddserver:

        */1 * * * *     root if [ -f /etc/bind/dynamic/.bind_restart ]; then /etc/init.d/bind9 reload >/dev/null; rm -f /etc/bind/dynamic/.bind_restart; fi

Update your domain's name server records to point to the bind server(s) configured by this script.

# TODO

- write the thing
- allow loc, txt records to be updated for a domain
- support AAAA records for ipv6
- some form of locking around updates
- add 'hosts' system parameter value to update /etc/hosts files rather than bind config
- an admin console that allows current values and history of updates to be viewed
- implement those other dyndns parameters that don't appear to actually do anything (mx, backmx etc)
- rewrite it all in a language that has heard of type safety
- write the html interface in spanish. and then french. and then the other one.  
- buy an iphone
- write an iphone client
- profit

# LIMITATIONS

Doesn't do the things that dyndns doesn't do

# BUGS

Doesn't handle multiple host updates per request

# VERSION

$Id$

# AUTHOR

Greg Knox <knoxg@randomnoun.com>

http://www.randomnoun.com/wp/2013/02/25/firewalling-your-smtp-traffic/

# LICENSE

(c) 2013 randomnoun. All Rights Reserved. 

This work is licensed under a Creative Commons Attribution 3.0 Unported License. 
(http://creativecommons.org/licenses/by/3.0/)


---

This README was created from the perlpod documentation in ddserver.pl

To recreate, run 

	perl -MPod::Markdown -e "Pod::Markdown->new->filter(@ARGV)" ddserver.pl > ddserver.md
