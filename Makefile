
DOCKER_COMPOSE = srcs/docker-compose.yml

all: up

up:
	docker compose -f $(DOCKER_COMPOSE) up --build

stop:
	docker compose -f $(DOCKER_COMPOSE) stop

down:
	docker compose -f $(DOCKER_COMPOSE) down \
	--remove-orphans

restart: down up

mariadb:
	docker compose -f $(DOCKER_COMPOSE) exec mariadb sh

wordpress:
	docker compose -f $(DOCKER_COMPOSE) exec wordpress sh

nginx:
	docker compose -f $(DOCKER_COMPOSE) exec nginx sh

# -f o --follow per seguire i log in tempo reale
logs:
	docker compose -f $(DOCKER_COMPOSE) logs -f

# Rimuove i container, le immagini buildate ma NON i volumi (i dati persistono)
clean:
	docker compose -f $(DOCKER_COMPOSE) down \
	--rmi all \					# Rimuove tutte le images buildate
	--remove-orphans 			# Rimuove container orfani, quelli non definiti nel docker-compose.yml

# Rimuove tutte le risorse inutilizzate, inclusi container, immagini, volumi e network non utilizzati (anche non legati al progetto)
fclean: clean
	docker compose -f $(DOCKER_COMPOSE) down --volumes
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

.PHONY: all up stop down restart mariadb wordpress nginx logs clean fclean help 