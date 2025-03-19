#!/bin/bash
cd ~/AIScannerStore_BE

# This file is used for the server's service unit file. 
# Don't change it unless you have a good reason to.
# Fuck window
# Extract credentials from appsetting file
SETTING="appsettings.json"
DB_USER=$(jq -r '.Database.Username' $SETTING)
DB_PASS=$(jq -r '.Database.Password' $SETTING)
DB_NAME=$(jq -r '.Database.Name' $SETTING)

# Generate the .sql file
echo "Creating init_db.sql..."
chmod +x ./generate_sql.sh
/bin/bash ./generate_sql.sh


# clean and initialize the database
echo "initializing database..."
psql "postgresql://$DB_USER:$DB_PASS@localhost/$DB_NAME" -f init_db.sql
