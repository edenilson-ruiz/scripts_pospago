DECLARE @p_periodo_pago varchar(6)
DECLARE @p_periodo_recalculo varchar(6)
DECLARE @p_distribuidor varchar(50) 

set @p_periodo_pago			= '202003'
set @p_periodo_recalculo	= '202001'
set @p_distribuidor			= 'E-SMART'

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
      ,isnull(A.[COMISION],0)-isnull(B.COMISION,0) COMISION
      ,isnull(A.[COMISION_SIN_IVA],0)-isnull(B.COMISION_SIN_IVA,0) COMISION_SIN_IVA
      ,39 [TIPOTRANS_ID]
      ,A.[NEGOCIO_ID]
      ,A.[PRORRATEO]     
  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoVentasDEXCorpoRecalculo] A
	LEFT JOIN [DM_COMISV_POSPAGO].[dbo].[PagoPospagoVentasDEXCorpo] B ON B.CO_ID = A.CO_ID AND B.PERIODO = A.PERIODO and B.DISTRIBUIDOR = A.DISTRIBUIDOR
WHERE A.PERIODO = @p_periodo_recalculo
 AND A.DISTRIBUIDOR = @p_distribuidor
 AND isnull(A.COMISION_SIN_IVA,0) != isnull(B.COMISION_SIN_IVA,0)
 
 
 
 --RECALCULO DE BONO POR VOLUMEN DISTRIBUIDORES CORPORATIVOS
 INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoBonoPorVolumenDEXCorpo
 SELECT '202003' [PERIODO_PAGO]
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
      ,A.[COMISION]-B.COMISION COMISION
      ,A.[COMISION_SIN_IVA]-B.COMISION_SIN_IVA COMISION_SIN_IVA
      ,41 [TIPOTRANS_ID]
      ,A.CLASI_PLAN
  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoBonoPorVolumenDEXCorpoRecalculo] A
	LEFT JOIN [DM_COMISV_POSPAGO].[dbo].[PagoPospagoBonoPorVolumenDEXCorpo] B ON B.CO_ID = A.CO_ID AND B.PERIODO = A.PERIODO and B.DISTRIBUIDOR = A.DISTRIBUIDOR
WHERE A.PERIODO = @p_periodo_recalculo
 AND A.DISTRIBUIDOR = @p_distribuidor
 AND A.COMISION_SIN_IVA != B.COMISION_SIN_IVA
 
 
 --SELECT * FROM PagoPospagoVentasDEXCorpo where PERIODO_PAGO = '202003' and DISTRIBUIDOR like '%E-SMART%' ORDER BY PERIODO
  
 --SELECT * FROM PagoPospagoVentasDEXCorpoRecalculo where CO_ID = '14596795'
 
 --SELECT * FROM PagoPospagoVentasDEXCorpo where CO_ID = '14596795'
 
 --SELECT * FROM PagoPospagoVentasDEXCorpo where CO_ID = '14596795'
 
 
-- select * from PagoPospagoVentasDEXCorpo where PERIODO_PAGO = '202003' and DISTRIBUIDOR like '%E-SMART%' and PERIODO = '202001'
 
 --delete PagoPospagoVentasDEXCorpo where PERIODO_PAGO = '202003' and DISTRIBUIDOR like '%E-SMART%' and PERIODO = '202001'
 
 --select * from PagoPospagoBonoPorVolumenDEXCorpo where PERIODO_PAGO = '202003' and DISTRIBUIDOR like '%E-SMART%' and PERIODO = '202001'
 


