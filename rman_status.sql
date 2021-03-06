set lines 150
col "%_COMPLETE" for 999.99
SELECT L.inst_id, L.SID, L.SERIAL#, L.CONTEXT, S.CLIENT_INFO "RMAN_CHANNEL", L.SOFAR, L.TOTALWORK,
  ROUND(L.SOFAR/L.TOTALWORK*100,2) "%_COMPLETE"
FROM gV$SESSION_LONGOPS L, GV$SESSION S
WHERE L.SID = S.SID
  AND L.OPNAME LIKE 'RMAN%'
  AND L.OPNAME NOT LIKE '%aggregate%'
  AND L.TOTALWORK != 0
  AND L.SOFAR <> TOTALWORK
ORDER BY 1,"RMAN_CHANNEL"
/
