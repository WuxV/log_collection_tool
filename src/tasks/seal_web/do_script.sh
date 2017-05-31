#!/bin/sh
OUTPUT="output"

function task_info() 
{
    echo "  # Start task [ $1 ]"
}

task_info "pds-web log"
cp /var/log/pds-web.log $OUTPUT -rf

task_info "httpd log"
cp /var/log/httpd/ $OUTPUT -rf

task_info "web config"
cp /etc/smartmon/web/api_url.php $OUTPUT -rf
