SHELL := /bin/sh

front:
	systemctl start frontend-dev

back:
	systemctl start backend-dev

admin:
	systemctl start admin-dev

app: front back admin

down:
	systemctl stop frontend-dev
	systemctl stop backend-dev
	systemctl stop admin-dev

restart: down app

minio: 
	systemctl start minio

postgres:
	systemctl start postgresql

db: minio postgres

pg_down:
	systemctl stop postgresql
	rm -rf /var/lib/postgresql/18/*

minio_down:
	systemctl stop minio
	rm -rf /var/lib/minio/*

db_down: pg_down minio_down

reboot: db_down restart db

rebuild: down db_down
	nixos-rebuild switch --flake .#dev

status:
	systemctl status frontend-dev backend-dev admin-dev minio postgresql --no-pager --lines=0

.PHONY: front back admin app down restart minio postgres db pg_down minio_down db_down reboot rebuild status