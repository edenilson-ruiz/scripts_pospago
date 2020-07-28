DECLARE @periodo_pago varchar(6)
DECLARE @periodo_corte varchar(6)
DECLARE @acreedor_id varchar(50)

set @periodo_corte = '202005'
set @periodo_pago = convert(varchar(6),dateadd(m,2,convert(datetime,@periodo_corte+'01')),112)	

--select top 1 * from PagoPospagoConsolidadoDEXCorpo where periodo_pago = @periodo_pago

insert into PagoPospagoCambiosDePlanDEXCorpo
SELECT @periodo_pago PERIODO_PAGO
	,A.PERIODO
	,A.FECHA FECHA_ID
	,B.DEALER_CODE
	,B.DEALER_NAME
	,B.DISTRIBUIDOR
	,B.CANAL
	,B.SUB_CANAL
	,B.ACREEDOR_ID
	,A.CUSTOMER_ID
	,A.DN_NUM
	,A.CO_ID
	,A.NOMBRE_CLIENTE
	,A.APELLIDO_CLIENTE
	,A.NOMBRE_COMPLETO
	,A.NOMBRE_PLAN_ACT
	,A.NOMBRE_PLAN_ANT
	,CASE
		WHEN LOWER(A.NOMBRE_PLAN_ACT) LIKE '%BOLS_N%' AND LOWER(A.NOMBRE_PLAN_ACT) LIKE '%A' THEN 'CORP BOLSON A'
		WHEN LOWER(A.NOMBRE_PLAN_ACT) LIKE '%BOLS_N%' AND LOWER(A.NOMBRE_PLAN_ACT) LIKE '%B' THEN 'CORP NORMAL'
		WHEN LOWER(A.NOMBRE_PLAN_ACT) LIKE '%AVI%' THEN 'CORP NORMAL'
		ELSE 'CORP NORMAL'
	 END TIPO_PLAN
	,CASE
		WHEN UPPER(A.NOMBRE_PLAN_ACT) LIKE '%SIN TERM%' THEN 'APORTADO'
		WHEN UPPER(A.NOMBRE_PLAN_ACT) LIKE '%SIN EQUIP%' THEN 'APORTADO'
		ELSE 'CON EQUIPO'
	 END TIPO_CONTRATO
	,A.RENTA_MENSUAL_ACT
	,A.RENTA_MENSUAL_ANT
	,A.CARGOS_AVI_ACT
	,A.CARGOS_AVI_ANT
	,(SUM(RENTA_MENSUAL_ACT+CARGOS_AVI_ACT) OVER (PARTITION BY A.PERIODO, B.DISTRIBUIDOR)/1.13) TOTAL_REVENUE_VENTA
	,0 META
	,0 ALCANCE_META
	,1 UNIDAD_GLOBAL
	,1 UNIDAD_APLICA
	,'SI' APLICA
	,0 FACT_PAGADAS
	,SUM(1) OVER (PARTITION BY A.PERIODO, B.DISTRIBUIDOR) TOTAL_APLICAN
	,SUM(1) OVER (PARTITION BY A.PERIODO, B.DISTRIBUIDOR) TOTAL_UNIDADES
	,0 EFECTIVIDAD_VENTAS
	,1 FACTOR
	,(A.DIFERENCIAL_RENTA) COMISION
	,(A.DIFERENCIAL_RENTA/1.13) COMISION_SIN_IVA 
	,c.TIPOTRANS_ID
	,c.CUENTA_SAP
	,c.CENTRO_COSTO_SAP
	,c.TIPOTRANS_DESC
	,c.NEGOCIO_ID
	,d.NEGOCIO_NOMBRE 
FROM DM_COMISV_POSPAGO.dbo.FactPospagoCambiosDePlan a
	inner join DM_COMISV_POSPAGO.dbo.DimDealer b on b.dealer_code = a.dealer_code
	inner join DM_COMISV_POSPAGO.dbo.DimTipoTransaccion c on c.TIPOTRANS_ID = 20
	inner join DM_COMISV_POSPAGO.dbo.DimNegocio d on d.NEGOCIO_ID = c.NEGOCIO_ID
where a.periodo = @periodo_corte
 and a.DIFERENCIAL_RENTA > 0
 and a.FECHA between CONVERT(varchar(8),b.fecha_ini,112) and CONVERT(varchar(8),ISNULL(b.fecha_fin,getdate()),112) 
 --and b.CANAL = 'CORPORATIVO'
 --and b.SUB_CANAL like '%Corp%'
 --and b.distribuidor like '%ACCE%'
 and a.CO_ID in (
 '14753839',
'14753880',
'14753809',
'14753891',
'14753889',
'14753807',
'14753860',
'14753850',
'14753862',
'14753806',
'14753858',
'14753808',
'14753823',
'14753878',
'14753853',
'14753824',
'14753825',
'14753822',
'14753832',
'14753883',
'14753852',
'14753882',
'14753845',
'14753815',
'14753874',
'14753869',
'14753804',
'14753811',
'14753864',
'14753818',
'14753817',
'14753800',
'14753885',
'14753887',
'14753893'
 )
 
 /*
 SELECT * FROM DM_COMISV_POSPAGO.dbo.FactPospagoCambiosDePlan a WHERE CO_ID = '13052228'
 
  UPDATE A 
  SET A.DEALER_CODE = 'DVCES.DC14-041397806'
	,A.DEALER_NAME = 'VANESSA LISSETTE BRAND HENRIQUEZ (DC14)'
  FROM DM_COMISV_POSPAGO.dbo.FactPospagoCambiosDePlan a 
  WHERE CO_ID = '13052228'
  
  SELECT * FROM dIMdEALER WHERE DEALER_CODE = 'DVCES.DC14-041397806'
  
  
  SELECT * FROM DimTipoTransaccion where negocio_id = 1 order by tipotrans_id
  
  
  insert into DimTipoTransaccion values (20,'Cambios de plan',13,'Movil Pospago','0309C00026','6102220006',1)
  
  SELECT TOP 10 * FROM DM_COMISV_POSPAGO.dbo.FactPospagoCambiosDePlan a WHERE PERIODO = '201812'
  
  DROP TABLE PagoPospagoCambiosDePlanDEXCorpo
  
*/

 --SELECT nombre_plan_act FROM DM_COMISV_POSPAGO.dbo.FactPospagoCambiosDePlan WHERE NOMBRE_PLAN_ACT LIKE '%SIN%' group by NOMBRE_PLAN_ACT order by NOMBRE_PLAN_ACT
 
