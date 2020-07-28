select PERIODO_PAGO, 'Venta' TRANS, SUM(a.CANT) CANT, SUM(RENTA_COMISION) RENTAS, SUM(COMISION_SIN_IVA) COMISION , SUM(COMISION_SIN_IVA) / SUM(a.CANT) RATIO, SUM(COMISION_SIN_IVA) / SUM(RENTA_COMISION/1.13) FACTOR_PAGO
from PagoPospagoVentasDEXCorpo a 
where PERIODO_PAGO between '201911' and '202002'
GROUP BY PERIODO_PAGO
--ORDER BY PERIODO_PAGO

select a.PERIODO_PAGO, 'Bono Por Volumen' TRANS,  SUM(a.CANT_VENTA) CANT, SUM(b.RENTA_COMISION) RENTAS, SUM(a.COMISION_SIN_IVA) COMISION , SUM(a.COMISION_SIN_IVA) / SUM(a.CANT_VENTA) RATIO, SUM(a.COMISION_SIN_IVA) / SUM(b.RENTA_COMISION/1.13) FACTOR_PAGO
from PagoPospagoBonoPorVolumenDEXCorpo a 
	INNER JOIN PagoPospagoVentasDEXCorpo B ON B.CO_ID = A.CO_ID AND B.FECHA_ID = A.FECHA_ID
where a.PERIODO_PAGO between '201911' and '202002'
GROUP BY a.PERIODO_PAGO
ORDER BY a.PERIODO_PAGO

select PERIODO_PAGO, 'Renovaciones' TRANS, SUM(a.UNIDAD) CANT, SUM(RENTA_MENSUAL_ACT) RENTAS, SUM(COMISION_SIN_IVA) COMISION , SUM(COMISION_SIN_IVA) / SUM(a.UNIDAD) RATIO, SUM(COMISION_SIN_IVA) / SUM(RENTA_MENSUAL_ACT/1.13) FACTOR_PAGO
from PagoPospagoRenovacionesDEXCorpo a 
where PERIODO_PAGO between '201911' and '202002'
GROUP BY PERIODO_PAGO
ORDER BY PERIODO_PAGO