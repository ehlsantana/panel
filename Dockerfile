FROM ghcr.io/pterodactyl/panel:latest

# L'image de base utilise Alpine Linux, donc on utilise apk au lieu de apt
RUN apk update && apk add --no-cache \
    curl \
    bash \
    && rm -rf /var/cache/apk/*

# Copier les fichiers nécessaires
COPY --chown=www-data:www-data . /var/www/html

# Définir le répertoire de travail
WORKDIR /var/www/html

# Configurer les permissions
RUN chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache

# Commande de démarrage optimisée
CMD ["/bin/bash", "-c", \
    "echo 'En attente du démarrage de la base de données...'; \
    sleep 30; \
    php artisan migrate --force; \
    php artisan p:user:make --email=lamelo2410@gmail.com --username=lionel --name-first=melo --name-last=night --password=Melo12345@ --admin=1; \
    /usr/bin/supervisord -c /etc/supervisor/supervisord.conf"]
