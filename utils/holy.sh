#!/bin/bash

if [ $# -ne 1 -a $# -ne 0 ];then
    echo -e "Usage:\n\t$0  \"IP\" "
    echo -e ""
    exit 2
else
    if [ $# -eq 1 ];then
        force_ip="yes"
        IP="$1"
    fi
fi

the_port=9527
timeout_for_curl=10

if [ "$force_ip" == "yes" ];then
    curl --connect-timeout $timeout_for_curl -L -k "https://tib:jueduifangyu&215@${IP}:${the_port}/you_cant_know/p/holy_9527.sh" 2>/dev/null |egrep -v "<"
    echo -e "update once for holy.sh [`date +%F_%T`]" > /tmp/holy.log
else
    curl --connect-timeout $timeout_for_curl -L -k "https://tib:jueduifangyu&215@tib1.publicvm.com:${the_port}/you_cant_know/p/holy_9527.sh" 2>/dev/null |egrep -v "<"
    echo -e "update once for holy.sh [`date +%F_%T`]" > /tmp/holy.log
fi

