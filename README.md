# php-base
This should be the base for most PHP apps.

## Params
You can use environment variable to configure the upload size and memory limit with these variables.
By default, the upload limit is 10 MB and the memory limit is at 512 MB.

```
PHP_MEMORY_LIMIT=512M
PHP_UPLOAD_SIZE=10M
```

## OP Cache
Parameters are available to configure the PHP OP Cache using these environment variables.

```
PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 (set to 1 if PHP_DEV_ENV is set to 1)
PHP_OPCACHE_MAX_ACCELERATED_FILES=10000
PHP_OPCACHE_MEMORY_CONSUMPTION=192
PHP_OPCACHE_MAX_WASTED_PERCENTAGE=10
```

# For dev environment
If you are building this image in a development environment, you should set the PHP_DEV_ENV to 1. In the ./start,
you would add ```-e PHP_DEV_ENV=1``` to the docker run command. This will partially disable OP cache so you
can test your changes without waiting for the cache refresh.
It can also be used in your apps for debuging, for example if using the php-base-laminas
image, the PHP_DEV_ENV also control the output of exception details.

In your app, you can use this code to display errors only in dev (errors should never be shown in prod)
```php
if(getenv('PHP_DEV_ENV') == 1) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
}
```


# Testing locally
If you want to test your application locally, you can ./build and use the ./start.sh script as a starting point.
