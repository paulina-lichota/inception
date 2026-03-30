# User documentation

## What is this project?

This project runs a WordPress website using three services:

- **Nginx** — handles all incoming HTTPS traffic on port 443 and forwards requests to WordPress
- **WordPress** — the web application, running with PHP-FPM
- **MariaDB** — the database that stores all WordPress data (posts, users, settings)

## Start and stop the project
```bash
# Start everything
make

# Stop everything (data is preserved)
make down

# Restart everything
make re
```

## Access the website

Add this line to your `/etc/hosts` file:
```
127.0.0.1 plichota.42.fr
```
or run

```bash
echo -n "plichota.42.fr" > /etc/hostname
```

Then open your browser and go to:
- **Website** → `https://plichota.42.fr`
- **Admin panel** → `https://plichota.42.fr/wp-admin`

Your browser will show a security warning because the SSL certificate is self-signed — click "Advanced" and proceed anyway.


## Credentials

All credentials are stored in the `secrets/` folder at the root of the project:

| File                           | Contains                  |
|--------------------------------|---------------------------|
| `secrets/db_password.txt`      | MariaDB user password     |
| `secrets/db_root_password.txt` | MariaDB root password     |
| `secrets/credentials.txt`      | WordPress admin password  |

Non-sensitive configuration (usernames, domain, database name) is in `srcs/.env`.

**Never commit these files to git.**

---

## Check that services are running
```bash
# See all running containers and their status
docker ps

# See live logs of all containers
make logs

# See logs of a specific container
docker logs mariadb
docker logs wordpress
docker logs nginx

# Enter a container
docker exec -it mariadb sh
docker exec -it wordpress sh
docker exec -it nginx sh
```

All three containers should show `Up` in `docker ps`. If one shows `Restarting`, check its logs to find the error.