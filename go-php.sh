#!/usr/bin/env bash

if [ ! -z "$PHP_DEV_ENV" ] && [ "${PHP_DEV_ENV}" == "1" ]; then
    echo 'In dev mode, disabling OP Cache'
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=1
    PHP_OPCACHE_REVALIDATE_FREQ=1
fi

# backward compatibility
if [ -z "$PHP_MEMORY_LIMIT" ] && [ ! -z "$MEMORY_LIMIT" ]; then
    PHP_MEMORY_LIMIT=$MEMORY_LIMIT
fi
if [ -z "$PHP_UPLOAD_SIZE" ] && [ ! -z "$UPLOAD_SIZE" ]; then
    PHP_UPLOAD_SIZE=$UPLOAD_SIZE
fi
if [ -z "$PHP_POST_MAX_SIZE" ] && [ ! -z "$POST_MAX_SIZE" ]; then
    PHP_POST_MAX_SIZE=$POST_MAX_SIZE
else
    PHP_POST_MAX_SIZE=$PHP_UPLOAD_SIZE
fi

# call the go-application if provided by the app
if [[ -f "/go-application.sh" ]]; then
    source /go-application.sh
fi

# start cron
service cron start

# trap SIGINT and SIGTERM signals and gracefully exit
trap "service cron stop; kill \$!; exit" SIGINT SIGTERM

apache2-foreground
