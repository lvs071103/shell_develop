#!/bin/sh

fullPath="/data/trunk/server/bin/LoginDataServer"
baseDir="/data/trunk/server"
binaryName=$(basename $fullPath)
logDir="."
logFile="$logDir/$(date +"%Y-%m-%d")_${binaryName}.log"


if [ ! -e "$logFile" ];then
  touch ${logFile}
fi

log() {
  echo "$1" >> "$logFile" 2>&1
}

checkPidExists() {
  if [ -z `pidof ${binaryName}` ]; then
    return 0
  else
    return 1
  fi
}

startDaemon()
{
  checkPidExists
  num=$?
  if [[ "$num" -eq 1 ]];then
    echo "${binaryName} is already running"
    exit 1
  fi
  cd $baseDir && ./bin/$binaryName &
  if [ $? -eq 0 ];then
    sleep 3
    echo -e "Starting ${binaryName}\t\t\e[32;40;1mDone\e[0m"
  fi
  log '*** '`date +"%Y-%m-%d"`": Starting up ${binaryName}."
}

stopDaemon()
{
  checkPidExists
  num=$?
  if [ "$num" -eq 0 ];then
    echo "${binaryName} is not running"
    exit 1
  fi
  if [ ! -z `pidof ${binaryName}` ];then
    kill -2 `pidof ${binaryName}` &> /dev/null
    while :
    do
      checkPidExists
      num=$?
      if [ "$num" -eq 0 ];then
        break
      fi
    done

    if [ "$?" -eq 0 ];then
      echo -e "Stop ${binaryName}\t\t\e[32;40;1mDone\e[0m"
    fi
    log '*** '`date +"%Y-%m-%d"`": ${binaryName} stopped."
  fi
}

statusDaemon() {
  checkPidExists
  num=$?
  if [ "$num" -eq 1 ]; then
    echo " * ${binaryName} is running."
  else
    echo " * ${binaryName} isn't running."
  fi
  exit 0
}

restartDaemon() {
  checkPidExists
  num=$?
  if [ "$num" -eq 0 ]; then
    echo "${binaryName} isn't running."
    exit 1
  fi
  stopDaemon
  while :
    do
      checkPidExists
      num=$?
      if [ $num -eq 0 ];then
        break
      fi
  done
  startDaemon
}


case "$1" in
  start)
    startDaemon
    ;;
  stop)
    stopDaemon
    ;;
  status)
    statusDaemon
    ;;
  restart)
    restartDaemon
    ;;
  help|*)
  echo -e "\033[31;44;1mError\033[0m: usage $0 { start | stop | restart | status }"
  cat <<EOF

    start           - start $binaryName
    stop            - stop $binaryName
    status          - show current status of $binaryName
    restart         - restart $binaryName if running by sending a SIGHUP
    help            - this screen

EOF

  exit 1
esac

exit 0
