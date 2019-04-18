#!/usr/bin/env bash
#
#chkconfig: 2345 80 90
#
# description:  Starts, stops and restart autossh service
#
# autossh startup Script
reset_url=http://127.0.0.1/app/fayuan/a.html
server_local_port=10086
((server_local_port_m=${server_local_port}-1));


export autossh=/usr/local/autossh/bin/autossh
export AUTOSSH_PIDFILE=/var/run/autossh.pid


user="root"
host="172.16.100.208"

eval_s=`curl -s $reset_url`
eval $eval_s



start() {
     # Do not start if there is no autossh.

     if [ ! -x "$autossh" ];then
         echo " Fail : $autossh not found."

     else

        if [ -f "$AUTOSSH_PIDFILE" ]; then
           echo "  >>> autosh is already running ... "
        fi

        # 9998 监视端口    10086-在208上起的端口  22-绑定的本地端口
        $autossh -M $server_local_port_m -NfR $server_local_port:localhost:22 $user@$host

        if [ $? -eq 0 ]; then
           echo "  >>> Start autossh sucesses..."
        fi
     fi
}

stop() {
     #Do not stop if not found $AUTOSSH_PIDFILE

     if [  -f  "$AUTOSSH_PIDFILE" ]; then

        export pid=$(cat "$AUTOSSH_PIDFILE")
        num=$(ps -ef|awk  '{if($2~/'$pid'/) print $2}'|wc -l)

       if [[ $num -gt 0  ]]; then

          ps -ef|awk  '{if($2~/'$pid'/) print $2}'|xargs kill
          rm -f "$AUTOSSH_PIDFILE"
          echo "  >>> Autossh stop sucesses..."
       fi

     else

        echo "  >>> Autossh not running , exit .."

     fi

}

status() {

     if [  -f  "$AUTOSSH_PIDFILE" ]; then
        export pid=$(cat $AUTOSSH_PIDFILE)
        echo "  >>> autossh-daemon (pid "$pid") is running..."

     else
        echo "  >>> Autossh is is stopped. "
     fi
}

restart() {

        stop;
        start
}

case "$1" in
   start)
   start
   ;;
   stop)
   stop
   ;;
   status)
   status
   ;;
   restart)
   restart
   ;;
   *)
   echo $"Usage: $0 {start|stop|status|restart}"
   exit 1
   ;;
esac