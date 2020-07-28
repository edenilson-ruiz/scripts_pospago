--select periodo_pago, periodo,  acreedor_id, transaccion, COUNT(*) cant, SUM(COMISION_SIN_IVA) comision from DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoDEXMasivo where periodo_pago = '201811' and distribuidor = 'CRECE' GROUP BY periodo_pago, periodo, ACREEDOR_ID, TRANSACCION
--select * from DimAcreedor where acreedor_nombre_comercial like '%TDM%'

use DM_COMISV_POSPAGO

DECLARE @periodo_pago varchar(6)
DECLARE @periodo_corte varchar(6)
DECLARE @acreedor_id varchar(20)

set @periodo_corte = '202006'
set @periodo_pago = convert(varchar(6),dateadd(m,1,convert(datetime,@periodo_corte+'01')),112)	
set @acreedor_id = '700000001'

if @acreedor_id = ''
	begin
	
		DELETE DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoDEXMasivo WHERE PERIODO_PAGO = @periodo_pago

		--SELECT TOP 10 * FROM PagoPospagoConsolidadoDEXMasivo
		 
		INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoDEXMasivo 
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
			,B.ACREEDOR_ID	
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
			,ISNULL(( SELECT SUM(REVENUE)
				   FROM DMSVRHI_COMISIONES.dbo.DimMetasDistriPosRevenue
				   WHERE PERIODO COLLATE Modern_Spanish_CI_AS = A.PERIODO
					AND DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = A.DISTRIBUIDOR
				  ),0) META	 	
			--,ISNULL((SUM(A.RENTA_COMISION) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR )) / ( SELECT SUM(REVENUE)
			--	   FROM DMSVRHI_COMISIONES.dbo.DimMetasDistriPosRevenue
			--	   WHERE PERIODO COLLATE Modern_Spanish_CI_AS = A.PERIODO
			--		AND DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = A.DISTRIBUIDOR
			--	  ),0)	ALCANCE_META_VENTA
			,CASE
				WHEN  ( 
						SELECT SUM(REVENUE)
						FROM DMSVRHI_COMISIONES.dbo.DimMetasDistriPosRevenue
							WHERE PERIODO COLLATE Modern_Spanish_CI_AS = A.PERIODO
						AND DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = A.DISTRIBUIDOR
					  ) <= 0 THEN 0
				ELSE ISNULL((SUM(A.RENTA_COMISION) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR )) / ( SELECT SUM(REVENUE)
				   FROM DMSVRHI_COMISIONES.dbo.DimMetasDistriPosRevenue
				   WHERE PERIODO COLLATE Modern_Spanish_CI_AS = A.PERIODO
					AND DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = A.DISTRIBUIDOR
				  ),0)	
			 END ALCANCE_META_VENTA	
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
			,A.PRORRATEO --INTO PagoPospagoConsolidadoDEXMasivo
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoVentasDEXMasivo] A
				INNER JOIN [DM_COMISV_POSPAGO].[dbo].DimDealer B ON B.DEALER_CODE = A.DEALER_CODE 		
		  WHERE A.PERIODO_PAGO = @periodo_pago
			AND A.FECHA_ID BETWEEN CONVERT(VARCHAR(8),B.FECHA_INI,112) AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
		UNION ALL
		/*--------------------------------------------------------------------------------------------------------------------
			PERMANENCIA
		--------------------------------------------------------------------------------------------------------------------*/
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
				,A.META
				,A.ALCANCE_META_VENTA
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
				,A.FECHA_PROCESO
				,CASE
					WHEN TRANSACCION = 'PERMANENCIA F6' THEN 27
					WHEN TRANSACCION = 'PERMANENCIA F5' THEN 26
					WHEN TRANSACCION = 'PERMANENCIA F4' THEN 25
					WHEN TRANSACCION = 'PERMANENCIA F3' THEN 24
					WHEN TRANSACCION = 'PERMANENCIA F2' THEN 23
					WHEN TRANSACCION = 'PERMANENCIA F1' THEN 22
					WHEN TRANSACCION = 'PAGO Y LISTO' THEN 4
					ELSE 3
				 END TIPOTRANS_ID
				,0 PLAZO_CONTRATO
				,1 PRORRATEO
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoPermanenciaDEXMasivo] A
			INNER JOIN [DM_COMISV_POSPAGO].[dbo].[FactPospagoVentas] b on b.co_id = a.co_id and b.fecha_id = A.FECHA_ID	
		  WHERE PERIODO_PAGO = @periodo_pago 
		  UNION ALL
		  /*--------------------------------------------------------------------------------------------------------------------
			RENOVACIONES
		  --------------------------------------------------------------------------------------------------------------------*/
		  SELECT DISTINCT A.[PERIODO_PAGO]
			  ,A.[PERIODO]
			  ,A.[FECHA_ID]
			  ,A.[DEALER_CODE]
			  ,A.[DEALER_NAME]
			  ,A.[DISTRIBUIDOR]
			  ,B.[ACREEDOR_ID]
			  ,A.[CANAL]
			  ,A.[CUSTOMER_ID]
			  ,A.[DN_NUM]
			  ,A.[CO_ID]
			  ,A.[NOMBRE_CLIENTE]
			  ,A.[APELLIDO_CLIENTE]
			  ,A.[NOMBRE_COMPLETO]
			  ,A.[NOMBRE_PLAN]
			  ,A.[TIPO_PLAN]
			  ,A.[TIPO_CONTRATO]
			  ,A.[RENTA_MENSUAL]
			  ,A.[TRANSACCION]
			  ,A.[TOTAL_REVENUE]
			  ,A.[META]
			  ,A.[ALCANCE_META_VENTA]
			  ,A.[UNIDAD_GLOBAL]
			  ,A.[UNIDAD_APLICA_PERMA]
			  ,A.[APLICA_PERMA]
			  ,A.[FACT_PAGADAS]
			  ,A.[TOTAL_APLICAN_PERMA]
			  ,A.[TOTAL_UNIDADES]
			  ,A.[EFECTIVIDAD_VENTAS]
			  ,A.[FACTOR]
			  ,A.[COMISION]
			  ,A.[COMISION_SIN_IVA]
			  ,A.[FECHA_PROCESO]
			  ,A.[TIPOTRANS_ID]
			  ,A.PLAZO_CONTR_NUM PLAZO_CONTRATO
			  ,A.PRORRATEO
		  FROM [STG_DMSVPOS_COMI].[dbo].[TXN_POSPAGO_RENOVACIONES_MASIVO] A
			INNER JOIN DM_COMISV_POSPAGO.dbo.DimDealer B ON B.DEALER_CODE = A.DEALER_CODE
		  WHERE A.PERIODO_PAGO = @periodo_pago
		   AND A.FECHA_ID BETWEEN CONVERT(VARCHAR(8),B.FECHA_INI,112) AND CONVERT(VARCHAR(8),ISNULL(B.FECHA_FIN,GETDATE()),112)	
		  UNION ALL
		  /*--------------------------------------------------------------------------------------------------------------------
			CAMBIOS DE PLAN
		  --------------------------------------------------------------------------------------------------------------------*/	
		 SELECT [PERIODO_PAGO]
			  ,[PERIODO]
			  ,[FECHA_ID]
			  ,[DEALER_CODE]
			  ,[DEALER_NAME]
			  ,[DISTRIBUIDOR]
			  ,[ACREEDOR_ID]
			  ,[CANAL]			  			  
			  ,[CUSTOMER_ID]
			  ,[DN_NUM]
			  ,[CO_ID]
			  ,[NOMBRE_CLIENTE]
			  ,[APELLIDO_CLIENTE]
			  ,[NOMBRE_COMPLETO]
			  ,[NOMBRE_PLAN_ACT]			
			  ,[TIPO_PLAN]
			  ,[TIPO_CONTRATO]
			  ,[RENTA_MENSUAL_ACT]			  
			  ,'CAMBIOS DE PLAN' TRANSACCION
			  ,[TOTAL_REVENUE_VENTA]
			  ,[META]
			  ,[ALCANCE_META]
			  ,[UNIDAD_GLOBAL]
			  ,[UNIDAD_APLICA]
			  ,[APLICA]
			  ,[FACT_PAGADAS]
			  ,[TOTAL_APLICAN]
			  ,[TOTAL_UNIDADES]
			  ,[EFECTIVIDAD_VENTAS]
			  ,[FACTOR]
			  ,[COMISION]
			  ,[COMISION_SIN_IVA]
			  ,GETDATE() FECHA_PROCESO
			  ,[TIPOTRANS_ID]
			  ,0 PLAZO_CONTRATO
			  ,1 PRORRATEO
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoCambiosDePlanDEXMasivo] A
		  WHERE A.PERIODO_PAGO = @periodo_pago		   
	end
else
	begin
		DELETE DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoDEXMasivo WHERE PERIODO_PAGO = @periodo_pago and ACREEDOR_ID = @acreedor_id

		--SELECT TOP 10 * FROM PagoPospagoConsolidadoDEXMasivo
		 
		INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoConsolidadoDEXMasivo 
		/*=============================================================================================================================
			VENTAS
		=============================================================================================================================*/
		SELECT
			@periodo_pago PERIODO_PAGO
			,A.PERIODO
			,A.FECHA_ID
			,A.DEALER_CODE
			,A.DEALER_NAME
			,A.DISTRIBUIDOR
			,B.ACREEDOR_ID	
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
			,ISNULL(( SELECT SUM(REVENUE)
				   FROM DMSVRHI_COMISIONES.dbo.DimMetasDistriPosRevenue
				   WHERE PERIODO COLLATE Modern_Spanish_CI_AS = A.PERIODO
					AND DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = A.DISTRIBUIDOR
				  ),0) META	 	
			--,ISNULL((SUM(A.RENTA_COMISION) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR )) / ( SELECT SUM(REVENUE)
			--	   FROM DMSVRHI_COMISIONES.dbo.DimMetasDistriPosRevenue
			--	   WHERE PERIODO COLLATE Modern_Spanish_CI_AS = A.PERIODO
			--		AND DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = A.DISTRIBUIDOR
			--	  ),0)	ALCANCE_META_VENTA
			,CASE
				WHEN  ( 
						SELECT SUM(REVENUE)
						FROM DMSVRHI_COMISIONES.dbo.DimMetasDistriPosRevenue
							WHERE PERIODO COLLATE Modern_Spanish_CI_AS = A.PERIODO
						AND DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = A.DISTRIBUIDOR
					  ) <= 0 THEN 0
				ELSE ISNULL((SUM(A.RENTA_COMISION) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR )) / ( SELECT SUM(REVENUE)
				   FROM DMSVRHI_COMISIONES.dbo.DimMetasDistriPosRevenue
				   WHERE PERIODO COLLATE Modern_Spanish_CI_AS = A.PERIODO
					AND DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = A.DISTRIBUIDOR
				  ),0)
			 END ALCANCE_META_VENTA	
			,1 UNIDAD_GLOBAL
			,0 UNIDAD_APLICA_PERMA
			,'NO' APLICA_PERMA
			,A.FACT_PAGADAS	
			,0 TOTAL_APLICAN_PERMA
			,COUNT(*) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR) TOTAL_UNIDADES
			,0 EFECTIVIDAD_VENTAS
			,A.FACTOR_VENTA FACTOR
			,A.COMISION
			,A.COMISION_SIN_IVA
			,GETDATE() FECHA_PROCESO
			,A.TIPO_TRANS_COMI_ID TIPOTRANS_ID 
			,A.PLAZO_NUM PLAZO_CONTRATO
			,A.PRORRATEO --INTO PagoPospagoConsolidadoDEXMasivo
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoVentasDEXMasivo] A
				INNER JOIN [DM_COMISV_POSPAGO].[dbo].DimDealer B ON B.DEALER_CODE = A.DEALER_CODE 		
		  WHERE A.PERIODO_PAGO = @periodo_pago
			AND A.FECHA_ID BETWEEN CONVERT(VARCHAR(8),B.FECHA_INI,112) AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
			and b.ACREEDOR_ID = @acreedor_id
		UNION ALL
		/*=============================================================================================================================
			PERMANENCIA
		=============================================================================================================================*/
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
				,A.META
				,A.ALCANCE_META_VENTA
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
				,A.FECHA_PROCESO
				,CASE
					WHEN TRANSACCION = 'PERMANENCIA F6' THEN 27
					WHEN TRANSACCION = 'PERMANENCIA F5' THEN 26
					WHEN TRANSACCION = 'PERMANENCIA F4' THEN 25
					WHEN TRANSACCION = 'PERMANENCIA F3' THEN 24
					WHEN TRANSACCION = 'PERMANENCIA F2' THEN 23
					WHEN TRANSACCION = 'PERMANENCIA F1' THEN 22
					WHEN TRANSACCION = 'PAGO Y LISTO' THEN 4
					ELSE 3
				 END TIPOTRANS_ID
				,0 PLAZO_CONTRATO
				,1 PRORRATEO
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoPermanenciaDEXMasivo] A
			INNER JOIN [DM_COMISV_POSPAGO].[dbo].[FactPospagoVentas] b on b.co_id = a.co_id and b.fecha_id = A.FECHA_ID	
		  WHERE PERIODO_PAGO = @periodo_pago 
			and a.ACREEDOR_ID = @acreedor_id
		  UNION ALL
		  /*=============================================================================================================================
			RENOVACIONES
		  =============================================================================================================================*/
		  SELECT DISTINCT A.[PERIODO_PAGO]
			  ,A.[PERIODO]
			  ,A.[FECHA_ID]
			  ,A.[DEALER_CODE]
			  ,A.[DEALER_NAME]
			  ,A.[DISTRIBUIDOR]
			  ,B.[ACREEDOR_ID]
			  ,A.[CANAL]
			  ,A.[CUSTOMER_ID]
			  ,A.[DN_NUM]
			  ,A.[CO_ID]
			  ,A.[NOMBRE_CLIENTE]
			  ,A.[APELLIDO_CLIENTE]
			  ,A.[NOMBRE_COMPLETO]
			  ,A.[NOMBRE_PLAN]
			  ,A.[TIPO_PLAN]
			  ,A.[TIPO_CONTRATO]
			  ,A.[RENTA_MENSUAL]
			  ,A.[TRANSACCION]
			  ,A.[TOTAL_REVENUE]
			  ,A.[META]
			  ,A.[ALCANCE_META_VENTA]
			  ,A.[UNIDAD_GLOBAL]
			  ,A.[UNIDAD_APLICA_PERMA]
			  ,A.[APLICA_PERMA]
			  ,A.[FACT_PAGADAS]
			  ,A.[TOTAL_APLICAN_PERMA]
			  ,A.[TOTAL_UNIDADES]
			  ,A.[EFECTIVIDAD_VENTAS]
			  ,A.[FACTOR]
			  ,A.[COMISION]
			  ,A.[COMISION_SIN_IVA]
			  ,A.[FECHA_PROCESO]
			  ,A.[TIPOTRANS_ID]
			  ,A.PLAZO_CONTR_NUM PLAZO_CONTRATO
			  ,A.PRORRATEO
		  FROM [STG_DMSVPOS_COMI].[dbo].[TXN_POSPAGO_RENOVACIONES_MASIVO] A
			INNER JOIN DM_COMISV_POSPAGO.dbo.DimDealer B ON B.DEALER_CODE = A.DEALER_CODE
		  WHERE A.PERIODO_PAGO = @periodo_pago
		   AND A.FECHA_ID BETWEEN CONVERT(VARCHAR(8),B.FECHA_INI,112) AND CONVERT(VARCHAR(8),ISNULL(B.FECHA_FIN,GETDATE()),112)
		   and b.ACREEDOR_ID = @acreedor_id
		  UNION ALL
		  /*=============================================================================================================================
			CAMBIOS DE PLAN
		  =============================================================================================================================*/
		  SELECT [PERIODO_PAGO]
			  ,[PERIODO]
			  ,[FECHA_ID]
			  ,[DEALER_CODE]
			  ,[DEALER_NAME]
			  ,[DISTRIBUIDOR]
			  ,[ACREEDOR_ID]
			  ,[CANAL]			  			  
			  ,[CUSTOMER_ID]
			  ,[DN_NUM]
			  ,[CO_ID]
			  ,[NOMBRE_CLIENTE]
			  ,[APELLIDO_CLIENTE]
			  ,[NOMBRE_COMPLETO]
			  ,[NOMBRE_PLAN_ACT]			
			  ,[TIPO_PLAN]
			  ,[TIPO_CONTRATO]
			  ,[RENTA_MENSUAL_ACT]			  
			  ,'CAMBIOS DE PLAN' TRANSACCION
			  ,[TOTAL_REVENUE_VENTA]
			  ,[META]
			  ,[ALCANCE_META]
			  ,[UNIDAD_GLOBAL]
			  ,[UNIDAD_APLICA]
			  ,[APLICA]
			  ,[FACT_PAGADAS]
			  ,[TOTAL_APLICAN]
			  ,[TOTAL_UNIDADES]
			  ,[EFECTIVIDAD_VENTAS]
			  ,[FACTOR]
			  ,[COMISION]
			  ,[COMISION_SIN_IVA]
			  ,GETDATE() FECHA_PROCESO
			  ,[TIPOTRANS_ID]
			  ,0 PLAZO_CONTRATO
			  ,1 PRORRATEO
		  FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoCambiosDePlanDEXMasivo] A
		  WHERE A.PERIODO_PAGO = @periodo_pago
		   AND A.ACREEDOR_ID = @acreedor_id
	end

/*

select periodo_pago, count(*) cant, sum(comision) comision
from [DM_COMISV_POSPAGO].[dbo].[PagoPospagoConsolidadoDEXMAsivo] 
where periodo_pago between 202001 and 202005
group by periodo_pago
order by PERIODO_PAGO


*/

