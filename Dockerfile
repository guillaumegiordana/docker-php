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
	php5-mongo \
	php5-apcu \
	php5-tidy \
	git \
	subversion

# fix for using top by example
ENV TERM dumb

RUN php5enmod mcrypt
RUN mkdir -p /tmp/session/
RUN curl -sS http://files.magerun.net/n98-magerun-latest.phar -o /usr/bin/n98-magerun.phar
RUN chmod +x /usr/bin/n98-magerun.phar
RUN mv /usr/bin/n98-magerun.phar /usr/bin/magerun
RUN mkdir -p /var/www/.n98-magerun/scripts/
COPY ./000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY ./30-custom.ini /etc/php5/apache2/conf.d/30-custom.ini

WORKDIR /var/www