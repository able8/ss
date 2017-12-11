#!/bin/bash

if [ $# -ne 2 ];then
    echo -e "Usage:\n\t$0 \"/local/path/to/dir/or/file\" [file/files]"
    exit 2
else
    local_path="$1"
    if [ ! -f $local_path -a ! -d $local_path ];then
        echo -e "Sorry..The path [$local_path] not found"
        exit 2
    fi
    only_last_one=$(echo -e "$local_path" |awk -F'/' '{print $NF}')
    choice="$2"
    if [ "$choice" != "file" -a "$choice" != "files" ];then
        echo -e "Sorry.. Choice should be [file] or [files]"
        exit 2
    fi
fi

echo -e "now I am uploading [$local_path] to my cloud [/var/www/html/$choice] "
echo -e "Please wait for a while"

rsync -azvrP -e "ssh -p 10066" $local_path tib@tib1.publicvm.com:/tmp/ 2>/dev/null
if [ $? -ne 0 ];then
    echo -e "Sorry. Upload failed"
    echo -e "Please try run again.. It's ok to run again"
    exit 2
fi

ssh -p 10066 tib@tib1.publicvm.com "sudo mv /tmp/${only_last_one} /var/www/html/${choice}/ 2>/dev/null" >/dev/null 2>/dev/null
if [ $? -eq 0 ];then
    echo -e "\n=== Done ===\n"
else
    echo -e "\n=== Failed ===\n"
fi

