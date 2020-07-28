--Realizar Backup de tablas operacionales Pospago Corporativo
select * into PagoPospagoVentasDEXCorpo_BK20190211_0838 from PagoPospagoVentasDEXCorpo;
select * into PagoPospagoRenovacionesDEXCorpo_BK20190211_0838 from PagoPospagoRenovacionesDEXCorpo;
select * into PagoPospagoBonoPorVolumenDEXCorpo_BK20190211_0838 from PagoPospagoBonoPorVolumenDEXCorpo;
select * into PagoPospagoCambiosDePlanDEXCorpo_BK20190211_0838 from PagoPospagoCambiosDePlanDEXCorpo;


--Realizar Backup de tablas Pospago Masivo
select * into PagoPospagoVentasDEXMasivo_BK20190211_0842 from PagoPospagoVentasDEXMasivo;
select * into PagoPospagoPermanenciaDEXMasivo_BK20190211_0842 from PagoPospagoPermanenciaDEXMasivo;

--Realizar Backup de tablas Pospago Telemarketing
select * into PagoPospagoVentasTMK_BK20190211_0844 from PagoPospagoVentasTMK


--Realizar Backup de tablas de Tercerizada
select * into PagoPospagoVentasDEXTerce_BK20190211_0844 from PagoPospagoVentasDEXTerce

--Backup de Consolidado Corporativo
select * into PagoPospagoConsolidadoDEXCorpo_BK20190211_0846 from dbo.PagoPospagoConsolidadoDEXCorpo

--Backup de Consolidado Masivo
select * into PagoPospagoConsolidadoDEXMasivo_BK20190211_0847 from PagoPospagoConsolidadoDEXMasivo