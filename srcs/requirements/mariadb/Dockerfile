FROM alpine:3.22

RUN apk add --no-cache mariadb mariadb-client

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 3306

ENTRYPOINT ["/init.sh"]
CMD ["mysqld_safe"]