#!/bin/sh

### --------------------------------------------------------------------------
### provide support for Linux and Darwin
### --------------------------------------------------------------------------
OS_NAME=`uname`

if [ "$OS_NAME" = "Darwin" ]; 
then
    TOMCAT_USER=www
    TOMCAT_GROUP=www
    DARWIN_MAJOR_VERSION=`uname -r | cut -f 1 -d '.'`
    if [ $DARWIN_MAJOR_VERSION -eq 9 ];
    then 
        TOMCAT_USER=_www
        TOMCAT_GROUP=_www
    fi
else
    TOMCAT_USER=tomcat6
    TOMCAT_GROUP=admin
fi

sudo chown -RL $TOMCAT_USER:$TOMCAT_GROUP /usr/local/tomcat