#!/bin/bash

# Script to copy Oracle Cluster Registry backup from ASM diskgroup to local directory
# Backs files up to $ORACLE_BASE/admin/ocrbackup
# Copyright 2018 Andy Colvin. All rights reserved. More info at https://oracle-ninja.com

# Get PID for ASM
ASMPID=`pgrep asm_pmon`

# If ASM isn't running, stop script
if [ -z "$ASMPID" ]; then
  echo -e "ASM is not running, exiting script";
  exit 1;
fi

# Gather Oracle environment variables
ORACLE_HOME=`ls -l /proc/$ASMPID/exe | awk -F'> ' '{ print $2 }' | sed 's/\/bin\/oracle$//'`
ORACLE_BASE=`strings /proc/$ASMPID/environ | grep ORACLE_BASE | sed 's/.*ORACLE_BASE=//'`
ORACLE_SID=`strings /proc/$ASMPID/environ | grep ORACLE_SID | sed 's/.*ORACLE_SID=//'`
PATH=$ORACLE_HOME/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin

# Get backup file information
OCRDATE=`ocrconfig -showbackup | grep day | tr -s ' ' | cut -d ' ' -f 2`
FILEDATE=`date --date="$OCRDATE" +"%Y%m%d"`
DAYBACKUP=`ocrconfig -showbackup | grep day | tr -s ' ' | cut -d ' ' -f 4 | sed 's/\://'`

# Exit if there isn't a valid day backup
if [ -z "$OCRDATE" ]; then
  echo -e "No 'day' backup exists, exiting";
  exit 1;
fi

# Create backup location if it doesn't exist
if [ ! -d "$ORACLE_BASE/admin/ocrbackup" ]; then
  echo -e "creating backup directory in $ORACLE_BASE/admin/ocrbackup\n";
  mkdir -p $ORACLE_BASE/admin/ocrbackup
fi

# Copy backup from ASM to local filesystem
$ORACLE_HOME/bin/asmcmd cp $DAYBACKUP $ORACLE_BASE/admin/ocrbackup/ocr_$FILEDATE.ocr

# Clean up backups older than 14 days
echo -e "\nCleaning up backups\n"
find $ORACLE_BASE/admin/ocrbackup -type f -name ‘*.ocr’ -mtime +14 -exec rm {} \;
