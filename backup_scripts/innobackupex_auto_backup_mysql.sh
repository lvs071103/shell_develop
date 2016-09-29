#!/bin/bash

TARGET_PATH=/data/backup_db
TIMESTAMP=$(date +%Y%m%d)
LOG_FILE=/var/log/mysql_back_info_${TIMESTAMP}.log
USER='root'
PASS=''
CONF_FILE='/etc/my.cnf'

if [ "$UID" -ne 0 ];then
	echo "You must run as root"
	exit
fi

full_backup() {
	if [ ! -d ${TARGET_PATH}/${TIMESTAMP}/full ];then
        	mkdir -p ${TARGET_PATH}/${TIMESTAMP}/full
	fi
	innobackupex --defaults-file=${CONF_FILE} --user=${USER} --password=${PASS} --no-timestamp ${TARGET_PATH}/${TIMESTAMP}/full >> ${LOG_FILE} 2>&1
	if [ "$?" -eq 0 ];then
		echo "full backup success"
	else
		echo "full backup failed"
		exit 1
	fi
}

incremental_backup(){
	if [ ! -d ${TARGET_PATH}/${TIMESTAMP}/incremental ];then
        	mkdir -p ${TARGET_PATH}/${TIMESTAMP}/incremental
	fi
	innobackupex --defaults-file=${CONF_FILE} --user=${USER} --password=${PASS} --incremental-basedir=${TARGET_PATH}/${TIMESTAMP}/full --incremental ${TARGET_PATH}/${TIMESTAMP}/incremental/ >> ${LOG_FILE} 2>&1
	if [ "$?" -eq 0 ];then
		echo "incremental backup success"
	else
		echo "incremental backup success"
		exit 1
	fi
}

zip(){
	Yesterday=$(perl -e 'use POSIX;print strftime "%Y%m%d",localtime time-86400;')
	cd ${TARGET_PATH}/
	if [ -d "${Yesterday}" ];then
		zip ${Yesterday}.zip -r ${Yesterday}/
		if [ "$?" -eq 0 ];then
			echo "compress success."
			rm -rf ${Yesterday}
			exit 0
		else
			echo "compress faild."
			exit 1
		fi
	else
 		echo "${Yesterday} not found or not backup"
		exit 1
	fi
}

case $1 in
	full)
	full_backup
	;;
	incremental)
	incremental_backup
	;;
	zip)
	zip
	;;
	*)
	echo "Usage: $0 <params: [full, incremental, zip]>"
	;;
esac
