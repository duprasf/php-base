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

## Using a certificate
Copy the ```apache-ssl.conf``` to ```/etc/apache2/conf-enable```. This should be done by adding
this line to your dockerfile

```
COPY apache-ssl.conf /etc/apache2/apache-ssl.conf
```
You will also need the key files in /var/www-certs/ those are ```[domain_name].crt```,
```[domain_name]-chain.crt``` and ```[domain_name].key```
This should be done by adding a volume when you create the container
```
docker run -d --name base -p 80:80 -p 443:443 \
    -v /[path-to-certs]/certs:/var/www-certs:ro \
    php:8-base
```
