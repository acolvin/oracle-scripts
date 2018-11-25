set lines 150
col Diskgroup for a15
select
  o.inst_id "Instance",
  g.name "Diskgroup",
  o.operation "Oper",
  o.state "State",
  o.power "Power",
  o.sofar "So Far",
  o.EST_WORK "Estimated Work",
  o.EST_RATE "Rate",
  o.EST_MINUTES "Minutes Left"
from
  gv$asm_operation o,
  v$asm_diskgroup g
where
  o.group_number = g.group_number
--and
--  o.state <> 'WAIT'
and
  o.state not in ('WAIT','DONE')
order by
  2,1,3
/
