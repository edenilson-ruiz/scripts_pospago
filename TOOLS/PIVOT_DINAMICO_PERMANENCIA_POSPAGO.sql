use DM_COMISV_POSPAGO;
go

IF OBJECT_ID('tempdb.dbo.#T', 'U') IS NOT NULL
  DROP TABLE #T; 

select TRANSACCION into #t
from PagoPospagoPermanenciaDEXMasivo 
where periodo_pago between '202001' and '202006'
group by TRANSACCION
ORDER BY TRANSACCION

declare @columnas varchar(max)

set @columnas = ''


select @columnas =  coalesce(@columnas + '[' + TRANSACCION + '],', '')
FROM (select TRANSACCION from #t) as DTM

set @columnas = left(@columnas,LEN(@columnas)-1)

DECLARE @SQLString nvarchar(500);

set @SQLString = N'
SELECT *
FROM
(select PERIODO_PAGO, TRANSACCION, COMISION 
 from PagoPospagoPermanenciaDEXMasivo 
 where periodo_pago between ''202001'' and ''202006''
) AS SourceTable
PIVOT
(
SUM(comision)
FOR TRANSACCION IN (' + @columnas + ')
) AS PivotTable
ORDER BY PERIODO_PAGO;'

EXECUTE sp_executesql @SQLString

