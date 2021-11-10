FROM php:8-apache
#
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
    nano && \
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


# SSH 2 seems to be part of PHP core now
#RUN cd /tmp \
#    && git clone https://github.com/php/pecl-networking-ssh2.git ssh2
#RUN cd /tmp/ssh2/ \
#    && .travis/build.sh
#RUN docker-php-ext-enable ssh2

# install composer
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Clean up the image
RUN rm -rf /var/lib/apt/lists/*

