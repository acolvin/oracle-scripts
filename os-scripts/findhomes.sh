#!/bin/bash
# A little helper script for finding ORACLE_HOMEs for all running instances in a Linux server
# by Tanel Poder (http://blog.tanelpoder.com)
# 
# slightly modified by Andy Colvin (http://blog.oracle-ninja.com)
#
# changed "sed 's/bin\/oracle$//'" to "sed 's/\/bin\/oracle$//'"
#
# updated pgrep to handle differences in pgrep on RHEL6 vs RHEL7

if [ `grep VERSION_ID /etc/os-release | cut -c 13` = "7" ]
  then
    export PGREP="pgrep -a"
  elif  [ `grep VERSION_ID /etc/os-release | cut -c 13` = "6" ]
  then
    export PGREP="pgrep -lf"
  else
    printf "this is whack\n"
fi

printf "%6s %-20s %-80s\n" "PID" "NAME" "ORACLE_HOME"
$PGREP _pmon_ |
  while read pid pname  y ; do
    printf "%6s %-20s %-80s\n" $pid $pname `ls -l /proc/$pid/exe | awk -F'>' '{ print $2 }' | sed 's/\/bin\/oracle$//' | sort | uniq` 
  done
