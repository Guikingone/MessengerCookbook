DOCKER ?= docker
DOCKER-COMPOSE ?= docker-compose
APP ?= $(DOCKER-COMPOSE) exec -T php /entrypoint
RABBIT_MQ ?= $(DOCKER-COMPOSE) exec -T rabbit_mq
SYMFONY ?= $(APP) bin/console
COMPOSER ?= $(APP) composer

##
## Setup
## -----
##

.DEFAULT_GOAL := help
help: ## Show this help message
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-20s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help

install: ## Build images and install the project
install: build start vendor
.PHONY: install

build: ## Build docker images
	- cp -n docker-compose.override.yml.dist docker-compose.override.yml
	$(DOCKER-COMPOSE) build
.PHONY: build

vendor: ## Install PHP dependencies
vendor: composer.lock
	$(COMPOSER) install -n --prefer-dist
.PHONY: vendor

start: ## Start the containers
	$(DOCKER-COMPOSE) up --no-recreate -d --remove-orphans
.PHONY: start

##
## Project
## ------
##

functional-test: ## Execute PHPUnit functional tests
functional-test: phpunit.xml.dist tests
	- cp -n phpunit.xml.dist phpunit.xml
	$(APP) bin/phpunit --group=functional
.PHONY: functional-test

cli: ## Launch a shell in the app container
	$(DOCKER-COMPOSE) exec php /entrypoint sh
.PHONY: app-cli

cc: ## Clear Symfony cache
cc: var/cache
	$(SYMFONY) cache:clear --env=$(or $(ENV), dev)
.PHONY: cc

rabbit_queues: ## List RabbitMQ queues
	$(RABBIT_MQ) rabbitmqctl list_queues $(or $(QUEUE), messages)
.PHONY: rabbit_queues

messenger: ## Consume Messenger messages
	$(SYMFONY) messenger:consume-messages $(or $(TRANSPORT), amqp)
.PHONY: messenger

##
## Quality & Tools
## ---------------
##

phpstan: ## Execute PHPStan
	$(DOCKER) run --rm -v "$(PWD):/app" phpstan/phpstan analyze $(DIRECTORY) --level=$(or $(LEVEL), 7)
.PHONY: phpstan
