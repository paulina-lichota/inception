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

### 3. Create the .env file
```bash
cp srcs/.env.example srcs/.env
```

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

### 5. Add the domain to /etc/hosts
```bash
echo "127.0.0.1 plichota.42.fr" | sudo tee -a /etc/hosts
```

## Build and launch
```bash
# Build images and start all containers
make

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