#!/bin/sh

CMD=/usr/bin/mysqlbinlog
MASTER_HOST=PokerJ-HP1
MYSQL_PORT="3306"
MYSQL_USER=
MYSQL_PASS=
BACKUP_DIR=/data/backup/binlogs/m_db
# time to wait before reconnecting after failure
RESPAWN=10

if [ ! -d "$BACKUP_DIR" ];then
	mkdir -p ${BACKUP_DIR}
fi

cd ${BACKUP_DIR}
echo "Backup dir: $BACKUP_DIR "

while :
do
LAST_FILE=`ls -1 $BACKUP_DIR | grep -v orig | tail -n 1`
TIMESTAMP=`date +%s`
FILE_SIZE=$(stat -c%s "$LAST_FILE")

if [ "$FILE_SIZE" -gt 0 ]; then
	echo "Backing up last binlog"
	mv $LAST_FILE ${LAST_FILE}_orig_${TIMESTAMP}
fi

touch $LAST_FILE
echo "Starting live binlog backup"
$CMD --read-from-remote-server --host=${MASTER_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASS} --raw --stop-never ${LAST_FILE}
echo "mysqlbinlog exited with $? trying to reconnect in $RESPAWN seconds."
sleep $RESPAWN
done
