!echo "************************************************"
!echo "************ checking ASM diskgroups ***********"
!echo "************************************************"

set lines 150
set pages 1000
col "Diskgroup" for a20
col "Fail Group" for a25
col "Size (MB)" for 999,999,999
col "Free (MB)" for 999,999,999
col Redundancy for a10
col "AU Size (MB)" for 999,999
col "Usable (MB)" for 999,999,999
select
  name "Diskgroup",
  SECTOR_SIZE "Sector Size",
  ALLOCATION_UNIT_SIZE/1024/1024 "AU Size (MB)",
  state "State",
  type "Redundancy",
  TOTAL_MB "Size (MB)",
  FREE_MB "Free (MB)",
  FREE_MB/decode(type, 'HIGH', 3,
                       'NORMAL', 2) "Usable (MB)"
from
  v$asm_diskgroup
order by 1
/

!echo "***************************************************************"
!echo "************ checking failgroup usage by diskgroup  ***********"
!echo "***************************************************************"

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

!echo "****************************************************"
!echo "************ checking for offline disks  ***********"
!echo "****************************************************"

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
