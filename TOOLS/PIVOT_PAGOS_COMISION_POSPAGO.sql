
--VENTA CORPO MONTOS
select trans, canal,[201810],[201811],[201812],[201901],[201902],[201903],[201904],[201905],[201906],[201907],[201908],[201909],[201910],[201911]
from (
select 'VENTA' trans, periodo_pago, canal, sum(COMISION_SIN_IVA) comision 
from DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXCorpo
where periodo_pago between '201810' and '201911'
group by periodo_pago, canal
union all
select 'BONO X VOLUMEN' trans, periodo_pago, 'CORPORATIVO' canal, sum(COMISION_SIN_IVA) comision 
from DM_COMISV_POSPAGO.dbo.PagoPospagoBonoPorVolumenDEXCorpo
where periodo_pago between '201810' and '201911'
group by periodo_pago
union all
select 'RENOVACIONES' trans, periodo_pago, canal, sum(COMISION_SIN_IVA) comision 
from DM_COMISV_POSPAGO.dbo.PagoPospagoRenovacionesDEXCorpo
where periodo_pago between '201810' and '201911'
group by periodo_pago, canal
) as SourceTable
PIVOT (sum(comision) FOR PERIODO_PAGO in ([201810], [201811],[201812],[201901],[201902],[201903],[201904],[201905],[201906],[201907],[201908],[201909],[201910],[201911] )) AS PivotTable


--CANTIDADES corpo
select trans, canal,[201810],[201811],[201812],[201901],[201902],[201903],[201904],[201905],[201906],[201907],[201908],[201909],[201910],[201911]
from (
select 'VENTA' trans, periodo_pago, canal, SUM(CANT) cantidad
from DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXCorpo
where periodo_pago between '201810' and '201911'
group by periodo_pago, canal
union all
select 'BONO X VOLUMEN' trans, periodo_pago, 'CORPORATIVO' canal, sum(CANT_VENTA) cantidad 
from DM_COMISV_POSPAGO.dbo.PagoPospagoBonoPorVolumenDEXCorpo
where periodo_pago between '201810' and '201911'
group by periodo_pago
union all
select 'RENOVACIONES' trans, periodo_pago, canal, sum(UNIDAD) cantidad 
from DM_COMISV_POSPAGO.dbo.PagoPospagoRenovacionesDEXCorpo
where periodo_pago between '201810' and '201911'
group by periodo_pago, canal
) as SourceTable
PIVOT (sum(cantidad) FOR PERIODO_PAGO in ([201810], [201811],[201812],[201901],[201902],[201903],[201904],[201905],[201906],[201907],[201908],[201909],[201910],[201911] )) AS PivotTable


select PERIODO_PAGO, CO_ID, COUNT(*) CANT
from DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXCorpo
where PERIODO_PAGO = '201903'
GROUP BY PERIODO_PAGO, CO_ID
--HAVING COUNT(*) > 1


select PERIODO_PAGO, CO_ID, COUNT(*) CANT
from DM_COMISV_POSPAGO.dbo.PagoPospagoBonoPorVolumenDEXCorpo
where PERIODO_PAGO = '201903'
GROUP BY PERIODO_PAGO, CO_ID
HAVING COUNT(*) > 1

select PERIODO_PAGO, CO_ID, COUNT(*) CANT
from DM_COMISV_POSPAGO.dbo.PagoPospagoRenovacionesDEXCorpo
where PERIODO_PAGO = '201903'
GROUP BY PERIODO_PAGO, CO_ID
--HAVING COUNT(*) > 1


select TIPO,[201810],[201811],[201812],[201901],[201902],[201903],[201904],[201905],[201906],[201907],[201908],[201909]
from (
select periodo_pago, canal, TIPO, sum(COMISION) comision 
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones
where periodo_pago between '201810' and '201910'
 and NEGOCIO = 'MULTIMEDIA'
 AND CANAL = 'CORPORATIVO'
group by periodo_pago, canal, TIPO
) as SourceTable
PIVOT (sum(comision) FOR PERIODO_PAGO in ([201810], [201811],[201812],[201901],[201902],[201903],[201904],[201905],[201906],[201907],[201908],[201909] )) AS PivotTable





select * from DimAcreedor where ACREEDOR_NOMBRE_COMERCIAL like '%DISTEL%'

SELECT * FROM DimAcreedor where acreedor_nombre like '%AMAYA%'