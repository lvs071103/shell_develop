#!/bin/sh
#
# exit 0 for success other for failed
#
#
if [ "$#" -ne 1 ];then
	echo "usage: $0 <git_version>"
	exit 1
fi

if [$UID -ne 0 ];then
	echo "You must run as root"
	exit
fi

VER_DIR=$(date +%Y%m%d_%H%M%S)

if [ ! -d /data/deploy/$VER_DIR ];then
    mkdir -p /data/deploy/$VER_DIR
fi

sync()
{
	rsync -rlpgoDuP --exclude=.git jize@192.168.170.8::php /data/deploy/$VER_DIR --password-file=/etc/rsyncd.pass > /var/log/supervisor/sync_code.log
	if [[ "$?" -eq 0 ]];then
		return 0
	else
		return 1
	fi
}

if sync;then
   echo "sync code success"
else
   echo "Sync code Failed"
   exit 1
fi

exit 0
