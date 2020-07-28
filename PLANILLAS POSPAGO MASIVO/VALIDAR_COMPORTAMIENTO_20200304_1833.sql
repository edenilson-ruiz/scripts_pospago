select * from FactPospagoDescuentos where TIPOTRANS_ID = 36

select *
from DimDealer where DEALER_CODE in (
'TV022AG',
'TV087PM'
)


select a.PERIODO, a.FECHA_ID, b.NDiaSemanaAbrev, COUNT(*) CANT 
from PagoPospagoVentasTMK A
	INNER JOIN DimTiempo b on b.Idfecha = A.FECHA_ID
where PERIODO_PAGO = '202003'
GROUP BY a.PERIODO, a.FECHA_ID, b.NDiaSemanaAbrev
ORDER BY A.FECHA_ID

select a.PERIODO, a.FECHA, b.NDiaSemanaAbrev, COUNT(*) CANT 
from PagoPospagoRenovacionesTMK A
	INNER JOIN DimTiempo b on b.Idfecha = A.FECHA
where PERIODO_PAGO = '202003'
GROUP BY a.PERIODO, a.FECHA, b.NDiaSemanaAbrev
ORDER BY A.FECHA


select PERIODO_PAGO, DISTRIBUIDOR, SUM(COMISION) COMISION
from PlanillasPospagoResumenMasivo
where PERIODO_PAGO between '201901' and '202003'
GROUP BY PERIODO_PAGO, DISTRIBUIDOR