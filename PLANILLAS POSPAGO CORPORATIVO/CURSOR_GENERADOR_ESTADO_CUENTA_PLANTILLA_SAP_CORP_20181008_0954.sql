--Variables para lo general
DECLARE @DEX_PERIODO_PAGO VARCHAR(6)
DECLARE @DEX_CANAL VARCHAR(20)
DECLARE @DEX_NEGOCIO VARCHAR(20)
DECLARE @DEX_ACREEDOR VARCHAR(20)
DECLARE @DEX_ACREEDOR_NOMBRE VARCHAR(50)



---Variables del cursor interno
declare @control_de_documento int
declare @clase_de_documento varchar(5)
declare @doc_presupuestario varchar(20)
declare @posicion_doc varchar(5)
declare @f_documento datetime
declare	@f_contabilizacion datetime
declare @sociedad varchar(5)
declare @moneda varchar(3)
declare	@tipo_cambio varchar(10)
declare @f_conversion datetime
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
DECLARE cur_pospago_corpo CURSOR FOR
SELECT A.PERIODO_PAGO
	,A.CANAL
	,A.NEGOCIO_NOMBRE
	,A.ACREEDOR_ID
	,A.DISTRIBUIDOR
FROM [DM_COMISV_POSPAGO].[dbo].[PlanillasPospagoResumenCorporativo] a
WHERE a.PERIODO_PAGO = '201810'
	AND A.COMISION >= 0
	--AND A.DISTRIBUIDOR LIKE '%CRECE%'
	--and A.ACREEDOR_ID = '700000137'
GROUP BY A.PERIODO_PAGO, A.CANAL, A.NEGOCIO_NOMBRE, A.ACREEDOR_ID, A.DISTRIBUIDOR

set @descuentos_mes = 0


OPEN cur_pospago_corpo

	FETCH cur_pospago_corpo INTO @DEX_PERIODO_PAGO, @DEX_CANAL, @DEX_NEGOCIO, @DEX_ACREEDOR, @DEX_ACREEDOR_NOMBRE
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			--PRINT @DEX_ACREEDOR		
			
			
			set @total_descuentos = ISNULL(( SELECT SUM(A.COMISION)*-1 
									  FROM PlanillasPospagoResumenCorporativo A
									  WHERE ACREEDOR_ID = @DEX_ACREEDOR
										AND PERIODO_PAGO = @DEX_PERIODO_PAGO
										AND NEGOCIO_NOMBRE = @DEX_NEGOCIO
										AND CANAL = @DEX_CANAL
										and comision < 0							  
									 ),0)
			
			--SELECT @TOTAL_DESCUENTOS 
			--set @total_descuentos = 3200				
			set @descuentos_mes = @total_descuentos
			
			--print 'Descuentos mes : ' + convert(varchar,@descuentos_mes)
		
			DECLARE cur_pospago_corpo_planilla_sap CURSOR FOR
			SELECT 
				 ROW_NUMBER() OVER (PARTITION BY X.PERIODO_FILE, X.CANAL, X.NEGOCIO_NOMBRE, X.ACREEDOR_ID ORDER BY X.PERIODO_FILE, X.CANAL, X.NEGOCIO_NOMBRE, X.ACREEDOR_ID, X.COMISION DESC) CONTROL_DE_DOCUMENTO
				,'AA' CLASE_DOCUMENTO	
				,'' DOC_PRESUPUESTARIO
				,'' POSICION_DOC
				,X.CCF_FECHA F_DOCUMENTO
				,NULL F_CONTABILIZACION
				,X.NEGOCIO_SOCIEDAD SOCIEDAD
				,'USD' MONEDA
				,'' TIPO_CAMBIO
				,NULL F_CONVERSION
				,X.ACREEDOR_ID C_ACREEDOR
				,X.COMISION IMPORTE
				,X.CUENTA_SAP CUENTA_DE_MAYOR
				,X.CENTRO_COSTO_SAP CENTRO_DE_COSTOS
				,'' ELEMENTO_PEP
				,'CMO'+CONVERT(VARCHAR(6),DATEADD(MM,-1,CONVERT(DATE,PERIODO_FILE+'01')),112) + ' - ' + 'Comisiones Pospago' + ' - ' + PERIODO_FILE  TEXTO_DE_CABECERA_DOCUMENTO
				,X.CCF_NUMERO REFERENCIA_CABECERA
				,X.TIPOTRANS_DESC + ' - ' + X.PERIODO TEXTO_DE_POSICION
				,CONVERT(varchar,dateadd(d,-(day(dateadd(m,1,getdate()))),dateadd(m,1,getdate())),104 ) F_VENCIMIENTO
				,X.NEGOCIO_CODE NEGOCIO
				,X.NEGOCIO_ACTIVIDAD ACTIVIDAD
				,X.UNIDADES_APLICAN CANT
				,X.CODIGO_PLANILLA				
				,GETDATE() FECHA_REGISTRO
			FROM (
				SELECT A.PERIODO_PAGO
					,A.PERIODO_FILE
					,A.PERIODO_LABEL
					,A.PERIODO
					,A.DISTRIBUIDOR
					,A.ACREEDOR_ID
					,A.CANAL	
					,A.TRANSACCION
					,A.UNIDAD_TOTALES
					,A.UNIDADES_APLICAN
					,A.COMISION
					,A.TIPOTRANS_ID
					,A.TRANSACCION TIPOTRANS_DESC
					,A.CUENTA_SAP
					,A.CENTRO_COSTO_SAP
					,A.NEGOCIO_ID
					,A.NEGOCIO_NOMBRE
					,A.NEGOCIO_CODE
					,A.NEGOCIO_ACTIVIDAD
					,A.NEGOCIO_SOCIEDAD
					,A.CCF_FECHA
					,A.CCF_NUMERO
					,A.CODIGO_PLANILLA
				 FROM PlanillasPospagoResumenCorporativo A
				 WHERE ACREEDOR_ID = @DEX_ACREEDOR
					AND PERIODO_PAGO = @DEX_PERIODO_PAGO
					AND NEGOCIO_NOMBRE = @DEX_NEGOCIO
					AND CANAL = @DEX_CANAL
					--AND CCF_NUMERO != 'AAAAABBBBBCCCCCDDDDD'
					--AND CCF_NUMERO != ''
					--AND CCF_NUMERO IS NOT NULL
					AND A.CCF_FECHA IS NOT NULL
					AND COMISION > 0			
			) X
			ORDER BY X.CANAL, X.DISTRIBUIDOR, X.COMISION DESC


			OPEN cur_pospago_corpo_planilla_sap

				FETCH cur_pospago_corpo_planilla_sap INTO  @control_de_documento 
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
						
						set @v_count = isnull((select COUNT(*) 
										from DM_COMISV_POSPAGO.dbo.FactPospagoEstadoCuenta 
										where PERIODO_PAGO = @DEX_PERIODO_PAGO
											and canal = @DEX_CANAL
											and negocio = @DEX_NEGOCIO
											and acreedor_id = @DEX_ACREEDOR
										),0)
										
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
									
								--print 'Entro en el update del estado de cuenta ' + @DEX_ACREEDOR + @DEX_ACREEDOR_NOMBRE
							end
						else
							begin
								
								INSERT INTO DM_COMISV_POSPAGO.dbo.FactPospagoEstadoCuenta 
								VALUES(@DEX_PERIODO_PAGO, @DEX_CANAL, @DEX_NEGOCIO, @DEX_ACREEDOR, @v_acum_ingresos, @descuentos_mes, @total_descontado, @saldo)
								
								--print 'Inserto en el estado de cuenta ' + @DEX_ACREEDOR
							end
						
						--print 'Acreedor => ' + @DEX_ACREEDOR + ', Importe => ' + convert(varchar,@importe) + ', Descuentos => ' + convert(varchar,@monto_a_descontar) + ', NuevaComision => ' + convert(varchar,@nueva_comision) + ', Saldo => '+ convert(varchar,@saldo)
						
						--print 'Nueva Comision ' + converT(varchar,@nueva_comision)
						
					    if @nueva_comision > 0
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
								   ,[FECHA_REGISTRO]
								   ,[PERIODO_PAGO]
								   ,[ACREEDOR_NOMBRE])
							 VALUES
								   ('1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,null
								   ,null
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1'
								   ,'1-corp'
								   ,GETDATE()
								   ,'201810'
								   ,'xx')								 
					     end
									
											
						FETCH cur_pospago_corpo_planilla_sap INTO  @control_de_documento 
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
				
			CLOSE cur_pospago_corpo_planilla_sap

			DEALLOCATE cur_pospago_corpo_planilla_sap
			
		
		FETCH cur_pospago_corpo INTO @DEX_PERIODO_PAGO, @DEX_CANAL, @DEX_NEGOCIO, @DEX_ACREEDOR, @DEX_ACREEDOR_NOMBRE
		END
	
CLOSE cur_pospago_corpo

DEALLOCATE cur_pospago_corpo

/*
select * 
from FactPospagoEstadoCuenta a 
INNER join DimAcreedor b on b.acreedor_id = a.acreedor_id 
where A.CANAL = 'CORPORATIVO'

SELECT *
FROM PlantillaSAPPospagoDEX
WHERE PERIODO_PAGO = '201810'
 AND CODIGO_PLANILLA LIKE '%CORP%'*/