select * 

update a
set A.SUB_CANAL = 'Distribuidor Masivo'
from PagoHistoricoComisiones a
WHERE SUB_CANAL LIKE '%distri%masivo%'

update a
set A.SUB_CANAL = 'Distribuidor Corp'
from PagoHistoricoComisiones a
WHERE SUB_CANAL LIKE '%distri%corp%'

update a
set A.SUB_CANAL = 'Agencia Tercerizada'
from PagoHistoricoComisiones a
WHERE SUB_CANAL LIKE '%agencia%terce%'


update a
set A.SUB_CANAL = 'Telemarketing'
from PagoHistoricoComisiones a
WHERE SUB_CANAL LIKE '%aliado%'


select SUB_CANAL, SUM(COMISION) COMISION from PagoHistoricoComisiones where NEGOCIO = 'POSPAGO' AND PERIODO_PAGO = '201902' GROUP BY SUB_CANAL