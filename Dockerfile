FROM ghcr.io/pterodactyl/panel:latest

# Create custom supervisor config
RUN mkdir -p /etc/supervisor/conf.d && \
    echo -e '[supervisord]\n\
nodaemon=true\n\
[program:nginx]\n\
command=/usr/sbin/nginx -g "daemon off;"\n\
autostart=true\n\
autorestart=true\n\
[program:php-fpm]\n\
command=/usr/local/sbin/php-fpm --nodaemonize\n\
autostart=true\n\
autorestart=true' > /etc/supervisor/supervisord.conf

# Create entrypoint script
RUN echo -e '#!/bin/sh\n\
php artisan migrate --force\n\
php artisan p:user:make --email=lamelo2410@gmail.com --username=lionel --name-first=melo --name-last=night --password=Melo12345@ --admin=1 || true\n\
exec "$@"' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Environment configuration
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV CACHE_DRIVER=redis
ENV SESSION_DRIVER=redis
ENV QUEUE_CONNECTION=redis

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
