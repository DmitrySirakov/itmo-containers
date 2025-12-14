#!/bin/bash
set -e

echo "Initializing database extensions and schemas..."

PGHOST=${PGHOST:-postgres}
PGPORT=${PGPORT:-5432}

echo "Connecting to PostgreSQL at $PGHOST:$PGPORT"

psql -v ON_ERROR_STOP=1 \
     -h "$PGHOST" \
     -p "$PGPORT" \
     --username "$POSTGRES_USER" \
     --dbname "$POSTGRES_DB" \
     <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pg_trgm";

    CREATE SCHEMA IF NOT EXISTS jupyterhub;
    
    GRANT ALL ON SCHEMA jupyterhub TO $POSTGRES_USER;
    
    ANALYZE;
EOSQL

echo "Database initialization completed!"

