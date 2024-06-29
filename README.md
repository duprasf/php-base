# php-base
This should be the base for all new or reworked PHP apps.

## Params
You can use environment variable to configure the PHP. These are the Environment
Variable currently used to configure PHP.

- PHP_DEV_ENV [0] set to one if you are in development, this enables/disabled a few features
disabling cache, displaying errors on screen, enabling the /cache route, etc.
- PHP_MEMORY_LIMIT [512M] this is the max memory the PHP can use.
- PHP_MAX_EXECUTION_TIME [30] maximum number, in seconds, of execution before the process stops.
- PHP_UPLOAD_SIZE [10M] maximum size of upload files, 10M should be good for almost all projects.
- PHP_POST_MAX_SIZE [10M] maximum of post total including the upload size.
- PHP_SESSION_TIME [108000] number of seconds for the PHP session.
- TZ [America/Toronto] timezone for PHP. This is useful for logs and such.

### OP Cache
Parameters are available to configure the PHP OP Cache using these environment variables. You
should not have to change anything in those settings, but in case you do...

- PHP_OPCACHE_VALIDATE_TIMESTAMPS [0] In prod, this should be set to 0 so timestamps is not
validated on each request. In Dev, this allows new files to be shown and not served from cache.
This value is automatically chaned to 1 if PHP_DEV_ENV is set to 1.
- PHP_OPCACHE_MAX_ACCELERATED_FILES [10000]
- PHP_OPCACHE_MEMORY_CONSUMPTION [192]
- PHP_OPCACHE_MAX_WASTED_PERCENTAGE [10]


# For dev environment
If you are not using the php-base-laminas image, you can use this code to display
errors only in dev (errors should never be shown in prod)

```php
if(getenv('PHP_DEV_ENV') == 1) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
}
```


# Testing locally
If you want to test your application locally, you use ./build to build the image
locally. This is useful if you need to modify the image or if you don't have
access to Artifactory.

Use the ./start script as a starting point for your application.
