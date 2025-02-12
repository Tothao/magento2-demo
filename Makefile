.DEFAULT_GOAL := help
SHELL := /bin/bash

DEV_DB := hyva_compat_modules_dev7_sutunam_info
DEV_SSH := hyva-compat-modules.dev7.sutunam.info@hyva-compat-modules.dev7.sutunam.info
STAGING_DB :=
STAGING_SSH :=
PROD_DB :=
PROD_SSH :=

WARDEN_EXISTS := $(shell command -v warden 2> /dev/null)
ifdef WARDEN_EXISTS
	WARDEN := warden
	DOCKER_COMPOSE := warden env
	EXEC := $(DOCKER_COMPOSE) exec
	PHP=$(EXEC) php-fpm
endif

TAILWIND_DIR=./vendor/hyva-themes/magento2-default-theme/web/tailwind/

# Common operations
setup: bootstrap deploy ## Set up project locally and clone data from DEV environment

bootstrap: ## Set up project locally and clone data from DEV environment (without deploy command)
	@cp -rf .warden/env.php.local app/etc/env.php
	$(WARDEN) bootstrap -e dev

up: ## Create and start docker containers
	$(DOCKER_COMPOSE) up -d

down: ## Stop and remove docker containers
	$(DOCKER_COMPOSE) down

start: ## Start environment
	$(DOCKER_COMPOSE) start

stop: ## Stop the running environment
	$(DOCKER_COMPOSE) stop

composer_install: ## Run composer install
	$(PHP) composer install

deploy:
	$(PHP) bin/magento cache:flush
	$(PHP) bin/magento setup:di:compile
	$(PHP) bin/magento setup:upgrade
	$(PHP) bin/magento setup:static-content:deploy -f

sample_data_reset: ## Reset sample data
	$(PHP) bin/magento sampledata:reset

sample_data_deploy: ## Deploy sample data
	$(PHP) bin/magento sampledata:deploy

disable_2fa: ## Disable Magento_TwoFactorAuth module
	$(PHP) bin/magento module:disable Magento_TwoFactorAuth

clean: ## Clean cache, compiled files and static contents
	rm -rf generated/code/* generated/metadata/*
	rm -rf var/generation/*
	rm -rf var/page_cache/* var/view_preprocessed/* var/cache/*
	rm -rf pub/static/frontend/* pub/static/adminhtml/*

reindex: ## Reindex
	$(PHP) bin/magento indexer:reindex

# Tests
phpcs: ## Run phpcs
	$(PHP) composer run phpcs

phpstan: ## Run phpstan
	$(PHP) composer run phpstan

# Frontend
npm_install:
	$(PHP) npm install --prefix $(TAILWIND_DIR)

npm_build:
	$(PHP) npm run build --prefix $(TAILWIND_DIR)

npm_watch:
	$(PHP) npm run watch --prefix $(TAILWIND_DIR)

# Help
help: ## Display this menu
	@echo -e "\n\033[104m                                        \033[0m"
	@echo -e "\033[104;30;1m             Make Utility               \033[0m"
	@echo -e "\033[104m                                        \033[0m\n"
	@IFS=$$'\n'; for line in `grep -h -E '^[a-zA-Z_#-]+:?.*?## .*$$' $(MAKEFILE_LIST)`; do if [ "$${line:0:2}" = "##" ]; then \
	echo $$line | awk 'BEGIN {FS = "## "}; {printf "\n\033[33m%s\033[0m\n", $$2}'; else \
	echo $$line | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}'; fi; \
	done; unset IFS; \
	echo ""
