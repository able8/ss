#!/bin/bash

cwd=$(cd `dirname $0` && pwd)
cd $cwd

if [ $(id -u) -ne 0 ];then
    echo -e "Sorry..Please run me as root"
    exit 2
fi

if [ -d "/data/ss" -o -d "/data/ss_hub" -o -d "/data/ss_no_change" ];then
    echo -e "Maybe ss alread installed on this machine.[/data/ss]"
    echo -e "If you need to reinstall please remove /data/ss and /data/ss_hub and /data/ss_no_change"
    echo -e "And run me again"
    exit 2
fi

mkdir -p /data/logs/

apt-get install python git vim -y >/dev/null

bash install_ss.sh server
if [ $? -ne 0 ];then
    exit 1
fi
echo -e "-------- Now start install bbr -----------"
bash bbr.sh
