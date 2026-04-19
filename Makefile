DOCKER_COMPOSE_FILE = srcs/docker-compose.yml
COMPOSE = docker compose -f $(DOCKER_COMPOSE_FILE)
LOGIN = plichota
DATA_DIR = /home/$(LOGIN)/data

all: prepare dirs up

# Crea secret ed env solo se mancano
prepare:
	@mkdir -p secrets
	@[ -f srcs/.env ] || cp srcs/.env.example srcs/.env
	@[ -f secrets/db_password.txt ]       || openssl rand -base64 24 | tr -d '\n' > secrets/db_password.txt
	@[ -f secrets/db_root_password.txt ]  || openssl rand -base64 24 | tr -d '\n' > secrets/db_root_password.txt
	@[ -f secrets/wp_admin_password.txt ] || openssl rand -base64 24 | tr -d '\n' > secrets/wp_admin_password.txt
	@[ -f secrets/wp_user_password.txt ]  || openssl rand -base64 24 | tr -d '\n' > secrets/wp_user_password.txt
	@echo "Secrets ed .env pronti. Modifica srcs/.env se necessario."

dirs:
	@mkdir -p $(DATA_DIR)/db
	@mkdir -p $(DATA_DIR)/wordpress

# build e avvio in background
up: dirs
	$(COMPOSE) up -d --build

stop:
	$(COMPOSE) stop

# Stop + rimozione container
down:
	$(COMPOSE) down \
	--remove-orphans

restart: down up

# Logs di tutti i container
logs:
	$(COMPOSE) logs -f

# Shell dentro i container
sh-mariadb:
	$(COMPOSE) exec mariadb sh

sh-wordpress:
	$(COMPOSE) exec wordpress sh

sh-nginx:
	$(COMPOSE) exec nginx sh

db:
	$(COMPOSE) exec mariadb sh -c 'mariadb -u root -p"$$(cat /run/secrets/db_root_password)"'

# -f o --follow per seguire i log in tempo reale
logs:
	$(COMPOSE) logs -f

# Rimuove container, immagini e volumi Docker (non la dir host)
clean:
	$(COMPOSE) down \
	--rmi all \
	--remove-orphans

# elimina anche i dati persistenti sull'host
fclean: clean
	@sudo rm -rf $(DATA_DIR)/db/*
	@sudo rm -rf $(DATA_DIR)/wordpress/*
	@docker system prune -af
	@echo "Pulizia completa"

re: fclean all

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "  (default)    - prepare + dirs + up"
	@echo "  prepare      - Crea .env e secrets se mancanti"
	@echo "  up           - Build e avvio containers"
	@echo "  stop         - Ferma i container senza rimuoverli"
	@echo "  down         - Ferma e rimuove i container"
	@echo "  restart      - Riavvia (senza rebuild)"
	@echo "  re           - fclean + all"
	@echo "  logs         - Segue i log in tempo reale"
	@echo "  db           - Entra nella shell MariaDB come root"
	@echo "  sh-mariadb   - Shell dentro il container mariadb"
	@echo "  sh-wordpress - Shell dentro il container wordpress"
	@echo "  sh-nginx     - Shell dentro il container nginx"
	@echo "  clean        - Rimuove container, immagini, volumi Docker"
	@echo "  fclean       - clean + elimina dati persistenti su host"

.PHONY: all prepare dirs up stop down restart re logs db \
        sh-mariadb sh-wordpress sh-nginx clean fclean help