FROM php:8.1-apache

WORKDIR /var/www

LABEL title = 'PHP8-base with composer, git and other essentials'
LABEL author = 'Web/Mobile Team (imsd.web-dsgi@hc-sc.gc.ca)'
LABEL source = 'https://github.hc-sc.gc.ca/hs/php-base'

# default values for PROD
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10" \
    MEMORY_LIMIT="512M" \
    UPLOAD_SIZE="10M"

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
    nano

#RUN pecl install memcached-3.1.5
#RUN docker-php-ext-enable memcached

# lines for LDAP
RUN apt-get install -y libldap2-dev libldap-common
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-install ldap

RUN set -eux; \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp; \
    docker-php-ext-configure intl; \
    docker-php-ext-configure mysqli --with-mysqli=mysqlnd; \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd; \
    docker-php-ext-configure zip; \
    docker-php-ext-install -j "$(nproc)" \
        gd \
        zip \
        intl \
        mysqli\
        opcache\
        gettext \
        pdo_mysql\
        pdo_sqlite


# install imagick
#RUN pecl install imagick
#RUN docker-php-ext-enable imagick

RUN a2enmod rewrite

# install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# set the php.ini
RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    sed -i "s@short_open_tag = Off@short_open_tag = On@g" /usr/local/etc/php/php.ini && \
    sed -i "s@memory_limit = .*@memory_limit = \${MEMORY_LIMIT}@g" /usr/local/etc/php/php.ini && \
    sed -i "s@upload_max_filesize = .*@upload_max_filesize = \${UPLOAD_SIZE}@g" /usr/local/etc/php/php.ini

COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Clean up the image
RUN rm -rf /var/lib/apt/lists/*

COPY go-php.sh /go-php.sh
RUN chmod 774 /go-php.sh
ENTRYPOINT ["/go-php.sh"]
