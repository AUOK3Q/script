#!/bin/bash

echo "请输入期望的CPU使用率（0-80之间的整数）："
read rate

if [[ ! $rate =~ ^[0-9]+$ || $rate -lt 0 || $rate -gt 80 ]]; then
    echo echo -e "\033[1;31;47m不合法的输入！\033[0m"
    exit 1
fi

while true; do
    cpu_avg=$(top -b -n 1 | grep "Cpu(s)" | awk '{print $2}' | cut -d "." -f 1)
    if ((cpu_avg < $rate)); then
	stress --cpu 1 --timeout 2s &
    fi
    sleep 1
done
