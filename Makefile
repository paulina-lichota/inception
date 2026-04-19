DOCKER_COMPOSE_FILE = srcs/docker-compose.yml
DOCKER_COMPOSE_CMD = docker compose -f $(DOCKER_COMPOSE_FILE)

all: prepare
	@mkdir -p /home/plichota/data/db
	@mkdir -p /home/plichota/data/wordpress

up:
	$(DOCKER_COMPOSE_CMD) up --build

prepare:
	@cp srcs/.env.example srcs/.env
	@mkdir -p secrets
	@echo -n "yourdbpassword" > secrets/db_password.txt
	@echo -n "yourrootpassword" > secrets/db_root_password.txt
	@echo -n "youradminpassword" > secrets/wp_admin_password.txt
	@echo -n "youruserpassword" > secrets/wp_user_password.txt
	@echo "Files /secrets creati"
	@echo "Copia di .env creata"
	@echo "Modifica i secrets, modifica il .env e runna 'make up'"

stop:
	$(DOCKER_COMPOSE_CMD) stop

down:
	$(DOCKER_COMPOSE_CMD) down \
	--remove-orphans

restart: down up

mariadb:
	$(DOCKER_COMPOSE_CMD) exec mariadb sh

db:
	docker exec -it srcs-mariadb-1 mariadb -u root -p$$(cat /run/secrets/db_root_password)

wordpress:
	$(DOCKER_COMPOSE_CMD) exec wordpress sh

nginx:
	$(DOCKER_COMPOSE_CMD) exec nginx sh

# -f o --follow per seguire i log in tempo reale
logs:
	$(DOCKER_COMPOSE_CMD) logs -f

# Rimuove i container, le immagini buildate ma NON i volumi (i dati persistono)
# -rmi all Rimuove tutte le images buildate
# --remove-orphans Rimuove container orfani, quelli non definiti nel docker-compose.yml
clean:
	$(DOCKER_COMPOSE_CMD) down \
	--rmi all \
	--remove-orphans

# Rimuove tutte le risorse inutilizzate, inclusi container, immagini, volumi e network non utilizzati (anche non legati al progetto)
fclean: clean
	$(DOCKER_COMPOSE_CMD) down --volumes
	docker network prune --force

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  up	     - Build and start the containers"
	@echo "  stop    - Stop the containers without removing them"
	@echo "  down    - Stop and remove the containers"
	@echo "  restart - Restart the containers (without rebuilding them)"
	@echo "  logs    - Follow the logs of the containers"
	@echo "  clean   - Stop and remove containers, images, and volumes"
	@echo "  fclean  - Remove all unused Docker data"

.PHONY: all up stop down restart db mariadb wordpress nginx logs clean fclean help