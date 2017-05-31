#!/bin/bash

if [ $USER != 'root' ]; then
    echo "Please use root!!!"
    exit
fi

if [ "$1" != '-f' ];then
    read -p "Start collect log, Are you sure? (Y/N): " INPUT
    case "$INPUT" in
        y|Y)
            ;;
        n|N)
            exit 1
            ;;
        *)
            exit 1
            ;;
    esac
fi

HOME_DIR="/root"
LOG_COLLECTION="log-files"
OUTPUT="output"

LOG_COLLECTION_PATH="$HOME_DIR/$LOG_COLLECTION"

DO_CHECK="do_check.sh"
DO_SCRIPT="do_script.sh"

function task_info() 
{
    echo "### Start collection [ $1 ]"
}

function result_info() 
{
    echo ""
    echo "Collection complete : $HOME_DIR/$1"
}

cd `dirname $0`
mkdir -p $LOG_COLLECTION_PATH

for dir in $(ls -l tasks/ |awk '/^d/ {print $NF}')
do
    dir_path="tasks/$dir"
    sh $dir_path/$DO_CHECK
    if [ $? -eq 0 ];then
        task_info $dir
        mkdir -p $dir_path/$OUTPUT
        cd $dir_path ; sh $DO_SCRIPT 2>/tmp/log-collection-error ; cd - >/dev/null
        mkdir -p $LOG_COLLECTION_PATH/$dir
        mv $dir_path/$OUTPUT/* $LOG_COLLECTION_PATH/$dir 2>/tmp/log-collection-error
    fi
done

now=$(date +%Y%m%d%H%M)
hostname=$(uname -n)
log_collection="$LOG_COLLECTION-$hostname-$now"
log_collection_tarball="$log_collection.tar.gz"
cd $HOME_DIR
mv $LOG_COLLECTION $log_collection
tar -zcf $log_collection.tar.gz $log_collection
rm -rf $log_collection

result_info $log_collection_tarball
