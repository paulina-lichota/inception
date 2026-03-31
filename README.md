This project has been created as part of the 42 curriculum by _The Learning Alchemist 🧠🔮 plichota_.

# Inception

## Description

You will dive into system admininistration and infrastructure engineering.
The goal of this project is to set up a small infrastructure composed of multiple services running in Docker containers inside a virtual machine.

The infrastructure consists of:
- An **Nginx** container (the only entrypoint), serving HTTPS on port 443 with TLSv1.2 or TLSv1.3
- A **WordPress** container using PHP-FPM and serving HTTPS on port 9000
- A **MariaDB** container, the database, running on port 3306

All containers are built from scratch using custom Dockerfiles based on Alpine Linux (but Debian is also allowed), without using any pre-built images from Docker Hub (except for the Alpine or Debian ones).

## Project Description

### How Docker is used

Each service runs in its own dedicated container, built from a custom Dockerfile. The containers communicate through a dedicated Docker network called `inception`.
Data is persisted using bind mounts on the host machine at `/home/plichota/data`. (as accorded to the subject)

### Design choices

**Virtual Machines vs Docker**

A VM virtualizes hardware.
Each VM has its own kernel, drivers, and OS running on top of a hypervisor.
This provides strong isolation but with significant overhead in terms of resources and startup time.

> A hypervisor is an astraction layer between the host and the guest operating systems.
> It allows the guest to run multiple operating systems at the same time, and to run them on different hardware.

Docker uses the host kernel directly.
Containers are isolated using Linux kernel features:
- namespaces: PID for processes, NET for network, MNT for filesystem isolation
- cgroups (resource limits).
- file system (mounts, volumes)
This makes containers much lighter and faster to start, at the cost of slightly weaker isolation since the kernel is shared.

In this project, Docker runs inside a VM, adding a security layer while keeping the benefits of containerization.

**Secrets vs Environment Variables**

Environment variables (`.env`) are convenient but less secure. They are visible via `docker inspect` and can be accidentally logged or exposed.

Docker Secrets are mounted as files in `/run/secrets/` inside the container, stored in memory (tmpfs), and not visible via `docker inspect`. They are the recommended way to handle sensitive data like passwords.

In this project: non-sensitive configuration (domain name, usernames, database name) goes in `.env`. Passwords go in `secrets/`.

**Docker Network vs Host Network**

With `network: host`, the container shares the host's network stack directly: no isolation, no NAT. The container can see all host interfaces and ports.

With a Docker `bridge` network, containers get their own isolated network. TDocker creates a private virtual network that only the containers inside it can see. Each container gets its own IP, and Docker handles internal DNS so they can reach each other by service name (e.g. `mariadb:3306`). From the outside, the network is completely invisible.

In this project, a custom bridge network called `inception` is used. Only Nginx exposes port 443 to the outside. MariaDB and WordPress are only reachable internally.

> `network: host`   → container lives on the host network, no isolation
> `network:bridge`  → container lives in a private network, only exposed ports are reachable from outside

**Docker Volumes vs Bind Mounts**

Without volumes, the data is stored in the writeable layer of the container filesystem (OverlayFS).
This layer is temporary and is discarded when the container is stopped.

Docker Volumes are managed entirely by Docker. Data is stored in `/var/lib/docker/volumes/`. They are portable and independent of the host's directory structure.

Bind Mounts link a specific host directory to a container path. They depend on the exact path existing on the host, but allow direct access to files from outside the container.

The subject requires bind mounts at `/home/plichota/data` where WordPress data and MariaDB data are persisted.

> No volume      →  writeable layer OverlayFS   →  it disappears with `docker rm`
> Docker Volume  →  /var/lib/docker/volumes/    →  persists, managed by Docker
> Bind Mount     →  /home/plichota/data/db      →  persists, you decide the path

### Build time vs Runtime

During the build, Docker reads the Dockerfile and executes the commands.
At that point it knows nothing about `docker-compose.yml` and therefore nothing about `.env`.
Variables don't exist yet: if you try to use them Docker substitutes them with an empty value.

Same problem for the SSL certificate, where `DOMAIN_NAME` is used in the `-subj` flag.

This is why `tools/start.sh` exists. Docker can't read `.env`,
it's `docker compose` that reads it, injects the variables, and starts the containers.
But docker compose only intervenes at runtime. The build ends exactly when Docker finishes executing the last command in the Dockerfile.

> `CMD` is not executed during the build. It's an instruction the container carries
> with it and uses only at runtime to know which process to start as PID 1.

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- Add the domain to `/etc/hosts`:
```
  127.0.0.1 plichota.42.fr
```
- Create the data directories:
```bash
  mkdir -p /home/plichota/data/wordpress
  mkdir -p /home/plichota/data/db
```
- Create the secrets files:
```bash
  echo -n "yourpassword" > secrets/db_password.txt
  echo -n "yourrootpassword" > secrets/db_root_password.txt
  echo -n "youradminpassword" > secrets/credentials.txt
```
- Create `srcs/.env` with your configuration (see `srcs/.env.example`)

### Run
```bash
# Build and start all containers
make all

# Stop containers
make down

# View logs (follow the logs of the containers)
make logs

# Full reset (remove all containers, images, volumes, networks)
make fclean
```

> use `make help` to see all available targets

### Access

- Website: `https://plichota.42.fr`
- WordPress admin: `https://plichota.42.fr/wp-admin`

## Resources

### Documentation
- [Docker official documentation](https://docs.docker.com)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Nginx documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [WordPress CLI documentation](https://wp-cli.org/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)
- [OpenSSL documentation](https://www.openssl.org/docs/)

### How AI was used

Claude (Anthropic) was used throughout this project for:
- Understanding Docker concepts (namespaces, cgroups, OverlayFS)
- Learning the differences between VMs and containers
- Structuring the project according to the subject requirements
- Writing parts of the Dockerfiles, docker-compose.yml, and shell scripts
- Reviewing and testing the Dockerfiles, docker-compose.yml, and shell scripts
- Understanding networking, volumes, and secrets in Docker

All AI-generated content was reviewed, tested, and fully understood before being included in the project (this line included).


## 🇮🇹 Additional Notes (written before this README)

### Debian vs Alpine
Alpine:
    - lighter (5 MB)
    - uses apk (instead of apt)
    - bash not installed (uses sh)
Debian:
    - heavy (120 MB)
    - uses apt
    - bash by default

### Dove vengono salvati i dati dei Docker?
- /usr                  read-only, statiici

- /var                  dati variabili, cambiano durante esecuzione
    - lib               dati persistenti delle app
        - mysql         dati specifici dell'app
        - apt/lists/*   metadati della repo
    - log               logs
    - run               file di runtime (pid, socket)
    - cache             cache (ricostruibilie, eliminabile)
    - tmp               dati temporanei (eliminati al reboot)

### Volumi vs DB
Volume = cartella sul disco dell'host, montata nel container
Quando definisci un volume, in realtà stai scrivendo in una cartella del disco dell'host.

### wp_data vs db_data
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


### Porte standard
- 80: http -> non devo usare (da subject)
- 443: https
- 9000: php-fpm
- 3306: mysql/mariadb

## Flusso iniezione variabili nel Dockerfile dentro nginx usando template + script

### Preambolo
Ho voluto creare un DOMAIN_NAME per il template di nginx (because why not?).
Cambiare una variabile in un punto solo, invece di andarsela a cercare in una moltitudine di punti, mi pare più elegante. E anche se non lo fosse, rimane comunque un soddisfacente pavoneggiamento ingegneristico.

### Come funziona?
Durante la build, Docker legge Dockerfile ed esegue i comandi. E basta.
In quel momento non sa niente di docker-compose.yml e quindi nemmeno di .env. Le varibili non esistono ancora, Docker non le vede. Se lo sostituisce, lo fa con un valore vuoto.

Stessa cosa per il certificato SSL, nel punto in cui uso DOMAIN_NAME.

### Perchè serve script?
Docker non può leggere .env.
E' il `docker compose` che legge .env, inietta le variabili e avvia i container. Ma il docker-compose interviene solo in run time. La build finisce esattamente quando Docker finisce di eseguire l'ultimo comando del Dockerfile.

> CMD e' un metadato, non viene eseguito durante la build. E' un'istruzione che il container si porta dietro fino a runtime per sapere quale processo avviare come PID 1.

docker compose up
    ↓
Docker legge .env
    ↓
Crea il container con le variabili d'ambiente già impostate
    ↓
Avvia CMD → start.sh
    ↓
start.sh trova DOMAIN_NAME già disponibile come variabile d'ambiente
    ↓
envsubst e openssl la usano correttamente

## ENTRYPOINT vs CMD

CMD: "usa questo comando, se nessun altro comando è specificato"
> puoi sovrascrivere lo script dall'esterno con `docker run image altro_comando`

ENTRYPOINT: "usa questo comando, punto."

Esempio concreto:
Stai debuggando e vuoi entrare dentro il container Wordpress senza che setup.sh parta. Lanci
`docker run wordpress sh`
Con CMD entra in sh invece che far partire setup.sh.
Con ENTRYPOINT parte sempre. Per entrare in sh devi usare
`docker run --entrypoint sh wordpress`
Parte sempre, ma è più comodo usare CMD.

> ENTRYPOINT esiste per un caso specifico: quando il container deve comportarsi come un eseguibile. (Quando vuoi usare il container come se fosse un programma installato sul tuo sistema)

I motivi per usare ENTRYPOINT sono diversi:
- **Compatibilità** — hai bisogno di una versione specifica di un tool che non è disponibile sul tuo sistema o che confligge con altra roba installata
- **Ambienti puliti** — vuoi eseguire qualcosa senza sporcare il tuo sistema con dipendenze
- **CI/CD** — nei pipeline di build e test ogni tool gira nel suo container, la macchina di build non ha niente installato
- **Distribuzione** — invece di dire agli utenti "installa python 3.9, poi installa queste 20 dipendenze", gli dai un container che funziona già


Noi lo usiamo con MariaDB per il patter **init+daemon**.
1. Uno script di inizializzazione che prepara l'ambiente
2. Un daemon che gira in foreground come PID 1

### Pattern init + daemon
È un pattern comune per i container che hanno bisogno di configurarsi prima di avviare il processo principale. Lo trovi spesso con database — MariaDB, PostgreSQL, MySQL — perché devono inizializzare il filesystem del database, creare utenti, impostare password prima di poter accettare connessioni.

Con ENTRYPOINT + CMD è elegante:
`init.sh` fa il lavoro sporco
`exec "$@"` passa il controllo a mysqld_safe
`mysqld_safe` diventa PID 1 e gira per sempre

Senza questo pattern dovresti mettere tutto dentro un unico script (init + avvio del daemon). Funziona uguale ma è meno separato e meno flessibile.


## Alpine e MariaDB
Alpine installa installa MariaDB con un file config con skip-networking di default, quindi non accetta connessioni TCP da altri container. Devi sovrascrivere quel file.

Da dentro il container di MariaDB:
`cat /etc/my.cnf.d/mariadb-server.cnf`

Devo sovrascrivere quel file. (anche nel Dockerfile)
`COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf`

[mysqld] → letto solo dal daemon standalone (il nostro caso)
# Abilita connessioni TCP/IP
skip-networking=OFF
# Ascolta su tutte le interfacce
bind-address=0.0.0.0


## Wordpress PHP-FPM
Come se non bastasse, WordPress non accetta connessioni TCP da altri container. Devi sovrascrivere il file di configurazione di PHP-FPM.
Il problema è PHP-FPM ascolta solo su localhost (127.0.0.1:9000) invece che su tutte le interfacce (0.0.0.0:9000).

`cat /etc/php84/php-fpm.conf`

Devo sovrascrivere quel file. (anche nel Dockerfile)
`COPY conf/www.conf /etc/php84/php-fpm.d/www.conf`

[www]
user = nobody
group = nobody
listen = 0.0.0.0:9000
listen.owner = nobody
listen.group = nobody
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3