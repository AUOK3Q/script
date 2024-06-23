#!/bin/bash

##  随机生成1000 ~ 60000随机数
function mimvp_uid_num() {
  min=$1
  max=$2
  mid=$(($max-$min+1))
  num=$(head -n 20 /dev/urandom | cksum | cut -f1 -d ' ')
  randnum=$(($num%$mid+$min))    
 
  # 排除已使用数字后随机添加
  used_id=`awk -F: '{print $3}' /etc/passwd |sed ":a;N;s/\n/,/g;ta"`
  num_exclude='$used_id'
  flag=`echo ${num_exclude} | grep ${randnum} | wc -l`
  while [ "$flag" -eq "1" ]
  do
    num=$(head -n 20 /dev/urandom | cksum | cut -f1 -d ' ')
    randnum=$(($num%$mid+$min))    
    flag=`echo ${num_exclude} | grep ${randnum} | wc -l`
  done
  echo $randnum
}
 
function print_uid_num() {
  for i in {1..1};
  do
    randnum=$(mimvp_uid_num 1000 60000)
    echo -e $randnum
  done
}
 
print_uid_num
