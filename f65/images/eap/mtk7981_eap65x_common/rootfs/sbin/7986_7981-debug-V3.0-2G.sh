#!/bin/sh
#set -x on
#for 7986、7981 2G Debug

num=0
echo -e "\nmac 820ED090=FEFDFC00\n"
sleep 1
iwpriv ra0 mac 820ED090=FEFDFC00
sleep 3

while [ $num -le 10 ];do
	iwpriv ra0 mac 820ED0A0-820ED0A4
	sleep 1
	num=$((${num}+1))
done

num=0
echo -e "\nmac 820ED090=B4B2B0AE\n"
sleep 1
iwpriv ra0 mac 820ED090=B4B2B0AE
iwpriv ra0 mac 820ED094=B9B8B7B6
sleep 3

while [ $num -le 10 ];do
	iwpriv ra0 mac 820ED0A0-820ED0AC
	sleep 1
	num=$((${num}+1))
done


num=0
echo -e "\nmac 820ED090=96BCBBBA\n"
sleep 1
iwpriv ra0 mac 820ED090=96BCBBBA
iwpriv ra0 mac 820ED094=9A999897
sleep 3

while [ $num -le 10 ];do
	iwpriv ra0 mac 820ED0A0-820ED0AC
	sleep 1
	num=$((${num}+1))
done

num=0
echo -e "\nmac 820ED090=9E9D9C9B\n"
sleep 1
iwpriv ra0 mac 820ED090=9E9D9C9B
iwpriv ra0 mac 820ED094=A2A1A09F
sleep 3

while [ $num -le 10 ];do
	iwpriv ra0 mac 820ED0A0-820ED0AC
	sleep 1
	num=$((${num}+1))
done


num=0
echo -e "\nmac 820ED090=A6A5A4A3\n"
sleep 1
iwpriv ra0 mac 820ED090=A6A5A4A3
iwpriv ra0 mac 820ED094=AAA9A8A7
sleep 3

while [ $num -le 10 ];do
	iwpriv ra0 mac 820ED0A0-820ED0AC
	sleep 1
	num=$((${num}+1))
done

echo -e "\n"

num=0
echo -e "\nmac 820ED090=80ADACAB\n"
sleep 1
iwpriv ra0 mac 820ED090=80ADACAB
iwpriv ra0 mac 820ED094=84838281
sleep 3

while [ $num -le 10 ];do
	iwpriv ra0 mac 820ED0A0-820ED0AC
	sleep 1
	num=$((${num}+1))
done


num=0
echo -e "\nmac 820ED090=88878685\n"
sleep 1
iwpriv ra0 mac 820ED090=88878685
iwpriv ra0 mac 820ED094=8C8B8A89
sleep 3

while [ $num -le 10 ];do
	iwpriv ra0 mac 820ED0A0-820ED0AC
	sleep 1
	num=$((${num}+1))
done

num=0
echo -e "\nmac 820ED090=908F8E8D\n"
sleep 1
iwpriv ra0 mac 820ED090=908F8E8D
iwpriv ra0 mac 820ED094=94939291
sleep 3

while [ $num -le 10 ];do
	iwpriv ra0 mac 820ED0A0-820ED0AC
	sleep 1
	num=$((${num}+1))
done

num=0
echo -e "\nmac 820ED090=00000095\n"
sleep 1
iwpriv ra0 mac 820ED090=00000095
iwpriv ra0 mac 820ED094=00000000
sleep 3

while [ $num -le 10 ];do
	iwpriv ra0 mac 820ED0A0-820ED0AC
	sleep 1
	num=$((${num}+1))
done

#add
num=0
echo -e "\n2G cnt\n"
iwpriv ra0 mac 83082004
iwpriv ra0 mac 83082004=A00
while [ $num -le 20 ];do
	iwpriv ra0 mac 83081010-83081040
	sleep 1
	num=$((${num}+1))
done

sleep 2
num=0
echo -e "\n820E31F8,case4\n"
iwpriv ra0 mac 820E31F8

while [ $num -le 6 ];do
	iwpriv ra0 mac 7C060390=1f
	iwpriv ra0 mac 7C060394=05050505
	iwpriv ra0 mac 820E22F0
	sleep 1
	iwpriv ra0 mac 7C060398=2e2e3131
	iwpriv ra0 mac 820E0104
	sleep 1
	iwpriv ra0 mac 7C060398=3b3b3d3d
	iwpriv ra0 mac 820E0104
	sleep 1
	num=$((${num}+1))
done


