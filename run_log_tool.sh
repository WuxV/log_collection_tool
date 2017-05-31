#!/bin/bash
rm -rf /tmp/.log_collection
dir_tmp=/tmp/.log_collection
mkdir $dir_tmp
sed -n -e '1,/^exit 0$/!p' $0 > "${dir_tmp}/src.tar.gz" 2>/dev/null
cd $dir_tmp
tar zxf src.tar.gz >/dev/null 2>&1
cd src
sh start.sh $@
rm /tmp/.log_collection -rf
exit 0
