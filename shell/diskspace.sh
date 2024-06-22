#!/bin/bash
#Insepct Harddisk , If the remaining space is more than 80%, the message is sent to the wl
#Tue Aug 2 09:45:56 CST 2016
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/wl/bin
export PATH
for RemainingSpace in $(df -h | awk '{print $5}' | grep -v 'Use' | sed -e
's/[%]//g')
do
if [[ $RemainingSpace > 95 ]];then
echo -e "$RemainingSpace"
echo -e "$(df -h | grep $RemainingSpace)" > /service/script/.HarddiskWarning
mail -s "disk Warning" wl < /service/script/.HarddiskWarning
fi
done