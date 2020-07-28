 insert into PaycomLineasExcluidas
 select PERIODO, CANAL, CO_ID, DN_NUM, DISTRIBUIDOR, NOMBRE_COMPLETO, 'RENOVACIONES' TRANSACCION, 'Autorenovacion Distribuidor ' + DISTRIBUIDOR DESCRIPCION
 FROM PagoPospagoRenovacionesDEXCorpo 
where periodo_pago = 202005
 and prorrateo = 0.1