#!/bin/sh
########################################################################
# WARNING: do not execute this as root or with sudo
#          instead execute as a user with sudo privileges
#          and provide your pass when prompted
########################################################################

### --------------------------------------------------------------------------
### {dev | production}
### --------------------------------------------------------------------------

BUILD_TYPE=dev

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

SERVER_SOURCE=/home/$USERNAME/Documents/svn/k12/wayang/server/trunk
CLIENT_SOURCE=/home/$USERNAME/Documents/svn/k12/wayang/client/branches/client-release-branch-1.2.3

### --------------------------------------------------------------------------
### should we save the old configuration (conf/Catalina/localhost/*.xml and 
### the .war)? {y | n} note that saving configurations takes up ~1G per build.
### --------------------------------------------------------------------------

ARCHIVE_OLD_BUILD=n
ARCHIVED_BUILD_DIRECTORY=/home/$USERNAME/Documents/archived-builds

### --------------------------------------------------------------------------
### name of the webapp
### --------------------------------------------------------------------------

APP_NAME=woj

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
### what log level should we use for the server?
### for production, please use warn
### debug produces copious amounts of information - not exhaustive (yet)
### --------------------------------------------------------------------------

if [ "$BUILD_TYPE" = "dev" ]; 
then
    LOG4J_LOG_LEVEL=debug
    CLIENT_DEBUG_VALUE=true
elif [ "$BUILD_TYPE" = "production" ]; 
then
    LOG4J_LOG_LEVEL=info
    CLIENT_DEBUG_VALUE=false
else 
    echo [FATAL] Build type must be "{dev | production}" - found $BUILD_TYPE
    echo [FATAL] Adjust this variable in deploy.sh
    echo [INFO] exiting
    exit 1
fi

### --------------------------------------------------------------------------
### where should the client files be placed?
### we are no longer installing in $TOMCAT_HOME/webapps/ROOT
### there should be no need to adjust this
### --------------------------------------------------------------------------
CLIENT_DESTINATION=$SERVER_SOURCE/web/client

### --------------------------------------------------------------------------
### don't adjust this unless you know what you are about
### --------------------------------------------------------------------------
LOG_DIRECTORY=$SERVER_SOURCE/logs/deploy
LOG_FILE=$SERVER_SOURCE/logs/deploy/deploy.log

### --------------------------------------------------------------------------
### must be writable by non root
### --------------------------------------------------------------------------
TMP_DIRECTORY=/tmp

### --------------------------------------------------------------------------
### where client files will be staged or copied to temporarily.
### no need to change this. 
### --------------------------------------------------------------------------
CLIENT_TMP_DIRECTORY=$TMP_DIRECTORY/client-`date +%Y%m%d%H%M%S`

WEBORB_DIRECTORY_NAME=weborb

### --------------------------------------------------------------------------
### variables for writing <client>/config.xml
### --------------------------------------------------------------------------

PATH_TO_CLIENT_CONFIG=$CLIENT_DESTINATION/config.xml
GATEWAY_HOST=$HOST # weborb
GATEWAY_PORT=$PORT
GATEWAY_URI=http://$GATEWAY_HOST:$GATEWAY_PORT/$WEBORB_DIRECTORY_NAME/console/weborb.wo
CHAT_HOST=$HOST
### coupled with writting of the web.xml file (see below)
CHAT_PORT=8088
OLD_GATEWAY_HOST=$HOST # tutor brain
OLD_GATEWAY_PORT=$PORT # tutor brain
### coupled with writting of the web.xml file (see below)
OLD_GATEWAY_SERVLET=TutorBrain # tutor brain
SIGNUP_HOST=$HOST
SIGNUP_PORT=$PORT
### coupled with writting of the web.xml file (see below)
SIGNUP_SERVLET=WoAdmin
SIGNUP_ACTION=CreateUser1

### --------------------------------------------------------------------------
### variables for writing <server>/web/META-INF/context.xml
### --------------------------------------------------------------------------

PATH_TO_CONTEXT=$SERVER_SOURCE/web/META-INF/context.xml
SERVER_MYSQL_PASS=MeSWAjE4U5aq4jec
SERVER_MYSQL_USER=woj-server
SERVER_MYSQL_HOST=$MYSQL_HOST
### coupled with the web.xml writing (see below)
SERVER_MYSQL_DB_NAME=adm

### --------------------------------------------------------------------------
### variables for writing <server>/web/index.html
### --------------------------------------------------------------------------

PATH_TO_INDEX_HTML=$SERVER_SOURCE/web/index.html
PATH_TO_CLIENT_DIRECTORY=client

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
    CATALINA_PID=$PATH_TO_TOMCAT/logs/tomcat6.pid
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
    TOMCAT_USER=tomcat6
    TOMCAT_GROUP=adm
    PATH_TO_TOMCATCTL=/etc/init.d/tomcat6
fi

### --------------------------------------------------------------------------
### variables for writing log4j.properties
### --------------------------------------------------------------------------
LOG4J_PROPERTIES=log4j.properties
# coupled with writing of web.xml (see below)
PATH_TO_LOG4J_PROPERTIES=$SERVER_SOURCE/web/WEB-INF/classes/$LOG4J_PROPERTIES
LOG4J_LOG_FILE=$PATH_TO_TOMCAT/logs/$APP_NAME.log


### --------------------------------------------------------------------------
### variables for writing <server>/web/web.xml
### --------------------------------------------------------------------------
WEB_XML=web.xml
PATH_TO_WEB_XML=$SERVER_SOURCE/web/WEB-INF/$WEB_XML
TUTOR_SERVLET_NAME=TutorBrain
TUTOR_SERVLET_CLASS=edu.usc.k12.sys.server.TutorServlet
TUTOR_SERVLET_RUN_MODE=hsexperiment
TUTOR_SERVLET_URL=/$TUTOR_SERVLET_NAME
CPANEL_SERVLET_NAME=CPanelServlet
CPANEL_SERVLET_CLASS=edu.usc.k12.cpanel.server.CPanelServlet
CONTROL_PANEL_NAME=cpanel/controlpanel
CONTROL_PANEL_CLASS=edu.usc.k12.cpanel.server.CPanelServlet
### WO_ADMIN_SERVLET_NAME=WoAdminServlet
### WO_ADMIN_SERVLET_CLASS=edu.usc.k12.sys.server.AdminServlet
### WO_ADMIN_SERVLET_URL=/WoAdmin
SESSION_TIMEOUT=60

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
### determine if we are cleaning the client or reusing it
### --------------------------------------------------------------------------

CLEAN_CLIENT=.

case $1 in
    rebuild-client) 
        CLEAN_CLIENT=1 
        echo [INFO] Will rebuild client files | tee -a $LOG_FILE ;;
    reuse-client) CLEAN_CLIENT=0 
        echo [INFO] Will attempt to reuse client files | tee -a $LOG_FILE ;;
    *) 
        echo "Usage: deploy.sh {rebuild-client | reuse-client}" 
        exit 1 ;;
esac


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
### check to see if the tomcat directory exists
### --------------------------------------------------------------------------

if [ ! -d $PATH_TO_TOMCAT ];
then
    echo [FATAL] Tomcat directory does not exist:  $PATH_TO_TOMCAT  | tee -a $LOG_FILE
    echo exiting  | tee -a $LOG_FILE
    exit 1
fi

### --------------------------------------------------------------------------
### check to see if the weborb directory exists
### --------------------------------------------------------------------------

if [ ! -d $PATH_TO_TOMCAT/webapps/$WEBORB_DIRECTORY_NAME ];
then
    echo [FATAL] weborb is not installed.  Install it before continuing. | tee -a $LOG_FILE
    echo exiting | tee -a $LOG_FILE
    exit 1
fi

### --------------------------------------------------------------------------
### check to see if the tomcatctl program exists
### --------------------------------------------------------------------------

echo [INFO] Testing for tomcatctl in $PATH_TO_TOMCATCTL... | tee -a $LOG_FILE
if [ -e $PATH_TO_TOMCATCTL ]; then
    echo [INFO] Found $PATH_TO_TOMCATCTL | tee -a $LOG_FILE
else 
    echo [FATAL] $PATH_TO_TOMCAT does not exist | tee -a $LOG_FILE
    echo [INFO] exiting | tee -a $LOG_FILE
    exit 1
fi

### --------------------------------------------------------------------------
### check to see if the server and client source exist
### --------------------------------------------------------------------------

if [ ! -d $SERVER_SOURCE ];
then
    echo [FATAL] Server source directory does not exist: $SERVER_SOURCE  | tee -a $LOG_FILE
    echo exiting  | tee -a $LOG_FILE
    exit 1
fi

if [ ! -d $CLIENT_SOURCE ];
then 
    echo [FATAL] Server source directory does not exist: $CLIENT_SOURCE  | tee -a $LOG_FILE
    echo exiting  | tee -a $LOG_FILE
    exit 1
fi

### --------------------------------------------------------------------------
### check to see if the tmp directory exists and test write permissions
### --------------------------------------------------------------------------

if [ ! -d $TMP_DIRECTORY ];
then
    echo [FATAL] Tmp directory does not exist: $TMP_DIRECTORY  | tee -a $LOG_FILE
    echo exiting  | tee -a $LOG_FILE
exit 1
fi

### --------------------------------------------------------------------------

echo [INFO] Testing write permissions on $TMP_DIRECTORY...  | tee -a $LOG_FILE
touch $CLIENT_TMP_DIRECTORY > /dev/null
if [ ! -e $CLIENT_TMP_DIRECTORY ];
then 
    echo [FATAL] Can not write to $CLIENT_TMP_DIRECTORY  | tee -a $LOG_FILE
    echo exiting  | tee -a $LOG_FILE
    exit 1
fi
rm -rf $CLIENT_TMP_DIRECTORY

### --------------------------------------------------------------------------
### Setting up Maven environment
### --------------------------------------------------------------------------

if [ "$OS_NAME" = "Darwin" ]; 
then
    MAVEN=/opt/local/bin/mvn
    MAVEN_REPOSITORY=/Users/$USERNAME/.m2/repository
else 
    MAVEN=/usr/local/maven/bin/mvn
    MAVEN_REPOSITORY=/home/$USERNAME/.m2/repository
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
echo "[INFO] recording svn info CLIENT_SOURCE to log file"
svn info $CLIENT_SOURCE >> $LOG_FILE

### --------------------------------------------------------------------------
### if we are cleaning the client, we need to grab the web/client/.svn directory
### to preserve the svn status of the web/client directory (which is empty)
### so we move the .svn directory to tmp/client-svn-<data> and move it back
### when we are done
### --------------------------------------------------------------------------

CLIENT_SVN_TMP_DIRECTORY=$TMP_DIRECTORY/client-svn-`date +%Y%m%d%H%M%S`

echo [INFO] Testing for $CLIENT_DESTINATION...  | tee -a $LOG_FILE
if [ -d $CLIENT_DESTINATION ];
then
    if [ $CLEAN_CLIENT = 1 ];
        then
        echo [INFO] Moving $CLIENT_DESTINATION/.svn directory to $CLIENT_SVN_TMP_DIRECTORY | tee -a $LOG_FILE
        mv $CLIENT_DESTINATION/.svn $CLIENT_SVN_TMP_DIRECTORY
        echo [INFO] Deleting $CLIENT_DESTINATION  | tee -a $LOG_FILE
        rm -rf $CLIENT_DESTINATION/*
    else
        echo [INFO] Will reuse client files | tee -a $LOG_FILE
    fi
else 
    echo [WARNING] Nothing to be done: $CLIENT_DESTINATION does not exist  | tee -a $LOG_FILE
    echo [WARNING] Cleaning client despite $1 being passed | tee -a $LOG_FILE
    CLEAN_CLIENT=1
fi

### --------------------------------------------------------------------------
### since we want to be able to walk away from the script while it is running
### we execute a trivial sudo command to give us sudo privileges before
### the long copy process
### --------------------------------------------------------------------------
sudo date > /dev/null

### --------------------------------------------------------------------------

if [ $CLEAN_CLIENT = 1 ];
then 
    # copy the client files to web/client
    echo [INFO] Copying client sources to $CLIENT_DESTINATION  | tee -a $LOG_FILE
    cp -r $CLIENT_SOURCE/* $CLIENT_DESTINATION

    # report what files we are going to remove
    echo [INFO] Removing the following files and directories from $CLIENT_DESTINATION  | tee -a $LOG_FILE
    for i in  *.fla *.flp *.as *.dv *.app *.exe *.mx thumbs.db .DS_STORE .svn/ components/ include/ com/ ;
    do 
        echo "[INFO] - " $i  | tee -a $LOG_FILE
    done
    
    # delete the files with find
    find $CLIENT_DESTINATION \( -name "*.fla" -o -name "*.flp" -o -name "*.as" -o -name "*.dv" -o -name ".svn" -o -name "thumbs.db" -o -name ".DS_STORE" -o -name "components" -o -name "include" -o -name "com" -o -name "*.app" -o -name "*.exe" -o -name "*.mx" \) | xargs rm -rf > /dev/null

    # move the .svn directory back to the web/client directory
    echo [INFO] Moving $CLIENT_SVN_TMP_DIRECTORY to $CLIENT_DESTINATION/.svn | tee -a $LOG_FILE
    mv $CLIENT_SVN_TMP_DIRECTORY $CLIENT_DESTINATION/.svn  
fi
   
### --------------------------------------------------------------------------
### A message to indicate that a file has been generated by this script
### --------------------------------------------------------------------------
THISHOST=`hostname`
AUTODATE=`date`
MESSAGE0="This file has been generated by deploy.sh located on $THISHOST at"
MESSAGE1="$SERVER_SOURCE/scripts/deploy.sh"
MESSAGE2="on $AUTODATE."
MESSAGE3="Recover with svn revert."

### --------------------------------------------------------------------------
### write the client config.xml file
### --------------------------------------------------------------------------

echo [INFO] Removing $PATH_TO_CLIENT_CONFIG | tee -a $LOG_FILE
echo [INFO] Recover with svn revert | tee -a $LOG_FILE
rm -f $PATH_TO_CLIENT_CONFIG
echo [INFO] Writing new $PATH_TO_CLIENT_CONFIG | tee -a $LOG_FILE
echo [INFO] === BEGIN config.xml === | tee -a $LOG_FILE
echo \<\?xml version=\"1.0\" encoding=\"ISO-8859-1\"\?\> | tee -a $PATH_TO_CLIENT_CONFIG
echo "<!-- $MESSAGE0" | tee -a $PATH_TO_CLIENT_CONFIG
echo "     $MESSAGE1" | tee -a $PATH_TO_CLIENT_CONFIG
echo "     $MESSAGE2" | tee -a $PATH_TO_CLIENT_CONFIG
echo "     $MESSAGE3 -->" | tee -a $PATH_TO_CLIENT_CONFIG
echo \<config\> | tee -a $PATH_TO_CLIENT_CONFIG
echo "  "\<data name=\"gatewayURI\" | tee -a $PATH_TO_CLIENT_CONFIG
echo "        "value=\"$GATEWAY_URI\" | tee -a $PATH_TO_CLIENT_CONFIG
echo "        "type=\"string\" /\> | tee -a $PATH_TO_CLIENT_CONFIG
echo "  "\<data name=\"debug\" | tee -a $PATH_TO_CLIENT_CONFIG
echo "        "value=\"$CLIENT_DEBUG_VALUE\" | tee -a $PATH_TO_CLIENT_CONFIG
echo "        "type=\"bool\" /\> | tee -a $PATH_TO_CLIENT_CONFIG
echo "  "\<data name=\"chatServer\" | tee -a $PATH_TO_CLIENT_CONFIG
echo "        "value=\"$CHAT_HOST\" | tee -a $PATH_TO_CLIENT_CONFIG
echo "        "type=\"string\" /\> | tee -a $PATH_TO_CLIENT_CONFIG
echo "  "\<data name=\"chatServerPort\" | tee -a $PATH_TO_CLIENT_CONFIG
echo "        "value=\"$CHAT_PORT\" | tee -a $PATH_TO_CLIENT_CONFIG
echo "        "type=\"number\" /\> | tee -a $PATH_TO_CLIENT_CONFIG
echo "  "\<data name=\"oldGatewayURI\" | tee -a $PATH_TO_CLIENT_CONFIG
echo "        "value=\"http://$OLD_GATEWAY_HOST:$OLD_GATEWAY_PORT/$APP_NAME/$OLD_GATEWAY_SERVLET\" | tee -a $PATH_TO_CLIENT_CONFIG
echo "        "type=\"string\" /\> | tee -a $PATH_TO_CLIENT_CONFIG
echo "  "\<data name=\"signupURL\" | tee -a $PATH_TO_CLIENT_CONFIG
echo "        "value=\"http://$SIGNUP_HOST:$SIGNUP_PORT/$SIGNUP_SERVLET\?action=$SIGNUP_ACTION\" | tee -a $PATH_TO_CLIENT_CONFIG 
echo "        "type=\"string\" /\> | tee -a $PATH_TO_CLIENT_CONFIG
#echo "  "\<data name=\"disabledItems\" | tee -a $PATH_TO_CLIENT_CONFIG
#echo "        "value=\"animalWatch\" | tee -a $PATH_TO_CLIENT_CONFIG
#echo "        "type=\"string\" /\> | tee -a $PATH_TO_CLIENT_CONFIG
echo "  "\<data name=\"motd\" | tee -a $PATH_TO_CLIENT_CONFIG
echo "        "value=\"Welcome! Explore the system. Some features might not be available at this time.\" | tee -a $PATH_TO_CLIENT_CONFIG
echo "        "type=\"string\" /\> | tee -a $PATH_TO_CLIENT_CONFIG
echo \</config\> | tee -a $PATH_TO_CLIENT_CONFIG
cat $PATH_TO_CLIENT_CONFIG >> $LOG_FILE
echo [INFO] === END config.xml | tee -a $LOG_FILE

### --------------------------------------------------------------------------
### write the web/META-INF/context.xml file
### --------------------------------------------------------------------------

echo [INFO] Removing $PATH_TO_CONTEXT | tee -a $LOG_FILE
echo [INFO] Recover with svn revert | tee -a $LOG_FILE
rm -f $PATH_TO_CONTEXT
echo [INFO] Writing new $PATH_TO_CONTEXT | tee -a $LOG_FILE
echo [INFO] === BEGIN context.xml === | tee -a $LOG_FILE
echo \<\?xml version=\"1.0\" encoding=\"UTF-8\"\?\> | tee -a $PATH_TO_CONTEXT
echo "<!-- $MESSAGE0" | tee -a $PATH_TO_CONTEXT
echo "     $MESSAGE1" | tee -a $PATH_TO_CONTEXT
echo "     $MESSAGE2" | tee -a $PATH_TO_CONTEXT
echo "     $MESSAGE3 -->" | tee -a $PATH_TO_CONTEXT
echo " <!-- Note: the maxActive attribute is linked to:" | tee -a $PATH_TO_CONTEXT
echo "      1. max_connections in my.cnf" | tee -a $PATH_TO_CONTEXT
echo "      2. maxThreads in tomcat/conf/server.xml thread pool Executor" | tee -a $PATH_TO_CONTEXT
echo "      If you make a change anywhere, you need to adjust the settings" | tee -a $PATH_TO_CONTEXT
echo "      everywhere (including deploy.sh)" | tee -a $PATH_TO_CONTEXT
echo "  -->" | tee -a $PATH_TO_CONTEXT 

echo \<Context docbase=\"$APP_NAME\" path=\"/$APP_NAME\"\> | tee -a $PATH_TO_CONTEXT
echo "  "\<Resource auth=\"Container\" | tee -a $PATH_TO_CONTEXT
echo "            "type=\"javax.sql.DataSource\" | tee -a $PATH_TO_CONTEXT
# this is not required (leaving as a reminder)
#echo "            "factory=\"org.apache.tomcat.dbcp.dbcp.BasicDataSourceFactory\" | tee -a $PATH_TO_CONTEXT
echo "            "driverClassName=\"com.mysql.jdbc.Driver\" | tee -a $PATH_TO_CONTEXT
echo "            "maxActive=\"100\" | tee -a $PATH_TO_CONTEXT
echo "            "maxIdle=\"25\" | tee -a $PATH_TO_CONTEXT
echo "            "minIdle=\"20\" | tee -a $PATH_TO_CONTEXT
echo "            "maxWait=\"3000\" | tee -a $PATH_TO_CONTEXT
echo "            "removeAbandoned=\"true\" | tee -a $PATH_TO_CONTEXT
echo "            "removeAbandonedTimeout=\"60\" | tee -a $PATH_TO_CONTEXT
echo "            "logAbandoned=\"true\" | tee -a $PATH_TO_CONTEXT
echo "            "validationQuery=\"SELECT 1\" | tee -a $PATH_TO_CONTEXT
echo "            "testOnBorrow=\"true\" | tee -a $PATH_TO_CONTEXT
echo "            "testWhileIdle=\"true\" | tee -a $PATH_TO_CONTEXT
echo "            "timeBetweenEvictionRunsMillis=\"10000\" | tee -a $PATH_TO_CONTEXT
echo "            "minEvictableIdleTimeMillis=\"60000\" | tee -a $PATH_TO_CONTEXT
echo "            "name=\"jdbc/$SERVER_MYSQL_DB_NAME\" | tee -a $PATH_TO_CONTEXT
echo "            "username=\"$SERVER_MYSQL_USER\" | tee -a $PATH_TO_CONTEXT
echo "            "password=\"$SERVER_MYSQL_PASS\"| tee -a $PATH_TO_CONTEXT
#echo "            "url=\"jdbc:mysql://$SERVER_MYSQL_HOST:3306/$SERVER_MYSQL_DB_NAME\" /\> | tee -a $PATH_TO_CONTEXT
echo "            "url=\"jdbc:mysql://$SERVER_MYSQL_HOST:3306\" /\> | tee -a $PATH_TO_CONTEXT
echo \</Context\> | tee -a $PATH_TO_CONTEXT

cat $PATH_TO_CONTEXT >> $LOG_FILE
echo [INFO] === END context.xml === | tee -a $LOG_FILE

### --------------------------------------------------------------------------
### write the web/index.html file
### --------------------------------------------------------------------------

echo [INFO] Removing $PATH_TO_INDEX_HTML | tee -a $LOG_FILE
echo [INFO] Recover with svn revert | tee -a $LOG_FILE
rm -f $PATH_TO_INDEX_HTML
echo [INFO] Writing new $PATH_TO_INDEX_HTML | tee -a $LOG_FILE
echo [INFO] === BEGIN index.html === | tee -a $LOG_FILE
echo \<html\> | tee -a $PATH_TO_INDEX_HTML
echo "<!-- $MESSAGE0" | tee -a $PATH_TO_INDEX_HTML 
echo "     $MESSAGE1" | tee -a $PATH_TO_INDEX_HTML 
echo "     $MESSAGE2" | tee -a $PATH_TO_INDEX_HTML 
echo "     $MESSAGE3 -->" | tee -a $PATH_TO_INDEX_HTML
echo "  "\<head\> | tee -a $PATH_TO_INDEX_HTML
echo "    "\<meta http-equiv=\"refresh\" | tee -a $PATH_TO_INDEX_HTML
echo "           "content=\"0\;$PATH_TO_CLIENT_DIRECTORY/\"\> | tee -a $PATH_TO_INDEX_HTML
echo "   "\</head\> | tee -a $PATH_TO_INDEX_HTML
echo \</html\> | tee -a $PATH_TO_INDEX_HTML
cat $PATH_TO_INDEX_HTML >> $LOG_FILE
echo [INFO] === END index.html === | tee -a $LOG_FILE

### --------------------------------------------------------------------------
### write the /web/WEB-INF/classes/log4j.properties file
### --------------------------------------------------------------------------

echo [INFO] Removing $PATH_TO_LOG4J_PROPERTIES | tee -a $LOG_FILE
echo [INFO] Recover with svn revert | tee -a $LOG_FILE
rm -f $PATH_TO_LOG4J_PROPERTIES
echo [INFO] Writing new $PATH_TO_LOG4J_PROPERTIES | tee -a $LOG_FILE
echo [INFO] === BEGIN $LOG4J_PROPERTIES === | tee -a $LOG_FILE
echo "### $MESSAGE0" | tee -a $PATH_TO_LOG4J_PROPERTIES
echo "### $MESSAGE1" | tee -a $PATH_TO_LOG4J_PROPERTIES
echo "### $MESSAGE2" | tee -a $PATH_TO_LOG4J_PROPERTIES
echo "### $MESSAGE3" | tee -a $PATH_TO_LOG4J_PROPERTIES
echo "log4j.rootLogger=$LOG4J_LOG_LEVEL, wayangServer" | tee -a $PATH_TO_LOG4J_PROPERTIES
echo "log4j.appender.wayangServer=org.apache.log4j.RollingFileAppender" | tee -a $PATH_TO_LOG4J_PROPERTIES
echo "log4j.appender.wayangServer.File=$LOG4J_LOG_FILE" | tee -a $PATH_TO_LOG4J_PROPERTIES
echo "log4j.appender.wayangServer.MaxFileSize=10MB" | tee -a $PATH_TO_LOG4J_PROPERTIES
echo "log4j.appender.wayangServer.MaxBackupIndex=10" | tee -a $PATH_TO_LOG4J_PROPERTIES
echo "log4j.appender.wayangServer.layout=org.apache.log4j.PatternLayout" | tee -a $PATH_TO_LOG4J_PROPERTIES
echo "log4j.appender.wayangServer.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss:SSS} %5p (%C{1}.%M %L) - %m%n" | tee -a $PATH_TO_LOG4J_PROPERTIES
cat $PATH_TO_LOG4J_PROPERTIES >> $LOG_FILE
echo [INFO] === END $LOG4J_PROPERTIES === | tee -a $LOG_FILE

### --------------------------------------------------------------------------
### write the web/WEB-INF/web.xml file
### --------------------------------------------------------------------------

echo [INFO] Removing $PATH_TO_WEB_XML | tee -a $LOG_FILE
echo [INFO] Recover with svn revert | tee -a $LOG_FILE
rm -f $PATH_TO_WEB_XML

echo [INFO] Writing new $PATH_TO_WEB_XML | tee -a $LOG_FILE
echo [INFO] === BEGIN $WEB_XML === | tee -a $LOG_FILE
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" | tee -a $PATH_TO_WEB_XML 
echo "  <!-- " | tee -a $PATH_TO_WEB_XML 
echo "    <!DOCTYPE web-app " | tee -a $PATH_TO_WEB_XML 
echo "     PUBLIC \"-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN\"" | tee -a $PATH_TO_WEB_XML 
echo "     \"http://java.sun.com/dtd/web-app_2_3.dtd\">" | tee -a $PATH_TO_WEB_XML 
echo "  -->" | tee -a $PATH_TO_WEB_XML 
echo "<!-- $MESSAGE0" | tee -a $PATH_TO_WEB_XML
echo "     $MESSAGE1" | tee -a $PATH_TO_WEB_XML
echo "     $MESSAGE2" | tee -a $PATH_TO_WEB_XML
echo "     $MESSAGE3 -->" | tee -a $PATH_TO_WEB_XML
echo "<web-app version=\"2.4\" xmlns=\"http://java.sun.com/xml/ns/j2ee\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://java.sun.com/xml/ns/j2ee http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd\">" | tee -a $PATH_TO_WEB_XML 
echo "  <display-name>$APP_NAME</display-name>" | tee -a $PATH_TO_WEB_XML 
### --------------------------------------------------------------------------
### database definition
### --------------------------------------------------------------------------
echo "  <resource-ref>" | tee -a $PATH_TO_WEB_XML 
echo "    <description>$APP_NAME DB</description>" | tee -a $PATH_TO_WEB_XML 
echo "    <res-ref-name>jdbc/$SERVER_MYSQL_DB_NAME</res-ref-name>" | tee -a $PATH_TO_WEB_XML 
echo "    <res-type>javax.sql.DataSource</res-type>" | tee -a $PATH_TO_WEB_XML 
echo "    <res-auth>Container</res-auth>" | tee -a $PATH_TO_WEB_XML 
echo "  </resource-ref>" | tee -a $PATH_TO_WEB_XML 
### --------------------------------------------------------------------------
### chat port
### --------------------------------------------------------------------------
echo "  <context-param>" | tee -a $PATH_TO_WEB_XML 
echo "    <param-name>chat.port</param-name><param-value>$CHAT_PORT</param-value>" | tee -a $PATH_TO_WEB_XML 
echo "  </context-param>" | tee -a $PATH_TO_WEB_XML 
### --------------------------------------------------------------------------
### log4J startup servlet
### --------------------------------------------------------------------------
echo "  <servlet>" | tee -a $PATH_TO_WEB_XML 
echo "    <servlet-name>log4jSetup</servlet-name>" | tee -a $PATH_TO_WEB_XML 
echo "    <servlet-class>edu.usc.k12.sys.server.Log4jSetupServlet</servlet-class>" | tee -a $PATH_TO_WEB_XML 
echo "    <init-param>" | tee -a $PATH_TO_WEB_XML 
echo "      <param-name>log4j.properties</param-name>" | tee -a $PATH_TO_WEB_XML 
echo "      <param-value>$PATH_TO_TOMCAT/webapps/$APP_NAME/WEB-INF/classes/$LOG4J_PROPERTIES</param-value>" | tee -a $PATH_TO_WEB_XML 
echo "    </init-param>" | tee -a $PATH_TO_WEB_XML 
echo "    <load-on-startup>0</load-on-startup>" | tee -a $PATH_TO_WEB_XML 
echo "  </servlet>" | tee -a $PATH_TO_WEB_XML
### --------------------------------------------------------------------------
### Variates random seed setup (-1 implies use system time - the default)
### --------------------------------------------------------------------------
echo "  <servlet>" | tee -a $PATH_TO_WEB_XML
echo "    <servlet-name>variatesSetup</servlet-name>" | tee -a $PATH_TO_WEB_XML
echo "    <servlet-class>edu.usc.k12.sys.server.InitializeVariatesServlet</servlet-class>" | tee -a $PATH_TO_WEB_XML
echo "    <init-param>" | tee -a $PATH_TO_WEB_XML
echo "      <param-name>randomSeed</param-name>" | tee -a $PATH_TO_WEB_XML
echo "      <param-value>-1</param-value>" | tee -a $PATH_TO_WEB_XML
echo "    </init-param>" | tee -a $PATH_TO_WEB_XML
echo "    <load-on-startup>1</load-on-startup>" | tee -a $PATH_TO_WEB_XML
echo "  </servlet>" | tee -a $PATH_TO_WEB_XML
### --------------------------------------------------------------------------
### Tutor servlet
### --------------------------------------------------------------------------
echo "  <servlet>" | tee -a $PATH_TO_WEB_XML 
echo "    <servlet-name>$TUTOR_SERVLET_NAME</servlet-name>" | tee -a $PATH_TO_WEB_XML 
echo "    <servlet-class>$TUTOR_SERVLET_CLASS</servlet-class>" | tee -a $PATH_TO_WEB_XML 
echo "    <init-param>" | tee -a $PATH_TO_WEB_XML 
echo "      <param-name>runmode</param-name>" | tee -a $PATH_TO_WEB_XML 
echo "      <param-value>$TUTOR_SERVLET_RUN_MODE</param-value>" | tee -a $PATH_TO_WEB_XML 
echo "    </init-param>" | tee -a $PATH_TO_WEB_XML 
echo "  </servlet>" | tee -a $PATH_TO_WEB_XML 
echo "  <servlet-mapping>" | tee -a $PATH_TO_WEB_XML 
echo "    <servlet-name>$TUTOR_SERVLET_NAME</servlet-name>" | tee -a $PATH_TO_WEB_XML 
echo "    <url-pattern>$TUTOR_SERVLET_URL</url-pattern>" | tee -a $PATH_TO_WEB_XML 
echo "  </servlet-mapping>" | tee -a $PATH_TO_WEB_XML 
### --------------------------------------------------------------------------
### CPanel servlet
### --------------------------------------------------------------------------
# echo "  <servlet>" | tee -a $PATH_TO_WEB_XML 
# echo "    <servlet-name>$CPANEL_SERVLET_NAME</servlet-name>" | tee -a $PATH_TO_WEB_XML 
# echo "    <servlet-class>$CPANEL_SERVLET_CLASS</servlet-class>" | tee -a $PATH_TO_WEB_XML 
# echo "  </servlet>" | tee -a $PATH_TO_WEB_XML 
### --------------------------------------------------------------------------
### Control Panel
### --------------------------------------------------------------------------
# echo "  <servlet>" | tee -a $PATH_TO_WEB_XML 
# echo "    <servlet-name>$CONTROL_PANEL_NAME</servlet-name>" | tee -a $PATH_TO_WEB_XML 
# echo "    <servlet-class>$CONTROL_PANEL_CLASS</servlet-class>" | tee -a $PATH_TO_WEB_XML 
# echo "  </servlet>" | tee -a $PATH_TO_WEB_XML 
### --------------------------------------------------------------------------
### WO admin servlet
### --------------------------------------------------------------------------
# echo "  <servlet>" | tee -a $PATH_TO_WEB_XML
# echo "    <servlet-name>$WO_ADMIN_SERVLET_NAME</servlet-name>" | tee -a $PATH_TO_WEB_XML
# echo "    <servlet-class>$WO_ADMIN_SERVLET_CLASS</servlet-class>" | tee -a $PATH_TO_WEB_XML
# echo "  </servlet>" | tee -a $PATH_TO_WEB_XML
# echo "  <servlet-mapping>" | tee -a $PATH_TO_WEB_XML
# echo "    <servlet-name>$WO_ADMIN_SERVLET_NAME</servlet-name>" | tee -a $PATH_TO_WEB_XML
# echo "    <url-pattern>$WO_ADMIN_SERVLET_URL</url-pattern>" | tee -a $PATH_TO_WEB_XML
# echo "  </servlet-mapping>" | tee -a $PATH_TO_WEB_XML 
### --------------------------------------------------------------------------
### session configuration
### --------------------------------------------------------------------------
echo "  <session-config>" | tee -a $PATH_TO_WEB_XML 
echo "    <session-timeout>$SESSION_TIMEOUT</session-timeout>" | tee -a $PATH_TO_WEB_XML 
echo "  </session-config>" | tee -a $PATH_TO_WEB_XML 
### --------------------------------------------------------------------------
### mime mapping
### --------------------------------------------------------------------------
echo "  <mime-mapping><extension>txt</extension><mime-type>text/plain</mime-type></mime-mapping>" | tee -a $PATH_TO_WEB_XML 
echo "  <mime-mapping><extension>htm</extension><mime-type>text/html</mime-type></mime-mapping>" | tee -a $PATH_TO_WEB_XML 
echo "  <mime-mapping><extension>gif</extension><mime-type>image/gif</mime-type></mime-mapping>" | tee -a $PATH_TO_WEB_XML 
echo "  <mime-mapping><extension>jpeg</extension><mime-type>image/jpeg</mime-type></mime-mapping>" | tee -a $PATH_TO_WEB_XML 
echo "  <mime-mapping><extension>html</extension><mime-type>text/html</mime-type></mime-mapping>" | tee -a $PATH_TO_WEB_XML 
echo "  <mime-mapping><extension>jpg</extension><mime-type>image/jpeg</mime-type></mime-mapping>" | tee -a $PATH_TO_WEB_XML 
echo "</web-app>" | tee -a $PATH_TO_WEB_XML 

cat $PATH_TO_WEB_XML >> $LOG_FILE
echo [INFO] === END $WEB_XML === | tee -a $LOG_FILE

### --------------------------------------------------------------------------
### run maven clean if this is a production build, otherwise, just run
### maven install
### --------------------------------------------------------------------------

echo [INFO] Changing directory to $SERVER_SOURCE  | tee -a $LOG_FILE
cd $SERVER_SOURCE/

if [ "$BUILD_TYPE" = production ];
then
    echo [INFO] installation type is $BUILD_TYPE - calling mvn clean | tee -a $LOG_FILE
    $MAVEN clean | tee -a $LOG_FILE
else
    echo [INFO] installation type is $BUILD_TYPE - skipping mvn clean | tee -a $LOG_FILE
fi

$MAVEN compile war:war | tee -a $LOG_FILE
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
### stop tomcat
### --------------------------------------------------------------------------

if [ "$OS_NAME" = "Darwin" ]; 
then
    if [ -e $CATALINA_PID ];
    then
        PID=`cat $CATALINA_PID`
        FOUND_PROCESS=`ps auxw | grep $PID | grep -v grep`
        if [ -z "$FOUND_PROCESS" ];
        then
            echo [WARNING] Can not find process with $PID - assuming Tomcat is not running
        else
            echo [INFO] Stopping Tomcat  | tee -a $LOG_FILE
            sudo $PATH_TO_TOMCATCTL stop $TOMCAT_STOP_ARGS > /dev/null # suppress output
        fi
    else
        echo [WARNING] $CATALINA_PID does not exist - assuming Tomcat is not running
    fi
else
    echo [INFO] Stopping Tomcat  | tee -a $LOG_FILE
    sudo $PATH_TO_TOMCATCTL stop $TOMCAT_STOP_ARGS > /dev/null # suppress output
fi

### --------------------------------------------------------------------------
### now we let's rm and/or archive the old build
### --------------------------------------------------------------------------

INNER_ARCHIVE_DIR=$ARCHIVED_BUILD_DIRECTORY/`date +%Y-%m-%d-%H%M%S`

### --------------------------------------------------------------------------
### move or delete the .war 
### --------------------------------------------------------------------------

if [ "$ARCHIVE_OLD_BUILD" = "y" ];
then
    echo [INFO] Creating archive directory $INNER_ARCHIVE_DIR... | tee -a $LOG_FILE
    mkdir -p $INNER_ARCHIVE_DIR
fi

echo [INFO] Testing for $PATH_TO_TOMCAT/webapps/$APP_NAME.war...  | tee -a $LOG_FILE
if [ -e $PATH_TO_TOMCAT/webapps/$APP_NAME.war ];
then 
    if [ "$ARCHIVE_OLD_BUILD" = "y" ];
    then 
        echo [INFO] Archiving  $PATH_TO_TOMCAT/webapps/$APP_NAME.war | tee -a $LOG_FILE
        sudo mv $PATH_TO_TOMCAT/webapps/$APP_NAME.war $INNER_ARCHIVE_DIR
    else
        echo [INFO] Deleting $PATH_TO_TOMCAT/webapps/$APP_NAME.war  | tee -a $LOG_FILE
        sudo rm $PATH_TO_TOMCAT/webapps/$APP_NAME.war
    fi
else 
    echo [WARNING] Nothing to be done: $PATH_TO_TOMCAT/webapps/$APP_NAME.war does not exist  | tee -a $LOG_FILE
fi

### --------------------------------------------------------------------------
### delete the webapps/application directory
### --------------------------------------------------------------------------

echo [INFO] Testing for $PATH_TO_TOMCAT/webapps/$APP_NAME...  | tee -a $LOG_FILE
if [ -d $PATH_TO_TOMCAT/webapps/$APP_NAME ];
then 
    if [ "$ARCHIVE_OLD_BUILD" = "y" ];
    then 
        echo [INFO] Moving $PATH_TO_TOMCAT/webapps/$APP_NAME/deploy.log to $INNER_ARCHIVE_DIR... | tee -a $LOG_FILE
        sudo mv $PATH_TO_TOMCAT/webapps/$APP_NAME/deploy.log $INNER_ARCHIVE_DIR
        # change the mod from 600
        sudo chmod 660 $INNER_ARCHIVE_DIR/deploy.log
    fi
    echo [INFO] Deleting $PATH_TO_TOMCAT/webapps/$APP_NAME  | tee -a $LOG_FILE
    sudo rm -r $PATH_TO_TOMCAT/webapps/$APP_NAME
else 
    echo [WARNING] Nothing to be done: $PATH_TO_TOMCAT/webapps/$APP_NAME does not exist  | tee -a $LOG_FILE
fi

### --------------------------------------------------------------------------
### testing for context files in tomcat/conf/Catalina/localhost 
### --------------------------------------------------------------------------

echo [INFO] Testing for $PATH_TO_TOMCAT/conf/Catalina/localhost/$APP_NAME.xml...  | tee -a $LOG_FILE
if [ -e $PATH_TO_TOMCAT/conf/Catalina/localhost/$APP_NAME.xml ];
then 
    if [ "$ARCHIVE_OLD_BUILD" = "y" ];
    then 
        echo [INFO] Moving $PATH_TO_TOMCAT/conf/Catalina/localhost/$APP_NAME.xml to $INNER_ARCHIVE_DIR... | tee -a $LOG_FILE
        sudo mv $PATH_TO_TOMCAT/conf/Catalina/localhost/$APP_NAME.xml $INNER_ARCHIVE_DIR
    else
        echo [INFO] Deleting $PATH_TO_TOMCAT/conf/Catalina/localhost/$APP_NAME.xml  | tee -a $LOG_FILE
        sudo rm $PATH_TO_TOMCAT/conf/Catalina/localhost/$APP_NAME.xml 
    fi
else 
    echo [WARNING] Nothing to be done: $PATH_TO_TOMCAT/conf/Catalina/localhost/$APP_NAME.xml does not exist  | tee -a $LOG_FILE
fi

### --------------------------------------------------------------------------

echo [INFO] Testing for $PATH_TO_TOMCAT/conf/Catalina/localhost/weborb.xml...  | tee -a $LOG_FILE
if [ -e $PATH_TO_TOMCAT/conf/Catalina/localhost/weborb.xml ];
then 
    if [ "$ARCHIVE_OLD_BUILD" = "y" ];
    then 
        echo [INFO] Moving $PATH_TO_TOMCAT/conf/Catalina/localhost/weborb.xml to $INNER_ARCHIVE_DIR... | tee -a $LOG_FILE
        sudo mv $PATH_TO_TOMCAT/conf/Catalina/localhost/weborb.xml $INNER_ARCHIVE_DIR
    else
        echo [INFO] Deleting $PATH_TO_TOMCAT/conf/Catalina/localhost/weborb.xml  | tee -a $LOG_FILE
        sudo rm $PATH_TO_TOMCAT/conf/Catalina/localhost/weborb.xml 
    fi
else 
    echo [WARNING] Nothing to be done: $PATH_TO_TOMCAT/conf/Catalina/localhost/weborb.xml does not exist  | tee -a $LOG_FILE
fi

### --------------------------------------------------------------------------
### change the ownership of the archive directory
### --------------------------------------------------------------------------

if [ "$ARCHIVE_OLD_BUILD" = "y" ];
then
    echo [INFO] Changing ownership of $ARCHIVED_BUILD_DIRECTORY... | tee -a $LOG_FILE
    sudo chown -R $USERNAME:$USERNAME $ARCHIVED_BUILD_DIRECTORY
fi

### --------------------------------------------------------------------------
### move the new war from the build directory to the tomcat/webapps dir
### --------------------------------------------------------------------------

echo [INFO] Copying $SERVER_SOURCE/target/$APP_NAME.war to $PATH_TO_TOMCAT/webapps/  | tee -a $LOG_FILE
sudo cp -r $SERVER_SOURCE/target/$APP_NAME.war $PATH_TO_TOMCAT/webapps/

### --------------------------------------------------------------------------
### copy context.xml to weborb/META-INF/context.xml and
###                     tomcat/conf/Catalina/localhost/weborb.xml
### will chown later
### --------------------------------------------------------------------------

echo [INFO] Copying $PATH_TO_CONTEXT to $PATH_TO_TOMCAT/webapps/$WEBORB_DIRECTORY_NAME/META-INF/context.xml | tee -a $LOG_FILE
sudo cp $PATH_TO_CONTEXT $PATH_TO_TOMCAT/webapps/$WEBORB_DIRECTORY_NAME/META-INF/context.xml 

echo [INFO] Copying $PATH_TO_CONTEXT to $PATH_TO_TOMCAT/conf/Catalina/localhost/weborb.xml | tee -a $LOG_FILE
sudo cp $PATH_TO_CONTEXT $PATH_TO_TOMCAT/conf/Catalina/localhost/weborb.xml | tee -a $LOG_FILE

### --------------------------------------------------------------------------
### installing weborb
### --------------------------------------------------------------------------

PATH_TO_APP_CLASSES=$SERVER_SOURCE/target/classes
PATH_TO_WEBORB_CLASSES=$PATH_TO_TOMCAT/webapps/$WEBORB_DIRECTORY_NAME/WEB-INF/classes/ # [pace]                                                                          

echo [INFO] Installing files for WebORB...  | tee -a $LOG_FILE
for dir in `ls $PATH_TO_APP_CLASSES`;
  do
  if [ -d $PATH_TO_APP_CLASSES/$dir ];
      then
      echo [INFO] Copying $PATH_TO_APP_CLASSES/$dir to $PATH_TO_WEBORB_CLASSES  | tee -a $LOG_FILE
      sudo cp -r $PATH_TO_APP_CLASSES/$dir $PATH_TO_WEBORB_CLASSES
  fi
done

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
### fix index.html in ROOT, if this is production 
### --------------------------------------------------------------------------

echo [INFO] checking installation type "{dev | production}"... | tee -a $LOG_FILE
echo [INFO] found installation type $BUILD_TYPE | tee -a $LOG_FILE
if [ "$BUILD_TYPE" = "production" ];
then

    TMP_ROOT_INDEX_HTML=/tmp/index-`date +%Y%m%d%H%M%S`.html
    echo [INFO] writing temporary index.html file to $TMP_ROOT_INDEX_HTML | tee -a $LOG_FILE
    PATH_TO_APP_CLIENT=$APP_NAME/client
    echo [INFO] Removing $PATH_TO_TOMCAT/webapps/ROOT/index.html | tee -a $LOG_FILE
    if [ -e $PATH_TO_TOMCAT/webapps/ROOT/index.html ];
    then 
        sudo rm -f $PATH_TO_TOMCAT/webapps/ROOT/index.html
    else 
        echo [WARNING] there is no $PATH_TO_TOMCAT/webapps/ROOT/index.html | tee -a $LOG_FILE
    fi
    echo [INFO] Writing new $TMP_ROOT_INDEX_HTML | tee -a $LOG_FILE
    echo [INFO] === BEGIN index.html === | tee -a $LOG_FILE
    echo \<html\> | tee -a $TMP_ROOT_INDEX_HTML
    echo "<!-- $MESSAGE0" | tee -a $TMP_ROOT_INDEX_HTML
    echo "     $MESSAGE1" | tee -a $TMP_ROOT_INDEX_HTML
    echo "     $MESSAGE2 -->" | tee -a $TMP_ROOT_INDEX_HTML
    echo "  "\<head\> | tee -a $TMP_ROOT_INDEX_HTML
    echo "    "\<meta http-equiv=\"refresh\" | tee -a $TMP_ROOT_INDEX_HTML
    echo "           "content=\"0\;$PATH_TO_APP_CLIENT/\"\> | tee -a $TMP_ROOT_INDEX_HTML
    echo "   "\</head\> | tee -a $TMP_ROOT_INDEX_HTML
    echo \</html\> | tee -a $TMP_ROOT_INDEX_HTML
    cat $TMP_ROOT_INDEX_HTML >> $LOG_FILE
    echo [INFO] === END index.html === | tee -a $LOG_FILE
    echo [INFO] copying $TMP_ROOT_INDEX_HTML to $PATH_TO_TOMCAT/webapps/ROOT | tee -a $LOG_FILE
    sudo cp $TMP_ROOT_INDEX_HTML $PATH_TO_TOMCAT/webapps/ROOT/index.html
    rm $TMP_ROOT_INDEX_HTML
else
    echo [INFO] Nothing to be done for $BUILD_TYPE | tee -a $LOG_FILE
fi

### --------------------------------------------------------------------------
### changing owner:group for the tomcat directory
### --------------------------------------------------------------------------

echo [INFO] Changing owner:group to $TOMCAT_USER:$TOMCAT_GROUP for $PATH_TO_TOMCAT  | tee -a $LOG_FILE
sudo chown -RL $TOMCAT_USER:$TOMCAT_GROUP $PATH_TO_TOMCAT

########################################################################

echo [INFO] Starting Tomcat...  | tee -a $LOG_FILE
sudo $PATH_TO_TOMCATCTL start $TOMCAT_START_ARGS > /dev/null # suppressing output

while [ ! -d $PATH_TO_TOMCAT/webapps/$APP_NAME ]
do
    echo [INFO] Waiting for $PATH_TO_TOMCAT/webapps/$APP_NAME.war to deploy...  | tee -a $LOG_FILE
    sleep 1
done

########################################################################

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

sudo cp $LOG_FILE $PATH_TO_TOMCAT/webapps/woj/

### --------------------------------------------------------------------------
### making deploy.log unreadable
### --------------------------------------------------------------------------
sudo chmod 600 $PATH_TO_TOMCAT/webapps/woj/deploy.log

DEPLOY_DATE=`date +%Y%m%d%H%M%S`
echo [INFO] Copying $LOG_FILE to $SERVER_SOURCE/logs/deploy/deploy-$DEPLOY_DATE.log
cp $LOG_FILE $SERVER_SOURCE/logs/deploy/deploy-$DEPLOY_DATE.log

exit 0

### --------------------------------------------------------------------------
### dead sea
### --------------------------------------------------------------------------
