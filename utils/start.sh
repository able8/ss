#!/bin/bash

cwd=$(cd `dirname $0` && pwd)
cd $cwd

apt-get install python git vim -y
vim ./Encrypt_or_Decrypt_my_data.py
python ./Encrypt_or_Decrypt_my_data.py -d new/1.sh.locked
bash new/1.sh server
#echo -e "\niptables -P INPUT ACCEPT\n" >> /etc/rc.local
bash new/bbr.sh
