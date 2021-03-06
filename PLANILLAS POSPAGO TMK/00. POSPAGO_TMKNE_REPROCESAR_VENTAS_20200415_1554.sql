SET NOCOUNT OFF;
	
--DECLARAMOS LAS VARIABLES
DECLARE @OpenQuery nvarchar(4000)
DECLARE @TSQL nvarchar(4000)
DECLARE @LinkedServer nvarchar(4000)
DECLARE @PeriodoCorte nvarchar(6)
DECLARE @PeriodoProce nvarchar(6)
DECLARE @PeriodoPago nvarchar(6)
DECLARE @PeriodoPagoProrrateados nvarchar(6)
DECLARE @FechaCorte nvarchar(8)
DECLARE @PeriodoActual nvarchar(6)
DECLARE @DiaActual nvarchar(8)
DECLARE @Distribuidor nvarchar(50)

--CONFIGURAMOS LAS VARIABLES
SET @LinkedServer = 'DWSV'
SET @PeriodoActual = (select convert(varchar(6),getdate(),112) )
SET @DiaActual = (select convert(varchar(8),getdate(),112) )


--CONFIGURAMOS OTROS PARAMETROS
select @FechaCorte = PosFechaCorte,
	@PeriodoCorte = PosPeriodoCorte,
	@PeriodoProce = PosPeriodoProc
from DimFechaCorte
where PosPeriodoProc = @PeriodoActuaL

set @PeriodoCorte = '202006'
SET @Distribuidor = 'DIGITEX'


--VERIFICAMOS LAS FECHAS DE CORTE E INSERTAMOS EN LA TABLA DE VENTAS

begin
	set @PeriodoPago  = convert(varchar(6),dateadd(m,1,convert(datetime,@PeriodoCorte+'01')),112)
	set @PeriodoPagoProrrateados = convert(varchar(6),dateadd(m,-2,convert(datetime,@PeriodoCorte+'01')),112) --Se setea el periodo para ventas que se ten�a que analizar una factura pagada
	
	DELETE FROM PagoPospagoVentasTMKNE WHERE PERIODO_PAGO = @PeriodoPago and DISTRIBUIDOR = @Distribuidor ;

	--PRINT N'Se han borrado los registros del periodo = ' + @PeriodoCorte;
	
	--1.1 Planes Normales
	INSERT INTO PagoPospagoVentasTMKNE
	SELECT 
		X.*
		,'SI' APLICA_PAGO
		,dbo.fnGetFactorComisionVentaTMK(x.fecha_id, x.canal, '1','MOVIL',x.TIPO_PLAN_ESQUEMA,x.RENTA_COMISION/1.13) FACTOR_VENTA
		,x.RENTA_COMISION * dbo.fnGetFactorComisionVentaTMK(x.fecha_id, x.canal, '1','MOVIL',x.TIPO_PLAN_ESQUEMA,x.RENTA_COMISION/1.13) * 
		 CASE 
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 0 and 2.99 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 3 and 5.99 THEN 0.1
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 6 and 11.99 THEN 0.2
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 12 and 17.99 THEN 0.5
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 18  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 0 and 2.99 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 3 and 5.99 THEN 0.4
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 6 THEN 1
			ELSE 0
		 END COMISION
		,((x.RENTA_COMISION * dbo.fnGetFactorComisionVentaTMK(x.fecha_id, x.canal, '1','MOVIL',x.TIPO_PLAN_ESQUEMA,x.RENTA_COMISION/1.13)  
		  )/1.13
		 ) * 
		 CASE 
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 0 and 2.99 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 3 and 5.99 THEN 0.1
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 6 and 11.99 THEN 0.2
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 12 and 17.99 THEN 0.5
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 18  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 0 and 2.99 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 3 and 5.99 THEN 0.4
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 6 THEN 1
			ELSE 0
		 END COMISION_SIN_IVA
		,1 UNIDAD
		--,1 TIPO_TRANS_COMI_ID --Se cambiar� debido a la politica IRF15 se tiene que identificar los contratos con Equipo
		,CASE
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' THEN 21
			ELSE 1
		 END TIPO_TRANS_COMI_ID
		,1 NEGOCIO_ID
		,CASE 
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 0 and 2.99 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 3 and 5.99 THEN 0.1
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 6 and 11.99 THEN 0.2
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 12 and 17.99 THEN 0.5
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 18  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 0 and 2.99 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 3 and 5.99 THEN 0.4
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 6 THEN 1
			ELSE 0
		 END PRORRATEO
		,GETDATE() FECHA_PROCESO
	FROM (
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
			,A.RENTA_COMISION				
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
			,B.ACREEDOR_ID
			,B.CANAL
			,B.SUB_CANAL
			,B.REGION				
			,CASE
				WHEN UPPER(A.TIPO_ALTA) = 'PORTABILIDAD' THEN 'PORTABILIDAD'
				ELSE 'ACTIVACION'
			 END TIPO_ALTA
			,'NORMAL' CLASI_PLAN
			,CASE
				WHEN UPPER(A.TIPO_ALTA) = 'PORTABILIDAD' THEN 'Portabilidad'
				WHEN UPPER(A.TIPO_CONTRATO) = 'CON EQUIPO' THEN 'Con Equipo'
				WHEN UPPER(A.TIPO_CONTRATO) = 'APORTADO' THEN 'Aportado'
				ELSE 'Desconocido'
			 END TIPO_PLAN_ESQUEMA
		   ,ROW_NUMBER() OVER (PARTITION BY A.PERIODO,B.DISTRIBUIDOR ORDER BY B.DISTRIBUIDOR,A.PERIODO,A.CO_ACTIVATED ) AS NUM_VENTA
		   ,(SELECT SUM(RENTA_COMISION) 
			 FROM FactPospagoVentas AA
				INNER JOIN DimDealer BB ON BB.DEALER_CODE = AA.DEALER_CODE
			 WHERE AA.PERIODO = A.PERIODO
				AND BB.CANAL = B.CANAL
				AND BB.SUB_CANAL = B.SUB_CANAL
				AND BB.DEALER_NAME = B.DEALER_NAME
			) REVENUE
		   ,C.Meta META					   
		FROM  FactPospagoVentas A
			INNER JOIN DimDealer B ON B.DEALER_CODE = A.DEALER_CODE 
			LEFT JOIN [DMSVMUL_COMISIONES].[dbo].[TblAlcancePospago] C ON C.Nombre_Agencia = B.DEALER_NAME
		WHERE B.CANAL = 'ALIADOS'
			AND B.SUB_CANAL = 'Telemarketing'
			AND A.PERIODO = @PeriodoCorte	
			and b.DISTRIBUIDOR = @Distribuidor			
			AND A.VENTA = 'S'				
			AND A.DN_NUM NOT LIKE '5032%'				
			AND A.FECHA_ID BETWEEN CONVERT(VARCHAR(8),B.FECHA_INI,112)
							   AND CONVERT(VARCHAR(8),ISNULL(B.FECHA_FIN,GETDATE()),112)
			AND NOT EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.FactPospagoRenovaciones WHERE CO_ID = A.CO_ID AND PERIODO = A.PERIODO)
			AND NOT EXISTS (
				SELECT * 
				FROM Datamart_Multimedia.dbo.FactMultimediaVentas B
				WHERE B.PERIODO = A.PERIODO       
					AND  B.DUI = A.PASSPORTNO
					AND UPPER(B.PAQUETE_NVO) LIKE '%LFI%SAT%'
			)
			AND NOT EXISTS (
				SELECT * 
				FROM Datamart_Multimedia.dbo.FactMultimediaVentas B
				WHERE B.PERIODO = A.PERIODO       
					AND  B.DUI = A.PASSPORTNO
					AND UPPER(B.PAQUETE_NVO) LIKE '%LFI%SAT%'
			)				
	) X	
	
	--1.2 Planes Prorrateados
	INSERT INTO PagoPospagoVentasTMKNE
	SELECT 
		X.*
		,CASE
			WHEN X.FACT_PAGADAS >= 1 THEN 'SI'
			ELSE 'NO'
		 END APLICA_PAGO
		,dbo.fnGetFactorComisionVentaTMK(x.fecha_id, x.canal, '1','MOVIL',x.TIPO_PLAN_ESQUEMA,x.RENTA_COMISION/1.13) FACTOR_VENTA
		,x.RENTA_COMISION * dbo.fnGetFactorComisionVentaTMK(x.fecha_id, x.canal, '1','MOVIL',x.TIPO_PLAN_ESQUEMA,x.RENTA_COMISION/1.13) * 
		 CASE 
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 0 and 2.99 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 3 and 5.99 THEN 0.1
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 6 and 11.99 THEN 0.2
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 12 and 17.99 THEN 0.5
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 18  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 0 and 2.99 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 3 and 5.99 THEN 0.4
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 6 THEN 1
			ELSE 0
		 END COMISION
		,((x.RENTA_COMISION * dbo.fnGetFactorComisionVentaTMK(x.fecha_id, x.canal, '1','MOVIL',x.TIPO_PLAN_ESQUEMA,x.RENTA_COMISION/1.13)  
		  )/1.13
		 ) * 
		 CASE 
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 0 and 2.99 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 3 and 5.99 THEN 0.1
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 6 and 11.99 THEN 0.2
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 12 and 17.99 THEN 0.5
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 18  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 0 and 2.99 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 3 and 5.99 THEN 0.4
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 6 THEN 1
			ELSE 0
		 END COMISION_SIN_IVA
		,CASE
			WHEN X.FACT_PAGADAS >= 1 THEN 1
			ELSE 0
		 END UNIDAD
		--,1 TIPO_TRANS_COMI_ID --Se cambiar� debido a la politica IRF15 se tiene que identificar los contratos con Equipo
		,CASE
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' THEN 21
			ELSE 1
		 END TIPO_TRANS_COMI_ID
		,1 NEGOCIO_ID
		,CASE 
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 0 and 2.99 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 3 and 5.99 THEN 0.1
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 6 and 11.99 THEN 0.2
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 12 and 17.99 THEN 0.5
			WHEN X.TIPO_CONTRATO = 'CON EQUIPO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 18  THEN 1
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 0 and 2.99 AND FACT_PAGADAS >= 1 THEN 0.05
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) between 3 and 5.99 THEN 0.4
			WHEN X.TIPO_CONTRATO = 'APORTADO' AND CAST(ISNULL(X.PLAZO_NUM,0) AS INT) >= 6 THEN 1
			ELSE 0
		 END PRORRATEO
		,GETDATE() FECHA_PROCESO
	FROM (
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
			,A.RENTA_COMISION				
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
			,B.ACREEDOR_ID
			,B.CANAL
			,B.SUB_CANAL
			,B.REGION				
			,CASE
				WHEN UPPER(A.TIPO_ALTA) = 'PORTABILIDAD' THEN 'PORTABILIDAD'
				ELSE 'ACTIVACION'
			 END TIPO_ALTA
			,'NORMAL' CLASI_PLAN
			,CASE
				WHEN UPPER(A.TIPO_ALTA) = 'PORTABILIDAD' THEN 'Portabilidad'
				WHEN UPPER(A.TIPO_CONTRATO) = 'CON EQUIPO' THEN 'Con Equipo'
				WHEN UPPER(A.TIPO_CONTRATO) = 'APORTADO' THEN 'Aportado'
				ELSE 'Desconocido'
			 END TIPO_PLAN_ESQUEMA
		   ,ROW_NUMBER() OVER (PARTITION BY A.PERIODO,B.DISTRIBUIDOR ORDER BY B.DISTRIBUIDOR,A.PERIODO,A.CO_ACTIVATED ) AS NUM_VENTA
		   ,(SELECT SUM(RENTA_COMISION) 
			 FROM FactPospagoVentas AA
				INNER JOIN DimDealer BB ON BB.DEALER_CODE = AA.DEALER_CODE
			 WHERE AA.PERIODO = A.PERIODO
				AND BB.CANAL = B.CANAL
				AND BB.SUB_CANAL = B.SUB_CANAL
				AND BB.DEALER_NAME = B.DEALER_NAME
			) REVENUE
		   ,C.Meta META					   
		FROM  FactPospagoVentas A
			INNER JOIN DimDealer B ON B.DEALER_CODE = A.DEALER_CODE 
			LEFT JOIN [DMSVMUL_COMISIONES].[dbo].[TblAlcancePospago] C ON C.Nombre_Agencia = B.DEALER_NAME
		WHERE B.CANAL = 'ALIADOS'
			AND B.SUB_CANAL = 'Telemarketing'
			AND A.PERIODO = @PeriodoPagoProrrateados
			and b.DISTRIBUIDOR = @Distribuidor							
			AND A.VENTA = 'S'				
			AND A.DN_NUM NOT LIKE '5032%'				
			AND A.FECHA_ID BETWEEN CONVERT(VARCHAR(8),B.FECHA_INI,112)
							   AND CONVERT(VARCHAR(8),ISNULL(B.FECHA_FIN,GETDATE()),112)
			AND NOT EXISTS (SELECT * FROM DM_COMISV_POSPAGO.dbo.FactPospagoRenovaciones WHERE CO_ID = A.CO_ID AND PERIODO = A.PERIODO)
			AND ( PLAZO_NUM < 3 or PLAZO_NUM is null)
			AND NOT EXISTS (SELECT * FROM PagoPospagoVentasTMKNE where PERIODO_PAGO = @PeriodoPago and PERIODO = @PeriodoPagoProrrateados AND CO_ID = a.co_id)
			AND NOT EXISTS (
				SELECT * 
				FROM Datamart_Multimedia.dbo.FactMultimediaVentas B
				WHERE B.PERIODO = A.PERIODO       
					AND  B.DUI = A.PASSPORTNO
					AND UPPER(B.PAQUETE_NVO) LIKE '%LFI%SAT%'
			)
			AND NOT EXISTS (
				SELECT * 
				FROM Datamart_Multimedia.dbo.FactMultimediaVentas B
				WHERE B.PERIODO = A.PERIODO       
					AND  B.DUI = A.PASSPORTNO
					AND UPPER(B.PAQUETE_NVO) LIKE '%LFI%SAT%'
			)				
	) X							
end