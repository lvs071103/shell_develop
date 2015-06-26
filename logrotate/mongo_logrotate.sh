#!/bin/sh

rotate_7(){
    find /var/log/mongo/ -type f -name "mongodb.log.*" -ctime +7 -exec rm -rf  {} \;
}    

logrotate(){
    if [ -f /data/db/mongod.lock ]; then
         /usr/bin/kill -SIGUSR1 `cat /data/db/mongod.lock 2>/dev/null` 2>/dev/null
    fi
}

logrotate
rotate_7
