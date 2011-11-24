#!/bin/sh
########################################################################
# WARNING: do not execute this as root or with sudo
#          instead execute as a user with sudo privileges
#          and provide your pass when prompted
########################################################################

### --------------------------------------------------------------------------
### user
### --------------------------------------------------------------------------

USERNAME=`whoami`

### --------------------------------------------------------------------------
### the host we will install on
### --------------------------------------------------------------------------

HOST=`hostname`
MYSQL_HOST=$HOST

### --------------------------------------------------------------------------
### the path to the server and client source
### the server and the client do _not_ need to have the same release number
### also note that the initial setup instructions indicate that one should
### create sym links for /Users -> /home and /home -> /Users on mac and linux
### respectfully
### --------------------------------------------------------------------------

SERVER_SOURCE=/home/$USERNAME/Documents/svn/k12/awvi/trunk
AUDIO_SOURCE=$SERVER_SOURCE/src/main/audio

### --------------------------------------------------------------------------
### name of the webapp
### --------------------------------------------------------------------------

APP_NAME=awvi

### --------------------------------------------------------------------------
### the path to the tomcat software
### --------------------------------------------------------------------------

PATH_TO_TOMCAT=/usr/local/tomcat

### --------------------------------------------------------------------------
### the port we will use to access tomcat
### for the most part, this will not need to be changed
### --------------------------------------------------------------------------

OS_NAME=`uname`

PORT=80
if [ "$OS_NAME" = "Darwin" ];
then
    PORT=8080
fi

### --------------------------------------------------------------------------
### don't adjust this unless you know what you are about
### --------------------------------------------------------------------------
LOG_DIRECTORY=$SERVER_SOURCE/logs/deploy
LOG_FILE=$SERVER_SOURCE/logs/deploy/deploy.log


########################################################################
# do not edit below this line unless you know what you are about       #
########################################################################

### --------------------------------------------------------------------------
### we support Mac OS builds and Linux builds
### --------------------------------------------------------------------------

TOMCAT_STOP_ARGS=""
TOMCAT_START_ARGS=""

if [ "$OS_NAME" = "Darwin" ];
then
    CATALINA_PID=`cat $PATH_TO_TOMCAT/logs/tomcat6.pid`
    TOMCAT_USER=www
    TOMCAT_GROUP=www
    DARWIN_MAJOR_VERSION=`uname -r | cut -f 1 -d '.'`
    if [ $DARWIN_MAJOR_VERSION -eq 9 ];
    then
        TOMCAT_USER=_www
        TOMCAT_GROUP=_www
    fi
    PATH_TO_TOMCATCTL=$PATH_TO_TOMCAT/bin/catalina.sh
    TOMCAT_STOP_ARGS="-force"
    TOMCAT_START_ARGS=""
else
    
    CATALINA_PID=`ps -ef | grep catalina | grep -v grep | cut -f4 -d" "`
    TOMCAT_USER=tomcat6
    TOMCAT_GROUP=adm
    PATH_TO_TOMCATCTL=/etc/init.d/tomcat6
fi


### --------------------------------------------------------------------------
### check to see if the log directory exists - if it does, create a new log
### file, if not, throw a FATAL message and exit
### --------------------------------------------------------------------------


if [ -d $LOG_DIRECTORY ];
then
    if [ -e $LOG_FILE ];
    then
        rm -f $LOG_FILE
    else
        touch $LOG_FILE
    fi
else
    echo [FATAL] Check your configuration.  Log file not found.
    echo [FATAL] $LOG_FILE
    exit 1
fi

### --------------------------------------------------------------------------
### do _not_ run as root
### --------------------------------------------------------------------------

WHOAMI=`whoami`

if [ $WHOAMI = root ];
then
    echo [FATAL] Do NOT run as root. | tee -a $LOG_FILE
    echo exiting  | tee -a $LOG_FILE
    exit 1
fi

### --------------------------------------------------------------------------
### get the ball rolling with a sudo command
### --------------------------------------------------------------------------

sudo date > /dev/null

### --------------------------------------------------------------------------
### check to see if the tomcat directory exists
### --------------------------------------------------------------------------

if [ ! -d $PATH_TO_TOMCAT ];
then
    echo [FATAL] Tomcat directory does not exist:  $PATH_TO_TOMCAT  | tee -a $LOG_FILE
    echo exiting  | tee -a $LOG_FILE
    exit 1
fi

### --------------------------------------------------------------------------
### check to see if the server source exist
### --------------------------------------------------------------------------

if [ ! -d $SERVER_SOURCE ];
then
    echo [FATAL] Server source directory does not exist: $SERVER_SOURCE  | tee -a $LOG_FILE
    echo exiting  | tee -a $LOG_FILE
    exit 1
fi

### --------------------------------------------------------------------------
### Setting up Maven environment
### --------------------------------------------------------------------------

if [ "$OS_NAME" = "Darwin" ];
then
    MAVEN=/opt/local/bin/mvn
    MAVEN_REPOSITORY=/Users/$USERNAME/.m2/repository
    MAVEN_SETTINGS_FILE=/Users/$USERNAME/.m2/settings.xml
else
    MAVEN=/usr/local/maven/bin/mvn
    MAVEN_REPOSITORY=/home/$USERNAME/.m2/repository
    MAVEN_SETTINGS_FILE=/home/$USERNAME/.m2/settings.xml
fi

### --------------------------------------------------------------------------

echo [INFO] Testing for $MAVEN_REPOSITORY... | tee -a $LOG_FILE
if [ ! -e $MAVEN_REPOSITORY ];
then
    echo [WARNING] $MAVEN_REPOSITORY does not exist, running maven for the first time... | tee -a $LOG_FILE
    echo [INFO] Changing directory to $SERVER_SOURCE  | tee -a $LOG_FILE
    cd $SERVER_SOURCE/
    $MAVEN install
fi

echo [INFO] Testing for $MAVEN_SETTINGS_FILE... | tee -a $LOG_FILE
if [ ! -e $MAVEN_SETTINGS_FILE ];
then
    echo [FATAL] $MAVEN_SETTINGS_FILE does not exist | tee -a $LOG_FILE
    echo [FATAL] A template for this file can be found in the $SERVER_SOURCE/init-files/settings-template.xml | tee -a $LOG_FILE
    echo [FATAL] exiting | tee -a $LOG_FILE
    exit 1
fi

### --------------------------------------------------------------------------
### figure out which version of mysql-connector-java maven will use
### this jar will be placed in the $PATH_TO_TOMCAT/lib once the war is built
### --------------------------------------------------------------------------

MYSQL_CONNECTOR_DIRECTORY=$MAVEN_REPOSITORY/mysql/mysql-connector-java
MYSQL_CONNECTOR_HIGHEST_VERSION=`ls $MYSQL_CONNECTOR_DIRECTORY | sort -r | head -1`
PATH_TO_MYSQL_CONNECTOR=$MYSQL_CONNECTOR_DIRECTORY/$MYSQL_CONNECTOR_HIGHEST_VERSION/mysql-connector-java-$MYSQL_CONNECTOR_HIGHEST_VERSION.jar

echo [INFO] Testing for mysql-connector at path  $PATH_TO_MYSQL_CONNECTOR... | tee -a $LOG_FILE
if [ -e $PATH_TO_MYSQL_CONNECTOR ];
then
    echo [INFO] Found $PATH_TO_MYSQL_CONNECTOR | tee -a $LOG_FILE
else
    echo [FATAL] $PATH_TO_MYSQL_CONNECTOR does not exist | tee -a $LOG_FILE
    echo [INFO] You may need to run mvn install in the $SERVER_SOURCE directory | tee -a $LOG_FILE
    echo [INFO] exiting | tee -a $LOG_FILE
    exit 1
fi

### --------------------------------------------------------------------------
### add provenance information to log file
### --------------------------------------------------------------------------

echo "[INFO] recording svn info SERVER_SOURCE to log file"
svn info $SERVER_SOURCE >> $LOG_FILE


### --------------------------------------------------------------------------
### start tomcat if it is not running
### --------------------------------------------------------------------------
if [ ! -z $CATALINA_PID ];
then
   FOUND_PROCESS=`ps auxw | grep $CATALINA_PID | grep -v grep`
    if [ -z "$FOUND_PROCESS" ];
    then
       echo [WARNING] Can not find process with $CATALINA_PID - assuming Tomcat is not running
       echo [INFO] Starting Tomcat  | tee -a $LOG_FILE
       sudo $PATH_TO_TOMCATCTL start $TOMCAT_START_ARGS > /dev/null # suppress output
    fi
else
   echo [INFO] Tomcat does not appear to be running  | tee -a $LOG_FILE
   echo [INFO] Starting Tomcat  | tee -a $LOG_FILE
   sudo $PATH_TO_TOMCATCTL start $TOMCAT_START_ARGS > /dev/null # suppress output
fi

### --------------------------------------------------------------------------
### clean the target first!
### then deploy with tomact plugin
### --------------------------------------------------------------------------

echo [INFO] Changing directory to $SERVER_SOURCE  | tee -a $LOG_FILE
cd $SERVER_SOURCE/

$MAVEN clean | tee -a $LOG_FILEs
$MAVEN tomcat:deploy | tee -a $LOG_FILE
MVN_EXIT=`echo $?`

if [ $MVN_EXIT -eq 0 ];
then
    echo [INFO] maven build succeeded | tee -a $LOG_FILE
else
    echo [FATAL] maven build failed | tee -a $LOG_FILE
    echo [FATAL] exiting code with code $MVN_EXIT | tee -a $LOG_FILE
    exit $MVN_EXIT
fi

### --------------------------------------------------------------------------
### install the latest mysql connector jar
### --------------------------------------------------------------------------

echo [INFO] testing for mysql-connector jar in $PATH_TO_TOMCAT/lib... | tee -a $LOG_FILE
if [ -z `ls $PATH_TO_TOMCAT/lib | grep mysql-connector` ];
then
    echo [INFO] No jars found | tee -a $LOG_FILE
else
    for jar in `ls $PATH_TO_TOMCAT/lib | grep mysql-connector`;
    do
        echo [INFO] Found $jar | tee -a $LOG_FILE
        echo [INFO] Deleteing $PATH_TO_TOMCAT/lib/$jar | tee -a $LOG_FILE
        sudo rm $PATH_TO_TOMCAT/lib/$jar
    done
fi

echo [INFO] Installing $PATH_TO_MYSQL_CONNECTOR to $PATH_TO_TOMCAT/lib | tee -a $LOG_FILE
sudo cp $PATH_TO_MYSQL_CONNECTOR $PATH_TO_TOMCAT/lib

### --------------------------------------------------------------------------
### changing owner:group for the tomcat directory
### --------------------------------------------------------------------------

echo [INFO] Changing owner:group to $TOMCAT_USER:$TOMCAT_GROUP for $PATH_TO_TOMCAT  | tee -a $LOG_FILE
sudo chown -RL $TOMCAT_USER:$TOMCAT_GROUP $PATH_TO_TOMCAT

### --------------------------------------------------------------------------
### waiting for tomcat to deploy the webapp
### --------------------------------------------------------------------------

while [ ! -d $PATH_TO_TOMCAT/webapps/$APP_NAME ]
do
    echo [INFO] Waiting for $PATH_TO_TOMCAT/webapps/$APP_NAME.war to deploy...  | tee -a $LOG_FILE
    sleep 1
done

### --------------------------------------------------------------------------
### copy the audio file to the tomcat directoyr
### --------------------------------------------------------------------------

echo [INFO] Copying audio files to $PATH_TO_TOMCAT/webapps/$APP_NAME | tee -a $LOG_FILE
sudo cp -r $AUDIO_SOURCE $PATH_TO_TOMCAT/webapps/$APP_NAME/
sudo rm -rf $PATH_TO_TOMCAT/webapps/$APP_NAME/.svn

### --------------------------------------------------------------------------
### changing owner:group for the tomcat directory
### --------------------------------------------------------------------------

echo [INFO] Changing owner:group to $TOMCAT_USER:$TOMCAT_GROUP for $PATH_TO_TOMCAT  | tee -a $LOG_FILE
sudo chown -RL $TOMCAT_USER:$TOMCAT_GROUP $PATH_TO_TOMCAT

echo [INFO] $PATH_TO_TOMCAT/webapps/$APP_NAME deployed  | tee -a $LOG_FILE

echo [INFO] Removing any backup files  | tee -a $LOG_FILE

if [ "$OS_NAME" = "Darwin" ];
then
    find $PATH_TO_TOMCAT/webapps/$APP_NAME \( -name "#*" -o -name "*#" -o -name "*~" \) | xargs rm -rf
else
    find $PATH_TO_TOMCAT/webapps/$APP_NAME \( -name "#*" -o -name "*#" -o -name "*~" \) -exec rm -rf {} \; > /dev/null
fi

echo [INFO] $APP_NAME successfully installed to $PATH_TO_TOMCAT/webapps/$APP_NAME  | tee -a $LOG_FILE

echo [INFO] Copying $LOG_FILE to $PATH_TO_TOMCAT/webapps/$APP_NAME | tee -a $LOG_FILE

sudo cp $LOG_FILE $PATH_TO_TOMCAT/webapps/$APP_NAME

### --------------------------------------------------------------------------
### making deploy.log unreadable
### --------------------------------------------------------------------------
sudo chmod 600 $PATH_TO_TOMCAT/webapps/$APP_NAME/deploy.log

DEPLOY_DATE=`date +%Y%m%d%H%M%S`
echo [INFO] Copying $LOG_FILE to $SERVER_SOURCE/logs/deploy/deploy-$DEPLOY_DATE.log
cp $LOG_FILE $SERVER_SOURCE/logs/deploy/deploy-$DEPLOY_DATE.log

exit 0

### --------------------------------------------------------------------------
### dead sea
### --------------------------------------------------------------------------
