  select g.name "Diskgroup", p.number_kfdpartner "Partner", d.FAILGROUP "Failgroup"
	     from x$kfdpartner p, v$asm_disk d, v$asm_diskgroup g
             where p.disk = &disk_number
  		and g.name='&diskgroup'
  		     and p.grp=g.group_number
  		     and d.group_number = g.group_number
  		     and p.grp=d.group_number
  		     and p.number_kfdpartner=d.disk_number
  	     ORDER BY p.number_kfdpartner
/
