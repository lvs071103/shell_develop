#!/bin/sh

USAGE="Usage: sh $0 [count]
    count   产生密码的个数, 默认为 1
"

[ $# == 1 ] && C=$1 || C=1

# LENGTH 格式(个数): 数字 小写字母 大写字母
LENGTH=(4 6 6)

S=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
s=(a b c d e f g h i j k l m n p q r s t u v w x y z)
# a=($(echo ${S[*]} | sed 's/O//' | tr 'A-Z' 'a-z'))

# 0 <= $RANDOM <= 32767
N=$((32767/(${#S[*]}-1)))
n=$((32767/(${#s[*]}-1)))

c=1
until ((${#STR}==${LENGTH[0]}+${LENGTH[1]}+${LENGTH[2]} && c>C)); do
    STR=$((for((i=0;i<${LENGTH[0]};i++)); do echo $RANDOM $(($RANDOM/3640)); done
    for((i=0;i<${LENGTH[1]};i++)); do echo $RANDOM ${S[$(($RANDOM/$N))]}; done
    for((i=0;i<${LENGTH[2]};i++)); do echo $RANDOM ${s[$(($RANDOM/$n))]}; done) | sort -nk1 | awk '{printf("%s",$2)}')
    echo -e "$c\t$STR"
    let c=$c+1
done

# 随机大写字母 A-Z
#echo ${S[$(($RANDOM/$N))]}
# 随机小写字母 a-z 不包括 o
#echo ${s[$(($RANDOM/$n))]}
# 随机数字 0-9
#echo $(($RANDOM/3640))
