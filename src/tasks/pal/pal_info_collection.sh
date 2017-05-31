#!/bin/bash

#Generator script for PAL information collection

# Copyright Phegda, Inc.  All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#

PAL_SYSFS_DIR="/sys/fs/pal/"
PAL_INFO_COLLECTION="output"
PAL_INFO_SYSFS_DIR=$PAL_INFO_COLLECTION/pal
PAL_INFO_MODULE_DIR=$PAL_INFO_COLLECTION/module

mkdir -p $PAL_INFO_COLLECTION
mkdir -p $PAL_INFO_SYSFS_DIR
mkdir -p $PAL_INFO_MODULE_DIR

function task_info() 
{
    echo "  # Start task [ $1 ]"
}

catch_dir_recursive()
{
    local INPUT_DIR=$1      # "/sys/fs/pal/"
    local OUTPUT_DIR=$2     # pal_info/pal     
    local ENTRY=""

    for ENTRY in $(find $INPUT_DIR -type f);
    do
        READABLE=false
        USER_ID=$(id -u)
        if [ $USER_ID -eq 0 ]; then
            PERMISSION=$(stat -c %a $ENTRY)
            PERMISSION=${PERMISSION:0:1}
            if (( $PERMISSION & 4 )); then
                READABLE=true
            fi
        else
            if [ -r $ENTRY ]; then
                READABLE=true
            fi
        fi
        if [ "$READABLE"x == "true"x ]; then
            ENTRY_RELATIVE_PATH=${ENTRY#$INPUT_DIR}
            ENTRY_DIRNAME=$(dirname $ENTRY_RELATIVE_PATH)
            ENTRY_BASENAME=$(basename $ENTRY_RELATIVE_PATH)
            mkdir -p $OUTPUT_DIR/$ENTRY_DIRNAME
            cat $ENTRY > $OUTPUT_DIR/$ENTRY_DIRNAME/$ENTRY_BASENAME
        fi
    done
}

task_info "Catch sysfs information"
catch_dir_recursive $PAL_SYSFS_DIR $PAL_INFO_SYSFS_DIR

task_info "Catch module information"
for MODULE in $(ls -d /sys/module/pal* 2>/dev/null); do
    MODULE_NAME=$(basename $MODULE)
    catch_dir_recursive $MODULE $PAL_INFO_MODULE_DIR/$MODULE_NAME
done
