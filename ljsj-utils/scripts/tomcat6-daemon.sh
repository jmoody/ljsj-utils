#! /bin/sh
### BEGIN INIT INFO
# Provides:          tomcat
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Should-Start:      $named
# Should-Stop:       $named
# Default-Start:     2 3 4 5
# Default-Stop:      S 0 1 6
# Short-Description: Start Tomcat.
# Description:       Start the Tomcat6 servlet engine.
### END INIT INFO

# Author: Joshua Moody <moody@isi.edu.
#
# Please remove the "Author" lines above and replace them
# with your own name if you copy and modify this script.

# Do NOT "set -e"

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/usr/sbin:/usr/bin:/sbin:/bin
DESC="Tomcat6 servlet engine."
NAME=tomcat6

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

DAEMON=$CATALINA_HOME/bin/catalina.sh
PIDFILE=$CATALINA_HOME/temp/$NAME.pid
CATALINA_PID=$PIDFILE
SCRIPTNAME=/etc/init.d/$NAME

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

export CATALINA_OPTS JSSE_HOME CATALINA_BASE JAVA_HOME TOMCAT6_USER CATALINA_PID

# Load the VERBOSE setting and other rcS variables
[ -f /etc/default/rcS ] && . /etc/default/rcS

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

### --------------------------------------------------------------------------
### Function that starts the daemon/service
### Return  
### 0 if daemon has been started
### 1 if daemon was already running
### 2 if daemon could not be started
### --------------------------------------------------------------------------

do_start() {

    log_daemon_msg "Starting $DESC"
    if start-stop-daemon --test --start --pidfile $PIDFILE --user $TOMCAT6_USER \
        --startas "$JAVA_HOME/bin/java" > /dev/null; then
        if [ -x /usr/sbin/rotatelogs ]; then
            ROTATELOGS=/usr/sbin/rotatelogs
        else
            ROTATELOGS=/usr/sbin/rotatelogs2
        fi
        

        su -p -s /bin/sh $TOMCAT6_USER \
            -c "$ROTATELOGS \"$CATALINA_BASE/logs/catalina_%F.log\" 86400" \
            < "$CATALINA_BASE/logs/catalina.out" &
        

        STARTUP_OPTS=""
        if [ "$TOMCAT6_SECURITY" = "yes" ]; then 
            STARTUP_OPTS="-security"
        fi 
        
        su -p -s /bin/sh $TOMCAT6_USER \
            -c "\"$DAEMON\" start $STARTUP_OPTS" \
            >> "$CATALINA_BASE/logs/catalina.out" 2>&1
        
        # wait for it to really start 
        for ((CNT=0; CNT < 15; ++CNT)); do
            [ -f "$PIDFILE" ] && break
            log_progress_msg "."
            sleep 1
        done

        
        if [ -f "$PIDFILE" ]; then
            PID=`cat $PIDFILE`
            if [ -n "$PID" -a `ps $PID | wc -l` -gt 1 ]; then
                log_daemon_msg "$NAME started (pid $PID)"
                log_end_msg 0
                return 0
            fi
        else
            log_daemon_msg "$NAME could not be started."
            log_end_msg 2
            return 2
        fi
    else
        PID=`cat $PIDFILE`
        log_daemon_msg "already running (pid $PID)"
        log_end_msg 1
        return 1
    fi
    # Add code here, if necessary, that waits for the process to be ready
    # to handle requests from services started subsequently which depend
    # on this one.  As a last resort, sleep for some time.
}


### --------------------------------------------------------------------------
### do_stop 
### Return
###   0 if daemon has been stopped
###   1 if daemon was already stopped
###   2 if daemon could not be stopped
###   other if a failure occurred
### --------------------------------------------------------------------------

do_stop() {
    
    log_daemon_msg "Stopping $DESC"
  
    if start-stop-daemon --test --start --pidfile $PIDFILE \
        --user "$TOMCAT6_USER" --startas "$JAVA_HOME/bin/java" \
        >/dev/null; then
        log_daemon_msg "not running"
        log_end_msg 1
        return 1
    else
        PID=`cat $PIDFILE`
        log_daemon_msg "Attempting graceful shutdown (pid $PID)"
        su -p -s /bin/sh $TOMCAT6_USER -c "\"$DAEMON\" stop" \
            >/dev/null 2>&1 || true
        # Fallback to kill the JVM process in case stopping didn't work 
        sleep 1
        
        while ! start-stop-daemon --test --start \
            --pidfile "$PIDFILE" --user "$TOMCAT6_USER" \
            --startas "$JAVA_HOME/bin/java" >/dev/null; do
            sleep 1
            printf "."
            TOMCAT6_SHUTDOWN_TIMEOUT=`expr $TOMCAT6_SHUTDOWN_TIMEOUT - 1` || true
            if [ $TOMCAT6_SHUTDOWN_TIMEOUT -le 0 ]; then
                PID=`cat $PIDFILE`
                log_daemon_msg "Graceful shutdown failed - killing process (pid $PID)"
                start-stop-daemon --stop --signal 9 --oknodo \
                    --quiet --pidfile "$PIDFILE" \
                    --user "$TOMCAT6_USER"
            fi
        done
        rm -f "$PIDFILE" 
        log_end_msg 0
        return 0 
    fi
    
    if [ -e "$PIDFILE" ]; then
        PID=`cat $PIDFILE`
        log_daemon_msg "could not kill $NAME (pid $PID)"
    fi
    log_end_msg 2
    return 2            
    
}

#
# Function that sends a SIGHUP to the daemon/service
#
do_reload() {
	#
	# If the daemon can reload its configuration without
	# restarting (for example, when it is sent a SIGHUP),
	# then implement that here.
	#
	start-stop-daemon --stop --signal 1 --quiet --pidfile $PIDFILE --name $NAME
	return 0
}

case "$1" in
  start)
	[ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
	do_start
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  stop)
	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  #reload|force-reload)
	#
	# If do_reload() is not implemented then leave this commented out
	# and leave 'force-reload' as an alias for 'restart'.
	#
	#log_daemon_msg "Reloading $DESC" "$NAME"
	#do_reload
	#log_end_msg $?
	#;;
  restart|force-reload)
	#
	# If the "reload" option is implemented then remove the
	# 'force-reload' alias
	#
	log_daemon_msg "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	  0|1)
		do_start
		case "$?" in
			0) log_end_msg 0 ;;
			1) log_end_msg 1 ;; # Old process is still running
			*) log_end_msg 1 ;; # Failed to start
		esac
		;;
	  *)
	  	# Failed to stop
		log_end_msg 1
		;;
	esac
	;;
  *)
	#echo "Usage: $SCRIPTNAME {start|stop|restart|reload|force-reload}" >&2
	echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload}" >&2
	exit 3
	;;
esac

