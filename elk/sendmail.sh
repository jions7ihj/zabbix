#!/bin/sh
#sendmail error log to someone

function sendErrorMail(){
	file=/root/elk/error_mail/$(date -d '-8 hour'  +%Y%m%d/$1%H.log)
#	echo $file

	if [ -f "$file" ]; then
		echo 'send mail'$file
		mail -s '[error]'$1 1357384977@qq.com,xiezhongjiang@fenbei.com,xuexiaobo@fenbei.com,chenglei@fenbei.com,zhengdi@qq.com,zouwenyan@fenbei.com,liushulin@fenbei.com,yangsong@fenbei.com,524095992@qq.com,ranruichun@fenbei.com < $file
		mv $file $file.send
	else
		echo 'no file:'$file
	fi
}

#end

sendErrorMail fblive-web-admin
sendErrorMail fblive-api-taskqueue
sendErrorMail fblive-api-datahistory
sendErrorMail fblive-api-web
sendErrorMail fblive-web-www
sendErrorMail fblive-api-robot
sendErrorMail fenbei2.0-web-admin
sendErrorMail fblive-api-server

