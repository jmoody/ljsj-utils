#!/bin/bash
DATE=`date +%Y%m%d-%H%M%S`
FILENAME=seagull.isi.edu-$DATE.svn
DIRECTORY=/nfs/nlg/ikcap/backups/seagull/svn
TMP_PATH=/tmp/$FILENAME
PATH=$DIRECTORY/$FILENAME

# write to seagull:/tmp/
/usr/ucb/svnadmin hotcopy /var/www/svn/ikcap $TMP_PATH

# tar and compress temp
/bin/tar -cf $TMP_PATH.tar $TMP_PATH

/usr/ucb/gzip $TMP_PATH.tar 

# mv to nlg/ikcap
/bin/mv $TMP_PATH.tar.gz $DIRECTORY

# clean up on seagull:/tmp/
/bin/rm -rf $TMP_PATH 

# remove files over 10 days old
/usr/ucb/find $DIRECTORY -atime +10 -delete






