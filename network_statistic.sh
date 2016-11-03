#! /bin/bash

## This script will do a trace route to a specified IP and collect tcp connection performance.
## You could deploy it in crontab to monitor the network connection performance in background.
## The Output log will be stored under ~/network_statistic/.
## Usage:
## network_statistic.sh <ip> <port>

ip=$1
port=$2

## Check if paping tool is installed. If not, download from google code
if [ ! -f ~/paping ]; then
  wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/paping/paping_1.5.5_x86-64_linux.tar.gz -o ~/paping_1.5.5_x86-64_linux.tar.gz
  tar xzvf paping_1.5.5_x86-64_linux.tar.gz
fi

## Check if the log folder existed.
if [ ! -d ~/network_statistic/ ]; then
  mkdir ~/network_statistic
  chmod -R 755 ~/network/statistic
fi


## Collect Trace route info 
date >> ~/network_statistic/"$ip"_network_statistic_`date +%Y%m%d`.log
echo "====Trace route performance to $ip" >> ~/network_statistic/"$ip"_network_statistic_`date +%Y%m%d`.log
/usr/bin/traceroute $ip >> ~/network_statistic/"$ip"_network_statistic_`date +%Y%m%d`.log

## Collect Paping info
echo "====Paping performance to $ip" >> ~/network_statistic/"$ip"_network_statistic_`date +%Y%m%d`.log
~/paping -p $port $ip -c 10  >> ~/network_statistic/"$ip"_network_statistic_`date +%Y%m%d`.log

## Collect tcpdump info
#/usr/sbin/tcpdump -i eth0 host <source IP> and host <dest IP>  -C  -W 10 -w /var/tmp/tcpdump.cap &
echo "==== Collect finished====" >> ~/network_statistic/"$ip"_network_statistic_`date +%Y%m%d`.log
