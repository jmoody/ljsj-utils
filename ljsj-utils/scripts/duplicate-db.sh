#!/bin/sh

### --------------------------------------------------------------------------
### duplicates all the tables visible by woj-server user on source to target
### requires:
### 1. that any slaves you wish to duplicate against, be configured to start
###    with --report-host=<host-name>, so that the checks for MySQL master
###    servers will not fail - otherwise the protections afforded by the 
###    script will be useless
###
### 2. a woj-server user is in place on the source machine
### 
### provides protection against: 
### 1. duplicating with a master server as a source (the assumption is that
###    you should be duplicating against a slave)
### 2. duplicating with a master server as a target (which is probably not
###    what you intented - if it is, modify the script, but don't forget to
###    stop any slaves before duplicating and start them when you are done)
### 3. duplicating with a slave server as a target - this probably not
###    what you wanted to do
###
### writes a provenance entry into the source and target 
### provenance.db_duplication_log (unless the source is a slave, in which
### case this write is skipped)
### --------------------------------------------------------------------------


# source information
# pupuk is a slave (mirror) to the current production machine
SOURCE_HOST=pupuk.isi.edu
SOURCE_USER=root                  
SOURCE_PASS=sewrAXu3EWrEprAg      

# target information
TARGET_HOST=peugeot.local
TARGET_USER=root
TARGET_PASS=sewrAXu3EWrEprAg

PROVENANCE_DB=provenance.db_duplication_log

# this this the user/pass that the animal watch/wayang outpost
# server/client will use
WO_SERVER_USER=woj-server
WO_SERVER_PASS=MeSWAjE4U5aq4jec

MYSQL_DUMP_OPTIONS="--add-drop-database --add-drop-table --add-locks --compress --comments --create-options --disable-keys --extended-insert --flush-privileges --lock-all-tables"

# place holder
REQUIRED_DATABASES=""

SOURCE_IS_SLAVE=.
TARGET_IS_SLAVE=.
SOURCE_IS_MASTER=.
TARGET_IS_MASTER=.

if [ "$SOURCE_HOST" = "$TARGET_HOST" ];
then
    echo "[FATAL] the source machine ($SOURCE_HOST) is the same as the target machine ($TARGET_HOST)"
    exit 1
fi

TMP_VARIABLE=`mysql -h$SOURCE_HOST -u$SOURCE_USER -p$SOURCE_PASS --execute "show slave status"`
if [ -z "$TMP_VARIABLE" ];
then 
    SOURCE_IS_SLAVE=0
else
    SOURCE_IS_SLAVE=1
fi

TMP_VARIABLE=`mysql -h$TARGET_HOST -u$TARGET_USER -p$TARGET_PASS --execute "show slave status"`
if [ -z "$TMP_VARIABLE" ];
then 
    TARGET_IS_SLAVE=0
else 
    TARGET_IS_SLAVE=1
fi

SOURCE_SLAVE_HOSTS=""
if [ $SOURCE_IS_SLAVE -eq 1 ];
then 
    SOURCE_IS_MASTER=0
else 
    TMP_VARIABLE=`mysql -h$SOURCE_HOST -u$SOURCE_USER -p$SOURCE_PASS --execute "show slave hosts"`
    if [ -z "$TMP_VARIABLE" ];
    then
        SOURCE_IS_MASTER=0
    else
        SOURCE_IS_MASTER=1
        SOURCE_SLAVE_HOSTS="$TMP_VARIABLE"
    fi
fi

if [ $TARGET_IS_SLAVE -eq 1 ];
then 
    TARGET_IS_MASTER=0
else 
    TMP_VARIABLE=`mysql -h$TARGET_HOST -u$TARGET_USER -p$TARGET_PASS --execute "show slave hosts"`
    if [ -z "$TMP_VARIABLE" ];
    then
        TARGET_IS_MASTER=0
    else
        TARGET_IS_MASTER=1
    fi
fi

if [ $TARGET_IS_SLAVE -eq 1 ];
then 
    echo "[FATAL] operation is not permitted: target $TARGET_HOST is a slave"
    echo "[FATAL] slaves are automagically synched to a master"
    echo "[FATAL] duplicating another database to them is not allowed"
    exit 1
fi

if [ $TARGET_IS_MASTER -eq 1 ];
then
    echo "[FATAL] operation is not permitted: target $TARGET_HOST is a master db"
    echo "[FATAL] this operation would have overwritten a master db"
    exit 1
fi

if [ $SOURCE_IS_MASTER -eq 1 ];
then 
    echo "[FATAL] operation is not permitted: source $SOURCE_HOST is a master db"
    echo "[FATAL] you should be synching against a slave, not the master"
    echo "[FATAL] use the following information to find a slave to duplicate against"
    echo "$SOURCE_SLAVE_HOSTS"
    exit 1
fi

# First, collect all the databases that the wo_server_user has access to or said
# different, which databases are viewable by the wo_server_user
echo "[INFO] collecting all databases that $WO_SERVER_USER at $SOURCE_HOST has privileges to use..."
for db in `mysql -u$WO_SERVER_USER -p$WO_SERVER_PASS -h$SOURCE_HOST --execute "show databases;"`
do
    case $db in
        # nop - this is the header
        Database) ;; 
        test) echo "[WARNING] ignoring database with name $db" ;; # nop
        # this is a simple append operation
        *) REQUIRED_DATABASES=$REQUIRED_DATABASES" "$db ;; 
    esac
done 

echo "[INFO] will duplicate the following databases:"

for db in $REQUIRED_DATABASES
do
    echo "[INFO] * $db"
done

# Next, grab all the required databases that we collected above
echo "[INFO] grabbing mysql databases from $SOURCE_HOST and installing on $TARGET_HOST"
echo "[INFO] with these options:"
for opt in --add-drop-database --add-drop-table --add-locks --compress --comments --create-options --disable-keys --extended-insert --flush-privileges --lock-all-tables
do
        echo "[INFO] $opt"
done

mysqldump -u$SOURCE_USER -p$SOURCE_PASS -h$SOURCE_HOST --add-drop-database --add-drop-table --add-locks --compress --comments --create-options --disable-keys --extended-insert --flush-privileges --lock-all-tables --databases $REQUIRED_DATABASES | mysql -u$TARGET_USER -p$TARGET_PASS -h$TARGET_HOST

# Then, grant privileges for the wo_server_user on the target machine using the root account
for db in $REQUIRED_DATABASES
do
    case $db in
	information_schema) ;; # nop
	*) 
	    echo "[INFO] granting privileges on $db for user $WO_SERVER_USER on $TARGET_HOST"
	    mysql -u$TARGET_USER -p$TARGET_PASS -h$TARGET_HOST --execute "grant all privileges on "$db".* to '"$WO_SERVER_USER"'@'%.isi.edu' identified by '"$WO_SERVER_PASS"' with grant option;" 
       	    mysql -u$TARGET_USER -p$TARGET_PASS -h$TARGET_HOST --execute "grant all privileges on "$db".* to '"$WO_SERVER_USER"'@'localhost' identified by '"$WO_SERVER_PASS"' with grant option;" ;;
    esac
done

# Finally, flush the privileges on the target machine using the root account
echo "[INFO] flushing privileges on $TARGET_HOST"
mysql -u$TARGET_USER -p$TARGET_PASS -h$TARGET_HOST --execute "flush privileges;"

DATE=`date +%Y-%m-%d\ %H:%M:%S`

PROVENANCE_STATEMENT="INSERT INTO $PROVENANCE_DB (date,source_ip,target_ip,mysql_dump_options,duplicated_databases,target_user) values ('$DATE','$SOURCE_HOST','$TARGET_HOST','$MYSQL_DUMP_OPTIONS','$REQUIRED_DATABASES','$WO_SERVER_USER')"

echo "[INFO] adding provenance information to target"
mysql -u$TARGET_USER -p$TARGET_PASS -h$TARGET_HOST --execute "$PROVENANCE_STATEMENT"

if [ $SOURCE_IS_SLAVE -eq 1 ];
then
    echo "[INFO] skipping adding provenance information to source ($SOURCE_HOST is a slave)";
else 
    echo "[INFO] adding provenance information to the source"
    mysql -u$SOURCE_USER -p$SOURCE_PASS -h$SOURCE_HOST --execute "$PROVENANCE_STATEMENT"
fi

exit 0