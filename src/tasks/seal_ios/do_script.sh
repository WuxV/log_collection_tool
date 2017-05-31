#!/bin/sh
OUTPUT="output"

function task_info() 
{
    echo "  # Start task [ $1 ]"
}

task_info "cluster log"
cp /var/pds/cluster/ $OUTPUT -rf

task_info "iosd conf"
mkdir -p $OUTPUT/etc-pds-conf
cp /etc/pds/* $OUTPUT/etc-pds-conf -rf
