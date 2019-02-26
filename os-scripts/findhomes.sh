#!/bin/bash
# A little helper script for finding ORACLE_HOMEs for all running instances in a Linux server
# by Tanel Poder (http://blog.tanelpoder.com)
# 
# slightly modified by Andy Colvin (http://blog.oracle-ninja.com)
# changed "sed 's/bin\/oracle$//'" to "sed 's/\/bin\/oracle$//'"

printf "%6s %-20s %-80s\n" "PID" "NAME" "ORACLE_HOME"
pgrep -lf _pmon_ |
  while read pid pname  y ; do
    printf "%6s %-20s %-80s\n" $pid $pname `ls -l /proc/$pid/exe | awk -F'>' '{ print $2 }' | sed 's/\/bin\/oracle$//' | sort | uniq` 
  done
