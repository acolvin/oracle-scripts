set lines 150
set pages 1000
col "Diskgroup" for a10
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
