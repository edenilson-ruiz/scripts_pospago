--SELECT * FROM DimAcreedor where acreedor_nombre_comercial like '%digitex%'
use DM_COMISV_POSPAGO

DECLARE @periodo_pago varchar(6)
DECLARE @periodo_corte varchar(6)
DECLARE @acreedor_id varchar(20)

set @periodo_corte = '202006'
set @periodo_pago = convert(varchar(6),dateadd(m,1,convert(datetime,@periodo_corte+'01')),112)	
set @acreedor_id = '800000147'

if @acreedor_id = ''
	begin
	
		DELETE DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoTMKNE WHERE PERIODO_PAGO = @periodo_pago

		--SELECT TOP 10 * FROM PagoPospagoConsolidadoTMKNE
		 
		INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoTMKNE 
		/*--------------------------------------------------------------------------------------------------------------------
			VENTAS
		--------------------------------------------------------------------------------------------------------------------*/
		SELECT
			 @periodo_pago PERIODO_PAGO
			,A.PERIODO
			,A.FECHA_ID
			,A.DEALER_CODE
			,A.DEALER_NAME
			,A.DISTRIBUIDOR
			,A.ACREEDOR_ID	
			,A.CANAL
			,A.CUSTOMER_ID
			,A.DN_NUM	
			,A.CO_ID
			,A.NOMBRE_CLIENTE
			,A.APELLIDO_CLIENTE
			,A.NOMBRE_COMPLETO
			,A.NOMBRE_PLAN
			,CASE 
				WHEN A.NOMBRE_PLAN LIKE '%PAGO%Y%LISTO%' THEN 'PAGO Y LISTO'
				WHEN A.NOMBRE_PLAN LIKE '%INTERNET%' THEN 'INTERNET MOVIL'
				WHEN A.NOMBRE_PLAN LIKE '%3G%' THEN 'INTERNET MOVIL'
				ELSE 'MOVIL'
			 END TIPO_PLAN
			,A.TIPO_CONTRATO
			,A.RENTA_COMISION RENTA_MENSUAL
			,'VENTA' TRANSACCION
			,SUM(A.RENTA_COMISION) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR ) TOTAL_REVENUE			
			,0 META	 				
			,0 ALCANCE_META_VENTA	
			,1 UNIDAD_GLOBAL
			,0 UNIDAD_APLICA_PERMA
			,'NO' APLICA_PERMA
			,ISNULL(A.FACT_PAGADAS	,0) FACT_PAGADAS
			,0 TOTAL_APLICAN_PERMA
			,COUNT(*) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR) TOTAL_UNIDADES
			,0 EFECTIVIDAD_VENTAS
			,A.FACTOR_VENTA FACTOR
			,A.COMISION
			,A.COMISION_SIN_IVA
			,GETDATE() FECHA_PROCESO
			,A.TIPO_TRANS_COMI_ID TIPOTRANS_ID 
			,A.PLAZO_NUM PLAZO_CONTRATO 
			,A.PRORRATEO --INTO PagoPospagoConsolidadoTMKNE
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoVentasTMKNE] A					
		  WHERE A.PERIODO_PAGO = @periodo_pago			

		
		
		/*--------------------------------------------------------------------------------------------------------------------
			PERMANENCIA
		--------------------------------------------------------------------------------------------------------------------*/
		
		INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoTMKNE 
		SELECT A.PERIODO_PAGO
				,A.PERIODO
				,A.FECHA_ID
				,A.DEALER_CODE
				,A.DEALER_NAME
				,A.DISTRIBUIDOR
				,A.ACREEDOR_ID
				,A.CANAL
				,A.CUSTOMER_ID
				,A.DN_NUM
				,A.CO_ID
				,B.NOMBRE_CLIENTE
				,B.APELLIDO_CLIENTE
				,B.NOMBRE_COMPLETO
				,A.NOMBRE_PLAN
				,A.TIPO_PLAN
				,A.TIPO_CONTRATO
				,A.RENTA_MENSUAL
				,A.TRANSACCION
				,A.TOTAL_REVENUE
				,ISNULL(A.META,0) META
				,ISNULL(A.ALCANCE_META_VENTA,0) ALCANCE_META_VENTA
				,A.UNIDAD_GLOBAL
				,A.UNIDAD_APLICA_PERMA
				,A.APLICA_PERMA
				,A.FACT_PAGADAS
				,A.TOTAL_APLICAN_PERMA
				,A.TOTAL_VENTAS TOTAL_UNIDADES
				,A.EFECTIVIDAD_VENTAS
				,A.FACTOR_PERMA FACTOR
				,A.COMISION
				,A.COMISION_SIN_IVA
				,GETDATE() FECHA_PROCESO
				,A.TIPOTRANS_ID
				,0 PLAZO_CONTRATO
				,1 PRORRATEO
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoPermanenciaTMKNE] A
			INNER JOIN [DM_COMISV_POSPAGO].[dbo].[FactPospagoVentas] b on b.co_id = a.co_id and b.fecha_id = A.FECHA_ID	
		  WHERE PERIODO_PAGO = @periodo_pago
		  
		  /*--------------------------------------------------------------------------------------------------------------------
			RENOVACIONES
		  --------------------------------------------------------------------------------------------------------------------*/
		  INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoTMKNE 
		  SELECT DISTINCT A.[PERIODO_PAGO]
			  ,A.[PERIODO]
			  ,A.[FECHA] FECHA_ID
			  ,A.[DEALER_CODE]
			  ,A.[DEALER_NAME]
			  ,A.[DISTRIBUIDOR]
			  ,A.[ACREEDOR_ID]
			  ,A.[CANAL]
			  ,A.[CUSTOMER_ID]
			  ,A.[DN_NUM]
			  ,A.[CO_ID]
			  ,A.[NOMBRE_CLIENTE]
			  ,A.[APELLIDO_CLIENTE]
			  ,A.[NOMBRE_COMPLETO]
			  ,A.[NOMBRE_PLAN_ACT]
			  ,A.MODALIDAD_NVA TIPO_PLAN
			  ,CASE 
				WHEN CO_EQU_TYPE LIKE '%APORTADO%' THEN 'APORTADO'
				ELSE 'CON EQUIPO'
			   END TIPO_CONTRATO
			  ,A.[RENTA_MENSUAL_ACT]
			  ,A.[TIPOTRANS_DESC] TRANSACCION
			  ,0 TOTAL_REVENUE
			  ,0 META
			  ,0 ALCANCE_META_VENTA
			  ,A.UNIDAD UNIDAD_GLOBAL
			  ,A.UNIDAD UNIDAD_APLICA_PERMA
			  ,0 APLICA_PERMA
			  ,0 FACT_PAGADAS
			  ,0 TOTAL_APLICAN_PERMA
			  ,SUM(UNIDAD) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR) TOTAL_UNIDADES
			  ,0 EFECTIVIDAD_VENTAS
			  ,A.[FACTOR_FIDE]
			  ,A.[COMISION]
			  ,A.[COMISION_SIN_IVA]
			  ,GETDATE() FECHA_PROCESO
			  ,A.[TIPOTRANS_ID]
			  ,A.PLAZO_CONTR_NUM PLAZO_CONTRATO
			  ,A.PRORRATEO
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoRenovacionesTMKNE]  A				
		  WHERE A.PERIODO_PAGO = @periodo_pago		   
		 
		  
		  /*--------------------------------------------------------------------------------------------------------------------
			TRANSACCIONES ADICIONALES, UPSELL VOS, UPSELL DATOS, SIN FRONTERAS Y FACEBOOK
		  --------------------------------------------------------------------------------------------------------------------*/	
		 INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoTMKNE 
		 SELECT A.[PERIODO_PAGO]
			  ,A.[PERIODO]
			  ,A.[FECHA_ID]
			  ,A.USERID [DEALER_CODE]
			  ,A.USERID [DEALER_NAME]
			  ,A.[DISTRIBUIDOR]
			  ,A.[ACREEDOR_ID]
			  ,'ALIADOS' CANAL
			  ,A.[CUSTOMER_ID]
			  ,A.[DN_NUM]
			  ,A.[CO_ID]
			  ,A.[NOMBRES_CLIENTE]
			  ,A.[APELLIDOS_CLIENTE]
			  ,A.NOMBRES_CLIENTE [NOMBRE_COMPLETO]
			  ,A.[NOMBRE_PLAN_ACT]			
			  ,'MOVIL' TIPO_PLAN
			  ,'MOVIL' TIPO_CONTRATO
			  ,A.CUOTA_ACT [RENTA_MENSUAL_ACT]			  
			  ,A.TRANSACCION
			  ,0 TOTAL_REVENUE_VENTA
			  ,0 META
			  ,0 ALCANCE_META
			  ,1 UNIDAD_GLOBAL
			  ,1 UNIDAD_APLICA
			  ,'SI' APLICA
			  ,0 FACT_PAGADAS
			  ,0 [TOTAL_APLICAN]
			  ,COUNT(*) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR, A.TRANSACCION) TOTAL_UNIDADES
			  ,0 [EFECTIVIDAD_VENTAS]
			  ,1 [FACTOR]
			  ,A.[COMISION]
			  ,A.[COMISION_SIN_IVA]
			  ,GETDATE() FECHA_PROCESO
			  ,A.[TIPOTRANS_ID]
			  ,0 PLAZO_CONTRATO
			  ,1 PRORRATEO
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoAdicionalesTMKNE] A
		  WHERE A.PERIODO_PAGO = @periodo_pago		
	end
else 
	begin
	
		DELETE DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoTMKNE WHERE PERIODO_PAGO = @periodo_pago and ACREEDOR_ID = @acreedor_id;

		--SELECT TOP 10 * FROM PagoPospagoConsolidadoTMKNE
		 
		INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoTMKNE 
		/*--------------------------------------------------------------------------------------------------------------------
			VENTAS
		--------------------------------------------------------------------------------------------------------------------*/
		SELECT
			 @periodo_pago PERIODO_PAGO
			,A.PERIODO
			,A.FECHA_ID
			,A.DEALER_CODE
			,A.DEALER_NAME
			,A.DISTRIBUIDOR
			,A.ACREEDOR_ID	
			,A.CANAL
			,A.CUSTOMER_ID
			,A.DN_NUM	
			,A.CO_ID
			,A.NOMBRE_CLIENTE
			,A.APELLIDO_CLIENTE
			,A.NOMBRE_COMPLETO
			,A.NOMBRE_PLAN
			,CASE 
				WHEN A.NOMBRE_PLAN LIKE '%PAGO%Y%LISTO%' THEN 'PAGO Y LISTO'
				WHEN A.NOMBRE_PLAN LIKE '%INTERNET%' THEN 'INTERNET MOVIL'
				WHEN A.NOMBRE_PLAN LIKE '%3G%' THEN 'INTERNET MOVIL'
				ELSE 'MOVIL'
			 END TIPO_PLAN
			,A.TIPO_CONTRATO
			,A.RENTA_COMISION RENTA_MENSUAL
			,'VENTA' TRANSACCION
			,SUM(A.RENTA_COMISION) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR ) TOTAL_REVENUE			
			,0 META	 				
			,0 ALCANCE_META_VENTA	
			,1 UNIDAD_GLOBAL
			,0 UNIDAD_APLICA_PERMA
			,'NO' APLICA_PERMA
			,ISNULL(A.FACT_PAGADAS	,0) FACT_PAGADAS
			,0 TOTAL_APLICAN_PERMA
			,COUNT(*) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR) TOTAL_UNIDADES
			,0 EFECTIVIDAD_VENTAS
			,A.FACTOR_VENTA FACTOR
			,A.COMISION
			,A.COMISION_SIN_IVA
			,GETDATE() FECHA_PROCESO
			,A.TIPO_TRANS_COMI_ID TIPOTRANS_ID 
			,A.PLAZO_NUM PLAZO_CONTRATO 
			,A.PRORRATEO --INTO PagoPospagoConsolidadoTMKNE
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoVentasTMKNE] A					
		  WHERE A.PERIODO_PAGO = @periodo_pago			
		  	AND ACREEDOR_ID = @acreedor_id;
		
		
		/*--------------------------------------------------------------------------------------------------------------------
			PERMANENCIA
		--------------------------------------------------------------------------------------------------------------------*/
		
		INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoTMKNE 
		SELECT A.PERIODO_PAGO
				,A.PERIODO
				,A.FECHA_ID
				,A.DEALER_CODE
				,A.DEALER_NAME
				,A.DISTRIBUIDOR
				,A.ACREEDOR_ID
				,A.CANAL
				,A.CUSTOMER_ID
				,A.DN_NUM
				,A.CO_ID
				,B.NOMBRE_CLIENTE
				,B.APELLIDO_CLIENTE
				,B.NOMBRE_COMPLETO
				,A.NOMBRE_PLAN
				,A.TIPO_PLAN
				,A.TIPO_CONTRATO
				,A.RENTA_MENSUAL
				,A.TRANSACCION
				,A.TOTAL_REVENUE
				,ISNULL(A.META,0) META
				,ISNULL(A.ALCANCE_META_VENTA,0) ALCANCE_META_VENTA
				,A.UNIDAD_GLOBAL
				,A.UNIDAD_APLICA_PERMA
				,A.APLICA_PERMA
				,A.FACT_PAGADAS
				,A.TOTAL_APLICAN_PERMA
				,A.TOTAL_VENTAS TOTAL_UNIDADES
				,A.EFECTIVIDAD_VENTAS
				,A.FACTOR_PERMA FACTOR
				,A.COMISION
				,A.COMISION_SIN_IVA
				,GETDATE() FECHA_PROCESO
				,A.TIPOTRANS_ID
				,0 PLAZO_CONTRATO
				,1 PRORRATEO
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoPermanenciaTMKNE] A
			INNER JOIN [DM_COMISV_POSPAGO].[dbo].[FactPospagoVentas] b on b.co_id = a.co_id and b.fecha_id = A.FECHA_ID	
		  WHERE PERIODO_PAGO = @periodo_pago
		  	AND ACREEDOR_ID = @acreedor_id;
		  
		  /*--------------------------------------------------------------------------------------------------------------------
			RENOVACIONES
		  --------------------------------------------------------------------------------------------------------------------*/
		  INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoTMKNE 
		  SELECT DISTINCT A.[PERIODO_PAGO]
			  ,A.[PERIODO]
			  ,A.[FECHA] FECHA_ID
			  ,A.[DEALER_CODE]
			  ,A.[DEALER_NAME]
			  ,A.[DISTRIBUIDOR]
			  ,A.[ACREEDOR_ID]
			  ,A.[CANAL]
			  ,A.[CUSTOMER_ID]
			  ,A.[DN_NUM]
			  ,A.[CO_ID]
			  ,A.[NOMBRE_CLIENTE]
			  ,A.[APELLIDO_CLIENTE]
			  ,A.[NOMBRE_COMPLETO]
			  ,A.[NOMBRE_PLAN_ACT]
			  ,A.MODALIDAD_NVA TIPO_PLAN
			  ,CASE 
				WHEN CO_EQU_TYPE LIKE '%APORTADO%' THEN 'APORTADO'
				ELSE 'CON EQUIPO'
			   END TIPO_CONTRATO
			  ,A.[RENTA_MENSUAL_ACT]
			  ,A.[TIPOTRANS_DESC] TRANSACCION
			  ,0 TOTAL_REVENUE
			  ,0 META
			  ,0 ALCANCE_META_VENTA
			  ,A.UNIDAD UNIDAD_GLOBAL
			  ,A.UNIDAD UNIDAD_APLICA_PERMA
			  ,0 APLICA_PERMA
			  ,0 FACT_PAGADAS
			  ,0 TOTAL_APLICAN_PERMA
			  ,SUM(UNIDAD) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR) TOTAL_UNIDADES
			  ,0 EFECTIVIDAD_VENTAS
			  ,A.[FACTOR_FIDE]
			  ,A.[COMISION]
			  ,A.[COMISION_SIN_IVA]
			  ,GETDATE() FECHA_PROCESO
			  ,A.[TIPOTRANS_ID]
			  ,A.PLAZO_CONTR_NUM PLAZO_CONTRATO
			  ,A.PRORRATEO
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoRenovacionesTMKNE]  A				
		  WHERE A.PERIODO_PAGO = @periodo_pago		   
		 	AND ACREEDOR_ID = @acreedor_id;
		  
		  /*--------------------------------------------------------------------------------------------------------------------
			TRANSACCIONES ADICIONALES, UPSELL VOS, UPSELL DATOS, SIN FRONTERAS Y FACEBOOK
		  --------------------------------------------------------------------------------------------------------------------*/	
		 INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoTMKNE 
		 SELECT A.[PERIODO_PAGO]
			  ,A.[PERIODO]
			  ,A.[FECHA_ID]
			  ,A.USERID [DEALER_CODE]
			  ,A.USERID [DEALER_NAME]
			  ,A.[DISTRIBUIDOR]
			  ,A.[ACREEDOR_ID]
			  ,'ALIADOS' CANAL
			  ,A.[CUSTOMER_ID]
			  ,A.[DN_NUM]
			  ,A.[CO_ID]
			  ,A.[NOMBRES_CLIENTE]
			  ,A.[APELLIDOS_CLIENTE]
			  ,A.NOMBRES_CLIENTE [NOMBRE_COMPLETO]
			  ,A.[NOMBRE_PLAN_ACT]			
			  ,'MOVIL' TIPO_PLAN
			  ,'MOVIL' TIPO_CONTRATO
			  ,A.CUOTA_ACT [RENTA_MENSUAL_ACT]			  
			  ,A.TRANSACCION
			  ,0 TOTAL_REVENUE_VENTA
			  ,0 META
			  ,0 ALCANCE_META
			  ,1 UNIDAD_GLOBAL
			  ,1 UNIDAD_APLICA
			  ,'SI' APLICA
			  ,0 FACT_PAGADAS
			  ,0 [TOTAL_APLICAN]
			  ,COUNT(*) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR, A.TRANSACCION) TOTAL_UNIDADES
			  ,0 [EFECTIVIDAD_VENTAS]
			  ,1 [FACTOR]
			  ,A.[COMISION]
			  ,A.[COMISION_SIN_IVA]
			  ,GETDATE() FECHA_PROCESO
			  ,A.[TIPOTRANS_ID]
			  ,0 PLAZO_CONTRATO
			  ,1 PRORRATEO
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoAdicionalesTMKNE] A
		  WHERE A.PERIODO_PAGO = @periodo_pago		
		  	AND ACREEDOR_ID = @acreedor_id;
	end