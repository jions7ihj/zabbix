#!/bin/bash
cd `dirname $0`
d=`date +%Y-%m-%d.log`
d7=`date -d'7 day ago' +%Y-%m-%d.log`
cd ../logs/
cp catalina.out catalina.out.${d}
echo "" > catalina.out
rm -rf catalina.out.${d7}
