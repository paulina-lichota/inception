#!/bin/sh

set -e

DATADIR="/var/lib/mysql"

# Inizializza il database solo se non esiste già
if [ ! -d "$DATADIR/mysql" ]; then
    echo "Inizializzazione di MariaDB..."

    # Inizializza i file di sistema
    mysql_install_db --user=mysql --datadir="$DATADIR" > /dev/null

    # Legge i secret
    DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
    DB_PASSWORD=$(cat /run/secrets/db_password)

    mysql -u root <<EOF
      CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
      CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';
      GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
      SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$(cat /run/secrets/db_root_password)');
      DELETE FROM mysql.user WHERE User='';
      DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
      FLUSH PRIVILEGES;
      EOF

    mysqladmin -u root shutdown
    sleep 5

fi

# Chiama CMD
exec "$@"
