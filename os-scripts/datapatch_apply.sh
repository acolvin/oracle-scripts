#!/bin/bash

#
# Copyright 2018 Andy Colvin. All rights reserved. More info at https://oracle-ninja.com
#
# Script to run datapatch and utlrp when a database SID is passed as a parameter
# Multiple SIDs can be passed as a comma-separated list
#
# Expects to be able to run Tanel Poder's findhomes.sh via sudo
# findhomes.sh can be found at https://github.com/tanelpoder/tpt-oracle/blob/master/tools/unix/findhomes.sh
#
# Script creates a separate log file for each database instance
# Modify LOGFILE= variable if you don't like the name
#

gather_oracle_env () {
  export ORACLE_HOME=`sudo findhomes.sh | grep $ORACLE_SID | sed 's/ / /' | awk '{print $3}'`
  export PATH=$ORACLE_HOME/OPatch:$ORACLE_HOME/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin
}

open_pdbs () {
#  sqlplus -S /nolog 1>>/tmp/post_patch_$ORACLE_SID.log 2>&1 << ENDSQLPLUS
  printf "\n**************************\n* Opening PDBs on $ORACLE_SID *\n**************************\n" >> $LOGFILE
  sqlplus -S /nolog 1>>$LOGFILE 2>&1 << ENDSQLPLUS
    conn / as sysdba
    alter pluggable database all open;
    exit;
ENDSQLPLUS
}

show_pdbs () {
  printf "\n****************************\n* Status of PDBs on $ORACLE_SID *\n****************************\n" >> $LOGFILE
#  sqlplus -S /nolog 1>>/tmp/post_patch_$ORACLE_SID.log 2>&1 << ENDSQLPLUS
  sqlplus -S /nolog 1>>$LOGFILE 2>&1 << ENDSQLPLUS
    conn / as sysdba
    show pdbs;
    exit;
ENDSQLPLUS
}

run_utlrp () {
  printf "running utlrp on $ORACLE_SID..."
  printf "\n***************************\n* Running utlrp on $ORACLE_SID *\n***************************\n" >> $LOGFILE
#  sqlplus -S /nolog 1>>/tmp/post_patch_$ORACLE_SID.log 2>&1 << ENDSQLPLUS
  sqlplus -S /nolog 1>>$LOGFILE 2>&1 << ENDSQLPLUS
    conn / as sysdba
    @?/rdbms/admin/utlrp.sql
    exit;
ENDSQLPLUS
  printf "COMPLETE\n"
}

run_datapatch () {
  printf "\nRunning datapatch in $ORACLE_HOME/OPatch for $ORACLE_SID..."
  printf "\n******************************\n* Running datapatch on $ORACLE_SID *\n*******************************\n" >> $LOGFILE
#  cd $ORACLE_HOME/OPatch; ./datapatch -db $ORACLE_SID -verbose >> /tmp/post_patch_$ORACLE_SID.log
  cd $ORACLE_HOME/OPatch; ./datapatch -db $ORACLE_SID -verbose >> $LOGFILE
  if [[ $? -eq 0 ]] ; then
    printf "COMPLETE\n"
  else
    printf "\n*** ERROR in datapatch run, check $LOGFILE ***\n"
  fi
}

export INSTANCES=$1

for ORACLE_SID in $(echo $INSTANCES | sed "s/,/ /g")
do
  export ORACLE_SID
  export LOGDATE=`date +"%Y%m%d%H%M"`
  export LOGFILE=/tmp/post_patch_${ORACLE_SID}_${LOGDATE}.log
  printf "\n************\nRunning post-patch steps on $ORACLE_SID at `date "+%Y/%m/%d_%R"`\nLog file can be found in $LOGFILE\n"
  gather_oracle_env
  open_pdbs
  show_pdbs
  run_datapatch
  run_utlrp
  show_pdbs
done