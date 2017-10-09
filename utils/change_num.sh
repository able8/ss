#!/bin/bash

if [ $# -ne 1 ];then
    echo -e "Usage:\n\t$0 \"num\""
    exit 1
fi

cd `dirname $0`

num="$1"
encrypt_method="aes-192-cfb8"
log="/tmp/change_num.log"

#N=$(iptables -t filter -L INPUT -vn|egrep -w "$ip"|egrep "ACCEPT"|wc -l)

file="../shadowsocks/crypto/openssl.py"
ori=$(egrep "$encrypt_method" $file)

if [ -f "$file" ];then
    sed -i "s+$ori+    '$encrypt_method': (24, $num, OpenSSLCrypto),+" $file
fi
if [ $? -eq 0 ];then
    echo -e "changed to $num successfully"
    echo -e "[`date +%F_%H:%M:%S`] chanegd to [$num] successfully" >> $log
    /bin/Restart_SS.sh
else
    echo -e "changed to $num failed"
    echo -e "[`date +%F_%H:%M:%S`] changed to [$num] failed" >> $log
fi
