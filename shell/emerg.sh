#!/bin/bash

read -p "请输入数字：" NUM
    case NUM in 
    1)echo "可疑爆破IP数量：\n"
    echo $(grep "Failed password for" /var/log/secure | awk '{print $11}' | sort | uniq -c | sort -nr | more)
    ;;
    2)echo "可以爆破IP列表：\n"
    echo $(grep "Failed password" /var/log/secure|grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"|uniq -c)    ;;
    3)echo "爆破用户名列表：\n"
    echo $(grep "Failed password" /var/log/secure|perl -e 'while($_=<>){ /for(.*?) from/; print "$1\n";}'|uniq -c|sort -nr)
    ;;
    esac