#!/bin/sh

# Inizializza il database solo se non esiste già
if [ ! -d "/var/lib/mysql/mysql" ]; then

    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    mysqld_safe --skip-networking &
    sleep 3

    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$(cat /run/secrets/db_root_password)');
FLUSH PRIVILEGES;
EOF

    mysqladmin -u root shutdown
    sleep 5

fi

exec "$@"