#!/bin/bash
# Generate the .sql file
echo "Creating init_db.sql..."
./generate_sql.sh

scp ./init_db.sql server1-common:~/AIScannerStore_db/init_db.sql
scp ./database_init.sh server1-common:~/AIScannerStore_db/database_init.sh

ssh server1-common "/bin/bash /home/common/AIScannerStore_db/database_init.sh"

read -n 1 -s -r -p "Press any key to close..."
