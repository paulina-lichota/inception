FROM alpine:3.22

RUN apk add --no-cache mariadb mariadb-client

# Crea il file config per far ascoltare MariaDB su tutte le interfacce (default è solo localhost)
COPY conf/bind.cnf /etc/bind.cnf.d/bind.cnf

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 3306

ENTRYPOINT ["/init.sh"]
CMD ["mysqld_safe"]