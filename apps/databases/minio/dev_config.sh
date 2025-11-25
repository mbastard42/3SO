#!/bin/sh

set -e

minio "$@" &
MINIO_PID=$!
sleep 3

ENDPOINT="${MINIO_ENDPOINT}"
BUCKET="${MINIO_BUCKET}"
ROOT_USER="${MINIO_ROOT_USER}"
ROOT_PASSWORD="${MINIO_ROOT_PASSWORD}"

mc alias set local "$ENDPOINT" "$ROOT_USER" "$ROOT_PASSWORD"
mc mb --ignore-existing "local/$BUCKET"
mc anonymous set private "local/$BUCKET"

wait $MINIO_PID