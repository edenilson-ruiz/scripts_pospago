--Con Montos a nivel de canal
select canal, sub_canal, negocio, tipo, [201810],[201811],[201812],[201901],[201902],[201903],[201904],[201905],[201906],[201907],[201908],[201909],[201910],[201911],[201912]
from (
select periodo_pago, canal, sub_canal, negocio, tipo, sum(comision) comision 
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones 
where periodo_pago between '202001' and '202006'
 and negocio = 'MULTIMEDIA' 
 --AND TIPO NOT IN ('TIEMPO AIRE')
group by periodo_pago, canal, sub_canal, negocio, tipo
) as SourceTable
PIVOT (sum(comision) FOR PERIODO_PAGO in ([201810], [201811],[201812],[201901],[201902],[201903],[201904],[201905],[201906],[201907],[201908],[201909],[201910],[201911],[201912])) AS PivotTable
ORDER BY SUB_CANAL, TIPO


--Con Montos a nivel de canal | RESUMEN
select canal, sub_canal, negocio, [201810],[201811],[201812],[201901],[201902],[201903],[201904],[201905],[201906],[201907],[201908],[201909],[201910],[201911],[201912]
from (
select periodo_pago, canal, sub_canal, negocio,  sum(comision) comision 
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones 
where periodo_pago between '201810' and '201912'
 and negocio = 'PREPAGO' 
 --AND TIPO NOT IN ('TIEMPO AIRE')
group by periodo_pago, canal, sub_canal, negocio
) as SourceTable
PIVOT (sum(comision) FOR PERIODO_PAGO in ([201810], [201811],[201812],[201901],[201902],[201903],[201904],[201905],[201906],[201907],[201908],[201909],[201910],[201911],[201912])) AS PivotTable
ORDER BY SUB_CANAL

SELECT * from DM_OPERACIONES_SV.dbo.FactHistoricoComisiones WHERE PERIODO_PAGO = '201911' AND NEGOCIO = 'PREPAGO'

select sum(comision) from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones where negocio = 'PREPAGO' and periodo_pago = '201906'


--Con Montos
select canal, tipo, [201810],[201811],[201812],[201901],[201902],[201903],[201904]
from (
select periodo_pago, canal, negocio, tipo, sum(comision) comision 
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones 
where periodo_pago between '201810' and '201904'
 and negocio = 'PREPAGO'
 and canal = 'DISTRIBUIDORES'
 --AND TIPO NOT IN ('TIEMPO AIRE')
group by periodo_pago, canal, negocio, tipo
) as SourceTable
PIVOT (sum(comision) FOR PERIODO_PAGO in ([201810], [201811],[201812],[201901],[201902],[201903],[201904])) AS PivotTable

--Con cantidades
select canal, tipo, [201810],[201811],[201812],[201901],[201902],[201903]
from (
select periodo_pago, canal, negocio, tipo, sum(CANTIDAD) cantidad
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones 
where periodo_pago between '201810' and '201903'
 and negocio = 'MULTIMEDIA'
 and canal = 'CORPORATIVO'
group by periodo_pago, canal, negocio, tipo
) as SourceTable
PIVOT (sum(cantidad) FOR PERIODO_PAGO in ([201810], [201811],[201812],[201901],[201902],[201903])) AS PivotTable


--Por Ratio
select canal, tipo, [201810],[201811],[201812],[201901],[201902],[201903]
from (
select periodo_pago, canal, negocio, tipo, (sum(comision)/sum(CANTIDAD)) cantidad
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones 
where periodo_pago between '201810' and '201903'
 and negocio = 'MULTIMEDIA'
 and canal = 'CORPORATIVO'
group by periodo_pago, canal, negocio, tipo
) as SourceTable
PIVOT ( FOR PERIODO_PAGO in ([201810], [201811],[201812],[201901],[201902],[201903])) AS PivotTable



select canal,[201810],[201811],[201812],[201901],[201902] 
from (
select periodo_pago, canal, negocio, sum(comision) comision 
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones 
where periodo_pago between '201810' and '201902'
 and negocio = 'PREPAGO'
group by periodo_pago, canal, negocio
) as SourceTable
PIVOT (sum(comision) FOR PERIODO_PAGO in ([201810], [201811],[201812],[201901],[201902])) AS PivotTable





SELECT distinct PERIODO_PAGO, CANAL, SUB_CANAL from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones WHERE SUB_CANAL LIKE '%corp%' AND NEGOCIO = 'POSPAGO'

update DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones set CANAL = 'CORPORATIVO' WHERE SUB_CANAL LIKE '%corp%' AND NEGOCIO = 'POSPAGO' AND PERIODO_PAGO = '201902'

update DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones set CANAL = 'DISTRIBUIDORES' WHERE CANAL= 'DISTRIBUIDOR' AND NEGOCIO = 'MULTIMEDIA' AND PERIODO_PAGO = '201904'



select TIPO, SUM(CANTIDAD) TOTAL_CANT, SUM(COMISION) COMISION 
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones 
where PERIODO_PAGO = '201903' 
and NEGOCIO = 'MULTIMEDIA' AND CANAL = 'CORPORATIVO'
GROUP BY TIPO



SELECT *
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones 
where periodo_pago between '201903' and '201903'
 and negocio = 'PREPAGO'
 and canal = 'DISTRIBUIDORES'
 AND TIPO IS NULL
 
 
 UPDATE A
 SET A.TIPO = 'ESQUEMA TAE'
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where periodo_pago between '201902' and '201902'
 and negocio = 'PREPAGO'
 and canal = 'DISTRIBUIDORES'
 AND TIPO_COMISION = 'TIEMPO AIRE'




SELECT * FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones WHERE PERIODO_PAGO = '201902' AND NEGOCIO = 'POSPAGO' and canal = 'ALIADOS'

--DELETE FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones WHERE PERIODO_PAGO = '201902' AND NEGOCIO = 'POSPAGO'



SELECT DISTINCT TIPO_COMISION, TIPO FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones WHERE NEGOCIO = 'POSPAGO' AND PERIODO_PAGO = '201902' AND TIPO IS NULL




--POSPAGO Y MULTIMEDIA
UPDATE A
SET A.TIPO = CASE 
				WHEN A.TIPO_COMISION LIKE '%ACTIVAC%' THEN 'VENTAS'
				WHEN A.TIPO_COMISION LIKE '%VENTA%' THEN 'VENTAS'
				WHEN A.TIPO_COMISION LIKE '%BONO%' THEN 'BONOS'
				WHEN A.TIPO_COMISION LIKE '%CLOUD%' THEN 'CLOUD'
				WHEN A.TIPO_COMISION LIKE '%DESCUENTO%' THEN 'DESCUENTOS'
				WHEN A.TIPO_COMISION LIKE '%PERMANENCIA%' THEN 'BONOS'
				WHEN A.TIPO_COMISION LIKE '%RENOVACI%' THEN 'RENOVACIONES'
				WHEN A.TIPO_COMISION LIKE '%UP%SELL%' THEN 'UPSELL'
				WHEN A.TIPO_COMISION LIKE '%SVA%' THEN 'SVA'
				WHEN A.TIPO_COMISION LIKE '%EQUIPO%ADICIO%' THEN 'PAQUETES MULTIMEDIA'
				ELSE A.TIPO
			 END
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones A
WHERE NEGOCIO = 'MULTIMEDIA' 
	AND PERIODO_PAGO = '201904' 
	AND TIPO IS NULL
	
	
--PREPAGO
UPDATE A
SET A.TIPO = CASE 
				WHEN A.TIPO_COMISION LIKE '%BAJAS%DE%PRECIO%' THEN 'BAJAS DE PRECIO'
				WHEN A.TIPO_COMISION LIKE '%ACTIVACION%' THEN 'ACTIVACIONES'
				WHEN A.TIPO_COMISION LIKE '%MANTENIMIENTO%' THEN 'MANTENIMIENTO'
				WHEN A.TIPO_COMISION LIKE '%COMISION%POR%METAS%%' THEN 'BONOS'
				WHEN A.TIPO_COMISION LIKE '%SVA%' THEN 'COMISION POR SVA'
				WHEN A.TIPO_COMISION LIKE '%COMPLEMENTO%' THEN 'COMPLEMENTOS'
				WHEN A.TIPO_COMISION LIKE '%COMPRA%TERMINAL%' THEN 'COMPRA TERMINAL'
				WHEN A.TIPO_COMISION LIKE '%REINTEGRO%ORGA%%' THEN 'REINTEGRO ORGA'
				WHEN A.TIPO_COMISION LIKE '%TIEMPO AIRE%' THEN 'ESQUEMA TAE'			
				ELSE A.TIPO
			 END
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones A
WHERE NEGOCIO = 'PREPAGO' 
	AND PERIODO_PAGO = '201905' 
	AND TIPO IS NULL
	
SELECT DISTINCT TIPO_COMISION, TIPO
	FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones A
WHERE NEGOCIO = 'PREPAGO' 
	AND PERIODO_PAGO = '201904' 
	AND TIPO IS NULL
ORDER BY TIPO_COMISION





SELECT * FROM DM_COMISV_POSPAGO.dbo.FactPospagoDescuentos where PERIODO_DESCUENTO = '201902' and TIPOTRANS_ID is null

SELECT * FROM DM_COMISV_POSPAGO.dbo.FactPospagoDescuentos where PERIODO_DESCUENTO = '201903' and TIPOTRANS_ID is null



SELECT DISTINCT NEGOCIO, PERIODO_PAGO FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones A WHERE TIPO IS NULL


SELECT 
* FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones A
 WHERE TIPO IS NULL
 
 
 SELECT * FROM PagoHistoricoComisiones WHERE PERIODO_PAGO = '201906' AND NEGOCIO = 'MULTIMEDIA' AND TIPO = 'EQUIPOS ADICIONALES'
 
 
  UPDATE PagoHistoricoComisiones SET TIPO = 'VENTAS' WHERE PERIODO_PAGO = '201906' AND NEGOCIO = 'MULTIMEDIA' AND TIPO = 'VENTA';
  
  UPDATE PagoHistoricoComisiones SET TIPO = 'PAQUETES MULTIMEDIA' WHERE PERIODO_PAGO = '201906' AND NEGOCIO = 'MULTIMEDIA' AND TIPO = 'EQUIPOS ADICIONALES';
  
  
  
  SELECT * FROM PagoHistoricoComisiones WHERE PERIODO_PAGO = '201905' AND NEGOCIO = 'PREPAGO' AND TIPO LIKE  '%TIEMPO%'
  
  update PagoHistoricoComisiones set TIPO = 'ESQUEMA TAE' WHERE PERIODO_PAGO = '201906' AND NEGOCIO = 'PREPAGO' AND TIPO_COMISION LIKE  '%TIEMPO%'
  
update a
set A.NOMBRE_ACREEDOR = b.ACREEDOR_NOMBRE
  FROM PagoHistoricoComisiones A
	INNER JOIN DM_COMISV_POSPAGO.dbo.DimAcreedor  b on b.ACREEDOR_ID = a.CODIGO_ACREEDOR