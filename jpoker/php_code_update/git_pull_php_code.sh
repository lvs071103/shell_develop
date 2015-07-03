#!/bin/sh
#
# exit 0 for success other for failed
#
#

if [ "$#" -ne 1 ];then
	echo "usage: $0 <git_version>"
	exit 1
fi

if [$UID -ne 0 ];then
	echo "You must run as root"
	exit
fi

GAME_VERSION="$1"
TIME=$(date "+%Y-%m-%d %H:%M:%S")
CODE_DIR=/data/salt/gamecode/
PDR_LIST=(poker_php_server poker_prd_config poker_sql)
JDR_LIST=(flash-policy-server gamagic-consumer gamagic-reporter global-messager jpoker-game-server recorder record-mover reservoir-server table-status poker-daily-rank jpoker-client-robot poker-tools)

checkout()
{
	/usr/bin/git pull && /usr/bin/git checkout $GAME_VERSION
	if [[ "$?" -eq 0 ]];then
		return 0
	else
		return 1
	fi
}

pull()
{
	/usr/bin/git pull
	if [[ "$?" -eq 0 ]];then
		return 0
	else
		return 1
	fi
}

make_md5()
{
	find ./ -name .git -a -type d -prune -o -type f ! -name "md5.data" -exec md5sum {} \; > md5.data
	if [[ "$?" -eq 0 ]];then
		return 0
	else
		return 1
	fi
}

# php code
for i in ${PDR_LIST[@]};do
	cd $CODE_DIR/php/$i
	if checkout; then
		echo "$TIME    pull php ${i} code success"
	else
		echo "$TIME    pull php ${i} code failed"
		exit 1
	fi
done

cd $CODE_DIR/php
if make_md5;then
	echo "make php md5sum success!"
else
	echo "make php md5sum failed!"
	exit 1
fi


# java code
for i in ${JDR_LIST[@]};do
	cd $CODE_DIR/java/$i
	if pull;then
		echo "$TIME    pull java ${i} code success"
	else
		echo "$TIME    pull java ${i} code failed"
		exit 1
    fi
done

cd $CODE_DIR/java
if make_md5;then
	echo "make java md5sum success!"
else
	echo "make java md5sum failed!"
	exit 1
fi

exit 0
