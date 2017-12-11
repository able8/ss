#!/bin/bash

cwd=$(cd `dirname $0` && pwd)
cd $cwd

if [ $# -ne 1 ];then
    echo -e "Usage:\n\t$0 \"local/server\""
    exit 2
else
    if [ "$1" != "server" -a "$1" != "local" ];then
        echo -e "Only server or local.."
        exit 2
    else
        server_local_choice="$1"
    fi
fi

function show_time_2()
{
    local N=$1
    N2=$((N/2))
    N3=$((100/N))
    N4=$((100%N))
    echo $N3,$N4
    b=''
    for ((i=0;$i<=100;i+=$N3))
    do
        printf "progress:[%-100s] %d%%\r" $b $i
        sleep 1
        f=""
        for ((k=1;$k<=$N3;k+=1))
        do
            f="#$f"
        done
        b="${f}${b}"
        s=$b
    done
    if [ $N4 -ne 0 ];then
        t=""
        for ((k=1;$k<=$N4;k+=1))
        do
            t="#$t"
        done
        s="${s}${t}"
        printf "progress:[%-100s] %d%%\r" $s 100
        sleep 1
    fi
    echo
}

function show_time()
{
    local N=$1
    b=''
    for ((i=1;$i<=$N;i+=1))
    do
        printf "[ sleep %d second ]\r" $i
        #printf "progress:[%-50s]%d%%\r" $b $i
        sleep 1
        #b=#$b
    done
    echo
}

function info_me()
{
    local msg="$*"
    echo -e "$num.----- $msg"
    num=$((num+1))
    #read -p "Continue: ? [y/n] " choice
    #if [ "$choice" == "y" -o "$choice" == "" ];then
    #   echo -e "Let's go"
    #else
    #   echo -e "Bye"
    #   exit 1
    #fi
}

################################################
get_info_of_user_config_py="../../shadowsocks/get_info_from_user_config_json.py"
public_ip=$(curl ip.cip.cc 2>/dev/null)
num=1
ss_repo_url="https://10.0.0.54/tib/ss.git"
if [ -f $get_info_of_user_config_py ];then
    ssh_port=$(python $get_info_of_user_config_py ssh_port)
    apache_port=$(python $get_info_of_user_config_py apache_port)
    root_password=$(python $get_info_of_user_config_py root_password)
    encrypt_key=$(python $get_info_of_user_config_py encrypt_key)
    var_www_path_key=$(python $get_info_of_user_config_py var_www_path_key)
    change_method_point=$(python $get_info_of_user_config_py change_method_point)
    apache_auth=$(python $get_info_of_user_config_py apache_http_auth)
    #apache_auth_password=$(python $get_info_of_user_config_py apache_http_auth|awk -F'-|-' '{print $2}')
    if [ "$ssh_port" == "" -o "$ssh_port" == "failed" ];then
        ssh_port=10011
    fi
    if [ "$change_method_point" == "" -o "$change_method_point" == "failed" ];then
        change_method_point="no_change"
    else
        change_method_point=$(echo -e $change_method_point||sed -e 's/\[//' -e 's/\]//'|column  -t)
    fi
    if [ "$apache_port" == "" -o "$apache_port" == "failed" ];then
        apache_port=9527
    fi
    if [ "$root_password" == "" -o "$root_password" == "failed" ];then
        root_password="no_change"
    fi
    if [ "$encrypt_key" == "" -o "$encrypt_key" == "failed" ];then
        encrypt_key="no_change"
    fi
    if [ "$var_www_path_key" == "" -o "$var_www_path_key" == "failed" ];then
        var_www_path_key="no_change"
        var_www_path="/var/www/html/dont_play_with_me/"
    else
        var_www_path="/var/www/html/${var_www_path_key}/"
    fi
    if [ "$apache_auth" == "" -o "$apache_auth" == "failed" ];then
        apache_auth="no_change"
    fi
    if [ "$apache_auth_password" == "" -o "$apache_auth_password" == "failed" -o "$apache_auth_password" == "-|-" ];then
        apache_auth_password="no_change"
    fi
else
    apache_port=9527
    ssh_port=10011
    encrypt_key="no_change"
    var_www_path="/var/www/html/dont_play_with_me/"
    var_www_path_key="no_change"
    change_method_point="no_change"
    root_password="no_change"
    apache_auth_username="no_change"
    apache_auth_password="no_change"
fi
zabbix_agentd_port=10050
################################################
echo -e $apache_port
echo -e $ssh_port
echo -e $encrypt_key
echo -e $var_www_path
echo -e $var_www_path_key
echo -e $change_method_point
echo -e $root_password
echo -e $apache_auth
sleep 2

echo -e "\n------------------------------------------"
info_me "clone a new ss from $ss_repo_url"
cd /data && git clone $ss_repo_url >/dev/null 2>&1
cp -a ss /data/ss_no_change >/dev/null
cp -a ss /data/ss_no_change >/dev/null

info_me "apt-get update"
apt-get update >/dev/null

info_me "添加防火墙规则允许几个端口 [$ssh_port,$apache_port,$zabbix_agentd_port]"
iptables -I INPUT 1 -p tcp --dport $ssh_port -j  ACCEPT
iptables -I INPUT 1 -p tcp --dport $zabbix_agentd_port -j  ACCEPT
iptables -I INPUT 1 -p tcp --dport $apache_port -j ACCEPT

info_me "install tmux python vim unzip stress-ng htop libevent-dev pthon-nacl ntpdate"
apt-get install python-nacl stress-ng tmux python vim unzip htop libevent-dev ntpdate -y >/dev/null

info_me "修改ssh 默认端口22 为 $ssh_port"
sed -i "s|Port 22|Port $ssh_port|" /etc/ssh/sshd_config >/dev/null
sed -i "s|^#.*Port $ssh_port|Port $ssh_port|" /etc/ssh/sshd_config >/dev/null

info_me "restart ssh"
/etc/init.d/ssh restart >/dev/null
service ssh restart >/dev/null
if [ "$root_password" == "no_change" ];then
    info_me "Dont change root password"
else
    info_me "change root password to $root_password and PermitRootLogin=yes"
    echo -e "root:${root_password}" |chpasswd
    sed -i "s/^.*PermitRootLogin.*$/PermitRootLogin yes/" /etc/ssh/sshd_config
fi

info_me "拷贝tools python包到python系统环境路径下"
python_lib_path=$(python -c "import sys;print sys.path[-1]")
if [ -d "/data/ss/shadowsocks/tools" ];then
    cp -a /data/ss/shadowsocks/tools $python_lib_path/
fi

info_me "change_default_INPUT_DROP_for_fuck_GFW.sh block all INPUT traffic now"
bash /data/ss/utils/change_default_INPUT_DROP_for_fuck_GFW.sh >/dev/null

info_me "ln -s some py to /bin/"
if [ ! -L "/bin/Encrypt_or_Decrypt_my_data.py" ];then
    ln -s /data/ss/utils/Encrypt_or_Decrypt_my_data.py /bin/
fi
if [ ! -L "/bin/Ginfo.sh" -a ! -f "/bin/Ginfo.sh" ];then
    ln -s /data/ss/utils/Ginfo.sh /bin/
fi
#cp -a -f /bin/ss/utils/change_timezone.sh /bin/
#cp -a -f /bin/ss/utils/delete_all_ACCEPT_ips.sh /bin/

if [ "$encrypt_key" == "no_change" ];then
    info_me "OK. 不需要修改Encrypt_key,使用默认值"
else
    info_me "OK 修改 Encry.py password 为配置的值"
    sed -i "s|key = \"IDontLikeYouGFW\"|key = \"${encrypt_key}\"|" /data/ss/utils/Encrypt_or_Decrypt_my_data.py
fi

info_me "生成ss config.json配置"
cd /data/ss/shadowsocks
if [ "$server_local_choice" == "server" ];then
    python gen_config_json.py ss
elif [ "$server_local_choice" == "local" ];then
    echo -e "Cant use local"
fi

info_me "生成ss的ciphers.py"
cd /data/ss/shadowsocks/crypto
python change_cipher_length.py
#python /bin/Encrypt_or_Decrypt_my_data.py -d openssl_my.py.locked >/dev/null
#python /bin/Encrypt_or_Decrypt_my_data.py -d /bin/ss/utils/monitor_bad_guys.py.locked >/dev/null
#python /bin/Encrypt_or_Decrypt_my_data.py -d /bin/ss/utils/change_method.sh.locked >/dev/null
#python /bin/Encrypt_or_Decrypt_my_data.py -d /bin/ss/utils/change_method.py.locked >/dev/null
#python /bin/Encrypt_or_Decrypt_my_data.py -d /bin/ss/utils/alarm.py.locked >/dev/null
#python /bin/Encrypt_or_Decrypt_my_data.py -d /bin/ss/utils/uptime.sh.locked >/dev/null

#info_me "ln -s change_method.sh to /bin/"
#ln -s /data/ss/utils/change_method.sh /bin/

cd /data/ss/utils/new
if [ -f .bashrc ];then
    rm .bashrc
fi

#info_me "拷贝一些配置如 .bashrc rc.local 到系统路径"
#python /bin/Encrypt_or_Decrypt_my_data.py -d .bashrc.locked >/dev/null
#python /bin/Encrypt_or_Decrypt_my_data.py -d rc.local.locked >/dev/null
#python /bin/Encrypt_or_Decrypt_my_data.py -d check_socks.sh.locked >/dev/null
#python /bin/Encrypt_or_Decrypt_my_data.py -d check_socks_server.sh.locked >/dev/null
#python /bin/Encrypt_or_Decrypt_my_data.py -d check_socks_local.sh.locked >/dev/null
#python /bin/Encrypt_or_Decrypt_my_data.py -d zbx.sh.locked >/dev/null

now_path=$(pwd)

info_me "增加gfw用户，并且设置sudoer免密码"
useradd gfw -m -s /bin/bash 2>/dev/null
chmod 700 /etc/sudoers
echo -e "\ngfw ALL=(root) NOPASSWD:ALL" >> /etc/sudoers
chmod 440 /etc/sudoers

info_me "安装apache，并且拷贝/etc/apache2 和 /var/www/html"
#apt-get install -y apache2 >/dev/null 2>&1
#/etc/init.d/apache2 stop >/dev/null
#if [ -d "/etc/apache2" ];then
#   mv /etc/apache2 /etc/apache2_bak
#fi
#
#cwd=$(cd `dirname $0` && pwd)
#cd $cwd
#cd ../../web
#
#python /bin/Encrypt_or_Decrypt_my_data.py -d apache2.tar.bz2.locked
#cp -a -f apache2 /etc/
#
#mkdir -p /var/www/
#if [ -d "/var/www/html" ];then
#   mv /var/www/html /var/www/html_2
#fi
#
#python /bin/Encrypt_or_Decrypt_my_data.py -d html.tar.bz2.locked
#cp -a -f html /var/www/
#chmod +x /var/www/html/you_cant_know/p/*
#chmod 777 /var/www/html/you_cant_know/file
#
#python_lib_path=$(python -c "import sys;print sys.path[1]")
#cp -a /var/www/html/you_cant_know/p/tib $python_lib_path
#
#cd $ori_cwd

#python /bin/Encrypt_or_Decrypt_my_data.py -d deal_apache.sh.locked >/dev/null
bash deal_apache.sh $var_www_path $var_www_path_key $apache_port "$apache_auth" >/dev/null
cd $now_path

info_me "创建日志目录"
mkdir -p /data/logs/ss
mkdir -p /data/logs/ss_no_change
mkdir -p /data/logs/ss_hub

info_me "拷贝 .bashrc to /root/ htoprc"
cp -a -f .bashrc.new /root/.bashrc
if [ ! -d "/root/.config/htop" ];then
    mkdir -p /root/.config/htop
fi
cp -a -f htoprc /root/.config/htop/

info_me "修改PS1 公网IP"
sed -i "s/public_ip/$public_ip/" /root/.bashrc

info_me ". ~/.bashrc"
. /root/.bashrc

info_me "cp some files to system path"
cp -a -f define_his /etc/
if [ -f "/etc/rc.local" ];then
    echo -e "#--------- added for ss [`date +%F_%T`] -----------------" >> /etc/rc.local
    cat rc.local >> /etc/rc.local && chmod +x /etc/rc.local
else
    echo  '#!/bin/bash' >> /etc/rc.local
    echo -e "\n\n#--------- added for ss [`date +%F_%T`] -----------------" >> /etc/rc.local
    cat rc.local >> /etc/rc.local && chmod +x /etc/rc.local
fi
#cp -a -f check_socks.sh /bin/ && chmod +x /bin/check_socks.sh
#cp -a -f check_socks_local.sh /bin/ && chmod +x /bin/check_socks_local.sh
#cp -a -f check_socks_server.sh /bin/ && chmod +x /bin/check_socks_server.sh
cp -a -f ps_mem /bin/ && chmod +x /bin/ps_mem

info_me "chmod +x /bin/{py,sh}"
chmod +x /bin/*.py
chmod +x /bin/*.sh

info_me "start python server.py"
python /data/ss/shadowsocks/server.py -q -q >> /tmp/ss_1.-----log 2>&1 &

info_me "make 2G swap and here we need to spent some time. Please just wait..[dd,mkswap,swapon]"
dd if=/dev/zero of=/swap.2G bs=1M count=200 >/dev/null 2>&1
mkswap /swap.2G >/dev/null 2>&1
swapon /swap.2G >/dev/null 2>&1

info_me "Show some infos here.. and we wait here for 5 seconds"
sleep 1
echo -e "================================================"
iptables -L -vn
iptables-save > /etc/iptables.save
echo -e "================================================"
free -m
echo -e "================================================"
netstat -antplue|egrep -i listen |sort -t'/' -k2 -V
echo -e "================================================"
cat /etc/rc.local
echo -e "================================================"

info_me "add some crontab tasks and show crontab after"
echo -e "\n##-------- added some crontab for ss ----------------" >> /etc/crontab
echo -e "* * * * * root bash /data/ss/utils/si.sh /data/ss/utils/new/check_socks_server.sh >/dev/null 2>&1 &" >> /etc/crontab
if [ "$change_method_point" == "no_change" ];then
    echo -e "0 */6 * * * root bash /data/ss/utils/si.sh  /data/ss/utils/change_method.sh >/dev/null 2>&1 &" >> /etc/crontab
else
    echo -e "0 ${change_method_point} * * * root bash /data/ss/utils/si.sh /data/ss/utils/change_method.sh >/dev/null 2>&1 &" >> /etc/crontab
fi
echo -e "1 4 * * * root bash /data/ss/utils/si.sh /bin/delete_all_ACCEPT_ips.sh >/dev/null 2>&1 &" >> /etc/crontab
echo -e "#* * * * * root bash /data/ss/utils/si.sh /data/ss/utils/monitor_bad_guys.py >/dev/null 2>&1 &" >> /etc/crontab
echo -e "#* * * * * root bash /data/ss/utils/si.sh /data/ss/utils/uptime.sh >/dev/null 2>&1 &" >> /etc/crontab
echo -e "1 1 * * 5 root bash /data/ss/utils/si.sh /data/ss/utils/change_method.py all >/dev/null 2>&1 &" >> /etc/crontab
echo -e "*/10 * * * * root ntpdate 0.asia.pool.ntp.org >/dev/null 2>&1 &" >> /etc/crontab
echo -e "##------------------------------------------------\n" >> /etc/crontab
cat /etc/crontab
echo -e "================================================"

info_me "添加一些公钥到root免密登陆，如果key.pub不为空的话"
cd $cwd
if [ -f "../key.pub" ];then
    mkdir -p ~/.ssh
    if [ $(cat ../key.pub|wc -l) -ne 0 ];then
        keys_num=$(cat ../key.pub|egrep -v "^$"|wc -l)
        echo -e "好的，找到$keys_num个公钥"
        cat ../key.pub >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
    else
        echo -e "没有公钥需要添加"
    fi
fi

info_me "change ss_no_change config.json"
cd /data/ss_no_change/shadowsocks/ && python gen_config_json.py ss_no_change

info_me "checkout ss_hub"
cd /data/ss_hub
git checkout -b ss_from_hub_master origin/ss_from_hub_master
cd /data/ss_hub/shadowsocks && python gen_config_json.py ss_hub

info_me "change timezone to Shanghai"
bash /data/ss/utils/change_timezone.sh "Asia/Shanghai" >/dev/null 2>&1

info_me "cp files to apache /var/www/html/${var_www_path_key}/files/"
cd $cwd
cp -a apk ${var_www_path}/files/ >/dev/null 2>&1

info_me "deal with git_config"
cd $cwd
cp -a git_config/.git* /root/

#info_me "deal with Get_My_Pass.py"
#python /bin/Encrypt_or_Decrypt_my_data.py -d deal_get_my_pass.sh.locked >/dev/null 2>&1
#bash deal_get_my_pass.sh >/dev/null 2>&1
#
#info_me "chmod +x /bin/{py,sh}"
#chmod +x /bin/*.py
#chmod +x /bin/*.sh
#
#info_me "deal zbx"
#cd $cwd
#bash zbx.sh >/dev/null 2>&1

echo -e "-----------------------------------------------------------------------------------------------"
echo -e "now we sleep 60 to wait for you.."
show_time 60

