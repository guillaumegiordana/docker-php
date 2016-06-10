FROM php:7.0-apache

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get update && apt-get install -y \
    apache2 \
    git \
    libxml2-dev \
    libmcrypt4 \
    libmcrypt-dev \
    libxslt-dev \
    libicu-dev \
    libpng12-dev \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    vim

RUN docker-php-ext-install -j$(nproc) \
    iconv mcrypt \
    mbstring \
    pdo_mysql \
    soap \
    mcrypt \
    xsl \
    intl \
    gd \
    zip

RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/lib

RUN rm -rf /var/lib/apt/lists/*

COPY ./000-default.conf /etc/apache2/sites-enabled/000-default.conf

ENV APACHE_DOC_ROOT=/var/www/html/ \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid \
    TERM=xterm-256color

RUN a2enmod rewrite
RUN a2enmod headers

WORKDIR /var/www/html