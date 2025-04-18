FROM ghcr.io/pterodactyl/panel:latest

# Install required packages
RUN apk add --no-cache nginx supervisor bash && \
    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor

# Create and configure entrypoint script
RUN echo -e '#!/bin/bash\n\
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache\n\
php artisan migrate --force --seed\n\
php artisan p:user:make --email=lamelo2410@gmail.com --username=lionel --name-first=melo --name-last=night --password=Melo12345@ --admin=1 || true\n\
exec "$@"' > /entrypoint.sh && \
    chmod +x /entrypoint.sh && \
    dos2unix /entrypoint.sh

# Configure PHP-FPM
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/' /usr/local/etc/php-fpm.d/www.conf && \
    echo "clear_env = no" >> /usr/local/etc/php-fpm.d/www.conf

# Configure Supervisor
RUN echo -e '[supervisord]\n\
nodaemon=true\n\
[program:nginx]\n\
command=nginx -g "daemon off;"\n\
autorestart=true\n\
[program:php-fpm]\n\
command=php-fpm8 -F\n\
autorestart=true' > /etc/supervisor/supervisord.conf

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
