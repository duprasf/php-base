# php-base

## Use LogRotate
Create a logfile configuration, name the file the name of your application.
The content of the file should be as follow
```
/[path to your logs]/* {
    daily
    rotate 31
    maxage 31
    size 2M
    compress
    delaycompress
}
```

In your dockerfile, copy the file in ```/etc/logrotate.d/[your app name]]]```
ex:
```
COPY files/appname-logrotate /etc/logrotate.d/appname
```
