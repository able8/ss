#!/usr/bin/env python
# -*- coding:utf-8 -*-

import sys,os,time,json,random,string
from tools import funcs
funcs.cd_into_cwd_dir(sys.argv[0])

#--------------------
start_port = 10000
end_port = 50000

all_ports = ["17788","20720","29920","6001","5351","1990"]
if os.path.exists("user_config.json"):
    try:
        user_config = json.loads(open("user_config.json").read())
        if user_config.has_key("all_ports") and len(user_config['all_ports']) != 0:
            funcs.color_print("Now I will use the ports you set and open 6 more random ports")
            all_ports = [ str(i) for i in user_config['all_ports']]
    except Exception as e:
        funcs.color_print("Sorry.. I got some error with the user_config.json. Maybe you should check it again.")
        funcs.color_print("And Now I will not use the info you give to me")
all_chars = string.printable[:62] + "^&@<>%_"
#--------------------

#if len(sys.argv) != 2:
#   print '''Usage:\n\t%s "[client/server]"''' % sys.argv[0]
#   sys.exit()
#else:
#   if str(sys.argv[1]).strip() != "client" and str(sys.argv[1]).strip() != "server":
#       print '''Usage:\n\t%s "[client/server]"''' % sys.argv[0]
#       sys.exit()
#   else:
#       choice = str(sys.argv[1]).strip()

k = 0
while True:
    if k >= 6:
        break
    else:
        num = random.randrange(start_port,end_port)
        if str(num) in all_ports:
            k -= 1
            continue
        else:
            all_ports.append(str(num))
            k += 1

def get_pass(num=16):
    t = []
    for i in range(num):
        t.append(all_chars[random.randint(0,len(all_chars)-1)])
    return "".join(t)

config_server = {
    "forbid": {
        "port": [],
        "site": []
    },
    "log": {
        "log_enable": "False",
        "log_path": "/var/log/ss/ss.log"
    },
    "method": "aes-256-cfb",
    "pid-file": "/var/run/shadowsocks.pid",
    "port_password": {},
    "role": "server",
    "timeout": 150,
    "limit": {},
    "workers": 1,
    "一些说明":{
        "1": "role 只是为了方便区别配置的角色[client/server],并无实际作用",
        "2": "limit 如果total为0，则不限制流量,只有大于0才生效，默认为0 [这里默认对每个端口都是不限制流量]",
        "3":"forbid 需要两个参数port和site同时启用才行 例如： port : 10000 site: qq.com 那么则是对于访问10000端口，请求qq.com相关的域名被拒绝"
    }
}

for one_port in all_ports:
    config_server['port_password'][str(one_port)] = "%s" % get_pass()
    config_server['limit'][str(one_port)] = {}
    config_server['limit'][str(one_port)]['total'] = 0
    config_server['limit'][str(one_port)]['used'] = 0

with open("config.json","w+") as f:
    f.write("%s\n" % funcs.json_dumps_unicode_to_string(config_server))
