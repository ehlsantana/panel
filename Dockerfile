FROM ghcr.io/pterodactyl/panel:latest

# 1. Install dependencies
RUN apk add --no-cache nginx supervisor

# 2. Create required directories first
RUN mkdir -p /var/www/html/storage \
    && mkdir -p /var/www/html/bootstrap/cache \
    && mkdir -p /run/nginx \
    && mkdir -p /var/log/supervisor

# 3. Set permissions (after creating directories)
RUN chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache

# 4. Configure PHP-FPM
RUN sed -i 's/listen = .*/listen = 9000/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/;listen.owner/listen.owner/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/;listen.group/listen.group/' /usr/local/etc/php-fpm.d/www.conf

# 5. Configure Nginx
RUN echo 'server {
    listen 8080;
    root /var/www/html/public;
    index index.php;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}' > /etc/nginx/http.d/default.conf

# 6. Configure Supervisor
RUN echo '[supervisord]
nodaemon=true

[program:nginx]
command=nginx -g "daemon off;"
autorestart=true

[program:php-fpm]
command=php-fpm8 -F
autorestart=true
' > /etc/supervisor/supervisord.conf

# 7. Entrypoint script
RUN echo '#!/bin/sh
php artisan migrate --force
php artisan p:user:make --email=lamelo2410@gmail.com --username=lionel --name-first=melo --name-last=night --password=Melo12345@ --admin=1 || true
exec "$@"
' > /entrypoint.sh && chmod +x /entrypoint.sh

WORKDIR /var/www/html
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
