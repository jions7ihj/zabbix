#!/bin/bash
# Author ranruichun
#Date/Time 
#CDATE=$(date "+%Y-%m-%d")
CDATE=$(date "+%Y%m%d")
CTIME=$(date "+%Y-%m-%d-%H-%M")

#Shell
CODE_DIR="/root/git_code/fblive"
TMP_API_DIR="/package/fblive-api-web"
TMP_WWW_DIR="/package/fblive-www-web"
TMP_ROBOT_DIR="/package/robot"
TMP_Taskqueue_DIR="/package/Taskqueue"
TMP_liveserver2_DIR="/package/liveserver2"
MODIFY_API_DIR="/root/data/api.fenbei.com/tomcat/WEB-INF/lib"
MODIFY_WWW_DIR="/root/data/www.fenbei.com/tomcat/WEB-INF/lib"
MODIFY_Robot="/root/data/FBLive5.Robot/lib"
MODIFY_Taskqueue="/root/data/FBLive5.Taskqueue/lib"
MODIFY_liveserver2="/root/liveserver2/lib"

git_pro(){
   rm -rf /root/git_code/*
   cd /root/git_code && git clone -b fblive-dev1.5.7 http://deploy:1234567890@192.168.1.232:8001/git/zhengdi/fblive.git
   echo "begin git pull"
   cd "$CODE_DIR" &&  git pull
   sed -i "s#private static boolean isLocal = false#private static boolean isLocal =  true#g" /root/git_code/fblive/fblive-lib/src/main/java/com/decibel/fblive/base/data/RedisSession.java
   API_VERL=$(git show|grep commit |cut -d ' '   -f2)
   API_VER=$(echo ${API_VERL:0:7})
   TAR_VER="$API_VER"-"$CTIME"
}

mvn_pro(){
    echo "mvn pro"
    cd "$CODE_DIR" &&  mvn clean >/dev/null
    cd "$CODE_DIR" &&  mvn install >/dev/null
    if [ $? -eq 0 ]; then
         echo "mvn success"
  else
       exit 123
      echo "mvn fail"
    fi    
}

cp_pro(){
   echo "begin cp" 
 cp /root/git_code/fblive/fblive-api/fblive-api-web/target/fblive-api-web-*.jar $TMP_API_DIR/$TAR_VER-fblive-api-web-1.5.0.jar
 cp /root/git_code/fblive/fblive-lib/target/fblive-lib-*.jar  $TMP_API_DIR/$TAR_VER-fblive-lib-1.5.0.jar 
 cp /root/git_code/fblive/fblive-web-www/target/fblive-web-www-*.jar  $TMP_WWW_DIR/$TAR_VER-fblive-web-www-1.5.0.jar
 cp /root/git_code/fblive/fblive-lib/target/fblive-lib-*.jar  $TMP_WWW_DIR/$TAR_VER-fblive-lib-1.5.0.jar 
}

deploy_pro_fenbei(){
  echo "begin deploy"
  rm -rf $MODIFY_API_DIR/fblive-api-web-1.5.0.jar
  rm -rf $MODIFY_API_DIR/fblive-lib-1.5.0.jar   
  rm -rf $MODIFY_WWW_DIR/fblive-lib-1.5.0.jar
  rm -rf $MODIFY_WWW_DIR/fblive-web-www-1.5.0.jar
 # ln -s $TMP_DIR/$TAR_VER-fblive-api-web-1.5.0.jar   $MODIFY_API_DIR/fblive-api-web-1.5.0.jar
   /bin/cp -f  $TMP_API_DIR/$TAR_VER-fblive-api-web-1.5.0.jar   $MODIFY_API_DIR/fblive-api-web-1.5.0.jar
   /bin/cp -f  $TMP_API_DIR/$TAR_VER-fblive-lib-1.5.0.jar       $MODIFY_API_DIR/fblive-lib-1.5.0.jar
   /bin/cp -f  $TMP_WWW_DIR/$TAR_VER-fblive-lib-1.5.0.jar       $MODIFY_WWW_DIR/fblive-lib-1.5.0.jar
   /bin/cp -f  $TMP_WWW_DIR/$TAR_VER-fblive-web-www-1.5.0.jar   $MODIFY_WWW_DIR/fblive-web-www-1.5.0.jar
   fenbei_restart;
}
   
fenbei_restart(){
/sbin/service tomcat1 stop
     sleep 10
  /sbin/service  tomcat1 start
}

Robot_restart(){
  ssh -p 22  root@192.168.1.230  '/root/data/FBLive5.Robot/bin/FBLive5.Robot restart'
}

Taskqueue_restart(){
  ssh -p 22  root@192.168.1.230  '/root/data/FBLive5.Taskqueue/bin/FBLive5.Taskqueue  restart'
}

liveserver2_restart(){
  echo "start restart liveserver2-230"
  ssh -p 22  root@192.168.1.230  '/root/liveserver2/bin/FBLive2.server restart'
  echo "start restart liveserver2-229"
  ssh -p 22  root@192.168.1.229  '/root/liveserver2/bin/FBLive2.server restart' 
}

deploy_pro_FBLive5Robot(){
  cp  /root/git_code/fblive/fblive-api/fblive-api-robot/target/fblive*.jar   $TMP_ROBOT_DIR/$TAR_VER-fblive-api-robot-1.5.0.jar
  cp  /root/git_code/fblive/fblive-lib/target/*.jar  $TMP_ROBOT_DIR/$TAR_VER-fblive-lib-1.5.0.jar
  ssh -p 22  root@192.168.1.230  'rm -rf /root/data/FBLive5.Robot/lib/fblive-api-robot-1.5.0.jar'
  ssh -p 22  root@192.168.1.230  'rm -rf /root/data/FBLive5.Robot/lib/fblive-lib-1.5.0.jar'
  scp     $TMP_ROBOT_DIR/$TAR_VER-fblive-api-robot-1.5.0.jar   192.168.1.230:$MODIFY_Robot/fblive-api-robot-1.5.0.jar
  scp     $TMP_ROBOT_DIR/$TAR_VER-fblive-lib-1.5.0.jar    192.168.1.230:$MODIFY_Robot/fblive-lib-1.5.0.jar
  Robot_restart
}

deploy_pro_FBLive5Taskqueue(){
#  scp /root/git_code/fblive/fblive-api/fblive-api-taskqueue/target/fblive-api-taskqueue-1.5.0.jar 192.168.1.230:$TMP_ROBOT_DIR/$TAR_VER-fblive-api-taskqueue-1.5.0.jar
#  scp /root/git_code/fblive/fblive-lib/target/fblive-lib-1.5.0.jar   192.168.1.230:$TMP_ROBOT_DIR/$TAR_VER-fblive-lib-1.5.0.jar
  cp  /root/git_code/fblive/fblive-api/fblive-api-taskqueue/target/*.jar  $TMP_Taskqueue_DIR/$TAR_VER-fblive-api-taskqueue-1.5.0.jar
  cp  /root/git_code/fblive/fblive-lib/target/*.jar  $TMP_Taskqueue_DIR/$TAR_VER-fblive-lib-1.5.0.jar
  ssh -p 22  root@192.168.1.230  'rm -rf /root/data/FBLive5.Taskqueue/lib/fblive-api-taskqueue-1.5.0.jar'
  ssh -p 22  root@192.168.1.230  'rm -rf /root/data/FBLive5.Taskqueue/lib/fblive-lib-1.5.0.jar'
  scp     $TMP_Taskqueue_DIR/$TAR_VER-fblive-api-taskqueue-1.5.0.jar   192.168.1.230:$MODIFY_Taskqueue/fblive-api-taskqueue-1.5.0.jar
  scp     $TMP_Taskqueue_DIR/$TAR_VER-fblive-lib-1.5.0.jar    192.168.1.230:$MODIFY_Taskqueue/fblive-lib-1.5.0.jar
  Taskqueue_restart
}

deploy_pro_liveserver2(){
  cp /root/git_code/fblive/fblive-api/fblive-api-server/target/fblive-api-server-*.jar $TMP_liveserver2_DIR/$TAR_VER-fblive-api-server-1.5.0.jar
  cp  /root/git_code/fblive/fblive-lib/target/fblive-lib-*.jar  $TMP_liveserver2_DIR/$TAR_VER-fblive-lib-1.5.0.jar
  ssh -p 22  root@192.168.1.230  'rm -rf /root/liveserver2/lib/fblive-api-server-1.5.0.jar'
  ssh -p 22  root@192.168.1.230  'rm -rf /root/liveserver2/lib/fblive-lib-1.5.0.jar'
  ssh -p 22  root@192.168.1.229  'rm -rf /root/liveserver2/lib/fblive-api-server-1.5.0.jar'
  ssh -p 22  root@192.168.1.229  'rm -rf /root/liveserver2/lib/fblive-lib-1.5.0.jar'
  scp     $TMP_liveserver2_DIR/$TAR_VER-fblive-api-server-1.5.0.jar   192.168.1.230:$MODIFY_liveserver2/fblive-api-server-1.5.0.jar
  scp     $TMP_liveserver2_DIR/$TAR_VER-fblive-lib-1.5.0.jar    192.168.1.230:$MODIFY_liveserver2/fblive-lib-1.5.0.jar
  scp     $TMP_liveserver2_DIR/$TAR_VER-fblive-api-server-1.5.0.jar   192.168.1.229:$MODIFY_liveserver2/fblive-api-server-1.5.0.jar
  scp     $TMP_liveserver2_DIR/$TAR_VER-fblive-lib-1.5.0.jar    192.168.1.229:$MODIFY_liveserver2/fblive-lib-1.5.0.jar
  liveserver2_restart
}


test_pro(){
  /bin/sh /root/showlog
}

test_robot_pro(){
	/usr/bin/ssh  192.168.1.230
	tail -f /root/data/FBLive5.Robot/logs/wrapper_$CDATE.log
}

rollback_list_all(){
  ls -l $TMP_API_DIR/*.jar
  ls -l $TMP_WWW_DIR/*.jar
}

rollback_list_api(){
  ls -l $TMP_API_DIR/*fblive-api-web*
}

rollback_list_www(){
  ls -l $TMP_WWW_DIR/*fblive-web-www*
}

rollback_list_Robot(){
  ls -l $TMP_ROBOT_DIR/*.jar
}

rollback_list_Taskqueue(){
  ls -l $TMP_Taskqueue_DIR/*.jar
}

rollback_list_liveserver2(){
  ls -l $TMP_liveserver2_DIR/*.jar
}

rollback_fenbei_api(){
  rm -rf $MODIFY_API_DIR/fblive-api-web-1.5.0.jar
  rm -rf $MODIFY_API_DIR/fblive-lib-1.5.0.jar
  /bin/cp -f  $TMP_API_DIR/$1-fblive-api-web-1.5.0.jar   $MODIFY_API_DIR/fblive-api-web-1.5.0.jar
  /bin/cp -f  $TMP_API_DIR/$1-fblive-lib-1.5.0.jar       $MODIFY_API_DIR/fblive-lib-1.5.0.jar 
  fenbei_restart
}

rollback_fenbei_www(){
  rm -rf $MODIFY_WWW_DIR/fblive-lib-1.5.0.jar
  rm -rf $MODIFY_WWW_DIR/fblive-web-www-1.5.0.jar
  /bin/cp -f  $TMP_WWW_DIR/$1-fblive-lib-1.5.0.jar          $MODIFY_WWW_DIR/fblive-lib-1.5.0.jar
  /bin/cp -f  $TMP_WWW_DIR/$1-fblive-web-www-1.5.0.jar      $MODIFY_WWW_DIR/fblive-web-www-1.5.0.jar
  fenbei_restart
}

rollback_Robot(){
  ssh -p 22  root@192.168.1.230  'rm -rf /root/data/FBLive5.Robot/lib/fblive-api-robot-1.5.0.jar'
  ssh -p 22  root@192.168.1.230  'rm -rf /root/data/FBLive5.Robot/lib/fblive-lib-1.5.0.jar'
  scp     $TMP_ROBOT_DIR/$TAR_VER-fblive-api-robot-1.5.0.jar   192.168.1.230:$MODIFY_Robot/fblive-api-robot-1.5.0.jar
  scp     $TMP_ROBOT_DIR/$TAR_VER-fblive-lib-1.5.0.jar    192.168.1.230:$MODIFY_Robot/fblive-lib-1.5.0.jar
  Robot_restart 
}

rollback_Taskqueue(){
  ssh -p 22  root@192.168.1.230  'rm -rf /root/data/FBLive5.Taskqueue/lib/fblive-api-taskqueue-1.5.0.jar'
  ssh -p 22  root@192.168.1.230  'rm -rf /root/data/FBLive5.Taskqueue/lib/fblive-lib-1.5.0.jar'
  scp     $TMP_Taskqueue_DIR/$1-fblive-api-taskqueue-1.5.0.jar   192.168.1.230:$MODIFY_Taskqueue/fblive-api-taskqueue-1.5.0.jar
  scp     $TMP_Taskqueue_DIR/$1-fblive-lib-1.5.0.jar             192.168.1.230:$MODIFY_Taskqueue/fblive-lib-1.5.0.jar
  Taskqueue_restart 
}

rollback_liveserver2(){
  ssh -p 22  root@192.168.1.230  'rm -rf /root/liveserver2/lib/fblive-api-server-1.5.0.jar'
  ssh -p 22  root@192.168.1.230  'rm -rf /root/liveserver2/lib/fblive-lib-1.5.0.jar'
  ssh -p 22  root@192.168.1.229  'rm -rf /root/liveserver2/lib/fblive-api-server-1.5.0.jar'
  ssh -p 22  root@192.168.1.229  'rm -rf /root/liveserver2/lib/fblive-lib-1.5.0.jar'
  scp     $TMP_liveserver2_DIR/$1-fblive-api-server-1.5.0.jar     192.168.1.230:$MODIFY_liveserver2/fblive-api-server-1.5.0.jar
  scp     $TMP_liveserver2_DIR/$1-fblive-lib-1.5.0.jar            192.168.1.230:$MODIFY_liveserver2/fblive-lib-1.5.0.jar
  scp     $TMP_liveserver2_DIR/$1-fblive-api-server-1.5.0.jar     192.168.1.229:$MODIFY_liveserver2/fblive-api-server-1.5.0.jar
  scp     $TMP_liveserver2_DIR/$1-fblive-lib-1.5.0.jar            192.168.1.229:$MODIFY_liveserver2/fblive-lib-1.5.0.jar
  liveserver2_restart
}

main(){
   case $1 in
	deploy_fenbei)
	    git_pro;
	    mvn_pro;	
	    cp_pro ;
	    deploy_pro_fenbei;
	    test_pro;
	    ;;
        deploy_FBLive5Robot)
       	    git_pro;
            mvn_pro;
            deploy_pro_FBLive5Robot;	   	     
	    ;; 
        deploy_pro_FBLive5Taskqueue)
       	    git_pro;
            mvn_pro;
            deploy_pro_FBLive5Taskqueue;	   	     
	    ;; 
        deploy_liveserver2)
       	    git_pro;
            mvn_pro;
            deploy_pro_liveserver2;	   	     
 	    ;;
	rollback_list)
	   rollback_list_all;
	   ;;
        rollback_list_api)
           rollback_list_api;
           ;;
        rollback_list_www)
           rollback_list_www;
           ;;
        rollback_list_robot)
           rollback_list_Robot;
           ;;
        rollback_list_Taskqueue)
           rollback_list_Taskqueue;
           ;;
        rollback_list_liveserver2)
           rollback_list_liveserver2;
           ;;
	rollback_fenbei_api)
	   rollback_fenbei_api $2;
	   test_pro;
	  ;;
	rollback_fenbei_www)
	   rollback_fenbei_www $2;
	   test_pro;
	  ;;
	rollback_robot)
	   rollback_Robot  $2;
	  ;;
	rollback_Taskqueue)
	   rollback_Taskqueue  $2;
	  ;;
	rollback_liveserver2)
	   rollback_liveserver2  $2;
	  ;;
	  *)
	usage;
     esac
}

usage(){
    echo $"Usage: $0 [deploy_fenbei|deploy_FBLive5Robot|deploy_pro_FBLive5Taskqueue|deploy_liveserver2|rollback_list |rollback_list_api|rollback_list_www |rollback_fenbei_www|rollback_fenbei_api  |rollback_list_robot |rollback_list_Taskqueue |rollback_list_liveserver2 | rollback_fenbei ver|rollback_robot ver | rollback_Taskqueue ver | rollback_liveserver2 ver]"
}

main $1 $2
