DOCKER ?= docker
DOCKER-COMPOSE ?= docker-compose
APP ?= $(DOCKER-COMPOSE) exec -T php /entrypoint
SYMFONY ?= $(APP) bin/console
COMPOSER ?= $(APP) composer

# Docker

install: build start vendor

.PHONY: install

build:
	- cp docker-compose.override.yml.dist docker-compose.override.yml
	$(DOCKER-COMPOSE) build

start:
	$(DOCKER-COMPOSE) up --no-recreate -d

# Project

vendor: composer.lock
	$(COMPOSER) install -n --prefer-dist

# Quality & Tools

phpstan:
	$(DOCKER) run --rm -v "$(PWD):/app" phpstan/phpstan analyze $(DIRECTORY) --level=$(or, $(LEVEL), 7)
