#!/bin/bash

cd ~/AIScannerStore_db
cp ~/settings/ai_scanner_store.json ./appsettings.json

# Fuck window
# Extract credentials from appsetting file
SETTING="appsettings.json"
DB_USER=$(jq -r '.Database.Username' $SETTING)
DB_PASS=$(jq -r '.Database.Password' $SETTING)
DB_NAME=$(jq -r '.Database.Name' $SETTING)
DB_URL="postgresql://$DB_USER:$DB_PASS@localhost/$DB_NAME"

echo "Cleanup database..."
psql $DB_URL -f cleanup_db.sql
echo "Cleanup database Done"