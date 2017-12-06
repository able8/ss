#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright 2012-2015 clowwindy
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

from __future__ import absolute_import, division, print_function,  with_statement

import sys
import os
import signal
import time
import random,json,platform

def check_the_platform():
    if platform.system().lower() == "linux":
        return "linux"
    elif platform.system().lower() == "darwin":
        return "mac"
    elif platform.system().lower() == "windows":
        return "win"
    else:
        return "Unknown"

__os__ = check_the_platform()
if __os__ == "linux" or __os__ == "win" or __os__ == "mac":
    sys.path.insert(0, os.path.split(os.path.split(os.path.realpath(sys.argv[0]))[0])[0])
else:
    print("Sorry.. Not supported platform EXIT now")
    sys.exit()

import common
import logging

from shadowsocks import shell, daemon, eventloop, tcprelay, udprelay, asyncdns

def main():

    shell.check_python()

    # fix py2exe
    if hasattr(sys, "frozen") and sys.frozen in  ("windows_exe", "console_exe"):
        p = os.path.dirname(os.path.abspath(sys.executable))
        os.chdir(p)

    config = shell.get_config(True)

    #added by cloud for local random choose a server and the port and the port_password
    if config.has_key('port_password') and len(config['port_password']) != 0:
        config['server_port'] = int(random.choice(config['port_password'].items())[0])
        config['password'] = common.to_str(config['port_password']["%s" % config['server_port']])
    else:
        if config.has_key("password") and config.has_key("server_port"):
            if type(config['server_port']) == list and len(config['server_port']) != 0:
                config['server_port'] = random.choice(config.get('server_port', 8388))
            elif type(config['server_port']) == str and config['server_port'] != "":
                config['server_port'] == int(common.to_str(config.get('server_port',8388)))
            elif type(config['server_port']) == int and config['server_port'] <= 65530:
                config['server_port'] = config['server_port']
            else:
                print("Sorry..config error please check config.json again")
                sys.exit(1)
            if config['password'] == "":
                print("Sorry..config error please check config.json again")
                sys.exit(1)
        else:
            print("Sorry..config error please check config.json again")
            sys.exit(1)

    logging.warn('!' * 30)
    if config.has_key('server_info'):
        if config['server_info'].has_key(config['server']):
            logging.info("OK.. [ (ip: %s) (server_port: %s) (password: %s) (server_info: %s) (method: %s) ]" % (config['server'],config['server_port'],config['password'],config['server_info']["%s" % config['server']],config['method']))
        else:
            logging.info("OK.. [ (ip: %s) (server_port: %s) (password: %s) (method: %s) ]" % (config['server'],config['server_port'],config['password'],config['method']))
    else:
        logging.info("OK.. [ (ip: %s) (server_port: %s) (password: %s) (method: %s) ]" % (config['server'],config['server_port'],config['password'],config['method']))
    logging.warn('!' * 30)
    time.sleep(1)

    daemon.daemon_exec(config)

    try:
        logging.info("starting local at %s:%d" % (config['local_address'], config['local_port']))

        dns_resolver = asyncdns.DNSResolver(config)
        tcp_server = tcprelay.TCPRelay(config, dns_resolver, True)
        udp_server = udprelay.UDPRelay(config, dns_resolver, True)
        loop = eventloop.EventLoop(config)
        dns_resolver.add_to_loop(loop)
        tcp_server.add_to_loop(loop)
        udp_server.add_to_loop(loop)

        def handler(signum, _):
            logging.warn('received SIGQUIT, doing graceful shutting down..')
            tcp_server.close(next_tick=True)
            udp_server.close(next_tick=True)
        signal.signal(getattr(signal, 'SIGQUIT', signal.SIGTERM), handler)

        def int_handler(signum, _):
            sys.exit(1)
        signal.signal(signal.SIGINT, int_handler)

        daemon.set_user(config.get('user', None))
        loop.run()
    except Exception as e:
        shell.print_exception(e)
        sys.exit(1)

if __name__ == '__main__':
    main()
