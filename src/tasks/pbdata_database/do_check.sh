#!/bin/bash

[ ! -f /boot/installer/platform ] && exit 1

if [ `cat /boot/installer/platform  | grep ^SYS_MODE | awk '{print $2}'` == "database" ];then
    exit 0
fi

exit 1
