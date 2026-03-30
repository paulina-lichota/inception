FROM alpine:3.18

RUN apk add --no-cache nginx openssl gettext

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf.template /etc/nginx/nginx.conf.template
COPY tools/start.sh /etc/nginx/tools/start.sh

RUN chmod +x /etc/nginx/tools/start.sh

EXPOSE 443

CMD ["/bin/sh", "/etc/nginx/tools/start.sh"]

# -nodes significa “no DES” — non cifra la chiave privata con una passphrase.
# Necessario perché Nginx deve leggerla automaticamente all'avvio senza input umano.