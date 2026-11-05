#!/bin/sh
#set -x on
#for 7986 5G Debug

iwpriv ra0 mac 820FD090=FEFDFC00
sleep 1
num=0
echo -e "\nmac 820FD090=FEFDFC00\n"
sleep 2
while [ $num -le 20 ];do
	iwpriv ra0 mac 820FD0A0-820FD0A4
	num=$((${num}+1))
done

echo -e "\n"

sleep 1
iwpriv ra0 mac 820FD090=B4B2B0AE
iwpriv ra0 mac 820FD094=B9B8B7B6
sleep 1
num=0
echo -e "\nmac 820FD090=B4B2B0AE\n"
sleep 2
while [ $num -le 20 ];do
	iwpriv ra0 mac 820FD0A0-820FD0AC
	num=$((${num}+1))
done

echo -e "\n"

num=0
sleep 1
iwpriv ra0 mac 820FD090=96BCBBBA
iwpriv ra0 mac 820FD094=9A999897
sleep 1
echo -e "\nmac 820FD090=96BCBBBA\n"
sleep 2
while [ $num -le 20 ];do
	iwpriv ra0 mac 820FD0A0-820FD0AC
	num=$((${num}+1))
done

echo -e "\n"

num=0
sleep 1
iwpriv ra0 mac 820FD090=9E9D9C9B
iwpriv ra0 mac 820FD094=A2A1A09F
sleep 1
echo -e "\nmac 820FD090=9E9D9C9B\n"
sleep 2
while [ $num -le 20 ];do
	iwpriv ra0 mac 820FD0A0-820FD0AC
	num=$((${num}+1))
done

echo -e "\n"

num=0
sleep 1
iwpriv ra0 mac 820FD090=A6A5A4A3
iwpriv ra0 mac 820FD094=AAA9A8A7
sleep 1
echo -e "\nmac 820FD090=A6A5A4A3\n"
sleep 2
while [ $num -le 20 ];do
	iwpriv ra0 mac 820FD0A0-820FD0AC
	num=$((${num}+1))
done

echo -e "\n"

num=0
sleep 1
iwpriv ra0 mac 820FD090=80ADACAB
iwpriv ra0 mac 820FD094=84838281
sleep 1
echo -e "\nmac 820FD090=80ADACAB\n"
sleep 2
while [ $num -le 20 ];do
	iwpriv ra0 mac 820FD0A0-820FD0AC
	num=$((${num}+1))
done

echo -e "\n"

num=0
sleep 1
iwpriv ra0 mac 820FD090=88878685
iwpriv ra0 mac 820FD094=8C8B8A89
sleep 1
echo -e "\nmac 820FD090=88878685\n"
sleep 2
while [ $num -le 20 ];do
	iwpriv ra0 mac 820FD0A0-820FD0AC
	num=$((${num}+1))
done

echo -e "\n"

num=0
sleep 1
iwpriv ra0 mac 820FD090=908F8E8D
iwpriv ra0 mac 820FD094=94939291
sleep 1
echo -e "\nmac 820FD090=908F8E8D\n"
sleep 2
while [ $num -le 20 ];do
	iwpriv ra0 mac 820FD0A0-820FD0AC
	num=$((${num}+1))
done

echo -e "\n"

num=0
sleep 1
iwpriv ra0 mac 820FD090=00000095
iwpriv ra0 mac 820FD094=00000000
sleep 1
echo -e "\nmac 820FD090=00000095\n"
sleep 2
while [ $num -le 20 ];do
	iwpriv ra0 mac 820FD0A0-820FD0AC
	num=$((${num}+1))
done


#add
num=0
echo -e "\n5G cnt\n"
iwpriv ra0 mac 83182004
iwpriv ra0 mac 83182004=A00
while [ $num -le 20 ];do
	iwpriv ra0 mac 83181010-83181040
	sleep 1
	num=$((${num}+1))
done

sleep 2
num=0
echo -e "\n820F31F8,case4\n"
iwpriv ra0 mac 820F31F8

while [ $num -le 6 ];do
	iwpriv ra0 mac 7C06039C=1f
	iwpriv ra0 mac 7C0603A0=05050505
	iwpriv ra0 mac 820F22F0
	sleep 1
	iwpriv ra0 mac 7C0603A4=2e2e3131
	iwpriv ra0 mac 820F0104
	sleep 1
	iwpriv ra0 mac 7C0603A4=3b3b3d3d
	iwpriv ra0 mac 820F0104
	sleep 1
	num=$((${num}+1))
done