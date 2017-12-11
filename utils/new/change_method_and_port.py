#!/usr/bin/env python
# -*- coding:utf-8 -*-

import sys,time,os
import json
import random
from tib import logs,funcs
from tib import global_vars as vars

funcs.cd_into_cwd_dir(sys.argv[0])
log_obj = logs.log2("./check_method_and_port/log.log")
os_type = funcs.check_the_platform()

work_path = '''%s''' % os.path.split("%s" % os.getcwd())[0]
if funcs.get_shell_cmd_output('''which Encrypt_or_Decrypt_my_data.py''') != "failed":
    Encry_py_path = "%s" % funcs.get_shell_cmd_output('''which Encrypt_or_Decrypt_my_data.py''')[0]
else:
    log_obj.write_err("sorry...No found Encrypt_or_Decrypt_my_data.py",3)
    sys.exit()

if len(sys.argv) == 2:
    choice = str(sys.argv[1]).strip()
    the_ip = ""
elif len(sys.argv) == 3:
    choice = str(sys.argv[1]).strip()
    the_ip = str("%s" % sys.argv[2]).strip()
else:
    choice = ""
    the_ip = ""

log_obj.write_run("-----------------------------------------------------------Start--------------------------------------------------------",3)
log_obj.write_run("choice is [%s]" % choice,3)
time.sleep(1)
change_port = "no"
tmp_dir = "/tmp/config_json_23"
before_config_json = "%s/shadowsocks/config.json" % work_path
before_json_dic = json.loads(open(before_config_json).read())
cal_time = "change_port.json"
port_last_time = 6 * 3600
rewrite_file = 'no'
ss_client_path = os.path.split(before_config_json)[0]
ss_client_name = before_config_json.split("/")[2]

the_port = 9527
timeout_for_curl = 10

if choice != "" and choice == "ip":
    if the_ip != "":
        my_host = the_ip
    else:
        my_host = "%s".strip() % funcs.get_ip_from_domain("tib1.publicvm.com")
else:
    my_host = "tib1.publicvm.com"
log_obj.write_run("my_host is [%s]" % my_host,3)
time.sleep(1)

if os.path.exists(cal_time) is True:
    last_time = funcs.time_to_timestamp(open(cal_time).read())
    now_time = funcs.time_to_timestamp(vars.NOW_TIME)
    if now_time - last_time > port_last_time:
        change_port = "yes"
        f = open(cal_time,"w+")
        f.write("%s" % vars.NOW_TIME)
        f.close()
else:
    f = open(cal_time,"w+")
    f.write("%s" % vars.NOW_TIME)
    f.close()
all_ports = ["1990", "1991", "1992", "1993", "5445", "4224", "7010", "8002", "9001", "5351", "20720", "29920", "31337", "33225", "17788", "6566", "6001", "13724", "8888", "22347", "4567", "47808"]

log_obj.write_run('''mkdir -p %s && cd %s && curl --connect-timeout %s -L -k "https://tib:jueduifangyu&215@%s:%s/you_cant_know/file/config.json.for_change.locked" > ./config.json.for_change.locked''' % (tmp_dir,tmp_dir,timeout_for_curl,my_host,the_port),3)
time.sleep(1)
kk = funcs.get_shell_cmd_output('''mkdir -p %s && cd %s && curl --connect-timeout %s -L -k "https://tib:jueduifangyu&215@%s:%s/you_cant_know/file/config.json.for_change.locked" > ./config.json.for_change.locked''' % (tmp_dir,tmp_dir,timeout_for_curl,my_host,the_port))
if str(kk).strip() == "failed":
    log_obj.write_run("Try again to get config.json.for_change.locked",3)
    log_obj.write_run('''mkdir -p %s && cd %s && curl --connect-timeout %s -L -k "https://tib:jueduifangyu&215@%s:%s/you_cant_know/file/config.json.for_change.locked" > ./config.json.for_change.locked''' % (tmp_dir,tmp_dir,timeout_for_curl,my_host,the_port),3)
    kk2 = funcs.get_shell_cmd_output('''mkdir -p %s && cd %s && curl --connect-timeout %s -L -k "https://tib:jueduifangyu&215@%s:%s/you_cant_know/file/config.json.for_change.locked" > ./config.json.for_change.locked''' % (tmp_dir,tmp_dir,timeout_for_curl,my_host,the_port))
    if str(kk2).strip() == "failed":
        log_obj.write_run("Failed again..exit now.\n",3)
        sys.exit()

log_obj.write_run('''mkdir -p %s && cd %s && curl --connect-timeout %s -L -k "https://tib:jueduifangyu&215@%s:%s/you_cant_know/file/check.html" > ./check.html''' % (tmp_dir,tmp_dir,timeout_for_curl,my_host,the_port),3)
time.sleep(1)
kk3 = funcs.get_shell_cmd_output('''mkdir -p %s && cd %s && curl --connect-timeout %s -L -k "https://tib:jueduifangyu&215@%s:%s/you_cant_know/file/check.html" > ./check.html''' % (tmp_dir,tmp_dir,timeout_for_curl,my_host,the_port))
if str(kk3).strip() == "failed":
    log_obj.write_run("check.html failed.. exit now",3)
    sys.exit()
if funcs.check_the_platform() == "mac":
    log_obj.write_run("cd %s && md5 config.json.for_change.locked > check_tmp.html && md5 check_tmp.html check.html" % tmp_dir,3)
    time.sleep(1)
    ak = funcs.get_shell_cmd_output('''cd %s && md5sum=$(md5 config.json.for_change.locked |awk -F'=' '{print $2}'|column -t) && echo "$md5sum  config.json.for_change.locked" > check_tmp.html && md5 check_tmp.html check.html|awk -F'=' '{print $2}' |column  -t''' % tmp_dir)
    if str(ak[0]).strip() == str(ak[1]).strip():
        log_obj.write_run("MD5 match..Continue",3)
    else:
        log_obj.write_run("MD5 not match EXIT now",3)
        time.sleep(1)
        sys.exit()
elif funcs.check_the_platform() == "linux":
    log_obj.write_run("cd %s && md5sum config.json.for_change.locked > check_tmp.html && md5sum check_tmp.html check.html" % tmp_dir,3)
    time.sleep(1)
    ak = funcs.get_shell_cmd_output("cd %s && md5sum config.json.for_change.locked > check_tmp.html && md5sum check_tmp.html check.html" % tmp_dir)
    if ak[0].split()[0].strip() == ak[1].split()[0].strip():
        log_obj.write_run("MD5 match..Continue",3)
    else:
        log_obj.write_run("MD5 not match EXIT now",3)
        time.sleep(1)
        sys.exit()
elif funcs.check_the_platform() == "win":
    pass
    sys.exit()
else:
    log_obj.write_err("Sorry..check os platform failed .. Only support linux + mac + win",3)
    sys.exit()

log_obj.write_run("python %s -d %s/config.json.for_change.locked" % (Encry_py_path,tmp_dir),3)
time.sleep(1)
for l in funcs.get_shell_cmd_output("python %s -d %s/config.json.for_change.locked" % (Encry_py_path,tmp_dir)):
    log_obj.write_run(l,3)

kk = json.loads(open("%s/config.json.for_change" % tmp_dir).read())

for k in funcs.get_shell_cmd_output("rm -rf %s" % tmp_dir):
    log_obj.write_run(k,3)

log_obj.write_run("origin method [%s] new method [%s]" % (before_json_dic['method'],kk['method']),3)
time.sleep(1)
if str(before_json_dic['method']).strip() != str(kk['method']).strip():
    log_obj.write_run("I need to change the config.json content. Method is not the same now. [%s]-->[%s]" % (before_json_dic['method'],kk['method']),3)
    before_json_dic['method'] = kk['method']
    rewrite_file = "yes"
if change_port == "yes":
    before_port = before_json_dic['server_port']
    if type(before_port) is list:
        before_port = before_port[0]
    before_json_dic['server_port'] = all_ports[random.randint(0,len(all_ports)-1)]
    log_obj.write_run("I need to change the port now.. [%s]-->[%s]" % (str(before_port),str(before_json_dic['server_port'])),3)
    before_json_dic['password'] = before_json_dic['port_password'][before_json_dic['server_port']]
    rewrite_file = "yes"

before_port = before_json_dic['server_port']
if type(before_port) is list:
    before_port = before_port[0]
if int(before_port) not in [int(one_port) for one_port in all_ports]:
    before_json_dic['server_port'] = all_ports[random.randint(0,len(all_ports)-1)]
    log_obj.write_run("I need to change the port now.. [%s]-->[%s]" % (str(before_port),str(before_json_dic['server_port'])),3)
    before_json_dic['password'] = before_json_dic['port_password'][before_json_dic['server_port']]
    rewrite_file = "yes"

before_json_dic['server'] = ["%s" % my_host]
before_json_dic['server_info'] = {"%s" % my_host: "from google clodu"}

log_obj.write_run(funcs.json_dumps_unicode_to_string(before_json_dic),3)
time.sleep(1)

if rewrite_file == "yes":
    with open("%s.tmp" % before_config_json,"w+") as f:
        f.write("%s\n" % json.dumps(before_json_dic,sort_keys=True,indent=4,ensure_ascii=False))
        for i in funcs.get_shell_cmd_output("mv -v %s.tmp %s" % (before_config_json,before_config_json)):
            log_obj.write_run(i,3)
    log_obj.write_run("cd %s && bash Format_script.sh %s" % (os.getcwd(),before_config_json),3)
    time.sleep(1)
    for i in funcs.get_shell_cmd_output("cd %s && bash Format_script.sh %s" % (os.getcwd(),before_config_json)):
        log_obj.write_run(i,3)
    if os_type == "linux":
        log_obj.write_run('''pid_to_kill=$(sudo ps -e faux|egrep "%s/local.py"|egrep -v grep|awk '{print $2}'|column -t) ; kill $pid_to_kill ; python %s/local.py -q -q >> /tmp/ss_local.log 2>&1 &''' % (os.path.split(before_config_json)[0],os.path.split(before_config_json)[0]),3)
        time.sleep(1)
        for j in funcs.get_shell_cmd_output('''pid_to_kill=$(sudo ps -e faux|egrep "%s/local.py"|egrep -v grep|awk '{print $2}'|column -t) ; kill $pid_to_kill ; python %s/local.py -q -q >> /tmp/ss_local.log 2>&1 &''' % (os.path.split(before_config_json)[0],os.path.split(before_config_json)[0])):
            log_obj.write_run(j,3)
        log_obj.write_run("Done for killing ss_client",3)
        log_obj.write_run("----------------------------",3)
        log_obj.write_run("""cd %s ; python %s/local.py -q -q >> /tmp/%s.log 2>&1 &""" % (ss_client_path,ss_client_path,ss_client_name),3)
        funcs.get_shell_cmd_output("""cd %s ; python %s/local.py -q -q >> /tmp/%s.log 2>&1 &""" % (ss_client_path,ss_client_path,ss_client_name))
    elif os_type == "mac":
        log_obj.write_run('''pid_to_kill=$(sudo ps aux|egrep "%s/local.py"|egrep -v grep|awk '{print $2}'|column -t) ; kill $pid_to_kill ; python %s/local.py -q -q >> /tmp/ss_local.log 2>&1 &''' % (os.path.split(before_config_json)[0],os.path.split(before_config_json)[0]),3)
        time.sleep(1)
        for j in funcs.get_shell_cmd_output('''pid_to_kill=$(sudo ps aux|egrep "%s/local.py"|egrep -v grep|awk '{print $2}'|column -t) ; kill $pid_to_kill ; python %s/local.py -q -q >> /tmp/ss_local.log 2>&1 &''' % (os.path.split(before_config_json)[0],os.path.split(before_config_json)[0])):
            log_obj.write_run(j,3)
        log_obj.write_run("Done for killing ss_client",3)
        log_obj.write_run("----------------------------",3)
        log_obj.write_run("""cd %s ; python %s/local.py -q -q >> /tmp/%s.log 2>&1 &""" % (ss_client_path,ss_client_path,ss_client_name),3)
        funcs.get_shell_cmd_output("""cd %s ; python %s/local.py -q -q >> /tmp/%s.log 2>&1 &""" % (ss_client_path,ss_client_path,ss_client_name))
    else:
        sys.exit()
else:
    if funcs.check_process_running("%s/local.py" % ss_client_path) == "no":
        log_obj.write_run("Need to start %s/local.py" % ss_client_path,3)
        log_obj.write_run("""cd %s ; python %s/local.py -q -q >> /tmp/%s.log 2>&1 &""" % (ss_client_path,ss_client_path,ss_client_name),3)
        funcs.get_shell_cmd_output("""cd %s ; python %s/local.py -q -q >> /tmp/%s.log 2>&1 &""" % (ss_client_path,ss_client_path,ss_client_name))
    log_obj.write_run("no need to rewrite config.json",3)
log_obj.write_run("-----------------------------------------------------------End-----------------------------------------------------",3)

