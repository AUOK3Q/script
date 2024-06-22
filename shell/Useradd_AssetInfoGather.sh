#!/bin/bash
RU=$(env | grep USER | cut -d "=" -f 2)
FD=("/proc" "/var/log")
HIP=$(echo $SSH_CONNECTION | awk '{print $3}')
MDWR=("java" "nginx" "Heartbeat" "haproxy" "hadoop" "mariadb" "docker" "containerd" "kafka" "httpd" "Apache" "oracle" "mysql" "PostgreSQL" "mongoDB" "redis" "websphere" "weblogic")
CMD=("ip" "uname" "echo" "hostname" "rpm" "netstat" "groups" "ps" "find" "iptables" "lsb_release" "dpkg" "dladm" "ifconfig" "showrev" "pfiles" "ipnat" "sockstat" "oslevel")
PG=$(openssl rand 8 | base64)

echo -e "\033[1;31;47m -------------------------------------------\033[0m"
echo -e "\033[1;31;47m --------------【主要功能】-----------------\033[0m"
echo -e "\033[1;31;47m ---------1）新增资产采集的系统账号---------\033[0m"
echo -e "\033[1;31;47m ---------2）授权主机信息目录读权限---------\033[0m"
echo -e "\033[1;31;47m ---------3）授权中间件读和执行权限---------\033[0m"
echo -e "\033[1;31;47m ---------4）授权采集命令的执行权限---------\033[0m"
echo -e "\033[1;31;47m -------------------------------------------\033[0m"

#中间件授权
mdware_grant(){
    for(( i=0;i<${#MDWR[@]};i++ )); do
        echo -n "正在搜索${MDWR[i]}的安装目录>>>"
        path=$(which "${MDWR[i]}" 2>/dev/null)
        if [ $? -eq 0 ]; then
            echo -e "\033[1;32;47m${MDWR[i]}的安装目录为${path}\033[0m"
            setfacl -m u:asset:rx -R  "${path}" &>/dev/null
            echo -e "\033[1;32;47m已为asset用户授权$path的读和执行权限\033[0m"
        else
            echo -e "\033[1;31;47m未找到${MDWR[i]}的安装目录！\033[0m"
        fi
    done
}
#采集目录授权
fd_grant(){
    for(( j=0;j<${#FD[j]};j++ )); do
        if [[ -d "${FD[j]}" ]]; then
            setfacl -m u:asset:r -R "${FD[j]}" &>/dev/null
            echo -e "\033[1;32;47masset已经有${FD[j]}目录的读权限\033[0m"
        else
             echo -e "\033[1;31;47m没有${FD[j]}目录\033[0m"
        fi
    done
}
#采集命令授权
cmd_grant(){
    for((i=0;i<${#CMD[@]};i++)) do
        if [[ -n $(which "${CMD[i]}" 2>/dev/null) ]];then
            setfacl -m u:asset:x $(which "${CMD[i]}") &>/dev/null
            echo -e "\033[1;32;47m已为asset账号添加${CMD[i]}命令的执行权限\033[0m"
        else
            echo -e "\033[1;31;47m未找到${CMD[i]}命令，请根据系统发行版本手工授权\033[0m" 
        fi 
    done
}
#检查root权限
if [ `echo ${RU} | awk -v tem="root" '{print($1>tem)? "1":"0"}'` -ne "0" ]; then
    echo -e "\033[1;31;47m请切换到root账号执行脚本！\033[0m\n"
    exit -1
#检查账号是否创建
elif id "asset" &>/dev/null;then
    echo -e "\033[1;32;47masset账号已存在,开始为资产信息采集所需目录|中间件|采集命令授权\033[0m\n"
    fd_grant FD
    mdware_grant MDWR
    cmd_grant CMD
else
    useradd asset &>/dev/null
    echo $PG | passwd --stdin asset &>/dev/null 
    echo -e "\033[1;32;47m$HIP的asset账号已创建，密码为:$PG,请尽快同步到4A。\033[0m\n"
    echo -e "\033[1;32;47m开始为资产信息采集所需目录|中间件|采集命令授权\033[0m\n"
    fd_grant FD
    mdware_grant MDWR
    cmd_grant CMD
fi
