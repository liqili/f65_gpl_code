#!/bin/sh

########################################
# define parameters
########################################
CONFDIR=/tmp/hotspot
conf_list=
########################################
# sanity check
########################################

########################################
# common api
########################################

getValue()
{
	export IFS=";"
	idx=0
	word=
	for word in $1; do
		if [ $2 -eq $idx ]; then
			break
		else
			word=
		fi
		idx=`expr $idx + 1`
	done
	export IFS=" "

}

createNAI()
{
	echo "nai_realm_data={
	nai_realm=$1" >> $3
	temp=`echo $2 | sed 's/eap-tls//'`
	if [ "$temp" != "" ]; then
		echo "        eap_method=eap-ttls
	auth_param=2:4
        auth_param=5:7" >> $3
	fi
	temp=`echo $2 | sed 's/eap-ttls//'`
	if [ "$temp" != "" ]; then
		echo "        eap_method=eap-tls
        auth_param=5:6" >> $3
	fi

	echo "}" >> $3
}

# advice of charge
# $1: 2860/rtdev , $2: naiX,1,2,3,4 ,$3: config name
insertAOC()
{
	ALLVALUE=`nvram_get $1 HS_aoc_$2_type`
	getValue "$ALLVALUE" $num
	aoc_type="$word"
	if [ "$aoc_type" == "" ]; then
		return
	fi

	echo "advice_of_charge_data={
	advice_of_charge_type=$aoc_type" >> $3

	ALLVALUE=`nvram_get $1 HS_aoc_$2_realm_encoding`
	getValue "$ALLVALUE" $num
	aoc_encoding="$word"
	echo "        aoc_realm_encoding=$aoc_encoding" >> $3

	ALLVALUE=`nvram_get $1 HS_aoc_$2_realm`
	getValue "$ALLVALUE" $num
	aoc_realm="$word"
	echo "        aoc_realm=$aoc_realm" >> $3

	i=1
	while [ $i -lt 5 ]
	do
		#nvram_get 2860 HS_aoc_1_1_language/currency/plan
		#nvram_get 2860 HS_aoc_1_2_language/currency/plan
		#nvram_get 2860 HS_aoc_1_3_language/currency/plan
		#nvram_get 2860 HS_aoc_1_4_language/currency/plan

		ALLVALUE=`nvram_get $1 HS_aoc_$2_${i}_language`
		getValue "$ALLVALUE" $num
		aoc_lang="$word"
		if [ "$aoc_lang" == "" ]; then
			i=`expr $i + 1`
			continue
		fi

		echo "        aoc_language=$aoc_lang" >> $3

		ALLVALUE=`nvram_get $1 HS_aoc_$2_${i}_currency`
		getValue "$ALLVALUE" $num
		aoc_currency="$word"
		echo "        aoc_currency_code=$aoc_currency" >> $3

		ALLVALUE=`nvram_get $1 HS_aoc_$2_${i}_plan`
		getValue "$ALLVALUE" $num
		aoc_plan="$word"
		echo "        aoc_plan_info=$aoc_plan" >> $3

		i=`expr $i + 1`
	done

	echo "}" >> $3
}

# Venue URL
# $1: 2860/rtdev , $2: config name
insertVenueUrl()
{
	# Venue URL
	echo "#VenueUrl" >> $2
	i=1
	while [ $i -lt 21 ]
	do
		ALLVALUE=`nvram_get $1 HS_venue_url_${i}`
		getValue "$ALLVALUE" $num
		vurl="$word"
		if [ "$vurl" == "" ]; then
			i=`expr $i + 1`
			continue
		fi
		echo "venue_url=$vurl" >> $2

		i=`expr $i + 1`
	done
}
create3GPP()
{
	echo "plmn={
	mcc=$1
	mnc=$2
}" >> $3
}

########################################
# api for generating config
########################################

#$1: 2860/rtdev $2: ra0
genConfig()
{
	# interface=ra0
	interface=$1

	echo "##hospot2.0 ap configuration file##

# Interface
# network interface name
interface=$interface

# Interworking
# 0: Disable
# 1: Enable
interworking=1

# Terms and Conditions FileName
# t_c_filename

# Terms and Conditions Server URL
# t_c_server_url

# Terms and Conditions TimeStamp
# t_c_timestamp

# Access Network Type
# 0: Private network
# 1: Private network with guest access
# 2: Chargeable public network
# 3: Free public network
# 4: Personal Device Network
# 5: Emergency Services Only Network
# 6-13: Reserved
#14: Test or experimental
#15: Wildcard
access_network_type=0

# Internet
# 0: Do not have connectivity to the Internet
# 1: The network provides connectivity to the Internet
internet=0

# Venue Group
# 0: Unspecified
# 1: Assembly
# 2: Business
# 3: Eductional
# 4: Factory and Industrial
# 5: Institutional
# 6: Mercantile
# 7: Residentail
# 8: Storage
# 9: Utility and Miscellaneous
#10: Vehicular
#11: Outdoor
#12-255 : Reserved
venue_group=n/a

# Venue Type
# Unspecified
#	0: Unspecified
#	1-255: Reserved
# 
# Assembly
#	0: Unspecified ssembly
#	1: Arena
#	2: Stadium
#	3: Passenger Terminal (e.g airport, bus, ferry, train station)
#	4: Amphitheater
#	5: Amusement Part
#	6: Place of Worship
#	7: Convention Center
#	8: Library
#	9: Museum
#  10: Restaurant
#  11: Theater
#  12: Bar
#  13: Coffee Shop
#  14: Zoo or Aquarium
#  15: Emergency COordination Center
#  16-255: Reserved
# Business
#	0: Unspecified Business
#	1: Doctor or Dentist office
#	2: Bank
#	3: Fire Station
#	4: Police Station
#	5: Reserved
#	6: Post Office
#	7: Professtional Office
#	8: Research and Development Facility
#	9: Attorney Office
#	10-255: Reserved
# Eductional
#	0: Unspecified Educational
#	1: School, Primary
#	2: School, Secondary
#	3: University or College
#	4-255: Reserved
# Factory and Industrial	
#	0: Unspecified Factory and INdustrial
#	1: Factory
#	2-255: Reserved
# Institutional
#	0: Unspecified Institutional
#	1: Hospital
#	2: Long-Term Care Facility
#	3: Alcohol and Drug Re-habilitation Center
#	4: Group Home
#	5: Prison or Jail
#	6-255: Reserved
# Mercantile
#	0: Unspecified Mercantile
#	1: Retail Store
#	2: Grocery Market
#	3: Automotive Serive Station
#	4: Shopping Mall
#	5: Gas Station
#	6-255: Reserved
# Residentail
#	0: Unspecified Residentail
#	1: Private Residence
#	2: Hotel or Motel
#	3: Dormitory
#	4: Boarding House
#	5-255: Reserved
# Storage
#	0: Unspecified Storage
#	1-255: Reserved
# Utility and Miscellaneous
#	0: Unspecified Utility and Miscellaneous
#	1-255: Reserved
# Vehicular
#	0: Unspecified Vehicular
#	1: Automobile or Truck
#	2: Airplane
#	3: Bus
#	4: Ferry
#	5: Ship or Boat
#	6: Train
#	7: Motor Bike
#	8-255: Reserved
# Outdoor
#	0:Unspecified Outdoor
#	1: Muni-mesh Network
#	2: City Park
#	3: Rest Area
#	4: Traffic Control
#	5: Bus Stop
#	6: Kiosk
#	7-255: Reserved
venue_type=n/a

# ANQP Query
# Enabled(1)/Disabled(0)
anqp_query=1

# MIH Information Service Advertisement Protocol
mih_support=0

# Venue Name
# language,name
venue_name=n/a

hessid=n/a

roaming_consortium_oi=n/a

" > $CONFDIR/wapp_ap_$interface.conf

echo "
# Advertisement Protocol ID
# 0: Access Network Query Protocol
# 1: MIH Information Service
# 2: MIH Command and Event Service Capability Discovery
# 3: Emergency Alert System(EAS)
# 4-220 : Reserved
# 221: Vendor Specific
# 222-255: Reserved
advertisement_proto_id=0

domain_name=n/a

# Network Autentication Type
# Network Authentication Type Indicator;Re-direct URL
network_auth_type=n/a

# IPv4Type
# 0: Address type not available
# 1: Public IPv4 address available
# 2: Port-restricted IPv4 address available
# 3: Single NATed private IPv4 address available
# 4: Double NATed private IPv4 address available
# 5: Port-restricted IPv4 address and single NATed IPv4 address available
# 6: Port-restricted IPv4 address and double NATed IPv4 address available
# 7: Availability of the address type in not known
# 8-63: Reserved
ipv4_type=0

# IPv6TYpe
# 0: Address type not available
# 1: Address type available
# 2: Availability of the address type not known
# 3: Reserved
ipv6_type=0

nai_realm_data=n/a
" >> $CONFDIR/wapp_ap_$interface.conf

	# NAI Realm list

	echo "

# Following are HS2.0 ANQP response #
# OperatorFirendName
op_friendly_name=n/a

# Connection Capability


wan_metrics=n/a

# 3GPP cellular network information
plmn=n/a
" >> $CONFDIR/wapp_ap_$interface.conf


	echo "

# Operating class
operating_class=n/a

preferred_candi_list_included=0

disassociation_imminent=0

bss_termination_included=0

ess_disassociation_imminent=1

disassociation_timer=100

validity_interval=0

# BSS Termination Duration
bss_termination_duration=n/a

session_information_url=n/a

bss_transisition_candi_list_preferences=n/a

timezone

# Downstream Group-Aaddressed Forwrding
dgaf_disabled=0

# anqp domain ID
anqp_domain_id=1

proxy_arp=0

# 0: L2FilterDisable
# 1: L2FilterBuiltIn
# 2: L2FilterExternal
l2_filter=0

icmpv4_deny=0

# p2p management
p2p_cross_connect_permitted=0

mmpdu_size=1024

# 0: server reacheable
# 1: server not reachable for 2F test
# 2: server not reachable for 4F test
external_anqp_server_test=0

# GAS Comeback Delay in TUs
gas_cb_delay=1

hs2_openmode_test=0

osu_providers_list=n/a

anonymous_nai=n/a

osu_interface=$interface

# 0:encrypt osu ssid
# 1:legacy osu ssid
# 2:test mode
legacy_osu=2

# Qosmap
# 0: Disable
# 1: Enable
qosmap=0

dscp_range=n/a

dscp_exception=n/a

# BSS Load IE test
# 0: Disable daemon control, BSS IE control by driver
# 1: Enable daemon control, hs daemon set station count and cu to driver
# 2: Enable daemon control, hs daemon disable BSS Load IE to driver
qload_test=0

qload_cu=50

qload_sta_cnt=1

mbo_ap_cdcp=1

mbo_ap_assoc_disallow_reason=n/a

mbo_ap_assoc_retry_delay=n/a

mbo_ap_transition_reason_code=n/a

#0x40
mbo_ap_capability=n/a
" >> $CONFDIR/wapp_ap_$interface.conf

	if [ "$conf_list" == "" ]; then
		conf_list="$CONFDIR/wapp_ap_$interface.conf"
	else
		conf_list="$conf_list$CONFDIR/wapp_ap_$interface.conf;"
	fi
	echo "conf_list: $conf_list" > /dev/console
}

########################################
# gen card1 config
########################################
# all_inf_list="all_main_inf="
# if [ "$card1_exist" != "" ]; then
# 	all_inf_list="${all_inf_list}${card1_main};"    #add to all main inf list
# 	BSSIDNUM=`nvram_get ${card1_nvram} BssidNum`
# 	num=0
# 	genConfig ${card1_nvram} ${card1_main}
# 	num=`expr $num + 1`

# 	while [ $num -lt $BSSIDNUM ]
# 	do
# 		inf_name="${card1_ext}${num}"
# 		genConfig ${card1_nvram} ${inf_name}		
# 		num=`expr $num + 1`
# 	done
# else
# 	echo " ########## ${card1_main} doesn't exist , skip generating ${card1_main} hs config"
# fi

# ########################################
# # gen card2 config
# ########################################

# if [ "$card2_exist" != "" ]; then
# 	all_inf_list="${all_inf_list}${card2_main};"    #append to all main inf list
# 	BSSIDNUM=`nvram_get ${card2_nvram} BssidNum`
# 	num=0
# 	genConfig ${card2_nvram} ${card2_main}	
# 	num=`expr $num + 1`

# 	while [ $num -lt $BSSIDNUM ]
# 	do
# 		inf_name="${card2_ext}${num}"
# 		genConfig ${card2_nvram} ${inf_name}		
# 		num=`expr $num + 1`
# 	done
# else
# 	echo "########## ${card2_main} doesn't exist , skip generating ${card2_main} hs config"
# fi

# ########################################
# # gen card3 config
# ########################################

# if [ "$card3_exist" != "" ]; then
# 	all_inf_list="${all_inf_list}${card3_main};"    #append to all main inf list
# 	BSSIDNUM=`nvram_get ${card3_nvram} BssidNum`
# 	num=0
# 	genConfig ${card3_nvram} ${card3_main}	
# 	num=`expr $num + 1`

# 	while [ $num -lt $BSSIDNUM ]
# 	do
# 		inf_name="${card3_ext}${num}"
# 		genConfig ${card3_nvram} ${inf_name}		
# 		num=`expr $num + 1`
# 	done
# else
# 	echo "########## ${card3_main} doesn't exist , skip generating ${card3_main} hs config"
# fi

########################################
# write conf_list & start hs daemon
########################################
setValue() {
	case $1 in
	3gpp) create3GPP $2 $3 $4;;
	esac
}

hotspot_conf_init() {

	if [ ! -f /etc/wapp_ap.conf ]; then
		echo "base config wapp_ap.conf not exsit!" > /dev/console
		return
	fi

	if [ ! -e $CONFDIR ]; then
		mkdir $CONFDIR
		cp -rf /etc/wapp_ap* $CONFDIR/
	fi
}

hotspot_conf_add() {
	RESULT=$(ps | grep wapp| grep -v grep)
	if [ ${#RESULT} == 0 ]; then
        /sbin/wapp &
		sleep 2
    fi
	conf_list=`cat $CONFDIR/wapp_ap.conf | grep conf_list= | sed s/[[:space:]]//g`

	if [ ! -f $CONFDIR/wapp_ap_$1.conf ]; then
		genConfig $1
	fi
	echo "genConfig conf_list: $conf_list" > /dev/console
	echo "# conf_list
		# all configuation files
		${conf_list}" > $CONFDIR/wapp_ap.conf
	if [ "$conf_list" != "conf_list=" ]; then
		killall -9 wapp
		/sbin/wapp &
		sleep 2
	fi
}

hotspot_conf_del() {
	conf_list=`cat $CONFDIR/wapp_ap.conf | grep conf_list= | sed s/[[:space:]]//g`

	if [ -f $CONFDIR/wapp_ap_$1.conf ]; then
		rm -rf $CONFDIR/wapp_ap_$1.conf
	else
		return
	fi

	wappctrl $1 off

	conf_list=`echo $conf_list | sed "s/\/tmp\/hotspot\/wapp_ap_$1.conf;//g"`
	echo "# conf_list
	# all configuation files
	${conf_list}" > $CONFDIR/wapp_ap.conf
	if [ "$conf_list" != "conf_list=" ]; then
		echo "conf_list: $conf_list" > /dev/console
	else
		killall -9 wapp
	fi
}

case $1 in
	init) hotspot_conf_init;;
	add) hotspot_conf_add $2;;
	del) hotspot_conf_del $2;;
esac