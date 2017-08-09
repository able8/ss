#!/bin/bash

#if [ $# -ne 1 ];then
#   echo -e "Usage:\n\t$0 \"encrypt_method\""
#   exit 1
#fi

cd `dirname $0`

#method="$1"
#encrypt_method="$method"
#log="/tmp/change_num.log"

#N=$(iptables -t filter -L INPUT -vn|egrep -w "$ip"|egrep "ACCEPT"|wc -l)

file="/fs/cnf/listen_port"
cat $file
#ori=$(egrep "$encrypt_method" $file)
#echo $ori|awk -F',' '{print $2}'
#if [ -f "$file" ];then
#   sed -i "s+$ori+    '$encrypt_method': (24, $num, OpenSSLCrypto),+" $file
#fi
#if [ $? -eq 0 ];then
#   echo -e "changed to $num successfully"
#   echo -e "[`date +%F_%H:%M:%S`] chanegd to [$num] successfully" >> $log
#   /bin/Restart_SS.sh
#else
#   echo -e "changed to $num failed"
#   echo -e "[`date +%F_%H:%M:%S`] changed to [$num] failed" >> $log
#fi
