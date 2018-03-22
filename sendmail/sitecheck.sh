#!/bin/bash
# curl -IL http://localhost/member/login.htm
# curl --data "memberName=fengkan&password=22" http://localhost/member/login.htm
SITE=192.168.1.167
URL="http://$SITE"
#mail_info
#email_sender=(xxb@kaixiaochai.com.cn xm@kaixiaochai.com.cn)
email_title="$SITE故障警告！！！"
email_content="主机$SITE:$PROT不通!请及时处理。 \n监控邮件，不必回复"

count=0
for (( k=0; k<2; k++ ))
do
    check_code=$( curl --connect-timeout 3 -sL -w "%{http_code}\\n" $URL -o /dev/null )
    if [ "$check_code" != "200" ]; then
        count=$(expr $count + 1)
        sleep 3
        continue
    else
        count=0
        break
    fi
done
if [ "$count" != "0" ]; then
    echo -e `date +"%Y-%m-%d %H:%M.%S"` $email_content | /bin/mail -s $email_title xuexiaobo2558@dingtalk.com lipeng@burnk.onaliyun.com
    exit 1
else
    exit 0
fi

#notify_error()
#{
#
#    for var in ${email_sender[@]};
#    do
#        echo --------------------------------------------
#        echo -e `date +"%Y-%m-%d %H:%M.%S"` $email_content | /bin/mail -s $email_title $var
#    done
#}

