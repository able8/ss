#!/bin/bash

cwd=$(cd `dirname $0` && pwd)
cd $cwd

vim ../Encrypt_or_Decrypt_my_data.py
cp -a ../Encrypt_or_Decrypt_my_data.py /bin/ && chmod +x /bin/Encrypt_or_Decrypt_my_data.py

if [ -d "/bin/ss_client" ];then
    echo -e "already installed ss on this machine..[/bin/ss_client] found"
    exit 2
fi

if [ -f "start_one_client_2.sh.locked" ];then
    python /bin/Encrypt_or_Decrypt_my_data.py -d start_one_client_2.sh.locked
    bash start_one_client_2.sh
else
    echo -e "Sorry..I cant find start_one_client_2.sh"
fi

