#!/bin/sh

# 650-wallv2 将每个口速率限制在1000M，防止rx跑流单口超过1000M导致数据包阻塞，引起rx速率下降
echo 1 1 0 1 1000000 4 4 > /sys/kernel/debug/hnat/qdma_txq1
echo 1 1 0 1 1000000 4 4 > /sys/kernel/debug/hnat/qdma_txq2
echo 0 wrr 0 > /sys/kernel/debug/hnat/qdma_sch1
echo 0 > /sys/kernel/debug/hnat/hook_toggle
echo 1 > /sys/kernel/debug/hnat/hook_toggle
