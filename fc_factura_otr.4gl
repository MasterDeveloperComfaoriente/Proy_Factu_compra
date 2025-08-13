GLOBALS "fc_globales.4gl"
DEFINE mnota1   LIKE fc_factura_m.nota1
{function gen_comp_factura(mmtp)

DEFINE mmtp char(1)

define mnit,mnitt like niif141.nit
define mdetdep like niif141.descripcion
define mdetdepp char(50)
define mcosto,mvalorr,mvalors,mvalorsb like niif141.valor
define cnt,cntp, mseredu integer
define mc, md, mdif, mvaltot, mvalanti, mivasub decimal(12,2)
define mcodcopp     like niif141.codcop
define mdocumentoo  like niif141.documento
define mfechaa      like niif141.fecha
define mtp char(2)
DEFINE mfe_medio_pago_aux   RECORD LIKE fe_medio_pago_aux.*
DEFINE mfc_factura_anti     RECORD LIKE fc_factura_anti.*
DEFINE mcon141              RECORD LIKE niif141.*
DEFINE mnumero,xx           INTEGER
DEFINE mdoccru              CHAR(15)
DEFINE mfecven              date
initialize mfc_factura_m.* to null
declare vil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_factura_m.prefijo
  AND fc_factura_m.documento = gfc_factura_m.documento
  --AND fc_factura_m.estado = "P"
foreach vil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare vil255 cursor for
 select * from fc_factura_d 
   where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
   order by codigo
 foreach vil255 into mfc_factura_d.*
  initialize mfc_conta3.* to null
  select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
    AND prefijo=mfc_factura_m.prefijo
    let mcodconta=NULL
    let mcodconta=mfc_conta3.codconta
    let mcodcop=NULL
  if mfc_factura_m.forma_pago="1" then
   CASE
     WHEN mfc_factura_m.medio_pago="10"
      let mcodcop=mfc_conta3.codcop_ef
     WHEN mfc_factura_m.medio_pago="48"
      let mcodcop=mfc_conta3.codcop_ba
     WHEN mfc_factura_m.medio_pago="49"
      let mcodcop=mfc_conta3.codcop_ba
     WHEN mfc_factura_m.medio_pago="42"
      let mcodcop=mfc_conta3.codcop_ba
     WHEN mfc_factura_m.medio_pago="20"
      let mcodcop=mfc_conta3.codcop_ef
     WHEN mfc_factura_m.medio_pago="45"
      let mcodcop=mfc_conta3.codcop_ba
   END CASE
  END IF
  if mfc_factura_m.forma_pago="2" THEN
   let mcodcop=mfc_conta3.codcop_cr
  END if  
 END FOREACH
END FOREACH 
LET mmarca2=mcodcop
CALL doccopcon141_niif()
let mdocumento=null
LET mdocumento=mdo
let mc=0
let md=0
let l=0
LET mvaltot=0
LET mvalanti=0
LET cnt=1
LET xx=mdocumento
WHILE cnt <> 0
 SELECT COUNT(*) INTO cnt FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
 IF cnt <> 0 THEN
  LET xx = xx + 1
  LET mdocumento = xx USING "&&&&&&&"        
 ELSE
  SELECT COUNT(*) INTO cnt FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento AND 
         niif146.codconta = mcodconta
  IF cnt <> 0 THEN
   LET xx = xx + 1
   LET mdocumento = xx USING "&&&&&&&"        
  ELSE
   EXIT WHILE
  END IF
 END IF
END WHILE 
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET gerrflag = FALSE
BEGIN WORK
create temp table con14 
   (
     codconta char(2),
     codcop char(4),
     documento char(7),
     fecha date,
     auxiliar char(12),
     codcen char(4),
     codbod char(2),
     nit char(12),
     descripcion char(30),
     nat char(1),
     valor money(12,2),
     sec smallint
   )
-- Actualiza El comprobante y numero con que fue Generado
UPDATE fc_factura_m 
SET codcop=mcodcop,docu=mdocumento 
 WHERE fc_factura_m.prefijo = gfc_factura_m.prefijo
  AND fc_factura_m.documento = gfc_factura_m.documento
LET mvaltot=0
initialize mfc_factura_m.* to null
declare vvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_factura_m.prefijo
  AND fc_factura_m.documento = gfc_factura_m.documento
  --AND fc_factura_m.estado = "A"
foreach vvil244 into mfc_factura_m.*
 -- VALIDO SI TIENE ANTICIPOS -- EDDY
  LET mvalanti=0
  SELECT sum(valor) INTO mvalanti FROM fc_factura_anti
   where prefijo=mfc_factura_m.prefijo 
     and documento=mfc_factura_m.documento
  IF mvalanti IS NULL THEN LET mvalanti=0 END if       
 initialize mfc_factura_d.* to null
 declare vvil255 cursor for
 select prefijo,documento,codigo,subcodigo,"A",cantidad,sum(valoruni),sum(iva),sum(impc),sum(subsi),sum(valor),cod_bene,sum(valorbene) from fc_factura_d 
  where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  GROUP BY 1,2,3,4,5,6,12 
  order by codigo
 foreach vvil255 into mfc_factura_d.*
  initialize mfc_servicios.* to null
  select * into mfc_servicios.* from fc_servicios 
   where codigo=mfc_factura_d.codigo 
  LET mivasub=0
  initialize mfc_conta3.* to null
  select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo
  initialize mfc_conta1.* to null
  select * into mfc_conta1.* from fc_conta1 
   where codigo=mfc_servicios.codigo
  
  
 
  
  if mfc_conta1.auxiliaring is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliaring
   let mauxiliar=mniif233.auxiliar
   let a="C"
   let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,mfc_servicios.descripcion
   -- VALIDACION SI EL SERVICIO ES DE EDUCACION EL BENEF DE PANDEMIA NO SE DESCUENTA 
   -- DEL INGRESO NI DE LA CARTERA
   LET mseredu = 0
   SELECT COUNT(*) INTO mseredu 
    FROM fc_servicios_prefijos
    WHERE codservicio  = 4
    AND prefijo = mfc_factura_m.prefijo
   IF mseredu IS NULL THEN LET mseredu = 0 END IF
   IF mseredu > 0 THEN
     let mvalor=mfc_factura_d.valor- mvalors
   ELSE 
     let mvalor=mfc_factura_d.valor-(mvalors+mvalorsb)
   END IF  
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencosing
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    IF mfc_factura_m.prefijo="AGEC" THEN
     IF mvalorsb>0 THEN
      if mniif233.tercero="S" THEN
       let mnit=mfe_empresa.nit
      ELSE
       let mnit=NULL
      end IF 
      let l=l+1
      INSERT INTO niif141
        ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
           nit, descripcion, nat, valor, sec )
       VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
           mnit, mdetdep, a, mvalors, l )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF
     END IF
     IF mvalorsb>0 THEN
      if mniif233.tercero="S" THEN
       let mnit=mfe_empresa.nit
      ELSE
       let mnit=NULL
      end IF 
      let l=l+1
      INSERT INTO niif141
        ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
           nit, descripcion, nat, valor, sec )
       VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
           mnit, mdetdep, a, mvalorsb, l )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF
     END IF 
    END IF
   END if 
  end if
  if mfc_conta1.auxiliariva is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliariva
   let mauxiliar=mniif233.auxiliar
   let a="C"
   let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,"-IVA GENERADO"
   {let mfc_factura_d.iva=mfc_factura_d.iva*mfc_factura_d.cantidad
   let mvalor=mfc_factura_d.iva}
   {let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencosiva
   else
    let mcodcen=null
   end IF
   IF mvalor>0 then
   let l=l+1
   INSERT INTO niif141
     ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
        nit, descripcion, nat, valor, sec )
    VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
        mnit, mdetdep, a, mvalor, l )
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
   END if
  end IF
  if mfc_conta1.auxiliarimpc is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarimpc
   let mauxiliar=mniif233.auxiliar
   let a="C"
   let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,"-IMPUESTO CONSUMO"
   {let mfc_factura_d.impc=mfc_factura_d.impc*mfc_factura_d.cantidad
   let mvalor=mfc_factura_d.impc}
  { let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencosimpc
   else
    let mcodcen=null
   end IF
   IF mvalor>0 then
   let l=l+1
   INSERT INTO niif141
     ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
        nit, descripcion, nat, valor, sec )
    VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
        mnit, mdetdep, a, mvalor, l )
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
   END if
  end IF
  if mfc_conta1.auxiliarcar is not null THEN
   IF mfc_factura_m.prefijo="AGEC" THEN
     IF mvalors<>0 THEN
       initialize mniif233.* to NULL
       select * into mniif233.* from niif233 
        where auxiliar=mfc_conta1.auxiliarcar
       let mauxiliar=mniif233.auxiliar
       let a="D"
       let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac 
        USING "&&&&&" clipped,"-SUB TARIFA"}
       --let mfc_factura_d.subsi=mfc_factura_d.subsi*mfc_factura_d.cantidad
      { let mvalor=mvalors
       let md=md+mvalor
       if mniif233.tercero="S" THEN
         let mnit=mfe_empresa.nit
       ELSE
         let mnit=NULL
       end IF
       if mniif233.centros="S" THEN
         let mcodcen=mfc_conta1.cencoscar
       ELSE
         let mcodcen=NULL
       end IF
       IF mvalor>0 THEN
         let l=l+1
        INSERT INTO niif141
        (codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
        nit, descripcion, nat, valor, sec )
         VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
        mnit, mdetdep, a, mvalor, l )
        IF status < 0 THEN
         LET gerrflag = TRUE
        END IF
        if mniif233.detalla="C" or mniif233.detalla="P" THEN
         IF mfc_factura_m.fecha_vencimiento IS NULL THEN
          LET mfc_factura_m.fecha_vencimiento=mfc_factura_m.fecha_factura
         END IF
         LET mfecven=NULL
         LET mfecven=mfc_factura_m.fecha_vencimiento+30
         LET mdoccru=NULL
         CASE
          WHEN mcodconta="03"
           LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
          WHEN mcodconta="07"
           LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
          WHEN mcodconta="08"
           LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
          OTHERWISE
           LET mdoccru=mfc_factura_m.numfac
         END CASE 
         INSERT INTO niif142
          ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fecven )
         VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, x, mdoccru, mfecven )
         IF status < 0 THEN
          LET gerrflag = TRUE
         END IF 
        END IF
       END IF
    END IF
    IF mvalorsb<>0 THEN
    initialize mniif233.* to NULL
    select * into mniif233.* from niif233 
     where auxiliar=mfc_conta1.auxiliarcar
    let mauxiliar=mniif233.auxiliar
    let a="D"
    let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,"-SUB BENEF"
    --let mfc_factura_d.subsi=mfc_factura_d.subsi*mfc_factura_d.cantidad
    let mvalor=mvalorsb
    let md=md+mvalor
    if mniif233.tercero="S" THEN
     let mnit=mfe_empresa.nit
    ELSE
     let mnit=NULL
    end IF
    if mniif233.centros="S" THEN
     let mcodcen=mfc_conta1.cencoscar
    ELSE
     let mcodcen=NULL
    end IF
    IF mvalor>0 THEN
     let l=l+1
     INSERT INTO niif141
     ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
        nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, 
     mauxiliar, mcodcen, null, 
        mnit, mdetdep, a, mvalor, l )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF
     if mniif233.detalla="C" or mniif233.detalla="P" THEN
      IF mfc_factura_m.fecha_vencimiento IS NULL THEN
       LET mfc_factura_m.fecha_vencimiento=mfc_factura_m.fecha_factura
      END if
      LET mfecven=null
      LET mfecven=mfc_factura_m.fecha_vencimiento+30
      LET mdoccru=NULL
      CASE
       WHEN mcodconta="03"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="07"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="08"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       OTHERWISE
        LET mdoccru=mfc_factura_m.numfac
      END case
      INSERT INTO niif142
       ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fecven )
      VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, x, mdoccru, mfecven )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF 
     END IF
    END if
   END IF
   END if
  END if}
  {if mfc_factura_m.forma_pago="2" OR (mfc_factura_m.forma_pago="1" AND mvalanti > 0) THEN  -- FACTURA A CREDITO
   --if mfc_factura_m.medio_pago="10" OR mfc_factura_m.medio_pago="20" THEN 
    if mfc_conta1.auxiliarcar is not null THEN
     initialize mniif233.* to NULL
     select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarcar
     let mauxiliar=mniif233.auxiliar
     let a="D"
     let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,"-FACTURA A CREDITO"}
    { if mfc_factura_m.cuotas<=0 THEN
      LET mfc_factura_m.cuotas=1
     END IF}
     {IF mvalanti > 0 AND  mfc_factura_m.forma_pago="1" THEN
       let mvalor = mvalanti
     ELSE 
       IF mseredu > 0 THEN
          let mvalor=(((mfc_factura_d.valor))/mfc_factura_m.cuotas)
       ELSE
          let mvalor=(((mfc_factura_d.valor+mfc_factura_d.iva+mfc_factura_d.impc)/mfc_factura_m.cuotas))
       END IF   
     end if }
     {let md=md+mvalor
     if mniif233.tercero="S" THEN
      let mnit=mfc_factura_m.nit
     ELSE
      let mnit=NULL
     end IF
     if mniif233.centros="S" THEN
      let mcodcen=mfc_conta1.cencoscar
     ELSE
      let mcodcen=NULL
     end IF
     IF mvalor>0 THEN}
      {FOR x = 1 TO mfc_factura_m.cuotas
       let l=l+1
       INSERT INTO niif141
       ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
          nit, descripcion, nat, valor, sec )
       VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
          mnit, mdetdep, a, mvalor, l )
       IF status < 0 THEN
        LET gerrflag = TRUE
       END IF
       if mniif233.detalla="C" or mniif233.detalla="P" THEN
        IF mfc_factura_m.fecha_vencimiento IS NULL THEN
         LET mfc_factura_m.fecha_vencimiento=mfc_factura_m.fecha_factura
        END if
        IF x<>1 THEN
         LET mfc_factura_m.fecha_vencimiento=mfc_factura_m.fecha_vencimiento+30
        END IF
        LET mdoccru=NULL
      CASE
       WHEN mcodconta="03"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="07"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="08"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       OTHERWISE
        LET mdoccru=mfc_factura_m.numfac
      END case
        INSERT INTO niif142
         ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fecven )
        VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, x, mdoccru, mfc_factura_m.fecha_vencimiento )
        IF status < 0 THEN
         LET gerrflag = TRUE
        END IF 
       END IF
      END for }
 {    END if
    end IF}
   --END IF
  {END IF
  if mfc_factura_m.forma_pago="1" THEN
   if mfc_factura_m.medio_pago="10" OR mfc_factura_m.medio_pago="20" THEN 
    if mfc_conta1.auxiliarcaja is not null THEN
     initialize mniif233.* to NULL
     select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarcaja
     let mauxiliar=mniif233.auxiliar
     let a="D"
     let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,"INGRESO DE CAJA"
     let mvalor=((mfc_factura_d.valor)-(mvalanti))
     let md=md+mvalor
     if mniif233.tercero="S" THEN
      let mnit=mfc_factura_m.nit
     ELSE
      let mnit=NULL
     end IF
     if mniif233.centros="S" THEN
      let mcodcen=mfc_conta1.cencoscaja
     ELSE
      let mcodcen=NULL
     end IF
     IF mvalor>0 THEN
      --let l=l+1
      INSERT INTO con14
        ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
           nit, descripcion, nat, valor, sec )
       VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
           mnit, mdetdep, a, mvalor, 1 )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF
     END IF
    end IF
   END IF
   if mfc_factura_m.medio_pago="48" OR mfc_factura_m.medio_pago="49" OR mfc_factura_m.medio_pago="42" OR mfc_factura_m.medio_pago="45" THEN 
    if mfc_conta1.auxiliarbanco is not null THEN
     initialize mniif233.* to NULL
     select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarbanco
     let mauxiliar=mniif233.auxiliar
     let a="D"
     let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,"-INGRESO BANCO"
     let mvalor=((mfc_factura_d.valor)-(mvalanti))
     let md=md+mvalor
     if mniif233.tercero="S" THEN
      let mnit=mfc_factura_m.nit
     ELSE
      let mnit=NULL
     end IF
     if mniif233.centros="S" THEN
      let mcodcen=mfc_conta1.cencosbanco
     ELSE
      let mcodcen=NULL
     end IF
     IF mvalor>0 THEN
      let l=l+1
      INSERT INTO con14
       ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
          nit, descripcion, nat, valor, sec )
      VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
          mnit, mdetdep, a, mvalor, 1 )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF
       if mniif233.banco="S" THEN
         INSERT INTO niif143
         ( codconta, codcop, documento, sec, estado, numche, usuario, fecest, estche )
         VALUES ( mcodconta, mcodcop, mdocumento, l, "N", mfc_factura_m.numfac, musuario,
         mfecha, "N" )
         IF status < 0 THEN
          LET gerrflag = TRUE
         END IF
      end if
     END IF
    end IF
   END if
  END IF
 end FOREACH
end FOREACH
-- movimiento de la cuenta de anticipo si la toca
initialize mcon141.* to null
 declare prt55 cursor for
 select codconta,codcop,documento,fecha,auxiliar,codcen,codbod,nit,descripcion,
  nat,sum(valor),1 from con14
  group by codconta,codcop,documento,fecha,auxiliar,codcen,codbod,nit,descripcion,nat
  order by auxiliar
 foreach prt55 into mcon141.*
  let l=l+1
  INSERT INTO niif141
   ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
     nit, descripcion, nat, valor, sec )
   VALUES ( mcon141.codconta, mcon141.codcop, mcon141.documento, mcon141.fecha,
     mcon141.auxiliar, mcon141.codcen, mcon141.codbod,  
     mcon141.nit, mcon141.descripcion, mcon141.nat, mcon141.valor, l )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END FOREACH }
 {IF mvalanti > 0 THEN
   initialize mfc_conta3.* to NULL
   select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
    AND prefijo=mfc_factura_m.prefijo
   if mfc_conta1.auxiliarant is not null THEN
     initialize mniif233.* to NULL
     select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarant
     let mauxiliar=mniif233.auxiliar
     let a="D"
     let mvalor=mvalanti
     let md=md+mvalor
     if mniif233.tercero="S" THEN
       let mnit=mfc_factura_m.nit
     ELSE
       let mnit=NULL
     end IF
     if mniif233.centros="S" THEN
       let mcodcen=mfc_conta1.cencosant
     ELSE
      let mcodcen=NULL
     end IF
     IF mvalor>0 THEN
      let l=l+1
      INSERT INTO niif141
       ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
          nit, descripcion, nat, valor, sec )
      VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
          mnit, mdetdep, a, mvalor, l )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fecven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_factura_anti.tipcru, mfc_factura_anti.nocts, mfc_factura_anti.doccru, 
       mfc_factura_anti.fecven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END IF
  end IF 
 END if} 
{
IF NOT gerrflag THEN
 if mc<>md then
  if mc<md then
   let mdif=md-mc
   let x=0
   select max(niif141.sec) into x from niif141 where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.nat="C"
   update niif141 set niif141.valor=(niif141.valor+mdif) 
    where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.sec=x
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   let mdif=mc-md
   let x=0
   select max(niif141.sec) into x from niif141 where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.nat="D"
   update niif141 set niif141.valor=(niif141.valor+mdif) 
    where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.sec=x
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
 end if
END IF
}
{IF NOT gerrflag THEN
 let mhora=time
  INSERT INTO niif339  -- NUEVA AUDITORIA ADICIONA
  ( codconta, codcop, documento, fecha, hora, tipope, usuario )
  VALUES 
  ( mcodconta, mcodcop, mdocumento, mfc_factura_m.fecha_factura, mhora, "A", musuario)
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 INSERT INTO niif149 ( codconta, codcop, documento, fecha, usuadd, usuact, estado )
      VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, musuario, musuario,"A")
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 LET mdetdepp=null
 let mdetdepp="FACTURA DE VENTA - ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&&&" CLIPPED
 INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "1", mdetdepp )
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 LET mdetdepp=null
 let mdetdepp=mfc_factura_m.nota1[1,50]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null
 let mdetdepp=mfc_factura_m.nota1[51,100]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "3", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null 
 let mdetdepp=mfc_factura_m.nota1[101,150]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "4", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null 
 let mdetdepp=mfc_factura_m.nota1[151,200]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "5", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF
IF NOT gerrflag THEN
  set lock mode to wait
  DECLARE con11lock CURSOR FOR
  select ultnum from niif148
   WHERE niif148.codcop=mcodcop
   FOR UPDATE
  OPEN con11lock
  FETCH con11lock
  UPDATE niif148 SET ultnum=ultnum+1 WHERE niif148.codcop=mcodcop
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  CLOSE con11lock 
END IF

IF NOT gerrflag THEN
 COMMIT WORK
 IF mmtp="1" THEN
  CALL FGL_WINMESSAGE( "Administrador", "EL COMPROBANTE FUE ADICIONADO", "information")
 END if 
ELSE
 ROLLBACK WORK
 IF mmtp="1" THEN
  CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "information")
 END if 
END if
DROP TABLE con14
END IF 
END FUNCTION}

{function gen_comp_factura_s(mmtp)
DEFINE mmtp char(1)
define mauxiliar,mauxiliarr like fc_conta1.auxiliariva
define mcodcen,mcodcenn   like fc_conta1.cencosiva
define mnit,mnitt like niif141.nit
define mdetdep like niif141.descripcion
define mdetdepp char(50)
define mcosto,mvalorr,mvalors,mvalorsb like niif141.valor
define cnt,cntp integer
define mc, md, mdif, mvaltot, mvalanti decimal(12,2)
define mcodcopp like niif141.codcop
define mdocumentoo like niif141.documento
define mfechaa,mfecven like niif141.fecha
define mtp char(2)
DEFINE mfe_medio_pago_aux RECORD LIKE fe_medio_pago_aux.*
DEFINE mfc_factura_anti RECORD LIKE fc_factura_anti.*
DEFINE mcon141 RECORD LIKE niif141.*
DEFINE mnumero,xx INTEGER
DEFINE mvals decimal(12,2)
DEFINE mdoccru CHAR(15)
LET mcodconta=NULL
LET mcodcop=NULL
LET mvals=0
initialize mfc_factura_m.* to null
declare suvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_factura_m.prefijo
  AND fc_factura_m.documento = gfc_factura_m.documento
  AND fc_factura_m.estado = "P"
foreach suvil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare suvil255 cursor for
 select * from fc_factura_d where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  order by codigo}
 {foreach suvil255 into mfc_factura_d.*
  IF mfc_factura_d.subsi<>0 THEN
   LET mvals=mvals+mfc_factura_d.subsi  
   initialize mfc_conta3.* to NULL
   select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo
   let mcodconta=NULL
   let mcodconta=mfc_conta3.codconta
   let mcodcop=NULL
   let mcodcop=mfc_conta3.codcop_su
  END if  
 END FOREACH}
{END FOREACH
IF mvals IS NULL OR mvals = 0 THEN
  RETURN
END IF  
IF mcodconta IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO LA CONTABILIDAD PARA COMPROBANTE DEL SUBSIDIO A LA DEMANDA", "stop")
 return
END IF
IF mcodcop IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO EL TIPO DE COMPROBANTE DEL SUBSIDIO A LA DEMANDA", "stop")
 return
END IF
LET mmarca2=mcodcop
CALL doccopcon141_niif()
let mdocumento=null
LET mdocumento=mdo
let mc=0
let md=0
let l=0
LET mvaltot=0
LET mvalanti=0
LET cnt=1
LET xx=mdocumento
WHILE cnt <> 0
 SELECT COUNT(*) INTO cnt FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
 IF cnt <> 0 THEN
  LET xx = xx + 1
  LET mdocumento = xx USING "&&&&&&&"        
 ELSE
  SELECT COUNT(*) INTO cnt FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
  IF cnt <> 0 THEN
   LET xx = xx + 1
   LET mdocumento = xx USING "&&&&&&&"        
  ELSE
   EXIT WHILE
  END IF
 END IF
END WHILE 
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET gerrflag = FALSE
BEGIN WORK
create temp table con14 
   (
     codconta char(2),
     codcop char(4),
     documento char(7),
     fecha date,
     auxiliar char(12),
     codcen char(4),
     codbod char(2),
     nit char(12),
     descripcion char(30),
     nat char(1),
     valor money(12,2),
     sec smallint
   )
LET mvaltot=0
initialize mfc_factura_m.* to null
declare suvvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_factura_m.prefijo
  AND fc_factura_m.documento = gfc_factura_m.documento
  --AND fc_factura_m.estado = "A"
foreach suvvil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare suvvil255 cursor for
 select prefijo,documento,codigo,subcodigo,"A",cantidad,sum(valoruni),sum(iva),sum(impc),sum(subsi),sum(valor),cod_bene,sum(valorbene) from fc_factura_d 
  where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  GROUP BY 1,2,3,4,5,6,12 
  order by codigo
 foreach suvvil255 into mfc_factura_d.*
  initialize mfc_servicios.* to null
  select * into mfc_servicios.* from fc_servicios 
   where codigo=mfc_factura_d.codigo 
  initialize mfc_conta1.* to null
  select * into mfc_conta1.* from fc_conta1 
   where codigo=mfc_servicios.codigo
  initialize mfc_conta3.* to NULL
   select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo 
  if mfc_conta1.auxiliarsubsi is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarsubsi
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,"-SUB TARIFA"
   LET mdetdep = mdetdep CLIPPED
   
   let md=md+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencossubsi
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     IF mfc_factura_m.fecha_vencimiento IS NULL THEN
      LET mfc_factura_m.fecha_vencimiento=mfc_factura_m.fecha_factura
     END if
     LET mfecven=null
     LET mfecven=mfc_factura_m.fecha_vencimiento+30
     LET mdoccru=NULL
      CASE
       WHEN mcodconta="03"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="07"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="08"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       OTHERWISE
        LET mdoccru=mfc_factura_m.numfac
      END case
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fecven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, 1, mdoccru, mfecven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END if 
   END IF
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarcars
   let mauxiliar=mniif233.auxiliar
   let a="C"
   let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,"-SUB TARIFA"
   
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencoscars
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     IF mfc_factura_m.fecha_vencimiento IS NULL THEN
      LET mfc_factura_m.fecha_vencimiento=mfc_factura_m.fecha_factura
     END if
     LET mfecven=null
     LET mfecven=mfc_factura_m.fecha_vencimiento+30
     LET mdoccru=NULL
      CASE
       WHEN mcodconta="03"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="07"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="08"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       OTHERWISE
        LET mdoccru=mfc_factura_m.numfac
      END case
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fecven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, 1, mdoccru, mfecven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END if
   END if
  end IF
 end foreach
end FOREACH

IF NOT gerrflag THEN
 let mhora=time
  INSERT INTO niif339  -- NUEVA AUDITORIA ADICIONA
  ( codconta, codcop, documento, fecha, hora, tipope, usuario )
  VALUES 
  ( mcodconta, mcodcop, mdocumento, mfc_factura_m.fecha_factura, mhora, "A", musuario)
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 INSERT INTO niif149 ( codconta, codcop, documento, fecha, usuadd, usuact, estado )
      VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, musuario, musuario,"A")
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 LET mdetdepp=null
 let mdetdepp="FACTURA - ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&&&" CLIPPED
 INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "1", mdetdepp )
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 LET mdetdepp=null
 let mdetdepp=mfc_factura_m.nota1[1,50]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null
 let mdetdepp=mfc_factura_m.nota1[51,100]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "3", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null 
 let mdetdepp=mfc_factura_m.nota1[101,150]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "4", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null 
 let mdetdepp=mfc_factura_m.nota1[151,200]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "5", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF

IF NOT gerrflag THEN
  set lock mode to wait
  DECLARE scon11lock CURSOR FOR
  select ultnum from niif148
   WHERE niif148.codcop=mcodcop
   FOR UPDATE
  OPEN scon11lock
  FETCH scon11lock
  UPDATE niif148 SET ultnum=ultnum+1 WHERE niif148.codcop=mcodcop
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  CLOSE scon11lock 
END IF
IF NOT gerrflag THEN
 COMMIT WORK
 IF mmtp="1" THEN
  CALL FGL_WINMESSAGE( "Administrador", "EL COMPROBANTE DE SUBSIDIO FUE ADICIONADO", "information")
 END if 
ELSE
 ROLLBACK WORK
 IF mmtp="1" THEN
  CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "information")
 END if
END if
DROP TABLE con14
END IF 
END FUNCTION}

{
function gen_comp_factura_a(mmtp)
DEFINE mmtp char(1)
define mauxiliar,mauxiliarr like fc_conta1.auxiliariva
define mcodcen,mcodcenn   like fc_conta1.cencosiva
define mnit,mnitt like niif141.nit
define mdetdep like niif141.descripcion
define mdetdepp char(50)
define mcosto,mvalorr,mvalors like niif141.valor
define cnt,cntp integer
define mc, md, mdif, mvaltot, mvalanti decimal(12,2)
define mcodcopp like niif141.codcop
define mdocumentoo like niif141.documento
define mfechaa like niif141.fecha
define mtp char(2)
DEFINE mfe_medio_pago_aux RECORD LIKE fe_medio_pago_aux.*
DEFINE mfc_factura_anti RECORD LIKE fc_factura_anti.*
DEFINE mcon141 RECORD LIKE niif141.*
DEFINE mnumero,xx INTEGER
DEFINE mvals decimal(12,2)
LET mcodconta=NULL
LET mcodcop=NULL
LET mvals=0
initialize mfc_factura_m.* to null
declare asuvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_factura_m.prefijo
  AND fc_factura_m.documento = gfc_factura_m.documento
  AND fc_factura_m.estado = "P"
foreach asuvil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare asuvil255 cursor for
 select * from fc_factura_d where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  order by codigo
 foreach asuvil255 into mfc_factura_d.*
  LET mvalanti=0
  SELECT sum(valor) INTO mvalanti FROM fc_factura_anti
   where prefijo=mfc_factura_m.prefijo 
     and documento=mfc_factura_m.documento
     and codigo=mfc_factura_d.codigo
  IF mvalanti<>0 THEN
   LET mvals=mvals+mvalanti  
   initialize mfc_conta3.* to NULL
   select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo
   let mcodconta=NULL
   let mcodconta=mfc_conta3.codconta
   let mcodcop=NULL
   let mcodcop=mfc_conta3.codcop_an
  END if  
 END FOREACH
END FOREACH
IF mvals IS NULL OR mvals = 0 THEN
  RETURN
END IF  
IF mcodconta IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO LA CONTABILIDAD PARA COMPROBANTE DEL ANTICIPO", "stop")
 return
END IF
IF mcodcop IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO EL TIPO DE COMPROBANTE DEL ANTICIPO", "stop")
 return
END IF
LET mmarca2=mcodcop
CALL doccopcon141_niif()
let mdocumento=null
LET mdocumento=mdo
let mc=0
let md=0
let l=0
LET mvaltot=0
LET mvalanti=0
LET cnt=1
LET xx=mdocumento
WHILE cnt <> 0
 SELECT COUNT(*) INTO cnt FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
 IF cnt <> 0 THEN
  LET xx = xx + 1
  LET mdocumento = xx USING "&&&&&&&"        
 ELSE
  SELECT COUNT(*) INTO cnt FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
  IF cnt <> 0 THEN
   LET xx = xx + 1
   LET mdocumento = xx USING "&&&&&&&"        
  ELSE
   EXIT WHILE
  END IF
 END IF
END WHILE 
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF

LET gerrflag = FALSE
BEGIN WORK
create temp table con14 
   (
     codconta char(2),
     codcop char(4),
     documento char(7),
     fecha date,
     auxiliar char(12),
     codcen char(4),
     codbod char(2),
     nit char(12),
     descripcion char(30),
     nat char(1),
     valor money(12,2),
     sec smallint
   )
LET mvaltot=0
initialize mfc_factura_m.* to null
declare asuvvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_factura_m.prefijo
  AND fc_factura_m.documento = gfc_factura_m.documento
 -- AND fc_factura_m.estado = "A"
foreach asuvvil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare asuvvil255 cursor for
 select prefijo,documento,codigo,subcodigo,"A",cantidad,sum(valoruni),sum(iva),sum(impc),sum(subsi),sum(valor) from fc_factura_d 
  where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  GROUP BY 1,2,3,4,5,6 
  order by codigo
 foreach asuvvil255 into mfc_factura_d.*
  initialize mfc_servicios.* to null
  select * into mfc_servicios.* from fc_servicios 
   where codigo=mfc_factura_d.codigo 
  LET mvalanti=0
  SELECT sum(valor) INTO mvalanti FROM fc_factura_anti
   where prefijo=mfc_factura_m.prefijo 
     and documento=mfc_factura_m.documento
     and codigo=mfc_factura_d.codigo

  initialize mfc_conta1.* to null
  select * into mfc_conta1.* from fc_conta1 
   where codigo=mfc_servicios.codigo

  if mfc_conta1.auxiliarant is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarant
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,"-ANTICIPOS"
   initialize mfc_factura_anti.* to NULL
   declare aanvvil255 cursor FOR
   select * from fc_factura_anti 
    where prefijo=mfc_factura_m.prefijo 
     and documento=mfc_factura_m.documento
     AND codigo=mfc_factura_d.codigo 
    order by codigo
   foreach aanvvil255 into mfc_factura_anti.*
    let mvalor=mfc_factura_anti.valor
    let md=md+mvalor
    if mniif233.tercero="S" THEN
     let mnit=mfc_factura_m.nit
    ELSE
     let mnit=NULL
    end IF
    if mniif233.centros="S" THEN
     let mcodcen=mfc_conta1.cencosant
    ELSE
     let mcodcen=NULL
    end IF
    IF mvalor>0 THEN
     let l=l+1
     INSERT INTO niif141
       ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
          nit, descripcion, nat, valor, sec )
      VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
          mnit, mdetdep, a, mvalor, l )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fecven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_factura_anti.tipcru, mfc_factura_anti.nocts, mfc_factura_anti.doccru, 
       mfc_factura_anti.fecven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END IF
   END foreach 
  end IF 
  if mfc_conta1.auxiliarcar is not null THEN
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarcar
   let mauxiliar=mniif233.auxiliar
   let a="C"
   let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac 
   USING "&&&&&" clipped,"-ANTICIPOS"
   let mvalor=mvalanti
   let mc=mc+mvalor
   if mniif233.tercero="S" THEN
     let mnit=mfc_factura_m.nit
   ELSE
     let mnit=NULL
   end IF
   if mniif233.centros="S" THEN
    let mcodcen=mfc_conta1.cencoscar
   ELSE
    let mcodcen=NULL
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
     ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
       nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, 
       mauxiliar, mcodcen, null, mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   END IF
  END if
 end foreach
end FOREACH}

{
IF NOT gerrflag THEN
 if mc<>md then
  if mc<md then
   let mdif=md-mc
   let x=0
   select max(niif141.sec) into x from niif141 where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.nat="C"
   update niif141 set niif141.valor=(niif141.valor+mdif) 
    where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.sec=x
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   let mdif=mc-md
   let x=0
   select max(niif141.sec) into x from niif141 where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.nat="D"
   update niif141 set niif141.valor=(niif141.valor+mdif) 
    where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.sec=x
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
 end if
END IF
}
{IF NOT gerrflag THEN
 let mhora=time
  INSERT INTO niif339  -- NUEVA AUDITORIA ADICIONA
  ( codconta, codcop, documento, fecha, hora, tipope, usuario )
  VALUES 
  ( mcodconta, mcodcop, mdocumento, mfc_factura_m.fecha_factura, mhora, "A", musuario)
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 INSERT INTO niif149 ( codconta, codcop, documento, fecha, usuadd, usuact, estado )
      VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, musuario, musuario,"A")
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF

IF NOT gerrflag THEN
 LET mdetdepp=null
 let mdetdepp="FACTURA DE VENTA - ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&&&" CLIPPED
 INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "1", mdetdepp )
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 LET mdetdepp=null
 let mdetdepp=mfc_factura_m.nota1[1,50]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null
 let mdetdepp=mfc_factura_m.nota1[51,100]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "3", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null 
 let mdetdepp=mfc_factura_m.nota1[101,150]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "4", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null 
 let mdetdepp=mfc_factura_m.nota1[151,200]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "5", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF

IF NOT gerrflag THEN
  set lock mode to wait
  DECLARE ascon11lock CURSOR FOR
  select ultnum from niif148
   WHERE niif148.codcop=mcodcop
   FOR UPDATE
  OPEN ascon11lock
  FETCH ascon11lock
  UPDATE niif148 SET ultnum=ultnum+1 WHERE niif148.codcop=mcodcop
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  CLOSE ascon11lock 
END IF
IF NOT gerrflag THEN
 COMMIT WORK
 IF mmtp="1" THEN
  CALL FGL_WINMESSAGE( "Administrador", "EL COMPROBANTE DE SUBSIDIO FUE ADICIONADO", "information")
 END if 
ELSE
 ROLLBACK WORK
 IF mmtp="1" THEN
  CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "information")
 END if 
END if
DROP TABLE con14
END IF 
END FUNCTION

function gen_comp_factura_b(mmtp)
DEFINE mmtp char(1)
define mauxiliar,mauxiliarr like fc_conta1.auxiliariva
define mcodcen,mcodcenn   like fc_conta1.cencosiva
define mnit,mnitt like niif141.nit
define mdetdep like niif141.descripcion
define mdetdepp char(50)
define mcosto,mvalorr,mvalors,mvalorsb like niif141.valor
define cnt,cntp integer
define mc, md, mdif, mvaltot, mvalanti decimal(12,2)
define mcodcopp like niif141.codcop
define mdocumentoo like niif141.documento
define mfechaa,mfecven like niif141.fecha
define mtp char(2)
DEFINE mfe_medio_pago_aux RECORD LIKE fe_medio_pago_aux.*
DEFINE mfc_factura_anti RECORD LIKE fc_factura_anti.*
DEFINE mcon141 RECORD LIKE niif141.*
DEFINE mnumero,xx INTEGER
DEFINE mvals decimal(12,2)
DEFINE mdoccru CHAR(15)
DEFINE mpreedu smallint
LET mcodconta=NULL
LET mcodcop=NULL
LET mvals=0
initialize mfc_factura_m.* to null
declare bsuvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_factura_m.prefijo
  AND fc_factura_m.documento = gfc_factura_m.documento
  AND fc_factura_m.estado = "P"
foreach bsuvil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare bsuvil255 cursor for
 select * from fc_factura_d where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  order by codigo}
 {foreach bsuvil255 into mfc_factura_d.*
  IF mfc_factura_d.valorbene<>0 THEN
   LET mvals=mvals+mfc_factura_d.valorbene  
   initialize mfc_beneficios.* to NULL
   select * into mfc_beneficios.* from fc_beneficios 
    where codigo=mfc_factura_d.cod_bene
   initialize mfc_conta3.* to NULL
   select * into mfc_conta3.* from fc_conta3 
    where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo
   let mcodconta=NULL
   let mcodconta=mfc_conta3.codconta
   let mcodcop=NULL
   let mcodcop=mfc_beneficios.codcop
  END if  
 END FOREACH}
{END FOREACH
IF mvals IS NULL OR mvals = 0 THEN
  RETURN
END IF  
IF mcodconta IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO LA CONTABILIDAD PARA COMPROBANTE DEL BENEFICIO", "stop")
 return
END IF
IF mcodcop IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO EL TIPO DE COMPROBANTE DEL BENEFICIO", "stop")
 return
END IF
LET mmarca2=mcodcop
CALL doccopcon141_niif()
let mdocumento=null
LET mdocumento=mdo
let mc=0
let md=0
let l=0
LET mvaltot=0
LET mvalanti=0
LET cnt=1
LET xx=mdocumento
WHILE cnt <> 0
 SELECT COUNT(*) INTO cnt FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
 IF cnt <> 0 THEN
  LET xx = xx + 1
  LET mdocumento = xx USING "&&&&&&&"        
 ELSE
  SELECT COUNT(*) INTO cnt FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
  IF cnt <> 0 THEN
   LET xx = xx + 1
   LET mdocumento = xx USING "&&&&&&&"        
  ELSE
   EXIT WHILE
  END IF
 END IF
END WHILE 
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET gerrflag = FALSE
BEGIN WORK
create temp table con14 
   (
     codconta char(2),
     codcop char(4),
     documento char(7),
     fecha date,
     auxiliar char(12),
     codcen char(4),
     codbod char(2),
     nit char(12),
     descripcion char(30),
     nat char(1),
     valor money(12,2),
     sec smallint
   )
LET mvaltot=0
initialize mfc_factura_m.* to null
declare bsuvvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_factura_m.prefijo
  AND fc_factura_m.documento = gfc_factura_m.documento
  AND fc_factura_m.estado = "P"
foreach bsuvvil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare bsuvvil255 cursor for
 select prefijo,documento,codigo,subcodigo,"A",
 cantidad,sum(valoruni),sum(iva),sum(impc),sum(subsi),sum(valor),cod_bene,sum(valorbene) 
  from fc_factura_d 
  where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  GROUP BY 1,2,3,4,5,6,12 
  order by codigo
 foreach bsuvvil255 into mfc_factura_d.*
  initialize mfc_servicios.* to null
  select * into mfc_servicios.* from fc_servicios 
   where codigo=mfc_factura_d.codigo
  initialize mfc_conta1.* to null
  select * into mfc_conta1.* from fc_conta1 
   where codigo=mfc_servicios.codigo
  initialize mfc_conta3.* to NULL
   select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo 
  initialize mfc_beneficios.* to NULL
   select * into mfc_beneficios.* from fc_beneficios 
   
  if mfc_beneficios.auxiliardb is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_beneficios.auxiliardb
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,"-SUB BENEFICIOS"
   LET mdetdep = mdetdep CLIPPED
  
   let md=md+mvalor
   if mniif233.tercero="S" THEN
    IF mfc_factura_d.prefijo ="AGEC" THEN
        let mnit="890500675"
     ELSE
        LET mnit= mfc_factura_m.nit
     END if   
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencossubsi
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     IF mfc_factura_m.fecha_vencimiento IS NULL THEN
      LET mfc_factura_m.fecha_vencimiento=mfc_factura_m.fecha_factura
     END if
     LET mfecven=null
     LET mfecven=mfc_factura_m.fecha_vencimiento+30
     LET mdoccru=NULL
      CASE
       WHEN mcodconta="03"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="07"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="08"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       OTHERWISE
        LET mdoccru=mfc_factura_m.numfac
      END case
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fecven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, 1, mdoccru, mfecven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END if 
   END IF
   -- VALIDAR SI ES UN PREFIJO DE EDUCACION 
   LET mpreedu = 0
    SELECT COUNT(*) INTO mpreedu
      FROM fc_servicios_prefijos
       WHERE prefijo = mfc_factura_m.prefijo 
       AND codservicio = 4   
   IF mpreedu IS NULL THEN LET mpreedu = 0 END IF
   initialize mniif233.* to null
   IF mpreedu > 0 THEN
    select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarcar
     let mauxiliar=mniif233.auxiliar
   ELSE   
     select * into mniif233.* from niif233 
      where auxiliar=mfc_beneficios.auxiliarcr
     let mauxiliar=mniif233.auxiliar
   END IF   
   let a="C"
   let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,"-SUB BENEFICIOS"
   
   let mc=mc+mvalor
   if mniif233.tercero="S" THEN
     IF mpreedu > 0 THEN
       let mnit=mfc_factura_m.nit
     else
       let mnit="890500675" 
     END if  
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencoscar
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     IF mfc_factura_m.fecha_vencimiento IS NULL THEN
      LET mfc_factura_m.fecha_vencimiento=mfc_factura_m.fecha_factura
     END if  
     LET mfecven=null
     LET mfecven=mfc_factura_m.fecha_vencimiento+30
     LET mdoccru=NULL
      CASE
       WHEN mcodconta="03"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="07"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="08"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       OTHERWISE
        LET mdoccru=mfc_factura_m.numfac
      END case
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fecven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, 1, mdoccru, mfecven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END if
   END if
  end IF
 end foreach
end FOREACH
IF NOT gerrflag THEN
 let mhora=time
  INSERT INTO niif339  -- NUEVA AUDITORIA ADICIONA
  ( codconta, codcop, documento, fecha, hora, tipope, usuario )
  VALUES 
  ( mcodconta, mcodcop, mdocumento, mfc_factura_m.fecha_factura, mhora, "A", musuario)
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 INSERT INTO niif149 ( codconta, codcop, documento, fecha, usuadd, usuact, estado )
      VALUES ( mcodconta, mcodcop , mdocumento, mfc_factura_m.fecha_factura, musuario, musuario,"A")
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 LET mdetdepp=null
 let mdetdepp="SUB BENEFICIOS - FACTURA - ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&&&" CLIPPED
 INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "1", mdetdepp )
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 LET mdetdepp=null
 let mdetdepp=mfc_factura_m.nota1[1,50]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null
 let mdetdepp=mfc_factura_m.nota1[51,100]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "3", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null 
 let mdetdepp=mfc_factura_m.nota1[101,150]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "4", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null 
 let mdetdepp=mfc_factura_m.nota1[151,200]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "5", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF}
{
IF NOT gerrflag THEN
  set lock mode to wait
  DECLARE bscon11lock CURSOR FOR
  select ultnum from niif148
   WHERE niif148.codcop=mcodcop
   FOR UPDATE
  OPEN bscon11lock
  FETCH bscon11lock
  UPDATE niif148 SET ultnum=ultnum+1 WHERE niif148.codcop=mcodcop
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  CLOSE bscon11lock 
END IF
IF NOT gerrflag THEN
 COMMIT WORK
 IF mmtp="1" THEN
  CALL FGL_WINMESSAGE( "Administrador", "EL COMPROBANTE DE SUBSIDIO FUE ADICIONADO", "information")
 END if 
ELSE
 ROLLBACK WORK
 IF mmtp="1" THEN
  CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "information")
 END if
END if
DROP TABLE con14
END IF 
END FUNCTION}

{FUNCTION act_totales_factura(mpref, mdocum)
 DEFINE mpref        LIKE  fc_factura_m.prefijo
 DEFINE mdocum       LIKE  fc_factura_m.documento
 DEFINE mbaseimpo, mtotiva, mtotimpc, mtotpag FLOAT
 DEFINE idunico     INTEGER 
 DEFINE mtimpbruto, mtbasimp, mttotimp, mttotdesc, mtotant, mttotpag, mimpbruto FLOAT
 DEFINE mtotreg smallint
 LET mtimpbruto = 0
 LET mtbasimp = 0
 let mttotimp = 0
 let mttotdesc = 0
 let mtotant = 0
 LET mttotpag = 0
 LET mtotreg = 0
 INITIALIZE mfc_factura_m.* TO NULL
 SELECT * INTO mfc_factura_m.*
  FROM fc_factura_m
   WHERE fc_factura_m.prefijo = mpref
    AND fc_factura_m.documento = mdocum
 IF mfc_factura_m.medio_pago IS NULL THEN
   UPDATE fc_factura_m
    SET medio_pago = "1"
    WHERE fc_factura_m.prefijo = mpref
    AND fc_factura_m.documento = mdocum
 END IF
 IF mfc_factura_m.tipodocumento IS NULL THEN
   UPDATE fc_factura_m
    SET tipodocumento = "1", tipoope = "10"
    WHERE fc_factura_m.prefijo = mpref
    AND fc_factura_m.documento = mdocum
  END IF
 INITIALIZE mfc_prefijos.* TO NULL
 SELECT * INTO mfc_prefijos.*
  FROM fc_prefijos
 WHERE  fc_prefijos.prefijo =mpref
 DELETE FROM fc_factura_imp 
  WHERE fc_factura_imp.prefijo = mpref
   AND fc_factura_imp.documento = mdocum
 DELETE FROM fc_factura_tot 
  WHERE fc_factura_tot.prefijo = mpref
   AND fc_factura_tot.documento = mdocum
 DECLARE cur_tot_fac CURSOR FOR
   SELECT *, rowid FROM fc_factura_d
    WHERE fc_factura_d.prefijo = mpref
    AND fc_factura_d.documento = mdocum
 FOREACH cur_tot_fac INTO mfc_factura_d.*, idunico
   INITIALIZE mfc_servicios.*  TO NULL
   SELECT * INTO mfc_servicios.*
     FROM fc_servicios
    WHERE fc_servicios.codigo = mfc_factura_d.codigo 
   LET mtotreg = mtotreg + 1 
   LET mbaseimpo = (mfc_factura_d.valoruni) * mfc_factura_d.cantidad
   LET mimpbruto = mfc_factura_d.valoruni * mfc_factura_d.cantidad}
   --LET mtotiva = mfc_factura_d.iva*mfc_factura_d.cantidad
  { IF mfc_prefijos.redondeo ="S" THEN
     LET mtotiva = nomredondea((mfc_factura_d.valoruni)* mfc_servicios.iva/100)*mfc_factura_d.cantidad
   ELSE
    LET mtotiva = ((mfc_factura_d.valoruni)* mfc_servicios.iva/100)*mfc_factura_d.cantidad
   END IF }
  { IF mfc_prefijos.redondeo ="S" THEN
     LET mtotimpc =  nomredondea((mfc_factura_d.valoruni)* mfc_servicios.impc/100)*mfc_factura_d.cantidad
   ELSE
     LET mtotimpc =  ((mfc_factura_d.valoruni)* mfc_servicios.impc/100)*mfc_factura_d.cantidad
   END IF  }
  { LET mtotpag =  mbaseimpo + mtotiva + mtotimpc
   LET mtimpbruto = mtimpbruto + mbaseimpo
   LET mtbasimp = mtbasimp + mbaseimpo
   LET mttotimp = mttotimp + mbaseimpo + mtotiva + mtotimpc
   LET mttotdesc = mttotdesc * mfc_factura_d.cantidad
   LET mttotpag = mttotpag + mtotpag}
  { UPDATE fc_factura_d  
     set ( base_imponible, total_iva, total_impc, total_pagar)
      = ( mbaseimpo, mtotiva, mtotimpc, mtotpag)
    WHERE fc_factura_d.prefijo = mfc_factura_d.prefijo
     AND fc_factura_d.documento = mfc_factura_d.documento
     AND fc_factura_d.codigo = mfc_factura_d.codigo
     AND rowid = idunico}
     {IF mfc_factura_d.iva >= 0 THEN
        LET cnt = 0 
        SELECT count(*) INTO cnt 
         FROM fc_factura_imp
          WHERE fc_factura_imp.prefijo = mfc_factura_d.prefijo
          AND fc_factura_imp.documento = mfc_factura_d.documento
          AND fc_factura_imp.porcentaje = mfc_servicios.iva
          AND fc_factura_imp.codimp = "01"
        IF cnt = 0 OR cnt IS NULL THEN
         --IF mtotiva = 0 THEN LET mbasimp = 0 END IF
         INSERT INTO fc_factura_imp 
          ( prefijo, documento, codimp, porcentaje, valor, base, autoret)
          VALUES ( mfc_factura_d.prefijo ,mfc_factura_d.documento, "01",
           mfc_servicios.iva, mtotiva, mbaseimpo, 0) 
        ELSE
          UPDATE fc_factura_imp 
            SET valor = valor + mtotiva, base = base + mbaseimpo
           WHERE fc_factura_imp.prefijo = mfc_factura_d.prefijo
           AND fc_factura_imp.documento = mfc_factura_d.documento
           AND fc_factura_imp.porcentaje = mfc_servicios.iva
           AND fc_factura_imp.codimp = "01"
        END IF 
      END IF 
     IF mfc_factura_d.impc > 0 THEN
       LET cnt = 0 
       SELECT count(*) INTO cnt 
        FROM fc_factura_imp
         WHERE fc_factura_imp.prefijo = mfc_factura_d.prefijo
         AND fc_factura_imp.documento = mfc_factura_d.documento
         AND fc_factura_imp.porcentaje = mfc_servicios.impc
         AND fc_factura_imp.codimp = "02" 
        IF cnt = 0 OR cnt IS NULL THEN
           INSERT INTO fc_factura_imp 
           ( prefijo, documento, codimp, porcentaje, valor, base, autoret)
           VALUES ( mfc_factura_d.prefijo ,mfc_factura_d.documento, "02",
            mfc_servicios.impc, mtotimpc, mbaseimpo, 0) 
        ELSE
          UPDATE fc_factura_imp 
            SET valor = valor + mtotimpc, base = base + mbaseimpo
           WHERE fc_factura_imp.prefijo = mfc_factura_d.prefijo
           AND fc_factura_imp.documento = mfc_factura_d.documento
           AND  fc_factura_imp.porcentaje = mfc_servicios.impc
           AND fc_factura_imp.codimp = "02"
        END IF 
      END IF   }
 { END FOREACH 
  SELECT sum(valor) INTO mtotant
   FROM fc_factura_anti
    WHERE fc_factura_anti.prefijo = mpref
    AND fc_factura_anti.documento = mdocum
    IF mtotant IS NULL THEN 
        LET mtotant = 0
    END if
   SELECT * INTO mfe_empresa.*  FROM fe_empresa
   IF mtotant > 0 THEN
    LET mttotpag = mttotpag - mtotant
   END IF
  INSERT INTO fc_factura_tot
     ( prefijo, documento, totreg, importebruto, baseimponible, baseconimpu,
     total_descuentos, total_cargos, total_anticipos, total_factura, moneda)
    VALUES
     (mpref, mdocum, mtotreg, mtimpbruto, mtbasimp, mttotimp, mttotdesc, 0,
      mtotant, mttotpag, mfe_empresa.moneda)
END FUNCTION}
{
FUNCTION act_totales_nota(mtipo, mdocum)
 DEFINE mtipo        LIKE  fc_nota_m.tipo
 DEFINE mdocum, mdocumento       LIKE  fc_nota_m.documento
 DEFINE mbaseimpo, mtotiva, mtotimpc, mtotpag FLOAT
 DEFINE idunico     INTEGER 
 DEFINE mtimpbruto, mtbasimp, mttotimp, mttotdesc, mtotant, mttotpag FLOAT
 DEFINE mtotreg smallint
 LET mtimpbruto = 0
 LET mtbasimp = 0
 let mttotimp = 0
 let mttotdesc = 0
 let mtotant = 0
 LET mttotpag = 0
 LET mtotreg = 0
 INITIALIZE mfc_nota_m.* TO NULL
 SELECT * INTO mfc_nota_m.*
  FROM fc_nota_m
   WHERE fc_nota_m.tipo = mtipo
    AND fc_nota_m.documento = mdocum
 INITIALIZE mfc_prefijos.* TO NULL
 SELECT * INTO mfc_prefijos.*
  FROM fc_prefijos
 WHERE fc_prefijos.prefijo = mfc_nota_m.prefijo
 DELETE FROM fc_nota_imp 
  WHERE fc_nota_imp.prefijo = mtipo
   AND fc_nota_imp.documento = mdocum
 DELETE FROM fe_nota_tot 
  WHERE fe_nota_tot.prefijo = mtipo
   AND fe_nota_tot.documento = mdocum
 DECLARE cur_totnota CURSOR FOR
   SELECT *, rowid FROM fe_nota_d
    WHERE fe_nota_d.tipo = mtipo
    AND fe_nota_d.documento = mdocum
 FOREACH cur_totnota INTO mfc_nota_d.*, idunico
   INITIALIZE mfc_servicios.*  TO NULL
   SELECT * INTO mfc_servicios.*
     FROM fc_servicios
    WHERE fc_servicios.codigo = mfc_nota_d.codigo 
   LET mtotreg = mtotreg + 1 
   LET mbaseimpo = (mfc_nota_d.valoruni-mfc_nota_d.subsi-mfc_nota_d.valorbene) * mfc_nota_d.cantidad}
   --LET mtotiva = mfc_nota_d.iva*mfc_nota_d.cantidad
  { IF mfc_prefijos.redondeo ="S" THEN
     LET mtotiva = nomredondea((mfc_nota_d.valoruni-mfc_nota_d.subsi-mfc_nota_d.valorbene)* mfc_servicios.iva/100)*mfc_nota_d.cantidad
   ELSE
     LET mtotiva = nomredondea((mfc_nota_d.valoruni-mfc_nota_d.subsi-mfc_nota_d.valorbene)* mfc_servicios.iva/100)*mfc_nota_d.cantidad
   END IF  }
  { IF mfc_prefijos.redondeo ="S" THEN
     LET mtotimpc = nomredondea((mfc_nota_d.valoruni-mfc_nota_d.subsi-mfc_nota_d.valorbene)* mfc_servicios.impc/100)*mfc_nota_d.cantidad
   ELSE
     LET mtotimpc = nomredondea((mfc_nota_d.valoruni-mfc_nota_d.subsi-mfc_nota_d.valorbene)* mfc_servicios.impc/100)*mfc_nota_d.cantidad
   END IF  }
  { LET mtotpag =  mbaseimpo + mtotiva + mtotimpc
   LET mtimpbruto = mtimpbruto + mbaseimpo 
   LET mtbasimp = mtbasimp + mbaseimpo
   LET mttotimp = mttotimp + mbaseimpo + mtotiva + mtotimpc
   LET mttotdesc = mttotdesc + (mfc_nota_d.subsi + mfc_nota_d.valorbene) * mfc_nota_d.cantidad
   LET mttotpag = mttotpag + mtotpag
   UPDATE fe_nota_d  
     set ( base_imponible, total_iva, total_impc, total_pagar)
      = ( mbaseimpo, mtotiva, mtotimpc, mtotpag)
    WHERE fe_nota_d.tipo = mfc_nota_d.tipo
     AND fe_nota_d.documento = mfc_nota_d.documento
     AND fe_nota_d.codigo = mfc_nota_d.codigo
     AND rowid = idunico
     IF mfc_nota_d.iva >= 0 THEN
        LET cnt = 0 
        SELECT count(*) INTO cnt 
         FROM fc_nota_imp
          WHERE fc_nota_imp.prefijo = mfc_nota_d.tipo
          AND fc_nota_imp.documento = mfc_nota_d.documento}
         { AND fc_nota_imp.porcentaje = mfc_servicios.iva}
          {AND fc_nota_imp.codimp = "01"
        IF cnt = 0 OR cnt IS NULL THEN}
         --IF mtotiva = 0 THEN LET mbasimp = 0 END IF
         {INSERT INTO fc_nota_imp 
          ( prefijo, documento, codimp,  valor, base, autoret)
          VALUES ( mfc_nota_d.tipo ,mfc_nota_d.documento, "01",
           mtotiva, mbaseimpo, 0) 
        ELSE
          UPDATE fc_nota_imp 
            SET valor = valor + mtotiva, base = base + mbaseimpo
           WHERE fc_nota_imp.prefijo = mfc_nota_d.tipo
           AND fc_nota_imp.documento = mfc_nota_d.documento
           AND fc_nota_imp.codimp = "01"
        END IF 
      END IF 
     IF mfc_nota_d.impc > 0 THEN
       LET cnt = 0 
       SELECT count(*) INTO cnt 
        FROM fc_nota_imp
         WHERE fc_nota_imp.prefijo = mfc_nota_d.tipo
         AND fc_nota_imp.documento = mfc_nota_d.documento}
        { AND fc_nota_imp.porcentaje = mfc_servicios.impc}
        { AND fc_nota_imp.codimp = "02" 
        IF cnt = 0 OR cnt IS NULL THEN
           INSERT INTO fc_nota_imp 
           ( prefijo, documento, codimp, valor, base, autoret)
           VALUES ( mfc_nota_d.tipo ,mfc_nota_d.documento, "02",
           mtotimpc, mbaseimpo, 0) 
        ELSE
          UPDATE fc_nota_imp 
            SET valor = valor + mtotimpc, base = base + mbaseimpo
           WHERE fc_nota_imp.prefijo = mfc_nota_d.tipo
           AND fc_nota_imp.documento = mfc_nota_d.documento}
          { AND  fc_nota_imp.porcentaje = mfc_servicios.impc}
          { AND fc_nota_imp.codimp = "02"
        END IF 
      END IF   
  END FOREACH 
  LET mdocumento = ""
  SELECT documento INTO mdocumento
   FROM fc_factura_m
    WHERE prefijo = mfc_nota_m.prefijo
    AND numfac = mfc_nota_m.numfac
  SELECT sum(valor) INTO mtotant
   FROM fc_factura_anti
    WHERE fc_factura_anti.prefijo = mfc_nota_d.prefijo
    AND fc_factura_anti.documento = mdocumento
    IF mtotant IS NULL THEN 
        LET mtotant = 0
    END if
   SELECT * INTO mfe_empresa.*  FROM fe_empresa
   INSERT INTO fe_nota_tot
     ( prefijo, documento, totreg, importebruto, baseimponible, baseconimpu,
     total_descuentos, total_cargos, total_anticipos, totalnota, moneda)
    VALUES
     (mtipo, mdocum, mtotreg, mtimpbruto, mtbasimp, mttotimp, mttotdesc, 0,
      mtotant, mttotpag, mfe_empresa.moneda)
END FUNCTION}
{
function gen_comp_factura_n_rever(mprefijo,mdo1)
DEFINE mprefijo char(5)
DEFINE mdo1 integer

define mauxiliar,mauxiliarr like fc_conta1.auxiliariva
define mcodcen,mcodcenn   like fc_conta1.cencosiva
define mnit,mnitt like niif141.nit
define mdetdep like niif141.descripcion
define mdetdepp char(50)
define mcosto,mvalorr,mvalors,mvalorsb like niif141.valor
define cnt,cntp integer
define mc, md, mdif, mvaltot, mvalanti, mivasub decimal(12,0)
define mcodcopp like niif141.codcop
define mdocumentoo like niif141.documento
define mfechaa like niif141.fecha
define mtp char(2)
DEFINE mfe_medio_pago_aux RECORD LIKE fe_medio_pago_aux.*
DEFINE mfc_factura_anti RECORD LIKE fc_factura_anti.*
DEFINE mcon141 RECORD LIKE niif141.*
DEFINE mnumero,xx INTEGER
DEFINE mfecven DATE
DEFINE m_nomnota char(15)
DEFINE mdoccru CHAR(15) 
initialize mfc_factura_m.* to null
declare revevil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = mprefijo
  AND fc_factura_m.numfac = mdo1
  AND fc_factura_m.estado = "R"
foreach revevil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare revevil255 cursor for
 select * from fc_factura_d where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  order by codigo
 foreach revevil255 into mfc_factura_d.*
  initialize mfc_conta3.* to null
  select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo
  let mcodconta=NULL
  let mcodconta=mfc_conta3.codconta
  let mcodcop=NULL
  let mcodcop=mfe_empresa.codcop_notac
  LET m_nomnota=null
  let m_nomnota="RECHAZADA CLIENTE"
 END FOREACH
END FOREACH 
LET mmarca2=mcodcop
CALL doccopcon141_niif()
let mdocumento=null
LET mdocumento=mdo
let mc=0
let md=0
let l=0
LET mvaltot=0
LET mvalanti=0
LET cnt=1
LET xx=mdocumento
WHILE cnt <> 0
 SELECT COUNT(*) INTO cnt FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
 IF cnt <> 0 THEN
  LET xx = xx + 1
  LET mdocumento = xx USING "&&&&&&&"        
 ELSE
  SELECT COUNT(*) INTO cnt FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
  IF cnt <> 0 THEN
   LET xx = xx + 1
   LET mdocumento = xx USING "&&&&&&&"        
  ELSE
   EXIT WHILE
  END IF
 END IF
END WHILE 
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET gerrflag = FALSE
BEGIN WORK
create temp table con14 
   (
     codconta char(2),
     codcop char(4),
     documento char(7),
     fecha date,
     auxiliar char(12),
     codcen char(4),
     codbod char(2),
     nit char(12),
     descripcion char(30),
     nat char(1),
     valor money(12,2),
     sec SMALLINT
   )

 --Actualiza tipo comprobante y numero
--UPDATE fc_nota_m SET codcop=mcodcop,docu=mdocumento
-- WHERE fc_nota_m.prefijo = gfc_nota_m.prefijo
--  AND fc_nota_m.numfac = gfc_nota_m.numfac

  
LET mvaltot=0
initialize mfc_factura_m.* to null
declare revnvvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = mprefijo
  AND fc_factura_m.numfac = mdo1
  AND fc_factura_m.estado = "R"
foreach revnvvil244 into mfc_factura_m.*
 LET gfc_nota_m.fecha_nota=NULL
 LET gfc_nota_m.fecha_nota=mfc_factura_m.fecest
    
 initialize mfc_factura_d.* to null
 declare revnvvil255 cursor for
 select prefijo,documento,codigo,subcodigo,"A",
 cantidad,sum(valoruni),sum(iva),sum(impc),sum(subsi),sum(valor),cod_bene,sum(valorbene) 
 from fc_factura_d 
  where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  GROUP BY 1,2,3,4,5,6,12 
  order by codigo
 foreach revnvvil255 into mfc_factura_d.*
  initialize mfc_servicios.* to null
  select * into mfc_servicios.* from fc_servicios 
   where codigo=mfc_factura_d.codigo 
  --LET mfc_factura_d.iva=nomredondea(mfc_factura_d.iva)
  --LET mfc_factura_d.impc=nomredondea(mfc_factura_d.impc)
  LET mivasub=0
  --LET mivasub=(mfc_factura_d.subsi*mfc_factura_d.cantidad)*(mfc_servicios.iva/100)
  --LET mfc_factura_d.iva=mfc_factura_d.iva-mivasub
  --LET mfc_factura_d.iva=mfc_factura_d.iva
  LET mvalanti=0
  SELECT sum(valor) INTO mvalanti FROM fc_factura_anti
   where prefijo=mfc_factura_m.prefijo 
     and documento=mfc_factura_m.documento
     and codigo=mfc_factura_d.codigo
  IF mvalanti IS NULL THEN LET mvalanti=0 END if   
  
  initialize mfc_conta3.* to null
  select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo
  initialize mfc_conta1.* to null
  select * into mfc_conta1.* from fc_conta1 
   where codigo=mfc_servicios.codigo
  LET mvalors=0
  
  LET mvalorsb=0
 
  
  if mfc_conta1.auxiliaring is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliaring
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep=mfc_servicios.descripcion
   let mvalor=mfc_factura_d.valor-(mvalanti+mvalors+mvalorsb)
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencosing
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    IF mfc_factura_m.prefijo="AGEC" THEN
     IF mvalors>0 THEN
      if mniif233.tercero="S" THEN
       let mnit=mfe_empresa.nit
      ELSE
       let mnit=NULL
      end IF 
      let l=l+1
      INSERT INTO niif141
        ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
           nit, descripcion, nat, valor, sec )
       VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
           mnit, mdetdep, a, mvalors, l )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF
     END IF 
    END IF
   END if 
  end if
  if mfc_conta1.auxiliariva is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliariva
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep="IVA GENERADO"
   --let mfc_factura_d.iva=mfc_factura_d.iva*mfc_factura_d.cantidad
   --let mvalor=mfc_factura_d.iva
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencosiva
   else
    let mcodcen=null
   end IF
   IF mvalor>0 then
   let l=l+1
   INSERT INTO niif141
     ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
        nit, descripcion, nat, valor, sec )
    VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
        mnit, mdetdep, a, mvalor, l )
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
   END if
  end IF
  if mfc_conta1.auxiliarimpc is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarimpc
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep="IMPUESTO CONSUMO"
   --let mfc_factura_d.impc=mfc_factura_d.impc*mfc_factura_d.cantidad
   --let mvalor=mfc_factura_d.impc
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencosimpc
   else
    let mcodcen=null
   end IF
   IF mvalor>0 then
   let l=l+1
   INSERT INTO niif141
     ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
        nit, descripcion, nat, valor, sec )
    VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
        mnit, mdetdep, a, mvalor, l )
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
   END if
  end IF
   
  if mfc_conta1.auxiliarcar is not null THEN
   IF mfc_factura_m.prefijo="AGEC" THEN}
   { IF mfc_factura_d.subsi<>0 THEN
    initialize mniif233.* to NULL
    select * into mniif233.* from niif233 
     where auxiliar=mfc_conta1.auxiliarcar
    let mauxiliar=mniif233.auxiliar
    let a="C"
    let mdetdep="SUB TARIFA ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac CLIPPED
    --let mfc_factura_d.subsi=mfc_factura_d.subsi*mfc_factura_d.cantidad
    
    let md=md+mvalor
    if mniif233.tercero="S" THEN
     let mnit=mfe_empresa.nit
    ELSE
     let mnit=NULL
    end IF
    if mniif233.centros="S" THEN
     let mcodcen=mfc_conta1.cencoscar
    ELSE
     let mcodcen=NULL
    end IF
    IF mvalor>0 THEN
     let l=l+1
     INSERT INTO niif141
     ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
        nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
        mnit, mdetdep, a, mvalor, l )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF
     if mniif233.detalla="C" or mniif233.detalla="P" THEN
      LET mfecven=null
      LET mfecven=mfc_factura_m.fecha_vencimiento+30
      LET mdoccru=NULL
      CASE
       WHEN mcodconta="03"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="07"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="08"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       OTHERWISE
        LET mdoccru=mfc_factura_m.numfac
      END case
      INSERT INTO niif142
       ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fecven )
      VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, x, mdoccru, mfecven )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF 
     END IF
    END if
   END IF}
   {END if
  END if
  if mfc_factura_m.forma_pago="2" THEN
   --if mfc_factura_m.medio_pago="10" OR mfc_factura_m.medio_pago="20" THEN 
    if mfc_conta1.auxiliarcar is not null THEN
     initialize mniif233.* to NULL
     select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarcar
     let mauxiliar=mniif233.auxiliar
     let a="C"
     let mdetdep="FACTURA A CREDITO ",mfc_factura_m.numfac
     {if mfc_factura_m.cuotas<=0 THEN
      LET mfc_factura_m.cuotas=1
     END if}
     {let mvalor=(((mfc_factura_d.valor)-(mvalanti))/1)
     let md=md+mvalor
     if mniif233.tercero="S" THEN
      let mnit=mfc_factura_m.nit
     ELSE
      let mnit=NULL
     end IF
     if mniif233.centros="S" THEN
      let mcodcen=mfc_conta1.cencoscar
     ELSE
      let mcodcen=NULL
     end IF
     IF mvalor>0 THEN}
      {FOR x = 1 TO mfc_factura_m.cuotas
       let l=l+1
       INSERT INTO niif141
       ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
          nit, descripcion, nat, valor, sec )
       VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
          mnit, mdetdep, a, mvalor, l )
       IF status < 0 THEN
        LET gerrflag = TRUE
       END IF
       if mniif233.detalla="C" or mniif233.detalla="P" THEN
        IF x<>1 THEN
         LET mfc_factura_m.fecha_vencimiento=mfc_factura_m.fecha_vencimiento+30
        END IF
        LET mdoccru=NULL
      CASE
       WHEN mcodconta="03"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="07"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="08"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       OTHERWISE
        LET mdoccru=mfc_factura_m.numfac
      END case
        INSERT INTO niif142
         ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fecven )
        VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, x, mdoccru, mfc_factura_m.fecha_vencimiento )
        IF status < 0 THEN
         LET gerrflag = TRUE
        END IF 
       END IF
      END for }
    { END if
    end IF
   --END IF
  END IF
  if mfc_factura_m.forma_pago="1" THEN
   if mfc_factura_m.medio_pago="10" OR mfc_factura_m.medio_pago="20" THEN 
    if mfc_conta1.auxiliarcaja is not null THEN
     initialize mniif233.* to NULL
     select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarcaja
     let mauxiliar=mniif233.auxiliar
     let a="C"
     let mdetdep="INGRESO DE CAJA ",mfc_factura_m.numfac
     let mvalor=((mfc_factura_d.valor)-(mvalanti))
     let md=md+mvalor
     if mniif233.tercero="S" THEN
      let mnit=mfc_factura_m.nit
     ELSE
      let mnit=NULL
     end IF
     if mniif233.centros="S" THEN
      let mcodcen=mfc_conta1.cencoscaja
     ELSE
      let mcodcen=NULL
     end IF
     IF mvalor>0 THEN
      --let l=l+1
      INSERT INTO con14
        ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
           nit, descripcion, nat, valor, sec )
       VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
           mnit, mdetdep, a, mvalor, 1 )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF
     END IF
    end IF
   END IF
   if mfc_factura_m.medio_pago="48" OR mfc_factura_m.medio_pago="49" OR mfc_factura_m.medio_pago="42" OR mfc_factura_m.medio_pago="45" THEN 
    if mfc_conta1.auxiliarbanco is not null THEN
     initialize mniif233.* to NULL
     select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarbanco
     let mauxiliar=mniif233.auxiliar
     let a="C"
     let mdetdep="INGRESO BANCO ",mfc_factura_m.numfac
     let mvalor=((mfc_factura_d.valor)-(mvalanti))
     let md=md+mvalor
     if mniif233.tercero="S" THEN
      let mnit=mfc_factura_m.nit
     ELSE
      let mnit=NULL
     end IF
     if mniif233.centros="S" THEN
      let mcodcen=mfc_conta1.cencosbanco
     ELSE
      let mcodcen=NULL
     end IF
     IF mvalor>0 THEN
      --let l=l+1
      INSERT INTO con14
       ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
          nit, descripcion, nat, valor, sec )
      VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
          mnit, mdetdep, a, mvalor, 1 )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF
     END IF
    end IF
   END if
  END IF
 end foreach
end FOREACH
initialize mcon141.* to null
 declare nprt55 cursor for
 select codconta,codcop,documento,fecha,auxiliar,codcen,codbod,nit,descripcion,
  nat,sum(valor),1 from con14
  group by codconta,codcop,documento,fecha,auxiliar,codcen,codbod,nit,descripcion,nat
  order by auxiliar
 foreach nprt55 into mcon141.*
  let l=l+1
  INSERT INTO niif141
   ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
     nit, descripcion, nat, valor, sec )
   VALUES ( mcon141.codconta, mcon141.codcop, mcon141.documento, mcon141.fecha,
     mcon141.auxiliar, mcon141.codcen, mcon141.codbod,  
     mcon141.nit, mcon141.descripcion, mcon141.nat, mcon141.valor, l )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END foreach }

{
IF NOT gerrflag THEN
 if mc<>md then
  if mc<md then
   let mdif=md-mc
   let x=0
   select max(niif141.sec) into x from niif141 where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.nat="C"
   update niif141 set niif141.valor=(niif141.valor+mdif) 
    where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.sec=x
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   let mdif=mc-md
   let x=0
   select max(niif141.sec) into x from niif141 where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.nat="D"
   update niif141 set niif141.valor=(niif141.valor+mdif) 
    where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.sec=x
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
 end if
END IF
}
{IF NOT gerrflag THEN
 let mhora=time
  INSERT INTO niif339  -- NUEVA AUDITORIA ADICIONA
  ( codconta, codcop, documento, fecha, hora, tipope, usuario )
  VALUES 
  ( mcodconta, mcodcop, mdocumento, gfc_nota_m.fecha_nota, mhora, "A", musuario)
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 INSERT INTO niif149 ( codconta, codcop, documento, fecha, usuadd, usuact, estado )
      VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, musuario, musuario,"A")
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 LET mdetdepp=null
 let mdetdepp=m_nomnota," A LA FACTURA - ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac CLIPPED
 INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "1", mdetdepp )
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[1,50]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[51,100]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 


 
IF NOT gerrflag THEN
  set lock mode to wait
  DECLARE ncon11lock CURSOR FOR
  select ultnum from niif148
   WHERE niif148.codcop=mcodcop
   FOR UPDATE
  OPEN ncon11lock
  FETCH ncon11lock
  UPDATE niif148 SET ultnum=ultnum+1 WHERE niif148.codcop=mcodcop
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  CLOSE ncon11lock 
END IF

IF NOT gerrflag THEN
 COMMIT WORK
 CALL FGL_WINMESSAGE( "Administrador", "EL COMPROBANTE FUE ADICIONADO", "information")
ELSE
 ROLLBACK WORK
 CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "information") 
END if
DROP TABLE con14
END IF 
END FUNCTION}
{
function gen_comp_factura_s_n_rever(mprefijo,mdo1)
DEFINE mprefijo char(5)
DEFINE mdo1 integer
define mauxiliar,mauxiliarr like fc_conta1.auxiliariva
define mcodcen,mcodcenn   like fc_conta1.cencosiva
define mnit,mnitt like niif141.nit
define mdetdep like niif141.descripcion
define mdetdepp char(50)
define mcosto,mvalorr,mvalors,mvalorsb like niif141.valor
define cnt,cntp integer
define mc, md, mdif, mvaltot, mvalanti decimal(12,2)
define mcodcopp like niif141.codcop
define mdocumentoo like niif141.documento
define mfechaa,mfecven like niif141.fecha
define mtp char(2)
DEFINE mfe_medio_pago_aux RECORD LIKE fe_medio_pago_aux.*
DEFINE mfc_factura_anti RECORD LIKE fc_factura_anti.*
DEFINE mcon141 RECORD LIKE niif141.*
DEFINE mnumero,xx INTEGER
DEFINE mvals decimal(12,2)
DEFINE m_nomnota char(15)
DEFINE mdoccru CHAR(15)
LET m_nomnota=null
let m_nomnota="RECHAZADA CLIENTE"
LET mcodconta=NULL
LET mcodcop=NULL
LET mvals=0
initialize mfc_factura_m.* to null
declare nsuvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = mprefijo
  AND fc_factura_m.numfac = mdo1
  AND fc_factura_m.estado = "R"
foreach nsuvil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare nsuvil255 cursor for
 select * from fc_factura_d where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  order by codigo}
 {foreach nsuvil255 into mfc_factura_d.*
  IF mfc_factura_d.subsi<>0 THEN
   LET mvals=mvals+mfc_factura_d.subsi  
   initialize mfc_conta3.* to NULL
   select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo
   let mcodconta=NULL
   let mcodconta=mfc_conta3.codconta
   let mcodcop=NULL
   let mcodcop=mfc_conta3.codcop_nrs
  END if  
 END FOREACH}
{END FOREACH
IF mvals IS NULL OR mvals = 0 THEN
  RETURN
END IF  
IF mcodconta IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO LA CONTABILIDAD PARA COMPROBANTE DEL SUBSIDIO A LA DEMANDA", "stop")
 return
END IF
IF mcodcop IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO EL TIPO DE COMPROBANTE DEL SUBSIDIO A LA DEMANDA", "stop")
 return
END IF
LET mmarca2=mcodcop
CALL doccopcon141_niif()
let mdocumento=null
LET mdocumento=mdo
let mc=0
let md=0
let l=0
LET mvaltot=0
LET mvalanti=0
LET cnt=1
LET xx=mdocumento
WHILE cnt <> 0
 SELECT COUNT(*) INTO cnt FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
 IF cnt <> 0 THEN
  LET xx = xx + 1
  LET mdocumento = xx USING "&&&&&&&"        
 ELSE
  SELECT COUNT(*) INTO cnt FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
  IF cnt <> 0 THEN
   LET xx = xx + 1
   LET mdocumento = xx USING "&&&&&&&"        
  ELSE
   EXIT WHILE
  END IF
 END IF
END WHILE 
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET gerrflag = FALSE
BEGIN WORK
create temp table con14 
   (
     codconta char(2),
     codcop char(4),
     documento char(7),
     fecha date,
     auxiliar char(12),
     codcen char(4),
     codbod char(2),
     nit char(12),
     descripcion char(30),
     nat char(1),
     valor money(12,2),
     sec smallint
   )
LET mvaltot=0
initialize mfc_factura_m.* to null
declare nsuvvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = mprefijo
  AND fc_factura_m.numfac = mdo1
  AND fc_factura_m.estado = "R"
foreach nsuvvil244 into mfc_factura_m.*
 LET gfc_nota_m.fecha_nota=NULL
 LET gfc_nota_m.fecha_nota=mfc_factura_m.fecest
 
 initialize mfc_factura_d.* to null
 declare nsuvvil255 cursor for
 select prefijo,documento,codigo,subcodigo,"A",cantidad,sum(valoruni),sum(iva),sum(impc),sum(subsi),sum(valor),cod_bene,sum(valorbene) from fc_factura_d 
  where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  GROUP BY 1,2,3,4,5,6,12 
  order by codigo
 foreach nsuvvil255 into mfc_factura_d.*
  initialize mfc_servicios.* to null
  select * into mfc_servicios.* from fc_servicios 
   where codigo=mfc_factura_d.codigo 
  initialize mfc_conta1.* to null
  select * into mfc_conta1.* from fc_conta1 
   where codigo=mfc_servicios.codigo
  initialize mfc_conta3.* to NULL
   select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo 
  if mfc_conta1.auxiliarsubsi is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarsubsi
   let mauxiliar=mniif233.auxiliar
   let a="C"
   let mdetdep="REVERSION SUB TARIFA ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "-------"
   LET mdetdep = mdetdep CLIPPED
   let md=md+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencossubsi
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     LET mfecven=null
     LET mfecven=mfc_factura_m.fecha_vencimiento+30
     LET mdoccru=NULL
      CASE
       WHEN mcodconta="03"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="07"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="08"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       OTHERWISE
        LET mdoccru=mfc_factura_m.numfac
      END case
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fecven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, 1, mdoccru, mfecven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END if 
   END IF
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarcars
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep="REVERSION SUB TARIFA ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac CLIPPED
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencoscars
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     LET mfecven=null
     LET mfecven=mfc_factura_m.fecha_vencimiento+30
     LET mdoccru=NULL
      CASE
       WHEN mcodconta="03"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="07"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       WHEN mcodconta="08"
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,mfc_factura_m.numfac
       OTHERWISE
        LET mdoccru=mfc_factura_m.numfac
      END case
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fecven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, 1, mdoccru, mfecven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END if
   END if
  end IF
 end foreach
end FOREACH

IF NOT gerrflag THEN
 let mhora=time
  INSERT INTO niif339  -- NUEVA AUDITORIA ADICIONA
  ( codconta, codcop, documento, fecha, hora, tipope, usuario )
  VALUES 
  ( mcodconta, mcodcop, mdocumento, gfc_nota_m.fecha_nota, mhora, "A", musuario)
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 INSERT INTO niif149 ( codconta, codcop, documento, fecha, usuadd, usuact, estado )
      VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, musuario, musuario,"A")
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 LET mdetdepp=null
 let mdetdepp=m_nomnota," A LA FACTURA - ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "-------" CLIPPED
 INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "1", mdetdepp )
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[1,50]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[51,100]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "3", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
IF NOT gerrflag THEN
  set lock mode to wait
  DECLARE nscon11lock CURSOR FOR
  select ultnum from niif148
   WHERE niif148.codcop=mcodcop
   FOR UPDATE
  OPEN nscon11lock
  FETCH nscon11lock
  UPDATE niif148 SET ultnum=ultnum+1 WHERE niif148.codcop=mcodcop
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  CLOSE nscon11lock 
END IF
IF NOT gerrflag THEN
 COMMIT WORK
 CALL FGL_WINMESSAGE( "Administrador", "EL COMPROBANTE DE SUBSIDIO FUE ADICIONADO", "information")
ELSE
 ROLLBACK WORK
 CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "information") 
END if
DROP TABLE con14
END IF 
END FUNCTION}

---migracion facturas copago

{FUNCTION traer_factura_pago()
  DEFINE mregimen    char(1)  
  --DEFINE mnumfact    LIKE salud_eps:ccf_facturas_copago.numero_factura
   LET mregimen= NULL  
   LET gerrflag = FALSE
   PROMPT " Digite el Regimen del Copago :  1. Contributivo  2. Subsidiado " for mregimen
   IF mregimen IS NULL THEN
     RETURN
   END IF 
   --LET mnumfact= NULL  
   LET gerrflag = FALSE
   --PROMPT " Digite el Número del copago : " for mnumfact
   --IF mnumfact is null THEN
     --RETURN 
   --END IF  
 --CALL migra_copagos(mnumfact,mregimen)
END FUNCTION  }
{
FUNCTION migra_copagos(tpdocumento,mregimen)
  DEFINE tpnumpac LIKE salud_eps:ccf_facturas_copago.id_paciente
  DEFINE tpdocumento LIKE salud_eps:ccf_facturas_copago.numero_factura 
  DEFINE mregimen LIKE salud_eps:ccf_facturas_copago.id_regimen
  DEFINE prefijo char(5)
  DEFINE documento char(7)
  DEFINE medio_pago,tipoope char(2)
  DEFINE forma_pago,franquicia,estado,tipo_documento char(1)
  DEFINE numche char(15)
  DEFINE contador,cuotas,parti INTEGER
  DEFINE mobs varCHAR(400)
  DEFINE nserv_salud char(255)
  DEFINE nombafil char(100)
  DEFINE mid_paciente   integer
  DEFINE mcodser        LIKE    fc_servicios.codigo
  DEFINE mdiorecep,mdiorecepc,tpersona,tpersonac,mestado,mestadoc char(1)
  DEFINE mnumero LIKE  fc_factura_m.documento
  DEFINE mnit_factura  LIKE fc_terceros.nit
  DEFINE control, x, rownull ,cont,edad SMALLINT
  LET mprefijo =""
  LET mcodser ="" 
   IF mregimen = "1" THEN
     LET prefijo = "FCOP"
     LET mcodser = "00301"
   ELSE
     LET prefijo = "COPS"
     LET mcodser = "00302"
   END IF   
   LET contador=0
   SELECT count(*) INTO contador FROM salud_eps:ccf_facturas_copago
   WHERE salud_eps:ccf_facturas_copago.numero_factura = tpdocumento
      AND salud_eps:ccf_facturas_copago.id_regimen=mregimen
   IF contador IS NULL THEN LET contador = 0 END IF   
   IF contador > 0 THEN
      let mnumero=tpdocumento  USING "&&&&&&&"
      LET contador = NULL 
      SELECT count(*) INTO contador FROM fc_factura_m
       WHERE fc_factura_m.documento=mnumero AND
       fc_factura_m.prefijo=prefijo
      IF contador IS NULL THEN LET contador = 0 END IF 
      IF contador>0 THEN
         MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
         comment= "La Factura ya esta Migrada",
              image= "exclamation")
          COMMAND "Aceptar"
            EXIT MENU
         END MENU
      ELSE
       LET documento=NULL
       LET mnota1=NULL
       LET nserv_salud = NULL
       INITIALIZE mfactu_copagos.* TO NULL
       SELECT * INTO mfactu_copagos.* FROM salud_eps:ccf_facturas_copago
        WHERE salud_eps:ccf_facturas_copago.numero_factura = tpdocumento
          AND salud_eps:ccf_facturas_copago.id_regimen=mregimen
       IF mfactu_copagos.numero_factura IS NOT NULL  THEN
          LET documento=mfactu_copagos.numero_factura USING "&&&&&&&"
          LET mnit_factura = ""
          CALL registro_tercero_copago(mfactu_copagos.id_paciente) RETURNING mnit_factura
          IF mnit_factura IS NULL THEN
            RETURN
          END IF
         
        DECLARE cur_det_copag_sub CURSOR FOR 
         SELECT * INTO mfactu_det_copagos.* 
          FROM salud_eps:ccf_detalle_facturas_copago
          WHERE salud_eps:ccf_detalle_facturas_copago.id_factura_copago =  mfactu_copagos.id_factura
          FOREACH cur_det_copag_sub INTO mfactu_det_copagos.*
            --  LET nota1=nserv_salud clipped,"-",mfactu_det_copagos.observacion_detalle CLIPPED
           INITIALIZE mcups.* TO NULL
           SELECT * INTO mcups.* FROM salud_eps:ccf_cups
           WHERE salud_eps:ccf_cups.id_cups = mfactu_det_copagos.id_codigo_servicio
            IF mcups.desc_cups IS NOT NULL THEN
             IF mnota1 IS NOT NULL THEN
               LET mnota1= mnota1 clipped, " ", "\nServicio : " , mcups.cod_cups CLIPPED, "-", mcups.desc_cups
             ELSE
              LET mnota1= "Servicio : " , mcups.cod_cups CLIPPED, "-", mcups.desc_cups 
             END IF  
            END IF 
           IF mfactu_det_copagos.observacion_detalle  IS NOT NULL THEN
            LET mnota1= mnota1 clipped, "\n", mfactu_det_copagos.observacion_detalle CLIPPED
           END IF
           INSERT INTO fc_factura_d( prefijo,documento,codigo, subcodigo, codcat, 
           cantidad, valoruni, iva, impc, subsi, valor, cod_bene, valorbene)
            VALUES ( prefijo, documento,mcodser,"", "", mfactu_det_copagos.cantidad ,
            mfactu_det_copagos.valor_copago, mfactu_det_copagos.valor_iva,0,0,
             mfactu_det_copagos.valor_total_copago,"",0)   
         END FOREACH
          DISPLAY "Insertando Factura ", prefijo CLIPPED, "-", documento
         INSERT INTO fc_factura_m 
         ( prefijo, documento, fecha_elaboracion, nit, medio_pago,  forma_pago, 
          franquicia, numche, nota1, cuotas, parti, estado, usuario_add, tipodocumento, tipoope )
         VALUES (prefijo, documento, mfactu_copagos.fecha_factura , mnit_factura, 
         "42  ","1","","",mnota1,"1", "1","B", musuario,"1","10" )
         DISPLAY "sttus grabacion maestro factura " ,status
        
         MENU "Información"  ATTRIBUTE( style= "dialog", 
           comment= " La factura fue migrada", image= "information")
           COMMAND "Aceptar"
             EXIT MENU
           END MENU
       END IF 
     END if  
   ELSE
     MENU "Información"  ATTRIBUTE( style= "dialog", 
        comment= " El Copago no existe verifique por Favor", image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  END if
END FUNCTION}
{
FUNCTION registro_tercero_copago(mid_paciente)
 DEFINE tpid,tpidc char(2)
 DEFINE mid_paciente    LIKE salud_eps:ccf_facturas_copago.id_paciente
 DEFINE mdiorecep,mdiorecepc,tpersona,tpersonac,mestado,mestadoc char(1)
 DEFINE edad SMALLINT
 DEFINE mexiste SMALLINT
  LET mnit =""
  INITIALIZE  mafiliados.* TO NULL
  SELECT * INTO mafiliados.* 
   FROM salud_eps:ccf_afiliados
    WHERE salud_eps:ccf_afiliados.id_afiliado = mid_paciente
   LET edad= (TODAY - mafiliados.fecha_nacimiento)/365.25
  DISPLAY " Edad ", edad 
   IF edad < 18 THEN
     IF mafiliados.identificacion_cotizante IS NULL OR mafiliados.identificacion_cotizante ="" THEN
       MENU "Información"  ATTRIBUTE( style= "dialog", 
       comment= "Servicio a menor de edad sin responsable", image="stop")
       COMMAND "Aceptar"
         EXIT MENU
       END MENU
     END if  
     LET mnit = mafiliados.identificacion_cotizante
     LET mnota1 =" Paciente : ", mafiliados.identificacion CLIPPED, "-",
     mafiliados.apellido1 CLIPPED, " ", mafiliados.apellido2 clipped, " ",
     mafiliados.nombre1 CLIPPED, " ", mafiliados.nombre2 clipped
     INITIALIZE mafiliados.* TO NULL
     SELECT * INTO mafiliados.* FROM salud_eps:ccf_afiliados
     WHERE salud_eps:ccf_afiliados.identificacion = mafiliados.identificacion_cotizante  
   ELSE
     LET mnit=mafiliados.identificacion
   END IF   
     INITIALIZE  mzona.* TO NULL
     SELECT * INTO mzona.* FROM salud_eps:ccf_municipios
      WHERE salud_eps:ccf_municipios.id_municipio = mafiliados.id_municipio
    CASE
     when mafiliados.id_tipo_identificacion="2"
       LET tpid="11"
     when mafiliados.id_tipo_identificacion="3"
       LET tpid="12"
     when mafiliados.id_tipo_identificacion="4"
       LET tpid="13"
     when mafiliados.id_tipo_identificacion="5"
       LET tpid="41"
     when mafiliados.id_tipo_identificacion="10"
       LET tpid="22"
     when mafiliados.id_tipo_identificacion="13"
       LET tpid="31"
     when mafiliados.id_tipo_identificacion="7"
      LET tpid="42"
    END CASE
    IF mafiliados.id_tipo_identificacion ="13" THEN
     LET tpersona="1"
    ELSE
     LET tpersona="2"
    END IF 
    IF mafiliados.correo_electronico IS NULL OR mafiliados.correo_electronico ='' THEN
        LET mdiorecep="4"
      ELSE
        LET mdiorecep="1"
      END IF
    LET mestado="A"  
    LET mexiste = NULL
    SELECT count(*) INTO mexiste FROM fc_terceros
     WHERE fc_terceros.nit=mnit
    IF mexiste IS NULL THEN LET mexiste = 0 END IF
     IF mexiste = 0 THEN
      DISPLAY "Insertanto el tercero ", mnit
      INSERT INTO fc_terceros
      (tipid, nit, digver,tipo_persona, regimen, razsoc, primer_apellido, segundo_apellido, 
       primer_nombre, segundo_nombre, direccion, telefono, celular, zona, pais, medio_recep, 
       nit_facturador, email, estado, porcen_parti, fecsis, usuario ) 
      VALUES (tpid, mafiliados.identificacion,"",tpersona,"0", "", mafiliados.apellido1, 
       mafiliados.apellido2, mafiliados.nombre1, mafiliados.nombre2, mafiliados.direccion,
       mafiliados.telefono,mafiliados.celular, mzona.codigo_dpto_mpio,"CO", mdiorecep,"",
       mafiliados.correo_electronico,mestado,0, today, musuario )
      END IF 
     -- validacion terceros contabilidad. (conta04) 
      LET mexiste = 0
      LET mnombre =""
      LET mnombre =   mafiliados.apellido1 CLIPPED, " ", mafiliados.apellido2 clipped, " ",
     mafiliados.nombre1 CLIPPED, " ", mafiliados.nombre2 clipped
      SELECT COUNT(*) INTO mexiste
       FROM conta04
      WHERE conta04.nit = mnit
     IF mexiste IS NULL THEN LET mexiste = 0 END IF
      IF mexiste = 0 THEN
       INSERT INTO conta04 
       (nit, razsoc, direccion, telefono, codzon, tipcon, codact, vendedor, nota, fecsis) 
        VALUES (mnit, mnombre, mafiliados.direccion, mafiliados.telefono, mzona.codigo_dpto_mpio,
         "3","0081", "N", "AFILIADO EPS - CLIENTE COPAGO", today)
      END IF  
    RETURN mnit 
END FUNCTION   
}

-- ACTUALIZA COMPROBANTES NIIF



{FUNCTION mes01niif141()
initialize tpcon_ni2331.* to null
select * into tpcon_ni2331.* from niif233
 where niif233.auxiliar=mniif141.auxiliar
if tpcon_ni2331.auxiliar is not null then
 let l=0 
 select count(*) into l from niif136
  where niif136.ano=mano and niif136.auxiliar=mniif141.auxiliar 
    and niif136.codconta=mcodconta
 if l=0 then
  call ins03niif141()
  IF gerrflag then
   return
  end if
 end if
 case
  when mniif141.nat="D" 
   let mnivel=1
   call nivauxniif1()
   if mniif233.clase<>"0" then
    update niif136 set deb_1=deb_1+mniif141.valor
    where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=2
   call nivauxniif1()
   if mniif233.grupo<>"0" then
    update niif136 set deb_1=deb_1+mniif141.valor
     where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=3
   call nivauxniif1()
   if mniif233.cta<>"00" then
    update niif136 set deb_1=deb_1+mniif141.valor
     where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=4
   call nivauxniif1()
   if mniif233.subcta<>"00" then
    update niif136 set deb_1=deb_1+mniif141.valor
     where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=5
   call nivauxniif1()
   if mniif233.auxuno<>"00" then
    update niif136 set deb_1=deb_1+mniif141.valor
     where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=6
   call nivauxniif1()
   if mniif233.auxdos<>"00" then
    update niif136 set deb_1=deb_1+mniif141.valor
     where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=7
   call nivauxniif1()
   if mniif233.auxtre<>"00" then
    update niif136 set deb_1=deb_1+mniif141.valor
     where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
  when mniif141.nat="C" 
   let mnivel=1
   call nivauxniif1()
   if mniif233.clase<>"0" then
    update niif136 set cre_1=cre_1+mniif141.valor
     where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=2
   call nivauxniif1()
   if mniif233.grupo<>"0" then
    update niif136 set cre_1=cre_1+mniif141.valor
     where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=3
   call nivauxniif1()
   if mniif233.cta<>"00" then
    update niif136 set cre_1=cre_1+mniif141.valor
     where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=4
   call nivauxniif1()
   if mniif233.subcta<>"00" then
    update niif136 set cre_1=cre_1+mniif141.valor
     where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=5
   call nivauxniif1()
   if mniif233.auxuno<>"00" then
    update niif136 set cre_1=cre_1+mniif141.valor
     where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=6
   call nivauxniif1()
   if mniif233.auxdos<>"00" then
    update niif136 set cre_1=cre_1+mniif141.valor
     where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=7
   call nivauxniif1()
   if mniif233.auxtre<>"00" then
    update niif136 set cre_1=cre_1+mniif141.valor
     where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
 end case
 let mnivel=1
 call nivauxniif1()
 if mniif233.clase<>"0" then
  update niif136 set ultmov=mniif141.fecha
   where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 let mnivel=2
 call nivauxniif1()
 if mniif233.grupo<>"0" then
  update niif136 set ultmov=mniif141.fecha
   where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 let mnivel=3
 call nivauxniif1()
 if mniif233.cta<>"00" then
  update niif136 set ultmov=mniif141.fecha
   where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 let mnivel=4
 call nivauxniif1()
 if mniif233.subcta<>"00" then
  update niif136 set ultmov=mniif141.fecha
   where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 let mnivel=5
 call nivauxniif1()
 if mniif233.auxuno<>"00" then
  update niif136 set ultmov=mniif141.fecha
   where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 let mnivel=6
 call nivauxniif1()
 if mniif233.auxdos<>"00" then
  update niif136 set ultmov=mniif141.fecha
   where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 let mnivel=7
 call nivauxniif1()
 if mniif233.auxtre<>"00" then
  update niif136 set ultmov=mniif141.fecha
   where niif136.ano=mano and niif136.auxiliar=mauxiliar
    and niif136.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 if tpcon_ni2331.tercero="S" then
  let l=0 
  select count(*) into l from niif137
   where niif137.ano=mano and niif137.auxiliar=mniif141.auxiliar
     and niif137.nit=mniif141.nit
    and niif137.codconta=mcodconta
  if l=0 then
   call ins05niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif137 set deb_1=deb_1+mniif141.valor
    where niif137.ano=mano and niif137.auxiliar=mniif141.auxiliar
      and niif137.nit=mniif141.nit 
    and niif137.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif137 set cre_1=cre_1+mniif141.valor
    where niif137.ano=mano and niif137.auxiliar=mniif141.auxiliar
      and niif137.nit=mniif141.nit 
    and niif137.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif137 set ultmov=mniif141.fecha
   where niif137.ano=mano and niif137.auxiliar=mniif141.auxiliar
     and niif137.nit=mniif141.nit 
    and niif137.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 if tpcon_ni2331.centros="S" then
  let l=0 
  select count(*) into l from niif138
   where niif138.ano=mano and niif138.auxiliar=mniif141.auxiliar
     and niif138.codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
  if l=0 then
   call ins07niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif138 set deb_1=deb_1+mniif141.valor
    where niif138.ano=mano and niif138.auxiliar=mniif141.auxiliar
      and niif138.codcen=mniif141.codcen
    and niif138.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif138 set cre_1=cre_1+mniif141.valor
    where niif138.ano=mano and niif138.auxiliar=mniif141.auxiliar
      and niif138.codcen=mniif141.codcen
    and niif138.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif138 set ultmov=mniif141.fecha
   where niif138.ano=mano and niif138.auxiliar=mniif141.auxiliar
     and niif138.codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif140
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  if l=0 then
   call ins49niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif140 set deb_1=deb_1+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif140 set cre_1=cre_1+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif140 set ultmov=mniif141.fecha
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 if tpcon_ni2331.detalla="I" then
  let l=0 
  select count(*) into l from niif139
   where niif139.ano=mano and niif139.auxiliar=mniif141.auxiliar
     and niif139.codbod=mniif141.codbod
    and niif139.codconta=mcodconta
  if l=0 then
   call ins22niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif139 set deb_1=deb_1+mniif141.valor
    where niif139.ano=mano and niif139.auxiliar=mniif141.auxiliar and niif139.codbod=mniif141.codbod
    and niif139.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif139 set cre_1=cre_1+mniif141.valor
    where niif139.ano=mano and niif139.auxiliar=mniif141.auxiliar and niif139.codbod=mniif141.codbod
    and niif139.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif139 set ultmov=mniif141.fecha
   where niif139.ano=mano and niif139.auxiliar=mniif141.auxiliar and niif139.codbod=mniif141.codbod 
    and niif139.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 if tpcon_ni2331.detalla="C" or tpcon_ni2331.detalla="P" then
  if mcodconta="05" then
   call actefectoniif141()
  else
   call n_actefectoniif141()
  end if
  IF gerrflag then
   return
  end if
 end if
ELSE
 LET mensa=" ERROR LA CUENTA DEL COMPR NO EXISTE EN ",mniif141.codcop,"-",mniif141.documento,"  ",mniif141.auxiliar," ",mniif141.sec using "&&&&"," "
 CALL FGL_WINMESSAGE( "Administrador", mensa, "stop")
end if
END FUNCTION  }
{FUNCTION mes02niif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif136
      where ano=mano and auxiliar=mniif141.auxiliar 
    and niif136.codconta=mcodconta
     if l=0 then
      call ins03niif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif137
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
    and niif137.codconta=mcodconta
      if l=0 then
       call ins05niif141()
      end if
      if mniif141.nat="D" then 
       update niif137 set deb_2=deb_2+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      else
       update niif137 set cre_2=cre_2+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      end if
      update niif137 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif138
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
      if l=0 then
       call ins07niif141()
      end if
      if mniif141.nat="D" then 
       update niif138 set deb_2=deb_2+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      else
       update niif138 set cre_2=cre_2+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      end if
      update niif138 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif140
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  if l=0 then
   call ins49niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif140 set deb_2=deb_2+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif140 set cre_2=cre_2+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif140 set ultmov=mniif141.fecha
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif139
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      if l=0 then
       call ins22niif141()
      end if
      if mniif141.nat="D" then 
       update niif139 set deb_2=deb_2+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      else
       update niif139 set cre_2=cre_2+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      end if
      update niif139 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
    and niif139.codconta=mcodconta
     end if
     if tpcon_ni2331.detalla="C" or tpcon_ni2331.detalla="P" then
      if mcodconta= "05" then
       call actefectoniif141()
      else
       call n_actefectoniif141()
      end if
     end if
    else
     LET mensa=" ERROR LA CUENTA DEL COMPR NO EXISTE EN ",mniif141.codcop,"-",mniif141.documento,"  ",mniif141.auxiliar," ",mniif141.sec using "&&&&"," "
     CALL FGL_WINMESSAGE( "Administrador", mensa, "stop")
    end if
END FUNCTION}  
{FUNCTION mes03niif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif136
      where ano=mano and auxiliar=mniif141.auxiliar 
    and niif136.codconta=mcodconta
     if l=0 then
      call ins03niif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif137
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
    and niif137.codconta=mcodconta
      if l=0 then
       call ins05niif141()
      end if
      if mniif141.nat="D" then 
       update niif137 set deb_3=deb_3+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      else
       update niif137 set cre_3=cre_3+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      end if
      update niif137 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif138
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
      if l=0 then
       call ins07niif141()
      end if
      if mniif141.nat="D" then 
       update niif138 set deb_3=deb_3+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      else
       update niif138 set cre_3=cre_3+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      end if
      update niif138 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif140
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  if l=0 then
   call ins49niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif140 set deb_3=deb_3+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif140 set cre_3=cre_3+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif140 set ultmov=mniif141.fecha
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif139
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      if l=0 then
       call ins22niif141()
      end if
      if mniif141.nat="D" then 
       update niif139 set deb_3=deb_3+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      else
       update niif139 set cre_3=cre_3+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      end if
      update niif139 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
    and niif139.codconta=mcodconta
     end if
     if tpcon_ni2331.detalla="C" or tpcon_ni2331.detalla="P" then
      if mcodconta= "05" then
       call actefectoniif141()
      else
       call n_actefectoniif141()
      end if
     end if
    ELSE
      LET mensa=" ERROR LA CUENTA DEL COMPR NO EXISTE EN ",mniif141.codcop,"-",mniif141.documento,"  ",mniif141.auxiliar," ",mniif141.sec using "&&&&"," "
      CALL FGL_WINMESSAGE( "Administrador", mensa, "stop")
    end if
END FUNCTION  }
{FUNCTION mes04niif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif136
      where ano=mano and auxiliar=mniif141.auxiliar 
    and niif136.codconta=mcodconta
     if l=0 then
      call ins03niif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif137
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
    and niif137.codconta=mcodconta
      if l=0 then
       call ins05niif141()
      end if
      if mniif141.nat="D" then 
       update niif137 set deb_4=deb_4+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      else
       update niif137 set cre_4=cre_4+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      end if
      update niif137 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif138
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
      if l=0 then
       call ins07niif141()
      end if
      if mniif141.nat="D" then 
       update niif138 set deb_4=deb_4+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      else
       update niif138 set cre_4=cre_4+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      end if
      update niif138 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif140
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  if l=0 then
   call ins49niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif140 set deb_4=deb_4+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif140 set cre_4=cre_4+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif140 set ultmov=mniif141.fecha
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif139
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      if l=0 then
       call ins22niif141()
      end if
      if mniif141.nat="D" then 
       update niif139 set deb_4=deb_4+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      else
       update niif139 set cre_4=cre_4+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      end if
      update niif139 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
    and niif139.codconta=mcodconta
     end if
     if tpcon_ni2331.detalla="C" or tpcon_ni2331.detalla="P" then
      if mcodconta="05" then
       call actefectoniif141()
      else
       call n_actefectoniif141()
      end if
     end if
    ELSE
      LET mensa=" ERROR LA CUENTA DEL COMPR NO EXISTE EN ",mniif141.codcop,"-",mniif141.documento,"  ",mniif141.auxiliar," ",mniif141.sec using "&&&&"," "
      CALL FGL_WINMESSAGE( "Administrador", mensa, "stop")
    end if
END FUNCTION  }
{FUNCTION mes05niif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif136
      where ano=mano and auxiliar=mniif141.auxiliar 
    and niif136.codconta=mcodconta
     if l=0 then
      call ins03niif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif137
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
    and niif137.codconta=mcodconta
      if l=0 then
       call ins05niif141()
      end if
      if mniif141.nat="D" then 
       update niif137 set deb_5=deb_5+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      else
       update niif137 set cre_5=cre_5+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      end if
      update niif137 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif138
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
      if l=0 then
       call ins07niif141()
      end if
      if mniif141.nat="D" then 
       update niif138 set deb_5=deb_5+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      else
       update niif138 set cre_5=cre_5+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      end if
      update niif138 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif140
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  if l=0 then
   call ins49niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif140 set deb_5=deb_5+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif140 set cre_5=cre_5+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif140 set ultmov=mniif141.fecha
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif139
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      if l=0 then
       call ins22niif141()
      end if
      if mniif141.nat="D" then 
       update niif139 set deb_5=deb_5+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      else
       update niif139 set cre_5=cre_5+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      end if
      update niif139 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
    and niif139.codconta=mcodconta
     end if
     if tpcon_ni2331.detalla="C" or tpcon_ni2331.detalla="P" then
      if mcodconta="05" then
       call actefectoniif141()
      else
       call n_actefectoniif141()
      end if
     end if
    else
     LET mensa=" ERROR LA CUENTA DEL COMPR NO EXISTE EN ",mniif141.codcop,"-",mniif141.documento,"  ",mniif141.auxiliar," ",mniif141.sec using "&&&&"," "
     CALL FGL_WINMESSAGE( "Administrador", mensa, "stop")
    end if
END FUNCTION  }

{FUNCTION mes07niif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif136
      where ano=mano and auxiliar=mniif141.auxiliar 
    and niif136.codconta=mcodconta
     if l=0 then
      call ins03niif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set deb_7=deb_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set deb_7=deb_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set deb_7=deb_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set deb_7=deb_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set deb_7=deb_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set deb_7=deb_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set deb_7=deb_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set cre_7=cre_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set cre_7=cre_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set cre_7=cre_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set cre_7=cre_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set cre_7=cre_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set cre_7=cre_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set cre_7=cre_7+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif137
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
    and niif137.codconta=mcodconta
      if l=0 then
       call ins05niif141()
      end if
      if mniif141.nat="D" then 
       update niif137 set deb_7=deb_7+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      else
       update niif137 set cre_7=cre_7+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      end if
      update niif137 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif138
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
      if l=0 then
       call ins07niif141()
      end if
      if mniif141.nat="D" then 
       update niif138 set deb_7=deb_7+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      else
       update niif138 set cre_7=cre_7+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      end if
      update niif138 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif140
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  if l=0 then
   call ins49niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif140 set deb_7=deb_7+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif140 set cre_7=cre_7+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif140 set ultmov=mniif141.fecha
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif139
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      if l=0 then
       call ins22niif141()
      end if
      if mniif141.nat="D" then 
       update niif139 set deb_7=deb_7+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      else
       update niif139 set cre_7=cre_7+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      end if
      update niif139 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
    and niif139.codconta=mcodconta
     end if
     if tpcon_ni2331.detalla="C" or tpcon_ni2331.detalla="P" then
      if mcodconta="05" then
       call actefectoniif141()
      else
       call n_actefectoniif141()
      end if
     end if
    else
     LET mensa=" ERROR LA CUENTA DEL COMPR NO EXISTE EN ",mniif141.codcop,"-",mniif141.documento,"  ",mniif141.auxiliar," ",mniif141.sec using "&&&&"," "
     CALL FGL_WINMESSAGE( "Administrador", mensa, "stop")
    end if
END FUNCTION  }
{FUNCTION mes08niif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif136
      where ano=mano and auxiliar=mniif141.auxiliar 
    and niif136.codconta=mcodconta
     if l=0 then
      call ins03niif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif137
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
    and niif137.codconta=mcodconta
      if l=0 then
       call ins05niif141()
      end if
      if mniif141.nat="D" then 
       update niif137 set deb_8=deb_8+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      else
       update niif137 set cre_8=cre_8+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      end if
      update niif137 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif138
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
      if l=0 then
       call ins07niif141()
      end if
      if mniif141.nat="D" then 
       update niif138 set deb_8=deb_8+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      else
       update niif138 set cre_8=cre_8+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      end if
      update niif138 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif140
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  if l=0 then
   call ins49niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif140 set deb_8=deb_8+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif140 set cre_8=cre_8+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif140 set ultmov=mniif141.fecha
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif139
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      if l=0 then
       call ins22niif141()
      end if
      if mniif141.nat="D" then 
       update niif139 set deb_8=deb_8+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      else
       update niif139 set cre_8=cre_8+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      end if
      update niif139 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
    and niif139.codconta=mcodconta
     end if
     if tpcon_ni2331.detalla="C" or tpcon_ni2331.detalla="P" then
      if mcodconta="05" then
       call actefectoniif141()
      else
       call n_actefectoniif141()
      end if
     end if
    ELSE
     LET mensa=" ERROR LA CUENTA DEL COMPR NO EXISTE EN ",mniif141.codcop,"-",mniif141.documento,"  ",mniif141.auxiliar," ",mniif141.sec using "&&&&"," "
     CALL FGL_WINMESSAGE( "Administrador", mensa, "stop")
    end if
END FUNCTION  }
{FUNCTION mes09niif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif136
      where ano=mano and auxiliar=mniif141.auxiliar 
    and niif136.codconta=mcodconta
     if l=0 then
      call ins03niif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif137
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
    and niif137.codconta=mcodconta
      if l=0 then
       call ins05niif141()
      end if
      if mniif141.nat="D" then 
       update niif137 set deb_9=deb_9+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      else
       update niif137 set cre_9=cre_9+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      end if
      update niif137 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif138
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
      if l=0 then
       call ins07niif141()
      end if
      if mniif141.nat="D" then 
       update niif138 set deb_9=deb_9+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      else
       update niif138 set cre_9=cre_9+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      end if
      update niif138 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif140
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  if l=0 then
   call ins49niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif140 set deb_9=deb_9+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif140 set cre_9=cre_9+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif140 set ultmov=mniif141.fecha
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif139
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      if l=0 then
       call ins22niif141()
      end if
      if mniif141.nat="D" then 
       update niif139 set deb_9=deb_9+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      else
       update niif139 set cre_9=cre_9+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      end if
      update niif139 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
    and niif139.codconta=mcodconta
     end if
     if tpcon_ni2331.detalla="C" or tpcon_ni2331.detalla="P" then
      if mcodconta="05" then
       call actefectoniif141()
      else
       call n_actefectoniif141()
      end if
     end if
    else
     LET mensa=" ERROR LA CUENTA DEL COMPR NO EXISTE EN ",mniif141.codcop,"-",mniif141.documento,"  ",mniif141.auxiliar," ",mniif141.sec using "&&&&"," "
     CALL FGL_WINMESSAGE( "Administrador", mensa, "stop")
    end if
END FUNCTION  }
{FUNCTION mes10niif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif136
      where ano=mano and auxiliar=mniif141.auxiliar 
    and niif136.codconta=mcodconta
     if l=0 then
      call ins03niif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif137
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
    and niif137.codconta=mcodconta
      if l=0 then
       call ins05niif141()
      end if
      if mniif141.nat="D" then 
       update niif137 set deb_10=deb_10+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      else
       update niif137 set cre_10=cre_10+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      end if
      update niif137 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif138
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
      if l=0 then
       call ins07niif141()
      end if
      if mniif141.nat="D" then 
       update niif138 set deb_10=deb_10+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      else
       update niif138 set cre_10=cre_10+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      end if
      update niif138 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif140
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  if l=0 then
   call ins49niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif140 set deb_10=deb_10+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif140 set cre_10=cre_10+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif140 set ultmov=mniif141.fecha
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif139
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      if l=0 then
       call ins22niif141()
      end if
      if mniif141.nat="D" then 
       update niif139 set deb_10=deb_10+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      else
       update niif139 set cre_10=cre_10+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      end if
      update niif139 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
    and niif139.codconta=mcodconta
     end if
     if tpcon_ni2331.detalla="C" or tpcon_ni2331.detalla="P" then
      if mcodconta="05" then
       call actefectoniif141()
      else
       call n_actefectoniif141()
      end if
     end if
    ELSE
      LET mensa=" ERROR LA CUENTA DEL COMPR NO EXISTE EN ",mniif141.codcop,"-",mniif141.documento,"  ",mniif141.auxiliar," ",mniif141.sec using "&&&&"," "
      CALL FGL_WINMESSAGE( "Administrador", mensa, "stop")
    end if
END FUNCTION  }
{FUNCTION mes11niif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif136
      where ano=mano and auxiliar=mniif141.auxiliar 
    and niif136.codconta=mcodconta
     if l=0 then
      call ins03niif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif137
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
    and niif137.codconta=mcodconta
      if l=0 then
       call ins05niif141()
      end if
      if mniif141.nat="D" then 
       update niif137 set deb_11=deb_11+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      else
       update niif137 set cre_11=cre_11+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      end if
      update niif137 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif138
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
      if l=0 then
       call ins07niif141()
      end if
      if mniif141.nat="D" then 
       update niif138 set deb_11=deb_11+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      else
       update niif138 set cre_11=cre_11+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      end if
      update niif138 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif140
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  if l=0 then
   call ins49niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif140 set deb_11=deb_11+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif140 set cre_11=cre_11+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif140 set ultmov=mniif141.fecha
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif139
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      if l=0 then
       call ins22niif141()
      end if
      if mniif141.nat="D" then 
       update niif139 set deb_11=deb_11+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      else
       update niif139 set cre_11=cre_11+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      end if
      update niif139 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
    and niif139.codconta=mcodconta
     end if
     if tpcon_ni2331.detalla="C" or tpcon_ni2331.detalla="P" then
      if mcodconta="05" then
       call actefectoniif141()
      else
       call n_actefectoniif141()
      end if
     end if
    else
     LET mensa=" ERROR LA CUENTA DEL COMPR NO EXISTE EN ",mniif141.codcop,"-",mniif141.documento,"  ",mniif141.auxiliar," ",mniif141.sec using "&&&&"," "
     CALL FGL_WINMESSAGE( "Administrador", mensa, "stop")
    end if
END FUNCTION  }
{FUNCTION mes12niif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif136
      where ano=mano and auxiliar=mniif141.auxiliar 
    and niif136.codconta=mcodconta
     if l=0 then
      call ins03niif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif136 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif137
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
    and niif137.codconta=mcodconta
      if l=0 then
       call ins05niif141()
      end if
      if mniif141.nat="D" then 
       update niif137 set deb_12=deb_12+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      else
       update niif137 set cre_12=cre_12+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
      end if
      update niif137 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
    and niif137.codconta=mcodconta
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif138
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
      if l=0 then
       call ins07niif141()
      end if
      if mniif141.nat="D" then 
       update niif138 set deb_12=deb_12+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      else
       update niif138 set cre_12=cre_12+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      end if
      update niif138 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif140
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  if l=0 then
   call ins49niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif140 set deb_12=deb_12+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif140 set cre_12=cre_12+mniif141.valor
    where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
      and niif140.codcen=mniif141.codcen
      and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif140 set ultmov=mniif141.fecha
   where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
     and niif140.codcen=mniif141.codcen 
     and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif139
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      if l=0 then
       call ins22niif141()
      end if
      if mniif141.nat="D" then 
       update niif139 set deb_12=deb_12+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      else
       update niif139 set cre_12=cre_12+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
    and niif139.codconta=mcodconta
      end if
      update niif139 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
    and niif139.codconta=mcodconta
     end if
     if tpcon_ni2331.detalla="C" or tpcon_ni2331.detalla="P" then
      if mcodconta="05" then
       call actefectoniif141()
      else
       call n_actefectoniif141()
      end if
     end if
    else
     LET mensa=" ERROR LA CUENTA DEL COMPR NO EXISTE EN ",mniif141.codcop,"-",mniif141.documento,"  ",mniif141.auxiliar," ",mniif141.sec using "&&&&"," "
     CALL FGL_WINMESSAGE( "Administrador", mensa, "stop")
    end if
END FUNCTION  }
{FUNCTION mes13niif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif136
      where ano=mano and auxiliar=mniif141.auxiliar 
    and niif136.codconta=mcodconta
     if l=0 then
      call ins03niif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
     end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif136 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif136 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif136 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif136 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif136 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif136 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif136 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
    and niif136.codconta=mcodconta
       end if
     end case
 if tpcon_ni2331.tercero="S" then
  let l=0 
  select count(*) into l from niif137
   where niif137.ano=mano and niif137.auxiliar=mniif141.auxiliar
     and niif137.nit=mniif141.nit
    and niif137.codconta=mcodconta
  if l=0 then
   call ins05niif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif137 set deb_13=deb_13+mniif141.valor
    where niif137.ano=mano and niif137.auxiliar=mniif141.auxiliar
      and niif137.nit=mniif141.nit 
    and niif137.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif137 set cre_13=cre_13+mniif141.valor
    where niif137.ano=mano and niif137.auxiliar=mniif141.auxiliar
      and niif137.nit=mniif141.nit 
    and niif137.codconta=mcodconta
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif137 set ultmov=mniif141.fecha
   where niif137.ano=mano and niif137.auxiliar=mniif141.auxiliar
     and niif137.nit=mniif141.nit 
    and niif137.codconta=mcodconta
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif138
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
      if l=0 then
       call ins07niif141()
      end if
      if mniif141.nat="D" then 
       update niif138 set deb_13=deb_13+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      else
       update niif138 set cre_13=cre_13+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
    and niif138.codconta=mcodconta
      end if
      update niif138 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
    and niif138.codconta=mcodconta
 end if
######
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
        let l=0 
        select count(*) into l from niif140
        where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
          and niif140.codcen=mniif141.codcen 
          and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
        if l=0 then
          call ins49niif141()
          IF gerrflag then
            return
         end if
        end if
        if mniif141.nat="D" then 
           update niif140 set deb_13=deb_13+mniif141.valor
            where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
            and niif140.codcen=mniif141.codcen
            and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
           IF status < 0 THEN
               LET gerrflag = TRUE
           END IF
        else
           update niif140 set cre_13=cre_13+mniif141.valor
            where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
              and niif140.codcen=mniif141.codcen
              and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
           IF status < 0 THEN
            LET gerrflag = TRUE
           END IF
        end if
        update niif140 set ultmov=mniif141.fecha
        where niif140.ano=mano and niif140.auxiliar=mniif141.auxiliar
         and niif140.codcen=mniif141.codcen 
         and niif140.nit=mniif141.nit 
    and niif140.codconta=mcodconta
        IF status < 0 THEN
          LET gerrflag = TRUE
        END IF
      end if
 end if
END FUNCTION  }
{FUNCTION ins03niif141()
 INSERT INTO niif136
  ( codconta, ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
  VALUES ( mcodconta, mano, mniif141.auxiliar , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, tpcon_ni2331.cta, tpcon_ni2331.subcta,
    tpcon_ni2331.auxuno, tpcon_ni2331.auxdos, tpcon_ni2331.auxtre )
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,"00000000000"
 LET l=0
 select count(*) into l from niif136 where ano=mano and auxiliar=mauxini
  and niif136.codconta=mcodconta
 if l=0 then
  INSERT INTO niif136
  ( codconta, ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mcodconta, mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, "0", "00", "00", "00", "00", "00" )
 end if
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,"0000000000"
 LET l=0
 select count(*) into l from niif136 where ano=mano and auxiliar=mauxini
  and niif136.codconta=mcodconta
 if l=0 then
  INSERT INTO niif136
  ( codconta, ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mcodconta, mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, "00", "00", "00", "00", "00" )
 end if
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
             tpcon_ni2331.cta clipped,"00000000"
 LET l=0
 select count(*) into l from niif136 where ano=mano and auxiliar=mauxini
  and niif136.codconta=mcodconta
 if l=0 then
  INSERT INTO niif136
  ( codconta, ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mcodconta, mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, tpcon_ni2331.cta, "00", "00", "00", "00" )
 end if
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
             tpcon_ni2331.cta clipped,tpcon_ni2331.subcta clipped,"000000"
 LET l=0
 select count(*) into l from niif136 where ano=mano and auxiliar=mauxini
  and niif136.codconta=mcodconta
 if l=0 then
  INSERT INTO niif136
  ( codconta, ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mcodconta, mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, tpcon_ni2331.cta, tpcon_ni2331.subcta,
    "00", "00", "00" )
 end if
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
             tpcon_ni2331.cta clipped,tpcon_ni2331.subcta clipped,
             tpcon_ni2331.auxuno clipped,"0000"
 LET l=0
 select count(*) into l from niif136 where ano=mano and auxiliar=mauxini
  and niif136.codconta=mcodconta
 if l=0 then
  INSERT INTO niif136
  ( codconta, ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mcodconta, mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, tpcon_ni2331.cta, tpcon_ni2331.subcta,
    tpcon_ni2331.auxuno, "00", "00" )
 end if
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
             tpcon_ni2331.cta clipped,tpcon_ni2331.subcta clipped,
             tpcon_ni2331.auxuno clipped,tpcon_ni2331.auxdos clipped,"00"
 LET l=0
 select count(*) into l from niif136 where ano=mano and auxiliar=mauxini
  and niif136.codconta=mcodconta
 if l=0 then
  INSERT INTO niif136
  ( codconta, ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mcodconta, mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, tpcon_ni2331.cta, tpcon_ni2331.subcta,
    tpcon_ni2331.auxuno, tpcon_ni2331.auxdos, "00" )
 end if
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
             tpcon_ni2331.cta clipped,tpcon_ni2331.subcta clipped,
             tpcon_ni2331.auxuno clipped,tpcon_ni2331.auxdos clipped,
             tpcon_ni2331.auxtre clipped
 LET l=0
 select count(*) into l from niif136 where ano=mano and auxiliar=mauxini
  and niif136.codconta=mcodconta
 if l=0 then
  INSERT INTO niif136
  ( codconta, ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mcodconta, mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, tpcon_ni2331.cta, tpcon_ni2331.subcta,
    tpcon_ni2331.auxuno, tpcon_ni2331.auxdos, tpcon_ni2331.auxtre )
 end if
END FUNCTION } 
{FUNCTION ins05niif141()
 INSERT INTO niif137
 ( codconta, ano, auxiliar, nit, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
  cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
  cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12, cre_13,
  deb_13,  ultmov )
 VALUES ( mcodconta, mano, mniif141.auxiliar, mniif141.nit, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha )
END FUNCTION } 
{FUNCTION ins07niif141()
 INSERT INTO niif138
 ( codconta, ano, auxiliar, codcen, salant, cre_1, deb_1, cre_2, deb_2,
   cre_3, deb_3, cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7,
   cre_8, deb_8, cre_9, deb_9, cre_10, deb_10, cre_11, deb_11,
   cre_12, deb_12, cre_13, deb_13 , ultmov )
 VALUES ( mcodconta, mano, mniif141.auxiliar, mniif141.codcen, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
  mniif141.fecha )
END FUNCTION  }
{FUNCTION ins49niif141()
 INSERT INTO niif140
 ( codconta, ano, auxiliar, codcen, nit,  salant, cre_1, deb_1, cre_2, deb_2,
   cre_3, deb_3, cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7,
   cre_8, deb_8, cre_9, deb_9, cre_10, deb_10, cre_11, deb_11,
   cre_12, deb_12, cre_13, deb_13 , ultmov )
 VALUES ( mcodconta, mano, mniif141.auxiliar, mniif141.codcen, mniif141.nit, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, mniif141.fecha )
END FUNCTION } 
{FUNCTION ins22niif141()
 INSERT INTO niif139
 ( codconta, ano, auxiliar, codbod, salant, cre_1, deb_1, cre_2, deb_2, cre_3,
  deb_3, cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8,
  deb_8, cre_9, deb_9, cre_10, deb_10, cre_11, deb_11,
  cre_12, deb_12, ultmov )
 VALUES ( mcodconta, mano, mniif141.auxiliar, mniif141.codbod, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  mniif141.fecha )
END FUNCTION}
{FUNCTION actefectoniif141()  
DEFINE x decimal(15,2)
 INITIALIZE mniif142.* TO NULL
 select * into mniif142.* from niif142
  where niif142.codcop=mniif141.codcop
    and niif142.documento=mniif141.documento
    and niif142.sec=mniif141.sec
           and niif142.codconta=mcodconta
 let l=0 
 select count(*) into l from niif145
  where niif145.tipcru=mniif142.tipcru and
        niif145.nocts=mniif142.nocts and
        niif145.doccru=mniif142.doccru and
        niif145.nit=mniif141.nit and
        niif145.auxiliar=mniif141.auxiliar
           and niif145.codconta=mcodconta
           and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
 if l=0 then
  if tpcon_ni2331.detalla="C" then
   if mniif141.nat="C" then
    let x=(0-mniif141.valor)
    INSERT INTO niif145
     ( codconta, codcop, documento, fecha, auxiliar, codcen, nit, tipcru, nocts, 
       doccru, fecven, detalla, valor , abonos, saldo, estado )
    VALUES ( mcodconta, mniif141.codcop, mniif141.documento, mniif141.fecha,
            mniif141.auxiliar, mniif141.codcen, mniif141.nit, mniif142.tipcru,
            mniif142.nocts, mniif142.doccru, mniif142.fecven,
            tpcon_ni2331.detalla, 0, mniif141.valor, x, "A" )
    update conta254n set valpag=valpag+mniif141.valor
     where conta254n.nocts=mniif142.nocts
       and conta254n.documento=mniif142.doccru
       and conta254n.codconta=mcodconta
    ### ACTUALIZA CUOTA EN FONEDE ###
    update desempleo10 set estado="S"
     where desempleo10.cuota=mniif142.nocts
       and desempleo10.documento=mniif142.doccru
   else
    INSERT INTO niif145
     ( codconta, codcop, documento, fecha, auxiliar, codcen, nit, tipcru, nocts,
       doccru, fecven, detalla, valor , abonos, saldo, estado )
    VALUES ( mcodconta, mniif141.codcop, mniif141.documento, mniif141.fecha,
            mniif141.auxiliar, mniif141.codcen, mniif141.nit, mniif142.tipcru,
            mniif142.nocts, mniif142.doccru, mniif142.fecven,
            tpcon_ni2331.detalla, mniif141.valor, 0, mniif141.valor, "A" )
   end if
  else
   if mniif141.nat="C" then
    INSERT INTO niif145
     ( codconta, codcop, documento, fecha, auxiliar, codcen, nit, tipcru, nocts, doccru, fecven,
       detalla, valor , abonos, saldo, estado )
    VALUES ( mcodconta, mniif141.codcop, mniif141.documento, mniif141.fecha,
            mniif141.auxiliar, mniif141.codcen, mniif141.nit, mniif142.tipcru,
            mniif142.nocts, mniif142.doccru, mniif142.fecven,
            tpcon_ni2331.detalla, mniif141.valor, 0, mniif141.valor, "A" )
   else
    let x=(0-mniif141.valor)
    INSERT INTO niif145
     ( codconta, codcop, documento, fecha, auxiliar, codcen, nit, tipcru, nocts, doccru, fecven,
       detalla, valor , abonos, saldo, estado )
    VALUES ( mcodconta, mniif141.codcop, mniif141.documento, mniif141.fecha,
            mniif141.auxiliar, mniif141.codcen, mniif141.nit, mniif142.tipcru,
            mniif142.nocts, mniif142.doccru, mniif142.fecven,
            tpcon_ni2331.detalla, 0, mniif141.valor, x, "A" )
   end if
  end if
 else
  let l=l+1
  if tpcon_ni2331.detalla="C" then
   if mniif141.nat="C" then
    update niif145 set abonos=abonos+mniif141.valor
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar 
      and niif145.codconta=mcodconta
      and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
    update niif145 set saldo=valor-abonos
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
       and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar 
      and niif145.codconta=mcodconta
      and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
    update conta254n set valpag=
           (valpag+mniif141.valor)
     where conta254n.nocts=mniif142.nocts
       and conta254n.documento=mniif142.doccru
       and conta254n.codconta=mcodconta
    ### ACTUALIZA CUOTA EN FONEDE ###
    update desempleo10 set estado="S"
     where desempleo10.cuota=mniif142.nocts
       and desempleo10.documento=mniif142.doccru
   else
    update niif145 set valor=valor+mniif141.valor
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar
      and niif145.codconta=mcodconta
      and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
    update niif145 set saldo=valor-abonos
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar
      and niif145.codconta=mcodconta
      and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
   end if
  else
   if mniif141.nat="C" then
    update niif145 set valor=valor+mniif141.valor
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar
      and niif145.codconta=mcodconta
      and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
    update niif145 set saldo=valor-abonos
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar
      and niif145.codconta=mcodconta
      and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
   else
    update niif145 set abonos=abonos+mniif141.valor
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar
      and niif145.codconta=mcodconta
      and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
    update niif145 set saldo=valor-abonos
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar
      and niif145.codconta=mcodconta
      and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
   end if
  end if
 end if
END FUNCTION}
{FUNCTION n_actefectoniif141()  
DEFINE x decimal(15,2)
 INITIALIZE mniif142.* TO NULL
 select * into mniif142.* from niif142
  where niif142.codcop=mniif141.codcop
    and niif142.documento=mniif141.documento
    and niif142.sec=mniif141.sec
           and niif142.codconta=mcodconta
 let l=0 
 select count(*) into l from niif145
  where niif145.tipcru=mniif142.tipcru and
        niif145.nocts=mniif142.nocts and
        niif145.doccru=mniif142.doccru and
        niif145.nit=mniif141.nit and
        niif145.auxiliar=mniif141.auxiliar
           and niif145.codconta=mcodconta
           --and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
 if l=0 then
  if tpcon_ni2331.detalla="C" then
   if mniif141.nat="C" then
    let x=(0-mniif141.valor)
    INSERT INTO niif145
     ( codconta, codcop, documento, fecha, auxiliar, codcen, nit, tipcru, nocts, 
       doccru, fecven, detalla, valor , abonos, saldo, estado )
    VALUES ( mcodconta, mniif141.codcop, mniif141.documento, mniif141.fecha,
            mniif141.auxiliar, mniif141.codcen, mniif141.nit, mniif142.tipcru,
            mniif142.nocts, mniif142.doccru, mniif142.fecven,
            tpcon_ni2331.detalla, 0, mniif141.valor, x, "A" )
    update conta254n set valpag=valpag+mniif141.valor
     where conta254n.nocts=mniif142.nocts
       and conta254n.documento=mniif142.doccru
       and conta254n.codconta=mcodconta
    ### ACTUALIZA CUOTA EN FONEDE ###
    update desempleo10 set estado="S"
     where desempleo10.cuota=mniif142.nocts
       and desempleo10.documento=mniif142.doccru
   else
    INSERT INTO niif145
     ( codconta, codcop, documento, fecha, auxiliar, codcen, nit, tipcru, nocts,
       doccru, fecven, detalla, valor , abonos, saldo, estado )
    VALUES ( mcodconta, mniif141.codcop, mniif141.documento, mniif141.fecha,
            mniif141.auxiliar, mniif141.codcen, mniif141.nit, mniif142.tipcru,
            mniif142.nocts, mniif142.doccru, mniif142.fecven,
            tpcon_ni2331.detalla, mniif141.valor, 0, mniif141.valor, "A" )
   end if
  else
   if mniif141.nat="C" then
    INSERT INTO niif145
     ( codconta, codcop, documento, fecha, auxiliar, codcen, nit, tipcru, nocts, doccru, fecven,
       detalla, valor , abonos, saldo, estado )
    VALUES ( mcodconta, mniif141.codcop, mniif141.documento, mniif141.fecha,
            mniif141.auxiliar, mniif141.codcen, mniif141.nit, mniif142.tipcru,
            mniif142.nocts, mniif142.doccru, mniif142.fecven,
            tpcon_ni2331.detalla, mniif141.valor, 0, mniif141.valor, "A" )
   else
    let x=(0-mniif141.valor)
    INSERT INTO niif145
     ( codconta, codcop, documento, fecha, auxiliar, codcen, nit, tipcru, nocts, doccru, fecven,
       detalla, valor , abonos, saldo, estado )
    VALUES ( mcodconta, mniif141.codcop, mniif141.documento, mniif141.fecha,
            mniif141.auxiliar, mniif141.codcen, mniif141.nit, mniif142.tipcru,
            mniif142.nocts, mniif142.doccru, mniif142.fecven,
            tpcon_ni2331.detalla, 0, mniif141.valor, x, "A" )
   end if
  end if
 else
  let l=l+1
  if tpcon_ni2331.detalla="C" then
   if mniif141.nat="C" then
    update niif145 set abonos=abonos+mniif141.valor
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar 
      and niif145.codconta=mcodconta
      --and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
    update niif145 set saldo=valor-abonos
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
       and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar 
      and niif145.codconta=mcodconta
      --and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
    update conta254n set valpag=
           (valpag+mniif141.valor)
     where conta254n.nocts=mniif142.nocts
       and conta254n.documento=mniif142.doccru
       and conta254n.codconta=mcodconta
    ### ACTUALIZA CUOTA EN FONEDE ###
    update desempleo10 set estado="S"
     where desempleo10.cuota=mniif142.nocts
       and desempleo10.documento=mniif142.doccru
   else
    update niif145 set valor=valor+mniif141.valor
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar
      and niif145.codconta=mcodconta
      --and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
    update niif145 set saldo=valor-abonos
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar
      and niif145.codconta=mcodconta
      --and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
   end if
  else
   if mniif141.nat="C" then
    update niif145 set valor=valor+mniif141.valor
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar
      and niif145.codconta=mcodconta
      --and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
    update niif145 set saldo=valor-abonos
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar
      and niif145.codconta=mcodconta
      --and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
   else
    update niif145 set abonos=abonos+mniif141.valor
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar
      and niif145.codconta=mcodconta
      --and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
    update niif145 set saldo=valor-abonos
     where niif145.tipcru=mniif142.tipcru and niif145.nocts=mniif142.nocts 
      and niif145.doccru=mniif142.doccru
      and niif145.nit=mniif141.nit and niif145.auxiliar=mniif141.auxiliar
      and niif145.codconta=mcodconta
      --and niif145.fecven=mniif142.fecven ## 05/14/2013 Cambio Solicitado Por la Jefe de Sistemas de acuerdo al nuevo modelo del programa de credito
   end if
  end if
 end if
END FUNCTION}
## ojo
{FUNCTION mes01genniif141()
initialize tpcon_ni2331.* to null
select * into tpcon_ni2331.* from niif233
 where niif233.auxiliar=mniif141.auxiliar
if tpcon_ni2331.auxiliar is not null then
 let l=0 
 select count(*) into l from niif182
  where niif182.ano=mano and niif182.auxiliar=mniif141.auxiliar 
 if l=0 then
  call ins03genniif141()
  IF gerrflag then
   return
  end if
 end if
 case
  when mniif141.nat="D" 
   let mnivel=1
   call nivauxniif1()
   if mniif233.clase<>"0" then
    update niif182 set deb_1=deb_1+mniif141.valor
    where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=2
   call nivauxniif1()
   if mniif233.grupo<>"0" then
    update niif182 set deb_1=deb_1+mniif141.valor
     where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=3
   call nivauxniif1()
   if mniif233.cta<>"00" then
    update niif182 set deb_1=deb_1+mniif141.valor
     where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=4
   call nivauxniif1()
   if mniif233.subcta<>"00" then
    update niif182 set deb_1=deb_1+mniif141.valor
     where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=5
   call nivauxniif1()
   if mniif233.auxuno<>"00" then
    update niif182 set deb_1=deb_1+mniif141.valor
     where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=6
   call nivauxniif1()
   if mniif233.auxdos<>"00" then
    update niif182 set deb_1=deb_1+mniif141.valor
     where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=7
   call nivauxniif1()
   if mniif233.auxtre<>"00" then
    update niif182 set deb_1=deb_1+mniif141.valor
     where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
  when mniif141.nat="C" 
   let mnivel=1
   call nivauxniif1()
   if mniif233.clase<>"0" then
    update niif182 set cre_1=cre_1+mniif141.valor
     where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=2
   call nivauxniif1()
   if mniif233.grupo<>"0" then
    update niif182 set cre_1=cre_1+mniif141.valor
     where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=3
   call nivauxniif1()
   if mniif233.cta<>"00" then
    update niif182 set cre_1=cre_1+mniif141.valor
     where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=4
   call nivauxniif1()
   if mniif233.subcta<>"00" then
    update niif182 set cre_1=cre_1+mniif141.valor
     where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=5
   call nivauxniif1()
   if mniif233.auxuno<>"00" then
    update niif182 set cre_1=cre_1+mniif141.valor
     where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=6
   call nivauxniif1()
   if mniif233.auxdos<>"00" then
    update niif182 set cre_1=cre_1+mniif141.valor
     where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
   let mnivel=7
   call nivauxniif1()
   if mniif233.auxtre<>"00" then
    update niif182 set cre_1=cre_1+mniif141.valor
     where niif182.ano=mano and niif182.auxiliar=mauxiliar
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   end if
 end case
 let mnivel=1
 call nivauxniif1()
 if mniif233.clase<>"0" then
  update niif182 set ultmov=mniif141.fecha
   where niif182.ano=mano and niif182.auxiliar=mauxiliar
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 let mnivel=2
 call nivauxniif1()
 if mniif233.grupo<>"0" then
  update niif182 set ultmov=mniif141.fecha
   where niif182.ano=mano and niif182.auxiliar=mauxiliar
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 let mnivel=3
 call nivauxniif1()
 if mniif233.cta<>"00" then
  update niif182 set ultmov=mniif141.fecha
   where niif182.ano=mano and niif182.auxiliar=mauxiliar
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 let mnivel=4
 call nivauxniif1()
 if mniif233.subcta<>"00" then
  update niif182 set ultmov=mniif141.fecha
   where niif182.ano=mano and niif182.auxiliar=mauxiliar
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 let mnivel=5
 call nivauxniif1()
 if mniif233.auxuno<>"00" then
  update niif182 set ultmov=mniif141.fecha
   where niif182.ano=mano and niif182.auxiliar=mauxiliar
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 let mnivel=6
 call nivauxniif1()
 if mniif233.auxdos<>"00" then
  update niif182 set ultmov=mniif141.fecha
   where niif182.ano=mano and niif182.auxiliar=mauxiliar
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 let mnivel=7
 call nivauxniif1()
 if mniif233.auxtre<>"00" then
  update niif182 set ultmov=mniif141.fecha
   where niif182.ano=mano and niif182.auxiliar=mauxiliar
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 if tpcon_ni2331.tercero="S" then
  let l=0 
  select count(*) into l from niif183
   where niif183.ano=mano and niif183.auxiliar=mniif141.auxiliar
     and niif183.nit=mniif141.nit
  if l=0 then
   call ins05genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif183 set deb_1=deb_1+mniif141.valor
    where niif183.ano=mano and niif183.auxiliar=mniif141.auxiliar
      and niif183.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif183 set cre_1=cre_1+mniif141.valor
    where niif183.ano=mano and niif183.auxiliar=mniif141.auxiliar
      and niif183.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif183 set ultmov=mniif141.fecha
   where niif183.ano=mano and niif183.auxiliar=mniif141.auxiliar
     and niif183.nit=mniif141.nit 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 if tpcon_ni2331.centros="S" then
  let l=0 
  select count(*) into l from niif184
   where niif184.ano=mano and niif184.auxiliar=mniif141.auxiliar
     and niif184.codcen=mniif141.codcen 
  if l=0 then
   call ins07genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif184 set deb_1=deb_1+mniif141.valor
    where niif184.ano=mano and niif184.auxiliar=mniif141.auxiliar
      and niif184.codcen=mniif141.codcen
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif184 set cre_1=cre_1+mniif141.valor
    where niif184.ano=mano and niif184.auxiliar=mniif141.auxiliar
      and niif184.codcen=mniif141.codcen
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif184 set ultmov=mniif141.fecha
   where niif184.ano=mano and niif184.auxiliar=mniif141.auxiliar
     and niif184.codcen=mniif141.codcen 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif186
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  if l=0 then
   call ins49genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif186 set deb_1=deb_1+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif186 set cre_1=cre_1+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif186 set ultmov=mniif141.fecha
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
 if tpcon_ni2331.detalla="I" then
  let l=0 
  select count(*) into l from niif185
   where niif185.ano=mano and niif185.auxiliar=mniif141.auxiliar
     and niif185.codbod=mniif141.codbod
  if l=0 then
   call ins22genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif185 set deb_1=deb_1+mniif141.valor
    where niif185.ano=mano and niif185.auxiliar=mniif141.auxiliar and niif185.codbod=mniif141.codbod
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif185 set cre_1=cre_1+mniif141.valor
    where niif185.ano=mano and niif185.auxiliar=mniif141.auxiliar and niif185.codbod=mniif141.codbod
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif185 set ultmov=mniif141.fecha
   where niif185.ano=mano and niif185.auxiliar=mniif141.auxiliar and niif185.codbod=mniif141.codbod 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
else
 CALL FGL_WINMESSAGE( "Administrador", "ERROR LA CUENTA DEL COMPROBANTE NO EXISTE", "stop")
end if
END FUNCTION } 
{FUNCTION mes02genniif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif182
      where ano=mano and auxiliar=mniif141.auxiliar 
     if l=0 then
      call ins03genniif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set deb_2=deb_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set cre_2=cre_2+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif183
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
      if l=0 then
       call ins05genniif141()
      end if
      if mniif141.nat="D" then 
       update niif183 set deb_2=deb_2+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      else
       update niif183 set cre_2=cre_2+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      end if
      update niif183 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif184
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
      if l=0 then
       call ins07genniif141()
      end if
      if mniif141.nat="D" then 
       update niif184 set deb_2=deb_2+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      else
       update niif184 set cre_2=cre_2+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      end if
      update niif184 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif186
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  if l=0 then
   call ins49genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif186 set deb_2=deb_2+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif186 set cre_2=cre_2+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif186 set ultmov=mniif141.fecha
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif185
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      if l=0 then
       call ins22genniif141()
      end if
      if mniif141.nat="D" then 
       update niif185 set deb_2=deb_2+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      else
       update niif185 set cre_2=cre_2+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      end if
      update niif185 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
     end if
    else
     CALL FGL_WINMESSAGE( "Administrador", "ERROR LA CUENTA DEL COMPROBANTE NO EXISTE", "stop")
    end if
END FUNCTION  }
{FUNCTION mes03genniif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif182
      where ano=mano and auxiliar=mniif141.auxiliar 
     if l=0 then
      call ins03genniif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set deb_3=deb_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set cre_3=cre_3+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif183
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
      if l=0 then
       call ins05genniif141()
      end if
      if mniif141.nat="D" then 
       update niif183 set deb_3=deb_3+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      else
       update niif183 set cre_3=cre_3+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      end if
      update niif183 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif184
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
      if l=0 then
       call ins07genniif141()
      end if
      if mniif141.nat="D" then 
       update niif184 set deb_3=deb_3+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      else
       update niif184 set cre_3=cre_3+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      end if
      update niif184 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif186
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  if l=0 then
   call ins49genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif186 set deb_3=deb_3+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif186 set cre_3=cre_3+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif186 set ultmov=mniif141.fecha
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif185
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      if l=0 then
       call ins22genniif141()
      end if
      if mniif141.nat="D" then 
       update niif185 set deb_3=deb_3+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      else
       update niif185 set cre_3=cre_3+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      end if
      update niif185 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
     end if
    else
     CALL FGL_WINMESSAGE( "Administrador", "ERROR LA CUENTA DEL COMPROBANTE NO EXISTE", "stop")
    end if
END FUNCTION } 
{FUNCTION mes04genniif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif182
      where ano=mano and auxiliar=mniif141.auxiliar 
     if l=0 then
      call ins03genniif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set deb_4=deb_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set cre_4=cre_4+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif183
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
      if l=0 then
       call ins05genniif141()
      end if
      if mniif141.nat="D" then 
       update niif183 set deb_4=deb_4+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      else
       update niif183 set cre_4=cre_4+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      end if
      update niif183 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif184
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
      if l=0 then
       call ins07genniif141()
      end if
      if mniif141.nat="D" then 
       update niif184 set deb_4=deb_4+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      else
       update niif184 set cre_4=cre_4+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      end if
      update niif184 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif186
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  if l=0 then
   call ins49genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif186 set deb_4=deb_4+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif186 set cre_4=cre_4+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif186 set ultmov=mniif141.fecha
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif185
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      if l=0 then
       call ins22genniif141()
      end if
      if mniif141.nat="D" then 
       update niif185 set deb_4=deb_4+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      else
       update niif185 set cre_4=cre_4+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      end if
      update niif185 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
     end if
    else
     CALL FGL_WINMESSAGE( "Administrador", "ERROR LA CUENTA DEL COMPROBANTE NO EXISTE", "stop")
    end if
END FUNCTION } 
{FUNCTION mes05genniif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif182
      where ano=mano and auxiliar=mniif141.auxiliar 
     if l=0 then
      call ins03genniif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set deb_5=deb_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set cre_5=cre_5+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif183
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
      if l=0 then
       call ins05genniif141()
      end if
      if mniif141.nat="D" then 
       update niif183 set deb_5=deb_5+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      else
       update niif183 set cre_5=cre_5+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      end if
      update niif183 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif184
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
      if l=0 then
       call ins07genniif141()
      end if
      if mniif141.nat="D" then 
       update niif184 set deb_5=deb_5+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      else
       update niif184 set cre_5=cre_5+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      end if
      update niif184 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif186
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  if l=0 then
   call ins49genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif186 set deb_5=deb_5+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif186 set cre_5=cre_5+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif186 set ultmov=mniif141.fecha
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif185
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      if l=0 then
       call ins22genniif141()
      end if
      if mniif141.nat="D" then 
       update niif185 set deb_5=deb_5+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      else
       update niif185 set cre_5=cre_5+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      end if
      update niif185 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
     end if
    else
     CALL FGL_WINMESSAGE( "Administrador", "ERROR LA CUENTA DEL COMPROBANTE NO EXISTE", "stop")
    end if
END FUNCTION } 
{FUNCTION mes06genniif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif182
      where ano=mano and auxiliar=mniif141.auxiliar 
     if l=0 then
      call ins03genniif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set deb_6=deb_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set deb_6=deb_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set deb_6=deb_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set deb_6=deb_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set deb_6=deb_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set deb_6=deb_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set deb_6=deb_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set cre_6=cre_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set cre_6=cre_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set cre_6=cre_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set cre_6=cre_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set cre_6=cre_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set cre_6=cre_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set cre_6=cre_6+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif183
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
      if l=0 then
       call ins05genniif141()
      end if
      if mniif141.nat="D" then 
       update niif183 set deb_6=deb_6+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      else
       update niif183 set cre_6=cre_6+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      end if
      update niif183 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif184
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
      if l=0 then
       call ins07genniif141()
      end if
      if mniif141.nat="D" then 
       update niif184 set deb_6=deb_6+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      else
       update niif184 set cre_6=cre_6+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      end if
      update niif184 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif186
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  if l=0 then
   call ins49genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif186 set deb_6=deb_6+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif186 set cre_6=cre_6+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif186 set ultmov=mniif141.fecha
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif185
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      if l=0 then
       call ins22genniif141()
      end if
      if mniif141.nat="D" then 
       update niif185 set deb_6=deb_6+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      else
       update niif185 set cre_6=cre_6+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      end if
      update niif185 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
     end if
    else
     CALL FGL_WINMESSAGE( "Administrador", "ERROR LA CUENTA DEL COMPROBANTE NO EXISTE", "stop")
    end if
END FUNCTION  }
 
{FUNCTION mes08genniif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif182
      where ano=mano and auxiliar=mniif141.auxiliar 
     if l=0 then
      call ins03genniif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set deb_8=deb_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set cre_8=cre_8+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif183
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
      if l=0 then
       call ins05genniif141()
      end if
      if mniif141.nat="D" then 
       update niif183 set deb_8=deb_8+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      else
       update niif183 set cre_8=cre_8+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      end if
      update niif183 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif184
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
      if l=0 then
       call ins07genniif141()
      end if
      if mniif141.nat="D" then 
       update niif184 set deb_8=deb_8+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      else
       update niif184 set cre_8=cre_8+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      end if
      update niif184 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif186
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  if l=0 then
   call ins49genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif186 set deb_8=deb_8+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif186 set cre_8=cre_8+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif186 set ultmov=mniif141.fecha
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif185
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      if l=0 then
       call ins22genniif141()
      end if
      if mniif141.nat="D" then 
       update niif185 set deb_8=deb_8+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      else
       update niif185 set cre_8=cre_8+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      end if
      update niif185 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
     end if
    else
     CALL FGL_WINMESSAGE( "Administrador", "ERROR LA CUENTA DEL COMPROBANTE NO EXISTE", "stop")
    end if
END FUNCTION  }
{FUNCTION mes09genniif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif182
      where ano=mano and auxiliar=mniif141.auxiliar 
     if l=0 then
      call ins03genniif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set deb_9=deb_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set cre_9=cre_9+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif183
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
      if l=0 then
       call ins05genniif141()
      end if
      if mniif141.nat="D" then 
       update niif183 set deb_9=deb_9+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      else
       update niif183 set cre_9=cre_9+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      end if
      update niif183 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif184
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
      if l=0 then
       call ins07genniif141()
      end if
      if mniif141.nat="D" then 
       update niif184 set deb_9=deb_9+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      else
       update niif184 set cre_9=cre_9+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      end if
      update niif184 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif186
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  if l=0 then
   call ins49genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif186 set deb_9=deb_9+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif186 set cre_9=cre_9+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif186 set ultmov=mniif141.fecha
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif185
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      if l=0 then
       call ins22genniif141()
      end if
      if mniif141.nat="D" then 
       update niif185 set deb_9=deb_9+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      else
       update niif185 set cre_9=cre_9+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      end if
      update niif185 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
     end if
    else
     CALL FGL_WINMESSAGE( "Administrador", "ERROR LA CUENTA DEL COMPROBANTE NO EXISTE", "stop")
    end if
END FUNCTION  }
{FUNCTION mes10genniif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif182
      where ano=mano and auxiliar=mniif141.auxiliar 
     if l=0 then
      call ins03genniif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set deb_10=deb_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set cre_10=cre_10+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif183
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
      if l=0 then
       call ins05genniif141()
      end if
      if mniif141.nat="D" then 
       update niif183 set deb_10=deb_10+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      else
       update niif183 set cre_10=cre_10+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      end if
      update niif183 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif184
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
      if l=0 then
       call ins07genniif141()
      end if
      if mniif141.nat="D" then 
       update niif184 set deb_10=deb_10+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      else
       update niif184 set cre_10=cre_10+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      end if
      update niif184 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif186
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  if l=0 then
   call ins49genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif186 set deb_10=deb_10+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif186 set cre_10=cre_10+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif186 set ultmov=mniif141.fecha
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif185
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      if l=0 then
       call ins22genniif141()
      end if
      if mniif141.nat="D" then 
       update niif185 set deb_10=deb_10+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      else
       update niif185 set cre_10=cre_10+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      end if
      update niif185 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
     end if
    else
     CALL FGL_WINMESSAGE( "Administrador", "ERROR LA CUENTA DEL COMPROBANTE NO EXISTE", "stop")
    end if
END FUNCTION  }
{FUNCTION mes11genniif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif182
      where ano=mano and auxiliar=mniif141.auxiliar 
     if l=0 then
      call ins03genniif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set deb_11=deb_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set cre_11=cre_11+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif183
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
      if l=0 then
       call ins05genniif141()
      end if
      if mniif141.nat="D" then 
       update niif183 set deb_11=deb_11+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      else
       update niif183 set cre_11=cre_11+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      end if
      update niif183 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif184
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
      if l=0 then
       call ins07genniif141()
      end if
      if mniif141.nat="D" then 
       update niif184 set deb_11=deb_11+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      else
       update niif184 set cre_11=cre_11+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      end if
      update niif184 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif186
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  if l=0 then
   call ins49genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif186 set deb_11=deb_11+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif186 set cre_11=cre_11+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif186 set ultmov=mniif141.fecha
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif185
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      if l=0 then
       call ins22genniif141()
      end if
      if mniif141.nat="D" then 
       update niif185 set deb_11=deb_11+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      else
       update niif185 set cre_11=cre_11+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      end if
      update niif185 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
     end if
    else
     CALL FGL_WINMESSAGE( "Administrador", "ERROR LA CUENTA DEL COMPROBANTE NO EXISTE", "stop")
    end if
END FUNCTION  }
{FUNCTION mes12genniif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif182
      where ano=mano and auxiliar=mniif141.auxiliar 
     if l=0 then
      call ins03genniif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set deb_12=deb_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set cre_12=cre_12+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
     end case
     let mnivel=1
     call nivauxniif1()
     if mniif233.clase<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=2
     call nivauxniif1()
     if mniif233.grupo<>"0" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=3
     call nivauxniif1()
     if mniif233.cta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=4
     call nivauxniif1()
     if mniif233.subcta<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=5
     call nivauxniif1()
     if mniif233.auxuno<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=6
     call nivauxniif1()
     if mniif233.auxdos<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     let mnivel=7
     call nivauxniif1()
     if mniif233.auxtre<>"00" then
      update niif182 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mauxiliar
     end if
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif183
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
      if l=0 then
       call ins05genniif141()
      end if
      if mniif141.nat="D" then 
       update niif183 set deb_12=deb_12+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      else
       update niif183 set cre_12=cre_12+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      end if
      update niif183 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif184
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
      if l=0 then
       call ins07genniif141()
      end if
      if mniif141.nat="D" then 
       update niif184 set deb_12=deb_12+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      else
       update niif184 set cre_12=cre_12+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      end if
      update niif184 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
     end if
 if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
  let l=0 
  select count(*) into l from niif186
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  if l=0 then
   call ins49genniif141()
   IF gerrflag then
    return
   end if
  end if
  if mniif141.nat="D" then 
   update niif186 set deb_12=deb_12+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   update niif186 set cre_12=cre_12+mniif141.valor
    where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
      and niif186.codcen=mniif141.codcen
      and niif186.nit=mniif141.nit 
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
  update niif186 set ultmov=mniif141.fecha
   where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
     and niif186.codcen=mniif141.codcen 
     and niif186.nit=mniif141.nit 
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 end if
     if tpcon_ni2331.detalla="I" then
      let l=0 
      select count(*) into l from niif185
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      if l=0 then
       call ins22genniif141()
      end if
      if mniif141.nat="D" then 
       update niif185 set deb_12=deb_12+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      else
       update niif185 set cre_12=cre_12+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod
      end if
      update niif185 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codbod=mniif141.codbod 
     end if
    else
     CALL FGL_WINMESSAGE( "Administrador", "ERROR LA CUENTA DEL COMPROBANTE NO EXISTE", "stop")
    end if
END FUNCTION  }
{FUNCTION mes13genniif141()
    initialize tpcon_ni2331.* to null
    select * into tpcon_ni2331.* from niif233
     where auxiliar=mniif141.auxiliar
    if tpcon_ni2331.auxiliar is not null then
     let l=0 
     select count(*) into l from niif182
      where ano=mano and auxiliar=mniif141.auxiliar 
     if l=0 then
      call ins03genniif141()
     end if
     case
      when mniif141.nat="D" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set deb_13=deb_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
      when mniif141.nat="C" 
       let mnivel=1
       call nivauxniif1()
       if mniif233.clase<>"0" then
        update niif182 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=2
       call nivauxniif1()
       if mniif233.grupo<>"0" then
        update niif182 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=3
       call nivauxniif1()
       if mniif233.cta<>"00" then
        update niif182 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=4
       call nivauxniif1()
       if mniif233.subcta<>"00" then
        update niif182 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=5
       call nivauxniif1()
       if mniif233.auxuno<>"00" then
        update niif182 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=6
       call nivauxniif1()
       if mniif233.auxdos<>"00" then
        update niif182 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
       let mnivel=7
       call nivauxniif1()
       if mniif233.auxtre<>"00" then
        update niif182 set cre_13=cre_13+mniif141.valor
         where ano=mano and auxiliar=mauxiliar
       end if
     end case
     if tpcon_ni2331.tercero="S" then
      let l=0 
      select count(*) into l from niif183
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
      if l=0 then
       call ins05genniif141()
      end if
      if mniif141.nat="D" then 
       update niif183 set deb_13=deb_13+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
      else
       update niif183 set cre_13=cre_13+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit
      end if
      update niif183 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and nit=mniif141.nit 
     end if
     if tpcon_ni2331.centros="S" then
      let l=0 
      select count(*) into l from niif184
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
      if l=0 then
       call ins07genniif141()
      end if
      if mniif141.nat="D" then 
       update niif184 set deb_13=deb_13+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      else
       update niif184 set cre_13=cre_13+mniif141.valor
        where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen
      end if
      update niif184 set ultmov=mniif141.fecha
       where ano=mano and auxiliar=mniif141.auxiliar and codcen=mniif141.codcen 
     end if
######
     if tpcon_ni2331.centros="S" and tpcon_ni2331.tercero<>"N" then
        let l=0 
        select count(*) into l from niif186
        where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
          and niif186.codcen=mniif141.codcen 
          and niif186.nit=mniif141.nit 
        if l=0 then
          call ins49genniif141()
          IF gerrflag then
            return
         end if
        end if
        if mniif141.nat="D" then 
           update niif186 set deb_13=deb_13+mniif141.valor
            where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
            and niif186.codcen=mniif141.codcen
            and niif186.nit=mniif141.nit 
           IF status < 0 THEN
               LET gerrflag = TRUE
           END IF
        else
           update niif186 set cre_13=cre_13+mniif141.valor
            where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
              and niif186.codcen=mniif141.codcen
              and niif186.nit=mniif141.nit 
           IF status < 0 THEN
            LET gerrflag = TRUE
           END IF
        end if
        update niif186 set ultmov=mniif141.fecha
        where niif186.ano=mano and niif186.auxiliar=mniif141.auxiliar
         and niif186.codcen=mniif141.codcen 
         and niif186.nit=mniif141.nit 
        IF status < 0 THEN
          LET gerrflag = TRUE
        END IF
     end if
   end if
END FUNCTION  }
{FUNCTION ins03genniif141()
 INSERT INTO niif182
  ( ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
  VALUES ( mano, mniif141.auxiliar , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, tpcon_ni2331.cta, tpcon_ni2331.subcta,
    tpcon_ni2331.auxuno, tpcon_ni2331.auxdos, tpcon_ni2331.auxtre )
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,"00000000000"
 LET l=0
 select count(*) into l from niif182 where ano=mano and auxiliar=mauxini
 if l=0 then
  INSERT INTO niif182
  ( ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, "0", "00", "00", "00", "00", "00" )
 end if
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,"0000000000"
 LET l=0
 select count(*) into l from niif182 where ano=mano and auxiliar=mauxini
 if l=0 then
  INSERT INTO niif182
  ( ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, "00", "00", "00", "00", "00" )
 end if
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
             tpcon_ni2331.cta clipped,"00000000"
 LET l=0
 select count(*) into l from niif182 where ano=mano and auxiliar=mauxini
 if l=0 then
  INSERT INTO niif182
  ( ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, tpcon_ni2331.cta, "00", "00", "00", "00" )
 end if
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
             tpcon_ni2331.cta clipped,tpcon_ni2331.subcta clipped,"000000"
 LET l=0
 select count(*) into l from niif182 where ano=mano and auxiliar=mauxini
 if l=0 then
  INSERT INTO niif182
  ( ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, tpcon_ni2331.cta, tpcon_ni2331.subcta,
    "00", "00", "00" )
 end if
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
             tpcon_ni2331.cta clipped,tpcon_ni2331.subcta clipped,
             tpcon_ni2331.auxuno clipped,"0000"
 LET l=0
 select count(*) into l from niif182 where ano=mano and auxiliar=mauxini
 if l=0 then
  INSERT INTO niif182
  ( ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, tpcon_ni2331.cta, tpcon_ni2331.subcta,
    tpcon_ni2331.auxuno, "00", "00" )
 end if
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
             tpcon_ni2331.cta clipped,tpcon_ni2331.subcta clipped,
             tpcon_ni2331.auxuno clipped,tpcon_ni2331.auxdos clipped,"00"
 LET l=0
 select count(*) into l from niif182 where ano=mano and auxiliar=mauxini
 if l=0 then
  INSERT INTO niif182
  ( ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, tpcon_ni2331.cta, tpcon_ni2331.subcta,
    tpcon_ni2331.auxuno, tpcon_ni2331.auxdos, "00" )
 end if
 let mauxini=null
 let mauxini=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
             tpcon_ni2331.cta clipped,tpcon_ni2331.subcta clipped,
             tpcon_ni2331.auxuno clipped,tpcon_ni2331.auxdos clipped,
             tpcon_ni2331.auxtre clipped
 LET l=0
 select count(*) into l from niif182 where ano=mano and auxiliar=mauxini
 if l=0 then
  INSERT INTO niif182
  ( ano, auxiliar, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
    cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
    cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12,
    cre_13, deb_13, ultmov, clase, grupo, cta, subcta, auxuno, auxdos, auxtre )
   VALUES ( mano, mauxini , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha,
    tpcon_ni2331.clase, tpcon_ni2331.grupo, tpcon_ni2331.cta, tpcon_ni2331.subcta,
    tpcon_ni2331.auxuno, tpcon_ni2331.auxdos, tpcon_ni2331.auxtre )
 end if
END FUNCTION } 

{FUNCTION ins05genniif141()
 INSERT INTO niif183
 ( ano, auxiliar, nit, salant, cre_1, deb_1, cre_2, deb_2, cre_3, deb_3, 
  cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8, deb_8,
  cre_9, deb_9, cre_10, deb_10, cre_11, deb_11, cre_12, deb_12, 
  cre_13, deb_13, ultmov )
 VALUES ( mano, mniif141.auxiliar, mniif141.nit, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, mniif141.fecha )
END FUNCTION  }
{FUNCTION ins07genniif141()
 INSERT INTO niif184
 ( ano, auxiliar, codcen, salant, cre_1, deb_1, cre_2, deb_2,
   cre_3, deb_3, cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7,
   cre_8, deb_8, cre_9, deb_9, cre_10, deb_10, cre_11, deb_11,
   cre_12, deb_12, cre_13, deb_13 , ultmov )
 VALUES ( mano, mniif141.auxiliar, mniif141.codcen, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
  mniif141.fecha )
END FUNCTION } 
{FUNCTION ins49genniif141()
 INSERT INTO niif186
 ( ano, auxiliar, codcen, nit,  salant, cre_1, deb_1, cre_2, deb_2,
   cre_3, deb_3, cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7,
   cre_8, deb_8, cre_9, deb_9, cre_10, deb_10, cre_11, deb_11,
   cre_12, deb_12, cre_13, deb_13 , ultmov )
 VALUES ( mano, mniif141.auxiliar, mniif141.codcen, mniif141.nit, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, mniif141.fecha )
END FUNCTION}  
{FUNCTION ins22genniif141()
 INSERT INTO niif185
 ( ano, auxiliar, codbod, salant, cre_1, deb_1, cre_2, deb_2, cre_3,
  deb_3, cre_4, deb_4, cre_5, deb_5, cre_6, deb_6, cre_7, deb_7, cre_8,
  deb_8, cre_9, deb_9, cre_10, deb_10, cre_11, deb_11,
  cre_12, deb_12, ultmov )
 VALUES ( mano, mniif141.auxiliar, mniif141.codbod, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  mniif141.fecha )
END FUNCTION}
{FUNCTION nivauxniif1()
define m1,m2 integer
initialize mauxiliar to null
for i=1 to mnumdig
 let mauxiliar=mauxiliar clipped,"0"
end for
case
 when mnivel=0
  let mauxiliar=mauxiliar clipped
 when mnivel=1
  let mauxiliar=tpcon_ni2331.clase clipped,mauxiliar
 when mnivel=2
  let mauxiliar=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,mauxiliar
 when mnivel=3
  let mauxiliar=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
                tpcon_ni2331.cta clipped,mauxiliar
 when mnivel=4
  let mauxiliar=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
                tpcon_ni2331.cta clipped,tpcon_ni2331.subcta clipped,mauxiliar
 when mnivel=5
  let mauxiliar=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
                tpcon_ni2331.cta clipped,tpcon_ni2331.subcta clipped,
                tpcon_ni2331.auxuno clipped,mauxiliar 
 when mnivel=6
  let mauxiliar=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
                tpcon_ni2331.cta clipped,tpcon_ni2331.subcta clipped,
                tpcon_ni2331.auxuno clipped,tpcon_ni2331.auxdos clipped,mauxiliar
 when mnivel=7
  let mauxiliar=tpcon_ni2331.clase clipped,tpcon_ni2331.grupo clipped,
                tpcon_ni2331.cta clipped,tpcon_ni2331.subcta clipped,
                tpcon_ni2331.auxuno clipped,tpcon_ni2331.auxdos clipped,
                tpcon_ni2331.auxtre clipped
end case
let m1=1
let m2=mcla
let mniif233.clase=mauxiliar[1,mcla]
let m1=mcla+1
let m2=mcla+mgru
let mniif233.grupo=mauxiliar[m1,m2]
let m1=m2+1
let m2=mcla+mgru+mcta
let mniif233.cta=mauxiliar[m1,m2]
let m1=m2+1
let m2=mcla+mgru+mcta+msct
let mniif233.subcta=mauxiliar[m1,m2]
let m1=m2+1
let m2=mcla+mgru+mcta+msct+maux1
let mniif233.auxuno=mauxiliar[m1,m2]
let m1=m2+1
let m2=mcla+mgru+mcta+msct+maux1+maux2
let mniif233.auxdos=mauxiliar[m1,m2]
let m1=m2+1
let m2=mcla+mgru+mcta+msct+maux1+maux2+maux3
let mniif233.auxtre=mauxiliar[m1,m2]
END FUNCTION}





