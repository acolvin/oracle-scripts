#!/bin/bash

#
# Copyright 2018 Andy Colvin. All rights reserved. More info at https://oracle-ninja.com
#
# Script to run datapatch and utlrp when a database SID is passed as a parameter
# Multiple SIDs can be passed as a comma-separated list
#
# Expects to be able to run Andy Colvin's modified findhomes.sh (preferably owned by root) via sudo in /usr/local/bin - sudo rule is:
# oracle ALL=(root) NOPASSWD:/usr/local/bin/findhomes.sh
#
# findhomes.sh can be found at https://github.com/acolvin/oracle-scripts/blob/master/os-scripts/findhomes.sh
#
# Script creates a separate log file for each database instance
# Modify LOGFILE= variable if you don't like the name
#

### Version history
# 20191209 - Update utlrp to use catcon.pl, modify logfile entry

gather_oracle_env () {
  export ORACLE_HOME=`sudo /usr/local/bin/findhomes.sh | grep -w ora_pmon_${ORACLE_SID} | sed 's/ / /' | awk '{print $3}'`
  export PATH=$ORACLE_HOME/OPatch:$ORACLE_HOME/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin
}

open_pdbs () {
  printf "\n**************************\n* Opening PDBs on $ORACLE_SID *\n**************************\n" >> $LOGFILE
  sqlplus -S /nolog 1>>$LOGFILE 2>&1 << ENDSQLPLUS
    conn / as sysdba
    alter pluggable database all open;
    exit;
ENDSQLPLUS
}

show_pdbs () {
  printf "\n****************************\n* Status of PDBs on $ORACLE_SID *\n****************************\n" >> $LOGFILE
  sqlplus -S /nolog 1>>$LOGFILE 2>&1 << ENDSQLPLUS
    conn / as sysdba
    show pdbs;
    exit;
ENDSQLPLUS
}

run_utlrp () {
  printf "running utlrp on $ORACLE_SID..."
  printf "\n***************************\n* Running utlrp on $ORACLE_SID *\n***************************\n" >> $LOGFILE
  $ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -d $ORACLE_HOME/rdbms/admin -l /tmp -b utlrp_$ORACLE_SID_ utlrp.sql 1>>$LOGFILE 2>&1
#  sqlplus -S /nolog 1>>$LOGFILE 2>&1 << ENDSQLPLUS
#    conn / as sysdba
#    @?/rdbms/admin/utlrp.sql
#    exit;
#ENDSQLPLUS
  printf "COMPLETE\n"
}

run_datapatch () {
  printf "\nRunning datapatch in $ORACLE_HOME/OPatch for $ORACLE_SID..."
  printf "\n******************************\n* Running datapatch on $ORACLE_SID *\n*******************************\n" >> $LOGFILE
  cd $ORACLE_HOME/OPatch; ./datapatch -db $ORACLE_SID -verbose 1>>$LOGFILE 2>&1
  if [[ $? -eq 0 ]] ; then
    printf "COMPLETE\n"
  else
    printf "\n*** ERROR in datapatch run, check $LOGFILE ***\n"
  fi
}

check_registry () {
  CONTAINERS="V\$CONTAINERS"
  printf "\n****************************\n* CDB_REGISTRY_SQL_PATCH on $ORACLE_SID *\n****************************\n" >> $LOGFILE
  sqlplus -S /nolog 1>>$LOGFILE 2>&1 << ENDSQLPLUS
    conn / as sysdba
    col name for a15
    col action_time for a40
    col status for a15
    set lines 150
    select c.name, r.patch_id, r.status, r.action_time from cdb_registry_sqlpatch r, $CONTAINERS c where c.con_id=r.con_id and r.action_time > trunc(sysdate) - 7 order by 1,2;
    exit;
ENDSQLPLUS
}

export INSTANCES=$1

for ORACLE_SID in $(echo $INSTANCES | sed "s/,/ /g")
do
  export ORACLE_SID
  export LOGDATE=`date +"%Y%m%d%H%M"`
  export LOGFILE=/tmp/post_patch_${ORACLE_SID}_${LOGDATE}.log
  printf "\n************\nRunning post-patch steps on $ORACLE_SID at `date "+%Y/%m/%d_%R"`\nLog file can be found in $LOGFILE\n"
  gather_oracle_env
#  open_pdbs
  show_pdbs
  run_datapatch
  run_utlrp
  check_registry
  show_pdbs
done
