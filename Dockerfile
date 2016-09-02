FROM php:7.0-apache

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && echo "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707" > $PHP_INI_DIR/conf.d/blackfire.ini

RUN apt-get update && apt-get install -y \
    libldap-2.4-2 \
    libldap2-dev \
    ldap-utils \
    git \
    libxml2-dev \
    libmcrypt4 \
    libmcrypt-dev \
    libxslt-dev \
    libicu-dev \
    libpng12-dev \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    vim \
    openssh-server

RUN ln -s /usr/lib/x86_64-linux-gnu/libldap-2.4.so.2 /usr/lib/libldap.so
RUN ln -s x86_64-linux-gnu/liblber-2.4.so.2 /usr/lib/liblber.so

RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) \
    ldap \
    calendar \
    iconv \
    mcrypt \
    mysqli \
    pdo_mysql \
    soap \
    xsl \
    intl \
    zip \
    gd

RUN mkdir /var/run/sshd
RUN sed -i -e 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN echo 'root:b33rst0re' |chpasswd

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

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

EXPOSE 22
CMD    /usr/sbin/sshd -D