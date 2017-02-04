#!/bin/sh

DESTHOST='10.9.146.112'
DESTHOSTDIR='/data/wwwroot/diyiyou/'
SOURCEDIR='/data/wwwroot/diyiyou/'
VERSION=$(date +%Y%m%d%H%M)
KEY_PATH="/root/.ssh/id_rsa"

inotifywait -mr --timefmt '%d/%m/%y %H:%M' --format '%T %w %f' -e close_write,modify,delete,create,attrib ${SOURCEDIR} | while read date time dir file; do

    FILECHANGE=${dir}${file}
    # convert absolute path to relative
    # FILECHANGEREL=`echo "$FILECHANGE" | sed 's_'$CURPATH'/__'`

    rsync --progress -avH  --exclude=loadimg ${SOURCEDIR} -e "ssh -i $KEY_PATH" root@${DESTHOST}:${DESTHOSTDIR} && 
    echo "At ${time} on ${date}, file $FILECHANGE was backed up via rsync"
done
