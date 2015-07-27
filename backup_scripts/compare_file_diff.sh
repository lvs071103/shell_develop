#!/bin/sh

echo_n=
echo_c=
day_time=`date +%Y%m%d-%H%M`
NEW_STABLE_DIR=/home/jack/newpackage/upload
RELEASE_DIR=/data/www/jdxc.sh.cn/bbs
cd ${NEW_STABLE_DIR}
FILE_LIST=$(find ./ -name "*.php")

update_1()
{
        if [ -e ${RELEASE_DIR}${path_name}/${file_name} ];then
                cp ${RELEASE_DIR}${path_name}/${file_name} ${RELEASE_DIR}${path_name}/${file_name}-${day_time}
        fi

        cp -rf ${NEW_STABLE_DIR}/${file_name} ${RELEASE_DIR}/${file_name}
}

update_2()
{
        if [ ${RELEASE_DIR}${path_name}/${file_name} ];then
                cp ${RELEASE_DIR}${path_name}/${file_name} ${RELEASE_DIR}${path_name}/${file_name}-${day_time}
        fi

        cp -rf ${NEW_STABLE_DIR}${path_name}/${file_name} ${RELEASE_DIR}${path_name}/${file_name}
}


for i in ${FILE_LIST[@]};do
        file_name=`basename $i`
        path_name=`echo $i | awk -F/ '{for(a=2;a<NF;a++) printf "/%s",$a}'`
        if [ -z "$path_name" ];then
                diff -q ${NEW_STABLE_DIR}/${file_name} ${RELEASE_DIR}/${file_name}
                if [[ "$?" -eq 0 ]];then
                        : #nothing to do
                else
                        echo $echo_n "Update? [Y/n] $echo_c"
                        read reply
                        if [ "$reply" = "n" ]; then
                                echo " ... skipping."
                        else
                                update_1
                        fi
                        echo "---------------------------------华丽分隔线-------------------------------"
                fi
        else
                diff -q ${NEW_STABLE_DIR}${path_name}/${file_name} ${RELEASE_DIR}${path_name}/${file_name}
                if [ "$?" -eq 0 ];then
                        : #nothing to do 
                else
                        echo $echo_n "Update? [Y/n] $echo_c"
                        read reply
                        if [ "$reply" = "n" ]; then
                                echo " ... skipping."
                        else
                                update_2
                        fi
                        echo "---------------------------------华丽分隔线-------------------------------"
                fi
        fi

done
