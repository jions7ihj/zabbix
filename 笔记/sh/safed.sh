#!/bin/bash
#-------------------VAR------------------------------------------------
IPTABLES=$(which iptables)
IPTABLES_SAVE=$(which iptables-save)
IPV4_RESTORE=$(which iptables-restore)
LOG=/srv/salt/zero/0/openresty/nginx/logs
#-------------------FUN------------------------------------------------
main(){
	cd $LOG
	while true
	do
		tail access.log -n 20|awk '{if ($4 == "_") {print $1}}'|sort|uniq -c|sort -nr|awk '{if ($2 !=null && $1>3) {print $2}}' > .drop
		tail access.log -n 20|grep -Ew '404'|grep -E 'x16|x00'|awk '{print$1}'|sort|uniq -c|sort -nr|awk '{if ($2!=null && $1>5) {print $2}}' >> .drop
		tail access.log -n 20|awk '{if($0~/404/ && $0~/chmod|echo/) print$1}'|sort|uniq -c|sort -nr|awk '{if ($2!=null && $1>0) {print $2}}' >> .drop
		tail access.log -n 20|awk '{if (($(NF-2) == "-") && ($(NF-1) == "-" ) && ($4 == "_" )) {print $1}}'|sort|uniq -c|sort -nr|awk '{if ($2 !=null && $1>2) {print $2}}' >> .drop
		tail access.log -n 20|grep -Ew '404'|awk '{if (($(NF-2) == "-") || ($(NF-1) == "-" )) {print $1}}'|sort|uniq -c|sort -nr|awk '{if ($2 !=null && $1>15) {print $2}}' >> .drop
		tail access.log -n 20|grep -Ew '403|499'|awk '{print$1}'|sort|uniq -c|sort -nr|awk '{if ($2!=null && $1>10) {print $2}}' >> .drop
		tail /var/log/secure -n 20|grep -Ew ': Failed' |awk '{print$11}'|grep '[0-9]\.'|sort|uniq -c|sort -nr|awk '{if ($2!=null && $1>2) {print $2}}' >> .drop
		tail /var/log/secure -n 20|grep 'Invalid'|awk '{print$NF}'|grep '[0-9]\.'|sort|uniq -c|sort -nr|awk '{if ($2!=null && $1>2) {print $2}}' >> .drop
		tail /var/log/secure -n 20|grep 'Did'|awk '{print$NF}'|grep '[0-9]\.'|sort|uniq -c|sort -nr|awk '{if ($2!=null && $1>2) {print $2}}' >> .drop
		if [ -s .drop ]
		then
			sort ./.drop|uniq > .dropIP
			for i in `cat .dropIP`
			do
				$IPTABLES -nL INPUT|grep $i -q
				if [ $? != 0 ]
				then
					$IPTABLES -I INPUT -s $i -j DROP
					$IPTABLES_SAVE > ./.iptables
					echo "`date` $i" >> blackip
				fi
			done
		fi
		sleep 21
	done
}
#-------------------PROGRAM--------------------------------------------
main &
