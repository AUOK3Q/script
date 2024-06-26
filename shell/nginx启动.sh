#!/bin/bash
#chkconfig:2345 90 98
#cnetos nginx启动脚本

nginx="/usr/bin/nginx/sbin/nginx"
pidfile="/usr/local/nginx/logs/nginx.pid"

case $1 in 
start)
	if [ -f $pidfile ];then
		echo -e "\033[91mNginx is already running...\033[0m"
		exit
	else
		$nginx && echo -e "\033[91mNginx is already runnning...\033[0m"
	fi;;
stop)
	if [ ! -f $pidfile ];then
		echo -e "\033[91mNginx is already stoped!\033[0m"
		exit
	else
		$nginx -s stop && echo -e "\033[32mNginx is already stoped!\033[0m"
	fi;;
restart)
	if [ ! -f $pidfile ];then
		echo -e "\033[91mNginx is already stoped!\033[0m"
		echo -e "\033[91mPlease to run nginx first.\033[0m"
		exit
	else 
		$nginx -s stop & echo -e "\033[32mNginx is stoped!\033[0m"
	fi
	$nginx && echo -e "033[32mNginx is running...\033[0m"
	;;
status)
	if [ -f $pidfile ];then
		echo -e "\033[32mNginx is running...\033[0m"
	else
		echo -e "\033[32mNgnix is stoped!\033[0m"
	fi;;
reload)
	if [ ! -f $pidfile ];then
		echo -e "\033[91mNginx is already stoped!\033[0m"
		exit
	else
		$nginx -s reload && echo -e "\033[32mReload configrue done.\033[0m"
	fi;;
*)
echo "Usage:$0 {start|stop|status|reload}";;
