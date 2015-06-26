#!/bin/sh

TIME=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=/data/backup/mongo
COMMAND=/data/mongo/bin/mongodump
TTL=7

BACKUP(){
    mkdir -p $BACKUP_DIR/127.0.0.1_$TIME
    $COMMAND -h 127.0.0.1 -p 27017 -o $BACKUP_DIR/127.0.0.1_$TIME >/var/log/mongodump_out.log 2>&1
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

if [ -f $COMMAND ];then
    BACKUP
    DELETE
fi
