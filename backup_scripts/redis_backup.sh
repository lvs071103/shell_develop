#!/bin/sh

if [[ $UID -ne 0 ]]; then
        echo "You must run as root"
        exit
fi

HOSTNAME=$(/bin/hostname)
localtime=$(date +%Y%m%d_%H%M)

port=($(netstat -lntp | grep redis-server | awk '{print $4}' | awk '{split($0,ports,":");print ports[length(ports)]}' | sort | uniq))
num=${#port[@]}

backup_file_name_6379=redis_${HOSTNAME}_6379_${localtime}.tar.gz
backup_file_name_6380=redis_${HOSTNAME}_6380_${localtime}.tar.gz
backup_path=/data/backup/redis/local

if [[ $num -eq 0 ]];then
    echo -e "\n\033[40;31m No redis server is running\033[0m\n"
    exit
fi

#压缩
for i in ${port[@]};do
    if [ ${i} -eq 6379 ]; then
        cd /data/redis/var
        tar czvf ${backup_file_name_6379} dump.rdb
    elif [ ${i} -eq 6380  ]; then
        cd /data/redis/var-6380
        tar czvf ${backup_file_name_6380} dump.rdb
    else
        echo "zip failed!" && exit 1
    fi
done
#移动
if [ ! -d ${backup_path} ]; then
    mkdir -p ${backup_path}
fi
for i in ${port[@]};do
    if [ ${i} -eq 6379 ]; then
        mv /data/redis/var/${backup_file_name_6379} ${backup_path}
    fi

    if [ ${i} -eq 6380 ];then
        mv /data/redis/var-6380/${backup_file_name_6380} ${backup_path}
    fi
done
#同步
#rsync -avIz $backup_path/*.tar.gz  192.168.1.9:/data/s1_server/redis/s1/

#清理
find ${backup_path}/ -type f -name "*.tar.gz"  -ctime +30 -exec rm -rf {} \;
