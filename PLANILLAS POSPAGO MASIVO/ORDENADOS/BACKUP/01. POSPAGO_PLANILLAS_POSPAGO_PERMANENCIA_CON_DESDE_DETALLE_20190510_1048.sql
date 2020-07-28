/*=====================================================================================================================================================
NOTAS DEL AUTOR:
10/05/2019 10:49 Se adicion� la parte del nuevo esquema de permanencia por 6 permanencias, esquema entr� en vigencia en Febrero 2019
21/06/2019 12:00 Se corrigi� la larte de evaluar el aplica o no la permanencia y que gane comision cero
=====================================================================================================================================================*/
--select * from DimAcreedor where Acreedor_Nombre_Comercial like '%ADATEL%'

DECLARE @periodo_pago varchar(6)
DECLARE @periodo_corte varchar(6)
DECLARE @acreedor_id varchar(50)
DECLARE @periodo_perma_nueva varchar(50)

set @periodo_corte = '201812'
set @periodo_perma_nueva = '201902'
set @periodo_pago = convert(varchar(6),dateadd(m,5,convert(datetime,@periodo_corte+'01')),112)	
set @acreedor_id = '700000128'


if @acreedor_id = ''
 begin
	DELETE DM_COMISV_POSPAGO.dbo.PagoPospagoPermanenciaDEXMasivo WHERE PERIODO_PAGO = @periodo_pago

	--CONSTRUYENDO VENTAS POSPAGO MASIVO
	INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoPermanenciaDEXMasivo
	SELECT 
		Y.*
		,[DM_COMISV_POSPAGO].[dbo].[fnGetFactorPermaPospagoMasivo](Y.ALCANCE_META_VENTA, Y.EFECTIDAD_VENTAS) FACTOR_PERMA
		,CASE
			WHEN Y.APLICA_PERMA = 'SI' THEN [DM_COMISV_POSPAGO].[dbo].[fnGetFactorPermaPospagoMasivo](Y.ALCANCE_META_VENTA, Y.EFECTIDAD_VENTAS) * Y.RENTA_MENSUAL
			ELSE 0
		 END COMISION
		,CASE
			WHEN Y.APLICA_PERMA = 'SI' THEN ( [DM_COMISV_POSPAGO].[dbo].[fnGetFactorPermaPospagoMasivo](Y.ALCANCE_META_VENTA, Y.EFECTIDAD_VENTAS) * Y.RENTA_MENSUAL ) /1.13
			ELSE 0
		 END  COMISION_SIN_IVA 
		,getdate() FECHA_PROCESO --INTO PagoPospagoPermanenciaDEXMasivo
	FROM (
		SELECT 
			 @periodo_pago PERIODO_PAGO
			,X.PERIODO
			,X.FECHA_ID
			,X.DEALER_CODE
			,X.DEALER_NAME
			,X.DISTRIBUIDOR		
			,X.ACREEDOR_ID
			,X.AGRUPACION CANAL
			,X.CUSTOMER_ID
			,X.DN_NUM
			,X.CO_ID
			,X.NOMBRE_PLAN	
			,CASE 
				WHEN X.NOMBRE_PLAN LIKE '%PAGO%Y%LISTO%' THEN 'PAGO Y LISTO'
				WHEN X.NOMBRE_PLAN LIKE '%INTERNET%' THEN 'INTERNET MOVIL'
				WHEN X.NOMBRE_PLAN LIKE '%3G%' THEN 'INTERNET MOVIL'
				ELSE 'MOVIL'
			 END TIPO_PLAN
			,X.TIPO_CONTRATO		
			,X.RENTA_MENSUAL
			,'PERMANENCIA' TRANSACCION
			,X.TOTAL_REVENUE
			,X.META		
			,CASE WHEN X.META = 0 THEN 0 ELSE X.TOTAL_REVENUE/X.META END ALCANCE_META_VENTA
			,X.UNIDAD_GLOBAL
			,X.UNIDAD_APLICA_PERMA
			,X.APLICA_PERMA
			,X.FACT_PAGADAS
			,SUM(X.UNIDAD_APLICA_PERMA) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) TOTAL_APLICAN_PERMA
			,SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) TOTAL_VENTAS
			,(SUM(X.UNIDAD_APLICA_PERMA) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) / CAST(SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) AS FLOAT) ) EFECTIDAD_VENTAS
			--,X.COMISION
			--,X.COMISION_SIN_IVA	
			,X.ESTADO_CONTRATO
			,X.FECHA_ESTADO_CONTRATO
		FROM (
		SELECT A.PERIODO
			,A.FECHA_ID
			,A.CUSTOMER_ID
			,A.DN_NUM
			,A.CO_ID
			,A.NOMBRE_PLAN
			,A.TIPO_CONTRATO
			,A.RENTA_COMISION RENTA_MENSUAL
			,( SELECT SUM(REVENUE)
			   FROM DMSVRHI_COMISIONES.dbo.DimMetasDistriPosRevenue
			   WHERE PERIODO COLLATE Modern_Spanish_CI_AS = A.PERIODO 
				AND DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = A.DISTRIBUIDOR
			  ) META	 
			,SUM(A.RENTA_COMISION) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR ) TOTAL_REVENUE		
			,B.FACT_PAGADAS	
			,CASE
				WHEN B.FACT_PAGADAS >= 2 THEN 'SI'
				ELSE 'NO'
			 END APLICA_PERMA
			,1 UNIDAD_GLOBAL	
			,CASE
				WHEN B.FACT_PAGADAS >= 2 THEN 1
				ELSE 0
			 END UNIDAD_APLICA_PERMA	
			,A.DEALER_CODE
			,A.DEALER_NAME
			,A.DISTRIBUIDOR	
			,A.CANAL AGRUPACION
			,c.ACREEDOR_ID
			--,A.COMISION
			--,A.COMISION_SIN_IVA
			--,GETDATE() FECHA_PROCESO	
			,B.CO_ESTADO_ACT ESTADO_CONTRATO
			,B.CO_ESTADO_ACT_FECHA FECHA_ESTADO_CONTRATO	
		  FROM DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXMasivo A
			INNER JOIN DM_COMISV_POSPAGO.dbo.FactPospagoVentas B ON B.CO_ID = A.CO_ID AND B.FECHA_ID = A.FECHA_ID
			INNER JOIN DM_COMISV_POSPAGO.dbo.DimDealer c on c.dealer_code = a.DEALER_CODE
		  WHERE A.PERIODO = @periodo_corte
			AND A.CANAL = 'DISTRIBUIDORES'
			--AND C.ACREEDOR_ID = @acreedor_id
			AND a.FECHA_ID BETWEEN CONVERT(VARCHAR(8),C.FECHA_INI,112) AND CONVERT(VARCHAR(8),ISNULL(C.FECHA_FIN,GETDATE()),112) 
			--AND A.DISTRIBUIDOR LIKE '%TDM%'
		) X
	) Y
	
	--PERMANENCIA 1, DESDE 201902, NO OLVIDAR COLOCAR LAS OTRAS TRANSACCIONES EL OTRO MES.
	INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoPermanenciaDEXMasivo
	SELECT 
		Y.*
		,CASE
			WHEN Y.FACT_PAGADAS >= 1 AND Y.ESTADO_CONTRATO = 'a'
			THEN [DM_COMISV_POSPAGO].[dbo].[fnGetFactorPermanenciaFactura](CONVERT(date,Y.FECHA_ID), Y.CANAL, 22, 'MOVIL','PERMAXFACTURA', Y.RENTA_MENSUAL/1.13, 1)
			ELSE 0 
		 END FACTOR_PERMA		
		,(CASE
			WHEN Y.FACT_PAGADAS >= 1 AND Y.ESTADO_CONTRATO = 'a'
			THEN [DM_COMISV_POSPAGO].[dbo].[fnGetFactorPermanenciaFactura](CONVERT(date,Y.FECHA_ID), Y.CANAL, 22, 'MOVIL','PERMAXFACTURA', Y.RENTA_MENSUAL/1.13, 1)
			ELSE 0 
		 END) * Y.RENTA_MENSUAL AS COMISION
		,( (CASE
				WHEN Y.FACT_PAGADAS >= 1 AND Y.ESTADO_CONTRATO = 'a'
				THEN [DM_COMISV_POSPAGO].[dbo].[fnGetFactorPermanenciaFactura](CONVERT(date,Y.FECHA_ID), Y.CANAL, 22, 'MOVIL','PERMAXFACTURA', Y.RENTA_MENSUAL/1.13, 1)
				ELSE 0 
			 END) * Y.RENTA_MENSUAL ) /1.13 COMISION_SIN_IVA 
		,getdate() FECHA_PROCESO --INTO PagoPospagoPermanenciaDEXMasivo
	FROM (
		SELECT 
			 @periodo_pago PERIODO_PAGO
			,X.PERIODO
			,X.FECHA_ID
			,X.DEALER_CODE
			,X.DEALER_NAME
			,X.DISTRIBUIDOR		
			,X.ACREEDOR_ID
			,X.AGRUPACION CANAL
			,X.CUSTOMER_ID
			,X.DN_NUM
			,X.CO_ID
			,X.NOMBRE_PLAN	
			,CASE 
				WHEN X.NOMBRE_PLAN LIKE '%PAGO%Y%LISTO%' THEN 'PAGO Y LISTO'
				WHEN X.NOMBRE_PLAN LIKE '%INTERNET%' THEN 'INTERNET MOVIL'
				WHEN X.NOMBRE_PLAN LIKE '%3G%' THEN 'INTERNET MOVIL'
				ELSE 'MOVIL'
			 END TIPO_PLAN
			,X.TIPO_CONTRATO		
			,X.RENTA_MENSUAL
			,'PERMANENCIA F1' TRANSACCION
			,X.TOTAL_REVENUE
			,X.META		
			,CASE WHEN X.META = 0 THEN 0 ELSE X.TOTAL_REVENUE/X.META END ALCANCE_META_VENTA
			,X.UNIDAD_GLOBAL
			,X.UNIDAD_APLICA_PERMA
			,X.APLICA_PERMA
			,X.FACT_PAGADAS
			,SUM(X.UNIDAD_APLICA_PERMA) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) TOTAL_APLICAN_PERMA
			,SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) TOTAL_VENTAS
			,(SUM(X.UNIDAD_APLICA_PERMA) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) / CAST(SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) AS FLOAT) ) EFECTIDAD_VENTAS
			--,X.COMISION
			--,X.COMISION_SIN_IVA	
			,X.ESTADO_CONTRATO
			,X.FECHA_ESTADO_CONTRATO
		FROM (
		SELECT A.PERIODO
			,A.FECHA_ID
			,A.CUSTOMER_ID
			,A.DN_NUM
			,A.CO_ID
			,A.NOMBRE_PLAN
			,A.TIPO_CONTRATO
			,A.RENTA_COMISION RENTA_MENSUAL
			,( SELECT SUM(REVENUE)
			   FROM DMSVRHI_COMISIONES.dbo.DimMetasDistriPosRevenue
			   WHERE PERIODO COLLATE Modern_Spanish_CI_AS = A.PERIODO 
				AND DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = A.DISTRIBUIDOR
			  ) META	 
			,SUM(A.RENTA_COMISION) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR ) TOTAL_REVENUE		
			,B.FACT01 FACT_PAGADAS	
			,CASE
				WHEN B.FACT_PAGADAS >= 1 THEN 'SI'
				ELSE 'NO'
			 END APLICA_PERMA
			,1 UNIDAD_GLOBAL	
			,CASE
				WHEN B.FACT_PAGADAS >= 1 THEN 1
				ELSE 0
			 END UNIDAD_APLICA_PERMA	
			,A.DEALER_CODE
			,A.DEALER_NAME
			,A.DISTRIBUIDOR	
			,A.CANAL AGRUPACION
			,c.ACREEDOR_ID
			,B.CO_ESTADO_ACT ESTADO_CONTRATO
			,B.CO_ESTADO_ACT_FECHA FECHA_ESTADO_CONTRATO
			--,A.COMISION
			--,A.COMISION_SIN_IVA
			--,GETDATE() FECHA_PROCESO		
		  FROM DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXMasivo A
			INNER JOIN DM_COMISV_POSPAGO.dbo.FactPospagoVentas B ON B.CO_ID = A.CO_ID AND B.FECHA_ID = A.FECHA_ID
			INNER JOIN DM_COMISV_POSPAGO.dbo.DimDealer c on c.dealer_code = a.DEALER_CODE
		  WHERE A.PERIODO = @periodo_perma_nueva
			AND A.CANAL = 'DISTRIBUIDORES'
			--AND C.ACREEDOR_ID = @acreedor_id
			--AND B.CO_ESTADO_ACT = 'a'
			AND a.FECHA_ID BETWEEN CONVERT(VARCHAR(8),C.FECHA_INI,112) AND CONVERT(VARCHAR(8),ISNULL(C.FECHA_FIN,GETDATE()),112) 
			--AND A.DISTRIBUIDOR LIKE '%TDM%'
		) X
	) Y
	
 end
else
 begin
	DELETE DM_COMISV_POSPAGO.dbo.PagoPospagoPermanenciaDEXMasivo WHERE PERIODO_PAGO = @periodo_pago and ACREEDOR_ID = @acreedor_id

	--CONSTRUYENDO VENTAS POSPAGO MASIVO
	INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoPermanenciaDEXMasivo
	SELECT 
		Y.*
		,[DM_COMISV_POSPAGO].[dbo].[fnGetFactorPermaPospagoMasivo](Y.ALCANCE_META_VENTA, Y.EFECTIDAD_VENTAS) FACTOR_PERMA
		,CASE
			WHEN Y.APLICA_PERMA = 'SI' THEN [DM_COMISV_POSPAGO].[dbo].[fnGetFactorPermaPospagoMasivo](Y.ALCANCE_META_VENTA, Y.EFECTIDAD_VENTAS) * Y.RENTA_MENSUAL
			ELSE 0
		 END COMISION
		,CASE
			WHEN Y.APLICA_PERMA = 'SI' THEN ( [DM_COMISV_POSPAGO].[dbo].[fnGetFactorPermaPospagoMasivo](Y.ALCANCE_META_VENTA, Y.EFECTIDAD_VENTAS) * Y.RENTA_MENSUAL ) /1.13
			ELSE 0
		 END  COMISION_SIN_IVA 
		,getdate() FECHA_PROCESO --INTO PagoPospagoPermanenciaDEXMasivo
	FROM (
		SELECT 
			 @periodo_pago PERIODO_PAGO
			,X.PERIODO
			,X.FECHA_ID
			,X.DEALER_CODE
			,X.DEALER_NAME
			,X.DISTRIBUIDOR		
			,X.ACREEDOR_ID
			,X.AGRUPACION CANAL
			,X.CUSTOMER_ID
			,X.DN_NUM
			,X.CO_ID
			,X.NOMBRE_PLAN	
			,CASE 
				WHEN X.NOMBRE_PLAN LIKE '%PAGO%Y%LISTO%' THEN 'PAGO Y LISTO'
				WHEN X.NOMBRE_PLAN LIKE '%INTERNET%' THEN 'INTERNET MOVIL'
				WHEN X.NOMBRE_PLAN LIKE '%3G%' THEN 'INTERNET MOVIL'
				ELSE 'MOVIL'
			 END TIPO_PLAN
			,X.TIPO_CONTRATO		
			,X.RENTA_MENSUAL
			,'PERMANENCIA' TRANSACCION
			,X.TOTAL_REVENUE
			,X.META		
			,CASE WHEN X.META = 0 THEN 0 ELSE X.TOTAL_REVENUE/X.META END ALCANCE_META_VENTA
			,X.UNIDAD_GLOBAL
			,X.UNIDAD_APLICA_PERMA
			,X.APLICA_PERMA
			,X.FACT_PAGADAS
			,SUM(X.UNIDAD_APLICA_PERMA) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) TOTAL_APLICAN_PERMA
			,SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) TOTAL_VENTAS
			,(SUM(X.UNIDAD_APLICA_PERMA) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) / CAST(SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) AS FLOAT) ) EFECTIDAD_VENTAS
			--,X.COMISION
			--,X.COMISION_SIN_IVA	
			,X.ESTADO_CONTRATO
			,X.FECHA_ESTADO_CONTRATO
		FROM (
		SELECT A.PERIODO
			,A.FECHA_ID
			,A.CUSTOMER_ID
			,A.DN_NUM
			,A.CO_ID
			,A.NOMBRE_PLAN
			,A.TIPO_CONTRATO
			,A.RENTA_COMISION RENTA_MENSUAL
			,( SELECT SUM(REVENUE)
			   FROM DMSVRHI_COMISIONES.dbo.DimMetasDistriPosRevenue
			   WHERE PERIODO COLLATE Modern_Spanish_CI_AS = A.PERIODO 
				AND DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = A.DISTRIBUIDOR
			  ) META	 
			,SUM(A.RENTA_COMISION) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR ) TOTAL_REVENUE		
			,B.FACT_PAGADAS	
			,CASE
				WHEN B.FACT_PAGADAS >= 2 THEN 'SI'
				ELSE 'NO'
			 END APLICA_PERMA
			,1 UNIDAD_GLOBAL	
			,CASE
				WHEN B.FACT_PAGADAS >= 2 THEN 1
				ELSE 0
			 END UNIDAD_APLICA_PERMA	
			,A.DEALER_CODE
			,A.DEALER_NAME
			,A.DISTRIBUIDOR	
			,A.CANAL AGRUPACION
			,c.ACREEDOR_ID
			--,A.COMISION
			--,A.COMISION_SIN_IVA
			--,GETDATE() FECHA_PROCESO		
			,B.CO_ESTADO_ACT ESTADO_CONTRATO
			,B.CO_ESTADO_ACT_FECHA FECHA_ESTADO_CONTRATO			
		  FROM DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXMasivo A
			INNER JOIN DM_COMISV_POSPAGO.dbo.FactPospagoVentas B ON B.CO_ID = A.CO_ID AND B.FECHA_ID = A.FECHA_ID
			INNER JOIN DM_COMISV_POSPAGO.dbo.DimDealer c on c.dealer_code = a.DEALER_CODE
		  WHERE A.PERIODO = @periodo_corte
			AND A.CANAL = 'DISTRIBUIDORES'
			AND C.ACREEDOR_ID = @acreedor_id
			AND a.FECHA_ID BETWEEN CONVERT(VARCHAR(8),C.FECHA_INI,112) AND CONVERT(VARCHAR(8),ISNULL(C.FECHA_FIN,GETDATE()),112) 
			--AND A.DISTRIBUIDOR LIKE '%TDM%'
		) X
	) Y
	
	--PERMANENCIA 1, DESDE 201902, NO OLVIDAR COLOCAR LAS OTRAS TRANSACCIONES EL OTRO MES.
	INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoPermanenciaDEXMasivo
	SELECT 
		Y.*
		,CASE
			WHEN Y.FACT_PAGADAS >= 1 AND Y.ESTADO_CONTRATO = 'a'
			THEN [DM_COMISV_POSPAGO].[dbo].[fnGetFactorPermanenciaFactura](CONVERT(date,Y.FECHA_ID), Y.CANAL, 22, 'MOVIL','PERMAXFACTURA', Y.RENTA_MENSUAL/1.13, 1)
			ELSE 0 
		 END FACTOR_PERMA		
		,(CASE
			WHEN Y.FACT_PAGADAS >= 1 AND Y.ESTADO_CONTRATO = 'a'
			THEN [DM_COMISV_POSPAGO].[dbo].[fnGetFactorPermanenciaFactura](CONVERT(date,Y.FECHA_ID), Y.CANAL, 22, 'MOVIL','PERMAXFACTURA', Y.RENTA_MENSUAL/1.13, 1)
			ELSE 0 
		 END) * Y.RENTA_MENSUAL AS COMISION
		,( (CASE
				WHEN Y.FACT_PAGADAS >= 1 AND Y.ESTADO_CONTRATO = 'a'
				THEN [DM_COMISV_POSPAGO].[dbo].[fnGetFactorPermanenciaFactura](CONVERT(date,Y.FECHA_ID), Y.CANAL, 22, 'MOVIL','PERMAXFACTURA', Y.RENTA_MENSUAL/1.13, 1)
				ELSE 0 
			 END) * Y.RENTA_MENSUAL ) /1.13 COMISION_SIN_IVA 
		,getdate() FECHA_PROCESO --INTO PagoPospagoPermanenciaDEXMasivo
	FROM (
		SELECT 
			 @periodo_pago PERIODO_PAGO
			,X.PERIODO
			,X.FECHA_ID
			,X.DEALER_CODE
			,X.DEALER_NAME
			,X.DISTRIBUIDOR		
			,X.ACREEDOR_ID
			,X.AGRUPACION CANAL
			,X.CUSTOMER_ID
			,X.DN_NUM
			,X.CO_ID
			,X.NOMBRE_PLAN	
			,CASE 
				WHEN X.NOMBRE_PLAN LIKE '%PAGO%Y%LISTO%' THEN 'PAGO Y LISTO'
				WHEN X.NOMBRE_PLAN LIKE '%INTERNET%' THEN 'INTERNET MOVIL'
				WHEN X.NOMBRE_PLAN LIKE '%3G%' THEN 'INTERNET MOVIL'
				ELSE 'MOVIL'
			 END TIPO_PLAN
			,X.TIPO_CONTRATO		
			,X.RENTA_MENSUAL
			,'PERMANENCIA F1' TRANSACCION
			,X.TOTAL_REVENUE
			,X.META		
			,CASE WHEN X.META = 0 THEN 0 ELSE X.TOTAL_REVENUE/X.META END ALCANCE_META_VENTA
			,X.UNIDAD_GLOBAL
			,X.UNIDAD_APLICA_PERMA
			,X.APLICA_PERMA
			,X.FACT_PAGADAS
			,SUM(X.UNIDAD_APLICA_PERMA) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) TOTAL_APLICAN_PERMA
			,SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) TOTAL_VENTAS
			,(SUM(X.UNIDAD_APLICA_PERMA) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) / CAST(SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR) AS FLOAT) ) EFECTIDAD_VENTAS
			--,X.COMISION
			--,X.COMISION_SIN_IVA	
			,X.ESTADO_CONTRATO
			,X.FECHA_ESTADO_CONTRATO
		FROM (
		SELECT A.PERIODO
			,A.FECHA_ID
			,A.CUSTOMER_ID
			,A.DN_NUM
			,A.CO_ID
			,A.NOMBRE_PLAN
			,A.TIPO_CONTRATO
			,A.RENTA_COMISION RENTA_MENSUAL
			,( SELECT SUM(REVENUE)
			   FROM DMSVRHI_COMISIONES.dbo.DimMetasDistriPosRevenue
			   WHERE PERIODO COLLATE Modern_Spanish_CI_AS = A.PERIODO 
				AND DISTRIBUIDOR COLLATE Modern_Spanish_CI_AS = A.DISTRIBUIDOR
			  ) META	 
			,SUM(A.RENTA_COMISION) OVER (PARTITION BY A.PERIODO, A.DISTRIBUIDOR ) TOTAL_REVENUE		
			,B.FACT01 FACT_PAGADAS	
			,CASE
				WHEN B.FACT_PAGADAS >= 1 THEN 'SI'
				ELSE 'NO'
			 END APLICA_PERMA
			,1 UNIDAD_GLOBAL	
			,CASE
				WHEN B.FACT_PAGADAS >= 1 THEN 1
				ELSE 0
			 END UNIDAD_APLICA_PERMA	
			,A.DEALER_CODE
			,A.DEALER_NAME
			,A.DISTRIBUIDOR	
			,A.CANAL AGRUPACION
			,c.ACREEDOR_ID
			,B.CO_ESTADO_ACT ESTADO_CONTRATO
			,B.CO_ESTADO_ACT_FECHA FECHA_ESTADO_CONTRATO
			--,A.COMISION
			--,A.COMISION_SIN_IVA
			--,GETDATE() FECHA_PROCESO		
		  FROM DM_COMISV_POSPAGO.dbo.PagoPospagoVentasDEXMasivo A
			INNER JOIN DM_COMISV_POSPAGO.dbo.FactPospagoVentas B ON B.CO_ID = A.CO_ID AND B.FECHA_ID = A.FECHA_ID
			INNER JOIN DM_COMISV_POSPAGO.dbo.DimDealer c on c.dealer_code = a.DEALER_CODE
		  WHERE A.PERIODO = @periodo_perma_nueva
			AND A.CANAL = 'DISTRIBUIDORES'
			AND C.ACREEDOR_ID = @acreedor_id			
			AND a.FECHA_ID BETWEEN CONVERT(VARCHAR(8),C.FECHA_INI,112) AND CONVERT(VARCHAR(8),ISNULL(C.FECHA_FIN,GETDATE()),112) 
			--AND A.DISTRIBUIDOR LIKE '%TDM%'
		) X
	) Y
 end



--SELECT * FROM DimAcreedor where acreedor_nombre like '%INNO%'

--select * from PagoPospagoConsolidadoDEXMasivo where periodo_pago = '201812' and acreedor_id = '700000435'

--select * from DM_COMISV_POSPAGO.dbo.PagoPospagoPermanenciaDEXMasivo where periodo_pago = '201812' and acreedor_id = '700000435'

--select * from DMSVRHI_COMISIONES.dbo.DimMetasDistriPosRevenue where DISTRIBUIDOR like '%inno%' order by periodo


--25543.5584955754
/*
select periodo_pago, sum(comision_sin_iva) comi_perma 
from PagoPospagoPermanenciaDEXMasivo
where periodo_pago between '201812' and '201903'
group by periodo_pago
order by 1;





select co_id, count(*) 
from PagoPospagoPermanenciaDEXMasivo 
where periodo_pago = '201902'
group by co_id
having count(*)>1

select CO_ID, COUNT(*)
from PagoPospagoPermanenciaDEXMasivo 
where PERIODO_PAGO = '201902'
group by CO_ID
having count(*)>1

--select transaccion, sum(comision_sin_iva) from DM_COMISV_POSPAGO.dbo.PagoPospagoPermanenciaDEXMasivo where PERIODO_PAGO = '201905' group by transaccion
*/

