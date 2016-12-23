#!/bin/bash
#Date/Time 
CDATE=$(date "+%Y-%m-%d")
CTIME=$(date "+%Y-%m-%d-%H-%M")

#Shell
CODE_DIR="/svndata/trunk/grass-zhs"
#CONFIG_DIR="/deploy/config"
TMP_DIR="/package"
TAR_DIR=$3 

usage(){
	echo $"Usage: $0 [deploy|rollback-list | rollback-pro ver]"
}

git_pro(){
   echo "begin svn  update"
   cd "$CODE_DIR" && svn update 
  # API_VERL=$(git show|grep commit |cut -d ' '   -f2)
  # API_VER=$(echo ${API_VERL:0:6})
  # cp -r "$CODE_DIR" "$TMP_DIR"

}

config_pro(){
   echo "add pro config"
   /bin/cp "$CONFIG_DIR"/* $TMP_DIR/demo/
   TAR_VER="$API_VER"-"$CTIME" 
   cd "$TMP_DIR" && mv demo pro_demo_$TAR_VER
}

tar_pro(){
    echo "mvn pro"
	mvn -Ptest clean compile package install
 #  cd  $TMP_DIR && tar czf pro_demo_"$TAR_VER".tar.gz  pro_demo_"$TAR_VER"

}

scp_pro(){
   echo "begin cp" 
if [ $1 == admin] 
 then
  /usr/bin/scp  $TMP_DIR/zhs-"$1"-1.0.war   188.188.188.110:/deploy  
}

deploy_pro(){
  echo "begin deploy"
  cd  /tmp $$ tar zxf pro_demo_"$TAR_VER".tar.gz
  rm -f /var/www/html/demo
  ln -s /tmp/pro_demo_"$TAR_VER" /var/www/html/demo
}

test_pro(){
  echo "test begin"
  echo "test ok curl"
}

rollback_list(){
  ls -l /tmp/*.tar.gz

}
rollback_pro(){
  rm -f /var/www/html/demo
  ln -s  /tmp/$1 /var/www/html/demo
}

main(){
   case $1 in
	deploy)
	    git_pro;
	    config_pro;	
	    tar_pro;
	    scp_pro $2;
	    deploy_pro;
	    test_pro;
	    ;;
	rollback-list)
	   rollback_list;
	   ;;
	rollback-pro)
	   rollback_pro $2;
	  ;;
	  *)
	usage;
     esac
}

main $1 $2
