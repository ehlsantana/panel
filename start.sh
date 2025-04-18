#!/bin/bash

# Attendre que la base de données soit prête
echo "Waiting for database to be ready..."
sleep 30

# Exécuter les migrations
php artisan migrate --force

# Créer l'utilisateur admin
php artisan p:user:make \
  --email=lamelo2410@gmail.com \
  --username=lionel \
  --name-first=melo \
  --name-last=night \
  --password=Melo12345@ \
  --admin=1

# Démarrer le serveur web
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
