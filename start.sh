#!/usr/bin/env bash
docker stop php-base
docker rm php-base

docker run -d --name php-base -p 80:80 \
    -v /docker/app:/var/www/html \
    php-base
