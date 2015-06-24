#!/bin/sh

if [ "$#" -ne 1 ];then
    echo "usage: $0 <svn_version>"
    exit 1
fi

if [[ $UID -ne 0 ]]; then
        echo "You must run as root"
        exit
fi

VERSION="$1"
RES_V=$(date +%Y%m%d_%H%M%S)
SVN_USER=""
SVN_PASS=""
SVN_URL=https://192.168.1.72/svn/poker_as_deploy/branches/${VERSION}
TAR_PATH=/data/deploy/tmp
IP=

checkout()
{
    if [ -d "$TAR_PATH"/"$VERSION" ]; then
        rm -rf  ${TAR_PATH}/${VERSION}
        echo "delete old version success!"
    fi
    svn checkout --non-interactive --trust-server-cert --username ${SVN_USER} --password ${SVN_PASS} ${SVN_URL} ${TAR_PATH}/${VERSION} >> /var/log/pull_cdn.log
    if [[ $? -eq 0 ]];then
        echo "svn checkout success!"
        cd ${TAR_PATH}
        svn export ${VERSION} res
        if [[ $? -eq 0 ]]; then
            echo "svn export complete!"
        else
            echo "svn export failed!"
            exit 1
        fi
    else
        echo "svn checkout failed!"
        exit 1
    fi
}

move_to_deploy()
{
    if [ ! -d "$TAR_PATH"/res ]; then
        echo "$TAR_PATH/res is not exist!"
        return 1
    fi

    if [ ! -d /data/deploy/${RES_V} ];then
        mkdir /data/deploy/${RES_V}
    fi

    mv ${TAR_PATH}/res /data/deploy/${RES_V}
    /bin/cp ${TAR_PATH}/crossdomain.xml /data/deploy/${RES_V}
    if [  -d /data/deploy/${RES_V}/res ] && [ -e  /data/deploy/${RES_V}/crossdomain.xml ]; then
        return 0
    else
        return 1
    fi
}

if checkout; then
    echo "checkout completed next-->move res directory" >> /var/log/pull_cdn.log
else
    exit 1
fi

if move_to_deploy;then
    echo "move code to deploy directory success!"
else
    echo "move code to deploy directory failed!"
    exit 1
fi

cd /data/deploy/${RES_V}/ 
find ./ -type f ! -name "md5.data" -exec md5sum {} \; > /data/deploy/${RES_V}/md5.data
if [[ "$?" -eq 0 ]]; then
    echo "make md5 complete!"
else
    echo "make md5 faild!"
    exit 1
fi

rsync -avzup --delete  /data/deploy/${RES_V}/*  root@${IP}:/data/tmp/${VERSION} >/var/log/pub_jp.log
if [[ "$?" -eq 0 ]];then
    echo "rsync to jp is success! version: ${VERSION}"
else
    echo "rsync to jp is failed! version: ${VERSION}"
    exit 1
fi

ssh root@${IP} '/data/tmp/rsync_to_taipei.sh 1.0.0'
if [[ "$?" -eq 0 ]];then
    echo "jp rsync to taipei success!"
else
    echo "jp rsync to taipei faild"
fi
