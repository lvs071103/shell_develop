#!/bin/sh
#
#defined redis1 data path like: /data/redis/var_6379 ----> port:6379
#defined redis2 data path like: /data/redis/var_6380 ----> port:6380

if [[ $UID -ne 0 ]]; then
        echo "You must run as root"
        exit
fi

LOCALTIME=`date +%Y%m%d_%H%M`
HOSTNAME=$(/bin/hostname)
PORT=($(netstat -lntp | grep redis-server | awk '{print $4}' | awk '{split($0,ports,":");print ports[length(ports)]}' | sort | uniq))
BACKUP_PATH=/data/backup/redis/local

if [[ -z `pgrep redis-server` ]];then
	echo -e "\n\033[40;31m No redis server is running\033[0m\n"
	exit
fi

#zip
for i in ${PORT[@]};do
	cd /data/redis/var_${i}
	tar czvf ${HOSTNAME}_redis_${i}_${LOCALTIME}.tar.gz dump.rdb
done

if [ ! -d ${BACKUP_PATH} ]; then
	mkdir -p ${BACKUP_PATH}
fi

#move
for i in ${PORT[@]};do
	mv /data/redis/var/${HOSTNAME}_redis_${i}_${LOCALTIME}.tar.gz ${BACKUP_PATH}
done

# clear old backup
find ${BACKUP_PATH}/ -type f -name "*.tar.gz"  -ctime +30 -exec rm -rf {} \;
