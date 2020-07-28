--Variables para lo general
DECLARE @DEX_PERIODO_PAGO VARCHAR(6)
DECLARE @DEX_CANAL VARCHAR(20)
DECLARE @DEX_NEGOCIO VARCHAR(20)
DECLARE @DEX_ACREEDOR VARCHAR(20)



---Variables del cursor interno
declare @control_de_documento int
declare @clase_de_documento varchar(5)
declare @doc_presupuestario varchar(20)
declare @posicion_doc varchar(5)
declare @f_documento varchar(10)
declare	@f_contabilizacion varchar(10)
declare @sociedad varchar(5)
declare @moneda varchar(3)
declare	@tipo_cambio varchar(10)
declare @f_conversion varchar(10)
declare @c_acreedor varchar(20)
declare @importe float
declare @cuenta_de_mayor varchar(20)
declare @centro_de_costos varchar(20)
declare @elemento_pep varchar(20)
declare @texto_de_cabecera_documento varchar(60)
declare @referencia_cabecera varchar(50)
declare @texto_posicion varchar(50)
declare @f_vencimiento varchar(10)
declare @negocio varchar(5)
declare @actividad varchar(10)
declare @cant int
declare @codigo_planilla varchar(50)
declare @total_descuentos float
declare @fecha_registro datetime

--VARIABLES PARA ENCONTRAR SALDOS POSITIVOS Y NO MOSTRAR NEGATIVOS EN LA PLANILLA
declare @monto_a_descontar float
declare @saldo float
declare @total_comision float
declare @acreedor_ini varchar(50)
declare @acreedor_act varchar(50)
declare @nueva_comision float
declare @v_acum_ingresos float
declare @total_descontado float
declare @descuentos_mes float

declare @v_count int
declare @v_exists int


/*======================================================================================================================================================================================
CURSOR GENERAL PARA ENCONTRAR DISTRIBUIDORES QUE HAN GANADO COMISION EN EL MES DE PAGO SEGUN CORRESPONDA
======================================================================================================================================================================================*/
DECLARE cur_pospago_dex CURSOR FOR
SELECT A.PERIODO_PAGO
	,A.CANAL
	,C.NEGOCIO_NOMBRE
	,A.ACREEDOR_ID
FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoConsolidadoDEXMasivo] a
	INNER JOIN DM_COMISV_POSPAGO.dbo.DimTipoTransaccion B ON B.TIPOTRANS_ID = A.TIPOTRANS_ID 
	INNER JOIN DM_COMISV_POSPAGO.dbo.DimNegocio C ON C.NEGOCIO_ID = B.NEGOCIO_ID
WHERE a.PERIODO_PAGO = '201809'
	--AND A.DISTRIBUIDOR LIKE '%CRECE%'
	--and A.ACREEDOR_ID = '700000180'
GROUP BY A.PERIODO_PAGO, A.CANAL, C.NEGOCIO_NOMBRE, A.ACREEDOR_ID

set @descuentos_mes = 0


OPEN cur_pospago_dex

	FETCH cur_pospago_dex INTO @DEX_PERIODO_PAGO, @DEX_CANAL, @DEX_NEGOCIO, @DEX_ACREEDOR
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			PRINT @DEX_ACREEDOR		
			
			
			set @total_descuentos = ISNULL((SELECT SUM(FPD.MONTO_FACTURAS+fpd.MONTO_EQUIPOS+fpd.MONTO_COMISION) 
									  FROM [DM_COMISV_POSPAGO].[dbo].[FactPospagoDescuentos] fpd
											INNER JOIN [DM_COMISV_POSPAGO].[dbo].[DimDealer] ddr on ddr.DEALER_CODE = fpd.DEALER_CODE
									  WHERE fpd.PERIODO_DESCUENTO = @DEX_PERIODO_PAGO
										AND fpd.PERIODO BETWEEN CONVERT(varchar(6),ddr.FECHA_INI,112) AND ISNULL(CONVERT(varchar(6),ddr.FECHA_FIN,112),CONVERT(varchar(6),GETDATE(),112))
										AND ddr.ACREEDOR_ID = @DEX_ACREEDOR
										AND ddr.CANAL = @DEX_CANAL			 
									  ),0) + ISNULL((SELECT SUM(SALDO_PENDIENTE_COBRO)
									          FROM DM_COMISV_POSPAGO.dbo.FactPospagoEstadoCuenta 
									          WHERE PERIODO_PAGO = CONVERT(VARCHAR(6),DATEADD(MM,-1,CONVERT(DATE,@DEX_PERIODO_PAGO+'01')),112)
									           AND CANAL = @DEX_CANAL
									           AND NEGOCIO = @DEX_NEGOCIO
									           AND ACREEDOR_ID = @DEX_ACREEDOR
									          ),0)								  
			
			--set @total_descuentos = 3200				
			set @descuentos_mes = @total_descuentos
		
			DECLARE cur_pospago_dex_planilla_sap CURSOR FOR
			SELECT 
				 ROW_NUMBER() OVER (PARTITION BY X.PERIODO_FILE, X.CANAL, X.NEGOCIO_NOMBRE, X.ACREEDOR_ID ORDER BY X.PERIODO_FILE, X.CANAL, X.NEGOCIO_NOMBRE, X.ACREEDOR_ID, X.COMISION DESC) CONTROL_DE_DOCUMENTO
				,'AA' CLASE_DOCUMENTO	
				,'' DOC_PRESUPUESTARIO
				,'' POSICION_DOC
				,'' F_DOCUMENTO
				,'' F_CONTABILIZACION
				,'SV03'	SOCIEDAD
				,'USD' MONEDA
				,'' TIPO_CAMBIO
				,'' F_CONVERSION
				,X.ACREEDOR_ID C_ACREEDOR
				,X.COMISION IMPORTE
				,X.CUENTA_SAP CUENTA_DE_MAYOR
				,X.CENTRO_COSTO_SAP CENTRO_DE_COSTOS
				,'' ELEMENTO_PEP
				,'CMO'+CONVERT(VARCHAR(6),DATEADD(MM,-1,CONVERT(DATE,PERIODO_FILE+'01')),112) + ' - ' + 'Comisiones Pospago' + ' - ' + PERIODO_FILE  TEXTO_DE_CABECERA_DOCUMENTO
				,'AAAAABBBBBCCCCCDDDDD' REFERENCIA_CABECERA
				,X.TIPOTRANS_DESC + ' - ' + X.PERIODO TEXTO_DE_POSICION
				,CONVERT(varchar,dateadd(d,-(day(dateadd(m,1,getdate()))),dateadd(m,1,getdate())),104 ) F_VENCIMIENTO
				,'SV003' NEGOCIO
				,3 ACTIVIDAD
				,X.UNIDADES_APLICAN CANT
				,X.ACREEDOR_ID + '-' +
				 CASE
					WHEN X.CANAL = 'DISTRIBUIDORES' THEN 'DEXC'
					WHEN X.CANAL = 'CORPORATIVO' THEN 'DCOR'
					WHEN X.CANAL = 'CADENAS' THEN 'CADC'
					WHEN X.CANAL = 'KIOSCOS' THEN 'CADT'
					WHEN X.CANAL = 'ALIADOS' THEN 'ALIA'
					WHEN X.CANAL = 'AGENCIAS' THEN 'TERC'
				 END + '-' + 
				 CONVERT(varchar,dateadd(d,-(day(getdate()-1)),getdate()),112) CODIGO_PLANILLA				
				 ,GETDATE() FECHA_REGISTRO
			FROM (
			SELECT PERIODO_PAGO
				,CONVERT(VARCHAR(6),DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_PAGO+'01')),112) PERIODO_FILE
				,CASE 
					WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_PAGO+'01'))) = 1 then 'Enero' + ' - ' + substring(PERIODO_PAGO,1,4)
					WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_PAGO+'01'))) = 2 then 'Febrero' + ' - ' + substring(PERIODO_PAGO,1,4)
					WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_PAGO+'01'))) = 3 then 'Marzo' + ' - ' + substring(PERIODO_PAGO,1,4)
					WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_PAGO+'01'))) = 4 then 'Abril' + ' - ' + substring(PERIODO_PAGO,1,4)
					WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_PAGO+'01'))) = 5 then 'Mayo' + ' - ' + substring(PERIODO_PAGO,1,4)
					WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_PAGO+'01'))) = 6 then 'Junio' + ' - ' + substring(PERIODO_PAGO,1,4)
					WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_PAGO+'01'))) = 7 then 'Julio' + ' - ' + substring(PERIODO_PAGO,1,4)
					WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_PAGO+'01'))) = 8 then 'Agosto' + ' - ' + substring(PERIODO_PAGO,1,4)
					WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_PAGO+'01'))) = 9 then 'Septiembre' + ' - ' + substring(PERIODO_PAGO,1,4)
					WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_PAGO+'01'))) = 10 then 'Octubre' + ' - ' + substring(PERIODO_PAGO,1,4)
					WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_PAGO+'01'))) = 11 then 'Noviembre' + ' - ' + substring(PERIODO_PAGO,1,4)
					WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_PAGO+'01'))) = 12 then 'Diciembre' + ' - ' + substring(PERIODO_PAGO,1,4)
				END PERIODO_LABEL	 
				,PERIODO
				,DISTRIBUIDOR
				,A.ACREEDOR_ID
				,CANAL
				,TRANSACCION
				,SUM(UNIDAD_GLOBAL) UNIDAD_TOTALES
				,CASE		
					WHEN TRANSACCION = 'PERMANENCIA' THEN SUM(UNIDAD_APLICA_PERMA)
					ELSE SUM(UNIDAD_GLOBAL)
				 END  UNIDADES_APLICAN
				,SUM(COMISION_SIN_IVA) COMISION
				,A.TIPOTRANS_ID
				,B.TIPOTRANS_DESC
				,B.CUENTA_SAP
				,B.CENTRO_COSTO_SAP	
				,C.NEGOCIO_NOMBRE
			FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoConsolidadoDEXMasivo] a
				INNER JOIN DM_COMISV_POSPAGO.dbo.DimTipoTransaccion B ON B.TIPOTRANS_ID = A.TIPOTRANS_ID 
				INNER JOIN DM_COMISV_POSPAGO.dbo.DimNegocio C ON C.NEGOCIO_ID = B.NEGOCIO_ID
			WHERE a.PERIODO_PAGO = @DEX_PERIODO_PAGO
			 AND A.CANAL = @DEX_CANAL
			 AND A.ACREEDOR_ID = @DEX_ACREEDOR
			GROUP BY A.PERIODO_PAGO, A.CANAL, A.PERIODO, A.DISTRIBUIDOR, A.ACREEDOR_ID, A.TRANSACCION, A.TIPOTRANS_ID, B.TIPOTRANS_DESC, B.CUENTA_SAP, B.CENTRO_COSTO_SAP, C.NEGOCIO_NOMBRE
			) X
			ORDER BY X.CANAL, X.DISTRIBUIDOR, X.COMISION DESC


			OPEN cur_pospago_dex_planilla_sap

				FETCH cur_pospago_dex_planilla_sap INTO  @control_de_documento 
														,@clase_de_documento 
														,@doc_presupuestario 
														,@posicion_doc 
														,@f_documento 
														,@f_contabilizacion 
														,@sociedad 
														,@moneda
														,@tipo_cambio 
														,@f_conversion 
														,@c_acreedor 
														,@importe 
														,@cuenta_de_mayor 
														,@centro_de_costos 
														,@elemento_pep 
														,@texto_de_cabecera_documento 
														,@referencia_cabecera 
														,@texto_posicion 
														,@f_vencimiento 
														,@negocio 
														,@actividad 
														,@cant 
														,@codigo_planilla 														
														,@fecha_registro 
														
				set @monto_a_descontar = 0
				set @saldo = 0
				set @total_comision = 0				
				set @acreedor_act = ''
				set @nueva_comision = 0	
				set @v_acum_ingresos = 0
				set @total_descontado = 0	
				
				set @v_exists = isnull((select COUNT(*) 
										 from [DM_COMISV_POSPAGO].[dbo].[PlantillaSAPPospagoDEX]
										 where CODIGO_PLANILLA = @codigo_planilla
										 ),0)					
						
				if @v_exists > 0 
					begin
						delete from [DM_COMISV_POSPAGO].[dbo].[PlantillaSAPPospagoDEX] where CODIGO_PLANILLA = @codigo_planilla
					end
				
				WHILE ( @@FETCH_STATUS = 0 )
					BEGIN							
						
						if @importe >= @total_descuentos
							begin
								set @monto_a_descontar = @total_descuentos
								set @total_descontado =  @total_descontado + @monto_a_descontar
								set @nueva_comision = @importe - @monto_a_descontar
								set @total_descuentos = 0
								set @saldo = 0
								set @v_acum_ingresos = @v_acum_ingresos + @importe	
							end
						else
							begin
								set @nueva_comision = 0
								set @monto_a_descontar = @importe
								set @total_descontado =  @total_descontado + @monto_a_descontar
								set @total_descuentos = @total_descuentos - @importe
								set @saldo = @total_descuentos
								set @v_acum_ingresos = @v_acum_ingresos + @importe
							end
						
						set @v_count = (select COUNT(*) 
										from DM_COMISV_POSPAGO.dbo.FactPospagoEstadoCuenta 
										where PERIODO_PAGO = @DEX_PERIODO_PAGO
											and canal = @DEX_CANAL
											and negocio = @DEX_NEGOCIO
											and acreedor_id = @DEX_ACREEDOR
										)
										
						if @v_count > 0 
							begin
								update a
								set  a.TOTAL_INGRESOS = @v_acum_ingresos
									,a.TOTAL_DESCUENTOS = @descuentos_mes
									,a.MONTO_DESCONTADO = @total_descontado									
									,a.SALDO_PENDIENTE_COBRO = @saldo
								from DM_COMISV_POSPAGO.dbo.FactPospagoEstadoCuenta a
								where periodo_pago = @DEX_PERIODO_PAGO
									and canal = @DEX_CANAL
									and negocio = @DEX_NEGOCIO
									and acreedor_id = @DEX_ACREEDOR
							end
						else
							begin
								INSERT INTO DM_COMISV_POSPAGO.dbo.FactPospagoEstadoCuenta 
								VALUES(@DEX_PERIODO_PAGO, @DEX_CANAL, @DEX_NEGOCIO, @DEX_ACREEDOR, @v_acum_ingresos, @descuentos_mes, @total_descontado, @saldo)
							end
						
						print 'Acreedor => ' + @DEX_ACREEDOR + ', Importe => ' + convert(varchar,@importe) + ', Descuentos => ' + convert(varchar,@monto_a_descontar) + ', NuevaComision => ' + convert(varchar,@nueva_comision) + ', Saldo => '+ convert(varchar,@saldo)
					
						
					    if (@nueva_comision) > 0
					     begin
					     	INSERT INTO [DM_COMISV_POSPAGO].[dbo].[PlantillaSAPPospagoDEX]
								   ([CONTROL_DE_DOCUMENTO]
								   ,[CLASE_DOCUMENTO]
								   ,[DOC_PRESUPUESTARIO]
								   ,[POSICION_DOC]
								   ,[F_DOCUMENTO]
								   ,[F_CONTABILIZACION]
								   ,[SOCIEDAD]
								   ,[MONEDA]
								   ,[TIPO_CAMBIO]
								   ,[F_CONVERSION]
								   ,[C_ACREEDOR]
								   ,[IMPORTE]
								   ,[CUENTA_DE_MAYOR]
								   ,[CENTRO_DE_COSTOS]
								   ,[ELEMENTO_PEP]
								   ,[TEXTO_DE_CABECERA_DOCUMENTO]
								   ,[REFERENCIA_CABECERA]
								   ,[TEXTO_DE_POSICION]
								   ,[F_VENCIMIENTO]
								   ,[NEGOCIO]
								   ,[ACTIVIDAD]
								   ,[CANT]
								   ,[CODIGO_PLANILLA]
								   ,[FECHA_REGISTRO])
							 VALUES
								   (@control_de_documento
								   ,@clase_de_documento
								   ,@doc_presupuestario
								   ,@posicion_doc
								   ,@f_documento
								   ,@f_contabilizacion
								   ,@sociedad
								   ,@moneda
								   ,@tipo_cambio
								   ,@f_conversion
								   ,@c_acreedor
								   ,@nueva_comision
								   ,@cuenta_de_mayor
								   ,@centro_de_costos
								   ,@elemento_pep
								   ,@texto_de_cabecera_documento
								   ,@referencia_cabecera
								   ,@texto_posicion
								   ,@f_vencimiento
								   ,@negocio
								   ,@actividad
								   ,@cant
								   ,@codigo_planilla
								   ,GETDATE())
					     end
									
											
						FETCH cur_pospago_dex_planilla_sap INTO  @control_de_documento 
														,@clase_de_documento 
														,@doc_presupuestario 
														,@posicion_doc 
														,@f_documento 
														,@f_contabilizacion 
														,@sociedad 
														,@moneda
														,@tipo_cambio 
														,@f_conversion 
														,@c_acreedor 
														,@importe 
														,@cuenta_de_mayor 
														,@centro_de_costos 
														,@elemento_pep 
														,@texto_de_cabecera_documento 
														,@referencia_cabecera 
														,@texto_posicion 
														,@f_vencimiento 
														,@negocio 
														,@actividad 
														,@cant 
														,@codigo_planilla 													
														,@fecha_registro 
					END				 					
				
			CLOSE cur_pospago_dex_planilla_sap

			DEALLOCATE cur_pospago_dex_planilla_sap
			
		
		FETCH cur_pospago_dex INTO @DEX_PERIODO_PAGO, @DEX_CANAL, @DEX_NEGOCIO, @DEX_ACREEDOR
		END
	
CLOSE cur_pospago_dex

DEALLOCATE cur_pospago_dex