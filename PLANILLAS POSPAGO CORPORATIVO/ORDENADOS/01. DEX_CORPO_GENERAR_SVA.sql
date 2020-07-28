
/* Formatted on 2018/12/10 11:43 (Formatter Plus v4.8.8) */


declare @p_periodo_pago nvarchar(6) = '202007'
declare @p_periodo_corte nvarchar(6) = '202006'

delete from PagoPospagoSVADEXCorpo where periodo_pago = @p_periodo_pago 

INSERT INTO PagoPospagoSVADEXCorpo
SELECT x.*,
       CASE
          WHEN x.unidades_total >= x.meta_unidades
          AND x.monto_total >= x.meta_monto
             THEN 3
          ELSE 2
       END factor,
       CASE
          WHEN x.unidades_total >= x.meta_unidades
          AND x.monto_total >= x.meta_monto
             THEN x.accessfee * 3
          ELSE x.accessfee * 2
       END comision,
       (  CASE
             WHEN x.unidades_total >= x.meta_unidades
             AND x.monto_total >= x.meta_monto
                THEN x.accessfee * 3
             ELSE x.accessfee * 2
          END
        / 1.13
       ) comision_sin_iva,
       18 tipotrans_id  
  FROM (SELECT a.pais_id, a.pais_abrv, a.plcode, a.pais_nombre,
               @p_periodo_pago periodo_pago, a.periodo, a.fecha_id, a.co_signed,
               a.co_activated, a.ch_validfrom, a.fecha_data, a.co_installed,
               a.co_entdate, a.co_expir_date, a.userlastmod, a.customer_id,
               a.co_id, a.dn_num, a.tmcode, a.tmcode_date, a.razon_alta,
               a.nombre_plan, a.co_estado_act_id, a.co_estado_act_fecha,
               a.co_estado_act_desc, a.custcode, a.prgcode, a.billcycle,
               a.cssocialsecno, a.modalidad, a.categoria_cliente,
               a.nombre_cliente, a.apellido_cliente, a.nombre_completo,
               a.cs_activ_date, a.dealer_code, a.dealer_name, a.plazo_desc,
               a.plazo_num, a.tipo_contrato, 'SVA' tipo_producto,
               a.serv_sncode, a.serv_status, a.serv_histno,
               a.serv_transactiono, a.serv_valid_from_date, a.serv_entry_date,
               a.paqt_spcode, a.paqt_histno, a.paqt_transactionno,
               a.paqt_valid_from_date, a.accessfee, a.csind,
               a.nombre_servicio, a.nombre_paquete, b.distribuidor, b.canal,
               b.sub_canal, b.acreedor_id, 15 meta_unidades, 700 meta_monto,
               SUM (1) OVER (PARTITION BY a.periodo, b.distribuidor)
                                                               unidades_total,
               SUM (a.accessfee / 1.13) OVER (PARTITION BY a.periodo, b.distribuidor)
                                                                  monto_total
          FROM factpospagoservicios a INNER JOIN dimdealer b
               ON b.dealer_code = a.dealer_code
         WHERE a.periodo = @p_periodo_corte
           AND a.fecha_id BETWEEN CONVERT (VARCHAR (8), b.fecha_ini, 112)
                              AND CONVERT (VARCHAR (8),
                                           isnull (b.fecha_fin, getdate ()),
                                           112
                                          )
           AND b.canal = 'CORPORATIVO'
           AND b.sub_canal LIKE '%distri%'
           AND a.nombre_servicio LIKE '%localiz%') x;
           
           
           
INSERT INTO PagoPospagoSVADEXCorpo
SELECT x.*,
       CASE
          WHEN x.unidades_total >= x.meta_unidades
          AND x.monto_total >= x.meta_monto
             THEN 3
          ELSE 2
       END factor,
       CASE
          WHEN x.unidades_total >= x.meta_unidades
          AND x.monto_total >= x.meta_monto
             THEN x.accessfee * 3
          ELSE x.accessfee * 2
       END comision,
       (  CASE
             WHEN x.unidades_total >= x.meta_unidades
             AND x.monto_total >= x.meta_monto
                THEN x.accessfee * 3
             ELSE x.accessfee * 2
          END
        / 1.13
       ) comision_sin_iva,
       18 tipotrans_id  
  FROM (SELECT a.pais_id, a.pais_abrv, a.plcode, a.pais_nombre,
                @p_periodo_pago periodo_pago, a.periodo, a.fecha_id, a.co_signed,
               a.co_activated, a.ch_validfrom, a.fecha_data, a.co_installed,
               a.co_entdate, a.co_expir_date, a.userlastmod, a.customer_id,
               a.co_id, a.dn_num, a.tmcode, a.tmcode_date, a.razon_alta,
               a.nombre_plan, a.co_estado_act_id, a.co_estado_act_fecha,
               a.co_estado_act_desc, a.custcode, a.prgcode, a.billcycle,
               a.cssocialsecno, a.modalidad, a.categoria_cliente,
               a.nombre_cliente, a.apellido_cliente, a.nombre_completo,
               a.cs_activ_date, a.dealer_code, a.dealer_name, a.plazo_desc,
               a.plazo_num, a.tipo_contrato, 'SVA' tipo_producto,
               a.serv_sncode, a.serv_status, a.serv_histno,
               a.serv_transactiono, a.serv_valid_from_date, a.serv_entry_date,
               a.paqt_spcode, a.paqt_histno, a.paqt_transactionno,
               a.paqt_valid_from_date, a.accessfee, a.csind,
               a.nombre_servicio, a.nombre_paquete, b.distribuidor, b.canal,
               b.sub_canal, b.acreedor_id, 15 meta_unidades, 700 meta_monto,
               SUM (1) OVER (PARTITION BY a.periodo, b.distribuidor)
                                                               unidades_total,
               SUM (a.accessfee / 1.13) OVER (PARTITION BY a.periodo, b.distribuidor)
                                                                  monto_total
          FROM factpospagoservicios a INNER JOIN dimdealer b
               ON b.dealer_code = a.dealer_code
         WHERE a.periodo = @p_periodo_corte
           AND a.fecha_id BETWEEN CONVERT (VARCHAR (8), b.fecha_ini, 112)
                              AND CONVERT (VARCHAR (8),
                                           isnull (b.fecha_fin, getdate ()),
                                           112
                                          )
           AND b.canal = 'CORPORATIVO'
           AND b.sub_canal LIKE '%distri%'
           AND upper(a.nombre_servicio) LIKE '%NOTIFI%') x;