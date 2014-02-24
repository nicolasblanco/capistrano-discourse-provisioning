#! /bin/sh
### BEGIN INIT INFO
# Provides:          god
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: God initscript
### END INIT INFO

# This is a Generated Init Script see the source: https://github.com/donnoman/cap-recipes/blob/master/lib/cap_recipes/tasks/god/god.init

# Author: Johnny Domino (domino@cmu.edu)
# Adapted: Donovan Bray (donnoman@donovanbray.com)

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH="/home/web/.rbenv/bin:/home/web/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
RBENV_VERSION=2.1.1

DESC="God Monitoring Tool"
NAME=god
CONF=/home/web/god/sidekiq.god
LEVEL=info
LOGFILE="/var/log/god/god.log" ; mkdir -p `dirname $LOGFILE`
PIDFILE="/var/log/god/god.pid" ; mkdir -p `dirname $PIDFILE`
DAEMON=/usr/local/bin/god
DAEMON_ARGS="-c $CONF -P $PIDFILE --log-level $LEVEL --log $LOGFILE"
SCRIPTNAME=/etc/init.d/god
OPEN_SOCKET=no
USE_TERMINATE_ON_KILL=yes

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{
    # Return
    #   0 if daemon has been started
    #   1 if daemon was already running
    #   2 if daemon could not be started
    start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON --test > /dev/null \
        || return 1
    start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON -- \
        $DAEMON_ARGS \
        || return 2
    # Add code here, if necessary, that waits for the process to be ready
    # to handle requests from services started subsequently which depend
    # on this one.  As a last resort, sleep for some time.
    [ "$OPEN_SOCKET" != no ] && sleep 3 && sh -c "chmod 0777 /tmp/god.*.sock;true"
}

# kills god + everything god is monitoring
do_terminate()
{
    $DAEMON terminate
    RETVAL="$?"
    return "$RETVAL"
}

#
# Function that stops the daemon/service
#
do_stop()
{
    $DAEMON quit
    RETVAL="$?"
    return "$RETVAL"
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
    log_daemon_msg "Reloading $DESC" "$NAME"
    $DAEMON load $CONF
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
    if [ "$0" != "$SCRIPTNAME" ] && [ "$USE_TERMINATE_ON_KILL" = "yes" ]; then
      [ "$VERBOSE" != no ] && log_daemon_msg "Terminating $DESC" "$NAME"
      do_terminate
    else
      [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
      do_stop
    fi
    case "$?" in
        0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
        2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
    ;;
  terminate)
    [ "$VERBOSE" != no ] && log_daemon_msg "Terminating $DESC" "$NAME"
    do_terminate
    case "$?" in
            0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
            2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
    ;;
  status)
    $DAEMON status && exit 0 || exit $?
    status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
    ;;
  reload|force-reload)
    do_reload
    log_end_msg $?
    ;;
  restart)
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
    echo "Usage: $SCRIPTNAME {start|stop|status|restart|terminate|force-reload}" >&2
    exit 3
    ;;
esac
