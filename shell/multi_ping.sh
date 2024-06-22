#!/bin/bash
#Version1.0
#ping测试

net=([0]="172.31.67"[1]="172.30.17"[3]="172.31.71")
multi_ping() {
    ping -c2 -i0.2 -W1 $1 &>/dev/null
    if [ $? -eq 0 ];then
        echo "$1 is up"
    else
        echo "$1 is down"
    fi
}
for i in net
do
    for j in [1..254]
    do
        multi_ping $net[i].$j &
    done
    wait
done