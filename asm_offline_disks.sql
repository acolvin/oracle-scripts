set lines 150
set pages 100
col Diskgroup for a25
col Disk for a50
select
  g.name "Diskgroup",
  d.name "Disk",
  d.failgroup "Fail Group",
  d.state "State",
  d.mount_status "Mount",
  d.mode_status "Mode"
from
  v$asm_diskgroup g,
  v$asm_disk d
where
  --d.GROUP_NUMBER=g.GROUP_NUMBER
  d.mode_status <> 'ONLINE'
  and d.GROUP_NUMBER=g.GROUP_NUMBER
order by 1,2
/
