#!/usr/bin/env bash
docker stop php-base
docker rm php-base

docker run -d --name php-base -p 80:80 -p 443:443 \
    -v ~/docker/php-base/certs:/var/www-certs:ro \
    php-base
