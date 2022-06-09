FROM php:8.1-apache

WORKDIR /var/www

LABEL title = 'PHP8-base with composer, git and other essentials'
LABEL author = 'Web/Mobile Team (imsd.web-dsgi@hc-sc.gc.ca)'
LABEL source = 'https://github.hc-sc.gc.ca/hs/php-base'

# update the OS and install common modules
RUN apt-get update -y && apt-get upgrade -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libwebp-dev \
    curl \
    libcurl4 \
    libcurl4-openssl-dev \
    zlib1g-dev \
    libicu-dev \
    libmemcached-dev \
    memcached \
    default-mysql-client \
    libsqlite3-dev \
    libmagickwand-dev \
    unzip \
    libzip-dev \
    zip \
    git \
    nano \
    logrotate && \
    rm -rf /var/lib/apt/lists/*

RUN pecl install memcached-3.1.5
RUN docker-php-ext-enable memcached

# lines for LDAP
#RUN apt-get update -y && apt-get upgrade -y libldap2-dev \
#    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && docker-php-ext-install ldap \


RUN set -eux; \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp; \
    docker-php-ext-configure intl; \
    docker-php-ext-configure mysqli --with-mysqli=mysqlnd; \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd; \
    docker-php-ext-configure zip; \
    docker-php-ext-install -j "$(nproc)" \
        gd \
        intl \
        mysqli \
        opcache \
        gettext  \
        pdo_mysql \
        pdo_sqlite \
        zip


# install imagick
#RUN pecl install imagick
#RUN docker-php-ext-enable imagick

RUN a2enmod rewrite

# configure Apache rotate logs
# In docker, we do not need to rotate Apache logs
#COPY apache2-logrotate /etc/logrotate.d/apache2

# install composer
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# set the php.ini
RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    sed -i "s@short_open_tag = Off@short_open_tag = On@g" /usr/local/etc/php/php.ini && \
    sed -i "s@memory_limit = 128M@memory_limit = 512M@g" /usr/local/etc/php/php.ini

# setup the SSL/HTTPS
RUN a2enmod headers ssl
COPY apache-ssl.conf /etc/apache2/conf-available/apache-ssl.conf
RUN ln -s /etc/apache2/conf-available/apache-ssl.conf /etc/apache2/conf-enabled/apache-ssl.conf


# Clean up the image
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 443
