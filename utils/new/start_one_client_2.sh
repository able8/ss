#!/bin/bash

cwd=$(cd `dirname $0` && pwd)
cd $cwd

mkdir -p /bin/ss_client
cp -a ../../shadowsocks /bin/ss_client/
cp -a ../../utils /bin/ss_client/

echo -e "\n------------------------------------------"
echo -e "1、decrypt some files and get config.json and start polipo:8300 and install polipo"
python /bin/Encrypt_or_Decrypt_my_data.py -d /bin/ss_client/utils/change_method_and_port.py.locked
python /bin/Encrypt_or_Decrypt_my_data.py -d /bin/ss_client/utils/change_method_and_port.sh.locked
python /bin/Encrypt_or_Decrypt_my_data.py -d /bin/ss_client/utils/holy.sh.locked
python /bin/Encrypt_or_Decrypt_my_data.py -d /bin/ss_client/utils/new/check_socks_local.sh.locked
python /bin/Encrypt_or_Decrypt_my_data.py -d /bin/ss_client/shadowsocks/config.json.local.locked
python /bin/Encrypt_or_Decrypt_my_data.py -d /bin/ss_client/shadowsocks/crypto/openssl_my.py.locked
mv /bin/ss_client/shadowsocks/config.json.local /bin/ss_client/shadowsocks/config.json
mv /bin/ss_client/shadowsocks/crypto/openssl_my.py /bin/ss_client/shadowsocks/crypto/openssl.py
apt-get install polipo -y >/dev/null 2>&1
bash /bin/ss_client/utils/polipo.sh "0.0.0.0" "18888" "127.0.0.1" "7790" > /tmp/polipo.log 2>&1 &

echo -e "2、add some crontab"
cp -a /etc/crontab /etc/crontab.bak.`date +%F_%T`
echo -e "

##--- added by tib [if need to delete please contact tib]
* * * * * root bash /bin/ss_client/utils/si_2.sh /bin/ss_client/utils/change_method_and_port.sh
* * * * * root bash /bin/ss_client/utils/si_2.sh /bin/ss_client/utils/new/check_socks_local.sh
*/10 * * * * root bash /bin/ss_client/utils/si_2.sh /bin/ss_client/utils/holy.sh
#################
" >> /etc/crontab
cat /etc/crontab

echo -e "\n--------------------------------------------"
