FROM ghcr.io/pterodactyl/panel:latest

# Installer les dépendances supplémentaires
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copier les fichiers de configuration nécessaires
COPY --chown=www-data:www-data . /var/www/html

# Définir le répertoire de travail
WORKDIR /var/www/html

# Configurer les permissions
RUN chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache

# Commande de démarrage
CMD ["/bin/bash", "-c", \
    "sleep 20 && \
    php artisan migrate --force && \
    php artisan p:user:make --email=lamelo2410@gmail.com --username=lionel --name-first=melo --name-last=night --password=Melo12345@ --admin=1 && \
    /usr/bin/supervisord -c /etc/supervisor/supervisord.conf"]
