--DECLARAMOS LAS VARIABLES
DECLARE @PeriodoCorte nvarchar(6)
DECLARE @PeriodoProce nvarchar(6)
DECLARE @PeriodoPago nvarchar(6)
DECLARE @FechaCorte nvarchar(8)
DECLARE @PeriodoActual nvarchar(6)
DECLARE @DiaActual nvarchar(8)

DECLARE @periodo nvarchar(6)

DECLARE @NombreDistribuidor varchar(80)

--ULTIMA MODIFICACION: Se realiz� el ingreso de una renovaciones para SOL INTEGRA CO_ID = 11027114
--Se pagar� en el mes de junio 2020

--CONFIGURAMOS LAS VARIABLES	
set @periodo = '202005'
set @NombreDistribuidor = 'DTS'

--SELECT * FROM DimDealer where distribuidor like '%FLAMENCO%'
--SELECT * FROM PagoPospagoRenovacionesDEXCorpo where periodo_pago = '202002' and distribuidor like '%flamenco%'
if @NombreDistribuidor != ''
begin
	set @PeriodoPago  = convert(varchar(6),dateadd(m,1,convert(datetime,@periodo+'01')),112)
	
	DELETE FROM PagoPospagoRenovacionesDEXCorpo WHERE PERIODO = @periodo AND DISTRIBUIDOR = @NombreDistribuidor
	
	--DROP TABLE PagoPospagoRenovacionesDEXCorpo

	INSERT INTO PagoPospagoRenovacionesDEXCorpo
	SELECT X.*	
		,1 UNIDAD
		,CASE
			WHEN EXISTS (SELECT * 
						 FROM DM_COMISV_POSPAGO.dbo.PayComLineasEspeciales P
						  WHERE P.CO_ID = X.CO_ID
								AND P.PERIODO = P.PERIODO
								AND P.CANAL = X.CANAL
								AND P.TRANSACCION = 'RENOVACIONES'										
							  )
			THEN 1				
			WHEN EXISTS (SELECT * 
						 FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
						  WHERE TMCODE = X.TMCODE_ACT
								AND X.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
								  			    AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT)
							  )
			THEN (SELECT factor_pago 
						 FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
						  WHERE TMCODE = X.TMCODE_ACT
								AND X.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
								  			    AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT)
							  )	
			WHEN X.NUM_FIDE BETWEEN 1 AND 75 THEN 2
			WHEN X.NOMBRE_PLAN_ACT LIKE '%CTL%APORT%2.5%' THEN 1
			ELSE 2.5
		 END FACTOR_FIDE
		,CASE
			WHEN X.PERIODO <  '201803' THEN CANT_VENTAS / META_LLAVE
			WHEN X.PERIODO >= '201803' THEN TOTAL_REVENUE_VENTA / META_LLAVE
			ELSE 0
		 END  ALCANCE
		,CASE
			WHEN EXISTS (SELECT * 
						 FROM DM_COMISV_POSPAGO.dbo.PayComLineasEspeciales P
						  WHERE P.CO_ID = X.CO_ID
								AND P.PERIODO = P.PERIODO
								AND P.CANAL = X.CANAL
								AND P.TRANSACCION = 'RENOVACIONES'										
							  )
			THEN (X.RENTA_MENSUAL_ACT + X.CARGOS_AVI_ACT)
		    WHEN X.PERIODO = '201807' AND X.CUSTOMER_ID IN (9717533,9888092) THEN (X.RENTA_MENSUAL_ACT + X.CARGOS_AVI_ACT) 
		    WHEN EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
							   WHERE TMCODE = X.TMCODE_ACT 
								AND X.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT)
							  )
			THEN X.RENTA_MENSUAL_ACT * (SELECT factor_pago 
						 FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
						  WHERE TMCODE = X.TMCODE_ACT
								AND X.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
								  			    AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT)
							  )			  
			WHEN X.NUM_FIDE BETWEEN 1 AND 75 THEN ( ( ( X.RENTA_MENSUAL_ACT * 2 ) + X.CARGOS_AVI_ACT ) )
			WHEN X.NOMBRE_PLAN_ACT LIKE '%CTL%APORT%2.5%' THEN ( X.RENTA_MENSUAL_ACT * 1 ) 
			ELSE ( ( (X.RENTA_MENSUAL_ACT * 2.5 ) + X.CARGOS_AVI_ACT ) ) 
		 END * 
		 CASE 
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 3	THEN 0.0
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 6	THEN 0.1
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 12	THEN 0.2
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 18	THEN 0.5
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) >= 18 THEN 1					
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 3	THEN 0.0
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 6	THEN 0.1
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 12	THEN 0.2
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 18	THEN 0.5
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) >= 18 THEN 1				
			ELSE 0
		 END COMISION
		,CASE
			WHEN EXISTS (SELECT * 
						 FROM DM_COMISV_POSPAGO.dbo.PayComLineasEspeciales P
						  WHERE P.CO_ID = X.CO_ID
								AND P.PERIODO = P.PERIODO
								AND P.CANAL = X.CANAL
								AND P.TRANSACCION = 'RENOVACIONES'										
							  )
			THEN ( X.RENTA_MENSUAL_ACT + X.CARGOS_AVI_ACT ) 
			WHEN X.PERIODO = '201807' AND X.CUSTOMER_ID IN (9717533,9888092) THEN ( X.RENTA_MENSUAL_ACT + X.CARGOS_AVI_ACT ) 
		    WHEN EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
							   WHERE TMCODE = X.TMCODE_ACT
								AND X.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT)
							  )
			THEN X.RENTA_MENSUAL_ACT * (SELECT factor_pago 
						 FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
						  WHERE TMCODE = X.TMCODE_ACT
								AND X.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
								  			    AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT)
							  )						
			WHEN X.NUM_FIDE BETWEEN 1 AND 75 THEN ( ( (X.RENTA_MENSUAL_ACT * 2 ) + X.CARGOS_AVI_ACT) )
			WHEN X.NOMBRE_PLAN_ACT LIKE '%CTL%APORT%2.5%' THEN ( X.RENTA_MENSUAL_ACT * 1 )
			ELSE ( ( (X.RENTA_MENSUAL_ACT * 2.5 )+ X.CARGOS_AVI_ACT ) )
		 END/1.13 * 
		 CASE 
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 3	THEN 0.0
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 6	THEN 0.1
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 12	THEN 0.2
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 18	THEN 0.5
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) >= 18 THEN 1					
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 3	THEN 0.0
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 6	THEN 0.1
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 12	THEN 0.2
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 18	THEN 0.5
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) >= 18 THEN 1				
			ELSE 0
		 END COMISION_SIN_IVA
		,Y.TIPOTRANS_DESC
		,A.ACREEDOR_ID
		,B.ACREEDOR_NOMBRE
		,Y.CUENTA_SAP
		,Y.CENTRO_COSTO_SAP
		,Z.NEGOCIO_ID
		,Z.NEGOCIO_NOMBRE --INTO PagoPospagoRenovacionesDEXCorpo
		,CASE 
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 3	THEN 0.0
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 6	THEN 0.1
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 12	THEN 0.2
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 18	THEN 0.5
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) >= 18 THEN 1					
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 3	THEN 0.0
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 6	THEN 0.1
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 12	THEN 0.2
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 18	THEN 0.5
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) >= 18 THEN 1				
			ELSE 0
		 END PRORRATEO		
	FROM (
	SELECT   A.[TICKLER_NUMBER]
			,A.[TICKLER_CODE]
			,A.[CUSTOMER_ID]
			,A.[CO_ID]
			,A.[CREATED_DATE]
			,A.[FECHA]
			,A.[PERIODO]
			,@PeriodoPago PERIODO_PAGO
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
			--,A.[RENTA_MENSUAL_ACT]
			,CASE
				WHEN EXISTS (SELECT * 
							  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
							  WHERE TMCODE = A.TMCODE_ACT
									AND A.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
												  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
									AND plazo_contrato = CAST(ISNULL(A.PLAZO_CONTR_NUM,0) AS INT)
							  )
				THEN (SELECT RENTA_MENSUAL
					  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
					  WHERE TMCODE = A.TMCODE_ACT
						AND A.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
										  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
						AND plazo_contrato = CAST(ISNULL(A.PLAZO_CONTR_NUM,0) AS INT)
					  ) 
				ELSE A.RENTA_MENSUAL_ACT
			 END RENTA_MENSUAL_ACT
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
			,B.DISTRIBUIDOR
			,B.CANAL
			,B.SUB_CANAL
			,B.REGION	
			,ROW_NUMBER() OVER (PARTITION BY A.PERIODO,B.DISTRIBUIDOR ORDER BY B.DISTRIBUIDOR,A.PERIODO,A.CREATED_DATE ) AS NUM_FIDE
			,(
			SELECT COUNT(*)
			FROM PagoPospagoVentasDEXCorpo 
			where periodo = a.periodo
				and distribuidor = b.distribuidor
				and UPPER(NOMBRE_PLAN) NOT LIKE '%AVL%'
			) CANT_VENTAS					
			,ISNULL((
				SELECT SUM(RENTA_COMISION + CARGOS_AVI)
				FROM PagoPospagoVentasDEXCorpo
				WHERE periodo = a.periodo
					and distribuidor = b.distribuidor
			),0) / 1.13 AS TOTAL_REVENUE_VENTA
			,(
			CASE
				WHEN A.PERIODO < '201803'  THEN (
					select MOVIL 
					from DimMetasDEXCorpo
					where periodo = a.periodo
						and distribuidor = b.distribuidor
				)
				WHEN A.PERIODO >= '201803' THEN (
					select FACT_MOVIL_NUEVO
					from DimMetasDEXCorpoRevenue
					where periodo = a.periodo
						and distribuidor = b.distribuidor
				)
				ELSE 0
			END 
			) META_LLAVE
			,5 TIPOTRANS_ID	
			,A.PLAZO_CONTR_NUM
	from dbo.FactPospagoRenovaciones a
		inner join DimDealer b on b.dealer_code = a.dealer_code
	where a.periodo = @periodo
		AND DISTRIBUIDOR = @NombreDistribuidor
		and a.estado_co_id_act in ('a')
		and b.canal = 'CORPORATIVO'
		and b.DISTRIBUIDOR not like '%INTERMOV%'
		--and a.CO_ID in ('12242597','12242624','12243299','12242769','13428443','12242768','12242754','12242756','12242764','12242759','12243293','12243294')
		and b.SUB_CANAL IN ('Ejecutivos Distri Corp','Distribuidores Corp')		
		and a.fecha between CONVERT(varchar(8),b.fecha_ini,112) and CONVERT(varchar(8),isnull(b.fecha_fin,getdate()),112)
		AND NOT EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.PayComLineasExcluidas ple where ple.CANAL = B.CANAL and ple.PERIODO = a.PERIODO and ple.CO_ID = a.CO_ID and ple.TRANSACCION = 'RENOVACIONES')
	) X LEFT JOIN DimTipoTransaccion Y ON Y.TIPOTRANS_ID = X.TIPOTRANS_ID
		LEFT JOIN DimNegocio Z ON Z.NEGOCIO_ID = Y.NEGOCIO_ID
		--LEFT JOIN [DMSVMUL_COMISIONES].[dbo].[DimRazonSocial] A ON A.DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = X.DISTRIBUIDOR
		INNER JOIN DimDealer A ON A.DEALER_CODE = X.DEALER_CODE
		INNER JOIN DimAcreedor B ON B.ACREEDOR_ID = A.ACREEDOR_ID
	WHERE X.fecha between CONVERT(varchar(8),A.fecha_ini,112) and CONVERT(varchar(8),isnull(A.fecha_fin,getdate()),112) 
end
else 
	begin
	set @PeriodoPago  = convert(varchar(6),dateadd(m,1,convert(datetime,@periodo+'01')),112)
	
	--DELETE FROM PagoPospagoRenovacionesDEXCorpo WHERE PERIODO = @periodo
	
	--DROP TABLE PagoPospagoRenovacionesDEXCorpo

	--INSERT INTO PagoPospagoRenovacionesDEXCorpo
	SELECT X.*	
		,1 UNIDAD
		,CASE
			WHEN EXISTS (SELECT * 
						 FROM DM_COMISV_POSPAGO.dbo.PayComLineasEspeciales P
						  WHERE P.CO_ID = X.CO_ID
								AND P.PERIODO = P.PERIODO
								AND P.CANAL = X.CANAL
								AND P.TRANSACCION = 'RENOVACIONES'										
							  )
			THEN 1							
			WHEN EXISTS (SELECT * 
						 FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
						  WHERE TMCODE = X.TMCODE_ACT
								AND X.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
								  			    AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT)
							  )
			THEN (SELECT factor_pago 
						 FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
						  WHERE TMCODE = X.TMCODE_ACT
								AND X.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
								  			    AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT)
							  )	
			WHEN X.NUM_FIDE BETWEEN 1 AND 75 THEN 2
			WHEN X.NOMBRE_PLAN_ACT LIKE '%CTL%APORT%2.5%' THEN 1
			ELSE 2.5
		 END FACTOR_FIDE
		,CASE
			WHEN X.PERIODO <  '201803' THEN CANT_VENTAS / META_LLAVE
			WHEN X.PERIODO >= '201803' THEN TOTAL_REVENUE_VENTA / META_LLAVE
			ELSE 0
		 END  ALCANCE
		,CASE
			WHEN EXISTS (SELECT * 
						 FROM DM_COMISV_POSPAGO.dbo.PayComLineasEspeciales P
						  WHERE P.CO_ID = X.CO_ID
								AND P.PERIODO = P.PERIODO
								AND P.CANAL = X.CANAL
								AND P.TRANSACCION = 'RENOVACIONES'										
							  )
			THEN (X.RENTA_MENSUAL_ACT + X.CARGOS_AVI_ACT)
		    WHEN X.PERIODO = '201807' AND X.CUSTOMER_ID IN (9717533,9888092) THEN (X.RENTA_MENSUAL_ACT + X.CARGOS_AVI_ACT) 
		    WHEN EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
							   WHERE TMCODE = X.TMCODE_ACT
								and X.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT)
							  )
			THEN X.RENTA_MENSUAL_ACT * (SELECT factor_pago 
						 FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
						  WHERE TMCODE = X.TMCODE_ACT
								AND X.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
								  			    AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT)
							  )				  
			WHEN X.NUM_FIDE BETWEEN 1 AND 75 THEN ( ( ( X.RENTA_MENSUAL_ACT * 2 ) + X.CARGOS_AVI_ACT ) )
			WHEN X.NOMBRE_PLAN_ACT LIKE '%CTL%APORT%2.5%' THEN ( X.RENTA_MENSUAL_ACT * 1 ) 
			ELSE ( ( (X.RENTA_MENSUAL_ACT * 2.5 ) + X.CARGOS_AVI_ACT ) ) 
		 END * 
		 CASE 
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 3	THEN 0.0
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 6	THEN 0.1
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 12	THEN 0.2
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 18	THEN 0.5
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) >= 18 THEN 1					
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 3	THEN 0.0
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 6	THEN 0.1
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 12	THEN 0.2
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 18	THEN 0.5
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) >= 18 THEN 1				
			ELSE 0
		 END COMISION
		,CASE
			WHEN EXISTS (SELECT * 
						 FROM DM_COMISV_POSPAGO.dbo.PayComLineasEspeciales P
						  WHERE P.CO_ID = X.CO_ID
								AND P.PERIODO = P.PERIODO
								AND P.CANAL = X.CANAL
								AND P.TRANSACCION = 'RENOVACIONES'										
							  )
			THEN ( X.RENTA_MENSUAL_ACT + X.CARGOS_AVI_ACT ) 
			WHEN X.PERIODO = '201807' AND X.CUSTOMER_ID IN (9717533,9888092) THEN ( X.RENTA_MENSUAL_ACT + X.CARGOS_AVI_ACT ) 
		    WHEN EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
							   WHERE TMCODE = X.TMCODE_ACT
								AND X.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT)
							  )
			THEN X.RENTA_MENSUAL_ACT * (SELECT factor_pago 
						 FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
						  WHERE TMCODE = X.TMCODE_ACT
								AND X.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
								  			    AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT)
							  )						
			WHEN X.NUM_FIDE BETWEEN 1 AND 75 THEN ( ( (X.RENTA_MENSUAL_ACT * 2 ) + X.CARGOS_AVI_ACT) )
			WHEN X.NOMBRE_PLAN_ACT LIKE '%CTL%APORT%2.5%' THEN ( X.RENTA_MENSUAL_ACT * 1 ) 
			ELSE ( ( (X.RENTA_MENSUAL_ACT * 2.5 )+ X.CARGOS_AVI_ACT ) )
		 END/1.13 * 
		 CASE 
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 3	THEN 0.0
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 6	THEN 0.1
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 12	THEN 0.2
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 18	THEN 0.5
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) >= 18 THEN 1					
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 3	THEN 0.0
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 6	THEN 0.1
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 12	THEN 0.2
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 18	THEN 0.5
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) >= 18 THEN 1				
			ELSE 0
		 END COMISION_SIN_IVA
		,Y.TIPOTRANS_DESC
		,A.ACREEDOR_ID
		,B.ACREEDOR_NOMBRE
		,Y.CUENTA_SAP
		,Y.CENTRO_COSTO_SAP
		,Z.NEGOCIO_ID
		,Z.NEGOCIO_NOMBRE --INTO PagoPospagoRenovacionesDEXCorpo
		,CASE 
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 3	THEN 0.0
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 6	THEN 0.1
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 12	THEN 0.2
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 18	THEN 0.5
			WHEN X.CO_EQU_TYPE LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) >= 18 THEN 1					
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 3	THEN 0.0
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 6	THEN 0.1
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 12	THEN 0.2
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) < 18	THEN 0.5
			WHEN X.CO_EQU_TYPE NOT LIKE '%APORTADO%' AND CAST(ISNULL(X.PLAZO_CONTR_NUM,0) AS INT) >= 18 THEN 1				
			ELSE 0
		 END PRORRATEO		
	FROM (
	SELECT   A.[TICKLER_NUMBER]
			,A.[TICKLER_CODE]
			,A.[CUSTOMER_ID]
			,A.[CO_ID]
			,A.[CREATED_DATE]
			,A.[FECHA]
			,A.[PERIODO]
			,@PeriodoPago PERIODO_PAGO
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
			--,A.[RENTA_MENSUAL_ACT]
			,CASE
				WHEN EXISTS (SELECT * 
							  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
							  WHERE TMCODE = A.TMCODE_ACT
									AND A.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
												  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
									AND plazo_contrato = CAST(ISNULL(A.PLAZO_CONTR_NUM,0) AS INT)
							  )
				THEN (SELECT RENTA_MENSUAL
					  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
					  WHERE TMCODE = A.TMCODE_ACT
						AND A.FECHA BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
										  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
						AND plazo_contrato = CAST(ISNULL(A.PLAZO_CONTR_NUM,0) AS INT)
					  ) 
				ELSE A.RENTA_MENSUAL_ACT
			 END RENTA_MENSUAL_ACT
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
			,B.DISTRIBUIDOR
			,B.CANAL
			,B.SUB_CANAL
			,B.REGION	
			,ROW_NUMBER() OVER (PARTITION BY A.PERIODO,B.DISTRIBUIDOR ORDER BY B.DISTRIBUIDOR,A.PERIODO,A.CREATED_DATE ) AS NUM_FIDE
			,(
			SELECT COUNT(*)
			FROM PagoPospagoVentasDEXCorpo 
			where periodo = a.periodo
				and distribuidor = b.distribuidor
				and UPPER(NOMBRE_PLAN) NOT LIKE '%AVL%'
			) CANT_VENTAS					
			,ISNULL((
				SELECT SUM(RENTA_COMISION + CARGOS_AVI)
				FROM PagoPospagoVentasDEXCorpo
				WHERE periodo = a.periodo
					and distribuidor = b.distribuidor
			),0) / 1.13 AS TOTAL_REVENUE_VENTA
			,(
			CASE
				WHEN A.PERIODO < '201803'  THEN (
					select MOVIL 
					from DimMetasDEXCorpo
					where periodo = a.periodo
						and distribuidor = b.distribuidor
				)
				WHEN A.PERIODO >= '201803' THEN (
					select FACT_MOVIL_NUEVO
					from DimMetasDEXCorpoRevenue
					where periodo = a.periodo
						and distribuidor = b.distribuidor
				)
				ELSE 0
			END 
			) META_LLAVE
			,5 TIPOTRANS_ID	
			,A.PLAZO_CONTR_NUM
	from dbo.FactPospagoRenovaciones a
		inner join DimDealer b on b.dealer_code = a.dealer_code
	where a.periodo = @periodo
		--AND DISTRIBUIDOR = @NombreDistribuidor
		and a.estado_co_id_act in ('a')
		and b.canal = 'CORPORATIVO'
		and b.DISTRIBUIDOR not like '%INTERMOV%'
		--and a.CO_ID in ('12242597','12242624','12243299','12242769','13428443','12242768','12242754','12242756','12242764','12242759','12243293','12243294')
		and b.SUB_CANAL IN ('Ejecutivos Distri Corp','Distribuidores Corp')		
		and a.fecha between CONVERT(varchar(8),b.fecha_ini,112) and CONVERT(varchar(8),isnull(b.fecha_fin,getdate()),112)
		AND NOT EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.PayComLineasExcluidas ple where ple.CANAL = B.CANAL and ple.PERIODO = a.PERIODO and ple.CO_ID = a.CO_ID and ple.TRANSACCION = 'RENOVACIONES')
	) X LEFT JOIN DimTipoTransaccion Y ON Y.TIPOTRANS_ID = X.TIPOTRANS_ID
		LEFT JOIN DimNegocio Z ON Z.NEGOCIO_ID = Y.NEGOCIO_ID
		--LEFT JOIN [DMSVMUL_COMISIONES].[dbo].[DimRazonSocial] A ON A.DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = X.DISTRIBUIDOR
		INNER JOIN DimDealer A ON A.DEALER_CODE = X.DEALER_CODE
		INNER JOIN DimAcreedor B ON B.ACREEDOR_ID = A.ACREEDOR_ID
	WHERE X.fecha between CONVERT(varchar(8),A.fecha_ini,112) and CONVERT(varchar(8),isnull(A.fecha_fin,getdate()),112) 
end