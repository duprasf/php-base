# php-base
This should be the base for most PHP apps.

## Params
You can use environment variable to configure the upload size and memory limit with these variables.
By default, the upload limit is 2 MB and the memory limit is at 512 MB.

```
UPLOAD_SIZE=2M
MEMORY_LIMIT=512M
```

# Testing locally
If you want to test your application locally, you can ./build and use the ./start.sh script as a starting point.
