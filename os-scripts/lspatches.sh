#!/bin/bash

# Copyright 2020 Andy Colvin. All rights reserved. More info at https://oracle-ninja.com
# Script to gather list of patches for every Oracle home on a host

# Version History
# 20200128 - Initial version

# Get Inventory Location
ORAINVENTORY=`grep loc /etc/oraInst.loc | cut -f2 -d"="`

# Run opatch lspatches for each home
for OH in `cat $ORAINVENTORY/ContentsXML/inventory.xml | grep -v REMOVED | sed -n "s/.*LOC=\"\(.*\)\"\ TYPE.*/\1/p" | sort -u`;
  do
    OWNER=`stat $OH | grep Uid | cut -f3 -d"/" | cut -f1 -d")"`
    printf '********************************************************************\n';
    printf '** Checking patches for %s **\n' $OH;
    printf '** Software owner is %s **\n' $OWNER;
    printf '********************************************************************\n';
    $OH/OPatch/opatch lspatches -oh $OH;
  done
