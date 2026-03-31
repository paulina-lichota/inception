FROM alpine:3.22

RUN apk add --no-cache mariadb mariadb-client

# Crea il file config per far ascoltare MariaDB su tutte le interfacce (default è solo localhost)
# my.cnf.d è la cartella dove MariaDB cerca i file di confi aggiuntivi
COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 3306

ENTRYPOINT ["/init.sh"]
CMD ["mysqld_safe"]