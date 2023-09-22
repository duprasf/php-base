#!/usr/bin/env bash

if [ ! -z "$UPLOAD_SIZE" ]
then
    sed -i "s@upload_max_filesize = 2M@upload_max_filesize = ${UPLOAD_SIZE}@g" /usr/local/etc/php/php.ini
fi

if [ ! -z "$MEMORY_LIMIT" ]
then
    sed -i "s@memory_limit = 512M@memory_limit = ${MEMORY_LIMIT}@g" /usr/local/etc/php/php.ini
fi

apache2-foreground
