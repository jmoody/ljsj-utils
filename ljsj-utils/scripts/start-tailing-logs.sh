#!/bin/sh

### --------------------------------------------------------------------------
### Discussion:
### utility for tailing remote logs using ssh and tail on Mac OS Leopard
### requires:  ssh2 and password caching (available only in Leopard)
### Log files are placed in ~/Library/Logs/Remote/ by default, but this 
### can be altered as needed.
### Currently supports logging on roslin and adama.
### Usage:  roslin.cs.arizona.edu and adama.cs.arizona.edu must be in your 
### ~/.ssh/known-hosts file _before_ you execute this script
### --------------------------------------------------------------------------

### --------------------------------------------------------------------------
### works without a password when using vpn and ssh2
### --------------------------------------------------------------------------

CATALINA_OUT="tomcat/logs/catalina.out"
WOJ_LOG="tomcat/logs/woj.log"
ROSLIN_TAIL_HISTORY="1000"
ADAMA_TAIL_HISTORY="10000"


### --------------------------------------------------------------------------

REMOTE_LOG_DIR="/Users/moody/Library/Logs/Remote"
ROSLIN_TOMCAT_LOG="$REMOTE_LOG_DIR/roslin-catalina.log"
ROSLIN_TOMCAT_PID=
ROSLIN_TOMCAT_PID_FILE="/tmp/roslin-catalina.pid"
ROSLIN_WOJ_PID=
ROSLIN_WOJ_PID_FILE="/tmp/roslin-woj.pid"
ROSLIN_WOJ_LOG="$REMOTE_LOG_DIR/roslin-woj.log"

### --------------------------------------------------------------------------

ADAMA_TOMCAT_LOG="$REMOTE_LOG_DIR/adama-catalina.log"
ADAMA_TOMCAT_PID=
ADAMA_TOMCAT_PID_FILE="/tmp/adama-catalina.pid"
ADAMA_WOJ_PID=
ADAMA_WOJ_PID_FILE="/tmp/adama-woj.pid"
ADAMA_WOJ_LOG="$REMOTE_LOG_DIR/adama-woj.log"

### --------------------------------------------------------------------------
### if remote log directory does not exist, create it
### --------------------------------------------------------------------------

if [ ! -d $REMOTE_LOG_DIR ]; then
    mkdir $REMOTE_LOG_DIR
fi


### --------------------------------------------------------------------------
### stop any running ssh/tail processes
### --------------------------------------------------------------------------

for pid_file in $ROSLIN_TOMCAT_PID_FILE $ROSLIN_WOJ_PID_FILE $ADAMA_TOMCAT_PID_FILE $ADAMA_WOJ_PID_FILE; 
do
    if [ -e $pid_file ]; then
        pid=`cat $pid_file`
        if [ ! -z "$pid" ];
        then
            #echo $pid_file " = " $pid
            process_exists=`ps auxw | grep $pid | grep -v grep`
            if [ ! -z "$process_exists" ];
            then
                kill -9 $pid
            fi
        fi
    fi
done

### --------------------------------------------------------------------------
### remove any existing log files
### --------------------------------------------------------------------------

for log_file in $ROSLIN_TOMCAT_LOG $ROSLIN_WOJ_LOG $ADAMA_TOMCAT_LOG $ADAMA_WOJ_LOG;
do
    if [ -e $log_file ]; 
    then
        rm -f $log_file
    fi
done

### --------------------------------------------------------------------------
### perform the ssh/tail operation for roslin
### --------------------------------------------------------------------------

ROSLIN_TOMCAT_PID=`ssh roslin.cs.arizona.edu "tail -n $ROSLIN_TAIL_HISTORY -F $CATALINA_OUT" >> $ROSLIN_TOMCAT_LOG & echo $!`
echo $ROSLIN_TOMCAT_PID 1> $ROSLIN_TOMCAT_PID_FILE
ROSLIN_WOJ_PID=`ssh roslin.cs.arizona.edu "tail -n $ROSLIN_TAIL_HISTORY -F $WOJ_LOG" >> $ROSLIN_WOJ_LOG & echo $!`
echo $ROSLIN_WOJ_PID 1> $ROSLIN_WOJ_PID_FILE

### --------------------------------------------------------------------------
### perform the ssh/tail operation for adama
### --------------------------------------------------------------------------

ADAMA_TOMCAT_PID=`ssh adama.cs.arizona.edu "tail -n $ADAMA_TAIL_HISTORY -F $CATALINA_OUT" >> $ADAMA_TOMCAT_LOG & echo $!`
echo $ADAMA_TOMCAT_PID 1> $ADAMA_TOMCAT_PID_FILE
ADAMA_WOJ_PID=`ssh adama.cs.arizona.edu "tail -n $ADAMA_TAIL_HISTORY -F $WOJ_LOG" >> $ADAMA_WOJ_LOG & echo $!`
echo $ADAMA_WOJ_PID 1> $ADAMA_WOJ_PID_FILE

### ***************************************************************************
### *                              End of File                                *
### ***************************************************************************

