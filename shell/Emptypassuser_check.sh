#!/bin/bash
#默认密码，自行设定
PASS="nF7NGV@r7$yXbBV"

EMPASS_USER="`getent shadow | grep '^[^:]*:.\?:' | cut -d: -f1 | sed ":a;N;s/\n/,/g;ta"`"

if [ $EMPASS_USER -eq '']; then
    echo "不存在空口令账号"
else
    for line in $(getent shadow | grep '^[^:]*:.\?:' | cut -d: -f1); do
        echo $PASS | passwd $line --stdin
    done
fi
