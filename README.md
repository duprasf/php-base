# php-base
This should be the base for most PHP apps.

## Params
You can use environment variable to configure the upload size and memory limit with these variables.
By default, the upload limit is 10 MB and the memory limit is at 512 MB.

```
UPLOAD_SIZE=10M
MEMORY_LIMIT=512M
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
