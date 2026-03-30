FROM alpine:3.18

RUN apk add --no-cache nginx openssl

# Genera certificato self-signed
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -newkey rsa:4096 \
    -keyout /etc/nginx/ssl/key.pem \
    -out /etc/nginx/ssl/cert.pem \
    -days 365 -nodes \
    -subj "/CN=${DOMAIN_NAME}"

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/www/html

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

# -nodes significa “no DES” — non cifra la chiave privata con una passphrase.
# Necessario perché Nginx deve leggerla automaticamente all'avvio senza input umano.