--ventas	= 1537
--result	= (1537 filas afectadas)
select *
/*update a
SET A.NOMBRE_CLIENTE = B.NOMBRE_CLIENTE
	,A.APELLIDO_CLIENTE = B.NOMBRE_CLIENTE
	,A.NOMBRE_COMPLETO = B.NOMBRE_COMPLETO*/
from dbo.PagoPospagoConsolidadoDEXMasivo a
	inner join PagoPospagoVentasDEXMasivo b on b.co_id = a.co_id and b.periodo_pago = a.periodo_pago
where a.periodo_pago = '201810'
 and a.NOMBRE_COMPLETO is null
 and a.TIPOTRANS_ID = 1
 

--renovaciones = 18
--result = (18 filas afectadas)
select *
/*update a
SET A.NOMBRE_CLIENTE = B.NOMBRE_CLIENTE
	,A.APELLIDO_CLIENTE = B.NOMBRE_CLIENTE
	,A.NOMBRE_COMPLETO = B.NOMBRE_COMPLETO*/
from dbo.PagoPospagoConsolidadoDEXMasivo a
	inner join FactPospagoRenovaciones b on b.co_id = a.co_id and b.PERIODO = a.PERIODO
where a.periodo_pago = '201810'
 and a.NOMBRE_COMPLETO is null
 and a.TIPOTRANS_ID = 5
 
 
 --permanencia	= 1497
 select * 
 /*update a
SET A.NOMBRE_CLIENTE = B.NOMBRE_CLIENTE
	,A.APELLIDO_CLIENTE = B.NOMBRE_CLIENTE
	,A.NOMBRE_COMPLETO = B.NOMBRE_COMPLETO*/
 from PagoPospagoConsolidadoDEXMasivo a
	inner join PagoPospagoVentasDEXMasivo b on b.co_id = a.co_id and b.periodo = a.PERIODO
 where a.PERIODO_PAGO = '201810'
  and a.NOMBRE_COMPLETO is null
  
  
 
 select CO_ID, COUNT(*) cant 
 from PagoPospagoConsolidadoDEXMasivo a
 where a.PERIODO_PAGO = '201810'
 group by CO_ID
 having COUNT(*)>1
 
 
 
 select b.* 
 
 update a
 SET A.NOMBRE_CLIENTE = B.NOMBRE_CLIENTE
	,A.APELLIDO_CLIENTE = B.NOMBRE_CLIENTE
	,A.NOMBRE_COMPLETO = B.NOMBRE_COMPLETO
 from PagoPospagoConsolidadoDEXMasivo a 
	inner join FactPospagoVentas b on b.co_id = a.co_id and b.PERIODO = a.PERIODO
 where a.PERIODO_PAGO = '201810' 
 and a.tipotrans_id = 3 
 and a.NOMBRE_COMPLETO is null 