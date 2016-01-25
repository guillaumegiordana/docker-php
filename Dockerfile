FROM tutum/apache-php
MAINTAINER Guillaume Giordana <guillaume.giordana@the-oz.com>

RUN apt-get update && \
	apt-get -yq install \
    curl \
    mcrypt \
    php5-curl \
	php5-gd \
	php5-mcrypt \
	php5-memcached \
	php5-intl \
	php5-xsl \
	php5-mongo

# fix for using top by example
ENV TERM dumb

RUN php5enmod mcrypt
RUN mkdir -p /tmp/session/
RUN curl -sS http://files.magerun.net/n98-magerun-latest.phar -o /usr/bin/n98-magerun.phar
RUN chmod +x /usr/bin/n98-magerun.phar
RUN mv /usr/bin/n98-magerun.phar /usr/bin/magerun
RUN mkdir -p /var/www/.n98-magerun/scripts/
WORKDIR /var/www