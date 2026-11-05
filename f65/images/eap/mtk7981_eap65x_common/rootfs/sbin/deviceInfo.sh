#! /bin/sh

mkdir /tmp/device_info
rm -f /tmp/deviceInfo.tgz
touch  /tmp/logdump/eap_inform.json
cp -r /tmp/log/* /tmp/device_info
#cp -r /tp_data/manu_data/default-mac /tmp/device_info
#cp -r /sys/kernel/debug/* /tmp/device_info
mv /tmp/ps_status.log /tmp/device_info
touch  /tmp/device_info/Config-Info.log
nvrammanager -r /tmp/device_info/Config-Info.log -p config-info
cd /tmp/device_info/rec
sed -i "/pwd\|password\|usr\|groupID\|tplinkID\|deviceName\|Pwd\|getCom\|setCom\|Username\|Password\|username\|password\|userName\|pskKey\|community\|pmk\|passcode\|wpaKey/d" ecs.rec
cd /tmp/device_info
sed -i "/pwd\|password\|usr\|groupID\|tplinkID\|deviceName\|Pwd\|getCom\|setCom\|Username\|Password\|username\|password\|userName/d" Config-Info.log

#########################################内存信息统计################################################
touch  Memory_Information.log
echo "/**************************************************************************************************/
/*                                           DATE                                                       */
/**************************************************************************************************/" >> Memory_Information.log
echo " " >> Memory_Information.log
date >> Memory_Information.log
echo " " >> Memory_Information.log
#echo "/**************************************************************************************************/
#/*                                         device-id                                                    */
#/**************************************************************************************************/" >> Memory_Information.log
#echo " " >> Memory_Information.log
#cat /tp_data/manu_data/device-id >> Memory_Information.log
#echo " " >> Memory_Information.log
echo "/**************************************************************************************************/
/*                                           free                                                       */
/**************************************************************************************************/" >> Memory_Information.log
echo " " >> Memory_Information.log
free >> Memory_Information.log
echo " " >> Memory_Information.log
echo "/**************************************************************************************************/
/*                                      /proc/meminfo                                                   */
/**************************************************************************************************/" >> Memory_Information.log
echo " " >> Memory_Information.log
cat /proc/meminfo >> Memory_Information.log
echo " " >> Memory_Information.log
echo "/**************************************************************************************************/
/*                                      /proc/zoneinfo                                                  */
/**************************************************************************************************/" >> Memory_Information.log
echo " " >> Memory_Information.log
cat /proc/zoneinfo >> Memory_Information.log
echo " " >> Memory_Information.log
echo "/**************************************************************************************************/
/*                                      /proc/vmstat                                                    */
/**************************************************************************************************/" >> Memory_Information.log
echo " " >> Memory_Information.log
cat /proc/vmstat >> Memory_Information.log
echo " " >> Memory_Information.log
echo "/**************************************************************************************************/
/*                                      /proc/buddyinfo                                                 */
/**************************************************************************************************/" >> Memory_Information.log
echo " " >> Memory_Information.log
cat /proc/buddyinfo >> Memory_Information.log
echo " " >> Memory_Information.log
echo "/**************************************************************************************************/
/*                                      /proc/iomem                                                     */
/**************************************************************************************************/" >> Memory_Information.log
echo " " >> Memory_Information.log
cat /proc/iomem >> Memory_Information.log
echo " " >> Memory_Information.log

#########################################CPU信息统计################################################
touch  CPU.log
echo "/**************************************************************************************************/
/*                                             DATE                                                     */
/**************************************************************************************************/" >> CPU.log
echo " " >> CPU.log
date >> CPU.log
echo " " >> CPU.log
echo "/**************************************************************************************************/
/*                                        /proc/interrupts                                              */
/**************************************************************************************************/" >> CPU.log
echo " " >> CPU.log
cat /proc/interrupts >> CPU.log
echo " " >> CPU.log
echo "/**************************************************************************************************/
/*                                       /proc/softirqs                                                 */
/**************************************************************************************************/" >> CPU.log
echo " " >> CPU.log
cat /proc/softirqs >> CPU.log
echo " " >> CPU.log
#echo "/**************************************************************************************************/
#/*                                       CPU CHIP TEMP                                                  */
#/**************************************************************************************************/" >> CPU.log
#echo " " >> CPU.log
#echo "/sys/class/thermal/thermal_zone4/temp:" >> CPU.log
#cat /sys/class/thermal/thermal_zone4/temp >> CPU.log
#echo " " >> CPU.log

########################################系统信息统计(包含网络信息)#########################################
touch  System_Information.log
echo "/**************************************************************************************************/
/*                                             DATE                                                     */
/**************************************************************************************************/" >> System_Information.log
echo " " >> System_Information.log
date >> System_Information.log
echo " " >> System_Information.log
echo "/**************************************************************************************************/
/*                                            uptime                                                    */
/**************************************************************************************************/" >> System_Information.log
echo " " >> System_Information.log
uptime >> System_Information.log
echo " " >> System_Information.log
echo "/**************************************************************************************************/
/*                                         /proc/net/dev                                                */
/**************************************************************************************************/" >> System_Information.log
echo " " >> System_Information.log
cat /proc/net/dev >> System_Information.log
echo " " >> System_Information.log
echo "/**************************************************************************************************/
/*                                         /proc/net/tcp                                                */
/**************************************************************************************************/" >> System_Information.log
echo " " >> System_Information.log
cat /proc/net/tcp >> System_Information.log
echo " " >> System_Information.log
echo "/**************************************************************************************************/
/*                                         /proc/net/udp                                                */
/**************************************************************************************************/" >> System_Information.log
echo " " >> System_Information.log
cat /proc/net/udp  >> System_Information.log
echo " " >> System_Information.log
echo "/**************************************************************************************************/
/*                                         /proc/net/unix                                                */
/**************************************************************************************************/" >> System_Information.log
echo " " >> System_Information.log
cat /proc/net/unix >> System_Information.log
echo " " >> System_Information.log
echo "/**************************************************************************************************/
/*                                         /proc/net/netlink                                             */
/**************************************************************************************************/" >> System_Information.log
echo " " >> System_Information.log
cat /proc/net/netlink  >> System_Information.log
echo " " >> System_Information.log
echo "/**************************************************************************************************/
/*                                          iptables-save                                               */
/**************************************************************************************************/" >> System_Information.log
echo " " >> System_Information.log
iptables-save >> System_Information.log
echo " " >> System_Information.log
echo "/**************************************************************************************************/
/*                                            netstat                                                   */
/**************************************************************************************************/" >> System_Information.log
echo " " >> System_Information.log
netstat -na >> System_Information.log
echo " " >> System_Information.log
#echo "/**************************************************************************************************/
#/*                                           WIFI Info                                                  */
#/**************************************************************************************************/" >> System_Information.log
#echo " " >> System_Information.log
#thermaltool -i wifi0 -get >> System_Information.log
#thermaltool -i wifi1 -get >> System_Information.log
#thermaltool -i wifi2 -get >> System_Information.log
#thermaltool -i wifi3 -get >> System_Information.log
#echo " " >> System_Information.log
echo "/**************************************************************************************************/
/*                                           iwconfig                                                  */
/**************************************************************************************************/" >> System_Information.log
echo " " >> System_Information.log
iwconfig >> System_Information.log
echo " " >> System_Information.log
echo "/**************************************************************************************************/
/*                                           ifconfig                                                  */
/**************************************************************************************************/" >> System_Information.log
echo " " >> System_Information.log
ifconfig >> System_Information.log
echo " " >> System_Information.log

##############################################进程信息统计#############################################
touch  Process_Information.log
echo "/**************************************************************************************************/
/*                                             DATE                                                     */
/**************************************************************************************************/" >> Process_Information.log
echo " " >> Process_Information.log
date >> Process_Information.log
echo " " >> Process_Information.log
echo "/**************************************************************************************************/
/*                                          /proc/stat                                                  */
/**************************************************************************************************/" >> Process_Information.log
echo " " >> Process_Information.log
cat /proc/stat >> Process_Information.log
echo " " >> Process_Information.log
echo "/**************************************************************************************************/
/*                                             top                                                      */
/**************************************************************************************************/" >> Process_Information.log
echo " " >> Process_Information.log
top -b -n1 >> Process_Information.log
echo " " >> Process_Information.log
echo "/**************************************************************************************************/
/*                                             ps                                                       */
/**************************************************************************************************/" >> Process_Information.log
echo " " >> Process_Information.log
ps >> Process_Information.log
echo " " >> Process_Information.log
echo "/**************************************************************************************************/
/*                                         /proc/mounts                                                 */
/**************************************************************************************************/" >> Process_Information.log
echo " " >> Process_Information.log
cat /proc/mounts >> Process_Information.log
echo " " >> Process_Information.log
echo "/**************************************************************************************************/
/*                                         /proc/modules                                                */
/**************************************************************************************************/" >> Process_Information.log
echo " " >> Process_Information.log
cat /proc/modules >> Process_Information.log
echo " " >> Process_Information.log

############################################/tmp下关键log##############################################
touch  tmp.log
echo "/**************************************************************************************************/
/*                                             DATE                                                     */
/**************************************************************************************************/" >> tmp.log
echo " " >> tmp.log
date >> tmp.log
echo " " >> tmp.log
echo "/**************************************************************************************************/
/*                                     /tmp/firmware-version                                            */
/**************************************************************************************************/" >> tmp.log
echo " " >> tmp.log
cat /tmp/firmware-version >> tmp.log
echo " " >> tmp.log
#echo "/**************************************************************************************************/
#/*                                       /tmp/eapmesh.log                                               */
#/**************************************************************************************************/" >> tmp.log
#echo " " >> tmp.log
#cat /tmp/eapmesh.log >> tmp.log
#echo " " >> tmp.log
echo "/**************************************************************************************************/
/*                                        /tmp/nrd.conf                                                 */
/**************************************************************************************************/" >> tmp.log
echo " " >> tmp.log
cat /tmp/nrd.conf >> tmp.log
echo " " >> tmp.log
#echo "/**************************************************************************************************/
#/*                                       /tmp/ECS_STATE                                                 */
#/**************************************************************************************************/" >> tmp.log
#echo " " >> tmp.log
#cat /tmp/ECS_STATE >> tmp.log
#echo " " >> tmp.log
echo "/**************************************************************************************************/
/*                                /tmp/logdump/eap_inform.json                                          */
/**************************************************************************************************/" >> tmp.log
echo " " >> tmp.log
cat /tmp/logdump/eap_inform.json >> tmp.log
rm -f /tmp/logdump/eap_inform.json
echo " " >> tmp.log
echo "/**************************************************************************************************/
/*                                      /tmp/cloudStatus                                                */
/**************************************************************************************************/" >> tmp.log
echo " " >> tmp.log
cat /tmp/cloudStatus >> tmp.log
echo " " >> tmp.log
echo "/**************************************************************************************************/
/*                                     /tmp/cloudConnType                                               */
/**************************************************************************************************/" >> tmp.log
echo " " >> tmp.log
cat /tmp/cloudConnType >> tmp.log
echo " " >> tmp.log
#echo "/**************************************************************************************************/
#/*                             /tmp/smart_antenna_mode_change_flag.txt                                  */
#/**************************************************************************************************/" >> tmp.log
#echo " " >> tmp.log
#cat /tmp/smart_antenna_mode_change_flag.txt >> tmp.log
#echo " " >> tmp.log

############################################kernel信息统计##############################################
touch  kernel.log
echo "/**************************************************************************************************/
/*                                             DATE                                                     */
/**************************************************************************************************/" >> kernel.log
echo " " >> kernel.log
date >> kernel.log
echo " " >> kernel.log
echo "/**************************************************************************************************/
/*                                            dmesg                                                     */
/**************************************************************************************************/" >> kernel.log
echo " " >> kernel.log
dmesg -c >> kernel.log
echo " " >> kernel.log

############################################wirless driver##############################################
iface_list="ra0 ra1 ra2 ra3 ra4 ra5 ra6 ra7 rax0 rax1 rax2 rax3 rax4 rax5 rax6 rax7"
num=0
touch driver_wireless_common.log
echo "/**************************************************************************************************/
/*                                           driverinfo                                                  */
/**************************************************************************************************/" >> driver_wireless_common.log
echo -e "\n show driverinfo\n" >> driver_wireless_common.log
iwpriv ra0 show driverinfo
sleep 0.5
dmesg -c >> driver_wireless_common.log
echo " " >> driver_wireless_common.log

echo "/**************************************************************************************************/
/*                                           times                                                  */
/**************************************************************************************************/" >> driver_wireless_common.log
echo " " >> driver_wireless_common.log
times >> driver_wireless_common.log
echo " " >> driver_wireless_common.log

echo "/**************************************************************************************************/
/*                                           stat                                                  */
/**************************************************************************************************/" >> driver_wireless_common.log
for iface in $iface_list
do
echo -e "\n $iface stat\n" >> driver_wireless_common.log
iwpriv $iface stat >> driver_wireless_common.log
echo " " >> driver_wireless_common.log
done

echo "/**************************************************************************************************/
/*                                           stainfo                                                  */
/**************************************************************************************************/" >> driver_wireless_common.log
for iface in $iface_list
do
echo -e "\n $iface show stainfo\n" >> driver_wireless_common.log
iwpriv $iface show stainfo
sleep 0.5
dmesg -c >> driver_wireless_common.log
echo " " >> driver_wireless_common.log
done

echo "/**************************************************************************************************/
/*                                           trinfo                                                  */
/**************************************************************************************************/" >> driver_wireless_common.log
echo -e "\n show trinfo\n" >> driver_wireless_common.log
sleep 0.5
iwpriv ra0 show trinfo
dmesg -c >> driver_wireless_common.log
echo " " >> driver_wireless_common.log

echo "/**************************************************************************************************/
/*                                           pseinfo                                                  */
/**************************************************************************************************/" >> driver_wireless_common.log
echo -e "\n show pseinfo\n" >> driver_wireless_common.log
sleep 0.5
iwpriv ra0 show pseinfo
dmesg -c >> driver_wireless_common.log
echo " " >> driver_wireless_common.log

echo "/**************************************************************************************************/
/*                                           wtblinfo                                                  */
/**************************************************************************************************/" >> driver_wireless_common.log
echo -e "\n show wtbl=1\n" >> driver_wireless_common.log
sleep 0.5
iwpriv ra0 show wtbl=1
dmesg -c >> driver_wireless_common.log
echo " " >> driver_wireless_common.log

echo "/**************************************************************************************************/
/*                                           dschinfo                                                  */
/**************************************************************************************************/" >> driver_wireless_common.log
echo -e "\n show dschinfo\n" >> driver_wireless_common.log
sleep 0.5
iwpriv ra0 show dschinfo
dmesg -c >> driver_wireless_common.log
echo " " >> driver_wireless_common.log

echo "/**************************************************************************************************/
/*                                           pleinfo                                                  */
/**************************************************************************************************/" >> driver_wireless_common.log
echo -e "\n show pleinfo=1\n" >> driver_wireless_common.log
sleep 0.5
iwpriv ra0 show pleinfo=1
dmesg -c >> driver_wireless_common.log
echo " " >> driver_wireless_common.log

echo "/**************************************************************************************************/
/*                                           tpinfo                                                  */
/**************************************************************************************************/" >> driver_wireless_common.log
echo -e "\n show tpinfo\n" >> driver_wireless_common.log
sleep 0.5
iwpriv ra0 show tpinfo
dmesg -c >> driver_wireless_common.log
echo " " >> driver_wireless_common.log

echo "/**************************************************************************************************/
/*                                           mibinfo                                                  */
/**************************************************************************************************/" >> driver_wireless_common.log
echo -e "\n show mibinfo\n" >> driver_wireless_common.log
sleep 0.5
iwpriv ra0 show mibinfo
dmesg -c >> driver_wireless_common.log
echo " " >> driver_wireless_common.log

echo "/**************************************************************************************************/
/*                                           MibBucketinfo                                                  */
/**************************************************************************************************/" >> driver_wireless_common.log
echo -e "\n show MibBucket\n" >> driver_wireless_common.log
sleep 0.5
iwpriv ra0 show MibBucket
dmesg -c >> driver_wireless_common.log
echo " " >> driver_wireless_common.log

echo "/**************************************************************************************************/
/*                                           serinfo                                                  */
/**************************************************************************************************/" >> driver_wireless_common.log
echo -e "\n show ser\n" >> driver_wireless_common.log
iwpriv ra0 show ser
sleep 0.5
dmesg -c >> driver_wireless_common.log
echo " " >> driver_wireless_common.log

cd /tmp
tar -zcvf deviceInfo.tgz device_info
rm -rf /tmp/device_info
