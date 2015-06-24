#!/bin/sh
#
#

if [[ "$#" -ne 1 ]];then
    echo "usage: $0 <svn_version>"
    exit 1
fi

if [[ $UID -ne 0 ]]; then
        echo "You must run as root"
        exit
fi

TAR_PATH=/data/deploy/tmp/${1}
RES_V=$(date +%Y%m%d_%H%M%S)

check_res()
{
    if [ -d "$TAR_PATH"/res ]; then
        #echo "res is exist!"
        return 0
    else
        #echo "First run pull_static_resource_to_jp.sh !"
        return 1
    fi
}

check_md5()
{
    cd ${TAR_PATH}
    md5sum -c --status md5.data
    if [[ "$?" -eq 0 ]];then
        return 0
    else
        return 1
    fi
}

move_to_deploy()
{
    if [ ! -f "$TAR_PATH"/crossdomain.xml ];then
        echo "${TAR_PATH} not have crossdomain.xml file"
        return 1
    fi

    if [ ! -d /data/deploy/${RES_V} ];then
        mkdir /data/deploy/${RES_V}
    fi

    mv ${TAR_PATH}/res /data/deploy/${RES_V}/
    mv ${TAR_PATH}/crossdomain.xml /data/deploy/${RES_V}/
    if [  -d /data/deploy/${RES_V}/res ] && [ -e  /data/deploy/${RES_V}/crossdomain.xml ]; then
        return 0
    else
        return 1
    fi
}

delete_symlink()
{
    if [ -L /data/www/static ]; then
        rm -rf /data/www/static
        return 0
    else
        echo "static not exist or static is not symlink"
        return 1
    fi
}

make_symlink()
{
    if [ ! -L /data/www/static ];then
        ln -s /data/deploy/${RES_V} /data/www/static
        return 0
    else
        echo "static exist or static is not symlink"
        return 1
    fi
}

if check_res;then
    echo "check res is OK!"
else
    echo "check res is failed! first run pull_static_resource_to_jp.sh"
    exit 1
fi

if check_md5;then
    echo "check md5 is OK !"
else
    echo "check md5 is failed!"
    exit 1
fi

if move_to_deploy;then
    echo "move code to deploy directory success!"
else
    echo "move code to deploy directory failed!"
    exit 1
fi

if delete_symlink;then
    echo "delete symlink success!"
else
    echo "delete symlink failed!"
    exit 1
fi

if make_symlink;then
    echo "make symlink success!"
else
    echo "make symlink failed!"
    exit 1
fi
