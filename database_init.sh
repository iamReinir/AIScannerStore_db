#!/bin/bash

cd ~/AIScannerStore_db
cp ~/settings/ai_scanner_store.json ./appsettings.json

# Fuck window
# Extract credentials from appsetting file
SETTING="appsettings.json"
DB_USER=$(jq -r '.Database.Username' $SETTING)
DB_PASS=$(jq -r '.Database.Password' $SETTING)
DB_NAME=$(jq -r '.Database.Name' $SETTING)

# clean and initialize the database
echo "initializing database..."
psql "postgresql://$DB_USER:$DB_PASS@localhost/$DB_NAME" -f init_db.sql
