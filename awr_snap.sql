set head off
select 'Snapshot '||dbms_workload_repository.create_snapshot()||' created.' from dual;
set head on
