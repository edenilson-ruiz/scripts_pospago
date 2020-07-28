INSERT INTO DM_COMISV_POSPAGO.dbo.PayComLineasExcluidas
SELECT PERIODO, CANAL, CO_ID, DN_NUM, DISTRIBUIDOR, NOMBRE_COMPLETO, 'VENTAS' TRANSACCION, 'Distribuidor menciona que no es venta de ellos' DESCRIPCION 
FROM PagoPospagoConsolidadoDEXMasivo 
where co_id in (
'14671265',
'14696778'
)