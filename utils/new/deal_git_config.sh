#!/bin/bash

if [ -d "/usr/local/src/scripts" ];then
    rm -rf /usr/local/src/scripts
    cd /usr/local/src && git clone https://github.com/bluetib/scripts.git
    cd scripts
    cp -a git_config/.git* /root/
fi


