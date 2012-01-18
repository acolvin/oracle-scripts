set lines 150
set pages 1000
col Diskgroup for a10
col Disk for a40
col "Size (MB)" for 999,999,999
select 
  g.name "Diskgroup", 
  d.path "Disk", 
  d.failgroup "Fail Group",
  d.state "State", 
  d.mount_status "Mount", 
  d.mode_status "Mode", 
  d.total_mb "Size (MB)", 
  d.SECTOR_SIZE "Sector Size"
from 
  v$asm_diskgroup g, 
  v$asm_disk d 
where 
  d.GROUP_NUMBER=g.GROUP_NUMBER 
order by 1,2
/
