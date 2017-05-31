#!/bin/sh

OUTPUT=./output
 
function task_info() 
{
    echo "  # Start task [ $1 ]"
}

task_info "cp asm log"
mkdir -p $OUTPUT/asm-log
for file in $(find /u01/app/grid/diag/asm/+asm/ -type f)
do
    file_type=${file##*.}
    if [ $file_type == "log" -o $file_type == "xml" ];then
        cp $file $OUTPUT/asm-log -rf
    fi
done

task_info "cp oracle log"
mkdir -p $OUTPUT/oracle-log
for file in $(find /u01/app/oracle/diag/rdbms/ -type f)
do
    file_type=${file##*.}
    if [ $file_type == "log" -o $file_type == "xml" ];then
        cp $file $OUTPUT/oracle-log -rf
    fi
done

task_info "multipath -l"
multipath -l > $OUTPUT/multipath

task_info "lsscsi|grep BIO"
lsscsi|grep BIO > $OUTPUT/lsscsi_bio
