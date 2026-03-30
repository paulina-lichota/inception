
all: up

up:
	docker compose up --build

stop:
	docker compose stop

down:
	docker compose down \
	--remove-orphans

restart: down all

mariadb:
	docker compose exec -it mariadb bash 		# -it per interagire con il terminale del container, bash per accedere alla shell del container

wordpress:
	docker compose exec -it wordpress bash

nginx:
	docker compose exec -it nginx bash

logs:
	docker compose logs -f		# -f o --follow per seguire i log in tempo reale

# Rimuove i container, le immagini buildate e i volumi associati
clean:
	docker compose down \
	--rmi all \					# Rimuove tutte le images buildate
	--volumes \					# Rimuove i volumi associati ai container
	--remove-orphans 			# Rimuove container orfani, quelli non definiti nel docker-compose.yml

# Rimuove tutte le risorse inutilizzate, inclusi container, immagini, volumi e network non utilizzati
fclean:
	docker system prune -f

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

.PHONY: all stop down restart logs clean fclean help