set pages 1000
set lines 100
col BEGIN_INTERVAL_TIME for a30
col END_INTERVAL_TIME for a30

select snap_id, instance_number, BEGIN_INTERVAL_TIME, END_INTERVAL_TIME from awr_pdb_snapshot order by 1,2;

