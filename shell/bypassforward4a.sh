#!/bin/bash
IP_POOL=("172.30.100.102" "10.54.14.189" "172.31.77.125")
SVRIP=''
HSIZE=$(grep HISTSIZE /etc/profile | awk -F= '{print $2}')
#日志取证
function forensic_conf() {
	sed -i 's/^HISTSIZE=1000/HISTSIZE=30000/g' /etc/profile
	sed -i "s/^rotate 4/rotate 24/g" /etc/logrotate.conf
	sed -i "s/1/6/g" /etc/logrotate.conf
	cat >>/etc/profile <<EOF
USER_IP=$(who -u am i 2>/dev/null | awk '{print $NF}' | sed -e 's/[()]//g')
if [ "$USER_IP" = "" ] 
then
USER_IP=$(hostname) 
fi
export HISTTIMEFORMAT="%F %T $USER_IP $(whoami) "
shopt -s histappend
export PROMPT_COMMAND="history -a"
EOF
	source /etc/profile
	echo $HSIZE
}

#网络测试
function netcon_test() {
	for i in "${!IP_POOL[@]}"; do
		ping -c1 -W1 ${IP_POOL[$i]} &>/dev/null
		if [ $? -eq 0 ]; then
			SVRIP=${IP_POOL[$i]}
		else
			echo "请检查您的网络"
		fi
	done
}
#绕行转发
function bypss_fwdcfg() {
	if ! type rsyslogd >/dev/null 2>&1; then
		echo "请安装rsyslog"
	else
		forensic_conf
		netcon_test
		echo "authpriv.info    @$SVRIP:11504" >>/etc/rsyslog.conf
		systemctl restart rsyslogd
	fi

}
