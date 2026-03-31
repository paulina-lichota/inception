FROM alpine:3.22

RUN apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-json \
    php83-curl \
    php83-dom \
    php83-mbstring \
    php83-openssl \
    php83-xml \
    php83-zip \
    wget

# Installa wp-cli (non esiste apk, scarichiamo dal sito che consiglia https://wp-cli.org)
RUN wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# Crea cartella wordpress (workdir crea cartella se non esiste)
WORKDIR /var/www/html

# Copia lo script di setup dall'host al container e lo rende eseguibile (il container non vede il filesystem dell'host)
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# Porta su cui PHP-FPM ascolta
EXPOSE 9000

# Esegue lo script di setup, poi avvia PHP-FPM in foreground come PID 1
ENTRYPOINT ["/setup.sh"]
CMD ["php-fpm83", "-F"]