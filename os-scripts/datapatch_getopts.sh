#!/bin/bash

#
# Copyright 2018 Andy Colvin. All rights reserved. More info at https://oracle-ninja.com
#
# Script to run datapatch and utlrp when a database SID is passed as a parameter
# Multiple SIDs can be passed as a comma-separated list via the -d argument
# If you want the script to attempt to open PDBs before running, include -o
#
# Example - ./datapatch_apply.sh -d db1,db2,db3,db4
#
# Expects to be able to run Tanel Poder's findhomes.sh via sudo in /usr/local/bin - sudo rule is:
# oracle ALL=(root) NOPASSWD:/usr/local/bin/findhomes.sh
#
# findhomes.sh can be found at https://github.com/tanelpoder/tpt-oracle/blob/master/tools/unix/findhomes.sh
#
# Script creates a separate log file for each database instance
# Modify LOGFILE= variable if you don't like the name
#

export OPEN_PDBS=0
export VERSION_NUMBER=20191231
export INSTANCES=`pgrep -l ora_pmon | cut -f3 -d "_"`

usage () {
   echo "Usage:
     $0 -p -d [-o] [-h]
     -p - Number of datapatch operations to run in parallel
     -o - Option to run 'alter pluggable database all open' before running datapatch
     -d - Comma-separated list of database instances to run datapatch
     -v - Version
     -h - Usage
   "
   exit 1
}

print_version () {
  printf "datapatch_apply.sh by Andy Colvin, version $VERSION_NUMBER\n"
  exit 1
}

#Grab Options
while getopts ohvp:d: option
do
 case "$option" in
   p) 
     export PARALLEL=$OPTARG
      ;;
   o)
     export OPEN_PDBS=1
     ;;
   d)
     export INSTANCES=$OPTARG
      ;;
   v)
     print_version 
      ;;
   *)
     usage
      ;;
 esac
done 2>/dev/null
shift $(($OPTIND-1))

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
  printf "COMPLETE\n"
}

run_datapatch () {
  printf "\nRunning datapatch in $ORACLE_HOME/OPatch for $ORACLE_SID..."
  printf "\n******************************\n* Running datapatch on $ORACLE_SID *\n*******************************\n" >> $LOGFILE
  cd $ORACLE_HOME/OPatch; ./datapatch -db $ORACLE_SID -verbose >> $LOGFILE
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

#export INSTANCES=$1

printf "\n****** database instances to be patched are \n$INSTANCES \n******\n"
printf "**** OPEN_PDBS value is $OPEN_PDBS *****\n"

for ORACLE_SID in $(echo $INSTANCES | sed "s/,/ /g")
do
  export ORACLE_SID
  export LOGDATE=`date +"%Y%m%d%H%M"`
  export LOGFILE=/tmp/post_patch_${ORACLE_SID}_${LOGDATE}.log
#  gather_oracle_env
  if [ $OPEN_PDBS -eq 1 ]
  then
    printf "**** opening PDBs ****\n"
  open_pdbs
  else
    printf "**** Skipping PDB Open ****\n"
  fi
  printf "\n************\nRunning post-patch steps on $ORACLE_SID at `date "+%Y/%m/%d_%R"`\nLog file can be found in $LOGFILE\n"
  show_pdbs
  run_datapatch
  run_utlrp
  check_registry
  show_pdbs
done
