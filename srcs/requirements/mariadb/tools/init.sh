#!/bin/sh

# Inizializza il database solo se non esiste già
if [ ! -d "/var/lib/mysql/mysql" ]; then
		echo "Inizializzazione di MariaDB..."

		# Inizializza i file di sistema
		mysql_install_db --user=mysql --datadir=/var/lib/mysql

		if [ -f /run/secrets/db_root_password ]; then
			echo "Root password file trovato"
		else
			echo "Root password file NON trovato"
			exit 1
		fi

		# mysqld legge SQL da stdin
		# --bootstrap esegue in modo sincrono dal heredoc ed esce
		# NON è un daemon in background 
		# ATTENZIONE -EOF RICHIEDE TAB NO SPAZI! Controllare editor
		mysqld --user=mysql --bootstrap <<-EOF
				USE mysql;
				FLUSH PRIVILEGES;

				CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
				CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';
				GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

				ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_root_password)';

				DELETE FROM mysql.global_priv WHERE User='';
				DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
				FLUSH PRIVILEGES;
		EOF
fi

# Chiama CMD
exec "$@"
