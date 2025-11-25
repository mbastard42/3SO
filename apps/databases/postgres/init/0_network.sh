#!/bin/bash
set -e

# Use PGDATA provided by the Postgres/pgvector image instead of hardcoding the path.
: "${PGDATA:?PGDATA is not set}"

HBA_FILE="$PGDATA/pg_hba.conf"

echo "0_network.sh: using PGDATA=$PGDATA"
echo "0_network.sh: target pg_hba.conf = $HBA_FILE"

# Resolve container IPs 
BACK_IP=$(getent hosts backend | awk '{ print $1 }' || true)
ADMIN_IP=$(getent hosts admin | awk '{ print $1 }' || true)

{
  echo ""
  echo "# Added by 0_network.sh to allow backend and admin to connect"
  if [ -n "$BACK_IP" ]; then
    echo "host    all             all             ${BACK_IP}/32           trust"
  else
    echo "# backend IP not found at init time"
  fi
  if [ -n "$ADMIN_IP" ]; then
    echo "host    all             all             ${ADMIN_IP}/32           trust"
  else
    echo "# admin IP not found at init time"
  fi
} >> "$HBA_FILE"