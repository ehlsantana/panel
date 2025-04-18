FROM ghcr.io/pterodactyl/panel:latest

# Install required packages
RUN apk add --no-cache nginx supervisor && \
    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor

# Configure PHP-FPM to listen on TCP port
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/;listen.allowed_clients/listen.allowed_clients/' /usr/local/etc/php-fpm.d/www.conf

# Configure Nginx
COPY <<EOF /etc/nginx/http.d/default.conf
server {
    listen 8080;
    server_name _;

    root /var/www/html/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

# Configure Supervisor
COPY <<EOF /etc/supervisor/supervisord.conf
[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:php-fpm]
command=php-fpm8 -F
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF

# Set up entrypoint
COPY <<EOF /entrypoint.sh
#!/bin/sh
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
php artisan migrate --force --seed
php artisan p:user:make --email=lamelo2410@gmail.com --username=lionel --name-first=melo --name-last=night --password=Melo12345@ --admin=1 || true
exec "$@"
EOF

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
