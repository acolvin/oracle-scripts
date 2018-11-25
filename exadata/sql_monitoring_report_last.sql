set lines 180
col report for a179
select
DBMS_SQLTUNE.REPORT_SQL_MONITOR(
   session_id=>sys_context('userenv','sid'),
   report_level=>'ALL') as report
from dual;
set lines 155
