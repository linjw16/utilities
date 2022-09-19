#!/bin/bash
cpuname=$(cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c)
physical=$(cat /proc/cpuinfo | grep "physical id" | sort -u | wc -l)
processor=$(cat /proc/cpuinfo | grep "processor" | wc -l)
cpucores=$(cat /proc/cpuinfo  | grep "cpu cores" | uniq)
siblings=$(cat /proc/cpuinfo  | grep "siblings"  | uniq)

echo "* * * * * CPU Information * * * * *"
echo "（CPU型号）cpu name : $cpuname"
echo "（物理CPU个数）physical id is : $physical"
echo "（逻辑CPU个数）processor is : $processor"
echo "（CPU内核数）cpu cores is : $cpucores"
echo "（单个物理CPU的逻辑CPU数）siblings is : $siblings"

