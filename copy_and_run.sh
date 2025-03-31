#!/bin/bash
# Generate the .sql file

SERVER1=server1-common
echo "Creating init_db.sql..."
./generate_sql.sh

scp ./init_db.sql $SERVER1:~/AIScannerStore_db/init_db.sql
scp ./cleanup_db.sql $SERVER1:~/AIScannerStore_db/cleanup_db.sql
scp ./database_init.sh $SERVER1:~/AIScannerStore_db/database_init.sh
scp ./database_cleanup.sh $SERVER1:~/AIScannerStore_db/database_cleanup.sh

ssh $SERVER1 "/bin/bash /home/common/AIScannerStore_db/database_init.sh"

read -n 1 -s -r -p "Press any key to close..."
