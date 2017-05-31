#!/bin/sh
OUTPUT="output"

function task_info() 
{
    echo "  # Start task [ $1 ]"
}

task_info "opt history"
cp /var/log/pds/.opt_history $OUTPUT/opt_history -rf

task_info "get metadata"
cat /opt/pds/conf/service.mds.ini | grep server | cut -d '=' -f 2 | xargs -I {} ./tools/pds-zk -z {} -l /pds/MetaData > $OUTPUT/metadata

task_info "get mds info"
cat /opt/pds/conf/service.mds.ini | grep server | cut -d '=' -f 2 | xargs -I {} ./tools/pds-zk -z {} -g /pds/NameServer/master/mds > $OUTPUT/mds
