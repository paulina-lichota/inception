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

## Additional Notes (written before this README)

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