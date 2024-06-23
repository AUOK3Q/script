#!/bin/bash
BASE_RECORD=$(touch baserecord.txt)
awk -F: '{print $1,$3}' > $BASE_RECORD
NEW_RECORD=$(touch $date_user.txt)
DIFF_RECORD="`diff $NEW_RECORD $BASE_RECORD |grep "^<" | awk '{print $2}'`"
FINAL_RECORD=$(touch /etc/obsolete_user)

if [ $DIFF_RECORD -eq ''];then
echo "未发现删除的账号"
else
for  line in `cat $DIFF_RECORD`;do
   for $line in `cat $NEW_RECORD`;do
      echo $line >> $FINAL_RECORD
done
done
fi