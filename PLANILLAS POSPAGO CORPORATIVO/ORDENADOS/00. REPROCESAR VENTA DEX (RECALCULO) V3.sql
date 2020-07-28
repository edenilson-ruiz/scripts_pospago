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

--VERIFICAMOS LAS FECHAS DE CORTE E INSERTAMOS EN LA TABLA DE VENTAS
set @PeriodoCorte = '202004'
set @NombreDistribuidor = 'E-SMART'

begin
	
	set @PeriodoPago  = convert(varchar(6),dateadd(m,1,convert(datetime,@PeriodoCorte+'01')),112)

	DELETE FROM DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXCorpoRecalculo WHERE PERIODO = @PeriodoCorte and DISTRIBUIDOR = @NombreDistribuidor;

	--DROP TABLE PagoPospagoVentasDEXCorpo;
	
	--PRINT N'Se han borrado los registros del periodo = ' + @PeriodoCorte;
	
	--INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXCorpo
	INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXCorpoRecalculo
	SELECT 
		X.*
		,1 CANT
		,CASE
			WHEN EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
							   WHERE TMCODE = X.TMCODE
								AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_NUM,0) AS INT)
							  )
			THEN (SELECT FACTOR_PAGO FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
							   WHERE TMCODE = X.TMCODE
								AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_NUM,0) AS INT))				
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
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_NUM,0) AS INT)
							  )
			THEN RENTA_COMISION * (SELECT FACTOR_PAGO FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
							   WHERE TMCODE = X.TMCODE
								AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_NUM,0) AS INT))
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
		 END * 
		 CASE 
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 3 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 6   THEN 0.1
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 12  THEN 0.2
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 18  THEN 0.5
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 18  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 3 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 6   THEN 0.4
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 12  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 18  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 18  THEN 1
			ELSE 0
		 END  COMISION
		,CASE
			WHEN EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
							   WHERE TMCODE = X.TMCODE
						        AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_NUM,0) AS INT)
							  )
			THEN RENTA_COMISION * (SELECT FACTOR_PAGO FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
							   WHERE TMCODE = X.TMCODE
								AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_NUM,0) AS INT))
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
		 END/1.13 * 
		 CASE 
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 3 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 6   THEN 0.1
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 12  THEN 0.2
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 18  THEN 0.5
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 18  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 3 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 6   THEN 0.4
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 12  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 18  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 18  THEN 1
			ELSE 0
		 END  COMISION_SIN_IVA
		--,1 TIPO_TRANS_COMI_ID --Se cambiará debido a la politica IRF15 se tiene que identificar los contratos con Equipo
		,CASE
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' THEN 21
			ELSE 1
		 END TIPO_TRANS_COMI_ID
		,1 NEGOCIO_ID 
		,CASE 
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 3 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 6   THEN 0.1
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 12  THEN 0.2
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 18  THEN 0.5
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 18  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 3 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 6   THEN 0.4
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 12  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) < 18  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 18  THEN 1
			ELSE 0
		 END PRORRATEO
		,GETDATE() FECHA_RECALCULO 
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
		and DISTRIBUIDOR = @NombreDistribuidor
		AND B.SUB_CANAL IN ('Ejecutivos Distri Corp','Distribuidores Corp')
		AND A.PERIODO = @PeriodoCorte
		AND A.DN_NUM NOT LIKE '5032%'
		AND A.VENTA = 'S'
		--AND A.CO_ID = '14596795'
		AND A.FECHA_ID BETWEEN CONVERT(VARCHAR(8),B.FECHA_INI,112)
						   AND CONVERT(VARCHAR(8),ISNULL(B.FECHA_FIN,GETDATE()),112)
		AND NOT EXISTS (SELECT * FROM [DM_OPERACIONES_SV].[dbo].[CuboCorpExcluidos] WHERE CO_ID = A.CO_ID AND PERIODO = A.PERIODO)								   
		AND NOT EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.FactPospagoRenovaciones WHERE CO_ID = A.CO_ID AND PERIODO = A.PERIODO)
		AND NOT EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.PayComLineasExcluidas ple where ple.CANAL = B.CANAL and ple.PERIODO = a.PERIODO and ple.CO_ID = a.CO_ID and ple.TRANSACCION = 'VENTAS')
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
	03/03/2020 10:35 => Se cambio que en la clasificación de planes no se bonifiquen las lineas B de un paquete corpo
	==================================================================================================================*/
	
	DELETE FROM DM_COMISV_POSPAGO.dbo.PagoPospagoBonoPorVolumenDEXCorpoRecalculo WHERE PERIODO = @PeriodoCorte and DISTRIBUIDOR = @NombreDistribuidor;
	
	
	--INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoBonoPorVolumenDEXCorpo
	INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoBonoPorVolumenDEXCorpoRecalculo
	SELECT X.[PERIODO_PAGO]
		  ,X.[PERIODO]
		  ,X.[FECHA_ID]
		  ,X.[CO_ID]
		  ,X.[TMCODE]
		  ,X.[NOMBRE_PLAN]
		  ,X.[TIPO_CONTRATO]
		  ,X.[PLAZO_NUM]
		  ,X.[DEALER_CODE]
		  ,X.[DEALER_NAME]
		  ,X.[DISTRIBUIDOR]
		  ,X.[APLICA]
		  ,X.[CANT_VENTA]
		  ,X.[CANT_APLICA]
		  ,X.[TOTAL_REVENUE]
		  ,X.[META_LLAVE]
		  ,X.[ALCANCE_META]				  
		,CASE
			WHEN EXISTS (SELECT * 
						  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
						  WHERE TMCODE = X.TMCODE
						    AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
							AND plazo_contrato = CAST(ISNULL(X.PLAZO_NUM,0) AS INT)
						  ) AND X.ALCANCE_META >= 0.8
			THEN (SELECT bono
				  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
				  WHERE TMCODE = X.TMCODE
				    AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
									  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
					AND plazo_contrato = CAST(ISNULL(X.PLAZO_NUM,0) AS INT)
				  ) 
			WHEN X.PLAZO_NUM < 18 AND TIPO_CONTRATO = 'APORTADO' THEN 0
			WHEN X.NOMBRE_PLAN LIKE '%AVL%' THEN 0		
			WHEN X.CLASI_PLAN = 'CORP BOLSON B' THEN 0			
			WHEN X.ALCANCE_META >= 0.8 THEN 25
			ELSE 0
		 END COMISION
		,(CASE
			WHEN EXISTS (SELECT * 
						  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
						  WHERE TMCODE = X.TMCODE
								AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
											  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
								AND plazo_contrato = CAST(ISNULL(X.PLAZO_NUM,0) AS INT)
						  ) AND X.ALCANCE_META >= 0.8
			THEN (SELECT bono
				  FROM DM_COMISV_POSPAGO.dbo.DimPlanesDEXCorpo 
				  WHERE TMCODE = X.TMCODE
					AND X.FECHA_ID BETWEEN CONVERT(VARCHAR(8),FECHA_INI,112) 
									  AND ISNULL(CONVERT(VARCHAR(8),FECHA_FIN,112),CONVERT(VARCHAR(8),GETDATE(),112))
					AND plazo_contrato = CAST(ISNULL(X.PLAZO_NUM,0) AS INT)
				  ) 
			WHEN X.PLAZO_NUM < 18 AND TIPO_CONTRATO = 'APORTADO' THEN 0
			WHEN X.NOMBRE_PLAN LIKE '%AVL%' THEN 0
			WHEN X.CLASI_PLAN = 'CORP BOLSON B' THEN 0
			WHEN X.ALCANCE_META >= 0.8 THEN 25
			ELSE 0
		 END/1.13) COMISION_SIN_IVA
		 ,17 TIPOTRANS_ID
		,X.[CLASI_PLAN]
		,GETDATE() FECHA_RECALCULO 
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
				WHEN A.CLASI_PLAN = 'CORP BOLSON B' THEN 'NO'
				ELSE 'SI'
			 END APLICA
			,1 CANT_VENTA
			,CASE
				WHEN A.PLAZO_NUM < 18 AND A.TIPO_CONTRATO = 'APORTADO' THEN 0
				WHEN A.NOMBRE_PLAN LIKE '%AVL%' THEN 0
				WHEN A.CLASI_PLAN = 'CORP BOLSON B' THEN 0
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
			,A.CLASI_PLAN
		FROM DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXCorpoRecalculo A
		WHERE A.PERIODO = @PeriodoCorte
		 AND A.DISTRIBUIDOR = @NombreDistribuidor
		 --AND A.CO_ID = '14596795'
	) X
	
	--FIN PROCESO DE BONO POR VOLUMEN
	
end

/*

SELECT A.*, B.COMISION, B.COMISION_SIN_IVA, A.COMISION - B.COMISION DIFERENCIA_CIVA, A.COMISION_SIN_IVA - B.COMISION_SIN_IVA DIFERENCIA_SIVA
FROM PagoPospagoVentasDEXCorpoRecalculo A
	LEFT JOIN PagoPospagoVentasDEXCorpo B ON B.CO_ID = A.CO_ID AND B.PERIODO = A.PERIODO AND B.FECHA_ID = A.FECHA_ID AND B.DISTRIBUIDOR = A.DISTRIBUIDOR
where A.PERIODO = '202001' 
	and A.DISTRIBUIDOR like '%E-SMART%'
	AND A.COMISION <> B.COMISION
	



SELECT A.*, B.COMISION, B.COMISION_SIN_IVA, A.COMISION - B.COMISION DIFERENCIA_CIVA, A.COMISION_SIN_IVA - B.COMISION_SIN_IVA DIFERENCIA_SIVA
FROM PagoPospagoBonoPorVolumenDEXCorpoRecalculo A
	LEFT JOIN PagoPospagoBonoPorVolumenDEXCorpo B ON B.CO_ID = A.CO_ID AND B.PERIODO = A.PERIODO AND B.FECHA_ID = A.FECHA_ID AND B.DISTRIBUIDOR = A.DISTRIBUIDOR
where A.PERIODO = '202001' 
	and A.DISTRIBUIDOR like '%E-SMART%'
	AND A.COMISION <> B.COMISION
	


--update DimTipoTransaccion set TIPOTRANS_DESC = REPLACE(TIPOTRANS_DESC,'Complemento','Recalculo') where NEGOCIO_ID = 1 and TIPOTRANS_ID in (39,40,41)

select * from DimCategoriaTransaccion where CATEGORIA_TRANS_ID = 12

*/