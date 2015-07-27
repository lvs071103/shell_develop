#!/bin/sh


echo_n=
echo_c=
day_time=`date +%Y%m%d-%H%M`
NEW_STABLE_DIR=/home/jack/newpackage/test_release/dev
RELEASE_DIR=/home/jack/newpackage/test_release/release

trap "interrupt" 1 2 3 6 15

set_echo_compat() {
    case `echo "testing\c"`,`echo -n testing` in
        *c*,-n*) echo_n=   echo_c=     ;;
        *c*,*)   echo_n=-n echo_c=     ;;
        *)       echo_n=   echo_c='\c' ;;
    esac
}

update()
{
        if [ ! -d ${RELEASE_DIR}/${path} ];then
                mkdir ${RELEASE_DIR}/${path}
        fi

        if [ -e ${RELEASE_DIR}${path}/${file} ];then
                cp ${RELEASE_DIR}${path}/${file} ${RELEASE_DIR}${path}/${file}-${day_time}
        fi
        /bin/cp -rf ${NEW_STABLE_DIR}${path}/${file} ${RELEASE_DIR}${path}/${file}
}


make_md5sum()
{
        find ./ -type f -exec md5sum {} \; > ${RELEASE_DIR}/.md5.data
}

check_md5()
{
        md5sum -c .md5.data > /tmp/md5_different.log 2>&1
}

interrupt() {
    echo
    echo "Aborting!"
    echo
    cleanup
    stty echo
    exit 1
}

cleanup() {
    echo "Cleaning up..."
}

set_echo_compat

cd ${NEW_STABLE_DIR}
if make_md5sum;then
        echo "make md5sum complete"
fi

cd ${RELEASE_DIR}
echo "md5sum check detail view /tmp/md5_different.log"

if check_md5;then
        echo "md5sum check OK"
        exit 0
else
        echo "md5sum check failed"
fi

NUM=`cat /tmp/md5_different.log | grep "FAILED" | wc -l`

if [ ${NUM} -ne 0 ];then
        echo "md5sum check failed number: ${NUM}"
fi

FILE_LIST=`awk -F: '/FAILED/ {print $1}' /tmp/md5_different.log`

echo 
echo "Enter y Batch update"
echo "Enter n skipping update"
echo "Enter m Manually update"
echo 

echo $echo_n "Batch Update?[y/n/m] $echo_c"
read reply
if [ "$reply" = "y" ];then
        cd ${NEW_STABLE_DIR}
        for i in ${FILE_LIST};do
                file=`basename ${i}`
                path=`echo ${i} | awk -F/ '{for(a=2;a<NF;a++){printf "/%s",$a}}'`
                update
        done
        echo "Batch update sucess."
elif [ "$reply" = "n" ];then
        echo "... skipping."
elif [ "$reply" = "m" ];then
        echo
        echo "Manually update"
        echo
        for i in ${FILE_LIST};do
                file=`basename ${i}`
                path=`echo ${i} | awk -F/ '{for(a=2;a<NF;a++){printf "/%s",$a}}'`
                echo $echo_n "Update? [y/n] $echo_c"
                read reply
                if [ "$reply" = "n" ]; then
                        echo " ${path}/${file} ... skipping."
                else
                        echo "${path}/${file} success."
                        update
                fi
        done
fi
