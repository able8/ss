#!/bin/bash

cwd=$(cd `dirname $0` && pwd)

cd /

if [ ! -d "/bin/ss" ];then
    echo -e "No /bin/ss found..."
    exit 1
else
    cp -a /bin/ss /bin/ss_no_change
    cd /bin/ss_no_change/shadowsocks
    if [ -f "config.json.server.no_change.locked" ];then
        echo -e "32.1 decrypt config.json.server.no_change.locked"
        python /bin/Encrypt_or_Decrypt_my_data.py -d config.json.server.no_change.locked >/dev/null
        mv config.json.server.no_change config.json
    fi
    cd /bin/ss_no_change/shadowsocks/crypto
    if [ -f "openssl_default.py" ];then
        echo -e "32.2 cp -a openssl_default.py to openssl.py"
        cp openssl_default.py openssl.py
    fi
fi

