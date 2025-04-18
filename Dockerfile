FROM ghcr.io/pterodactyl/panel:latest

# Install Nginx & Supervisor
RUN apk add --no-cache nginx supervisor

# Fix PHP-FPM to work with Nginx
RUN sed -i 's/;listen.owner = www-data/listen.owner = www-data/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/;listen.group = www-data/listen.group = www-data/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/' /usr/local/etc/php-fpm.d/www.conf

# Configure Nginx
RUN rm /etc/nginx/http.d/default.conf && \
    echo -e 'server {\n\
    listen 8080;\n\
    server_name _;\n\
    root /var/www/html/public;\n\
    index index.php;\n\
    location / {\n\
        try_files \$uri \$uri/ /index.php?\$query_string;\n\
    }\n\
    location ~ \.php$ {\n\
        fastcgi_pass 127.0.0.1:9000;\n\
        fastcgi_index index.php;\n\
        include fastcgi_params;\n\
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n\
    }\n\
}' > /etc/nginx/http.d/panel.conf

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Start services via Supervisor
RUN echo -e '[supervisord]\n\
nodaemon=true\n\
[program:nginx]\n\
command=nginx -g "daemon off;"\n\
autorestart=true\n\
[program:php-fpm]\n\
command=php-fpm8 -F\n\
autorestart=true' > /etc/supervisor/supervisord.conf

# Entrypoint
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
