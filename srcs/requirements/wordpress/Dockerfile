FROM alpine:3.22

RUN apk add --no-cache \
    php84 \
    php84-fpm \
    php84-mysqli \
    php84-json \
    php84-curl \
    php84-dom \
    php84-mbstring \
    php84-openssl \
    php84-xml \
    php84-zip \
    php84-phar \
    wget

# Symlink tra php84 e php (Alpine non ha php package, creo link simbolico da usare come comando)
RUN ln -s /usr/bin/php84 /usr/bin/php

# Installa wp-cli (non esiste apk, scarichiamo dal sito che consiglia https://wp-cli.org)
RUN wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# Crea cartella wordpress (workdir crea cartella se non esiste)
WORKDIR /var/www/html

# Copia lo script di setup dall'host al container e lo rende eseguibile (il container non vede il filesystem dell'host)
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# Aumenta memoria RAM disponibile (default 128M, WordPress consiglia almeno 256M)
# il file .ini si trova nella cartella che si crea con l'installazione di apk add php84
# RUN ln -s /usr/bin/php84 /usr/bin/php
RUN echo "memory_limit=256M" > /etc/php84/conf.d/memory.ini

# Porta su cui PHP-FPM ascolta
EXPOSE 9000

# Esegue lo script di setup, poi avvia PHP-FPM in foreground come PID 1
ENTRYPOINT ["/setup.sh"]
CMD ["php-fpm84", "-F"]