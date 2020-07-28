declare @periodo varchar(6)
declare @tipo_eval int

set @periodo = '202003'
set @tipo_eval = 1

--exec DM_COMISV_POSPAGO.dbo.spCalcularPospagoVentasDEXMasivo @periodo, @tipo_eval;
exec DM_COMISV_POSPAGO.dbo.spCalcularPospagoVentasDEXCorpo;
--exec DM_COMISV_POSPAGO.dbo.spCalcularPospagoVentasTelemarketing;
--exec DM_COMISV_POSPAGO.dbo.spCalcularPospagoVentasTercerizada;
--exec DM_COMISV_POSPAGO.dbo.spCalcularPospagoRenovaTMK @periodo, @tipo_eval;
exec DM_COMISV_POSPAGO.dbo.spCalcularPospagoRenovaDEXCorpo @periodo, @tipo_eval;

--37368.1247787611
--37368.1247787611
--32868.7893805304
SELECT SUM(comision_sin_iva) comision FROM PagoPospagoVentasDEXCorpo where PERIODO_PAGO = '202004'

--18818.5840707967
--18818.5840707967
--26889.3805309738
SELECT SUM(comision_sin_iva) comision FROM PagoPospagoBonoPorVolumenDEXCorpo where PERIODO_PAGO = '202004'

--64585.2854645799
--64585.2854645796
--42703.7886747069
SELECT SUM(comision_sin_iva) comision FROM PagoPospagoRenovacionesDEXCorpo where PERIODO_PAGO = '202004'