#!/usr/bin/env bash
docker stop php-base
docker rm php-base

echo 'Starting docker server, by :latest tag is currently PHP 8.2'

docker run -d --name php-base -p 80:80 \
    -v /docker/php-base-test-app:/var/www/html \
    -e PHP_DEV_ENV=1 \
    php-base
