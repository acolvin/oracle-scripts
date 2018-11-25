set lines 150
col name for a75
set pages 1000

select name, thread#, sequence#, archived, applied, completion_time from v$archived_log order by 3;
