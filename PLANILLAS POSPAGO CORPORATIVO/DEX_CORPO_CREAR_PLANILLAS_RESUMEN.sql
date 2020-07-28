DECLARE @periodo_pago varchar(6)
DECLARE @periodo_corte varchar(6)

set @periodo_corte = '201809'
set @periodo_pago = convert(varchar(6),dateadd(m,1,convert(datetime,@periodo_corte+'01')),112)	

DELETE FROM DM_COMISV_POSPAGO.dbo.PlanillasPospagoResumenCorporativo WHERE PERIODO_PAGO = @periodo_pago 

INSERT INTO DM_COMISV_POSPAGO.dbo.PlanillasPospagoResumenCorporativo (
	   PERIODO_PAGO
      ,PERIODO_FILE
      ,PERIODO_LABEL
      ,PERIODO
      ,DISTRIBUIDOR
      ,ACREEDOR_ID
      ,CANAL
      ,TIPOTRANS_ID
      ,TRANSACCION
      ,UNIDAD_TOTALES
      ,UNIDADES_APLICAN
      ,TOTAL_REVENUE_VENTA
      ,META_VENTA
      ,ALCANCE_META_VENTA
      ,COMISION
      ,CUENTA_SAP
      ,CENTRO_COSTO_SAP
      ,NEGOCIO_ID
      ,NEGOCIO_NOMBRE
      ,NEGOCIO_CODE
      ,NEGOCIO_ACTIVIDAD
      ,NEGOCIO_SOCIEDAD
      ,CORRELATIVO
      ,CODIGO_PLANILLA
)
--TRANSACCIONES DEL CONSOLIDADO
SELECT X.PERIODO_PAGO
	,X.PERIODO_FILE
	,X.PERIODO_LABEL
	,X.PERIODO
	,X.DISTRIBUIDOR
	,X.ACREEDOR_ID
	,X.CANAL
	,X.TIPOTRANS_ID
	,X.TRANSACCION
	,X.UNIDAD_TOTALES
	,X.UNIDADES_APLICAN
	,X.TOTAL_REVENUE_VENTA
	,X.META_VENTA
	,X.ALCANCE_META_VENTA
	,X.COMISION
	,X.CUENTA_SAP
	,X.CENTRO_COSTO_SAP
	,X.NEGOCIO_ID
	,X.NEGOCIO_NOMBRE
	,X.NEGOCIO_CODE
	,X.NEGOCIO_ACTIVIDAD
	,X.NEGOCIO_SOCIEDAD      
    ,ROW_NUMBER() OVER (PARTITION BY X.DISTRIBUIDOR, X.PERIODO_PAGO ORDER BY X.DISTRIBUIDOR, X.PERIODO_PAGO, X.TIPOTRANS_ID)  CORRELATIVO 
    ,X.ACREEDOR_ID + '-CORP-' +  CONVERT(varchar(8),dateadd(d,-(day(getdate()-1)),getdate()),112) CODIGO_PLANILLA
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
    ,A.TIPOTRANS_ID
    ,A.TIPOTRANS_DESC TRANSACCION
    ,SUM(UNIDAD_GLOBAL) UNIDAD_TOTALES                
    ,SUM(UNIDAD_APLICA)  UNIDADES_APLICAN
    ,A.TOTAL_REVENUE_VENTA
    ,A.META META_VENTA
    ,A.ALCANCE_META ALCANCE_META_VENTA
    ,SUM(COMISION_SIN_IVA) COMISION
    ,A.CUENTA_SAP
    ,A.CENTRO_COSTO_SAP
    ,A.NEGOCIO_ID
	,B.NEGOCIO_NOMBRE
	,B.NEGOCIO_CODE
	,B.NEGOCIO_ACTIVIDAD
	,B.NEGOCIO_SOCIEDAD     
FROM [DM_COMISV_POSPAGO].[dbo].[PagoPospagoConsolidadoDEXCorpo] a
	INNER JOIN DM_COMISV_POSPAGO.dbo.DimNegocio B ON B.NEGOCIO_ID = A.NEGOCIO_ID				            
WHERE a.PERIODO_PAGO = @periodo_pago
 --AND A.ACREEDOR_ID = '700000047'
GROUP BY A.PERIODO_PAGO, A.CANAL, A.PERIODO, A.DISTRIBUIDOR, A.ACREEDOR_ID, A.TIPOTRANS_ID, A.TIPOTRANS_DESC, A.TOTAL_REVENUE_VENTA, A.META, A.ALCANCE_META
		,A.CUENTA_SAP,A.CENTRO_COSTO_SAP,A.NEGOCIO_ID,B.NEGOCIO_NOMBRE,B.NEGOCIO_CODE
		,B.NEGOCIO_ACTIVIDAD,B.NEGOCIO_SOCIEDAD 
UNION ALL 
--DESCUENTOS CLAWBACK
SELECT PERIODO_DESCUENTO AS PERIODO_PAGO
    ,CONVERT(VARCHAR(6),DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01')),112) PERIODO_FILE
    ,CASE 
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 1 then 'Enero' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 2 then 'Febrero' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 3 then 'Marzo' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 4 then 'Abril' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 5 then 'Mayo' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 6 then 'Junio' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 7 then 'Julio' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 8 then 'Agosto' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 9 then 'Septiembre' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 10 then 'Octubre' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 11 then 'Noviembre' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 12 then 'Diciembre' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
    END PERIODO_LABEL	 
    ,A.PERIODO
    ,(SELECT TOP 1 ACREEDOR_NOMBRE_COMERCIAL FROM DM_COMISV_POSPAGO.dbo.DimAcreedor WHERE ACREEDOR_ID = A.ACREEDOR_ID) DISTRIBUIDOR
    ,A.ACREEDOR_ID
    ,A.CANAL
    ,A.TIPOTRANS_ID
    ,B.TIPOTRANS_DESC TRANSACCION
    ,COUNT(*) UNIDAD_TOTALES
    ,COUNT(*)  UNIDADES_APLICAN
    ,0 TOTAL_REVENUE_VENTA
    ,0 META_VENTA
    ,0 ALCANCE_META_VENTA
    ,SUM(A.MONTO)*-1 COMISION          
    ,B.CUENTA_SAP
    ,B.CENTRO_COSTO_SAP
    ,B.NEGOCIO_ID
	,C.NEGOCIO_NOMBRE
	,C.NEGOCIO_CODE
	,C.NEGOCIO_ACTIVIDAD
	,C.NEGOCIO_SOCIEDAD    
FROM [DM_COMISV_POSPAGO].[dbo].[FactPospagoDescuentosClawbackDEXCorpo] a
    INNER JOIN DM_COMISV_POSPAGO.dbo.DimTipoTransaccion B ON B.TIPOTRANS_ID	 = A.TIPOTRANS_ID	
    INNER JOIN DM_COMISV_POSPAGO.dbo.DimNegocio C ON C.NEGOCIO_ID = B.NEGOCIO_ID
WHERE a.PERIODO_DESCUENTO = @periodo_pago
 --AND A.ACREEDOR_ID = '700000047'
GROUP BY A.PERIODO_DESCUENTO, A.PERIODO, A.CANAL, A.ACREEDOR_ID, A.TIPOTRANS_ID, B.TIPOTRANS_DESC
	,B.CUENTA_SAP,B.CENTRO_COSTO_SAP,B.NEGOCIO_ID, C.NEGOCIO_NOMBRE,C.NEGOCIO_CODE
	,C.NEGOCIO_ACTIVIDAD,C.NEGOCIO_SOCIEDAD 
UNION ALL 
--DESCUENTOS QFLOW
SELECT PERIODO_DESCUENTO AS PERIODO_PAGO
    ,CONVERT(VARCHAR(6),DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01')),112) PERIODO_FILE
    ,CASE 
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 1 then 'Enero' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 2 then 'Febrero' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 3 then 'Marzo' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 4 then 'Abril' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 5 then 'Mayo' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 6 then 'Junio' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 7 then 'Julio' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 8 then 'Agosto' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 9 then 'Septiembre' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 10 then 'Octubre' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 11 then 'Noviembre' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
        WHEN MONTH(DATEADD(MONTH,0,CONVERT(DATETIME,PERIODO_DESCUENTO+'01'))) = 12 then 'Diciembre' + ' - ' + substring(PERIODO_DESCUENTO,1,4)
    END PERIODO_LABEL	 
    ,A.PERIODO
    ,(SELECT TOP 1 ACREEDOR_NOMBRE_COMERCIAL FROM DM_COMISV_POSPAGO.dbo.DimAcreedor WHERE ACREEDOR_ID = A.ACREEDOR_ID) DISTRIBUIDOR
    ,A.ACREEDOR_ID
    ,A.CANAL
    ,A.TIPOTRANS_ID
    ,B.TIPOTRANS_DESC TRANSACCION
    ,COUNT(*) UNIDAD_TOTALES
    ,COUNT(*)  UNIDADES_APLICAN   
    ,0 TOTAL_REVENUE_VENTA             
    ,0 META_VENTA
    ,0 ALCANCE_META_VENTA
    ,SUM(A.MONTO)*-1 COMISION
    ,B.CUENTA_SAP
    ,B.CENTRO_COSTO_SAP
    ,B.NEGOCIO_ID
	,C.NEGOCIO_NOMBRE
	,C.NEGOCIO_CODE
	,C.NEGOCIO_ACTIVIDAD
	,C.NEGOCIO_SOCIEDAD    
FROM [DM_COMISV_POSPAGO].[dbo].[FactPospagoDescuentosQFlowDEXCorpo] a
	INNER JOIN DM_COMISV_POSPAGO.dbo.DimTipoTransaccion B ON B.TIPOTRANS_ID	 = A.TIPOTRANS_ID	
    INNER JOIN DM_COMISV_POSPAGO.dbo.DimNegocio C ON C.NEGOCIO_ID = B.NEGOCIO_ID
WHERE a.PERIODO_DESCUENTO = @periodo_pago
 --AND A.ACREEDOR_ID = ''
GROUP BY A.PERIODO_DESCUENTO, A.PERIODO, A.CANAL, A.ACREEDOR_ID, A.TIPOTRANS_ID
	,B.TIPOTRANS_DESC, B.CUENTA_SAP,B.CENTRO_COSTO_SAP,B.NEGOCIO_ID
	,C.NEGOCIO_NOMBRE,C.NEGOCIO_CODE,C.NEGOCIO_ACTIVIDAD,C.NEGOCIO_SOCIEDAD  
) X
ORDER BY X.TIPOTRANS_ID			


/*
select * from PagoPospagoVentasDEXCorpo where periodo_pago = '201810' and distribuidor like '%DTS%'

select * from PagoPospagoRenovacionesDEXCorpo where periodo_pago = '201810' and distribuidor like '%DTS%'

select * from DimMetasDEXCorpoRevenue where periodo = '201809' and distribuidor like '%DTS%'




*/


