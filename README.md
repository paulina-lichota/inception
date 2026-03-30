## Debian vs Alpine
Alpine:
    - più leggera (5 MB)
    - usa apk (invece di apt)
    - non ha bash installato di default (usa sh)
Debian:
    - più pesante(120 MB)
    - usa apt
    - bash installato di default

## Dove vengono salvati i dati dei Docker?
- /usr                  read-only, statiici

- /var                  dati variabili, cambiano durante esecuzione
    - lib               dati persistenti delle app
        - mysql         dati specifici dell'app
        - apt/lists/*   metadati della repo
    - log               logs
    - run               file di runtime (pid, socket)
    - cache             cache (ricostruibilie, eliminabile)
    - tmp               dati temporanei (eliminati al reboot)

## Volumi vs DB
Volume = cartella sul disco dell'host, montata nel container
Quando definisci un volume, in realtà stai scrivendo in una cartella del disco dell'host.

## wp_data vs db_data
*wp_data* contiene l'installazione di Wordpress e tutti i suoi dati interni:
- /var/www/html
    - wp-admin/
    - wp-includes/
    - wp-content/
    - wp-config.php
    - index.php

*db_data* contiene i dati del db:
- /var/lib/mysql/
    - wordpress/    (il db)
        - wp_posts
        - wp_users
        - wp_options
    - mysql/    (db di sistema di maria db)