#!/usr/bin/env bash
set -e

echo "1_databases_and_users.sh: Initializing users & databases..."


#----------------------------------------------------------
# 1. CREATE ROLES (safe inside DO $$)
#----------------------------------------------------------
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL

DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${PG_ODOO_USER}') THEN
    CREATE ROLE ${PG_ODOO_USER} LOGIN PASSWORD '${PG_ODOO_PASSWORD}';
  END IF;

  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${PG_SYMFONY_USER}') THEN
    CREATE ROLE ${PG_SYMFONY_USER} LOGIN PASSWORD '${PG_SYMFONY_PASSWORD}';
  END IF;
END
\$\$;

EOSQL

#----------------------------------------------------------
# 2. CREATE DATABASES (must be *outside* DO $$ blocks)
#----------------------------------------------------------

# truth (odoo)
DB_EXISTS=$(psql --username "$POSTGRES_USER" --dbname "postgres" -tAc \
  "SELECT 1 FROM pg_database WHERE datname='${PG_ODOO_DB}'")

if [ "$DB_EXISTS" != "1" ]; then
  echo "Creating database ${PG_ODOO_DB}..."
  psql --username "$POSTGRES_USER" --dbname "postgres" -c \
    "CREATE DATABASE ${PG_ODOO_DB} OWNER ${PG_ODOO_USER};"
fi

# mirror (symfony)
DB_EXISTS=$(psql --username "$POSTGRES_USER" --dbname "postgres" -tAc \
  "SELECT 1 FROM pg_database WHERE datname='${PG_SYMFONY_DB}'")

if [ "$DB_EXISTS" != "1" ]; then
  echo "Creating database ${PG_SYMFONY_DB}..."
  psql --username "$POSTGRES_USER" --dbname "postgres" -c \
    "CREATE DATABASE ${PG_SYMFONY_DB} OWNER ${PG_SYMFONY_USER};"
fi

#----------------------------------------------------------
# 3. LOCK DOWN DEFAULT PRIVILEGES
#----------------------------------------------------------
psql --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL

REVOKE CONNECT ON DATABASE ${PG_ODOO_DB}  FROM PUBLIC;
REVOKE CONNECT ON DATABASE ${PG_SYMFONY_DB} FROM PUBLIC;

GRANT CONNECT ON DATABASE ${PG_ODOO_DB}  TO ${PG_ODOO_USER};
GRANT CONNECT ON DATABASE ${PG_SYMFONY_DB} TO ${PG_SYMFONY_USER};

EOSQL

echo "1_databases_and_users.sh: Databases and users initialized"
