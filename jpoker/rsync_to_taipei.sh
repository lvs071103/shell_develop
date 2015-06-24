#!/bin/sh

R_IP=

if [ "$#" -ne 1 ];then
    echo "usage: $0 <svn_version>"
    exit 1
fi

if [[ $UID -ne 0 ]]; then
        echo "You must run as root"
        exit
fi

rsync -e "ssh -i /root/jump/jizeipoker.pri" -avzup --delete  /data/tmp/$1/* jizeipoker@${R_IP}:/data/deploy/tmp/$1 > /var/log/rsync_to_taipei.log
if [[ "$?" -eq 0 ]];then
    echo "rsync success!"
else
    echo "rsync failed!"
    exit 1
fi
