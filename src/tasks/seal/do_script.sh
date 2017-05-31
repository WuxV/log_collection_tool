#!/bin/sh
OUTPUT="output"

function task_info() 
{
    echo "  # Start task [ $1 ]"
}

task_info "cp pds log"
mkdir -p $OUTPUT/log
cp /var/log/pds/.*.stdlog $OUTPUT/log -rf
cp /var/log/pds/*.log $OUTPUT/log -rf

task_info "cp conf"
cp /opt/pds/conf $OUTPUT/conf -rf
