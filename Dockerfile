FROM ghcr.io/pterodactyl/panel:latest

# Configuration spécifique pour Render
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV CACHE_DRIVER=redis
ENV SESSION_DRIVER=redis
ENV QUEUE_CONNECTION=redis

# Création directe de l'utilisateur admin dans l'entrypoint
RUN echo -e '#!/bin/sh\n\
php artisan migrate --force\n\
php artisan p:user:make --email=lamelo2410@gmail.com --username=lionel --name-first=melo --name-last=night --password=Melo12345@ --admin=1 || true\n\
exec "$@"' > /entrypoint.sh \
&& chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
