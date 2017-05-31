#!/bin/sh

OUTPUT=./output
 
echo "  # Start task [ cp asm log ]"
mkdir -p $OUTPUT/asm-log
for file in $(find /u01/app/grid/diag/asm/+asm/ -type f)
do
    file_type=${file##*.}
    if [ $file_type == "log" -o $file_type == "xml" ];then
        cp $file $OUTPUT/asm-log -rf
    fi
done

echo "  # Start task [ cp oracle log ]"
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

task_info "smartmgrcli node info"
smartmgrcli node info > $OUTPUT/nodeinfo

task_info "smartmgrcli disk list"
smartmgrcli disk list > $OUTPUT/disklist

task_info "smartmgrcli disk info"
for disk in `smartmgrcli disk list|awk '{print $2}'|egrep 'hd|sd'`
do
    smartmgrcli disk info -n $disk > $OUTPUT/diskinfo_$disk 
done

task_info "smartmgrcli flash list"
smartmgrcli flash list > $OUTPUT/flashlist

task_info "smartmgrcli pool list"
smartmgrcli pool list > $OUTPUT/poollist

task_info "smartmgrcli lun list"
smartmgrcli lun list > $OUTPUT/lunlist

task_info "smartmgrcli lun info"
for lun in `smartmgrcli lun list|awk '{print $2}'|egrep 'hd|sd|lun'`
do
    smartmgrcli lun info -n $lun > $OUTPUT/luninfo_$lun
done

task_info "/etc/init.d/smartmgr_ctl status"
/etc/init.d/smartmgr_ctl status > smartmgr_ctl

task_info "Catch srp info"
./tools/smartscsiadmin  --list_target > $OUTPUT/srp_target
./tools/smartscsiadmin  --list_device  > $OUTPUT/srp_device
./tools/smartscsiadmin  --list_group  > $OUTPUT/srp_group
./tools/smartscsiadmin  --write_config > $OUTPUT/srp.conf
