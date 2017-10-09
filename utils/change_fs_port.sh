#!/bin/bash


if [ $# -ne 1 ];then
    echo -e "Usage:\n\t$0 \"num\""
    exit 1
fi

cd `dirname $0`

port="$1"
#encrypt_method="aes-192-cfb8"
log="/tmp/change_fs_port.log"
ports=$(netstat -antplue|egrep  -i listen --col|awk '{print $4}'|awk -F':' '{print $2}'|column -t|sort -V)
for i in $ports
do
    if [ "$i" == "$port" ];then
        echo -e "Sorry. Please change port . Already listening..$port"
        exit 1
    fi
done

#N=$(iptables -t filter -L INPUT -vn|egrep -w "$ip"|egrep "ACCEPT"|wc -l)

file="/fs/cnf/listen_port"
#ori=$(egrep "$encrypt_method" $file)

if [ -f "$file" ];then
    echo -e "$port" > $file
    #sed -i "s+$ori+    '$encrypt_method': (24, $num, OpenSSLCrypto),+" $file
    if [ $? -eq 0 ];then
        echo -e "changed fs port to $port successfully"
        echo -e "[`date +%F_%H:%M:%S`] chanegd fs port to [$port] successfully" >> $log
        /fs/restart.sh
    else
        echo -e "changed fs port to $port failed"
        echo -e "[`date +%F_%H:%M:%S`] changed fs port to [$port] failed" >> $log
    fi
fi
