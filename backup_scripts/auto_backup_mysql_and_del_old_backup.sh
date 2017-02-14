#!/bin/bash

TIME=$(date +%Y%m%d_%H%M%S)
USER='root'
PASS='123456'
HOST=10.16.1.188
BACKUP_DIR=/data/backup_db
BINARY_PATH=/usr/local/lnmp/mysql/bin
TTL=7


DBS=$(${BINARY_PATH}/mysql -h${HOST} -u${USER} -p${PASS} -e "show databases;" | awk '{print $c}' c=${1:-1})
echo ${DBS}

BACKUP(){
  mkdir -p $BACKUP_DIR/${HOST}_$TIME
  for i in ${DBS[@]}
  do
    if [ ${i} == 'Database' ] || [ ${i} == 'information_schema' ] || \
       [ ${i} == 'mysql' ] || [ ${i} == 'performance_schema' ] || \
       [ ${i} == 'test' ]; then
      :
    else
      ${BINARY_PATH}/mysqldump -h${HOST} -u${USER} -p${PASS} --set-gtid-purged=OFF -R ${i} > ${BACKUP_DIR}/${HOST}_${TIME}/${i}.sql 2>/dev/null
    fi
  done

  cd ${BACKUP_DIR}
  tar zcf ${HOST}_${TIME}.tar.gz ${HOST}_$TIME
  if [ $? -eq 0 ];then
    rm -rf ${BACKUP_DIR}/${HOST}_${TIME}
  fi
}

DELETE(){
    find ${BACKUP_DIR} -type f -name "*.tar.gz" -ctime +$TTL -exec rm -rf {} \;
}


if [ ! -d $BACKUP_DIR ]; then
    mkdir -p $BACKUP_DIR
fi

BACKUP
DELETE
