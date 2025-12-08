SHELL := /bin/sh

server:
	systemctl start server

front:
	systemctl start frontend-dev

back:
	systemctl start backend-dev

admin:
	systemctl start admin-dev

app: server front back admin

down:
	systemctl stop server || true
	systemctl stop frontend-dev || true
	systemctl stop backend-dev || true
	systemctl stop admin-dev || true

restart: down app

minio: 
	systemctl start minio

postgres:
	systemctl start postgresql

db: minio postgres

pg_down:
	systemctl stop postgresql || true
	rm -rf /var/lib/postgresql/18/*

minio_down:
	systemctl stop minio || true
	rm -rf /var/lib/minio/*

db_down: pg_down minio_down

reboot: db_down restart db

dev:
	nixos-rebuild switch --flake .#dev

preprod:
	nixos-rebuild switch --flake .#preprod

rebuild: down db_down
	
status:
	systemctl status frontend-dev backend-dev admin-dev minio postgresql --no-pager --lines=0

.PHONY: front back admin app down restart minio postgres db pg_down minio_down db_down reboot dev preprod rebuild status