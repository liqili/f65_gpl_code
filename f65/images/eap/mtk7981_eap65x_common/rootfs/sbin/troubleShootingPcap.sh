#! /bin/sh

cap1="tsPcap.pcap1"

if [ -f "/tmp/$cap1" ];then
	echo "pcap1 exist"
    killall tcpdump
    rm -f /tmp/$cap1
	touch /tmp/pcapdone
fi