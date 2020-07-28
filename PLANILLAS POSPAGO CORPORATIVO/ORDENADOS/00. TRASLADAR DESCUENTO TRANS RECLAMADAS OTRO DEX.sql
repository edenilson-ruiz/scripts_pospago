SELECT * FROM DimAcreedor WHERE Acreedor_id = '700000040'

select *
from FactPospagoVentas a
inner join DimDealer b on b.DEALER_CODE = a.DEALER_CODE
where CO_ID in (
'14702812',
'14702818',
'14702817',
'14702760',
'14702816',
'14702755',
'14702762'
) and PERIODO = '202002'
 and a.FECHA_ID between CONVERT(varchar(8),b.fecha_ini,112) 
					and CONVERT(varchar(8),isnull(b.FECHA_FIN,getdate()),112)
 
--VENTAS
INSERT INTO FactPospagoDescuentos(PERIODO_DESCUENTO
	,PERIODO
	,CO_ID
	,CUSTOMER_ID
	,DN_NUM
	,DEALER_CODE
	,MOTIVO
	,MONTO_EQUIPOS
	,MONTO_FACTURAS
	,MONTO_COMISION
	,NEGOCIO
	,SEGMENTO
	,TIPOTRANS_ID
	,ACREEDOR_ID
	,CANAL)
select '202004' PERIODO_DESCUENTO
	, PERIODO
	, CO_ID
	, CUSTOMER_ID
	, DN_NUM
	, DEALER_CODE
	, 'Transaccion reclamada por Otro Dealer ' + TIPOTRANS_DESC as MOTIVO
	, 0 MONTO_EQUIPOS
	, 0 MONTO_FACTURAS
	, COMISION_SIN_IVA MONTO_COMISION
	, 'MOVIL' NEGOCIO
	, 'ALTAS' SEGMENTO
	, 37 TIPOTRANS_ID
	, ACREEDOR_ID
	, CANAL
from PagoPospagoConsolidadoDEXCorpo 
where co_id in ( 
'14702812',
'14702818',
'14702817',
'14702760',
'14702816',
'14702755',
'14702762'
) and periodo = '202002'

--RENOVACIONES
INSERT INTO FactPospagoDescuentos(PERIODO_DESCUENTO
	,PERIODO
	,CO_ID
	,CUSTOMER_ID
	,DN_NUM
	,DEALER_CODE
	,MOTIVO
	,MONTO_EQUIPOS
	,MONTO_FACTURAS
	,MONTO_COMISION
	,NEGOCIO
	,SEGMENTO
	,TIPOTRANS_ID
	,ACREEDOR_ID
	,CANAL)
select '202004' PERIODO_DESCUENTO
	, PERIODO
	, CO_ID
	, CUSTOMER_ID
	, DN_NUM
	, DEALER_CODE
	, 'Transaccion reclamada por Otro Dealer ' + TIPOTRANS_DESC as MOTIVO
	, 0 MONTO_EQUIPOS
	, 0 MONTO_FACTURAS
	, COMISION_SIN_IVA MONTO_COMISION
	, 'MOVIL' NEGOCIO
	, 'RENOVACIONES' SEGMENTO
	, 37 TIPOTRANS_ID
	, ACREEDOR_ID
	, CANAL
from PagoPospagoConsolidadoDEXCorpo 
where CO_ID in ( 
'14698230',
'12278946',
'12278972'
) and periodo = '202002'

select * from FactPospagoDescuentos where periodo_descuento = '201903' and Acreedor_id = '700000044'


select * from FactPospagoDescuentos where PERIODO_DESCUENTO = '201905'

select * from FactPospagoDescuentosOtros where PERIODO_DESCUENTO = '201905' and Acreedor_id = '700000044'

select * from DimAcreedor where ACREEDOR_ID = '700000137'



select *
from FactPospagoVentas
where co_id in (
'13700395',
'13683381'
)


select *
from PagoPospagoConsolidadoDEXCorpo
where co_id in (
13316146
)





select * from FactPospagoDescuentos where PERIODO_DESCUENTO = '202003'

select * from DimAcreedor where ACREEDOR_ID = '700000038'

SELECT * FROM DimDealer WHERE DEALER_CODE = 'DVCES.DC06-039878668'



select * from PagoPospagoConsolidadoDEXCorpo where CO_ID in (14596795)

select * from PagoPospagoRenovacionesDEXCorpo where co_id = '12243293' and PERIODO = '202001'

select * from DimPlanesDEXCorpo where tmcode = 6974


select * from FactPospagoRenovaciones where CO_ID = '12243293' AND PERIODO = '202001'



UPDATE FactPospagoRenovaciones SET CO_EQU_TYPE = '357079102032151' where CO_ID = '12243293' AND PERIODO = '202001'

UPDATE PagoPospagoRenovacionesDEXCorpo SET CO_EQU_TYPE = '357079102032151' where CO_ID = '12243293' AND PERIODO = '202001'

