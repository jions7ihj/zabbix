#!/bin/bash

appName=server-account
version=1.0.0
dirName=${appName}-${version}
tarName=${dirName}-build.tar.gz

currentDateTime=`date '+%Y%m%d%H%M%S'`

if [ ! -f "../${tarName}" ]; then
  echo "error: not found ${tarName}";
  exit 0
fi

tar zxf ../${tarName} -C ./
unzip -q ./${dirName}/lib/${dirName}.jar -d ./${dirName} && rm -rf ./${dirName}/lib/${dirName}.jar
sed -i s/"    active: dev"/"    active: test"/g ./${dirName}/application.yml
sed -i 's#defaultZone.*#defaultZone: http://192.168.8.197:9001/eureka/#g' ./${dirName}/bootstrap.yml
if [ ! -d '/dbdata/app/backup' ]; then
  mkdir -p /dbdata/app/backup
fi

if [ ! -d '/dbdata/pid' ]; then
  mkdir -p /dbdata/pid
fi

if [ -d "/dbdata/app/${dirName}" ]; then
  curPwd=`pwd`
  cd /dbdata/app/
  tar zcf backup/${dirName}-${currentDateTime}.tar.gz ${dirName}
  rm -rf ${dirName}
  cd ${curPwd}
fi

cp -r ${dirName} /dbdata/app/
rm -r ${dirName}
#cp ./config.properties /dbdata/app/${dirName}/

chmod a+x /dbdata/app/${dirName}/start.sh
mkdir -p /logs/act

cd /dbdata/app/${dirName}/
echo "deploy successed!"

./start.sh start

exit 0;
