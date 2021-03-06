--DISTRIBUIDORES CORPORATIVOS
EXEC dbo.spCalcularPospagoVentasDEXCorpo;						--Ventas
EXEC dbo.spCalcularPospagoRenovaDEXCorpo '202006',1, 'false';	--Renovaciones

--DISTRIBUIDORES MASIVOS
EXEC dbo.spCalcularPospagoVentasDEXMasivo '202006',1;			--Ventas

--ALIADOS
EXEC dbo.A01spCalcularPospagoVentasTMKNE;							--Ventas
EXEC dbo.A02spCalcularPospagoPermanenciaTMKNE '202004';			--Permanencias
EXEC dbo.A03spCalcularPospagoRenovaTMKNE '202006',1				--Renovaciones
EXEC dbo.A04spCalcularAdicionalesTMKNE;							--Adicionales UpSellVoz, UpSellDatos, SF, FB




/*=======================================================================================
 CORPORATIVO
=======================================================================================*/
-- Ventas (Provision y Real)
select * from PagoPospagoVentasDEXCorpo where periodo_pago = '202006';

-- Bono por Volumen (Provision y Real)
select * from PagoPospagoBonoPorVolumenDEXCorpo where periodo_pago = '202006';

-- Renovaciones (Provision y Real)
select * from PagoPospagoRenovacionesDEXCorpo where periodo_pago = '202006';

/*=======================================================================================
 MASIVO
=======================================================================================*/
-- Ventas (Provision y Real)
select * from PagoPospagoVentasDEXMasivo where periodo_pago = '202006';

-- Permanencia (Provision)
select * from PagoPospagoPermanenciaDEXMasivoSM where periodo_pago = '202006';

-- Permanencia (Real)
select * from PagoPospagoPermanenciaDEXMasivo where periodo_pago = '202006';

-- Renovaciones
select * from STG_DMSVPOS_COMI.dbo.TXN_POSPAGO_RENOVACIONES_MASIVO where periodo_pago = '202006';

/*=======================================================================================
 TELEMARKETING
=======================================================================================*/
-- Ventas TMK Nuevo Esquema (Provision y Real)
select * from PagoPospagoVentasTMKNE where PERIODO_PAGO = '202006';

-- Permanencias TMK Nuevo Esquema (Provision y Real)
select * from PagoPospagoPermanenciaTMKNE where PERIODO_PAGO = '202006';

-- Renovaciones TMK Nuevo Esquema (Provision y Real)
select * from PagoPospagoRenovacionesTMKNE where PERIODO_PAGO = '202006';

-- Adicionales UpSell Datos, Voz, SF, FB TMK Nuevo Esquema (Provision y Real)
select * from PagoPospagoAdicionalesTMKNE where PERIODO_PAGO = '202006';