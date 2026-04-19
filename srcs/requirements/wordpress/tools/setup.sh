#!/bin/sh

# Scarica WordPress solo se non è già installato
if [ ! -f "/var/www/html/wp-config.php" ]; then

    # Scarica WordPress o notifica se fallisce
    wp core download --path=/var/www/html --allow-root || { echo "WordPress download failed"; exit 1; }


    # Crea wp-config.php con le credenziali del database
    wp config create \
        --path=/var/www/html \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=$(cat /run/secrets/db_password) \
        --dbhost=mariadb \
        --allow-root

    # Installa WordPress
    wp core install \
        --path=/var/www/html \
        --url=https://${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_ADMIN} \
        --admin_password=$(cat /run/secrets/wp_admin_password) \
        --admin_email=${WP_ADMIN_EMAIL} \
        --skip-email \
        --allow-root

    # Crea utente aggiuntivo richiesto dal subject
    wp user create \
        ${WP_USER} ${WP_USER_EMAIL} \
        --role=subscriber \
        --user_pass=$(cat /run/secrets/wp_user_password) \
        --allow-root

fi

exec "$@"