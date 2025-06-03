SHELL = /bin/bash
PROJECT_DIR = app
PROJECT_NAME = myapp # Explicit project name for docker-compose

# Individual Compose files (relative to PROJECT_DIR)
NETWORK_COMPOSE_FILE = docker-compose.network.yml
MYSQL_COMPOSE_FILE = docker-compose.mysql.yml
PHPMYADMIN_COMPOSE_FILE = docker-compose.phpmyadmin.yml
LOKI_COMPOSE_FILE = docker-compose.loki-stack.yml
PORTAINER_COMPOSE_FILE = docker-compose.portainer.yml

# Base docker-compose command
COMPOSE = docker-compose --project-directory $(PROJECT_DIR) --project-name $(PROJECT_NAME)

.PHONY: all up down logs clean network mysql phpmyadmin loki portainer
.DEFAULT_GOAL := help

# --- CONTROL TARGETS ---
all: up ## Start all services

up: network ## Start all services by first ensuring network is up, then services
	$(COMPOSE) -f $(MYSQL_COMPOSE_FILE) up -d
	$(COMPOSE) -f $(PHPMYADMIN_COMPOSE_FILE) up -d
	$(COMPOSE) -f $(LOKI_COMPOSE_FILE) up -d
	$(COMPOSE) -f $(PORTAINER_COMPOSE_FILE) up -d
	@echo "All services started."

down: ## Stop and remove all services and the network
	$(COMPOSE) -f $(PORTAINER_COMPOSE_FILE) down --remove-orphans
	$(COMPOSE) -f $(LOKI_COMPOSE_FILE) down --remove-orphans
	$(COMPOSE) -f $(PHPMYADMIN_COMPOSE_FILE) down --remove-orphans
	$(COMPOSE) -f $(MYSQL_COMPOSE_FILE) down --remove-orphans
	$(COMPOSE) -f $(NETWORK_COMPOSE_FILE) down --remove-orphans
	@echo "All services and network stopped."

network: ## Start the network
	$(COMPOSE) -f $(NETWORK_COMPOSE_FILE) up -d
	@echo "Network started."

# --- INDIVIDUAL SERVICE GROUPS ---
mysql: network ## Start/stop MySQL
mysql-up: network
	$(COMPOSE) -f $(MYSQL_COMPOSE_FILE) up -d
mysql-down:
	$(COMPOSE) -f $(MYSQL_COMPOSE_FILE) down --remove-orphans
mysql-logs:
	$(COMPOSE) -f $(MYSQL_COMPOSE_FILE) logs -f --tail=50

phpmyadmin: network ## Start/stop phpMyAdmin
phpmyadmin-up: network
	$(COMPOSE) -f $(PHPMYADMIN_COMPOSE_FILE) up -d
phpmyadmin-down:
	$(COMPOSE) -f $(PHPMYADMIN_COMPOSE_FILE) down --remove-orphans
phpmyadmin-logs:
	$(COMPOSE) -f $(PHPMYADMIN_COMPOSE_FILE) logs -f --tail=50

loki: network ## Start/stop Loki stack
loki-up: network
	$(COMPOSE) -f $(LOKI_COMPOSE_FILE) up -d
loki-down:
	$(COMPOSE) -f $(LOKI_COMPOSE_FILE) down --remove-orphans
loki-logs:
	$(COMPOSE) -f $(LOKI_COMPOSE_FILE) logs -f --tail=50

portainer: network ## Start/stop Portainer
portainer-up: network
	$(COMPOSE) -f $(PORTAINER_COMPOSE_FILE) up -d
portainer-down:
	$(COMPOSE) -f $(PORTAINER_COMPOSE_FILE) down --remove-orphans
portainer-logs:
	$(COMPOSE) -f $(PORTAINER_COMPOSE_FILE) logs -f --tail=50

# --- UTILITY TARGETS ---
logs: ## View logs for all running services
	$(COMPOSE) \
		-f $(NETWORK_COMPOSE_FILE) \
		-f $(MYSQL_COMPOSE_FILE) \
		-f $(PHPMYADMIN_COMPOSE_FILE) \
		-f $(LOKI_COMPOSE_FILE) \
		-f $(PORTAINER_COMPOSE_FILE) \
		logs -f --tail=100

clean: down ## Stop services, remove containers, network, and ALL VOLUMES associated with this project
	@echo "WARNING: This will remove all Docker volumes associated with project '$(PROJECT_NAME)'."
	@read -p "Are you sure? (y/N) " -n 1 -r REPLY; \
	echo ; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker volume ls -qf "name=$(PROJECT_NAME)_" | xargs -r docker volume rm; \
		echo "Project volumes removed."; \
	else \
		echo "Volume removal cancelled."; \
	fi

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_0-9-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)