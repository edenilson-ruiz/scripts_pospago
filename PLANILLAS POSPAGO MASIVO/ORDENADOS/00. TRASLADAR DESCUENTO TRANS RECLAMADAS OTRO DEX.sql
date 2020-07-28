select *
from FactPospagoVentas a
inner join DimDealer b on b.DEALER_CODE = a.DEALER_CODE
where CO_ID in (
'13659618',
'13659246'
) and PERIODO = '201901'
 and a.FECHA_ID between CONVERT(varchar(8),b.fecha_ini,112) and CONVERT(varchar(8),isnull(b.FECHA_FIN,getdate()),112)
 

INSERT INTO FactPospagoDescuentos
select '201903' PERIODO_DESCUENTO
	, PERIODO
	, CO_ID
	, CUSTOMER_ID
	, DN_NUM
	, DEALER_CODE
	, 'Venta reclamada por Otro Dealer' MOTIVO
	, 0 MONTO_EQUIPOS
	, 0 MONTO_FACTURAS
	, COMISION MONTO_COMISION
	, 'MOVIL' NEGOCIO
	, 'ALTAS' SEGMENTO
	, 37 TIPOTRANS_ID
	, ACREEDOR_ID
	, CANAL 
from PagoPospagoConsolidadoDEXMasivo
where co_id in ( 
'13659618',
'13659246'
)
