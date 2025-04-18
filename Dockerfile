FROM ghcr.io/pterodactyl/panel:latest

# Install required packages
RUN apk add --no-cache nginx supervisor bash

# Create necessary directories
RUN mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /etc/supervisor/conf.d

# Create supervisor config using printf to avoid echo issues
RUN printf '[supervisord]\nnodaemon=true\n\n[program:nginx]\ncommand=nginx -g "daemon off;"\nautostart=true\nautorestart=true\n\n[program:php-fpm]\ncommand=php-fpm8 -F\nautostart=true\nautorestart=true\n' > /etc/supervisor/supervisord.conf

# Create entrypoint script using printf
RUN printf '#!/bin/sh\n\n# Set permissions\nchown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache\n\n# Run migrations\nphp artisan migrate --force\n\n# Create admin user\nphp artisan p:user:make --email=lamelo2410@gmail.com --username=lionel --name-first=melo --name-last=night --password=Melo12345@ --admin=1 || true\n\n# Start supervisor\nexec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf\n' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Configure PHP-FPM to listen correctly
RUN sed -i 's/listen = .*/listen = 9000/' /usr/local/etc/php-fpm.d/www.conf

# Set working directory
WORKDIR /var/www/html

ENTRYPOINT ["/entrypoint.sh"]
