#!/bin/sh

DAY_FLAG=`date +%Y%m%d`
Host=192.168.1.9
BAK_DIR=/data/wwwroot/game_server/logs
PKG_NAME=$(find $BAK_DIR -name "*.log" | grep -v $DAY_FLAG | awk -F '/' '{print $6}')
echo $PKG_NAME

packaging()
{
	cd $BAK_DIR && tar czvf $i.tar.gz $i
	if [[ "$?" -eq 0 ]];then
		return 0
	else
		return 1
	fi
}

transmit()
{
	scp  $BAK_DIR/$i.tar.gz  root@$Host:/data/server_logs/s1/
	if [[ "$?" -eq 0 ]];then
		return 0
	else
		return 1
	fi
}

delete()
{
	rm -rf $BAK_DIR/$i.tar.gz && rm -rf $BAK_DIR/$i
}

if [ -z "$PKG_NAME" ];then
	echo "The log file not exsit yet"
	exit 0
fi

for i in ${PKG_NAME[@]};do
	if packaging; then
		echo "compress success"
		if transmit;then
			echo "transmit success"
			delete
		else
			echo "transmit failed"
			exit 1
		fi
	else
		echo "compress failed"
		exit 1
	fi
done
