#!/bin/bash

TIMES=0
#最多允许3次失败
FAIL_TIME=3
LIST=""
CURR_TIME=`date "+%Y-%m-%d %H:%M:%S"`

#过滤出尝试连接主机的ip
LIST=$(grep "authentication failure" /var/log/secure | awk '{print$14}' | sed -e 's/rhost=//g' -e 's/ /_/g' | uniq)

#Trusted Hosts
excludeList=( "116.31.95.82" )

function chkExcludeList()
{
    for j in "${excludeList[@]}"; do
        if [[ "$1" == $j ]]; then
            return 10
        else
            TIMES=$(grep -o "$1" /var/log/secure|wc -l)
            if [ $TIMES -lt $FAIL_TIME ]; then
                return 10
            fi
        fi
    done
    return 11
}

#检查并追加到hosts.deny文件中
for i in $LIST; do
    chkExcludeList "$i"
        if [ $? != "10" ]; then
            if [ "$(grep $i /etc/hosts.deny)" = "" ]; then
                echo "# "$CURR_TIME >> /etc/hosts.deny 
                echo "ALL: $i : DENY" >> /etc/hosts.deny
            fi
        fi
done
