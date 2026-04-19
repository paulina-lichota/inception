# Developer Documentation

## Prerequisites

Install Docker and Docker Compose on your machine:
```bash
# Linux
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# log out and back in
```

Verify installation:
```bash
docker --version
docker compose version
```

## Setup from scratch

### 1. Clone the repository
```bash
git clone https://github.com/plichota/inception.git
cd inception
```

### 2. Create the secrets files

```bash
mkdir -p secrets
echo -n "yourdbpassword" > secrets/db_password.txt
echo -n "yourrootpassword" > secrets/db_root_password.txt
echo -n "youradminpassword" > secrets/wp_admin_password.txt
echo -n "youruserpassword" > secrets/wp_user_password.txt
```
or run `make` to prepare the sample files 

### 3. Create the .env file
```bash
cp srcs/.env.example srcs/.env
```
or run `make` to prepare the sample files 

Edit `srcs/.env` with your values:

```bash
DOMAIN_NAME=plichota.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_ADMIN=superuser
WP_ADMIN_EMAIL=admin@plichota.42.fr
WP_USER=editor
WP_USER_EMAIL=editor@plichota.42.fr
```

### 4. Create the data directories
```bash
mkdir -p /home/plichota/data/wordpress
mkdir -p /home/plichota/data/db
```

or run `make` to prepare

### 5. Add the domain to /etc/hosts
```bash
echo "127.0.0.1 plichota.42.fr" | sudo tee -a /etc/hosts
```

## Build and launch
```bash

# Prepare secrets and env, create missing folders
make
# Then change the secrets and .env

# Build images and start all containers
make up

# Start in background
docker compose -f srcs/docker-compose.yml up -d --build

# View logs in real time
make logs
```


## Manage containers and volumes
```bash
# List running containers
docker ps

# Enter a container
docker exec -it mariadb sh
docker exec -it wordpress sh
docker exec -it nginx sh

# View logs of a specific container
docker logs -f mariadb
docker logs -f wordpress
docker logs -f nginx

# Stop containers (data preserved)
make down

# Rebuild a single service
docker compose -f srcs/docker-compose.yml up -d --build mariadb

# List volumes
docker volume ls

# Inspect a volume
docker volume inspect srcs_db_data

# Remove everything except volumes
make clean

# Remove everything including volumes (data is lost)
make fclean
```

## Logs
```bash
# Live logs of all containers together
make logs

# Live logs of a specific container
docker logs -f mariadb
docker logs -f wordpress
docker logs -f nginx

# Last 100 lines of logs
docker logs --tail 100 mariadb

# Logs with timestamps
docker logs -t mariadb
```

## Troubleshooting

### Check the connection between wordpress and mariadb:
```bash
docker exec -it srcs-wordpress-1 sh

nc -w 3 mariadb 3306
echo $?
```
Returns `0` if the connection is successful. If not, check the logs of the mariadb container.

## DB
inside mariadb container:
`mariadb -u root -p$(cat /run/secrets/db_root_password)`

then:
-- Mostra tutti i database
`SHOW DATABASES;`

-- Seleziona il database wordpress
`USE wordpress;`

-- Mostra tutte le tabelle
`SHOW TABLES;`

-- Mostra tutti gli utenti WordPress
`SELECT * FROM wp_users;`

-- Mostra solo username e email
`SELECT user_login, user_email FROM wp_users;`

-- Esci
`EXIT;`

# Per MariaDB

-- Mostra tutti gli utenti del database
SELECT User, Host FROM mysql.user;

-- Mostra i permessi di un utente
SHOW GRANTS FOR 'wpuser'@'%';

## Docker Compose commands
```bash
# Build and start all containers in foreground (shows logs)
docker compose -f srcs/docker-compose.yml up --build

# Build and start all containers in background
docker compose -f srcs/docker-compose.yml up -d --build

# Stop containers (data preserved)
docker compose -f srcs/docker-compose.yml down

# Stop and remove images
docker compose -f srcs/docker-compose.yml down --rmi all

# Stop and remove images and volumes (data lost)
docker compose -f srcs/docker-compose.yml down --rmi all --volumes

# Stop and remove everything including orphan containers
docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans

# Rebuild a single service without stopping the others
docker compose -f srcs/docker-compose.yml up -d --build nginx

# Check status of all services
docker compose -f srcs/docker-compose.yml ps

# Check healthcheck status
docker compose -f srcs/docker-compose.yml ps --format "table {{.Name}}\t{{.Status}}"
```

## Where data is stored and how it persists

Data is stored on the host machine using bind mounts at `/home/plichota/data/`:
```
/home/plichota/data/
├── db/          → MariaDB database files (/var/lib/mysql inside the container)
└── wordpress/   → WordPress files (/var/www/html inside the container)
```

These directories are mounted into the containers at runtime. When a container stops or is removed, the data remains on the host at these paths.

Data is lost only if you explicitly delete these directories or run `make fclean` which removes the volumes.
```bash
# Manually backup the database
docker exec mariadb mysqldump -u root -p wordpress > backup.sql

# Restore the database
docker exec -i mariadb mysql -u root -p wordpress < backup.sql
```

## Project structure
```
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/              ← not committed to git
│   ├── wp_admin_password.txt
│   ├── wp_user_password.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env              ← not committed to git
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        └── nginx/
            ├── Dockerfile
            ├── conf/
            └── tools/
```

## VM

You should use a VM to run the project.

Folder:
/goinfe/login

Distro download:
https://www.debian.org/download

### Basic settings
RAM 4GB
CPU 4
Memory 50+GB
username with your username

in Network of your VM add the port forwarding
SSH TCP 22 -> 22
HTTP TCP 80 -> 80
HTTPS TCP 443 -> 443

Then reboot

### Install git

aggiungiti al gruppo sudo se hai usermod,
`usermod -aG sudo nome_utente`
altrimenti vai di root con
`su -`

Aggiorna la VM e installa dipendenze base
`apt install ca-certificates curl gnupg lsb-release -y`
`sudo apt update`
`sudo apt upgrade -y`

install git
`sudo apt install git`

### Install docker and docker-compose

unistall older version of docker
`sudo apt remove docker docker-engine docker-compose docker.io containerd runc`
`sudo apt purge docker docker-engine docker-compose docker.io containerd runc`
`sudo apt autoremove -y`
check
`which docker`
`docker --version`

Ora seguiamo la guida
[https://docs.docker.com/engine/install/debian/]

Ora vediamo lo status con
`sudo systemctl docker status`
o in alcuni sistemi facciamo partire il daemon manualmente:
`sudo systemctl docker status`

Testa con
`sudo docker run hello-world`

### Now let's clone the repo
set ssh keys for github (42 account)
`ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`

copy the ssh key in the clipboard
`cat ~/.ssh/id_rsa.pub`

Paste into your intra account
