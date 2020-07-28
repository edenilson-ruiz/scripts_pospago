select distinct TIPO_COMISION, TIPO from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones where PERIODO_PAGO = '201908' and NEGOCIO = 'MULTIMEDIA' AND TIPO IS NULL

select distinct TIPO_COMISION, TIPO from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones where PERIODO_PAGO = '201902' and NEGOCIO = 'POSPAGO' and TIPO is null

select distinct CANAL, TIPO_COMISION from DM_OPERACIONES_SV.dbo.FactHistoricoComisiones where PERIODO_PAGO = '201902' and NEGOCIO = 'POSPAGO'

select distinct CANAL, TIPO_COMISION from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones where PERIODO_PAGO = '201902' and NEGOCIO = 'POSPAGO'

--delete FROM PagoHistoricoComisiones where PERIODO_PAGO = '201902' and NEGOCIO = 'POSPAGO' and SUB_CANAL in ('Agencia Tercerizada','Telemarketing')

/*====================================================================================
GENERAL
====================================================================================*/
update a
set A.SUB_CANAL = 'Distribuidor Masivo'
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones a
WHERE SUB_CANAL LIKE '%distri%masivo%'

update a
set A.SUB_CANAL = 'Distribuidor Corp'
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones a
WHERE SUB_CANAL LIKE '%distri%corp%'

update a
set A.SUB_CANAL = 'Agencia Tercerizada'
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones a
WHERE SUB_CANAL LIKE '%agencia%terce%'


update a
set A.SUB_CANAL = 'Telemarketing'
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones a
WHERE CANAL LIKE '%aliado%'

/*====================================================================================
	POSPAGO
====================================================================================*/

DECLARE @periodo_proce varchar(6)
DECLARE @negocio varchar(20)

set @periodo_proce = '202001'
set @negocio = 'POSPAGO'

--ACTUALIZANDO TIPO DE TRANSACCION A NIVEL GENERAL
update A
set A.TIPO = CASE 
			WHEN A.TIPO_COMISION LIKE '%Descuentos%'		THEN 'DESCUENTOS'
			WHEN A.TIPO_COMISION LIKE '%Desc%'				THEN 'DESCUENTOS'
			WHEN A.TIPO_COMISION LIKE '%Permanencia%'		THEN 'BONOS'
			WHEN A.TIPO_COMISION LIKE '%Renovaciones%'		THEN 'RENOVACIONES'
			WHEN A.TIPO_COMISION LIKE '%Up%Sell%'			THEN 'UPSELL'
			WHEN A.TIPO_COMISION LIKE '%Venta%'				THEN 'VENTAS'
			WHEN A.TIPO_COMISION LIKE '%Clawback%'			THEN 'CLAWBACK'
			WHEN A.TIPO_COMISION LIKE '%Equipo%Adiciona%'	THEN 'PAQUETES MULTIMEDIA'
			WHEN A.TIPO_COMISION LIKE '%Bono X Volumen%'	THEN 'BONOS'
			WHEN A.TIPO_COMISION LIKE '%CRUCE%CUENTA%'		THEN 'CRUCE DE CUENTA'
           END 
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @periodo_proce
 AND A.NEGOCIO = @negocio
 --AND A.TIPO IS NULL	
 
/*====================================================================================
	MULTIMEDIA
====================================================================================*/

DECLARE @mm_periodo_proce varchar(6)
DECLARE @mm_negocio varchar(20)

set @mm_periodo_proce = '202001'
set @mm_negocio = 'MULTIMEDIA'

--ACTUALIZANDO TIPO DE TRANSACCION A NIVEL GENERAL
update A
set A.TIPO = CASE 
			WHEN A.TIPO_COMISION LIKE '%Descuentos%'		THEN 'DESCUENTOS'
			WHEN A.TIPO_COMISION LIKE '%Desc%'				THEN 'DESCUENTOS'
			WHEN A.TIPO_COMISION LIKE '%Permanencia%'		THEN 'BONOS'
			WHEN A.TIPO_COMISION LIKE '%Renovaciones%'		THEN 'RENOVACIONES'
			WHEN A.TIPO_COMISION LIKE '%Up%Sell%'			THEN 'UPSELL'
			WHEN A.TIPO_COMISION LIKE '%Venta%'				THEN 'VENTAS'
			WHEN A.TIPO_COMISION LIKE '%Clawback%'			THEN 'CLAWBACK'
			WHEN A.TIPO_COMISION LIKE '%Equipo%Adiciona%'	THEN 'PAQUETES MULTIMEDIA'
			WHEN A.TIPO_COMISION LIKE '%Bono X Volumen%'	THEN 'BONOS'
			WHEN A.TIPO_COMISION LIKE '%CRUCE%CUENTA%'		THEN 'CRUCE DE CUENTA'
			WHEN A.TIPO_COMISION LIKE '%complemento%'		THEN 'COMPLEMENTO'
			WHEN A.COMISION < 0 THEN 'DESCUENTO'
           END 
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @mm_periodo_proce
 AND A.NEGOCIO = @mm_negocio
 --AND A.TIPO IS NULL	
	
/*====================================================================================
	PREPAGO
====================================================================================*/
DECLARE @pre_periodo_proce varchar(6)
DECLARE @pre_negocio varchar(20)

set @pre_periodo_proce = '202001'
set @pre_negocio = 'PREPAGO'

update A
set A.TIPO = 'ESQUEMA TAE'
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @pre_periodo_proce
	and A.NEGOCIO = @pre_negocio
	and A.TIPO_COMISION = 'TIEMPO AIRE'
	--AND TIPO IS NULL
	
update A
set A.TIPO = 'MANTENIMIENTO'
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @pre_periodo_proce
	and A.NEGOCIO = @pre_negocio
	and A.TIPO_COMISION LIKE '%MANTENIMIENTO%'
	--AND TIPO IS NULL
	
	
update A
set A.TIPO = 'ACTIVACIONES'
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @pre_periodo_proce
	and A.NEGOCIO = @pre_negocio
	and A.TIPO_COMISION LIKE '%ACTIVACIO%'
	--AND TIPO IS NULL

update A
set A.TIPO = 'BAJAS DE PRECIO'
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @pre_periodo_proce
	and A.NEGOCIO = @pre_negocio
	and A.TIPO_COMISION LIKE '%BAJA%PRECIO%'
	AND TIPO IS NULL
	
update A
set A.TIPO = 'BONOS'
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @pre_periodo_proce
	and A.NEGOCIO = @pre_negocio
	and A.TIPO_COMISION LIKE '%COMISION%META%'
	--AND TIPO IS NULL


update A
set A.TIPO = 'COMISION POR SVA'
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @pre_periodo_proce
	and A.NEGOCIO = @pre_negocio
	and A.TIPO_COMISION LIKE '%COMISION%SVA%'
	--AND TIPO IS NULL
	
update A
set A.TIPO = 'COMPLEMENTOS'
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @pre_periodo_proce
	and A.NEGOCIO = @pre_negocio
	and A.TIPO_COMISION LIKE '%COMPLEMENT%'
	AND TIPO IS NULL

update A
set A.TIPO = 'COMPRA TERMINAL'
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @pre_periodo_proce
	and A.NEGOCIO = @pre_negocio
	and A.TIPO_COMISION LIKE '%COMPRA%TERMINAL%'
	--AND TIPO IS NULL
	
	
update A
set A.TIPO = 'REINTEGRO ORGA'
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @pre_periodo_proce
	and A.NEGOCIO = @pre_negocio
	and A.TIPO_COMISION LIKE '%REINTEGRO%ORGA%'
	--AND TIPO IS NULL

UPDATE a
SET A.CANAL = 'DISTRIBUIDORES'
	,a.SUB_CANAL = 'Distribuidor Masivo' 
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @pre_periodo_proce
 AND A.NEGOCIO = @pre_negocio
 and CANAL like '%MAYORISTAS%'

UPDATE a
SET A.CANAL = 'CADENAS'
	,a.SUB_CANAL = 'Cadenas Comerciales' 
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @pre_periodo_proce
 AND A.NEGOCIO = @pre_negocio  
 and SUB_CANAL like '%CADENA%'
 
 UPDATE a
SET A.CANAL = 'CADENAS'
	,a.SUB_CANAL = 'Cadenas de Telefonia (Kioscos)' 
from DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @pre_periodo_proce
 AND A.NEGOCIO = @pre_negocio
 AND CODIGO_ACREEDOR in ('700000010','700000134','700000149','700000154','700000157','700000158','700000159','700000160',
						 '700000161','700000178','700000179','700000186','700000195','700000203','700000225','700000405')
 
UPDATE a
SET A.CANAL = 'SEGMENTADA'
	,a.SUB_CANAL = 'Segmentada' 
FROM DM_OPERACIONES_SV.dbo.PagoHistoricoComisiones  A
where A.PERIODO_PAGO >= @pre_periodo_proce
 AND A.NEGOCIO = @pre_negocio
 AND TIPO_COMISION like '%SEGMENTA%'