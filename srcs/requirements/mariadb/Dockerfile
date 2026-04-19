FROM alpine:3.22

RUN apk add --no-cache mariadb mariadb-client && \
    mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Crea il file config per far ascoltare MariaDB su tutte le interfacce (default è solo localhost)
# my.cnf.d è la cartella dove MariaDB cerca i file di confi aggiuntivi
COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 3306

# Script di inizializzazione
# Usiamo entrypoint per essere sicuri che questo script venga 
# eseguito all'avvio del container PRIMA di lanciare il processo principale
ENTRYPOINT ["/init.sh"]

# Comando di default
# Sovrascrivibile con docker run
# Avvia il servizio vero
# mysqld diretto (non mysqld_safe): resta PID 1 in foreground
# --user=mysql per far girare il daemon come utente non-root
CMD ["mysqld", "--user=mysql"]