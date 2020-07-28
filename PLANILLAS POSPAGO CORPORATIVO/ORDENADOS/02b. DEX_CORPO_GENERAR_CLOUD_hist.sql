--TRUNCATE TABLE PagoPospagoCloudDEXCorpo
INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoCloudDEXCorpo
SELECT 
	X.*
   ,SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) UNIDADES_TOTAL   
   ,SUM(X.CARGO_BASICO)  OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) MONTO_TOTAL
   ,SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) / X.META_UNIDADES ALCANCE_UNIDADES
   ,SUM(X.CARGO_BASICO)  OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) / X.META_MONTO ALCANCE_MONTO   
   ,CASE
  	  WHEN SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_UNIDADES THEN 'SI'
	  ELSE 'NO'
	END CUMPLE_META_CANT
   ,CASE
	  WHEN SUM(X.CARGO_BASICO) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_MONTO THEN 'SI'
	   ELSE 'NO'
	END CUMPLE_META_MONTO	
	,CASE
  	  WHEN SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_UNIDADES 
  	   AND SUM(X.CARGO_BASICO)  OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_MONTO
  	  THEN 3
	  ELSE 2
	END FACTOR
	,CAST(CASE
  	  WHEN SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_UNIDADES 
  	   AND SUM(X.CARGO_BASICO)  OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_MONTO
  	  THEN X.CARGO_BASICO * 3.00 * 1.13
	  ELSE X.CARGO_BASICO * 2.00 * 1.13
	END AS FLOAT) COMISION
	,CASE
  	  WHEN SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_UNIDADES 
  	   AND SUM(X.CARGO_BASICO)  OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_MONTO
  	  THEN X.CARGO_BASICO * 3
	  ELSE X.CARGO_BASICO * 2
	END COMISION_SIN_IVA
	,CASE
		WHEN X.TIPO_PRODUCTO = 'SVA' THEN 18
		WHEN X.TIPO_PRODUCTO = 'CLOUD' THEN 19
		ELSE 0
	 END TIPOTRANS_ID
FROM (
SELECT '201812' PERIODO_PAGO
      ,[PERIODO]
      ,[CUSTOMER_ID]
      ,[CO_ID]
      ,[FECHA]
      ,[NOMBRE_COMPLETO]
      ,[CATEGORIA_CLIENTE]
      ,[NOMBRE_PLAN]
      ,[LSITE]
      ,[COMENTARIO]
      ,[PLAZO]
      ,[SEGMENTO]
      ,[TIPO_TRANS]
      ,[SUB_TRANS]
      ,CASE 
		WHEN TIPO_PRODUCTO = 'SVA-CLOUD' THEN 'CLOUD'
		ELSE 'SVA'
       END TIPO_PRODUCTO
      ,[ND]
      ,a.[DEALER_CODE]
      ,a.[DISTRIBUIDOR]
      ,b.ACREEDOR_ID
      ,a.[EMP_ID]
      ,[TIPO_ASESOR]
      ,[CODIGO_JEFE]
      ,[NOMBRE_JEFE]
      ,[SECTOR]
      ,[UNIDAD_GLOBAL]
      ,[UNIDAD]
      ,[CARGO_BASICO]
      ,[CB_CONTABILIZADO]
      ,a.[CANAL]
      ,[EJECUTIVO_RRHH]
      ,[FACTOR_PAGO]
      ,[PRORRATEO]
      ,15.0000 META_UNIDADES
      ,700.0000 META_MONTO   
      ,[CUMPLE_PLAZO_CONTRATO]
	  ,[CUMPLE_CASO_QFLOW]   
  FROM [DM_OPERACIONES_SV].[dbo].[PagoConsolidadoCorpoInt] A
   INNER JOIN [DM_COMISV_POSPAGO].[dbo].DimDealer b on b.dealer_code collate SQL_Latin1_General_CP1_CI_AS = A.DEALER_CODE
WHERE a.PERIODO BETWEEN '201809' AND '201811'
 AND a.SUB_TRANS = 'SVA'
 AND a.TIPO_ASESOR = 'DISTRIBUIDORES'
 and convert(varchar(8),A.FECHA,112) between CONVERT(varchar(8),b.fecha_ini,112) and CONVERT(varchar(8),isnull(b.fecha_fin,GETDATE()),112)
 --AND DISTRIBUIDOR = 'ACCES COM'
) X
ORDER BY X.PERIODO, X.DISTRIBUIDOR, X.FECHA








/*========================================================================================================
COMPLEMENTOS
=========================================================================================================*/
--201807
INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoCloudDEXCorpo
SELECT 
	X.*
   ,SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) UNIDADES_TOTAL   
   ,SUM(X.CARGO_BASICO)  OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) MONTO_TOTAL
   ,0 ALCANCE_UNIDADES
   ,0 ALCANCE_MONTO   
   ,'NO' CUMPLE_META_CANT
   ,'NO' CUMPLE_META_MONTO	
   ,1 FACTOR 
   ,X.CARGO_BASICO * 1.13 COMISION
   ,X.CARGO_BASICO COMISION_SIN_IVA
	,CASE
		WHEN X.TIPO_PRODUCTO = 'SVA' THEN 18
		WHEN X.TIPO_PRODUCTO = 'CLOUD' THEN 19
		ELSE 0
	 END TIPOTRANS_ID 
FROM (
SELECT '201812' PERIODO_PAGO
      ,[PERIODO]
      ,[CUSTOMER_ID]
      ,[CO_ID]
      ,[FECHA]
      ,[NOMBRE_COMPLETO]
      ,[CATEGORIA_CLIENTE]
      ,[NOMBRE_PLAN]
      ,[LSITE]
      ,[COMENTARIO]
      ,[PLAZO]
      ,[SEGMENTO]
      ,[TIPO_TRANS]
      ,[SUB_TRANS]
      ,CASE 
		WHEN TIPO_PRODUCTO = 'SVA-CLOUD' THEN 'CLOUD'
		ELSE 'SVA'
       END TIPO_PRODUCTO
      ,[ND]
      ,a.[DEALER_CODE]
      ,a.[DISTRIBUIDOR]
      ,b.ACREEDOR_ID
      ,a.[EMP_ID]
      ,[TIPO_ASESOR]
      ,[CODIGO_JEFE]
      ,[NOMBRE_JEFE]
      ,[SECTOR]
      ,[UNIDAD_GLOBAL]
      ,[UNIDAD]
      ,[CARGO_BASICO]
      ,[CB_CONTABILIZADO]
      ,a.[CANAL]
      ,[EJECUTIVO_RRHH]
      ,[FACTOR_PAGO]
      ,[PRORRATEO]
      ,0 META_UNIDADES
      ,0 META_MONTO   
      ,[CUMPLE_PLAZO_CONTRATO]
	  ,[CUMPLE_CASO_QFLOW]   
  FROM [DM_OPERACIONES_SV].[dbo].[PagoConsolidadoCorpoInt] A
   INNER JOIN [DM_COMISV_POSPAGO].[dbo].DimDealer b on b.dealer_code collate SQL_Latin1_General_CP1_CI_AS = A.DEALER_CODE
WHERE a.PERIODO BETWEEN '201807' AND '201807'
 AND a.SUB_TRANS = 'SVA'
 AND a.TIPO_ASESOR = 'DISTRIBUIDORES'
 and convert(varchar(8),A.FECHA,112) between CONVERT(varchar(8),b.fecha_ini,112) and CONVERT(varchar(8),isnull(b.fecha_fin,GETDATE()),112)
 --AND DISTRIBUIDOR = 'ACCES COM'
) X
ORDER BY X.PERIODO, X.DISTRIBUIDOR, X.FECHA


--201808
INSERT INTO DM_COMISV_POSPAGO.dbo.PagoPospagoCloudDEXCorpo
SELECT 
	X.*
   ,SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) UNIDADES_TOTAL   
   ,SUM(X.CARGO_BASICO)  OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) MONTO_TOTAL
   ,SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) / X.META_UNIDADES ALCANCE_UNIDADES
   ,SUM(X.CARGO_BASICO)  OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) / X.META_MONTO ALCANCE_MONTO   
   ,CASE
  	  WHEN SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_UNIDADES THEN 'SI'
	  ELSE 'NO'
	END CUMPLE_META_CANT
   ,CASE
	  WHEN SUM(X.CARGO_BASICO) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_MONTO THEN 'SI'
	   ELSE 'NO'
	END CUMPLE_META_MONTO	
	,CASE
  	  WHEN SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_UNIDADES 
  	   AND SUM(X.CARGO_BASICO)  OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_MONTO
  	  THEN 1
	  ELSE 1
	END FACTOR
	,CAST(CASE
  	  WHEN SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_UNIDADES 
  	   AND SUM(X.CARGO_BASICO)  OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_MONTO
  	  THEN X.CARGO_BASICO * 1.13
	  ELSE X.CARGO_BASICO * 1.13
	END AS FLOAT) COMISION
	,CASE
  	  WHEN SUM(X.UNIDAD_GLOBAL) OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_UNIDADES 
  	   AND SUM(X.CARGO_BASICO)  OVER (PARTITION BY X.PERIODO, X.DISTRIBUIDOR, X.TIPO_PRODUCTO) >= X.META_MONTO
  	  THEN X.CARGO_BASICO 
	  ELSE X.CARGO_BASICO
	END COMISION_SIN_IVA
	,CASE
		WHEN X.TIPO_PRODUCTO = 'SVA' THEN 18
		WHEN X.TIPO_PRODUCTO = 'CLOUD' THEN 19
		ELSE 0
	 END TIPOTRANS_ID 
FROM (
SELECT '201812' PERIODO_PAGO
      ,[PERIODO]
      ,[CUSTOMER_ID]
      ,[CO_ID]
      ,[FECHA]
      ,[NOMBRE_COMPLETO]
      ,[CATEGORIA_CLIENTE]
      ,[NOMBRE_PLAN]
      ,[LSITE]
      ,[COMENTARIO]
      ,[PLAZO]
      ,[SEGMENTO]
      ,[TIPO_TRANS]
      ,[SUB_TRANS]
      ,CASE 
		WHEN TIPO_PRODUCTO = 'SVA-CLOUD' THEN 'CLOUD'
		ELSE 'SVA'
       END TIPO_PRODUCTO
      ,[ND]
      ,a.[DEALER_CODE]
      ,a.[DISTRIBUIDOR]
      ,b.ACREEDOR_ID
      ,a.[EMP_ID]
      ,[TIPO_ASESOR]
      ,[CODIGO_JEFE]
      ,[NOMBRE_JEFE]
      ,[SECTOR]
      ,[UNIDAD_GLOBAL]
      ,[UNIDAD]
      ,[CARGO_BASICO]
      ,[CB_CONTABILIZADO]
      ,a.[CANAL]
      ,[EJECUTIVO_RRHH]
      ,[FACTOR_PAGO]
      ,[PRORRATEO]
      ,15.0000 META_UNIDADES
      ,700.0000 META_MONTO   
      ,[CUMPLE_PLAZO_CONTRATO]
	  ,[CUMPLE_CASO_QFLOW]   
  FROM [DM_OPERACIONES_SV].[dbo].[PagoConsolidadoCorpoInt] A
   INNER JOIN [DM_COMISV_POSPAGO].[dbo].DimDealer b on b.dealer_code collate SQL_Latin1_General_CP1_CI_AS = A.DEALER_CODE
WHERE a.PERIODO BETWEEN '201808' AND '201808'
 AND a.SUB_TRANS = 'SVA'
 AND a.TIPO_ASESOR = 'DISTRIBUIDORES'
 and convert(varchar(8),A.FECHA,112) between CONVERT(varchar(8),b.fecha_ini,112) and CONVERT(varchar(8),isnull(b.fecha_fin,GETDATE()),112)
 --AND DISTRIBUIDOR = 'ACCES COM'
) X
ORDER BY X.PERIODO, X.DISTRIBUIDOR, X.FECHA



--select SUM(comision_sin_iva) from DM_COMISV_POSPAGO.dbo.PagoPospagoCloudDEXCorpo


select * from PagoPospagoVentasDEXCorpo where co_id = '13501250'

select * from FactPospagoServicios where co_id = '13501250'



SELECT * from DM_COMISV_POSPAGO.dbo.PagoPospagoCloudDEXCorpo where co_id in (
'12174056',
'12174048',
'12174052',
'11962919',
'11962915',
'11962923',
'11997779'
)

---se borran por estar desactivados
delete a 
from DM_COMISV_POSPAGO.dbo.PagoPospagoCloudDEXCorpo a 
where co_id in (
'12174056',
'12174048',
'12174052',
'11962919',
'11962915',
'11962923',
'11997779'
)