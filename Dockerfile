FROM ghcr.io/pterodactyl/panel:latest

# L'image Pterodactyl utilise déjà les permissions correctes, pas besoin de les modifier
# Éviter les commandes chown qui causent des erreurs

# Définir le répertoire de travail
WORKDIR /var/www/html

# Commande de démarrage optimisée
CMD ["/bin/sh", "-c", \
    "echo 'Initialisation du panel Pterodactyl...'; \
    sleep 15; \
    php artisan migrate --force; \
    php artisan p:user:make --email=lamelo2410@gmail.com --username=lionel --name-first=melo --name-last=night --password=Melo12345@ --admin=1 || true; \
    /usr/bin/supervisord -c /etc/supervisor/supervisord.conf"]
