#!/bin/sh

TIME=$(date +%Y%m%d_%H%M%S)
USER=root
PASS=
DBS=(game_center)
BACKUP_DIR=/data/backup/mysql
TTL=15

BACKUP(){
    mkdir -p $BACKUP_DIR/127.0.0.1_$TIME
    for i in ${DBS[*]}
    do
        /usr/bin/mysqldump --set-gtid-purged=OFF -u$USER -p$PASS $i > $BACKUP_DIR/127.0.0.1_$TIME/$i.sql 2>/dev/null
    done

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

