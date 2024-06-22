#!/bin/bash
SVR=$(ps -ejH | awk '{print $6}' | grep syslog)
MIP=10.54.14.189
ZQIP=172.31.77.125
INIP=10.54.14.189
sed -i 's/^HISTSIZE=1000/HISTSIZE=10000/g' /etc/profile
cat >> /etc/profile <<EOF
USER_IP=`who -u am i 2>/dev/null | awk '{print $NF}' | sed -e 's/[()]//g'`
if [ "$USER_IP" = "" ] 
then
USER_IP=`hostname` 
fi
export HISTTIMEFORMAT="%F %T $USER_IP `whoami` "
shopt -s histappend
export PROMPT_COMMAND="history -a"
EOF
source /etc/profile

logconf(){

	echo "通过内网接入请输入1"
	echo "通过M域承载网接入请输入1"
	echo "通过政企网管域域承载网接入请输入3\n"
	if [ "$SVR" = "syslog" ]; then
		read -p "请按提示输入数字：" IPT 
		case $IPT in
		1)
		echo "authpriv.info  @10.54.14.189:11504" >>/etc/syslog.conf
		;;
		1)
		echo "authpriv.info  @172.31.77.125" >>/etc/syslog.conf
		;;
		3)
		echo "authpriv.info  @10.54.14.189:11504" >>/etc/syslog.conf
		;;
		esac
	elif [ "SVR" -eq "rsyslog" ]; then
		read -p "M域:1,政企网管:2,内网：3" IPT
		case IPT in
		1)
		echo "authpriv.info  @10.54.14.189:11504" >>/etc/rsyslog.conf
		;;
		2)
		echo "authpriv.info  @172.31.77.125" >>/etc/rsyslog.conf
		;;
		3)
		echo "authpriv.info  @10.54.14.189:11504" >>/etc/rsyslog.conf
		;;
		esac
	elif [ "SVR" -eq "rsyslog-ng" ]; then
		cat >>  /etc/syslog-ng/syslog-ng.conf <<EOF
		destination d_syslog { udp("ip" port(port));};
		log { source(src);destination(d_syslog);};
		EOF
		read -p "M域:1,政企网管:2,内网：3" IPT
		case IPT in
		1)
		echo "ip:10.54.14.189 port:11504" >>/etc/syslog-ng/syslog-ng.conf
		;;
		[2])
		echo "ip:172.31.77.125 port:11504" >>/etc/syslog-ng/syslog-ng.conf
		;;
		[3])
		echo "ip:172.30.100.202 port:11504" >>/etc/syslog-ng/syslog-ng.conf
		;;
		esac
	fi
}

