#!/bin/sh

# source information
SOURCE_USER=root                  
SOURCE_PASS=sewrAXu3EWrEprAg      
BACKUP_DIRECTORY=/Users/ldc/db-backups/`date +%Y%m%d`
LOG_FILE=/Users/ldc/db-backups/backups.log

if [ ! -d $BACKUP_DIRECTORY ];
then
    mkdir $BACKUP_DIRECTORY
fi

for MYSQL_SERVER in kulit.isi.edu 
do 

    FILENAME=$BACKUP_DIRECTORY/$MYSQL_SERVER.sql
    echo [`date +%Y%m%d`] Performing backup on $MYSQL_SERVER to $FILENAME | tee -a $LOG_FILE
    mysqldump -u$SOURCE_USER -p$SOURCE_PASS -h$MYSQL_SERVER --add-drop-database --add-drop-table --add-locks --compress --comments --create-options --disable-keys --extended-insert --flush-privileges --lock-all-tables --all-databases > $FILENAME
    gzip -9 -f $FILENAME
done

