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

## Using a SSL
When building your image, you will have to add ```--build-arg ssl=true```

Create a ```apache-ssl.conf``` in a ```ssl``` folder (see below)

You will also need the key files in ```/var/www-certs/``` those are ```certificate-public.crt```,
```certificate-chain.crt``` and ```certificate-private.key```
This should be done by adding a *volume* when you create the container


```
docker run -d --name base -p 80:80 -p 443:443 \
    --build-arg ssl=true \
    -v /[path-to-certs]/certs:/var/www-certs:ro \
    php:8-base
```

### apache-ssl.conf
```
<IfModule mod_ssl.c>
<VirtualHost *:80>
    RewriteEngine On
    RewriteCond %{HTTPS} !=on
    RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]
</VirtualHost>
<VirtualHost *:443>
    Header always append Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    ServerAdmin imsd.web-dsgi@hc-sc.gc.ca
    documentRoot /var/www/html

    <DirectoryMatch /var/www/html>
        Require all granted
        Options -Indexes
        RewriteEngine On

        RewriteCond %{REQUEST_FILENAME} -s [OR]
        RewriteCond %{REQUEST_FILENAME} -d [OR]
        RewriteCond %{REQUEST_FILENAME} -l
        RewriteRule ^.*$ - [NC,L]
        RewriteRule ^.*$ /index.php [NC,L]
    </DirectoryMatch>

    SSLEngine on

    # Intermediate configuration, tweak to your needs
    SSLProtocol             TLSv1.2
    SSLCipherSuite          ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:!DSS
    #SSLProtocol             TLSv1.3
    #SSLCipherSuite          TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256:TLS_AES_128_CCM_SHA256
    SSLHonorCipherOrder     on

    SSLOptions +StrictRequire
    SSLCertificateFile /var/www-certs/certificate-public.crt
    SSLCertificateKeyFile /var/www-certs/certificate-private.key
    SSLCertificateChainFile /var/www-certs/certificate-chain.crt

    # Header edit Set-Cookie (?i)^(.*)(;\s*secure)??((\s*;)?(.*)) "$1; Secure$3$4"
</VirtualHost>
</IfModule>
```
