#!/usr/bin/env bash

if [ ! -z "$PHP_DEV_ENV" ] && [ "${PHP_DEV_ENV}" == "1" ]; then
    echo 'In dev mode, disabling cache'
    echo 'PHP_OPCACHE_VALIDATE_TIMESTAMPS=1' >> /tmp/php-opcache
    . /tmp/php-opcache
fi

POST_MAX_SIZE=$UPLOAD_SIZE

apache2-foreground
