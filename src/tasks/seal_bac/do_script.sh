#!/bin/sh
OUTPUT="output"

function task_info() 
{
    echo "  # Start task [ $1 ]"
}

for i in `ls /sys/bus/pbd/devices/`;do 
    echo "pbd : $i"
    echo "connections : "
    ls /sys/bus/pbd/devices/$i/connections
    for j in `ls /sys/bus/pbd/devices/$i/`;do 
        if [ -f /sys/bus/pbd/devices/$i/$j  -a "$j" != "mgmt" ];then
            echo -n "$j : "
            cat /sys/bus/pbd/devices/$i/$j
        fi
    done
done > $OUTPUT/pbd-device-list

