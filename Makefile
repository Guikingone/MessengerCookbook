DOCKER ?= docker
DOCKER-COMPOSE ?= docker-compose
APP ?= $(DOCKER-COMPOSE) exec -T php /entrypoint
RABBIT_MQ ?= $(DOCKER-COMPOSE) exec -T rabbit_mq
SYMFONY ?= $(APP) bin/console
COMPOSER ?= $(APP) composer

# Docker

install: build start vendor

.PHONY: install

build:
	- cp -n docker-compose.override.yml.dist docker-compose.override.yml
	$(DOCKER-COMPOSE) build

start:
	$(DOCKER-COMPOSE) up --no-recreate -d

# Project

vendor: composer.lock
	$(COMPOSER) install -n --prefer-dist

functional-test: phpunit.xml.dist tests
	- cp -n phpunit.xml.dist phpunit.xml
	$(APP) bin/phpunit --group=functional

# Quality & Tools

app-cli:
	$(APP) sh

cc: var/cache
	$(SYMFONY) cache:clear

rabbit_queues:
	$(RABBIT_MQ) rabbitmqctl list_queues $(or $(QUEUE), messages)

messenger:
	$(SYMFONY) messenger:consume-messages $(or $(TRANSPORT), amqp)

phpstan:
	$(DOCKER) run --rm -v "$(PWD):/app" phpstan/phpstan analyze $(DIRECTORY) --level=$(or $(LEVEL), 7)

.PHONY: cc phpstan
