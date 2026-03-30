#!/bin/sh

# Scarica WordPress se non esiste già
if [ ! -f "/var/www/html/wp-config.php" ]; then
    wget -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
    tar -xzf /tmp/wordpress.tar.gz -C /tmp
    mv /tmp/wordpress/* /var/www/html/
    rm -rf /tmp/wordpress.tar.gz /tmp/wordpress

    # Configura wp-config.php
    wp config create \
        --path=/var/www/html \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb \
        --allow-root

    # Installa WordPress
    wp core install \
        --path=/var/www/html \
        --url=https://${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_ADMIN} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    # Crea utente aggiuntivo
    wp user create \
        ${WP_USER} ${WP_USER_EMAIL} \
        --role=subscriber \
        --user_pass=${WP_USER_PASSWORD} \
        --allow-root
fi

exec "$@"
```

Aggiungi al `.env`:
```
WP_ADMIN=admin
WP_ADMIN_PASSWORD=adminpass
WP_ADMIN_EMAIL=admin@login.42.fr
WP_USER=user
WP_USER_PASSWORD=userpass
WP_USER_EMAIL=user@login.42.fr