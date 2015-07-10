#!/bin/sh

TIME=$(date +%Y%m%d_%H%M%S)
USER=
PASS=
BACKUP_DIR=/data/backup/mysql/local
TTL=15

BACKUP(){
    mkdir -p $BACKUP_DIR/127.0.0.1_$TIME
    /usr/bin/mysqldump --set-gtid-purged=OFF --single-transaction --flush-logs --master-data=2 --all-databases --events --routines -u$USER -p$PASS  > $BACKUP_DIR/127.0.0.1_$TIME/all_databases.sql 2>/dev/null

    cd $BACKUP_DIR
    tar zcf 127.0.0.1_$TIME.tar.gz 127.0.0.1_$TIME
    rm -rf $BACKUP_DIR/127.0.0.1_$TIME
}

DELETE(){
    find $BACKUP_DIR -type f -name "*.tar.gz" -ctime +$TTL -exec rm -rf {} \;
}


if [ ! -d $BACKUP_DIR ]; then
    mkdir -p $BACKUP_DIR
fi
BACKUP
DELETE

