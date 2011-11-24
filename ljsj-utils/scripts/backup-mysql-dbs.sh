#!/bin/bash
DATE=`date +%Y%m%d-%H%M%S`
FILENAME=seagull.isi.edu-$DATE.sql
DIRECTORY=/nfs/nlg/ikcap/backups/seagull/mysql
ARCHIVE_PATH=$DIRECTORY/$FILENAME

#su moody -c "/usr/ucb/mysqldump -uroot --add-drop-database --add-drop-table --add-locks --compress --comments --create-options --disable-keys --extended-insert --flush-privileges --lock-all-tables --comments --all-databases > $ARCHIVE_PATH"

/usr/ucb/mysqldump -uroot --add-drop-database --add-drop-table --add-locks --compress --comments --create-options --disable-keys --extended-insert --flush-privileges --lock-all-tables --comments --all-databases > $ARCHIVE_PATH

#su moody -c "/usr/ucb/gzip -9 $ARCHIVE_PATH"

/usr/ucb/gzip -9 $ARCHIVE_PATH

find $DIRECTORY  -atime +10 -delete 






