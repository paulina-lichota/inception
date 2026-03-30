FROM alpine:3.18

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

# Installa WP-CLI
RUN wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# Crea cartella wordpress
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

COPY conf/setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 9000

ENTRYPOINT ["/setup.sh"]
CMD ["php-fpm83", "-F"]