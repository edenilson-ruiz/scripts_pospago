DECLARE @p_periodo_pago varchar(6)
DECLARE @p_periodo_recalculo varchar(6)
DECLARE @p_distribuidor varchar(50) 

set @p_periodo_pago			= '202005'
set @p_periodo_recalculo	= '202003'
set @p_distribuidor			= 'SIGNO'

-- diferencias desde recalculo desde tabla pago hacia recalculo

 --RECALCULO DE VENTAS POSPAGO DISTRIBUIDORES CORPORATIVOS 
 INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXCorpo
 SELECT A.[PAIS_ID]
      ,A.[PAIS_ABRV]
      ,A.[PAIS_NOMBRE]
      ,A.[PLCODE]
      ,A.[PERIODO]
      ,@p_periodo_pago [PERIODO_PAGO]
      ,A.[FECHA_ID]
      ,A.[CO_ENTDATE]
      ,A.[CO_SIGNED]
      ,A.[CO_ACTIVATED]
      ,A.[CH_VALIDFROM]
      ,A.[CO_INSTALLED]
      ,A.[CO_EXPIR_DATE]
      ,A.[CH_REASON]
      ,A.[RAZON_ALTA]
      ,A.[BILLCYCLE]
      ,A.[CUSTOMER_ID]
      ,A.[CO_ID]
      ,A.[DN_NUM]
      ,A.[CARGOS_TOTAL_ALTA]
      ,A.[CARGOS_SERV_CORE]
      ,A.[CARGOS_DATOS]
      ,A.[CARGOS_AVI]
      ,A.[RENTA_COMISION]
      ,A.[FINAN_FLAG]
      ,A.[FINAN_CUOTA]
      ,A.[FINAN_MONTO]
      ,A.[MARCA]
      ,A.[MODELO]
      ,A.[ADQUIRIDO_VIA]
      ,A.[PLAZO_DESC]
      ,A.[PLAZO_NUM]
      ,A.[USERLASTMOD]
      ,A.[TIPO]
      ,A.[MODALIDAD]
      ,A.[TIPO_CONTRATO]
      ,A.[TMCODE]
      ,A.[CARGO_PAQUETE]
      ,A.[NOMBRE_PAQUETE]
      ,A.[NOMBRE_PLAN]
      ,A.[CD_SEQNO]
      ,A.[PORT_ID]
      ,A.[CO_ESTADO_ACT]
      ,A.[CO_ESTADO_ACT_DESC]
      ,A.[CO_ESTADO_ACT_FECHA]
      ,A.[NOMBRE_CLIENTE]
      ,A.[APELLIDO_CLIENTE]
      ,A.[NOMBRE_COMPLETO]
      ,A.[CATEGORIA_CLIENTE_ID]
      ,A.[CATEGORIA_CLIENTE_DESC]
      ,A.[DNI]
      ,A.[CODIGO_VENDEDOR]
      ,A.[VENTA]
      ,A.[FACT_PAGADAS]
      ,A.[FECHA_DATA]
      ,A.[FECHA_UPDATE]
      ,A.[DEALER_CODE]
      ,A.[DEALER_NAME]
      ,A.[DISTRIBUIDOR]
      ,A.[CANAL]
      ,A.[SUB_CANAL]
      ,A.[REGION]
      ,A.[TIPO_ALTA]
      ,A.[CLASI_PLAN]
      ,A.[TIPO_PLAN_ESQUEMA]
      ,A.[NUM_VENTA]
      ,A.[CANT]
      ,A.[FACTOR_VENTA]
      ,isnull(B.[COMISION],0)-isnull(A.COMISION,0) COMISION
      ,isnull(B.[COMISION_SIN_IVA],0)-isnull(A.COMISION_SIN_IVA,0) COMISION_SIN_IVA
      ,39 [TIPOTRANS_ID]
      ,A.[NEGOCIO_ID]
      ,A.[PRORRATEO]     
  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoVentasDEXCorpo] a
	LEFT JOIN [DM_COMISV_POSPAGO].[dbo].[PagoPospagoVentasDEXCorpoRecalculo] b ON B.CO_ID = A.CO_ID AND B.PERIODO = A.PERIODO and B.DISTRIBUIDOR = A.DISTRIBUIDOR AND isnull(A.COMISION_SIN_IVA,0) != isnull(B.COMISION_SIN_IVA,0)
WHERE A.PERIODO = @p_periodo_recalculo
 AND A.DISTRIBUIDOR = @p_distribuidor
 and a.co_id in (
 '14766567',
 '14766569'
 )
 
 

 
 --RECALCULO DE BONO POR VOLUMEN DISTRIBUIDORES CORPORATIVOS
 INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoBonoPorVolumenDEXCorpo
 SELECT @p_periodo_pago  [PERIODO_PAGO]
      ,A.[PERIODO]
      ,A.[FECHA_ID]
      ,A.[CO_ID]
      ,A.[TMCODE]
      ,A.[NOMBRE_PLAN]
      ,A.[TIPO_CONTRATO]
      ,A.[PLAZO_NUM]
      ,A.[DEALER_CODE]
      ,A.[DEALER_NAME]
      ,A.[DISTRIBUIDOR]
      ,A.[APLICA]
      ,A.[CANT_VENTA]
      ,A.[CANT_APLICA]
      ,A.[TOTAL_REVENUE]
      ,A.[META_LLAVE]
      ,A.[ALCANCE_META]
      ,isnull(B.[COMISION],0)-isnull(A.COMISION,0) COMISION
      ,isnull(B.[COMISION_SIN_IVA],0)-isnull(A.COMISION_SIN_IVA,0) COMISION_SIN_IVA
      ,41 [TIPOTRANS_ID]
      ,A.CLASI_PLAN
  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoBonoPorVolumenDEXCorpo] A
	LEFT JOIN [DM_COMISV_POSPAGO].[dbo].[PagoPospagoBonoPorVolumenDEXCorpoRecalculo] B ON B.CO_ID = A.CO_ID AND B.PERIODO = A.PERIODO and B.DISTRIBUIDOR = A.DISTRIBUIDOR AND isnull(A.COMISION_SIN_IVA,1) != isnull(B.COMISION_SIN_IVA,0)
WHERE A.PERIODO = @p_periodo_recalculo
 AND A.DISTRIBUIDOR = @p_distribuidor
 AND A.CO_ID IN ( 
 '14766567',
 '14766569'
 )
 
 
 
 /*
 
 --RENOVACIONES RECALCULO
 INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoRenovacionesDEXCorpo
 SELECT A.[TICKLER_NUMBER]
      ,A.[TICKLER_CODE]
      ,A.[CUSTOMER_ID]
      ,A.[CO_ID]
      ,A.[CREATED_DATE]
      ,A.[FECHA]
      ,A.[PERIODO]
      ,@p_periodo_pago  [PERIODO_PAGO]
      ,A.[MES_RENOV]
      ,A.[DIA]
      ,A.[DIA_SEMANA]
      ,A.[CREATED_BY]
      ,A.[TMCODE_ACT]
      ,A.[TMCODE_DATE_ACT]
      ,A.[CO_EQU_TYPE]
      ,A.[SHORT_DESCRIPTION]
      ,A.[PLCODE]
      ,A.[DN_ID]
      ,A.[DN_NUM]
      ,A.[DEALER_ID]
      ,A.[DN_STATUS]
      ,A.[SEQNO_ANT]
      ,A.[TMCODE_ANT]
      ,A.[TMCODE_DATE_ANT]
      ,A.[PROFILE_ID_ACT]
      ,A.[NOMBRE_PLAN_ACT]
      ,A.[CARGOS_TOTAL_FIDE_ACT]
      ,A.[CARGOS_SERV_CORE_ACT]
      ,A.[NOMBRE_PAQUETE_DAT_ACT]
      ,A.[CARGOS_DATOS_ACT]
      ,A.[CARGOS_AVI_ACT]
      ,A.[RENTA_MENSUAL_ACT]
      ,A.[NOMBRE_PLAN_ANT]
      ,A.[CARGOS_TOTAL_FIDE_ANT]
      ,A.[CARGOS_SERV_CORE_ANT]
      ,A.[NOMBRE_PAQUETE_DAT_ANT]
      ,A.[CARGOS_DATOS_ANT]
      ,A.[CARGOS_AVI_ANT]
      ,A.[RENTA_MENSUAL_ANT]
      ,A.[PROFILE_ID_ANT]
      ,A.[DIFERENCIAL_RENTA]
      ,A.[ANALISIS_DIFERENCIAL]
      ,A.[SITIO_RENOV_ID]
      ,A.[SITIO_RENOV_NOMBRE]
      ,A.[CUSTCODE]
      ,A.[CATEGORIA_CLIENTE_ID]
      ,A.[CATEGORIA_CLIENTE_NOMBRE]
      ,A.[MERCADO]
      ,A.[TIPO_NVO]
      ,A.[MODALIDAD_NVA]
      ,A.[NOMBRE_CLIENTE]
      ,A.[APELLIDO_CLIENTE]
      ,A.[NOMBRE_COMPLETO]
      ,A.[DEALER_CODE]
      ,A.[DEALER_NAME]
      ,A.[ESTADO_CO_ID_ACT]
      ,A.[RAZON_CO_ID_ACT]
      ,A.[FECHA_CO_ID_ACT]
      ,A.[FECHA_CARGA]
      ,A.[DISTRIBUIDOR]
      ,A.[CANAL]
      ,A.[SUB_CANAL]
      ,A.[REGION]
      ,A.[NUM_FIDE]
      ,A.[CANT_VENTAS]
      ,A.[TOTAL_REVENUE_VENTA]
      ,A.[META_LLAVE]
      ,40 [TIPOTRANS_ID]
      ,A.[PLAZO_CONTR_NUM]
      ,A.[UNIDAD]
      ,A.[FACTOR_FIDE]
      ,A.[ALCANCE]
      ,isnull(b.[COMISION],0)-isnull(a.COMISION,0) COMISION
      ,isnull(b.[COMISION_SIN_IVA],0)-isnull(a.COMISION_SIN_IVA,0) COMISION_SIN_IVA
      ,'Recalculo Renovacion' [TIPOTRANS_DESC]
      ,A.[ACREEDOR_ID]
      ,A.[ACREEDOR_NOMBRE]
      ,A.[CUENTA_SAP]
      ,A.[CENTRO_COSTO_SAP]
      ,A.[NEGOCIO_ID]
      ,A.[NEGOCIO_NOMBRE]
      ,A.[PRORRATEO]   
FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoRenovacionesDEXCorpo] A
	INNER JOIN [DM_COMISV_POSPAGO].[dbo].[PagoPospagoRenovacionesDEXCorpoRecalculo] B ON B.CO_ID = A.CO_ID AND B.PERIODO = A.PERIODO and B.DISTRIBUIDOR = A.DISTRIBUIDOR	
WHERE A.PERIODO = @p_periodo_recalculo
	AND A.DISTRIBUIDOR = @p_distribuidor
	AND isnull(A.COMISION_SIN_IVA,1) != isnull(B.COMISION_SIN_IVA,0)
*/
 
 SELECT CO_ID, NOMBRE_PLAN_ACT, RENTA_MENSUAL_ACT, CARGOS_AVI_ACT, ALCANCE, FACTOR_FIDE, COMISION, COMISION_SIN_IVA
 FROM PagoPospagoRenovacionesDEXCorpo
 WHERE CO_ID IN (
'11997511',
'11997525',
'11997517',
'11997519',
'11997513',
'11997522',
'10594140'
 ) AND PERIODO = '202002' ORDER BY CO_ID
 
 
 SELECT CO_ID, NOMBRE_PLAN_ACT, RENTA_MENSUAL_ACT, CARGOS_AVI_ACT, ALCANCE, FACTOR_FIDE, COMISION, COMISION_SIN_IVA
 FROM PagoPospagoRenovacionesDEXCorpoRecalculo
 WHERE CO_ID IN (
'11997511',
'11997525',
'11997517',
'11997519',
'11997513',
'11997522',
'10594140'
 ) AND PERIODO = '202002' ORDER BY CO_ID