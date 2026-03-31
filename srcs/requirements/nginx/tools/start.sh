#!/bin/sh

# Se non avessi fatto la pignola col DOMAIN_NAME, avrei potuto mettere tutto di là eh (nel Dockerfile)

# Genera il certificato SSL self-signed
openssl req -x509 -newkey rsa:4096 \
    -keyout /etc/nginx/ssl/key.pem \
    -out /etc/nginx/ssl/cert.pem \
    -days 365 -nodes \
    -subj "/CN=${DOMAIN_NAME}"

# Sostituisce DOMAIN_NAME nel template e genera nginx.conf
envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Avvia nginx in foreground come PID 1
nginx -g 'daemon off;'