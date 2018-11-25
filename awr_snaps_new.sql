col start_time for a30
col end_time for a30
col bounce noprint
break on bounce skip 1
select snap_id, instance_number inst_number, start_time, replace(end_time-start_time,'+000000000 ','') duration, snap_level,
CASE WHEN startup_time = prev_startup_time THEN 0 ELSE 1 END as bounce
from (
select snap_id, s.instance_number, begin_interval_time start_time, end_interval_time end_time, snap_level, flush_elapsed,
 lag(s.startup_time) over (partition by s.dbid, s.instance_number order by s.snap_id) prev_startup_time,
                s.startup_time
from DBA_HIST_SNAPSHOT s, v$instance i
where begin_interval_time between sysdate-1 and sysdate
and s.instance_number = i.instance_number
and s.instance_number = 1
)
order by 1,2,3
/
