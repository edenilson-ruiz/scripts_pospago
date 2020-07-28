	--DECLARAMOS LAS VARIABLES
	DECLARE @OpenQuery nvarchar(4000)
	DECLARE @TSQL nvarchar(4000)
	DECLARE @LinkedServer nvarchar(4000)
	DECLARE @PeriodoCorte nvarchar(6)
	DECLARE @PeriodoProce nvarchar(6)
	DECLARE @PeriodoPago nvarchar(6)
	DECLARE @FechaCorte nvarchar(8)
	DECLARE @PeriodoActual nvarchar(6)
	DECLARE @DiaActual nvarchar(8)
	
	DECLARE @NombreDistribuidor varchar(80)

	--CONFIGURAMOS LAS VARIABLES
	SET @LinkedServer = 'DWSV'
	SET @PeriodoActual = (select convert(varchar(6),getdate(),112) )
	SET @DiaActual = (select convert(varchar(8),getdate(),112) )

	--CONFIGURAMOS OTROS PARAMETROS
	select @FechaCorte = PosFechaCorte,
		@PeriodoCorte = PosPeriodoCorte,
		@PeriodoProce = PosPeriodoProc
	from DimFechaCorte
	where PosPeriodoProc = @PeriodoActual
	
	set @PeriodoCorte = '201905'
	set @NombreDistribuidor = 'MOBILE SOLUTIONS'

	--VERIFICAMOS LAS FECHAS DE CORTE E INSERTAMOS EN LA TABLA DE VENTAS
	
		begin
			
			set @PeriodoPago  = convert(varchar(6),dateadd(m,1,convert(datetime,@PeriodoCorte+'01')),112)
		
			DELETE FROM DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXCorpo WHERE PERIODO = @PeriodoCorte and DISTRIBUIDOR = @NombreDistribuidor AND CO_ID NOT in ('13700395','13683381');
		
			--DROP TABLE PagoPospagoVentasDEXCorpo;
			
			--PRINT N'Se han borrado los registros del periodo = ' + @PeriodoCorte;
			
			INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXCorpo
			SELECT 
				X.*
				,1 CANT
				,CASE
					WHEN EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
									   WHERE TMCODE = X.TMCODE
										AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
													  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))										
									  )
					THEN 2				
					WHEN CLASI_PLAN = 'CORP BOLSON A' and num_venta between 1 and 10 then 2
					WHEN CLASI_PLAN = 'CORP BOLSON A' and num_venta > 10 then 2.5
					WHEN CLASI_PLAN = 'CORP BOLSON B' and num_venta between 1 and 100 then 2
					WHEN CLASI_PLAN = 'CORP BOLSON B' and num_venta > 100 then 2.5
					WHEN NOMBRE_PLAN LIKE '%AVI%' and isnull((select accessfee from FactPospagoServicios where periodo = x.periodo and co_id = x.co_id and serv_sncode = 195),0) = 0 and num_venta between 1 and 100 THEN 1
					WHEN NOMBRE_PLAN LIKE '%AVI%' and isnull((select accessfee from FactPospagoServicios where periodo = x.periodo and co_id = x.co_id and serv_sncode = 195),0) = 0 and num_venta > 100 THEN 1
					WHEN NOMBRE_PLAN LIKE '%AV_%' and isnull((select accessfee from FactPospagoServicios where periodo = x.periodo and co_id = x.co_id and serv_sncode = 195),0) = 0 and num_venta between 1 and 100 THEN 2
					WHEN NOMBRE_PLAN LIKE '%AV_%' and isnull((select accessfee from FactPospagoServicios where periodo = x.periodo and co_id = x.co_id and serv_sncode = 195),0) = 0 and num_venta > 100 THEN 2.5
					WHEN CLASI_PLAN = 'CORP NORMAL' and num_venta between 1 and 100 then 2
					WHEN CLASI_PLAN = 'CORP NORMAL' and num_venta > 100 then 2.5
					WHEN TIPO_PLAN_ESQUEMA= 'CORP NORMAL' and num_venta between 1 and 100 then 2
					WHEN TIPO_PLAN_ESQUEMA = 'CORP NORMAL' and num_venta > 100 then 2.5
					ELSE 0
				 END FACTOR_VENTA
				,CASE
					WHEN EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
									   WHERE TMCODE = X.TMCODE
								       AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
													  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
									  )
					THEN RENTA_COMISION * 2 
					WHEN CLASI_PLAN = 'CORP BOLSON A' and num_venta between 1 and 10 then (renta_comision*2)+isnull(cargos_avi,0)
					WHEN CLASI_PLAN = 'CORP BOLSON A' and num_venta > 10 then (renta_comision*2.5)+isnull(cargos_avi,0)
					WHEN CLASI_PLAN = 'CORP BOLSON B' and num_venta between 1 and 100 then (renta_comision*2)+isnull(cargos_avi,0)
					WHEN CLASI_PLAN = 'CORP BOLSON B' and num_venta > 100 then (renta_comision*2.5)+isnull(cargos_avi,0)
					WHEN NOMBRE_PLAN LIKE '%AVI%' and isnull((select accessfee from FactPospagoServicios where periodo = x.periodo and co_id = x.co_id and serv_sncode = 195),0) = 0 and num_venta between 1 and 100 THEN 8+(isnull(cargos_datos,0))*2
					WHEN NOMBRE_PLAN LIKE '%AVI%' and isnull((select accessfee from FactPospagoServicios where periodo = x.periodo and co_id = x.co_id and serv_sncode = 195),0) = 0 and num_venta > 100 THEN 8+(isnull(cargos_datos,0))*2.5
					WHEN NOMBRE_PLAN LIKE '%AV_%' and isnull((select accessfee from FactPospagoServicios where periodo = x.periodo and co_id = x.co_id and serv_sncode = 195),0) = 0 and num_venta between 1 and 100 THEN 8+(isnull(cargos_datos,0))*2
					WHEN NOMBRE_PLAN LIKE '%AV_%' and isnull((select accessfee from FactPospagoServicios where periodo = x.periodo and co_id = x.co_id and serv_sncode = 195),0) = 0 and num_venta > 100 THEN 8+(isnull(cargos_datos,0))*2.5
					WHEN CLASI_PLAN = 'CORP NORMAL' and num_venta between 1 and 100 then (renta_comision*2)+isnull(cargos_avi,0)
					WHEN CLASI_PLAN = 'CORP NORMAL' and num_venta > 100 then (renta_comision*2.5)+isnull(cargos_avi,0)
					WHEN TIPO_PLAN_ESQUEMA = 'CORP NORMAL' and num_venta between 1 and 100 then (renta_comision*2)+isnull(cargos_avi,0)
					WHEN TIPO_PLAN_ESQUEMA = 'CORP NORMAL' and num_venta > 100 then (renta_comision*2.5)+isnull(cargos_avi,0)
					ELSE 0
				 END COMISION
				,CASE
					WHEN EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
									   WHERE TMCODE = X.TMCODE
								       AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
													  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
									  )
					THEN RENTA_COMISION * 2 
					WHEN CLASI_PLAN = 'CORP BOLSON A' and num_venta between 1 and 10 then (renta_comision*2)+isnull(cargos_avi,0)
					WHEN CLASI_PLAN = 'CORP BOLSON A' and num_venta > 10 then (renta_comision*2.5)+isnull(cargos_avi,0)
					WHEN CLASI_PLAN = 'CORP BOLSON B' and num_venta between 1 and 100 then (renta_comision*2)+isnull(cargos_avi,0)
					WHEN CLASI_PLAN = 'CORP BOLSON B' and num_venta > 100 then (renta_comision*2.5)+isnull(cargos_avi,0)
					WHEN NOMBRE_PLAN LIKE '%AVI%' and isnull((select accessfee from FactPospagoServicios where periodo = x.periodo and co_id = x.co_id and serv_sncode = 195),0) = 0 and num_venta between 1 and 100 THEN 8+(isnull(cargos_datos,0))*2
					WHEN NOMBRE_PLAN LIKE '%AVI%' and isnull((select accessfee from FactPospagoServicios where periodo = x.periodo and co_id = x.co_id and serv_sncode = 195),0) = 0 and num_venta > 100 THEN 8+(isnull(cargos_datos,0))*2.5
					WHEN NOMBRE_PLAN LIKE '%AV_%' and isnull((select accessfee from FactPospagoServicios where periodo = x.periodo and co_id = x.co_id and serv_sncode = 195),0) = 0 and num_venta between 1 and 100 THEN 8+(isnull(cargos_datos,0))*2
					WHEN NOMBRE_PLAN LIKE '%AV_%' and isnull((select accessfee from FactPospagoServicios where periodo = x.periodo and co_id = x.co_id and serv_sncode = 195),0) = 0 and num_venta > 100 THEN 8+(isnull(cargos_datos,0))*2.5
					WHEN CLASI_PLAN = 'CORP NORMAL' and num_venta between 1 and 100 then (renta_comision*2)+isnull(cargos_avi,0)
					WHEN CLASI_PLAN = 'CORP NORMAL' and num_venta > 100 then (renta_comision*2.5)+isnull(cargos_avi,0)
					WHEN TIPO_PLAN_ESQUEMA = 'CORP NORMAL' and num_venta between 1 and 100 then (renta_comision*2)+isnull(cargos_avi,0)
					WHEN TIPO_PLAN_ESQUEMA = 'CORP NORMAL' and num_venta > 100 then (renta_comision*2.5)+isnull(cargos_avi,0)
					ELSE 0
				 END/1.13 COMISION_SIN_IVA
				,CASE
					WHEN X.TIPO_CONTRATO = 'CON EQUIPO' THEN 21
					ELSE 1
				 END TIPO_TRANS_COMI_ID
				,1 NEGOCIO_ID 
				,1 PRORRATEO
			FROM
			(
				SELECT 		
				A.PAIS_ID
				,A.PAIS_ABRV
				,A.PAIS_NOMBRE
				,A.PLCODE
				,A.PERIODO
				,@PeriodoPago PERIODO_PAGO
				,A.FECHA_ID
				,A.CO_ENTDATE
				,A.CO_SIGNED
				,A.CO_ACTIVATED
				,A.CH_VALIDFROM
				,A.CO_INSTALLED
				,A.CO_EXPIR_DATE			
				,A.CH_REASON
				,A.RAZON_ALTA
				,A.BILLCYCLE
				,A.CUSTOMER_ID
				,A.CO_ID
				,A.DN_NUM
				,A.CARGOS_TOTAL_ALTA
				,A.CARGOS_SERV_CORE
				,A.CARGOS_DATOS
				,A.CARGOS_AVI
				,CASE
					WHEN EXISTS (SELECT * 
								  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
								  WHERE TMCODE = A.TMCODE
								    AND A.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
													  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
									AND plazo_contrato = CAST(ISNULL(A.PLAZO_NUM,0) AS INT)
								  )
					THEN (SELECT RENTA_MENSUAL
						  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
						  WHERE TMCODE = A.TMCODE
							AND A.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
							AND plazo_contrato = CAST(ISNULL(A.PLAZO_NUM,0) AS INT)
						  ) 
					ELSE A.RENTA_COMISION
				 END RENTA_COMISION				
				,A.FINAN_FLAG
				,A.FINAN_CUOTA
				,A.FINAN_MONTO												
				,A.MARCA
				,A.MODELO
				,A.ADQUIRIDO_VIA
				,A.PLAZO_DESC
				,A.PLAZO_NUM
				,A.USERLASTMOD								
				,A.TIPO
				,A.MODALIDAD
				,A.TIPO_CONTRATO
				,A.TMCODE
				,(SELECT ACCESSFEE
				  FROM FactPospagoServicios FPS
				  WHERE FPS.CO_ID = A.CO_ID
					AND FPS.PERIODO = A.PERIODO
					AND FPS.SERV_SNCODE = 119
				  ) CARGO_PAQUETE
				,(SELECT NOMBRE_PAQUETE
				  FROM FactPospagoServicios FPS
				  WHERE FPS.CO_ID = A.CO_ID
					AND FPS.PERIODO = A.PERIODO
					AND FPS.SERV_SNCODE = 119
				  ) NOMBRE_PAQUETE
				,A.NOMBRE_PLAN							
				,A.CD_SEQNO
				,A.PORT_ID								
				,A.CO_ESTADO_ACT
				,A.CO_ESTADO_ACT_DESC
				,A.CO_ESTADO_ACT_FECHA								
				,A.NOMBRE_CLIENTE
				,A.APELLIDO_CLIENTE
				,A.NOMBRE_COMPLETO
				,A.PRGCODE CATEGORIA_CLIENTE_ID
				,A.CATEGORIA_CLIENTE CATEGORIA_CLIENTE_DESC				
				,A.PASSPORTNO DNI				
				,A.CODIGO_VENDEDOR				
				,A.VENTA
				,A.FACT_PAGADAS
				,A.FECHA_DATA
				,A.FECHA_UPDATE
				,A.DEALER_CODE
				,B.DEALER_NAME
				,B.DISTRIBUIDOR
				,B.CANAL
				,B.SUB_CANAL
				,B.REGION				
				,CASE
					WHEN UPPER(A.TIPO_ALTA) = 'PORTABILIDAD' THEN 'PORTABILIDAD'
					ELSE 'ACTIVACION'
				 END TIPO_ALTA
				,CASE
						WHEN LOWER(NOMBRE_PLAN) LIKE '%BOLS_N%' AND LOWER(NOMBRE_PLAN) LIKE '%A' THEN 'CORP BOLSON A'
						WHEN LOWER(NOMBRE_PLAN) LIKE '%BOLS_N%' AND LOWER(NOMBRE_PLAN) LIKE '%B' THEN 'CORP BOLSON B'
						WHEN LOWER(NOMBRE_PLAN) LIKE '%AVI%' THEN 'CORP AVI'
						ELSE 'CORP NORMAL'
				 END CLASI_PLAN
				,CASE
					WHEN LOWER(A.NOMBRE_PLAN) LIKE '%BOLS_N%' AND LOWER(A.NOMBRE_PLAN) LIKE '%A' THEN 'CORP BOLSON A'
					WHEN LOWER(A.NOMBRE_PLAN) LIKE '%BOLS_N%' AND LOWER(A.NOMBRE_PLAN) LIKE '%B' THEN 'CORP NORMAL'
					WHEN LOWER(A.NOMBRE_PLAN) LIKE '%AVI%' THEN 'CORP NORMAL'
					ELSE 'CORP NORMAL'
				END TIPO_PLAN_ESQUEMA
			   ,ROW_NUMBER() OVER (PARTITION BY A.PERIODO,B.DISTRIBUIDOR,CASE
															WHEN LOWER(A.NOMBRE_PLAN) LIKE '%BOLS_N%' AND LOWER(A.NOMBRE_PLAN) LIKE '%A' THEN 'CORP BOLSON A'
															WHEN LOWER(A.NOMBRE_PLAN) LIKE '%BOLS_N%' AND LOWER(A.NOMBRE_PLAN) LIKE '%B' THEN 'CORP NORMAL'
															WHEN LOWER(A.NOMBRE_PLAN) LIKE '%AVI%' THEN 'CORP NORMAL'
															ELSE 'CORP NORMAL'
														END ORDER BY B.DISTRIBUIDOR,CASE
															WHEN LOWER(A.NOMBRE_PLAN) LIKE '%BOLS_N%' AND LOWER(A.NOMBRE_PLAN) LIKE '%A' THEN 'CORP BOLSON A'
															WHEN LOWER(A.NOMBRE_PLAN) LIKE '%BOLS_N%' AND LOWER(A.NOMBRE_PLAN) LIKE '%B' THEN 'CORP NORMAL'
															WHEN LOWER(A.NOMBRE_PLAN) LIKE '%AVI%' THEN 'CORP NORMAL'
															ELSE 'CORP NORMAL'
														END,A.PERIODO,A.CO_ACTIVATED ) AS NUM_VENTA
			FROM  FactPospagoVentas A
				INNER JOIN DimDealer B ON B.DEALER_CODE = A.DEALER_CODE 
			WHERE B.CANAL = 'CORPORATIVO'
			    AND A.CO_ID NOT in ('13700395','13683381')
			    AND A.CO_ID NOT IN ('13785258','13785258','12735927','11257610','11257647','11257582')
				and B.DISTRIBUIDOR = @NombreDistribuidor
				AND B.SUB_CANAL IN ('Ejecutivos Distri Corp','Distribuidores Corp')
				AND A.PERIODO = @PeriodoCorte
				AND A.VENTA = 'S'
				AND A.FECHA_ID BETWEEN CONVERT(VARCHAR(8),B.FECHA_INI,112)
								   AND CONVERT(VARCHAR(8),ISNULL(B.FECHA_FIN,GETDATE()),112)
				AND NOT EXISTS (SELECT * FROM [DM_OPERACIONES_SV].[dbo].[CuboCorpExcluidos] WHERE CO_ID = A.CO_ID AND PERIODO = A.PERIODO)								   
				AND NOT EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.FactPospagoRenovaciones WHERE CO_ID = A.CO_ID AND PERIODO = A.PERIODO)
				--AND NOT EXISTS (
				--	SELECT * 
				--	FROM SERV199.DM_COMI_MULTIMEDIA.DBO.COMI_MUL_CROSS_SELLING B
				--	WHERE B.IDPERIODO_MSV = A.PERIODO       
				--		AND  B.DUI = A.PASSPORTNO
				--		AND UPPER(B.PAQUETE_NVO) LIKE '%LFI%SAT%'
				--)
				--AND NOT EXISTS (
				--	SELECT * 
				--	FROM SERV199.DM_COMI_MULTIMEDIA.DBO.COMI_MUL_VENTAS B
				--	WHERE B.IDPERIODO_MSV = A.PERIODO       
				--		AND  B.DUI = A.PASSPORTNO
				--		AND UPPER(B.PAQUETE_NVO) LIKE '%LFI%SAT%'
				--)
			) X
			
			
			/*==================================================================================================================
			01/10/2018 15:20 => Se ingreso la parte del bono por volumen, para poder procesar las planillas automaticas
			05/11/2018 15:38 => Se cambio la parte del numerador para la variable de alcance de meta, estaba tomando solo montos
			==================================================================================================================*/
			
			
			DELETE FROM DM_COMISV_POSPAGO.dbo.PagoPospagoBonoPorVolumenDEXCorpo WHERE PERIODO = @PeriodoCorte AND DISTRIBUIDOR = @NombreDistribuidor;
			
			
			INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoBonoPorVolumenDEXCorpo
			SELECT X.*
				,CASE
					WHEN EXISTS (SELECT * 
								  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
								  WHERE TMCODE = X.TMCODE
								   AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
													  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								  ) AND X.ALCANCE_META >= 0.8
					THEN (SELECT bono
						  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
						  WHERE TMCODE = X.TMCODE
						   AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
						  ) 
					WHEN X.PLAZO_NUM < 18 AND TIPO_CONTRATO = 'APORTADO' THEN 0
					WHEN X.NOMBRE_PLAN LIKE '%AVL%' THEN 0
					WHEN X.ALCANCE_META >= 0.8 THEN 25
					ELSE 0
				 END COMISION
				,(CASE
					WHEN EXISTS (SELECT * 
								  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
								  WHERE TMCODE = X.TMCODE
								   AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
													  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								  ) AND X.ALCANCE_META >= 0.8
					THEN (SELECT bono
						  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
						  WHERE TMCODE = X.TMCODE
						   AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
						  ) 
					WHEN X.PLAZO_NUM < 18 AND TIPO_CONTRATO = 'APORTADO' THEN 0
					WHEN X.NOMBRE_PLAN LIKE '%AVL%' THEN 0
					WHEN X.ALCANCE_META >= 0.8 THEN 25
					ELSE 0
				 END/1.13) COMISION_SIN_IVA
				 ,17 TIPOTRANS_ID
			FROM (
				SELECT A.PERIODO_PAGO
					,A.PERIODO
					,A.FECHA_ID
					,A.CO_ID
					,A.TMCODE
					,A.NOMBRE_PLAN 
					,A.TIPO_CONTRATO
					,A.PLAZO_NUM
					,A.DEALER_CODE
					,A.DEALER_NAME
					,A.DISTRIBUIDOR
					,CASE
						WHEN A.PLAZO_NUM < 18 AND A.TIPO_CONTRATO = 'APORTADO' THEN 'NO'
						WHEN A.NOMBRE_PLAN LIKE '%AVL%' THEN 'NO'
						ELSE 'SI'
					 END APLICA
					,1 CANT_VENTA
					,CASE
						WHEN A.PLAZO_NUM < 18 AND A.TIPO_CONTRATO = 'APORTADO' THEN 0
						WHEN A.NOMBRE_PLAN LIKE '%AVL%' THEN 0
						ELSE 1
					 END CANT_APLICA
					,(SUM(RENTA_COMISION+CARGOS_AVI) OVER (PARTITION BY PERIODO_PAGO, PERIODO, DISTRIBUIDOR))/1.13 TOTAL_REVENUE
					,CASE
						WHEN A.PERIODO < '201803'  THEN (
							select MOVIL 
							from DimMetasDEXCorpo
							where periodo = A.periodo
								and distribuidor = A.distribuidor
						)
						WHEN A.PERIODO >= '201803' THEN (
							select FACT_MOVIL_NUEVO
							from DimMetasDEXCorpoRevenue
							where periodo = a.periodo
								and distribuidor = A.distribuidor
						)
						ELSE 0
					 END META_LLAVE
					,CASE 
						WHEN A.PERIODO < '201803' THEN (SUM(CASE
																WHEN A.PLAZO_NUM < 18 AND A.TIPO_CONTRATO = 'APORTADO' THEN 0
																WHEN A.NOMBRE_PLAN LIKE '%AVL%' THEN 0
																ELSE 1
															 END) OVER (PARTITION BY PERIODO_PAGO, PERIODO, DISTRIBUIDOR) 
														)
						WHEN A.PERIODO >= '201803' THEN ((SUM(RENTA_COMISION+CARGOS_AVI) OVER (PARTITION BY PERIODO_PAGO, PERIODO, DISTRIBUIDOR))/1.13) 
						ELSE 0
					 END /
					 CASE
						WHEN A.PERIODO < '201803'  THEN (
							select MOVIL 
							from DimMetasDEXCorpo
							where periodo = A.periodo
								and distribuidor = A.distribuidor
						)
						WHEN A.PERIODO >= '201803' THEN (
							select FACT_MOVIL_NUEVO
							from DimMetasDEXCorpoRevenue
							where periodo = a.periodo
								and distribuidor = A.distribuidor
						)
						ELSE 0
					 END ALCANCE_META	
				FROM DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXCorpo A
				WHERE A.PERIODO = @PeriodoCorte
				 AND A.DISTRIBUIDOR = @NombreDistribuidor
			--	 AND A.DISTRIBUIDOR = 'INVERMER'
			) X
			
			--FIN PROCESO DE BONO POR VOLUMEN

		end
		
		
--		select * from DimDealer where DEALER_CODE = 'DVCES.DC29-023645536'

/*
select * from PagoPospagoConsolidadoDEXCorpo where periodo_pago = '201811' and DISTRIBUIDOR = 'MOBILE SOLUTIONS' AND TIPOTRANS_DESC LIKE '%ACT%'


SELECT * FROM FactPospagoVentas where co_id in ('13501250')

SELECT * FROM PagoPospagoConsolidadoDEXCorpo where co_id in (
'13498316',
'13457188',
'13501250'
)

select * from FactPospagoVentas where dn_num = '50379894661'

select * from FactPospagoVentas where co_id in (
'13498316',
'13457188'
)



SELECT * FROM PagoPospagoVentasDEXCorpo_BKMP201812 WHERE DISTRIBUIDOR LIKE '%TDM%'

SELECT * FROM PagoPospagoBonoPorVolumenDEXCorpo_BKMP201812 WHERE DISTRIBUIDOR LIKE '%TDM%'


SELECT * FROM PagoPospagoVentasDEXCorpo WHERE DISTRIBUIDOR LIKE '%TDM%'

SELECT * FROM PagoPospagoBonoPorVolumenDEXCorpo WHERE DISTRIBUIDOR LIKE '%TDM%'

SELECT * FROM PagoPospagoVentasDEXCorpo WHERE DISTRIBUIDOR LIKE '%TDM%'

select * from PagoPospagoConsolidadoDEXCorpo where distribuidor like '%TDM%' AND PERIODO_PAGO = '201812'

select * from dbo.DimMetasDEXCorpoRevenue where periodo = '201812' 

select * from DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXCorpo where periodo_pago = '201901' and distribuidor like '%DTS%'

select * from DM_COMISV_POSPAGO.dbo.PagoPospagoBonoPorVolumenDEXCorpo where periodo_pago = '201901' and distribuidor like '%DTS%'

*/

/*

select *
from FactPospagoVentas
where CO_ID in (
'13606214',
'13606220',
'13606225'
)



select *
from FactPospagoVentas
where CO_ID in (
'13606214',
'13606220',
'13606225'
)

update a
set a.DEALER_CODE = 'DVCES.10518'
from FactPospagoVentas a
where CO_ID in (
'13606214',
'13606220',
'13606225'
)


---DVCES.10518




select * from DimDealer where DEALER_CODE = 'DVCES.10518'


select *
from DM_OPERACIONES_SV.dbo.PagoConsolidadoCorpoInt
where CO_ID in (
'13606214',
'13606220',
'13606225'
)*/

/*
SELECT CO_ID FROM PagoPospagoVentasDEXCorpo_BKMP201905 where PERIODO_PAGO = '201905' and DISTRIBUIDOR like '%E-SMART%'


SELECT * 
FROM PagoPospagoConsolidadoDEXCorpo a 
where CO_ID = '13785258'

SELECT * 
FROM FactPospagoVentas a
	inner join PagoPospagoConsolidadoDEXCorpo b on b.CO_ID = a.CO_ID
where a.CO_ID = '13785258'
 and b.TIPOTRANS_ID = 21
 
update a
set a.DEALER_CODE = b.DEALER_CODE
FROM FactPospagoVentas a
	inner join PagoPospagoConsolidadoDEXCorpo b on b.CO_ID = a.CO_ID
where a.CO_ID = '13785258'
 and b.TIPOTRANS_ID = 21

select * from DimDealer where dealer_code = 'DVCES.DC13-038224337'
*/

/*

select * from PagoPospagoVentasDEXCorpo where PERIODO_PAGO = '201903' and DISTRIBUIDOR like '%E-SMART%'


select a.CO_ID, a.DEALER_CODE, b.DEALER_CODE, B.CO_ESTADO_ACT, B.CO_ESTADO_ACT_DESC, b.VENTA
from PagoPospagoConsolidadoDEXCorpo a
	inner join FactPospagoVentas b on b.CO_ID = a.CO_ID and b.PERIODO = a.PERIODO
where PERIODO_PAGO = '201903' and DISTRIBUIDOR like '%E-SMART%' and a.TIPOTRANS_ID = 1
 
 
 UPDATE A
 SET b.	
from PagoPospagoConsolidadoDEXCorpo a
	inner join FactPospagoVentas b on b.CO_ID = a.CO_ID and b.PERIODO = a.PERIODO
where A.PERIODO_PAGO = '201903' and A.DISTRIBUIDOR like '%E-SMART%' and a.TIPOTRANS_ID = 1


 
 
 SELECT CO_ID FROM PagoPospagoVentasDEXCorpo WHERE PERIODO_PAGO = '201905' AND DISTRIBUIDOR LIKE '%E-SMART%' AND PERIODO = '201904'*/
 
 
 
 
 SELECT *  
 FROM FactPospagoVentas a
	inner join PagoPospagoVentasDEXCorpo b on b.CO_ID = a.CO_ID  AND B.PERIODO = A.PERIODO
 where b.DISTRIBUIDOR like '%E-SMART%'
  AND B.PERIODO = '201903'
  
  
  SELECT TIPOTRANS_DESC, PERIODO, TOTAL_UNIDADES, TOTAL_APLICAN, SUM(COMISION_SIN_IVA) FROM PagoPospagoConsolidadoDEXCorpo where PERIODO_PAGO = '201905' and DISTRIBUIDOR like '%E-SMART%' GROUP BY TIPOTRANS_DESC, PERIODO, TOTAL_UNIDADES, TOTAL_APLICAN ORDER BY SUM(COMISION_SIN_IVA) DESC
  
  
 SELECT SUM(COMISION_SIN_IVA) FROM PagoPospagoBonoPorVolumenDEXCorpo WHERE PERIODO_PAGO = '201904' AND DISTRIBUIDOR LIKE '%E-SMART%'
 
 SELECT SUM(COMISION_SIN_IVA) FROM PagoPospagoVentasDEXCorpo WHERE PERIODO_PAGO = '201904' AND DISTRIBUIDOR LIKE '%E-SMART%'
 
 SELECT * FROM PagoPospagoVentasDEXCorpo WHERE PERIODO_PAGO = '201904' AND DISTRIBUIDOR LIKE '%E-SMART%' AND TMCODE = 6584
 
 
 
 SELECT TIPOTRANS_DESC, PERIODO, PERIODO_PAGO, SUM(UNIDAD_GLOBAL) TOTAL_UNIDADES, SUM(UNIDAD_APLICA) TOTAL_APLICA, SUM(COMISION_SIN_IVA) COMISION_SIN_IVA 
FROM PagoPospagoConsolidadoDEXCorpo where PERIODO_PAGO = '201905' and DISTRIBUIDOR like '%E-SMART%'
 GROUP BY TIPOTRANS_DESC, PERIODO, PERIODO_PAGO
 ORDER BY SUM(COMISION_SIN_IVA) DESC
 
 --28
 SELECT *
 FROM FactPospagoVentas a
	inner join DimDealer b on b.DEALER_CODE = a.DEALER_CODE 
 where a.PERIODO = '201904'
  and b.DISTRIBUIDOR like '%DTS%'
  and b.CANAL = 'CORPORATIVO'
  AND A.FECHA_ID BETWEEN CONVERT(VARCHAR(8),B.FECHA_INI,112) AND CONVERT(VARCHAR(8),ISNULL(B.FECHA_FIN, GETDATE()),112)
  AND A.CO_ID = '13791999'
 -- AND A.VENTA = 'S'
  
  --23
  SELECT *
 FROM FactPospagoRenovaciones a
	inner join DimDealer b on b.DEALER_CODE = a.DEALER_CODE 
 where a.PERIODO = '201904'
  and b.DISTRIBUIDOR like '%DTS%'
  and b.CANAL = 'CORPORATIVO'
  AND A.DN_NUM = '50378446307'
  
  
SELECT * FROM PagoPospagoConsolidadoDEXCorpo where  PERIODO_PAGO = '201905' AND DISTRIBUIDOR LIKE '%DTS%' AND TIPOTRANS_ID IN (1,21)

SELECT * FROM PagoPospagoRenovacionesDEXCorpo where PERIODO_PAGO = '201905' AND DISTRIBUIDOR LIKE '%DTS%'
  
  
  select * from FactPospagoCambiosDePlan where CO_ID = '10589095'
  
  
  
  
SELECT * FROM PagoPospagoConsolidadoDEXCorpo where  PERIODO_PAGO = '201905' AND CO_ID = '13791999'



SELECT * FROM FactPospagoRenovaciones where  PERIODO = '201904' AND CO_ID = '13791999'

