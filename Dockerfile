# VERSION 0.1
# AUTHOR:         Miroslav Prasil <miroslav@prasil.info>
# DESCRIPTION:    Image with DokuWiki & lighttpd
# TO_BUILD:       docker build -t mprasil/dokuwiki .
# TO_RUN:         docker run -d -p 80:80 --name my_wiki mprasil/dokuwiki

# Upstream:
# https://bitbucket.org/mprasil/docker_dokuwiki.git

FROM ubuntu:14.04
MAINTAINER Miroslav Prasil <miroslav@prasil.info>

# Set the version you want of Twiki
ENV DOKUWIKI_VERSION 2015-08-10a
ENV DOKUWIKI_CSUM a4b8ae00ce94e42d4ef52dd8f4ad30fe

ENV LAST_REFRESHED 6. September 2015

# Update & install packages & cleanup afterwards
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install wget lighttpd php5-cgi php5-gd php5-ldap && \
    apt-get clean autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log}

# Download & check & deploy dokuwiki & cleanup
RUN wget -q -O /dokuwiki.tgz "http://download.dokuwiki.org/src/dokuwiki/dokuwiki-$DOKUWIKI_VERSION.tgz" && \
    if [ "$DOKUWIKI_CSUM" != "$(md5sum /dokuwiki.tgz | awk '{print($1)}')" ];then echo "Wrong md5sum of downloaded file!"; exit 1; fi && \
    mkdir /dokuwiki && \
    tar -zxf dokuwiki.tgz -C /dokuwiki --strip-components 1 && \
    rm dokuwiki.tgz

# Set up ownership
RUN chown -R www-data:www-data /dokuwiki

# Configure lighttpd
ADD dokuwiki.conf /etc/lighttpd/conf-available/20-dokuwiki.conf
RUN lighty-enable-mod dokuwiki fastcgi accesslog
RUN mkdir /var/run/lighttpd && chown www-data.www-data /var/run/lighttpd

EXPOSE 80
VOLUME ["/dokuwiki/data/","/dokuwiki/lib/plugins/","/dokuwiki/conf/","/dokuwiki/lib/tpl/","/var/log/"]

ENTRYPOINT ["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]

