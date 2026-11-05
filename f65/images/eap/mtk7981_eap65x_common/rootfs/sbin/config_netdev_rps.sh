#!/bin/sh

# 全局赋值操作: 
#       $1: net_device  name
#       $3: rps_cpu 的掩码
dev_path=/sys/class/net/$1/queues
rps_cpu=$2

# 配置某个具体 net_device 的 rps 的使能/不使能
config_dev_rps_cpus()
{
    cd $dev_path
    for dir_rps in  rx-* ;
        do echo $rps_cpu >  "$dir_rps/rps_cpus";
    done
}

# main
config_dev_rps_cpus

