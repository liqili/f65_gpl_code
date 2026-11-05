#!/bin/sh
#set -x on
#for 7986/7981 Debug
	echo -e "\niwconfig\n"
	sleep 1
	iwconfig
	echo -e "\nifconfig\n"
	sleep 1
	ifconfig
	
	echo -e "\nshow wifi_sys\n"
	sleep 1
	iwpriv ra0 show wifi_sys
	
	echo -e "\nshow devinfo\n"
	sleep 1
	iwpriv ra0 show devinfo
	
	echo -e "\nshow driverinfo\n"
	sleep 1
	iwpriv ra0 show driverinfo
	
	echo -e "\nshow radio_info\n"
	sleep 1
	iwpriv ra0 show radio_info
	
	echo -e "\nshow apcfginfo\n"
	sleep 1
	
	iface_list="ra0 rax0 ra2 rax2 apcli0 apclix0"
	
    for iface in $iface_list
    do
		echo "$iface show apcfginfo"
		sleep 1
		iwpriv $iface show apcfginfo
    done

	echo -e "\nshow mbss=1\n"
	sleep 1
	iwpriv ra0 show mbss=1

	echo -e "\nshow secinfo\n"
	sleep 1
	iwpriv ra0 show secinfo
	
	echo -e "\nwarp0/wo\n"
	sleep 1
	cat /proc/warp_ctrl/warp0/wo
	
	echo -e "\nwarp0/cfg\n"
	sleep 1
	cat /proc/warp_ctrl/warp0/cfg
	
	echo -e "\ncwarp0/stat\n"
	sleep 1
	cat /proc/warp_ctrl/warp0/stat

	echo -e "\nser\n"
	iwpriv ra0 show ser
	sleep 1
	echo -e "\nserinfo\n"
	iwpriv ra0 show serinfo
	sleep 1

	echo -e "\n11f20274\n"
	regs d 11f20274	

	echo -e "\n11d008c8\n"
	regs d 11d008c8
	
	echo -e "\nmac 88000000\n"
	iwpriv ra0 mac 88000000

	echo -e "\nmac 83081000\n"
	iwpriv ra0 mac 83081000

	echo -e "\nmac 83181000\n"
	iwpriv ra0 mac 83181000

	echo -e "\nmac 820E0004\n"
	iwpriv ra0 mac 820E0004

	echo -e "\nmac 820F0004\n"
	iwpriv ra0 mac 820F0004
	
	echo -e "\nefuseinfo\n"
	iwpriv ra0 show efuseinfo
	
	
	sleep 2
	num=0
	while [ $num -le 5 ]
	do
		echo -e "\ntrinfo\n"
		iwpriv ra0 show trinfo
		sleep 1
		
		echo -e "\nwarp0/tx\n"
		cat /proc/warp_ctrl/warp0/tx
		
		echo -e "\nwarp0/rx\n"
		cat /proc/warp_ctrl/warp0/rx
		
		echo -e "\n0x15194200\n"
		regs d 0x15194200

		echo -e "\n0x151a5000\n"
		regs d 0x151a5000
		
		echo -e "\nwarp0/wed\n"
		echo 8 > /proc/warp_ctrl/warp0/wed
		sleep 1
		
		echo -e "\n/proc/interrupts\n"
		cat /proc/interrupts
		
		echo -e "\npseinfo\n"
		iwpriv ra0 show pseinfo

		echo -e "\npleinfo\n"
		iwpriv ra0 show pleinfo
		echo -e "\npleinfo=1\n"
		iwpriv ra0 show pleinfo=1

		num=`expr $num + 1`
	done
	
	sleep 2
	num=0
	while [ $num -le 5 ]
	do
		echo -e "\nra0 stat\n"
		iwpriv ra0 stat
		
		echo -e "\nrax0 stat\n"
		iwpriv rax0 stat
		sleep 1
		
		echo -e "\nra0 stainfo\n"
		iwpriv ra0 show stainfo
		echo -e "\nra0 stainfo=ap\n"
		iwpriv ra0 show stainfo=ap

		echo -e "\nrax0 stainfo\n"
		iwpriv rax0 show stainfo
		echo -e "\nrax0 stainfo=ap\n"
		iwpriv rax0 show stainfo=ap

		echo -e "\napcli0 stainfo=ap\n"
		iwpriv apcli0 show stainfo
		echo -e "\nrax0 stainfo=ap\n"
		iwpriv apclix0 show stainfo=ap
		
		sleep 1
		
		echo -e "\nwtbl_stat\n"
		iwpriv ra0 show wtbl_stat
		
		wcid_list="0 1 2 3 4 5 6 256 257"
		
		for wcid in $wcid_list
		do
			iwpriv ra0 show wtbl=$wcid
		done
		
		echo -e "\ntpinfo=0-2\n"
		iwpriv ra0 show tpinfo=0-2

		echo -e "\ntpinfo=0-4\n"
		iwpriv ra0 show tpinfo=0-4
		
		echo -e "\nra0 tpinfo=1-2\n"
		iwpriv ra0 show tpinfo=1-2
		echo -e "\nrax0 tpinfo=1-2\n"
		iwpriv rax0 show tpinfo=1-2
		
		echo -e "\ntpinfo=1-3\n"
		iwpriv ra0 show tpinfo=1-3
		
		echo -e "\ntpinfo=1-4\n"
		iwpriv ra0 show tpinfo=1-4

		echo -e "\ntpinfo=1-5\n"
		iwpriv ra0 show tpinfo=1-5

		echo -e "\ntpinfo=1-6\n"
		iwpriv ra0 show tpinfo=1-6
		
		echo -e "\ntpinfo=1-7\n"
		iwpriv ra0 show tpinfo=1-7

		echo -e "\nswqinfo\n"
		iwpriv ra0 show swqinfo

		echo -e "\nbainfo\n"
		iwpriv ra0 show bainfo

		num=`expr $num + 1`
	done
	
	sleep 2
	num=0
	while [ $num -le 3 ]
	do
		echo -e "\nbcninfo\n"
		iwpriv ra0 show bcninfo
		echo -e "\nfw_dbg_info\n"
		iwpriv ra0 show fw_dbg_info

		echo -e "\nmibinfo\n"
		iwpriv ra0 show mibinfo
		sleep 1
		echo -e "\nmibinfo\n"
		iwpriv rax0 show mibinfo
		
		echo -e "\nMibBucket\n"
		iwpriv ra0 show MibBucket
		sleep 1
		echo -e "\nMibBucket\n"
		iwpriv rax0 show MibBucket
		num=`expr $num + 1`
	done
	
	sleep 2
	num=0
	while [ $num -le 20 ]
	do
		sleep 1
		echo -e "\n 401980\n"
		iwpriv ra0 mac 401980
		echo -e "\n 890d0100-890d0300\n"
		sleep 1
		iwpriv ra0 mac 890d0100-890d0300
		
		echo -e "\n 820E3150\n"
		iwpriv ra0 mac 820E3150
		echo -e "\n 820F3150\n"
		iwpriv ra0 mac 820F3150
	
		echo -e "\n 820E31F8\n"
		iwpriv ra0 mac 820E31F8
		
		echo -e "\n 820F31F8\n"
		iwpriv ra0 mac 820F31F8

		echo -e "\n 820E22EC\n"
		iwpriv ra0 mac 820E22EC-820E22FC
		
		echo -e "\n 820F22EC\n"
		iwpriv ra0 mac 820F22EC-820F22FC
		
		num=`expr $num + 1`
	done

	sleep 2
	num=0
	while [ $num -le 6 ]
	do
		sleep 1
		echo -e "\n 820E3000\n"
		iwpriv ra0 mac 820E3000 
		echo -e "\n 820F3000\n"
		iwpriv ra0 mac 820F3000

		echo -e "\n 820E3160\n"
		iwpriv ra0 mac 820E3160 
		echo -e "\n 820F3160\n"
		iwpriv ra0 mac 820F3160
		echo -e "\n 820E3164\n"
		iwpriv ra0 mac 820E3164 
		echo -e "\n 820F3164\n"
		iwpriv ra0 mac 820F3164
		
		
		echo -e "\n 820e3260-820e3278\n"
		sleep 1
		iwpriv ra0 mac 820e3260-820e3278
		
		echo -e "\n 820f3260-820f3278\n"
		sleep 1
		iwpriv ra0 mac 820f3260-820f3278

		echo -e "\n 820e3170-820e317C\n"
		sleep 1
		iwpriv ra0 mac 820e3170-820e317C
		echo -e "\n 820f3170-820f317C\n"
		sleep 1
		iwpriv ra0 mac 820f3170-820f317C
		
		echo -e "\n 820c0100-820c0140\n"
		sleep 1
		iwpriv ra0 mac 820c0100-820c0140	
		num=`expr $num + 1`
	done

	echo  -e "\nmac 820E4368、820F4368\n"
	sleep 1
	num=0
	while [ $num -le 30 ]
	do
		iwpriv ra0 mac 820E4368
		iwpriv ra0 mac 820F4368
		
		num=`expr $num + 1`
	done	
	
	echo  -e "\nmac 820E4378-820E43A4"
	echo  -e "\nmac 820F4378-820F43A4\n"
	sleep 1
	num=0
	while [ $num -le 20 ]
	do
		iwpriv ra0 mac 820E4378-820E43A4
		sleep 1
		iwpriv ra0 mac 820F4378-820F43A4
		sleep 1
		num=`expr $num + 1`
	done
	
	echo  -e "\nmac 820E22E8"
	echo  -e "\nmac 820E22F0-820E22FC\n"
	sleep 1
	num=0
	while [ $num -le 30 ]
	do	
		iwpriv ra0 mac 820E22E8 #读出来的应该是03020100，不是的话，iwpriv ra0 mac 820E22E8=03020100
		iwpriv ra0 mac 820E22F0
		iwpriv ra0 mac 820E22F4
		iwpriv ra0 mac 820E22F8
		iwpriv ra0 mac 820E22FC
		
		num=`expr $num + 1`
	done
	
	echo  -e "\nmac 820F22E8"
	echo  -e "\nmac 8820F22F0-820F22FC\n"
	sleep 1
	num=0
	while [ $num -le 30 ]
	do
		iwpriv ra0 mac 820F22E8 #读出来的应该是03020100，同上
		iwpriv ra0 mac 820F22F0
		iwpriv ra0 mac 820F22F4
		iwpriv ra0 mac 820F22F8
		iwpriv ra0 mac 820F22FC
		
		num=`expr $num + 1`
	done
	
	sleep 1
	num=0
	while [ $num -le 3 ]
	do
		echo -e "\n 820EB0A8\n"
		iwpriv ra0 mac 820EB0A8
		echo -e "\n 820FB0A8\n"
		iwpriv ra0 mac 820FB0A8
		
		echo -e "\n 820EB0B8\n"
		iwpriv ra0 mac 820EB0B8
		echo -e "\n 820FB0B8\n"
		iwpriv ra0 mac 820FB0B8

		echo -e "\n 820EB330\n"
		iwpriv ra0 mac 820EB330
		echo -e "\n 820FB330\n"
		iwpriv ra0 mac 820FB330
		
		echo -e "\n 820EB368\n"		
		iwpriv ra0 mac 820EB368
		echo -e "\n 820FB368\n"	
		iwpriv ra0 mac 820FB368
		sleep 1
		
		num=`expr $num + 1`
	done
  

