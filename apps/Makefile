SHELL := /bin/bash

ENV_DEV ?= .env.dev
COMPOSE := docker compose --project-directory . -f compose.yaml -f compose.dev.yaml --env-file $(ENV_DEV)
UP := up --build --remove-orphans
RUN := run --rm
DOWN := down --remove-orphans

# UTILS

up:
	$(COMPOSE) $(UP)

lgtm:
	$(COMPOSE) $(UP) -d lgtm

# APPS LIFECYCLE

front: lgtm
	$(COMPOSE) $(UP) --watch frontend >/dev/null 2>&1 &

back: lgtm
	$(COMPOSE) $(UP) --watch backend >/dev/null 2>&1 &

admin: lgtm
	$(COMPOSE) $(UP) -d admin

app: front back admin

down:
	$(COMPOSE) $(DOWN) frontend backend admin

restart: down app

# DB LIFECYCLE

minio: lgtm
	$(COMPOSE) $(UP) -d minio
	$(COMPOSE) $(RUN) minio-init

postgres: lgtm
	$(COMPOSE) $(UP) -d postgres

db: minio postgres

vdown:
	$(COMPOSE) $(DOWN) -v

reboot: vdown app db

ps:
	docker ps

deps:
	docker plugin install grafana/loki-docker-driver:3.3.2-arm64 --alias loki --grant-all-permissions

.PHONY: lgtm front back admin app down restart minio postgres db vdown reboot all