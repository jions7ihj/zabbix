#!/bin/bash

#the date 7 days ago
Date_7=`date -d "-7 day" +%Y%m%d`
http_log_path="/usr/local/services/apache2/logs"

#clear logs
rm -fr ${http_log_path}/access_log-${Date_7}
