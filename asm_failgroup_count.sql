set lines 150
set pages 1000
col "Diskgroup" for a10
col "Fail Group" for a15
select
  g.name "Diskgroup",
  d.failgroup "Fail Group",
  count(d.name) "Disks"
from
  v$asm_diskgroup g,
  v$asm_disk d
where
  g.group_number = d.group_number
group by 
  g.name, 
  d.failgroup
order by 
  g.name,
  d.failgroup
/
