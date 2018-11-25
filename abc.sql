column "Tablespace" format a25
column "Used MB" format 99,999,999
column "Free MB" format 99,999,999
column "Total MB" format 99,999,999
set echo off

compute sum of "Used MB", "Free MB", "Total MB" on report
break on report
select
fs.tablespace_name "Tablespace",
(df.totalspace - fs.freespace) "Used MB",
fs.freespace "Free MB",
df.totalspace "Total MB",
round(100 * (fs.freespace / df.totalspace)) "Pct. Free"
from
(select
tablespace_name,
round(sum(bytes) / 1048576) TotalSpace
from
dba_data_files
group by
tablespace_name
) df,
(select
tablespace_name,
round(sum(bytes) / 1048576) FreeSpace
from
dba_free_space
group by
tablespace_name
) fs
where
df.tablespace_name = fs.tablespace_name
order by "Tablespace"
/


