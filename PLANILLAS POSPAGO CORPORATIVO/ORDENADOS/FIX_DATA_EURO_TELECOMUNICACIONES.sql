declare @periodo_pago varchar(6) = '202003'
declare @acreedor_nuevo varchar(9) = '900004208'
declare @acreedor_anterior varchar(9) = '700000209'

--ACTUALIZACION DE ACREEDOR_ID, NOMBRE_DISTRIBUIDOR Y DEALER_NAME EN PERMANENCIA
update a
set a.ACREEDOR_ID = @acreedor_nuevo
	,a.DISTRIBUIDOR = 'EURO TELECOMUNICACIONES'
	,a.DEALER_NAME = REPLACE(DEALER_NAME, 'EUROCOMUNICACIONES','EURO TELECOMUNICACIONES')
--select REPLACE(DEALER_NAME, 'EUROCOMUNICACIONES','EURO TELECOMUNICACIONES') ND, A.*
FROM PagoPospagoPermanenciaDEXMasivo a
WHERE DISTRIBUIDOR LIKE '%euro%'
 and PERIODO_PAGO = @periodo_pago
 and ACREEDOR_ID = @acreedor_anterior
 

update a
set a.ACREEDOR_ID = @acreedor_nuevo
	,a.DISTRIBUIDOR = 'EURO TELECOMUNICACIONES'
	,a.DEALER_NAME = REPLACE(DEALER_NAME, 'EUROCOMUNICACIONES','EURO TELECOMUNICACIONES')
--select REPLACE(DEALER_NAME, 'EUROCOMUNICACIONES','EURO TELECOMUNICACIONES') ND, A.*
FROM PagoPospagoPermanenciaDEXMasivo a
WHERE DISTRIBUIDOR LIKE '%euro%'
 and PERIODO_PAGO = @periodo_pago
 and ACREEDOR_ID = @acreedor_nuevo
 
update a
set a.ACREEDOR_ID = @acreedor_nuevo
	,a.DISTRIBUIDOR = 'EURO TELECOMUNICACIONES'
	,a.DEALER_NAME = REPLACE(DEALER_NAME, 'EUROCOMUNICACIONES','EURO TELECOMUNICACIONES')
--select REPLACE(DEALER_NAME, 'EUROCOMUNICACIONES','EURO TELECOMUNICACIONES') ND, A.*
FROM ClawbackPospagoDistribuidores a
WHERE DISTRIBUIDOR LIKE '%euro%'
 and PERIODO_PAGO = @periodo_pago
 --and ACREEDOR_ID = @acreedor_nuevo
 


/*
SELECT * FROM PagoPospagoConsolidadoDEXMasivo where PERIODO_PAGO = '202002' and DISTRIBUIDOR like '%euro%' and TRANSACCION like '%perma%'

SELECT * FROM PagoPospagoPermanenciaDEXMasivo where PERIODO_PAGO = '202002' and DISTRIBUIDOR like '%euro%'

select * from DimDealer where dealer_code = 'TV087AR'

select DISTINCT DISTRIBUIDOR, ACREEDOR_ID from ClawbackPospagoDistribuidores where PERIODO_PAGO = '202002' and DISTRIBUIDOR like '%EURO%'

*/