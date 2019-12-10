set pages 1000
set lines 150
col "Diskgroup" for a16
col "Attribute" for a30
col "Value" for a20
select
  g.name "Diskgroup",
  a.name "Attribute",
  a.value "Value"
from
  v$asm_diskgroup g,
  v$asm_attribute a
where
  a.group_number=g.group_number
and
  a.name not like 'template%'
order by 1,2
/
