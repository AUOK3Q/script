#/bin/bash
#author by lichunlei
username=$(whoami)
# Welcome
sysver=$(cat /etc/os-release | grep PRETTY_NAME | cut -c14-27)

# Memory
memory_total=$(cat /proc/meminfo | awk '/^MemTotal:/ {printf($2)}')
memory_free=$(cat /proc/meminfo | awk '/^MemFree:/ { printf($2)}')
buffers=$(cat /proc/meminfo | awk '/^Buffers:/ { printf($2)}')
cached=$(cat /proc/meminfo | awk '/^Cached:/ { printf($2)}')
sreclaimable=$(cat /proc/meminfo | awk '/^SReclaimable:/ { printf($2)}')
swap_total=$(cat /proc/meminfo | awk '/^SwapTotal:/ { printf($2)}')
swap_free=$(cat /proc/meminfo | awk '/^SwapFree:/ { printf($2)}')
pass_expire=$(chage -l $username | grep 'Password expires' | awk -F":" '{print $2}')
login_times=$(last | grep "^$(whoami)" | head -1 | awk '{print $4,$5,$6,$7}')

if [ $memory_total -gt 0 ]
then
    memory_usage=`echo "scale=1; ($memory_total - $memory_free - $buffers - $cached - $sreclaimable) * 100.0 / $memory_total" |bc`
    memory_usage="${memory_usage}%"
else
    memory_usage=0.0%
fi

# Swap memory
if [ $swap_total -gt 0 ]
then
    swap_mem=`echo "scale=1; ($swap_total - $swap_free) * 100.0 / $swap_total" |bc`
    swap_mem="${swap_mem}%"
else
    swap_mem=0.0%
fi

# Usage
usageof=$(df -h / | awk '/\// {print $(NF-1)}')

# System load
load_average=$(awk '{print $1}' /proc/loadavg)

# WHO I AM
whoiam=$(whoami)

# Time
time_cur=$(date)

# Processes
processes=$(ps aux | wc -l)

# Users
user_num=$(users | wc -w)

# Ip address
ip_pre=""
if [ -x "/sbin/ip" ]
then
    ip_pre=$(/sbin/ip a | grep inet | grep -v "127.0.0.1" | grep -v inet6 | awk '{print $2}')
fi

echo -e "##############################################\n"
echo -e "欢迎使用  $sysver\n"
echo -e "系统时间: \t$time_cur\n"
echo -e "当前进程数: \t$processes\n"
echo -e "内存已使用: \t$memory_usage\n"
echo -e "交换分区已使用: \t$swap_mem\n"
echo -e "磁盘已使用: \t$usageof\n"
echo -e "上一次登录:\t$login_times\n"
echo -e "密码过期:$pass_expire\n"
echo -e "系统负载: \t\033[0;33;40m$load_average\033[0m\n"
for line in $ip_pre
do
    ip_address=${line%/*}
    echo -e "IP地址: \t$ip_address"
done
echo -e "在线用户数: \t$user_num"
if [ "$whoiam" == "root" ]
then
    echo -e "##############################################"
else
    echo -e "To run a command as administrator(user \"root\"),use \"sudo <command>\"."
    echo -e "##############################################"
fi
