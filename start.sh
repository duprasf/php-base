#!/usr/bin/env bash
docker run -d --name whmb -p 80:80 -p 443:443 \
    -v ~/docker/php-base/certs:/var/www-certs:ro \
    php:8-base
