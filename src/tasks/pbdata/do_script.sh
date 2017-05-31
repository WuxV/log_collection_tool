#!/bin/sh

OUTPUT=./output

function task_info() 
{
    echo "  # Start task [ $1 ]"
}

## MegaCli Status Function
megacli_status()
{
  CONT="a0"
  STATUS=0
  echo -n "Checking RAID status on "
  for a in $CONT
  do
    NAME=`./tools/MegaCli64 -AdpAllInfo -$a -nolog | grep "Product Name" | cut -d: -f2`
    echo "Controller $a: $NAME"
    noonline=`./tools/MegaCli64 PDList -$a -nolog | grep Online | wc -l`
    echo "No of Physical disks online : $noonline"
    DEGRADED=`./tools/MegaCli64 -AdpAllInfo -a0 -nolog | grep "Degrade"`
    echo $DEGRADED
    NUM_DEGRADED=`echo $DEGRADED | cut -d" " -f3`
    [ "$NUM_DEGRADED" -ne 0 ] && STATUS=1
    FAILED=`$./tools/MegaCli64 -AdpAllInfo -a0 -nolog | grep "Failed Disks"`
    echo $FAILED
    NUM_FAILED=`echo $FAILED | cut -d" " -f4`
    [ "$NUM_FAILED" -ne 0 ] && STATUS=1
  done
  return $STATUS
}

task_info "cp srp info"
cp /etc/modprobe.d/ib_srp.conf $OUTPUT -rf

# =====================
# check
# =====================
task_info "check smartmon-trapper"
/etc/init.d/smartmon-trapper status > $OUTPUT/smartmon-trapper 2>/dev/null
if [ ! -s $OUTPUT/smartmon-trapper ]; then
    systemctl status smartmon-trapper > $OUTPUT/smartmon-trapper
fi

task_info "check smartmgr-agent"
/etc/init.d/smartmon-agent status > $OUTPUT/smartmon-agent 2>/dev/null
if [ ! -s $OUTPUT/smartmon-agent ]; then
    systemctl status smartmon-agent > $OUTPUT/smartmon-agent
fi

# =====================
# smartmgr
# =====================
task_info "cp smartmgr log"
mkdir -p $OUTPUT/smartmgr-log
cp /var/log/smartmgr/.*.stdlog $OUTPUT/smartmgr-log -rf
cp /var/log/smartmgr/*.log $OUTPUT/smartmgr-log -rf

task_info "cp smartmgr conf"
mkdir -p $OUTPUT/smartmon-conf/
cp /opt/smartmgr/conf/* $OUTPUT/smartmgr-conf -rf

task_info "cp smartmgr license"
mkdir -p $OUTPUT/smartmgr-license/
cp /opt/smartmgr/files/conf/* $OUTPUT/smartmgr-license -rf

task_info "check license"
if [ -e /opt/smartmgr/files/conf/pbdata.lic ]; then
    ./tools/licdisp -f /opt/smartmgr/files/conf/pbdata.lic > $OUTPUT/smartmgr-license/licdisp
fi

# =====================
# smartmon
# =====================
task_info "cp smartmon log"
mkdir -p $OUTPUT/smartmon-log/
cp /var/log/smartmon/.*.stdlog $OUTPUT/smartmon-log -rf
cp /var/log/smartmon/*.log $OUTPUT/smartmon-log -rf

task_info "cp smartmon conf"
mkdir -p $OUTPUT/smartmon-conf/
cp /opt/smartmon/files/conf/* $OUTPUT/smartmon-conf -rf


# =====================
# ipmi
# =====================
task_info "Catch IPMI info"
mkdir -p $OUTPUT/ipmi
./tools/ipmitool bmc info > $OUTPUT/ipmi/bmcinfo
./tools/ipmitool chassis status > $OUTPUT/ipmi/chassis-status
./tools/ipmitool chassis restart_cause > $OUTPUT/ipmi/chassis-restart_cause
./tools/ipmitool lan print > $OUTPUT/ipmi/lan-print
./tools/ipmitool pef list > $OUTPUT/ipmi/pef-list
./tools/ipmitool sdr elist all > $OUTPUT/ipmi/sdr-elist-all
./tools/ipmitool sel info > $OUTPUT/ipmi/sel-info
./tools/ipmitool sel elist > $OUTPUT/ipmi/sel-elist

# =====================
# net
# =====================
task_info "Catch net info"
mkdir -p $OUTPUT/net
./tools/ibstatus > $OUTPUT/net/"ibstatus"
./tools/ibstat > $OUTPUT/net/"ibstat"
./tools/ibdiagnet -r > $OUTPUT/net/ibstatdiag
./tools/ibnetdiscover > $OUTPUT/net/ibnetdiscover 2>> $OUTPUT/net/ibnetdiscover.err
./tools/ibcheckerrors > $OUTPUT/net/ibcheckerrors
./tools/ibqueryerrors >> $OUTPUT/net/ibcheckerrors
./tools/ibswitches > $OUTPUT/net/ibswitches
cat /proc/net/bonding/bond* > $OUTPUT/net/bond.out
cat /etc/modprobe.d/bonding.conf  > $OUTPUT/net/bonding.conf
ifconfig -a > $OUTPUT/net/ifconfig-a

# iblinkinfo
task_info "Catch iblink info"
./tools/iblinkinfo -l > $OUTPUT/net/iblinkinfo

# ethtool
task_info "Catch ethtool info"
mkdir -p $OUTPUT/net/ethtool
for ETH in `ifconfig -a | grep  ": "| awk '{print $1}'| awk -F':' '{print $1}' `; do
   ./tools/ethtool $ETH > $OUTPUT/net/ethtool/ethtool_$ETH 2>> $OUTPUT/net/ethtool/ethtool_$ETH.err
   if [ ! -s $OUTPUT/net/ethtool/ethtool_$ETH.err ]; then
       rm -f $OUTPUT/net/ethtool/ethtool_$ETH.err
   fi
   ethtool_options="-a -c -g -i -k -S"
   for ETHOPT in $ethtool_options ; do
      ./tools/ethtool $ETHOPT $ETH > $OUTPUT/net/ethtool/ethtool$ETHOPT_$ETH 2>> $OUTPUT/net/ethtool/ethtool$ETHOPT_$ETH.err
      if [ ! -s $OUTPUT/net/ethtool/ethtool$ETHOPT_$ETH.err ]; then
         rm -f $OUTPUT/net/ethtool/ethtool$ETHOPT_$ETH.err
      fi
   done
done

## net conf
task_info "cp net conf"
mkdir -p $OUTPUT/net/conf
cp /etc/sysconfig/network > $OUTPUT/net/conf/network
cp /etc/sysconfig/network-scripts/ifcfg* > $OUTPUT/net/conf

# =====================
# raid
# =====================
task_info "Catch RAID info"
mkdir -p $OUTPUT/raid
lsscsi |grep -v BIO > $OUTPUT/raid/lsscsi-nobio
fdisk -l > $OUTPUT/raid/fdisk-l
{ for PART in  /dev/sd* ; do  parted -s $PART print ; done ; } > $OUTPUT/raid/parted 2>>$OUTPUT/raid/parted.err
cp /proc/mounts $OUTPUT/raid/mounts

# disk data gathered from LSI MegaRAID
task_info "Catch MegaRAID info"
./tools/MegaCli64 -AdpAllInfo -aALL -nolog > $OUTPUT/raid/megacli64-AdpAllInfo
./tools/MegaCli64 -AdpEventLog -GetEvents -f > $OUTPUT/raid/megacli64-GetEvents-all -aALL -nolog > /dev/null 2>&1
./tools/MegaCli64 -fwtermlog -dsply -aALL -nolog > $OUTPUT/raid/megacli64-FwTermLog
./tools/MegaCli64 -cfgdsply -aALL -nolog > $OUTPUT/raid/megacli64-CfgDsply
./tools/MegaCli64 -adpbbucmd -aALL -nolog > $OUTPUT/raid/megacli64-BbuCmd
./tools/MegaCli64 -LdPdInfo -aALL  -nolog > $OUTPUT/raid/megacli64-LdPdInfo
./tools/MegaCli64 -PDList -aALL -nolog > $OUTPUT/raid/megacli64-PdList_long
./tools/MegaCli64 -LDInfo -LALL -aALL -nolog > $OUTPUT/raid/megacli64-LdInfo
./tools/MegaCli64 -PhyErrorCounters -aALL -nolog > $OUTPUT/raid/megacli64-PhyErrorCounters
megacli_status > $OUTPUT/raid/megacli64-status
./tools/MegaCli64 -PDList -aALL -nolog | awk '/Slot Number/ { counter += 1; slot[counter] = $3 } /Device Id/ { device[counter] = $3 } /Firmware state/ { state_drive[counter] = $3 } /Inquiry/     { name_drive[counter] = $3 " " $4 " " $5 " " $6 } END { for (i=1; i<=counter; i+=1) printf ( "Slot %02d Device %02d (%s) status is: %s \n", slot[i], device[i], name_drive[i], state_drive[    i]); }' > $OUTPUT/raid/megacli64-PdList_short
