FROM ghcr.io/pterodactyl/panel:latest

# Installation des dépendances manquantes
RUN apk add --no-cache nginx supervisor && \
    mkdir -p /run/nginx && \
    mkdir -p /etc/supervisor/conf.d

# Configuration Supervisor
RUN echo -e '[supervisord]\n\
nodaemon=true\n\
[program:nginx]\n\
command=nginx -g "daemon off;"\n\
autorestart=true\n\
[program:php]\n\
command=php-fpm8 -F\n\
autorestart=true' > /etc/supervisor/supervisord.conf

# Script d'initialisation
RUN echo -e '#!/bin/sh\n\
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache\n\
php artisan migrate --force --seed\n\
php artisan p:user:make --email=lamelo2410@gmail.com --username=lionel --name-first=melo --name-last=night --password=Melo12345@ --admin=1 || true\n\
exec "$@"' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
