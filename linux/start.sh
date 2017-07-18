#!/bin/bash

#author vinter edit

#启动执行: ./start.sh start | stop

appName=server-account
version=1.0.0


logPath=/logs/act

targetName=${appName}-${version}
pidFile=/dbdata/pid/${appName}.pid

mainClass=com.gftech.ct.account.AccountApplication

logFile=act-stdout.log

function stop(){
  c="`ps -ef | grep -c ${mainClass}`"
  if [ $c -gt 1 ]; then
    if [ -f ${pidFile} ]; then
      kill -9 `cat ${pidFile}`
      echo "" > ${pidFile}
      echo "killing ${appName}"
      sleep 1
    fi
  fi
}

function start(){
  stop;
  echo "starting $targetName"
  LIB_DIR=./lib
  cp=$CLASSPATH:.
  files=`ls -1 ${LIB_DIR}`
  for file in ${files} ;do
    cp=$cp:${LIB_DIR}/${file}
  done

  currentDateTime=`date '+%Y%m%d%H%M%S'`
  logs=${logPath}/act-stdout-${currentDateTime}.log
  mv ${logPath}/${logFile} ${logs}
  java -Xmx2048m -Xms2048m -Xmn1024m -Xss256m -cp "$cp" ${mainClass} > ${logPath}/${logFile} 2>&1 &
  echo $! > ${pidFile}
  echo "started pid:$!"
}

case $1 in
  start)
    start
  ;;
  stop)
    stop
  ;;
  *)
    echo "require argument: start | stop"
esac

exit 0