#!/bin/bash

rpm -q pal > /dev/null 2>&1
[ $? -ne 0 ] && exit 1 || exit 0
