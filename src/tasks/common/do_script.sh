#!/bin/bash

OUTPUT="output"
baseinfo_file=$OUTPUT/baseinfo

function task_info() 
{
    echo "  # Start task [ $1 ]"
}

task_info "BaseInfo"
# systime
echo "Systime : `date`" >> $baseinfo_file

# check os type
os=$(uname -o)
echo "OS Type: $os" >> $baseinfo_file

# check os release version and name
os_name=$(cat /etc/system-release)
echo "OS Release: $os_name" >> $baseinfo_file

# check architecture
architecture=$(uname -m)
echo "OS Architecture: $architecture" >> $baseinfo_file

# check kernel release
kernelrelease=$(uname -r)
echo "Kernel Release: $kernelrelease" >> $baseinfo_file

# check hostname 
hostname=$(uname -n)
echo "Hostname: $hostname" >> $baseinfo_file

# check internal ip
internalip=$(hostname -I)
echo -e "Internal IP:" >> $baseinfo_file
for ip in $internalip
do
    echo -e "$ip" >> $baseinfo_file
done

# check dns
nameserver=$(cat /etc/resolv.conf |grep -E "\<nameserver[ ]+"|awk '{print $NF}')
echo "DNS: $nameserver" >> $baseinfo_file

# check login users
echo -e "Login Users:\n$(who)" >> $baseinfo_file

# back cpuinfo
task_info "CpuInfo"
cat /proc/cpuinfo > $OUTPUT/cpuinfo

# back meminfo
task_info "Meminfo"
cat /proc/meminfo > $OUTPUT/meminfo

# back cmdline
cat /proc/cmdline > $OUTPUT/cmdline

# back modules
cat /proc/modules > $OUTPUT/modules

# check df
task_info "df"
df -h > $OUTPUT/df

# Catch kernel message
task_info "cp messages"
cp /var/log/messages $OUTPUT

# Catch process information
task_info "ps -elf"
ps -elf > $OUTPUT/ps
pstree -aApu > $OUTPUT/pstree

# Catch top information
task_info "top -H -bn 1"
top -H -bn 1 > $OUTPUT/top

# Catch iostat information for 5 seconds
task_info "iostat -dmx 1 5"
iostat -dmx 1 5 > $OUTPUT/iostat

# Catch CPU information for 5 seconds
task_info "mpstat -P ALL 1 5"
mpstat -P ALL 1 5 > $OUTPUT/mpstat

# network
task_info "ip a"
ip a > $OUTPUT/ip

# netstat
task_info "netstat -anp"
netstat -anp > $OUTPUT/netstat-anp
netstat -nr > $OUTPUT/netstat-nr

# firewalld
task_info "systemctl status firewalld"
systemctl status firewalld > $OUTPUT/firewalld

task_info "/etc/init.d/iptables status"
/etc/init.d/iptables status > $OUTPUT/iptables 2>/dev/null

# chkconfig 
task_info "chkconfig --list"
chkconfig --list > $OUTPUT/chkconfig 2>/dev/null

# systemctl
task_info "systemctl list-units --type=service"
systemctl list-units --type=service > $OUTPUT/services

# sar 
task_info "sar -n DEV  1 5"
sar -n DEV  1 5 > $OUTPUT/sar

# lspci
task_info "lspci"
./tools/lspci > $OUTPUT/lspci
./tools/lspci -t -vv > $OUTPUT/lspci_tree
./tools/lspci -vvv > $OUTPUT/lspci-vvv 2>/dev/null
./tools/lspci -xxxx > $OUTPUT/lspci-xxxx 2>/dev/null

# megeraid
task_info "perccli64 /call show"
./tools/perccli64 /call show > $OUTPUT/perccli64

task_info "storcli64 /call show"
./tools/storcli64 /call show > $OUTPUT/storcli64

# sas2raid
task_info "sas2ircu list"
./tools/sas2ircu list > $OUTPUT/sas2raid_list
for i in `./tools/sas2ircu list | grep "00h" | awk '{print $1}'`;do echo "Index:$i"; ./tools/sas2ircu $i display ;done > $OUTPUT/sas2raid_pre

# sysctl
task_info "sysctl -a"
sysctl -a > $OUTPUT/sysctl

# ulimit
task_info "ulimit -a"
ulimit -a > $OUTPUT/ulimit

# last
task_info "last"
last > $OUTPUT/last

# uptime
task_info "uptime"
uptime > $OUTPUT/uptime

# free
task_info "free"
free -m > $OUTPUT/free-m
free -g > $OUTPUT/free-g

# history
task_info "cat ~/.bash_history"
cat ~/.bash_history > $OUTPUT/history

# crash
task_info "cp /var/crash"
mkdir -p $OUTPUT/crash
for d in `ls /var/crash/`;do
    mkdir -p $OUTPUT/crash/$d
    cp /var/crash/$d/*.txt $OUTPUT/crash/$d
done

# grub.conf
task_info "cp /etc/grub*.cfg"
cp /etc/grub*.cfg $OUTPUT

# lsmod
task_info "lsmod"
lsmod > $OUTPUT/lsmod

# lsblk
task_info "lsblk"
lsblk > $OUTPUT/lsblk

# modinfo
task_info "modinfo"
mkdir $OUTPUT/modinfo
for m in `lsmod | grep -v ^Module | awk '{print $1}'`;do  modinfo $m > $OUTPUT/modinfo/$m;done

# service
task_info "service --status-all"
service --status-all > $OUTPUT/service-status 2>/dev/null

# dmidecode
task_info "dmidecode"
dmidecode > $OUTPUT/dmidecode

# biosdecode
task_info "biosdecode"
biosdecode > $OUTPUT/biosdecode

# swapon
task_info "swapon -s"
swapon -s > $OUTPUT/swapon

# rpm
# Verifying installed rpms may take 3-4 minutes
task_info "Catch installed rpms, this will take 3-4 minutes"
rpm -qa --queryformat '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}.rpm\n' | sort > $OUTPUT/rpm-qa
rpm -qaV > $OUTPUT/rpm-qav
