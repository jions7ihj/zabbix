#!/bin/bash



target=$1
input="Y"
if [ -z ${target} ]; then
    echo "To deploy on which server, please enter the address of SSH(user@host:port):";
    read target
    input=""
    #echo "input arguments target address";
    #exit 0
fi

if [ -z input ]; then
  echo "Are you deploy to ${target}?"
  read input
fi

fileName=1.0.0-build.tar.gz

pg=$2
function deploy(){
  if [ -z "$pg" ]; then
    git pull
    mvn clean -DskipTests package
  else
    if [ "$pg" = "Y" ]; then
      git pull
      mvn clean -DskipTests package
    fi
  fi
  scp server-account/target/server-account-${fileName} ${target}
  scp server-business/target/server-business-${fileName} ${target}
  scp server-discovery/target/server-discovery-${fileName} ${target}
  scp server-im/target/server-im-${fileName} ${target}
  scp server-manage/target/server-manage-${fileName} ${target}
}


case ${input} in
  y|Y|yes|Yes|YES)
    deploy;
    ;;
  n|N|No|NO)
    exit 0
  ;;
esac
echo "deploy end.";