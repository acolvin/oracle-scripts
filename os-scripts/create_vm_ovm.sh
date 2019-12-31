#!/bin/bash

#####################################
#  Written by Andy Colvin           #
#  Accenture Enkitec Group          #
#  2016-10-15                       #
#                                   #
#  This script creates a VM on the  #
#  Oracle Vritual Machine           #
#  using the ovmcli messaging API   #
#                                   #
#####################################

### Modify these variables for your environment
OVMMuser=admin
OVMMhost=$OVMMhost

### Variables to be set for VM ###
vmName=$1
domainName=enkitec.com
vmIP=$2
vmNetMask=255.255.255.0
vmGW=10.9.237.1
vmPW=$3
vmTemplate=$4
vmIPShort=`echo $vmIP | cut -c 10-`

##### Static Variables

while getopts ":hisgtp" opt; do
  case ${opt} in
    h ) # set hostname
      ;;
    i ) # set ip
      ;;
    s ) # set subnet
      ;;
    g ) # set gateawy
      ;;
    t ) # set VM template
      ;;
    p ) # set password
      ;;
    \? ) echo "Usage: cmd [-h] [-t]"
      ;;
  esac
done

ipa host-add $vmName.enkitec.local --password=welcome1 --ip-address=$vmIP
ipa dnsrecord-add 237.9.10.in-addr.arpa $vmIPShort --ptr-rec $vmName.enkitec.local.
ssh  -oPort=10000 OVMMuser@$OVMMhost "clone vm name=$vmTemplate destType=Vm destName=$vmName serverPool=Rack1_ServerPool"
ssh  -oPort=10000 OVMMuser@$OVMMhost "start vm name=$vmName"
sleep 30
ssh  -oPort=10000 OVMMuser@$OVMMhost "sendVmMessage Vm name=$vmName key=com.oracle.linux.network.hostname message=$vmName.$domainName log=no"
ssh  -oPort=10000 OVMMuser@$OVMMhost "sendVmMessage Vm name=$vmName key=com.oracle.linux.network.dns-search-domains.0 message=enkitec.local log=no"
ssh  -oPort=10000 OVMMuser@$OVMMhost "sendVmMessage Vm name=$vmName key=com.oracle.linux.network.host.0 message='$vmIP $vmName.enkitec.local $vmName' log=no"
ssh  -oPort=10000 OVMMuser@$OVMMhost "sendVmMessage Vm name=$vmName key=com.oracle.linux.network.dns-servers.0 message=10.9.236.101 log=no"
ssh  -oPort=10000 OVMMuser@$OVMMhost "sendVmMessage Vm name=$vmName key=com.oracle.linux.network.device.0 message=eth0 log=no"
ssh  -oPort=10000 OVMMuser@$OVMMhost "sendVmMessage Vm name=$vmName key=com.oracle.linux.network.onboot.0 message=yes log=no"
ssh  -oPort=10000 OVMMuser@$OVMMhost "sendVmMessage Vm name=$vmName key=com.oracle.linux.network.bootproto.0 message=static log=no"
ssh  -oPort=10000 OVMMuser@$OVMMhost "sendVmMessage Vm name=$vmName key=com.oracle.linux.network.ipaddr.0 message=$vmIP log=no"
ssh  -oPort=10000 OVMMuser@$OVMMhost "sendVmMessage Vm name=$vmName key=com.oracle.linux.network.netmask.0 message=$vmNetMask log=no"
ssh  -oPort=10000 OVMMuser@$OVMMhost "sendVmMessage Vm name=$vmName key=com.oracle.linux.network.gateway.0 message=$vmGW log=no"
ssh  -oPort=10000 OVMMuser@$OVMMhost "sendVmMessage Vm name=$vmName key=com.oracle.linux.root-password message=$vmPW log=no"
sleep 30
#ssh-keyscan -H $vmIP >> ~/.ssh/known_hosts
ssh-keyscan $vmIP >> ~/.ssh/known_hosts
ssh -o StrictHostKeyChecking=no root@$vmIP 'echo "nameserver 10.9.236.101" >> /etc/resolv.conf'
ssh -o StrictHostKeyChecking=no root@$vmIP 'ipa-client-install --password=welcome1 --mkhomedir --enable-dns-updates --unattended --no-ntp'
ssh -o StrictHostKeyChecking=no root@$vmIP 'rm -Rf /root/.ssh/authorized_keys'
