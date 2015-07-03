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

DEP_PATH=/data/deploy
LOG_PATH=/data/www/logs
RES_PATH=/data/www

VER_PATH=$(ls -ltr /data/deploy/ | tail -1 | awk -F ' ' '{print $9}')

TIME=$(date "+%Y-%m-%d %H:%M:%S")

check_md5()
{
	cd $DEP_PATH/$VER_PATH
	md5sum -c --status md5.data
	if [[ "$?" -eq 0  ]];then
		return 0
	else
		return 1
	fi
}

symlink()
{
	ln -s $DEP_PATH/$VER_PATH $RES_PATH/code
	if [[ "$?" -eq 0 ]];then
		return 0
	else
		return 1
	fi
}

if [ ! -d $LOG_PATH/supervisor ]; then
	mkdir -p $LOG_PATH/supervisor
	chown -R nobody.nobody $LOG_PATH
fi

if check_md5; then
	echo "$TIME	Check md5sum is OK"
	rm -rf $RES_PATH/code
	echo "$TIME	delete old symlink"
 
	if symlink;then
		echo "$TIME	make symlink success"
	else
		echo "$TIME	make symlink failed"
		exit  1
	fi
else
	echo "$TIME	Check md5sum failed"
	exit 1
fi

#清理缓存
curl -s http://{{ grains['ip_interfaces']['eth0'][0]  }}/opcache_reset.php > /dev/null

exit 0
