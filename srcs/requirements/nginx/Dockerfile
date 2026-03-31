FROM alpine:3.22

# Installa nginx, openssl per il certificato TLS, gettext per envsubst
RUN apk add --no-cache nginx openssl gettext

# Crea la cartella per i certificati SSL
RUN mkdir -p /etc/nginx/ssl

# Copia il template della config e lo script di avvio
COPY conf/nginx.conf.template /etc/nginx/nginx.conf.template
COPY tools/start.sh /etc/nginx/tools/start.sh

# Rende lo script eseguibile
RUN chmod +x /etc/nginx/tools/start.sh

# Porta HTTPS
EXPOSE 443

# Avvia lo script che genera il certificato, la config e poi nginx
# Usiamo uno script perchè abbiamo usato DOMAIN_NAME nella config
# Ma il .env viene letto solo a runtime, quindi risulterebbe vuoto
# Durante la build le variabili d'ambiente del container non esistono ancora
# Non possiamo iniettare roba dal .env a build time, non esiste ancora il container
CMD ["/bin/sh", "/etc/nginx/tools/start.sh"]

# -nodes significa “no DES” — non cifra la chiave privata con una passphrase.
# Necessario perché Nginx deve leggerla automaticamente all'avvio senza input umano.