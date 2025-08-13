  GLOBALS "fe_globales.4gl"
DEFINE mtiprep char(1)
DEFINE mnommes2, mnommes char(12)
DEFINE mregmes  ARRAY[12] OF RECORD
 nommes char(12)
END RECORD
function imprime_factu_r()
DEFINE handler om.SaxDocumentHandler
DEFINE contenido VARCHAR(1024)
 DEFINE mprefijo char(5)
 define ubicacion char(80)
 define mdoo,cnt integer
 define mtotfacc like fe_factura_d.valoruni
 define mtotivaa like fe_factura_d.iva
 DEFINE op char(1)
 let mprefijo=null
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null then 
  return
 end if
 let mdo=null
 let mdoo=null
 prompt "No. de Factura =====>> : " for mdoo
 if mdoo is null then 
  return
 end if
 let mdo=mdoo using "&&&&&&&"
 if mdo is null then 
  return
 end IF
 let op=null
 prompt "Digite 1>Forma Preimpresa - 2>Hoja Blanca  3> PDF  =====>> : " for op
 if op is null OR (op<>"1" AND op<>"2" AND op<>"3") then 
  return
 end if
 if mdo is not null then 
  MESSAGE  "Trabajando por favor espere ... " --AT 2,1
  let cnt=0
  select count(*) into cnt from fe_factura_m 
   where prefijo=mprefijo AND numfac=mdoo
  if cnt is null then let cnt=0 end if
  if cnt=0 THEN
   CALL FGL_WINMESSAGE( "Administrador", " LA FACTURA DIGITADA NO EXISTE ", "stop")
   return
  else
   initialize mfe_factura_m.* to null
   select * into mfe_factura_m.* from fe_factura_m 
    where prefijo=mprefijo AND numfac=mdoo
   if mfe_factura_m.estado<>"A" THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA FACTURA DIGITADA NO ESTA APROBADA ", "stop")
    return
   end if
  end if
 end if
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
let ubicacion=fgl_getenv("HOME"),"/reportes/factura_",mprefijo CLIPPED,"_",mdo
let ubicacion=ubicacion CLIPPED
let ubicacion2=fgl_getenv("HOME"),"/QR.png"
let ubicacion2=ubicacion2 CLIPPED

initialize mfe_factura_m.* to null
select * into mfe_factura_m.* from fe_factura_m 
where prefijo=mprefijo AND numfac=mdoo
initialize mfe_prefijos.* to NULL 
select * into mfe_prefijos.* from fe_prefijos 
where prefijo=mprefijo
DISPLAY  "..",mfe_prefijos.*
 CASE
  WHEN  op="1"
   start report rfactu_r to ubicacion
  WHEN  op ="2"
   start report hrfactu_r to ubicacion
  WHEN op="3" 
   IF mfe_prefijos.num_plantilla="2" THEN 
    IF fgl_report_loadCurrentSettings("factura_caja.4rp") THEN -- if  the file 
     -- loaded OK
     LET handler = fgl_report_commitCurrentSettings()     -- commit the file
     start report hrfactu_r TO XML HANDLER HANDLER
    END IF
   ELSE
    IF fgl_report_loadCurrentSettings("factura_epss.4rp") THEN -- if  the file 
     -- loaded OK
     LET handler = fgl_report_commitCurrentSettings()     -- commit the file
     start report hrfactu_r TO XML HANDLER HANDLER
    END IF
   END IF  
 END CASE
let mtotfacc=0
let mtotivaa=0
select sum(fe_factura_d.iva*fe_factura_d.cantidad) into mtotivaa
 from fe_factura_d
where prefijo=mprefijo AND documento=mfe_factura_m.documento
IF mfe_prefijos.redondeo ="S" THEN
  LET mtotivaa=nomredondea(mtotivaa)
END if
select sum(fe_factura_d.valor) into mtotfacc
 from fe_factura_d
where prefijo=mprefijo 
AND documento=mfe_factura_m.documento
initialize mfe_terceros.* to null
select * into mfe_terceros.* from fe_terceros 
 where nit=mfe_factura_m.nit
initialize mgener09.* to null 
SELECT * into mgener09.* FROM gener09
  WHERE codzon = mfe_terceros.zona
---
CALL llamadoQR(mfe_factura_m.*,mtotfacc,mtotivaa,ubicacion2)
---  
initialize mfe_factura_d.* to null
declare prfactu_r cursor for
select * from fe_factura_d
 where prefijo=mfe_factura_m.prefijo AND documento=mfe_factura_m.documento
  order by codigo,subcodigo
foreach prfactu_r into mfe_factura_d.*
 IF op="1" THEN
  output to report rfactu_r(mtotfacc,mtotivaa)
 ELSE
  output to report hrfactu_r(mtotfacc,mtotivaa)
 END if 
end FOREACH
IF op="1" THEN
 finish report rfactu_r
 call impsn(ubicacion)
ELSE
 finish report hrfactu_r
END if 
END FUNCTION
REPORT rfactu_r(mtotfacc,mtotivaa)
define mx1,mx2 char(1)
define mvaloruni,mtotfac,mtotfacc like fe_factura_d.valoruni
define mvaloriva,mtotiva,mtotivaa like fe_factura_d.iva
define mvalorsub,mtotsub,mtotsubb,mvalant,mtotsubben like fe_factura_d.subsi
DEFINE mrazsoc char(50)
DEFINE mnot1,mnot2,mnot3,mnot4,mnot5 char(80)
output
 top margin 0
 bottom margin 0
 left margin 0
 right margin 80
 page length 38
format
 page header
 if pageno="1" then
  let mtotfac=0
  let mtotiva=0
  let mtotsub=0
  let mtotsubben=0
 end if
 let mx1=null
 let mx2=null
 if mfe_factura_m.forma_pago="1" then
  let mx1="X"
 end if
 if mfe_factura_m.forma_pago="2" then
  let mx2="X"
 end IF
 let mrazsoc=NULL
 IF mfe_terceros.tipo_persona="1" THEN
  let mrazsoc=mfe_terceros.razsoc
 ELSE
  let mrazsoc=mfe_terceros.primer_apellido clipped," ",mfe_terceros.segundo_apellido clipped," ",
  mfe_terceros.primer_nombre clipped," ",mfe_terceros.segundo_nombre clipped
 END if
 skip 9 lines
 print column 10,mrazsoc,
       column 70,mfe_factura_m.nit
 print column 100,day(mfe_factura_m.fecha_elaboracion),
       column 107,month(mfe_factura_m.fecha_elaboracion),
       column 119,year(mfe_factura_m.fecha_elaboracion)
 skip 1 lines      
 print column 15,mfe_terceros.direccion,
       column 75,mx1,
       column 95,mx2
 skip 1 lines
 print column 15,mgener09.detzon[1,50],
       column 75,mfe_terceros.telefono,
       column 100,day(mfe_factura_m.fecha_vencimiento),
       column 107,month(mfe_factura_m.fecha_vencimiento),
       column 119,year(mfe_factura_m.fecha_vencimiento)
 skip 3 LINES
 LET mnot1=NULL
 LET mnot1=mfe_factura_m.nota1[1,80]
 LET mnot2=NULL
 LET mnot2=mfe_factura_m.nota1[81,160]
 LET mnot3=NULL
 LET mnot3=mfe_factura_m.nota1[161,240]
 LET mnot4=NULL
 LET mnot4=mfe_factura_m.nota1[241,320]
 LET mnot5=NULL
 LET mnot5=mfe_factura_m.nota1[321,400]
 --print  column 05,mfe_factura_m.nota1
 print  column 05,mnot1
 print  column 05,mnot2
 print  column 05,mnot3
 print  column 05,mnot4
 print  column 05,mnot5
 skip 1 lines
on every row
 let mvaloruni=0
 let mvaloruni=mfe_factura_d.valoruni
 let mtotfac=mtotfac+(mvaloruni*mfe_factura_d.cantidad)
 let mtotiva=mtotiva+(mfe_factura_d.iva*mfe_factura_d.cantidad)
 let mtotsub=mtotsub+(mfe_factura_d.subsi*mfe_factura_d.cantidad)
 let mtotsubben=mtotsubben+(mfe_factura_d.valorbene*mfe_factura_d.cantidad)
 initialize mfe_servicios.* to null
 select * into mfe_servicios.* from fe_servicios
 where codigo=mfe_factura_d.codigo
 initialize mfe_sub_servicios.* to null
 select * into mfe_sub_servicios.* from fe_sub_servicios
 where codigo=mfe_factura_d.subcodigo
 print  column 05,mfe_factura_d.codigo,
        column 17,mfe_factura_d.cantidad using "&&&&",
        column 30,mfe_servicios.descripcion[1,30] clipped,"-",mfe_sub_servicios.descripcion[1,30] clipped,
        column 90,mvaloruni using "##,###,##&.&&",
        column 110,mvaloruni*mfe_factura_d.cantidad using "###,###,##&.&&"
  --on last ROW
 page TRAILER
 IF mfe_prefijos.redondeo= "S" THEN 
   LET mtotiva=nomredondea(mtotiva)
   LET mtotsub=nomredondea(mtotsub)
   LET mtotfac=nomredondea(mtotfac)
 END IF 
 LET mvalant = 0
 SELECT sum(valor) INTO mvalant
  FROM fe_factura_anti
 WHERE prefijo = mfe_factura_m.prefijo
 AND documento = mfe_factura_m.documento
 IF mvalant IS NULL THEN
  LET mvalant = 0
 END IF
 let mvalche=(mtotfac+mtotiva)-(mtotsub+mvalant+mtotsubben)
 PRINT  COLUMN 30,"ANTICIPOS RECIBIDOS",
        column 110,mvalant*-1 using "---,---,--&.&&"
 PRINT  COLUMN 30,"VALOR SUBSIDIO",
        column 110,mtotsub*-1 using "---,---,--&.&&"
 PRINT  COLUMN 30,"OTROS BENEFICIOS",
        column 110,mtotsubben*-1 using "---,---,--&.&&"
 skip 1 lines       
 call letras()
 print  column 110,(mtotfac-mtotsub) using "###,###,##&.&&"
 print  column 05,mletras1 clipped," ",mletras2 clipped,
        column 110,mtotiva using "###,###,##&.&&"
 print  column 110,(mtotfac+mtotiva)-(mtotsub+mvalant+mtotsubben) using "###,###,##&.&&"
 --skip to top of page
end REPORT

REPORT hrfactu_r(mtotfacc,mtotivaa)
DEFINE mfe_servicios RECORD LIKE fe_servicios.*
--DEFINE mfe_prefijos RECORD LIKE fe_prefijos.*
define mx1,mx2 char(1)
define mvaloruni,mtotfac,mtotfacc like fe_factura_d.valoruni
define mvaloriva,mtotiva,mtotivaa like fe_factura_d.iva
define mtotal,mvalorsub,mtotsub,mtotsubb, mvalant ,mimpc,mvalorbene like fe_factura_d.subsi
DEFINE mcodigo LIKE fe_factura_d.codigo
DEFINE mcantidad like fe_factura_d.cantidad
DEFINE mrazsoc char(50)
DEFINE mdetalle char(100)
DEFINE mdet,mdett char(30)
DEFINE l INT 
output
 top margin 4
 bottom margin 4
 left margin 0
 right margin 132
 page length 66
format
 page header
-- BEFORE GROUP OF mfe_factura_m.numfac
 if pageno="1" then
  let mtotfac=0
  let mtotiva=0
  let mtotsub=0
  LET l=0
 end IF
 let mtime=time
 print column 104, "FACTURA DE VENTA : ",mfe_factura_m.prefijo clipped," ",mfe_factura_m.numfac USING "#######"
 skip 1 LINES
 let mp1 = (132-length(mfe_empresa.razsoc clipped))/2
 print column mp1,mfe_empresa.razsoc
 let mp1 = (132-length("EDIFICIO SEDE: Avenida 2 Calle 14 Esquina"))/2
 print column mp1,"EDIFICIO SEDE: Avenida 2 Calle 14 Esquina"
 let mp1 = (132-length("PBX. 5836888"))/2
 print column mp1,"PBX. 5836888"
 let mp1 = (132-length("Cucuta - Norte de Santander"))/2
 print column mp1,"Cucuta - Norte de Santander"
 let mp1 = (132-length("NO SOMOS GRANDES CONTIBUYENTES RESOLUCION DIAN No. 0041 DEL 30/01/2014"))/2
 print column mp1,"NO SOMOS GRANDES CONTIBUYENTES RESOLUCION DIAN No. 0041 DEL 30/01/2014"
 skip 1 LINES
 --PRINT mfe_factura_m.*

 --print "---------------------------------------------------------------",
  ---     "------------------------------------------------------------------------------"
 --PRINT mfe_factura_m.fecha_factura       
 --PRINT COLUMN 01,"DATOS DEL CLIENTE"
 let mrazsoc=NULL
 IF mfe_terceros.tipo_persona="1" THEN
  let mrazsoc=mfe_terceros.razsoc
 ELSE
  let mrazsoc=mfe_terceros.primer_apellido clipped," ",mfe_terceros.segundo_apellido clipped," ",
              mfe_terceros.primer_nombre clipped," ",mfe_terceros.segundo_nombre clipped
 END if
 skip 1 LINES
 print mrazsoc
 --PRINT mfe_factura_m.nit
 print mfe_terceros.direccion 
 print mfe_terceros.telefono
 print mgener09.detzon
 CASE
  WHEN mfe_factura_m.forma_pago="1"
   LET mdet="CONTADO"
  WHEN mfe_factura_m.forma_pago="2"
   LET mdet="CREDITO"
 END case  
 print "Forma Pago : ",mdet 
 --PRINT mfe_factura_m.fecha_factura
-- print "---------------------------------------------------------------",
--       "------------------------------------------------------------------------------"
-- PRINT COLUMN 01,"SERVI",
--       COLUMN 07,"DESCRIPCION",
--       COLUMN 75,"CANT",
--       COLUMN 85,"VALOR UNITARIO",
--       COLUMN 105,"VALOR SUBSIDIO",
--       COLUMN 125,"VALOR TOTAL"
--print "---------------------------------------------------------------",
--      "------------------------------------------------------------------------------"
ON  EVERY  ROW
 LET l=l+1
--INITIALIZE mfe_prefijos.* TO NULL 
--SELECT * INTO mfe_prefijos.* 
-- FROM fe_prefijos
-- WHERE prefijo=mfe_factura_m.prefijo 
 INITIALIZE mfe_servicios.* TO NULL 
 SELECT * INTO mfe_servicios.* FROM fe_servicios
  WHERE codigo=mfe_factura_d.codigo 
 PRINT mfe_servicios.coduni 
 PRINT l 
 PRINT mfe_prefijos.*
 
 PRINT mfe_factura_m.*
 
 PRINT mfe_factura_d.*
 LET mcodigo=mfe_factura_d.codigo
 LET mcantidad=mfe_factura_d.cantidad 
 PRINT mcodigo
 PRINT mcantidad

 
DISPLAY "Cat..",mfe_factura_d.codigo," ",mfe_factura_d.cantidad
 
 --PRINT mfe_factura_m.prefijo 
 --PRINT mfe_factura_m.numfac 
 --PRINT mfe_factura_m.fecha_factura
--- skip 1 LINES
-- PRINT COLUMN 01,"DATOS DEL CLIENTE"
 let mrazsoc=NULL
 IF mfe_terceros.tipo_persona="1" THEN
  let mrazsoc=mfe_terceros.razsoc
 ELSE
  let mrazsoc=mfe_terceros.primer_apellido clipped," ",mfe_terceros.segundo_apellido clipped," ",
              mfe_terceros.primer_nombre clipped," ",mfe_terceros.segundo_nombre clipped
 END if
 skip 1 LINES
 DISPLAY  "..",mfe_terceros.* 
 PRINT mrazsoc
 --print mfe_factura_m.nit
 print mfe_terceros.direccion 
 print mfe_terceros.telefono
 print mgener09.detzon
 CASE
  WHEN mfe_factura_m.forma_pago="1"
   LET mdet="CONTADO"
   CASE 
    WHEN mfe_factura_m.medio_pago="10"
     LET mdett="EFECTIVO"
    WHEN mfe_factura_m.medio_pago="20" 
     LET mdett="CHEQUE"
    WHEN mfe_factura_m.medio_pago="42"  
     LET mdett="CONSIGNACION"
    WHEN mfe_factura_m.medio_pago="45"    
     LET mdett="TRANSFERENCIA"
    WHEN mfe_factura_m.medio_pago="48"    
     LET mdett="TARJETA CREDITO"
    WHEN mfe_factura_m.medio_pago="49"     
     LET mdett="TARJETA DEBITO"
   END CASE  
  WHEN mfe_factura_m.forma_pago="2"
   LET mdet="CREDITO"
 END case  
 print mdet 
 print mdett 
 let mvaloruni=0
 let mvaloruni=mfe_factura_d.valoruni
 let mtotfac=mtotfac+(mvaloruni*mfe_factura_d.cantidad)
 let mtotiva=mtotiva+(mfe_factura_d.iva*mfe_factura_d.cantidad)
 let mtotsub=mtotsub+(mfe_factura_d.subsi*mfe_factura_d.cantidad)
 initialize mfe_servicios.* to null
 select * into mfe_servicios.* from fe_servicios
 where codigo=mfe_factura_d.codigo
 DISPLAY  ":",mfe_servicios.descripcion
 initialize mfe_sub_servicios.* to null
 select * into mfe_sub_servicios.* from fe_sub_servicios
 where codigo=mfe_factura_d.subcodigo
 print  mfe_factura_d.codigo
 PRINT  mfe_servicios.descripcion,"-",mfe_sub_servicios.descripcion
 PRINT  mfe_factura_d.cantidad 
 PRINT  mvaloruni 
 LET mvalorsub=mfe_factura_d.subsi*mfe_factura_d.cantidad 
 PRINT mvalorsub 
 LET mtotfacc=(mvaloruni-mfe_factura_d.subsi)*mfe_factura_d.cantidad 
 --LET mtotfacc=mtotfacc-mvalorsub 
 PRINT mtotfacc       
 --page TRAILER
 ON  LAST  ROW
 --AFTER GROUP OF mfe_factura_m.numfac
 
 INITIALIZE mgen02.* TO NULL
 select * into mgen02.* from gener02 where usuario=mfe_factura_m.usuario_add
 --print "---------------------------------------------------------------",
 --      "------------------------------------------------------------------------------"
 --skip 1 lines

 PRINT mgen02.nombre
 
 IF mfe_prefijos.redondeo ="S" THEN
  LET mtotiva=nomredondea(mtotiva)
  LET mtotsub=nomredondea(mtotsub)
  LET mtotfac=nomredondea(mtotfac)
 END IF 
 LET mvalant = 0
 
 SELECT sum(valor) INTO mvalant
  FROM fe_factura_anti
 WHERE prefijo = mfe_factura_m.prefijo
 AND documento = mfe_factura_m.documento
 IF mvalant IS NULL THEN
  LET mvalant = 0
 END IF  
 
 
 

 DISPLAY "",mletras1," ",mletras2 
 print  mtotfac 
 LET mtotsub=mtotsub*-1 
 PRINT  mtotsub
 LET mvalant=mvalant*-1  
 print  mvalant     
 print  mtotiva 
 IF mvalorbene IS NULL THEN
  LET mvalorbene = 0
 END IF  

 

 SELECT sum(impc),SUM(valorbene*cantidad)    INTO mimpc, mvalorbene
  FROM fe_factura_d
 WHERE prefijo = mfe_factura_m.prefijo
 AND documento = mfe_factura_m.documento
 
 IF mimpc IS NULL THEN
  LET mimpc = 0
 END IF  
 
 PRINT mimpc
 PRINT mvalorbene


 LET mvalorbene=mvalorbene*-1 
 DISPLAY  "bne.",mvalorbene
 LET mtotal=(mtotfac+mtotiva+mtotsub+mvalant+mvalorbene) 
 DISPLAY  "total..",mtotal
 print  mtotal 


 let mvalche=(mtotal)
 DISPLAY  "che",mvalche
 call letras()
PRINTX mletras1 
 PRINTX mletras2 
 --SKIP 4 LINES
 --print "---------------------------------------------------------------",
 --      "------------------------------------------------------------------------------"
 print mfe_factura_m.nota1
 --PRINT mfe_factura_m.nota1
 --PRINT mfe_factura_m.nota1
 --print "---------------------------------------------------------------",
 --      "------------------------------------------------------------------------------"
 --SKIP 3 LINES      
 --PRINT COLUMN 1, "________________________________________________________"
-- PRINT  "      Elaboró : ", mgen02.nombre 
 --SKIP 3 LINES
 --print "---------------------------------------------------------------",
 --      "------------------------------------------------------------------------------"
 PRINT "FACTURA POR COMPUTADOR"
 PRINT "Autorizacion de Facturacion DIAN No. ",mfe_prefijos.num_auto clipped," Fecha. ",mfe_prefijos.fec_auto 
 PRINT "Numeracion Habilitada del ",mfe_prefijos.numini clipped," hasta el ",mfe_prefijos.numfin 
 PRINT "Fecha Vencimiento ",mfe_prefijos.fec_ven USING "yyyy/mm/dd"
  --on last row
 --skip to top of page
end REPORT



REPORT hrfactu_rr(mfe_factura_m,mfe_factura_d,mtotfacc,mtotivaa)
--DEFINE mfe_prefijos RECORD LIKE fe_prefijos.*
DEFINE mfe_factura_m RECORD LIKE fe_factura_m.*
DEFINE mfe_factura_d RECORD LIKE fe_factura_d.*
define mx1,mx2 char(1)
define mvaloruni,mtotfac,mtotfacc like fe_factura_d.valoruni
define mvaloriva,mtotiva,mtotivaa like fe_factura_d.iva
define mtotal,mvalorsub,mtotsub,mtotsubb, mvalant ,mimpc,mvalorbene like fe_factura_d.subsi
DEFINE mrazsoc char(50)
DEFINE mdetalle char(100)
DEFINE mdet char(10)
output
 top margin 4
 bottom margin 4
 left margin 0
 right margin 132
 page length 66
format
 
 BEFORE GROUP OF mfe_factura_m.documento
  let mtotfac=0
  let mtotiva=0
  let mtotsub=0
  let mtime=time
 print column 104, "FACTURA DE VENTA : ",mfe_factura_m.prefijo clipped," ",mfe_factura_m.numfac USING "#######"
 skip 1 LINES
 let mp1 = (132-length(mfe_empresa.razsoc clipped))/2
 print column mp1,mfe_empresa.razsoc
 let mp1 = (132-length("EDIFICIO SEDE: Avenida 2 Calle 14 Esquina"))/2
 print column mp1,"EDIFICIO SEDE: Avenida 2 Calle 14 Esquina"
 let mp1 = (132-length("PBX. 5836888"))/2
 print column mp1,"PBX. 5836888"
 let mp1 = (132-length("Cucuta - Norte de Santander"))/2
 print column mp1,"Cucuta - Norte de Santander"
 let mp1 = (132-length("NO SOMOS GRANDES CONTIBUYENTES RESOLUCION DIAN No. 0041 DEL 30/01/2014"))/2
 print column mp1,"NO SOMOS GRANDES CONTIBUYENTES RESOLUCION DIAN No. 0041 DEL 30/01/2014"
 skip 1 LINES
 --PRINT mfe_factura_m.*

 --print "---------------------------------------------------------------",
  ---     "------------------------------------------------------------------------------"
 --PRINT mfe_factura_m.fecha_factura       
 --PRINT COLUMN 01,"DATOS DEL CLIENTE"
 let mrazsoc=NULL
 IF mfe_terceros.tipo_persona="1" THEN
  let mrazsoc=mfe_terceros.razsoc
 ELSE
  let mrazsoc=mfe_terceros.primer_apellido clipped," ",mfe_terceros.segundo_apellido clipped," ",
              mfe_terceros.primer_nombre clipped," ",mfe_terceros.segundo_nombre clipped
 END if
 skip 1 LINES
 print mrazsoc
 --PRINT mfe_factura_m.nit
 print mfe_terceros.direccion 
 print mfe_terceros.telefono
 print mgener09.detzon
 CASE
  WHEN mfe_factura_m.forma_pago="1"
   LET mdet="CONTADO"
  WHEN mfe_factura_m.forma_pago="2"
   LET mdet="CREDITO"
 END case  
 print "Forma Pago : ",mdet 
 --PRINT mfe_factura_m.fecha_factura
-- print "---------------------------------------------------------------",
--       "------------------------------------------------------------------------------"
-- PRINT COLUMN 01,"SERVI",
--       COLUMN 07,"DESCRIPCION",
--       COLUMN 75,"CANT",
--       COLUMN 85,"VALOR UNITARIO",
--       COLUMN 105,"VALOR SUBSIDIO",
--       COLUMN 125,"VALOR TOTAL"
--print "---------------------------------------------------------------",
--      "------------------------------------------------------------------------------"
ON  EVERY  ROW

--INITIALIZE mfe_prefijos.* TO NULL 
--SELECT * INTO mfe_prefijos.* 
-- FROM fe_prefijos
-- WHERE prefijo=mfe_factura_m.prefijo 
 PRINT mfe_prefijos.*
 PRINT mfe_factura_m.*
 PRINT mfe_factura_d.*
DISPLAY "Cat..",mfe_factura_d.codcat
 
 --PRINT mfe_factura_m.prefijo 
 --PRINT mfe_factura_m.numfac 
 --PRINT mfe_factura_m.fecha_factura
--- skip 1 LINES
-- PRINT COLUMN 01,"DATOS DEL CLIENTE"
 let mrazsoc=NULL
 IF mfe_terceros.tipo_persona="1" THEN
  let mrazsoc=mfe_terceros.razsoc
 ELSE
  let mrazsoc=mfe_terceros.primer_apellido clipped," ",mfe_terceros.segundo_apellido clipped," ",
              mfe_terceros.primer_nombre clipped," ",mfe_terceros.segundo_nombre clipped
 END if
 skip 1 LINES
 DISPLAY  "..",mfe_terceros.* 
 PRINT mrazsoc
 --print mfe_factura_m.nit
 print mfe_terceros.direccion 
 print mfe_terceros.telefono
 print mgener09.detzon
 CASE
  WHEN mfe_factura_m.forma_pago="1"
   LET mdet="CONTADO"
  WHEN mfe_factura_m.forma_pago="2"
   LET mdet="CREDITO"
 END case  
 print mdet 
 let mvaloruni=0
 let mvaloruni=mfe_factura_d.valoruni
 let mtotfac=mtotfac+(mvaloruni*mfe_factura_d.cantidad)
 let mtotiva=mtotiva+(mfe_factura_d.iva*mfe_factura_d.cantidad)
 let mtotsub=mtotsub+(mfe_factura_d.subsi*mfe_factura_d.cantidad)
 initialize mfe_servicios.* to null
 select * into mfe_servicios.* from fe_servicios
 where codigo=mfe_factura_d.codigo
 initialize mfe_sub_servicios.* to null
 select * into mfe_sub_servicios.* from fe_sub_servicios
 where codigo=mfe_factura_d.subcodigo
 print  mfe_factura_d.codigo
 PRINT  mfe_servicios.descripcion,"-",mfe_sub_servicios.descripcion
 PRINT  mfe_factura_d.cantidad 
 PRINT  mvaloruni 
 LET mvalorsub=mfe_factura_d.subsi*mfe_factura_d.cantidad 
 PRINT mvalorsub 
 LET mtotfacc=(mvaloruni-mfe_factura_d.subsi)*mfe_factura_d.cantidad 
 --LET mtotfacc=mtotfacc-mvalorsub 
 PRINT mtotfacc       
 --page TRAILER
 --ON  LAST  ROW
 AFTER GROUP OF mfe_factura_m.documento
 
 INITIALIZE mgen02.* TO NULL
 select * into mgen02.* from gener02 where usuario=mfe_factura_m.usuario_add
 --print "---------------------------------------------------------------",
 --      "------------------------------------------------------------------------------"
 --skip 1 lines

 PRINT mgen02.nombre
 
 IF mfe_prefijos.redondeo ="S" THEN
  LET mtotiva=nomredondea(mtotiva)
  LET mtotsub=nomredondea(mtotsub)
  LET mtotfac=nomredondea(mtotfac)
 END IF 
 LET mvalant = 0
 
 SELECT sum(valor) INTO mvalant
  FROM fe_factura_anti
 WHERE prefijo = mfe_factura_m.prefijo
 AND documento = mfe_factura_m.documento
 IF mvalant IS NULL THEN
  LET mvalant = 0
 END IF  
 
 DISPLAY "",mletras1," ",mletras2 
 print  mtotfac 
 LET mtotsub=mtotsub*-1 
 PRINT  mtotsub
 LET mvalant=mvalant*-1  
 print  mvalant     
 print  mtotiva 
 IF mvalorbene IS NULL THEN
  LET mvalorbene = 0
 END IF  

 SELECT sum(impc),SUM(valorbene*cantidad)    INTO mimpc, mvalorbene
  FROM fe_factura_d
 WHERE prefijo = mfe_factura_m.prefijo
 AND documento = mfe_factura_m.documento
 
 IF mimpc IS NULL THEN
  LET mimpc = 0
 END IF  
 
 PRINT mimpc
 PRINT mvalorbene
 LET mvalorbene=mvalorbene*-1 
 DISPLAY  "bne.",mvalorbene
 LET mtotal=(mtotfac+mtotiva+mtotsub+mvalant+mvalorbene) 
 DISPLAY  "total..",mtotal
 print  mtotal 


 let mvalche=(mtotal)
 DISPLAY  "che",mvalche
 call letras()
PRINTX mletras1 
 PRINTX mletras2 
 --SKIP 4 LINES
 --print "---------------------------------------------------------------",
 --      "------------------------------------------------------------------------------"
 print mfe_factura_m.nota1
 --PRINT mfe_factura_m.nota1
 --PRINT mfe_factura_m.nota1
 --print "---------------------------------------------------------------",
 --      "------------------------------------------------------------------------------"
 --SKIP 3 LINES      
 --PRINT COLUMN 1, "________________________________________________________"
-- PRINT  "      Elaboró : ", mgen02.nombre 
 --SKIP 3 LINES
 --print "---------------------------------------------------------------",
 --      "------------------------------------------------------------------------------"
 PRINT "FACTURA POR COMPUTADOR"
 PRINT "Autorizacion de Facturacion DIAN No. ",mfe_prefijos.num_auto clipped," Fecha. ",mfe_prefijos.fec_auto 
 PRINT "Numeracion Habilitada del ",mfe_prefijos.numini clipped," hasta el ",mfe_prefijos.numfin 
 PRINT "Fecha Vencimiento ",mfe_prefijos.fec_ven USING "yyyy/mm/dd"
  --on last row
 --skip to top of page
end REPORT



function detalladofactu()
 define mfe_factura_m record like fe_factura_m.*
 define mfe_factura_d record like fe_factura_d.*
 define ubicacion char(100)
 define op char(1)
 define mcaja char(2)
 define cnt,musuario integer
 define mcosto,mcostoo decimal(12,2)
 DEFINE mprefijo char(5)
 define tp record
  codser char(5),
  codcat char(2),
  costo decimal(12,2),
  subsidio decimal(12,2),
  cantidad integer,
  iva decimal(12,2),
  total decimal(12,2)
 end RECORD

 LET mfecini = NULL
 LET mfecfin = NULL
 let mdeftit="    RELACION DE FACTURAS "
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL confecr() RETURNING mfecini,mfecfin
 if mfecini is null or mfecfin is null then
   return
 end IF
 let mprefijo=null
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null then 
  return
 end if
 MESSAGE "" --AT 2,1
 MESSAGE "Trabajando por favor espere ... " --AT 2,1
 
 create temp table mvilla2
 (
  documento integer,
  codser char(5),
  codcat char(2),
  costo decimal(12,2),
  subsidio decimal(12,2), 
  cantidad integer,
  iva decimal(12,2),
  total decimal(12,2)
 )
 let ubicacion=fgl_getenv("HOME"),"/reportes/detalladofac"
 let ubicacion=ubicacion clipped
 start report rarqgennnfac to ubicacion
  INITIALIZE mfe_factura_m.* TO NULL
  declare facrrtes44444 cursor for
  SELECT * FROM fe_factura_m
    WHERE prefijo=mprefijo 
    AND fecha_factura>=mfecini and fecha_factura<=mfecfin
     and (estado="A" OR
      (fe_factura_m.estado ="N" AND fe_factura_m.fecest > mfecfin))
   ORDER BY documento
  FOREACH facrrtes44444 INTO mfe_factura_m.*
   INITIALIZE mfe_factura_d.* TO NULL
   declare facrrtes444444 cursor for
   SELECT fe_factura_d.* FROM fe_factura_d, fe_servicios
     WHERE  fe_factura_d.codigo = fe_servicios.codigo
       AND fe_servicios.cobertura <> "0"
       AND fe_factura_d.documento=mfe_factura_m.documento
       AND fe_factura_d.prefijo=mfe_factura_m.prefijo
    ORDER BY fe_factura_d.codigo
   FOREACH facrrtes444444 INTO mfe_factura_d.*
    insert into mvilla2 ( documento, codser, codcat, costo, subsidio, cantidad, 
     iva, total )
    values ( mfe_factura_m.numfac, mfe_factura_d.codigo, 
     mfe_factura_d.codcat, mfe_factura_d.valoruni, 
     mfe_factura_d.subsi, mfe_factura_d.cantidad,
     mfe_factura_d.iva, mfe_factura_d.valor )
   END FOREACH
  END FOREACH
 INITIALIZE tp.* TO NULL
 declare facrtestp cursor for
 #SELECT codusu,codser,codcat,codtipusu,costo,sum(cantidad),sum(iva),sum(total)
 SELECT codser,codcat,costo,subsidio,sum(cantidad),sum(iva*cantidad),sum(total-subsidio*cantidad)
   FROM mvilla2
  GROUP BY codser,codcat,costo,subsidio --,iva
  ORDER BY codser,codcat,costo--,iva
 FOREACH facrtestp INTO tp.*
  --LET tp.iva= nomredondea(tp.iva)
  --LET tp.total=nomredondea(tp.total)
  output to report rarqgennnfac(tp.*,mprefijo)
 end foreach
 finish report rarqgennnfac
 call impsn(ubicacion)
 drop table mvilla2
END FUNCTION  
REPORT rarqgennnfac(tp,mprefijo)
define op char(1)
define mcaja char(2)
define cnt,musuario integer
define mtitulo char(100)
DEFINE mprefijo char(5)
define tp record
-- documento integer,
 codser char(5),
 codcat char(2),
 costo decimal(12,2),
 subsidio decimal(12,2),
 cantidad integer,
 iva decimal(12,2),
 total decimal(12,2)
end record
output
 top margin 1
 bottom margin 1
 left margin 0
 right margin 132
 page length 66
format
 page header
 print column 1,"Fecha : ",today," + ",mtime,
       column 121,"Pag No. ",pageno using "####"
 skip 1 lines
 let mp1 = (132-length(mfe_empresa.razsoc clipped))/2
 print column mp1,mfe_empresa.razsoc
 print column 56,"MOVIMIENTO DE LOS SERVICIOS POR FACTURAS DE ",mfecini," AL ",mfecfin
 skip 1 lines
 let mtitulo="MOVIMIENTO GENERAL PREFIJO ",mprefijo
 print column 01,mtitulo
 print "----------------------------------------------------------------------------",
       "----------------------------------------------------------------------------"
 print  column 01,"SERVICIO",
        column 60,"CAT",
        column 65,"CANTID",
        column 75,"  VAL TARIFA   ",
        COLUMN 95, "VAL SUBSIDIO ",  
        column 115,"  TOTAL IVA    ",
        column 135,"  VALOR TOTAL  "
       -- column 135,"# FACTURA"
 print "----------------------------------------------------------------------------",
       "----------------------------------------------------------------------------"

on every row
 initialize mfe_servicios.* to null
 select * into mfe_servicios.* from fe_servicios
  where codigo=tp.codser
 --LET tp.costo=nomredondea(tp.costo-(tp.iva/tp.cantidad)) 
 print  column 01,tp.codser,
        column 08,mfe_servicios.descripcion,
        column 61,tp.codcat,
        column 65,tp.cantidad using "&&&&&&",
        column 75,tp.costo using "###,###,##&.&&",
        COLUMN 95,(tp.subsidio* tp.cantidad) using "###,###,##&.&&",
        column 115,tp.iva using "###,###,##&.&&",
        column 135,tp.total using "###,###,##&.&&"
        --column 135,tp.documento
 on last row
 skip 3 lines
 print  column 01,"TOTALES GENERAL ==> ",
        column 65,"______",
        column 95,"__________________",
        column 115,"__________________",
        column 135,"__________________"
 print  column 65,sum(tp.cantidad) using "&&&&&&",
        COLUMN 95,sum(tp.subsidio* tp.cantidad) using "###,###,##&.&&",
        column 115,sum(tp.iva) using "###,###,###,##&.&&",
        column 135,sum(tp.total) using "###,###,###,##&.&&"
 skip to top of page
end report

FUNCTION rep_facturas_ter()
DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
DEFINE mcodser LIKE fe_servicios.codigo
DEFINE mcodpun CHAR(2)
DEFINE cnt INTEGER
DEFINE opp,ox,oxx CHAR(1)
DEFINE mprefijo char(5)
 let ubicacion=fgl_getenv("HOME"),"/reportes/facturas_ter"
 let ubicacion=ubicacion CLIPPED
 let mprefijo=NULL
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null THEN 
  RETURN
 end IF
 {let mcodser = NULL
 prompt "Codigo servicio =====>> : " for mcodser
 LET mcodser=  upshift(mcodser)
 if mcodser is null THEN 
  RETURN
 end if}
 LET mfecini = NULL
 LET mfecfin = NULL
 let mdeftit="    RELACION DE FACTURAS "
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL confecr() RETURNING mfecini,mfecfin
 if mfecini is null or mfecfin is null then
   return
 end IF
 LET mtiprep = NULL
 PROMPT " Reporte  1. Texto   2. Excel : " for  mtiprep
 IF mtiprep <> "1" AND mtiprep <> "2" THEN
    RETURN
 END if  
 IF mtiprep ="1" THEN
  START REPORT terrprec_txtpp TO ubicacion
 ELSE
  LET handler = configureOutputt("XLS","22cm","28cm",17,"1.5cm")
  --LET handler = configureOutput_excel(90,"5.0cm","3.0cm","0.5cm","0.5cm","XLSX")
  START REPORT terrprec_xlspp TO XML HANDLER HANDLER
 END IF
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
  DECLARE terppcurrec CURSOR FOR
   SELECT fe_factura_m.* 
   FROM fe_factura_m 
    WHERE fe_factura_m.prefijo = mprefijo 
    AND fe_factura_m.fecha_factura between mfecini and mfecfin
    AND fe_factura_m.estado ="A" 
    ORDER BY fe_factura_m.numfac
   FOREACH terppcurrec INTO mfe_factura_m.*
    DECLARE tterppcurrec CURSOR FOR
    SELECT * FROM fe_factura_ter
    WHERE prefijo=mfe_factura_m.prefijo 
    AND documento=mfe_factura_m.documento 
     ORDER BY cat
    FOREACH tterppcurrec INTO mfe_factura_ter.*
       IF mtiprep = "1" THEN
        OUTPUT TO REPORT terrprec_txtpp()
      ELSE
        OUTPUT TO REPORT terrprec_xlspp()
      END IF  
    END FOREACH 
   END FOREACH
 IF mtiprep ="1" THEN
   finish report terrprec_txtpp
   let mdefnom="RELACION DE RECIBOS"
   let mdeflet="condensed"
   let mdeftam=66
   let mhoja="9.5x11"
   call impsn(ubicacion)
 ELSE
   finish report terrprec_xlspp 
 END IF  
END FUNCTION

REPORT terrprec_xlspp()
 define mnombre char(60)
 DEFINE mnom char(60)
 DEFINE mformap char(10)
 DEFINE mformapp,mformappp char(20)
 DEFINE mestado char(10)
 DEFINE mcat char(20)
 define msexo char(20)
 --output
  --top margin 3
  --bottom  margin 8
  --left  margin 0
  --right margin 240
  --page length 66
 format
  FIRST page HEADER
    
  print column 01,"PREF",
        column 8,"NUM/FAC",
        column 20,"FE.FACTURA",
        COLUMN 32,"DOC.BENEF",
        COLUMN 40,"NOMBRE BENEFICIARIO",
        COLUMN 75, "SEXO",
        COLUMN 87,"CATEGO",
        COLUMN 97,"EDAD",
        column 107,"TERCERO",
        column 125,"NOMBRE TERCERO"
  on every row
   initialize mfe_terceros.* to null
   select * into mfe_terceros.* from fe_terceros 
    where nit=mfe_factura_m.nit
   IF mfe_terceros.tipo_persona="2" THEN 
    LET mnombre=NULL
    Let mnombre=mfe_terceros.primer_apellido CLIPPED," ",
                mfe_terceros.segundo_apellido CLIPPED," ",
                mfe_terceros.primer_nombre CLIPPED," ",
                mfe_terceros.segundo_nombre CLIPPED," "
   ELSE
    LET mnombre=NULL
    Let mnombre=mfe_terceros.razsoc CLIPPED
   END IF
   LET mformap=NULL
   LET mformapp=NULL
   LET mformappp=null   
   CASE
    when mfe_factura_m.forma_pago="1"
     LET mformap="CONTADO"
    when mfe_factura_m.forma_pago="2"
     LET mformap="CREDITO" 
   END CASE
   CASE
    when mfe_factura_m.medio_pago="1"
     LET mformapp="EFECTIVO"
    when mfe_factura_m.medio_pago="2"
     LET mformapp="TARJETA CREDITO"
    when mfe_factura_m.medio_pago="3"
     LET mformapp="TARJETA DEBITO"
    when mfe_factura_m.medio_pago="4"
     LET mformapp="CONSIGNACION"
    when mfe_factura_m.medio_pago="5"
     LET mformapp="CHEQUE"
    when mfe_factura_m.medio_pago="6"
     LET mformapp="TRANSFERENCIA"
    when mfe_factura_m.medio_pago="7"
     LET mformapp="LIBRANZA"
   END CASE
   CASE
    when mfe_factura_m.franquicia="1"
     LET mformappp="VISA"
    when mfe_factura_m.franquicia="2"
     LET mformappp="MASTERCARD"
    when mfe_factura_m.franquicia="3"
     LET mformappp="DINERS"
    when mfe_factura_m.franquicia="4"
     LET mformappp="AMERICAN EXPRESS"
   END CASE 
   CASE 
    WHEN mfe_factura_ter.cat="A"
     LET mcat="CATEGORIA A"
    WHEN mfe_factura_ter.cat="B"
     LET mcat="CATEGORIA B"
    WHEN mfe_factura_ter.cat="C"
     LET mcat="CATEGORIA C"
    WHEN mfe_factura_ter.cat="D"
     LET mcat="CATEGORIA D"
    WHEN mfe_factura_ter.cat="E"
     LET mcat="CATEGORIA E"
   END CASE

   CASE 
    WHEN mfe_factura_ter.sexo="M"
     LET msexo="MASCULINO"
    WHEN mfe_factura_ter.sexo="F"
     LET msexo="FEMENINO"
   END CASE

   LET mnom=NULL
   LET mnom=mfe_factura_ter.nombre clipped 
 PRINT   column 01, mfe_factura_m.prefijo,
         column 8, mfe_factura_m.numfac, 
         column 20, mfe_factura_m.fecha_factura,
         column 34, mfe_factura_ter.cedula,
         column 48, mfe_factura_ter.nombre,
         column 82, msexo,
         column 100, mcat,
         column 125, mfe_factura_ter.edad USING "&&&" clipped,
         column 130, mfe_factura_m.nit,
         column 145, mnombre     
         
  --skip to top of page
end REPORT
REPORT terrprec_txtpp()
 define mnombre char(60)
 DEFINE mnom char(60)
 DEFINE mformap char(10)
 DEFINE mformapp,mformappp char(20)
 DEFINE mestado char(10)
 DEFINE mcat char(20)
 define msexo char(20)
   OUTPUT
    top margin 3
    bottom  margin 8
    left  margin 3
    right margin 240
    page length 66
 format
page header
 print column 1,"Fecha : ",today," + ",mtime,
       column 121,"Pag No. ",pageno using "####"
 skip 1 lines
 let mp1 = (132-length(mfe_empresa.razsoc clipped))/2
 print column mp1,mfe_empresa.razsoc
 print column 56,"DESAGREGADO COBERTURA POR FACTURACION DE :",mfecini," AL ",mfecfin
 skip 1 LINES
  
  print "------------------------------------------------------------------",
       "----------------------------------------------------------------------------",
       "----------------------------------------------"
 print column 01,"PREF",
        column 8,"NUM/FAC",
        column 20,"FE.FACTURA",
        COLUMN 32,"DOC.BENEF",
        COLUMN 60,"NOMBRE BENEFICIARIO",
        COLUMN 95, "SEXO",
        COLUMN 108,"EDAD",
        COLUMN 118,"CATEGO",
        column 132,"TERCERO",
        column 145,"NOMBRE TERCERO"
  print "------------------------------------------------------------------",
       "----------------------------------------------------------------------------",
       "---------------------------------------------"      
  on every row
   initialize mfe_terceros.* to null
   select * into mfe_terceros.* from fe_terceros 
    where nit=mfe_factura_m.nit
   IF mfe_terceros.tipo_persona="2" THEN 
    LET mnombre=NULL
    Let mnombre=mfe_terceros.primer_apellido CLIPPED," ",
                mfe_terceros.segundo_apellido CLIPPED," ",
                mfe_terceros.primer_nombre CLIPPED," ",
                mfe_terceros.segundo_nombre CLIPPED," "
   ELSE
    LET mnombre=NULL
    Let mnombre=mfe_terceros.razsoc CLIPPED
   END IF
   LET mformap=NULL
   LET mformapp=NULL
   LET mformappp=null   
   CASE
    when mfe_factura_m.forma_pago="1"
     LET mformap="CONTADO"
    when mfe_factura_m.forma_pago="2"
     LET mformap="CREDITO" 
   END CASE
   CASE 
    WHEN mfe_factura_ter.cat="A"
     LET mcat="CATEGORIA A"
    WHEN mfe_factura_ter.cat="B"
     LET mcat="CATEGORIA B"
    WHEN mfe_factura_ter.cat="C"
     LET mcat="CATEGORIA C"
    WHEN mfe_factura_ter.cat="D"
     LET mcat="CATEGORIA D"
    WHEN mfe_factura_ter.cat="E"
     LET mcat="CATEGORIA E"
   END CASE

   CASE 
    WHEN mfe_factura_ter.sexo="M"
     LET msexo="MASCULINO"
    WHEN mfe_factura_ter.sexo="F"
     LET msexo="FEMENINO"
   END CASE
   LET mnom=NULL
   LET mnom=mfe_factura_ter.nombre clipped 
    LET mnom=mfe_factura_ter.nombre CLIPPED 
  PRINT column 01, mfe_factura_m.prefijo,
         column 8, mfe_factura_m.numfac, 
         column 20, mfe_factura_m.fecha_factura,
         column 34, mfe_factura_ter.cedula,
         column 48, mfe_factura_ter.nombre,
         column 92, msexo,
         column 109, mfe_factura_ter.edad USING "&&&" clipped, 
         column 110, mcat[1,12],
         column 130, mfe_factura_m.nit,
         column 145, mnombre     
  ON LAST ROW       
   skip to top of page
end REPORT

FUNCTION rep_facturas_movi()
DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
DEFINE mcodpun CHAR(2)
DEFINE cnt INTEGER
DEFINE opp,ox,oxx CHAR(1)
DEFINE mprefijo char(5)
 let mprefijo=null
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null then 
  return
 end IF
 LET mfecini = NULL
 LET mfecfin = NULL
 let mdeftit="    RELACION DE FACTURAS "
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL confecr() RETURNING mfecini,mfecfin
 if mfecini is null or mfecfin is null then
   return
 end IF
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
 -- LET handler = configureOutputt("XLS","22cm","28cm",17,"1.5cm")
 LET handler = configureOutput_excel(90,"5.0cm","3.0cm","0.5cm","0.5cm","XLSX")
  --CALL ini_mensaje_espera("Generando Reporte ... Espere por favor...")
  START REPORT mterrprec_xlspp TO XML HANDLER HANDLER

   DECLARE mterppcurrec CURSOR FOR
   SELECT * FROM fe_factura_m
    WHERE fecha_elaboracion between mfecini and mfecfin
     AND prefijo=mprefijo
    ORDER BY prefijo,documento
   FOREACH mterppcurrec INTO mfe_factura_m.*
    DECLARE mtterppcurrec CURSOR FOR
    SELECT * FROM fe_factura_d
    WHERE prefijo=mfe_factura_m.prefijo AND documento=mfe_factura_m.documento 
     ORDER BY codigo
    FOREACH mtterppcurrec INTO mfe_factura_d.*
   
     OUTPUT TO REPORT mterrprec_xlspp()
    END FOREACH 
   END FOREACH
   
 finish report mterrprec_xlspp
 --let mdefnom="RELACION DE RECIBOS"
 --let mdeflet="condensed"
 --let mdeftam=66
 --let mhoja="9.5x11"
 --call impsn(nomrep,"S")
END FUNCTION


REPORT mterrprec_xlspp()
 define mnombre char(35)
 DEFINE mformap char(10)
 DEFINE mformapp,mformappp char(20)
 DEFINE mestado char(10)
 --output
  --top margin 3
  --bottom  margin 8
  --left  margin 0
  --right margin 240
  --page length 66
 format
  FIRST page HEADER
    
  print column 01,"PREFIJO",
        column 10,"DOCUMENTO",
        column 20,"FE.ELABORA",
        column 35,"TERCERO",
        column 60,"NOMBRE TERCERO",
        column 100,"ESTADO",
        COLUMN 110,"CODIGO",
        COLUMN 120,"DESCRIPCION",
        COLUMN 175,"CAT",
        COLUMN 180,"CANTI",
        COLUMN 190,"VALOR UNITARIO",
        COLUMN 210,"VALOR IVA",
        COLUMN 230,"VALOR IMPC",
        COLUMN 250,"VALOR SUBSI",
        COLUMN 270,"VALOR TOTAL"
        

  on every row
   initialize mfe_terceros.* to null
   select * into mfe_terceros.* from fe_terceros 
    where nit=mfe_factura_m.nit
   IF mfe_terceros.tipo_persona="2" THEN 
    LET mnombre=NULL
    Let mnombre=mfe_terceros.primer_apellido CLIPPED," ",
                mfe_terceros.segundo_apellido CLIPPED," ",
                mfe_terceros.primer_nombre CLIPPED," ",
                mfe_terceros.segundo_nombre CLIPPED," "
   ELSE
    LET mnombre=NULL
    Let mnombre=mfe_terceros.razsoc CLIPPED
   END IF
   initialize mfe_servicios.* to null
   select * into mfe_servicios.* from fe_servicios 
    where codigo=mfe_factura_d.codigo
   CASE  
    when mfe_factura_m.estado="B"
     LET mestado="BORRADOR"
    when mfe_factura_m.estado="A"
     LET mestado="APROBADA" 
   END case
   print column 01, mfe_factura_m.prefijo,
         column 10, mfe_factura_m.documento,
         column 20, mfe_factura_m.fecha_elaboracion,
         column 35, mfe_factura_m.nit,
         column 60, mnombre clipped,
         column 100, mestado,
         column 110, mfe_factura_d.codigo,
         column 120, mfe_servicios.descripcion clipped,
         column 175, mfe_factura_d.codcat,
         column 180, mfe_factura_d.cantidad USING "&&&&",
         column 190, mfe_factura_d.valoruni using "###,###,##&.&&",
         column 210, mfe_factura_d.iva using "###,###,##&.&&",
         column 230, mfe_factura_d.impc using "###,###,##&.&&",
         column 250, mfe_factura_d.subsi using "###,###,##&.&&",
         column 270, mfe_factura_d.valor using "###,###,##&.&&"
  --skip to top of page
end REPORT


--funcion para imprimir mas de una Factura 

function imprime_factu_rr()
DEFINE handler om.SaxDocumentHandler
 DEFINE mprefijo char(5)
 define ubicacion char(80)
 define mdooi,mdoof,cnt integer
 define mtotfacc like fe_factura_d.valoruni
 define mtotivaa like fe_factura_d.iva
 DEFINE op char(1)
 let mprefijo=null
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null then 
  return
 end if
 let mdo=null
 let mdooi=NULL
 let mdoof=null
 prompt "No. de Factura Inicial =====>> : " for mdooi
 if mdooi is null then 
  return
 end if
 let mdooi=mdooi using "&&&&&&&"
 if mdooi is null then 
  return
 end IF
  prompt "No. de Factura Final =====>> : " for mdoof
 if mdoof is null then 
  return
 end if
 let mdoof=mdoof using "&&&&&&&"
 if mdoof is null then 
  return
 end IF

 let op=3
 --prompt "Digite 1>Forma Preimpresa - 2>Hoja Blanca  3> PDF  =====>> : " for op
 --if op is null OR (op<>"1" AND op<>"2" AND op<>"3") then 
 -- return
 --end if
 if mdooi is not null then 
  MESSAGE  "Trabajando por favor espere ... " --AT 2,1
  let cnt=0
  select count(*) into cnt from fe_factura_m 
   where prefijo=mprefijo AND numfac BETWEEN mdooi AND mdoof
  if cnt is null then let cnt=0 end if
  if cnt=0 THEN
   CALL FGL_WINMESSAGE( "Administrador", " LA FACTURA DIGITADA NO EXISTE ", "stop")
   return
  else
   initialize mfe_factura_m.* to NULL
   DECLARE cur_factu_m CURSOR FOR 
    select *  from fe_factura_m 
     where prefijo=mprefijo AND numfac BETWEEN mdooi AND mdoof
    ORDER BY  numfac
   FOREACH cur_factu_m INTO mfe_factura_m.*
   if mfe_factura_m.estado<>"A" THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA FACTURA DIGITADA NO ESTA APROBADA ", "stop")
   -- return
   end IF
   END FOREACH  
  end if
 end if
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
let ubicacion=fgl_getenv("HOME"),"/reportes/factura_",mdo
let ubicacion=ubicacion CLIPPED
{IF fgl_report_loadCurrentSettings("factura.4rp") THEN -- if  the file 
   LET handler = fgl_report_commitCurrentSettings()     -- commit the file
   start report hrfactu_r TO XML HANDLER HANDLER
 END IF
}
--prueba
IF fgl_report_loadCurrentSettings("factura_r.4rp") THEN -- if  the file 
   LET handler = fgl_report_commitCurrentSettings()     -- commit the file
   start report hrfactu_rr TO XML HANDLER HANDLER
 END IF
initialize mfe_factura_m.* to NULL
DECLARE cur_fact_dd CURSOR FOR 
 SELECT  * INTO  mfe_factura_m.* FROM  fe_factura_m 
  where prefijo=mprefijo AND numfac BETWEEN mdooi AND mdoof
  --GROUP BY documento 
  ORDER BY documento 
  --ORDER BY numfac
FOREACH  cur_fact_dd INTO  mfe_factura_m.*
initialize mfe_prefijos.* to null
select * into mfe_prefijos.* from fe_prefijos 
where prefijo=mprefijo
let mtotfacc=0
let mtotivaa=0
select sum(fe_factura_d.iva*fe_factura_d.cantidad) into mtotivaa
 from fe_factura_d
where prefijo=mprefijo AND documento=mfe_factura_m.documento
IF mfe_prefijos.redondeo ="S" THEN
  LET mtotivaa=nomredondea(mtotivaa)
END IF
select sum(fe_factura_d.valor) into mtotfacc
  from fe_factura_d
 where prefijo=mprefijo 
   AND documento=mfe_factura_m.documento
 initialize mfe_terceros.* to NULL
 select * into mfe_terceros.* from fe_terceros 
  where nit=mfe_factura_m.nit
 initialize mgener09.* to NULL 
 SELECT * into mgener09.* FROM gener09
   WHERE codzon = mfe_terceros.zona
 initialize mfe_factura_d.* to NULL
 declare prfactu_rr cursor FOR
 select * from fe_factura_d
  where prefijo=mfe_factura_m.prefijo AND documento=mfe_factura_m.documento
  -- GROUP BY documento
   ORDER BY documento
   --order by codigo,subcodigo
 foreach prfactu_rr into mfe_factura_d.*
 -- DISPLAY  "fac DET ..",mfe_factura_d.*
   OUTPUT  TO  REPORT  hrfactu_rr(mfe_factura_m.*,mfe_factura_d.*,mtotfacc,mtotivaa)
 end FOREACH

END FOREACH 
 finish report hrfactu_rr
--finish report hrfactu_r
END FUNCTION

FUNCTION rep_facturas_ter2()
DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
DEFINE mcodser LIKE fe_servicios.codigo
DEFINE mcodpun CHAR(2)
DEFINE cnt INTEGER
DEFINE opp,ox,oxx CHAR(1)
DEFINE mprefijo char(5)
 let ubicacion=fgl_getenv("HOME"),"/reportes/facturas_terval"
 let ubicacion=ubicacion CLIPPED
 let mprefijo=NULL
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null THEN 
  RETURN
 end IF
 LET mfecini = NULL
 LET mfecfin = NULL
 let mdeftit="    RELACION DE FACTURAS "
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL confecr() RETURNING mfecini,mfecfin
 if mfecini is null or mfecfin is null then
   return
 end IF
 LET mtiprep = NULL
 PROMPT " Reporte  1. Texto   2. Excel : " for  mtiprep
 IF mtiprep <> "1" AND mtiprep <> "2" THEN
    RETURN
 END if  
 IF mtiprep ="1" THEN
  START REPORT terrprec_txtpp2 TO ubicacion
 ELSE
  LET handler = configureOutputt("XLS","22cm","28cm",17,"1.5cm")
  START REPORT terrprec_xlspp2 TO XML HANDLER HANDLER
 END IF
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
  DECLARE terppcurrec2 CURSOR FOR
   SELECT fe_factura_m.* 
   FROM fe_factura_m 
    WHERE fe_factura_m.prefijo = mprefijo 
    AND fe_factura_m.fecha_factura between mfecini and mfecfin
    AND (fe_factura_m.estado ="A" OR
      (fe_factura_m.estado ="N" AND fe_factura_m.fecest > mfecfin))
    ORDER BY fe_factura_m.numfac
   FOREACH terppcurrec2 INTO mfe_factura_m.*
    DECLARE tterppcurrec2 CURSOR FOR
    SELECT * FROM fe_factura_ter
    WHERE prefijo=mfe_factura_m.prefijo 
    AND documento=mfe_factura_m.documento
    AND valor > 0 
     ORDER BY cat
    FOREACH tterppcurrec2 INTO mfe_factura_ter.*
       IF mtiprep = "1" THEN
        OUTPUT TO REPORT terrprec_txtpp2()
      ELSE
        OUTPUT TO REPORT terrprec_xlspp2()
      END IF  
    END FOREACH 
   END FOREACH
 IF mtiprep ="1" THEN
   finish report terrprec_txtpp2
   let mdefnom="RELACION DE BENEFICIARIOS"
   let mdeflet="condensed"
   let mdeftam=66
   let mhoja="9.5x11"
   call impsn(ubicacion)
 ELSE
   finish report terrprec_xlspp2 
 END IF  
END FUNCTION
REPORT terrprec_xlspp2()
 define mnombre char(60)
 DEFINE mnom char(60)
 DEFINE mformap char(10)
 DEFINE mformapp,mformappp char(20)
 DEFINE mestado char(10)
 DEFINE mcat char(20)
 define msexo char(20)
 --output
  --top margin 3
  --bottom  margin 8
  --left  margin 0
  --right margin 240
  --page length 66
 format
  FIRST page HEADER
    
  print column 01,"PREF",
        column 8,"NUM/FAC",
        column 20,"FE.FACTURA",
        COLUMN 32,"DOC.BENEF",
        COLUMN 40,"NOMBRE BENEFICIARIO",
        COLUMN 75, "SEXO",
        COLUMN 87,"CATEGO",
        COLUMN 97,"EDAD",
        column 107,"TERCERO",
        column 125,"NOMBRE TERCERO"
  on every ROW
   IF mfe_factura_m.cedtra IS NULL THEN
     initialize mfe_terceros.* to NULL
     select * into mfe_terceros.* from fe_terceros 
      where nit=mfe_factura_m.nit
     IF mfe_terceros.tipo_persona="2" THEN 
      LET mnombre=NULL
      Let mnombre=mfe_terceros.primer_apellido CLIPPED," ",
                  mfe_terceros.segundo_apellido CLIPPED," ",
                  mfe_terceros.primer_nombre CLIPPED," ",
                  mfe_terceros.segundo_nombre CLIPPED," "
     ELSE
      LET mnombre=NULL
       Let mnombre=mfe_terceros.razsoc CLIPPED
     END IF
   ELSE
     INITIALIZE msubsi15.* TO NULL
     SELECT * INTO msubsi15.* 
       FROM subsi15
      WHERE cedtra = mfe_factura_m.cedtra   
      LET mnombre=NULL
      Let mnombre=msubsi15.priape CLIPPED," ", msubsi15.segape clipped, " ",
                  msubsi15.nombre CLIPPED
   END IF 
   LET mformap=NULL
   LET mformapp=NULL
   LET mformappp=null   
   CASE
    when mfe_factura_m.forma_pago="1"
     LET mformap="CONTADO"
    when mfe_factura_m.forma_pago="2"
     LET mformap="CREDITO" 
   END CASE
   CASE
    when mfe_factura_m.medio_pago="1"
     LET mformapp="EFECTIVO"
    when mfe_factura_m.medio_pago="2"
     LET mformapp="TARJETA CREDITO"
    when mfe_factura_m.medio_pago="3"
     LET mformapp="TARJETA DEBITO"
    when mfe_factura_m.medio_pago="4"
     LET mformapp="CONSIGNACION"
    when mfe_factura_m.medio_pago="5"
     LET mformapp="CHEQUE"
    when mfe_factura_m.medio_pago="6"
     LET mformapp="TRANSFERENCIA"
    when mfe_factura_m.medio_pago="7"
     LET mformapp="LIBRANZA"
   END CASE
   CASE
    when mfe_factura_m.franquicia="1"
     LET mformappp="VISA"
    when mfe_factura_m.franquicia="2"
     LET mformappp="MASTERCARD"
    when mfe_factura_m.franquicia="3"
     LET mformappp="DINERS"
    when mfe_factura_m.franquicia="4"
     LET mformappp="AMERICAN EXPRESS"
   END CASE 
   CASE 
    WHEN mfe_factura_ter.cat="A"
     LET mcat="CATEGORIA A"
    WHEN mfe_factura_ter.cat="B"
     LET mcat="CATEGORIA B"
    WHEN mfe_factura_ter.cat="C"
     LET mcat="CATEGORIA C"
    WHEN mfe_factura_ter.cat="D"
     LET mcat="CATEGORIA D"
    WHEN mfe_factura_ter.cat="E"
     LET mcat="CATEGORIA E"
   END CASE

   CASE 
    WHEN mfe_factura_ter.sexo="M"
     LET msexo="MASCULINO"
    WHEN mfe_factura_ter.sexo="F"
     LET msexo="FEMENINO"
   END CASE

   LET mnom=NULL
   LET mnom=mfe_factura_ter.nombre clipped 
 PRINT   column 01, mfe_factura_m.prefijo,
         column 8, mfe_factura_m.numfac, 
         column 20, mfe_factura_m.fecha_factura,
         column 34, mfe_factura_ter.cedula,
         column 48, mfe_factura_ter.nombre,
         column 82, msexo,
         column 100, mcat,
         column 123, mfe_factura_ter.edad USING "&&&" clipped,
         column 130, mfe_factura_m.nit,
         column 145, mnombre     
         
  --skip to top of page
end REPORT
REPORT terrprec_txtpp2()
 define mnombre char(45)
 DEFINE mnom char(60)
 DEFINE mformap char(10)
 DEFINE mformapp,mformappp char(20)
 DEFINE mestado char(10)
 DEFINE mcat char(12)
 define msexo char(10)
 DEFINE mtipidben char(1)
   OUTPUT
    top margin 3
    bottom  margin 8
    left  margin 3
    right margin 240
    page length 66
 format
page header
 print column 1,"Fecha : ",today," + ",mtime,
       column 165,"Pag No. ",pageno using "####"
 skip 1 lines
 let mp1 = (180-length(mfe_empresa.razsoc clipped))/2
 print column mp1,mfe_empresa.razsoc
 print column 50,"MICRODATO SUBSIDIO EN ESPECIE POR FACTURACION DE :",mfecini," AL ",mfecfin
 skip 1 LINES
  
  print "---------------------------------------------------------------------------",
        "----------------------------------------------------------------------------",
        "-----------------------------------------------"
 print column 01,"PREF",
        column 7,"NUM/FAC",
        column 16,"FE.FACTURA",
        COLUMN 30, "TI/D",
        COLUMN 36,"DOC.BENEF",
        COLUMN 57,"NOMBRE BENEFICIARIO",
        COLUMN 95, "SEXO",
        COLUMN 103,"CAT",
        COLUMN 108,"EDAD",
        COLUMN 126, "VALOR SUB", 
        column 140,"CED/AFIL ",
        column 155,"NOMBRE AFILIADO"
  print "---------------------------------------------------------------------------",
       "----------------------------------------------------------------------------",
       "--------------------------------------------------"      
  on every ROW
  IF mfe_factura_m.cedtra IS NULL then 
    initialize mfe_terceros.* to NULL
    select * into mfe_terceros.* from fe_terceros 
    where nit=mfe_factura_m.nit
    IF mfe_terceros.tipo_persona="2" THEN 
      LET mnombre=NULL
      Let mnombre=mfe_terceros.primer_apellido CLIPPED," ",
                 mfe_terceros.segundo_apellido CLIPPED," ",
                 mfe_terceros.primer_nombre CLIPPED," ",
                 mfe_terceros.segundo_nombre CLIPPED," "
     ELSE
      LET mnombre=NULL
      Let mnombre=mfe_terceros.razsoc CLIPPED
    END IF
    LET msubsi15.cedtra = mfe_factura_m.nit
  ELSE
     INITIALIZE msubsi15.* TO NULL
     SELECT * INTO msubsi15.* 
       FROM subsi15
      WHERE cedtra = mfe_factura_m.cedtra   
      LET mnombre=NULL
      Let mnombre=msubsi15.priape CLIPPED," ", msubsi15.segape clipped, " ",
                  msubsi15.nombre CLIPPED
   END IF
   LET mtipidben = NULL
   INITIALIZE msubsi15.* TO NULL 
    SELECT * INTO msubsi15.* FROM subsi15
     WHERE cedtra = mfe_factura_ter.cedula
   IF msubsi15.cedtra IS NOT NULL THEN
     LET mtipidben = msubsi15.coddoc
   END IF    
   IF mtipidben IS NULL THEN
    INITIALIZE msubsi20.* TO NULL 
    SELECT * INTO msubsi20.* FROM subsi20
     WHERE cedcon = mfe_factura_ter.cedula
     IF msubsi20.cedcon IS NOT NULL THEN
      LET mtipidben = "1"
     END IF    
   END IF
   IF mtipidben IS NULL THEN
    INITIALIZE msubsi22.* TO NULL 
    DECLARE cur_ben CURSOR FOR
    SELECT *  FROM subsi22
      WHERE subsi22.documento = mfe_factura_ter.cedula
    FOREACH cur_ben INTO msubsi22.*
     EXIT FOREACH
    END FOREACH   
    LET mtipidben = msubsi22.coddoc
   END IF     
   CASE  
     WHEN mtipidben ="8"
       LET mtipidben ="6"
     WHEN mtipidben ="10"
       LET mtipidben ="5" 
     WHEN mtipidben ="7"
       LET mtipidben ="3"
     WHEN mtipidben ="3"
       LET mtipidben ="7" 
     WHEN mtipidben ="6"
       LET mtipidben ="1" 
   END CASE   
   LET mformap=NULL
   LET mformapp=NULL
   LET mformappp=null   
   CASE 
    WHEN mfe_factura_ter.sexo="M"
     LET msexo="MASCULINO"
    WHEN mfe_factura_ter.sexo="F"
     LET msexo="FEMENINO"
   END CASE
   LET mnom=NULL
   LET mnom=mfe_factura_ter.nombre clipped 
    LET mnom=mfe_factura_ter.nombre CLIPPED 
   PRINT column 01, mfe_factura_m.prefijo,
         column 6, mfe_factura_m.numfac USING "------", 
         column 16, mfe_factura_m.fecha_factura,
         COLUMN 30, mtipidben,
         COLUMN 35, mfe_factura_ter.cedula CLIPPED,
         column 50, mfe_factura_ter.nombre,
         column 92, msexo,
         column 104, mfe_factura_ter.cat,
         column 109, mfe_factura_ter.edad USING "--&" clipped,
         COLUMN 115, mfe_factura_ter.valor USING "---,---,--&.--",
         column 138, mfe_factura_m.nit[1,12],
         column 145, mnombre     
  ON LAST ROW
  print "---------------------------------------------------------------------------",
       "----------------------------------------------------------------------------",
       "--------------------------------------------------"
  PRINT COLUMN 1, "TOTALES",     
   COLUMN 115, sum(mfe_factura_ter.valor) USING "---,---,--&.--"
   skip to top of page
end REPORT

function ssf_circular_002()
DEFINE handler om.SaxDocumentHandler
define mestad07 record like estadistica07.*
define cnt, mreg integer
define mfecnac date
define medad decimal(14,2)
DEFINE mprefijo char(5)
DEFINE msexo char(1)
define tp record
 edad integer,
 codser char(5),
 codcat char(2),
 sexo char(1),
 personas integer,
 usos integer,
 parti integer
end RECORD
--LLENADO DE MESES
 LET mregmes[1].nommes = "ENERO"
 LET mregmes[2].nommes = "FEBRERO"
 LET mregmes[3].nommes = "MARZO"
 LET mregmes[4].nommes = "ABRIL"
 LET mregmes[5].nommes = "MAYO"
 LET mregmes[6].nommes = "JUNIO"
 LET mregmes[7].nommes ="JULIO" 
 LET mregmes[8].nommes = "AGOSTO"
 LET mregmes[9].nommes = "SEPTIEMBRE"
 LET mregmes[10].nommes = "OCTUBRE"
 LET mregmes[11].nommes = "NOVIEMBRE"
 LET mregmes[12].nommes = "DICIEMBRE"
let mprefijo=null
prompt "Prefijo =====>> : " for mprefijo
LET mprefijo= upshift(mprefijo)
if mprefijo is null then 
 return
end if
LET mfecini = NULL
LET mfecfin = NULL
let mdeftit="    RELACION DE FACTURAS "
let mdefpro="Digite Rango de fechas" #23
let mdeffec1=today
let mdeffec2=today
CALL confecr() RETURNING mfecini,mfecfin
if mfecini is null or mfecfin is null then
 return
end IF
LET mmes = month(mfecini)
LET mnommes = mregmes[mmes].nommes
 create TEMP table mvilla3
 (
  edad integer,
  codser char(5),
  codcat char(2),
  sexo char(1),
  personas integer,
  usos integer,
  parti INTEGER,    
  prefijo CHAR(5),
  documento char(7),
  cedula char(20)
 )
 PROMPT "Formato del  Reporte  1-> Texto   2-> Excel  : " for  mtiprep
 IF mtiprep <> "1" AND mtiprep <> "2" THEN
    RETURN
 END if 
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
 let ubicacion=fgl_getenv("HOME"),"/reportes/coberssf"
 let ubicacion=ubicacion CLIPPED
 IF mtiprep = "1" THEN
   START REPORT nuerep_resumen_ssf TO ubicacion
 ELSE
   LET handler = configureOutput_excel(90,"5.0cm","3.0cm","0.5cm","0.5cm","XLSX")
   START REPORT nuerep_resumen_ssf TO  XML HANDLER HANDLER
 END IF  
 LET mreg = 0
 initialize mfe_factura_m.* to null
declare cr_circular002 cursor for
 SELECT  fe_factura_m.* from fe_factura_m 
   WHERE fe_factura_m.prefijo=mprefijo 
   and fe_factura_m.fecha_factura>=mfecini 
   and fe_factura_m.fecha_factura<=mfecfin
   and (fe_factura_m.estado="A" OR
      (fe_factura_m.estado ="N" AND fe_factura_m.fecest > mfecfin))
 Foreach cr_circular002 into mfe_factura_m.*
 declare cr_cir002 cursor for
 select * from fe_factura_d, fe_servicios
   where fe_factura_d.prefijo=mfe_factura_m.prefijo
     and fe_factura_d.documento=mfe_factura_m.documento
     AND fe_servicios.codigo=fe_factura_d.codigo
     AND fe_servicios.cobertura <> "0"
  order by fe_factura_d.codigo
 foreach cr_cir002 into mfe_factura_d.*, mfe_servicios.*
  DISPLAY "factura ", mfe_factura_m.prefijo,"-", mfe_factura_m.numfac,
   " Servicio : ", mfe_factura_d.codigo,
   " tipo cobertura : ", mfe_servicios.cobertura, " Cat: ", mfe_factura_d.codcat
 CASE 
  WHEN mfe_servicios.cobertura="1"            --- DETALLA NUCLEO FAMILIAR
    LET cnt=0
    LET medad = 0
    LET msexo = 0
    SELECT count(*) INTO cnt FROM fe_factura_ter
      where prefijo=mfe_factura_m.prefijo
      and documento=mfe_factura_m.documento
    IF cnt IS NULL THEN LET cnt=0 END IF
    IF cnt=0 THEN      
      DISPLAY " NO SE DETALLO NUCLEO FACTURA ", mfe_factura_m.numfac 
      IF mfe_factura_m.cedtra IS NULL THEN
        initialize msubsi15.* to NULL
         select * into msubsi15.* from subsi15 
         where cedtra=mfe_factura_m.nit
        let mfecnac=msubsi15.fecnac
        let msexo=msubsi15.sexo
        let medad=0
        let medad=mfecfin-mfecnac
        let medad=medad/(365.25)
      ELSE
        initialize msubsi15.* to NULL
        select * into msubsi15.* from subsi15 
         where cedtra=mfe_factura_m.cedtra
        let mfecnac=msubsi15.fecnac
        let msexo=msubsi15.sexo
        let medad=0
        let medad=mfecfin-mfecnac
        let medad=medad/(365.25) 
      END IF 
      initialize mestad07.* to NULL
      declare cireven04 cursor FOR
      select * from estadistica07 order by codigo ASC
      foreach cireven04 into mestad07.*
        if medad<=mestad07.totfin THEN
        exit FOREACH
       end IF
      end FOREACH
      IF mprefijo = "EDUC" OR mprefijo = "EDUP" OR mprefijo = "EDUO" THEN
        LET mnommes2= NULL
        CALL validarmes_col() 
        IF mnommes <> mnommes2 THEN
          CONTINUE FOREACH
        END IF
      END IF  
      insert into mvilla3 (edad, codser, codcat, sexo, personas,
      usos, parti, prefijo, documento, cedula )
      values ( mestad07.codigo, mfe_factura_d.codigo,
      mfe_factura_d.codcat, msexo, 1, 1, 
      0, mfe_factura_m.prefijo, mfe_factura_m.documento, mfe_factura_m.nit)
    ELSE
     initialize mfe_factura_ter.* to NULL
     declare dxcireven04 cursor FOR
     select * from fe_factura_ter
      where prefijo=mfe_factura_m.prefijo
      and documento=mfe_factura_m.documento
      --AND cat = mfe_factura_d.codcat
     foreach dxcireven04 into mfe_factura_ter.*
       LET mreg = mreg + 1
       initialize mestad07.* to NULL
       declare xcireven04 cursor FOR
       select * from estadistica07 order by codigo ASC
       foreach xcireven04 into mestad07.*
         if mfe_factura_ter.edad<=mestad07.totfin THEN
           exit FOREACH
         end IF
       end FOREACH
       IF mprefijo = "EDUC" OR mprefijo = "EDUP" OR mprefijo = "EDUO" THEN
         LET mnommes2= NULL
         CALL validarmes_col() 
         IF mnommes <> mnommes2 THEN
          CONTINUE FOREACH
         END IF
       END IF  
       LET cnt=0
       SELECT count(*) INTO cnt FROM mvilla3
       where prefijo=mfe_factura_m.prefijo
       and documento=mfe_factura_m.documento
       AND cedula=mfe_factura_ter.cedula
       IF cnt IS NULL THEN LET cnt=0 END IF
       IF cnt=0 THEN  
         insert into mvilla3 ( edad, codser, codcat, sexo, 
          personas, usos, parti, prefijo, documento, cedula )
         values ( mestad07.codigo, mfe_factura_d.codigo,
          mfe_factura_ter.cat, mfe_factura_ter.sexo,
          1, 1, 0, mfe_factura_m.prefijo, 
          mfe_factura_m.documento, mfe_factura_ter.cedula)
       ELSE
        insert into mvilla3 ( edad, codser, codcat, sexo, 
          personas, usos, parti, prefijo, documento, cedula )
         values ( mestad07.codigo, mfe_factura_d.codigo,
          mfe_factura_ter.cat, mfe_factura_ter.sexo,
          0, 1, 0, mfe_factura_m.prefijo, 
          mfe_factura_m.documento, mfe_factura_ter.cedula)   
       END IF
     END FOREACH
   END IF 
  WHEN mfe_servicios.cobertura="2"    --- PARTICIPANTES.
  let msexo=0
  let medad=0
  IF mfe_factura_m.cedtra IS NULL THEN
     initialize msubsi15.* to NULL
      select * into msubsi15.* from subsi15 
      where cedtra=mfe_factura_m.nit
      let mfecnac=msubsi15.fecnac
      let msexo=msubsi15.sexo
      let medad=0
      let medad=mfecfin-mfecnac
      let medad=medad/(365.25)
    ELSE
     initialize msubsi15.* to NULL
      select * into msubsi15.* from subsi15 
       where cedtra=mfe_factura_m.cedtra
      let mfecnac=msubsi15.fecnac
      let msexo=msubsi15.sexo
      let medad=0
      let medad=mfecfin-mfecnac
      let medad=medad/(365.25)
    END IF 
   initialize mestad07.* to NULL
   declare cir04 cursor FOR
   select * from estadistica07 order by codigo ASC
    foreach cir04 into mestad07.*
      if medad<=mestad07.totfin THEN
       exit FOREACH
     end IF
    end FOREACH
    insert into mvilla3 ( edad, codser, codcat, sexo, personas,
       usos, parti, prefijo, documento, cedula )
     values ( mestad07.codigo, mfe_factura_d.codigo,
      mfe_factura_d.codcat, msexo, 1,  
      0, mfe_factura_m.parti, mfe_factura_m.prefijo, 
      mfe_factura_m.documento, mfe_factura_m.nit)
  END CASE
 end FOREACH
end FOREACH
####################################
DISPLAY " registros procesados ", mreg
initialize tp.* to NULL
SELECT UNIQUE cedula, edad, codser, codcat, sexo, 1 personas, 
 sum(usos) usos, sum(parti) parti
  FROM mvilla3
  GROUP BY cedula, edad, codser, codcat, sexo
 INTO TEMP mvilla3_consol 
declare cr_cir003 cursor for
select edad, codser, codcat, sexo,sum(personas),sum(usos), sum(parti)
  from mvilla3_consol
 group by edad, codser, codcat, sexo
 order by codser, codcat, edad, sexo
foreach cr_cir003 into tp.*
 output to report nuerep_resumen_ssf(tp.*,mprefijo)
end foreach
finish report nuerep_resumen_ssf
IF mtiprep = "1" THEN
  call impsn(ubicacion)
END IF  
drop table mvilla3
DROP TABLE mvilla3_consol
end FUNCTION

FUNCTION validarmes_col() 
 LET mnommes2 = NULL
 FOR i = 14 TO 400
  IF mfe_factura_m.nota1[i,i] <> " " THEN
   LET mnommes2 = mnommes2 clipped,  mfe_factura_m.nota1[i,i]
  ELSE
    EXIT FOR 
  END IF 
 END FOR
END FUNCTION

report nuerep_resumen_ssf(tp,mprefijo)
DEFINE mprefijo char(5)
define op char(1)
define mcaja char(2)
define cnt,musuario integer
define mtitulo char(100)
define msexo,mcat char(1)
define mcatt char(2)
DEFINE mvilla_catego RECORD LIKE villa_catego.*
define tp record
 edad integer,
 codser char(5),
 codcat char(2),
 sexo char(1),
 personas integer,
 usos integer,
 parti integer
end RECORD
 OUTPUT
  top margin 1
   bottom margin 1
   left margin 0 
   right margin 132
   page length 66
format
 page HEADER
 let mtime=time
 print column 1,"fecha : ",today," + ",mtime,
       column 121,"pag no. ",pageno using "####"
 skip 1 lines
 let mp1 = (132-length(mfe_empresa.razsoc clipped))/2
 print column mp1,mfe_empresa.razsoc
 skip 1 LINES
 print column 01,"REPORTE ESTADISTICO DE CORTE : ",mfecini," AL ",mfecfin, 
  " PARA EL PREFIJO : ", mprefijo 
 print "------------------------------------------------------------------",
       "------------------------------------------------------------------",
       "---------------------------------"
  print  column 01,"EDAD",
         column 10,"SEXO",
         column 20,"SERVICIO",
         column 30,"DESCRIPCION SERVICIO",
         column 85,"CATEGO",
         column 95,"DESCRIPCION CATEGORIA",
         column 130,"#PERSONAS",
         column 140,"USOS",
         column 150,"PARTI"
print "------------------------------------------------------------------",
      "------------------------------------------------------------------",
      "---------------------------------"
on every row
 initialize mfe_servicios.* to null
 select * into mfe_servicios.* from fe_servicios
  where codigo=tp.codser
 let mcat=NULL
 let mcatt=null
 case
  when tp.codcat="A"
   let mcat="1"
   let mcatt="01"
  when tp.codcat="B"
   let mcat="2"
   let mcatt="02"
  when tp.codcat="C"
   let mcat="3"
   let mcatt="03"
  when tp.codcat="D"
   let mcat="4"
   let mcatt="04"
  when tp.codcat="E"
   let mcat="5"
   let mcatt="05" 
 end case 
 initialize mvilla_catego.* to null
 select * into mvilla_catego.* from villa_catego
  where codigo=mcatt
 IF mcatt = "05" THEN
   LET mvilla_catego.descripcion   = "EMPRESA"
 END if 
 let msexo=null
 if tp.sexo="M" then
  let tp.sexo="1"
 else
  if tp.sexo="F" then
   let tp.sexo="2"
  else
   let tp.sexo="0"
  end if
 end if
  print column 04,tp.edad USING "##",
        column 11,tp.sexo USING "##",
        column 20,tp.codser,
        column 30,mfe_servicios.descripcion,
        column 85,mcat,
        column 95,mvilla_catego.descripcion,
        column 130,tp.personas using "&&&&&",
        column 140,tp.usos using "&&&&&",
        column 150,tp.parti using "&&&&&"
ON last row
 SKIP 2 LINES
  PRINT COLUMN 10,"TOTALES.....",
       COLUMN 130,SUM(tp.personas) using "&&&&&",
       COLUMN 140,SUM(tp.usos) using "&&&&&",
       COLUMN 150,SUM(tp.parti) using "&&&&&&"
 skip to top of page
end REPORT

function consol_coberturas()
DEFINE handler om.SaxDocumentHandler
define mestad07 record like estadistica07.*
define cnt, mreg integer
define mfecnac date
define medad decimal(14,2)
DEFINE mprefijo char(5)
DEFINE msexo char(1)
define tp RECORD
 prefijo char(4),
 edad integer,
 codser char(2),
 codcat char(2),
 sexo char(1),
 personas integer,
 usos integer,
 parti integer
end RECORD
LET mfecini = NULL
LET mfecfin = NULL
let mdeftit="    RELACION DE FACTURAS "
let mdefpro="Digite Rango de fechas" #23
let mdeffec1=today
let mdeffec2=today
CALL confecr() RETURNING mfecini,mfecfin
if mfecini is null or mfecfin is null then
 return
end IF
 create TEMP table mvilla3
 (
  edad integer,
  codser char(2),
  codcat char(2),
  sexo char(1),
  personas integer,
  usos integer,
  parti INTEGER,    
  prefijo CHAR(5),
  documento char(7),
  cedula char(20)
 )
 PROMPT "Formato del  Reporte  1-> Texto   2-> Excel  : " for  mtiprep
 IF mtiprep <> "1" AND mtiprep <> "2" THEN
    RETURN
 END if 
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
 let ubicacion=fgl_getenv("HOME"),"/reportes/concober"
 let ubicacion=ubicacion CLIPPED
 IF mtiprep = "1" THEN
   START REPORT cobrep_resumen_ssf TO ubicacion
 ELSE
   LET handler = configureOutput_excel(90,"5.0cm","3.0cm","0.5cm","0.5cm","XLSX")
   START REPORT cobrep_resumen_ssf TO  XML HANDLER HANDLER
 END IF  
 LET mreg = 0
initialize mfe_factura_m.* to null
declare cr_cob002 cursor for
 SELECT  fe_factura_m.* from fe_factura_m 
   WHERE fe_factura_m.fecha_factura>=mfecini 
   and fe_factura_m.fecha_factura<=mfecfin
   and (fe_factura_m.estado="A" OR
      (fe_factura_m.estado ="N" AND fe_factura_m.fecest > mfecfin))
 Foreach cr_cob002 into mfe_factura_m.*
 declare cr_cob02 cursor for
 select * from fe_factura_d,  fe_servicios, est_servicios
   where fe_factura_d.prefijo=mfe_factura_m.prefijo
     and fe_factura_d.documento=mfe_factura_m.documento
     AND fe_servicios.codigo=fe_factura_d.codigo
     AND fe_servicios.codser_sf = est_servicios.codsersf
     AND fe_servicios.cobertura <> "0"
     AND fe_servicios.codser_sf <> "0"
  order by fe_factura_d.codigo
 foreach cr_cob02 into mfe_factura_d.*, mfe_servicios.*, mest_servicios.*
  DISPLAY "factura ", mfe_factura_m.prefijo,"-", mfe_factura_m.numfac,
   " Servicio : ", mfe_factura_d.codigo,
   " tipo cobertura : ", mfe_servicios.cobertura, " Cat: ", mfe_factura_d.codcat
 CASE 
  WHEN mfe_servicios.cobertura="1"            --- DETALLA NUCLEO FAMILIAR
    LET cnt=0
    LET medad = 0
    LET msexo = 0
    SELECT count(*) INTO cnt FROM fe_factura_ter
      where prefijo=mfe_factura_m.prefijo
      and documento=mfe_factura_m.documento
    IF cnt IS NULL THEN LET cnt=0 END IF
    IF cnt=0 THEN                        --- NO SE DETALLO NUCLEO
      IF mfe_factura_m.cedtra IS NULL THEN
        initialize msubsi15.* to NULL
         select * into msubsi15.* from subsi15 
         where cedtra=mfe_factura_m.nit
        let mfecnac=msubsi15.fecnac
        let msexo=msubsi15.sexo
        let medad=0
        let medad=mfecfin-mfecnac
        let medad=medad/(365.25)
      ELSE
        initialize msubsi15.* to NULL
        select * into msubsi15.* from subsi15 
         where cedtra=mfe_factura_m.cedtra
        let mfecnac=msubsi15.fecnac
        let msexo=msubsi15.sexo
        let medad=0
        let medad=mfecfin-mfecnac
        let medad=medad/(365.25) 
      END IF 
      initialize mestad07.* to NULL
      declare circob04 cursor FOR
      select * from estadistica07 order by codigo ASC
      foreach circob04 into mestad07.*
        if medad<=mestad07.totfin THEN
        exit FOREACH
       end IF
      end FOREACH
      insert into mvilla3 (edad, codser, codcat, sexo, personas,
      usos, parti, prefijo, documento, cedula )
      values ( mestad07.codigo, mest_servicios.codsersf, 
      mfe_factura_d.codcat, msexo, 1, 1, 0, mfe_factura_m.prefijo,
      mfe_factura_m.documento, mfe_factura_m.nit)
   ELSE
     initialize mfe_factura_ter.* to NULL
     declare dcireven04 cursor FOR
     select * from fe_factura_ter
      where prefijo=mfe_factura_m.prefijo
      and documento=mfe_factura_m.documento
      AND cat = mfe_factura_d.codcat
     foreach dcireven04 into mfe_factura_ter.*
       LET mreg = mreg + 1
       initialize mestad07.* to NULL
       declare xcirven04 cursor FOR
       select * from estadistica07 order by codigo ASC
       foreach xcirven04 into mestad07.*
         if mfe_factura_ter.edad<=mestad07.totfin THEN
           exit FOREACH
         end IF
       end FOREACH
       LET cnt=0
       SELECT count(*) INTO cnt FROM mvilla3
       where prefijo=mfe_factura_m.prefijo
       and documento=mfe_factura_m.documento
       AND cedula=mfe_factura_ter.cedula
       IF cnt IS NULL THEN LET cnt=0 END IF
       IF cnt=0 THEN  
         insert into mvilla3 ( edad, codser, codcat, sexo, 
          personas, usos, parti, prefijo, documento, cedula )
         values ( mestad07.codigo, mest_servicios.codsersf, 
          mfe_factura_ter.cat, mfe_factura_ter.sexo,
          1, 1, 0, mfe_factura_m.prefijo, 
          mfe_factura_m.documento, mfe_factura_ter.cedula)
       END IF
     END FOREACH
   END IF 
  WHEN mfe_servicios.cobertura="2"    --- PARTICIPANTES.
  let msexo=0
  let medad=0
  IF mfe_factura_m.cedtra IS NULL THEN
     initialize msubsi15.* to NULL
      select * into msubsi15.* from subsi15 
      where cedtra=mfe_factura_m.nit
      let mfecnac=msubsi15.fecnac
      let msexo=msubsi15.sexo
      let medad=0
      let medad=mfecfin-mfecnac
      let medad=medad/(365.25)
    ELSE
     initialize msubsi15.* to NULL
      select * into msubsi15.* from subsi15 
       where cedtra=mfe_factura_m.cedtra
      let mfecnac=msubsi15.fecnac
      let msexo=msubsi15.sexo
      let medad=0
      let medad=mfecfin-mfecnac
      let medad=medad/(365.25)
    END IF 
   initialize mestad07.* to NULL
   declare cobcir04 cursor FOR
   select * from estadistica07 order by codigo ASC
    foreach cobcir04 into mestad07.*
      if medad<=mestad07.totfin THEN
       exit FOREACH
     end IF
    end FOREACH
    insert into mvilla3 ( edad, codser, codcat, sexo, personas,
       usos, parti, prefijo, documento, cedula )
     values ( mestad07.codigo, mest_servicios.codsersf, 
      mfe_factura_d.codcat, msexo, 1,  
      0, mfe_factura_m.parti, mfe_factura_m.prefijo, 
      mfe_factura_m.documento, mfe_factura_m.nit)
  END CASE
 end FOREACH
end FOREACH
####################################
DISPLAY " registros procesados ", mreg
initialize tp.* to NULL
SELECT UNIQUE prefijo, cedula, edad, codser, codcat, sexo, 1 personas, 
 sum(usos) usos, sum(parti) parti
  FROM mvilla3
  GROUP BY  prefijo, cedula, edad, codser, codcat, sexo
 INTO TEMP mvilla3_consol 
declare cr_cobcir003 cursor for
select prefijo, edad, codser, codcat, sexo,sum(personas),sum(usos), sum(parti)
  from mvilla3_consol
 group by prefijo, edad, codser, codcat, sexo
 order by codser, prefijo, codcat, edad, sexo
foreach cr_cobcir003 into tp.*
 output to report cobrep_resumen_ssf(tp.*)
end foreach
finish report cobrep_resumen_ssf
IF mtiprep = "1" THEN
  call impsn(ubicacion)
END IF  
drop table mvilla3
DROP TABLE mvilla3_consol
end function

report cobrep_resumen_ssf(tp)
define op char(1)
define mcaja char(2)
define cnt,musuario integer
define mtitulo char(100)
define msexo,mcat char(1)
define mcatt char(2)
DEFINE mvilla_catego RECORD LIKE villa_catego.*
define tp RECORD
 prefijo char(4),
 edad integer,
 codser char(2),
 codcat char(2),
 sexo char(1),
 personas integer,
 usos integer,
 parti integer
end RECORD
 OUTPUT
  top margin 1
   bottom margin 1
   left margin 0 
   right margin 132
   page length 66
format
 page HEADER
 let mtime=time
 print column 1,"fecha : ",today," + ",mtime,
       column 121,"pag no. ",pageno using "####"
 skip 1 lines
 let mp1 = (132-length(mfe_empresa.razsoc clipped))/2
 print column mp1,mfe_empresa.razsoc
 skip 1 LINES
 print column 01,"REPORTE COBERTURAS DE CORTE : ",mfecini," AL ",mfecfin 
 print "------------------------------------------------------------------",
       "------------------------------------------------------------------",
       "---------------------------------"
  PRINT COLUMN 01, "PREF",
        column 07,"SERV",
        column 35,"DESCRIPCION SERVICIO",
        column 55,"CATEG",
        column 70,"DESCRIPCION CATEGORIA",   
        column 95,"EDAD",
        column 103,"SEXO",
        column 111,"#PERSONAS",
        column 121,"USOS",
        column 131,"PARTI"
print "------------------------------------------------------------------",
      "------------------------------------------------------------------",
      "---------------------------------"
on every row
 initialize mest_servicios.* to null
 select * into mest_servicios.* from est_servicios
  where codsersf=tp.codser
 let mcat=NULL
 let mcatt=null
 case
  when tp.codcat="A"
   let mcat="1"
   let mcatt="01"
  when tp.codcat="B"
   let mcat="2"
   let mcatt="02"
  when tp.codcat="C"
   let mcat="3"
   let mcatt="03"
  when tp.codcat="D"
   let mcat="4"
   let mcatt="04"
  when tp.codcat="E"
   let mcat="5"
   let mcatt="05" 
 end case 
 initialize mvilla_catego.* to null
 select * into mvilla_catego.* from villa_catego
  where codigo=mcatt
 IF mcatt = "05" THEN
   LET mvilla_catego.descripcion   = "EMPRESA"
 END if 
 let msexo=null
 if tp.sexo="M" then
  let tp.sexo="1"
 else
  if tp.sexo="F" then
   let tp.sexo="2"
  else
   let tp.sexo="0"
  end if
 end if
  PRINT COLUMN 01 ,tp.prefijo, 
        column 8,tp.codser,
        column 12,mest_servicios.nombresf,
        column 57,mcat,
        column 60,mvilla_catego.descripcion, 
        column 96,tp.edad USING "##",
        column 104,tp.sexo USING "##",
        column 112,tp.personas using "&&&&&",
        column 122,tp.usos using "&&&&&",
        column 132,tp.parti using "&&&&&"
ON last row
 SKIP 2 LINES
  PRINT COLUMN 10,"TOTALES.....",
       COLUMN 112,SUM(tp.personas) using "&&&&&",
       COLUMN 122,SUM(tp.usos) using "&&&&&",
       COLUMN 132,SUM(tp.parti) using "&&&&&&"
 skip to top of page
end REPORT

FUNCTION resing_tarifas()
DEFINE handler om.SaxDocumentHandler
define cnt, mreg integer
DEFINE mprefijo char(5)
DEFINE mvaling decimal(12,2)
define tp RECORD
 prefijo char(4),
 codserssf  char(2),
 codser char(5),
 codcat char(2),
 valor decimal(12,2), 
 auxiliar char(12)
end RECORD
DEFINE mauxiliar char(12)
LET mfecini = NULL
LET mfecfin = NULL
let mdeftit="  INGRESO POR TARIFAS    "
let mdefpro="Digite Rango de fechas" #23
let mdeffec1=today
let mdeffec2=today
CALL confecr() RETURNING mfecini,mfecfin
if mfecini is null or mfecfin is null then
 return
end IF
 create TEMP table consoling
 (
  codser char(5),
  codserssf char(2),
  codcat char(2),
  valor decimal(12,2),
  prefijo CHAR(5),
  auxiliar char(12)
 )
 PROMPT "Formato del  Reporte  1-> Texto   2-> Excel  : " for  mtiprep
 IF mtiprep <> "1" AND mtiprep <> "2" THEN
    RETURN
 END IF 

 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
 let ubicacion=fgl_getenv("HOME"),"/reportes/ingtarifas"
 let ubicacion=ubicacion CLIPPED
 IF mtiprep = "1" THEN
   START REPORT resumentar_ssf2 TO ubicacion
 ELSE
   LET handler = configureOutput_excel(90,"5.0cm","3.0cm","0.5cm","0.5cm","XLSX")
   START REPORT resumentar_ssf2 TO  XML HANDLER HANDLER
 END IF  
 LET mreg = 0
initialize mfe_factura_m.* to null
declare cr_tar002 cursor for
 SELECT  fe_factura_m.* from fe_factura_m 
   WHERE fe_factura_m.fecha_factura BETWEEN mfecini AND mfecfin
     and fe_factura_m.estado IN ("A" ,"N") 
  Foreach cr_tar002 into mfe_factura_m.*
 LET mvaling = 0
 declare cr_tar02 cursor for
 select * from fe_factura_d,  fe_servicios
   where fe_factura_d.prefijo=mfe_factura_m.prefijo
     and fe_factura_d.documento=mfe_factura_m.documento
     AND fe_servicios.codigo=fe_factura_d.codigo
  order by fe_factura_d.codigo
 foreach cr_tar02 into mfe_factura_d.*, mfe_servicios.*
  DISPLAY "factura ", mfe_factura_m.prefijo,"-", mfe_factura_m.numfac,
   " Servicio : ", mfe_factura_d.codigo
   INITIALIZE mest_servicios.* TO NULL
   SELECT * INTO mest_servicios.*
    FROM est_servicios
     WHERE codsersf = mfe_servicios.codser_sf
   LET mauxiliar = NULL
   SELECT auxiliaring INTO mauxiliar
     FROM fe_conta1
   WHERE codigo = mfe_servicios.codigo
   IF mfe_factura_d.cod_bene = "01" THEN
     LET mvaling = (mfe_factura_d.valoruni * mfe_factura_d.cantidad) - 
     mfe_factura_d.subsi - mfe_factura_d.valorbene
  ELSE
    LET mvaling = (mfe_factura_d.valoruni * mfe_factura_d.cantidad) - 
     mfe_factura_d.subsi 
  END IF  
  insert into consoling (codser, codserssf, codcat, valor, prefijo, auxiliar )
    values ( mfe_factura_d.codigo, mest_servicios.codsersf, mfe_factura_d.codcat, mvaling, 
    mfe_factura_m.prefijo, mauxiliar)
 END FOREACH   
END FOREACH 
declare cr_ing003 cursor for
select prefijo, codserssf, codser, codcat, sum(valor), auxiliar
  from consoling
 group by prefijo, codserssf, codser, codcat, auxiliar
 order by auxiliar, codserssf, codser, prefijo, codcat
foreach cr_ing003 into tp.*
 output to report resumentar_ssf2(tp.*)
end foreach
finish report resumentar_ssf2
IF mtiprep = "1" THEN
  call impsn(ubicacion)
END IF  
drop table consoling
END FUNCTION

report resumentar_ssf2(tp)
define op char(1)
define mcaja char(2)
define cnt,musuario integer
define mtitulo char(100)
define mcatt, mcat char(2)
define tp RECORD
 prefijo char(4),
 codserssf  char(2),
 codser char(5),
 codcat char(2),
 valor decimal(12,2), 
 auxiliar char(12)
end RECORD
 OUTPUT
  top margin 0
   bottom margin 0
   left margin 0 
   right margin 132
   page length 66
format
 FIRST page HEADER
 SKIP 2 lines
 let mtime=time
 print column 1,"fecha : ",today," + ",mtime,
       column 110,"pag no. ",pageno using "####"
 skip 1 lines
 let mp1 = (122-length(mfe_empresa.razsoc clipped))/2
 print column mp1,mfe_empresa.razsoc
 skip 1 LINES
 print column 01,"REPORTE INGRESOS POR TARIFAS DE CORTE : ",mfecini," AL ",mfecfin 
 print "------------------------------------------------------------------",
       "------------------------------------------------------------------",
       "-----------------------------------"
 PRINT COLUMN 01, "PREF",
        column 07,"S/SSF",
        COLUMN 15, "SERV",
        COLUMN 35, "DESC. SERVICIO SSF ",
        column 65,"DESCRIPCION SERVICIO FACT",
        column 105,"CAT",   
        column 125,"TOTAL/INGRESOS",
        COLUMN 142," AUXILIAR "
 print "------------------------------------------------------------------",
       "------------------------------------------------------------------",
       "-----------------------------------"     
on every ROW
   initialize mest_servicios.* to NULL
   select * into mest_servicios.* from est_servicios
   where codsersf=tp.codserssf
  INITIALIZE mfe_servicios.* TO NULL
  SELECT * INTO mfe_servicios.* FROM fe_servicios
  WHERE codigo = tp.codser
 let mcat=NULL
 let mcatt=null
 PRINT COLUMN 01 ,tp.prefijo, 
        column 9,tp.codserssf,
        COLUMN 13,tp.codser,
        column 20,mest_servicios.nombresf,
        column 61,mfe_servicios.descripcion clipped,
        column 106,tp.codcat,
        COLUMN 123,tp.valor USING "---,---,---,--&.&&",
        COLUMN 145,tp.auxiliar 
ON last row
 SKIP 2 LINES
  PRINT COLUMN 10,"TOTALES.....",
       COLUMN 123,SUM(tp.valor) USING "---,---,---,--&.&&"
 skip to top of page
end REPORT

FUNCTION subdem_ssf()
  DEFINE handler om.SaxDocumentHandler
  define cnt, mreg INTEGER
  DEFINE mprefijo char(5)
  DEFINE mtipor char(1)
  define tp RECORD
    prefijo char(4),
    codsf char(2),
    codser char(5),
    codcat char(2),
    valor decimal(12,2),
    valpag decimal(12,2),
    cant integer,
    cantdev integer
  end RECORD
  LET mfecini = NULL
  LET mfecfin = NULL
  let mdeftit="        SUBSIDIO A LA DEMANDA      "
  let mdefpro="Digite Rango de fechas" #23
  let mdeffec1=TODAY
  let mdeffec2=TODAY
  CALL confecr() RETURNING mfecini,mfecfin
  if mfecini is null or mfecfin is null THEN
   RETURN
  end IF
 create TEMP table subsidiod
 (
  numfac char(7),
  prefijo CHAR(4),
  codssf  char(2),
  codser  char(5),  
  codcat char(2),
  valor decimal(12,2),
  cant  integer,
  valpag decimal(12,2),
  cantdev integer
 )
 LET mtipor = NULL
 PROMPT "Digite     1. General   2. Por prefijo : " FOR mtipor
 IF mtipor <> "1" AND mtipor <> "2" THEN
    RETURN
 END IF
 LET mtiprep = NULL
 PROMPT "Formato del  Reporte  1-> Texto   2-> Excel  : " for  mtiprep
 IF mtiprep <> "1" AND mtiprep <> "2" THEN
    RETURN
 END IF 
 IF mtipor = "2" THEN 
   LET mprefijo = NULL
   prompt "Prefijo =====>> : " for mprefijo
   LET mprefijo= upshift(mprefijo)
   if mprefijo is null THEN 
    RETURN
   end IF
 END IF  
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
 let ubicacion=fgl_getenv("HOME"),"/reportes/subdemanda"
 let ubicacion=ubicacion CLIPPED
 IF mtiprep = "1" THEN
   START REPORT repo_subdemanda TO ubicacion
 ELSE
   LET handler = configureOutput_excel(90,"5.0cm","3.0cm","0.5cm","0.5cm","XLSX")
   START REPORT repo_subdemanda TO XML HANDLER HANDLER
 END IF
LET mreg = 0
IF mtipor ="2" THEN
  initialize mfe_factura_m.* to NULL
  declare cr_sub002 cursor FOR
   SELECT  fe_factura_m.* from fe_factura_m 
     WHERE fe_factura_m.fecha_factura>=mfecini 
     and fe_factura_m.fecha_factura<=mfecfin
     AND fe_factura_m.prefijo =mprefijo
     and (fe_factura_m.estado<>"B" AND fe_factura_m.estado <>"X")
   Foreach cr_sub002 into mfe_factura_m.*
    declare cr_sub02 cursor FOR
   select * from fe_factura_d,  fe_servicios, est_servicios
     where fe_factura_d.prefijo=mfe_factura_m.prefijo
       and fe_factura_d.documento=mfe_factura_m.documento
       AND fe_servicios.codigo=fe_factura_d.codigo
       AND fe_servicios.codser_sf = est_servicios.codsersf
       AND fe_servicios.cobertura <> "0"
       AND fe_servicios.codser_sf <> "0"
       AND (fe_factura_d.codcat ="A" OR fe_factura_d.codcat ="B") 
    order by fe_factura_d.codigo
   foreach cr_sub02 into mfe_factura_d.*, mfe_servicios.*, mest_servicios.*
    DISPLAY "factura ", mfe_factura_m.prefijo,"-", mfe_factura_m.numfac,
     " Servicio : ", mfe_factura_d.codigo,
     " tipo cobertura : ", mfe_servicios.cobertura, " Cat: ", mfe_factura_d.codcat
    IF mfe_factura_d.subsi > 0 THEN
     insert into subsidiod (numfac, prefijo, codssf, codser, codcat, valor, cant, valpag,  cantdev )
    values (mfe_factura_m.numfac, mfe_factura_d.prefijo, mfe_servicios.codser_sf, mfe_factura_d.codigo, mfe_factura_d.codcat, 
      mfe_factura_d.valoruni, mfe_factura_d.cantidad, mfe_factura_d.valoruni - mfe_factura_d.subsi,0)   
    END IF
    END FOREACH  
   END FOREACH
  -- CICLO DE DEVOLUCIONES (NOTAS CREDITO)
  initialize mfe_nota_m.* to NULL
  declare cr_dev02 cursor FOR
   SELECT  * from fe_nota_m 
     WHERE fe_nota_m.fecha_nota>=mfecini 
     and fe_nota_m.fecha_nota<=mfecfin
     AND fe_nota_m.prefijo =mprefijo
     and fe_nota_m.estado="A" 
    Foreach cr_dev02 into mfe_nota_m.*
   declare cr_dev022 cursor FOR
   select * from fe_nota_d,  fe_servicios, est_servicios
     where fe_nota_d.tipo=mfe_nota_m.tipo
      and fe_nota_d.documento=mfe_nota_m.documento
      AND fe_servicios.codigo=fe_nota_d.codigo
      AND fe_servicios.codser_sf = est_servicios.codsersf
      AND fe_servicios.cobertura <> "0"
      AND fe_servicios.codser_sf <> "0"
      AND (fe_nota_d.codcat ="A" OR fe_nota_d.codcat ="B") 
    order by fe_nota_d.codigo
   foreach cr_dev022 into mfe_nota_d.*, mfe_servicios.*, mest_servicios.*
    DISPLAY "nota ", mfe_nota_m.prefijo,"-", mfe_nota_m.numfac,
     " Servicio : ", mfe_nota_d.codigo,
     " tipo cobertura : ", mfe_servicios.cobertura, " Cat: ", mfe_nota_d.codcat
    IF mfe_nota_d.subsi > 0 THEN
     insert into subsidiod (numfac, prefijo, codssf, codser, codcat, valor, cant, valpag,  cantdev )
       values (mfe_nota_m.numnota,mfe_nota_d.prefijo, mfe_servicios.codser_sf, mfe_nota_d.codigo , mfe_nota_d.codcat, 
       mfe_nota_d.valoruni, 0, mfe_nota_d.valoruni - mfe_nota_d.subsi, 
       mfe_nota_d.cantidad)   
    END IF
   END FOREACH  
  END FOREACH
ELSE
 initialize mfe_factura_m.* to NULL
  declare crg_sub002 cursor FOR
   SELECT  fe_factura_m.* from fe_factura_m 
     WHERE fe_factura_m.fecha_factura>=mfecini 
     and fe_factura_m.fecha_factura<=mfecfin
     and (fe_factura_m.estado<>"B" AND fe_factura_m.estado <>"X")
   Foreach crg_sub002 into mfe_factura_m.*
    declare cr_gsub02 cursor FOR
   select * from fe_factura_d,  fe_servicios, est_servicios
     where fe_factura_d.prefijo=mfe_factura_m.prefijo
       and fe_factura_d.documento=mfe_factura_m.documento
       AND fe_servicios.codigo=fe_factura_d.codigo
       AND fe_servicios.codser_sf = est_servicios.codsersf
       AND fe_servicios.cobertura <> "0"
       AND fe_servicios.codser_sf <> "0"
       AND (fe_factura_d.codcat ="A" OR fe_factura_d.codcat ="B") 
    order by fe_factura_d.codigo
   foreach cr_gsub02 into mfe_factura_d.*, mfe_servicios.*, mest_servicios.*
    DISPLAY "factura ", mfe_factura_m.prefijo,"-", mfe_factura_m.numfac,
     " Servicio : ", mfe_factura_d.codigo,
     " tipo cobertura : ", mfe_servicios.cobertura, " Cat: ", mfe_factura_d.codcat
    IF mfe_factura_d.subsi > 0 THEN
     insert into subsidiod (numfac, prefijo, codssf, codser, codcat, valor, cant, valpag,  cantdev )
    values (mfe_factura_m.numfac, mfe_factura_d.prefijo, mfe_servicios.codser_sf, mfe_factura_d.codigo, mfe_factura_d.codcat, 
      mfe_factura_d.valoruni, mfe_factura_d.cantidad, mfe_factura_d.valoruni - mfe_factura_d.subsi,0)   
    END IF
    END FOREACH  
   END FOREACH
  -- CICLO DE DEVOLUCIONES (NOTAS CREDITO)
  initialize mfe_nota_m.* to NULL
  declare crg_dev02 cursor FOR
   SELECT  * from fe_nota_m 
     WHERE fe_nota_m.fecha_nota>=mfecini 
     and fe_nota_m.fecha_nota<=mfecfin
     and fe_nota_m.estado="A" 
    Foreach crg_dev02 into mfe_nota_m.*
   declare crg_dev022 cursor FOR
   select * from fe_nota_d,  fe_servicios, est_servicios
     where fe_nota_d.tipo=mfe_nota_m.tipo
      and fe_nota_d.documento=mfe_nota_m.documento
      AND fe_servicios.codigo=fe_nota_d.codigo
      AND fe_servicios.codser_sf = est_servicios.codsersf
      AND fe_servicios.cobertura <> "0"
      AND fe_servicios.codser_sf <> "0"
      AND (fe_nota_d.codcat ="A" OR fe_nota_d.codcat ="B") 
    order by fe_nota_d.codigo
   foreach crg_dev022 into mfe_nota_d.*, mfe_servicios.*, mest_servicios.*
    DISPLAY "nota ", mfe_nota_m.prefijo,"-", mfe_nota_m.numfac,
     " Servicio : ", mfe_nota_d.codigo,
     " tipo cobertura : ", mfe_servicios.cobertura, " Cat: ", mfe_nota_d.codcat
    IF mfe_nota_d.subsi > 0 THEN
     insert into subsidiod (numfac, prefijo, codssf, codser, codcat, valor, cant, valpag,  cantdev )
       values (mfe_nota_m.numnota,mfe_nota_d.prefijo, mfe_servicios.codser_sf, mfe_nota_d.codigo , mfe_nota_d.codcat, 
       mfe_nota_d.valoruni, 0, mfe_nota_d.valoruni - mfe_nota_d.subsi, 
       mfe_nota_d.cantidad)   
    END IF
   END FOREACH  
  END FOREACH
END IF  
declare cr_dem03 cursor for
select prefijo, codssf, codser, codcat, valor, valpag, sum(cant), sum(cantdev)
  from subsidiod
 group by prefijo, codssf, codser, codcat, valor, valpag
 order BY  codssf, codser, prefijo, codcat
foreach cr_dem03 into tp.*
 output to report repo_subdemanda(tp.*, mtiprep)
end foreach
finish report repo_subdemanda
IF mtiprep = "1" THEN
  call impsn(ubicacion)
END IF  
drop table subsidiod
END FUNCTION

report repo_subdemanda(tp,mtiprep)
define op char(1)
define mcaja char(2)
DEFINE mtiprep char(1)
define cnt,musuario integer
define mtitulo char(100)
define mcatt, mcat char(2)
DEFINE mvilla_catego RECORD LIKE villa_catego.*
 define tp RECORD
    prefijo char(4),
    codsf char(2),
    codser char(5),
    codcat char(2),
    valor decimal(12,2),
    valpag decimal(12,2),
    cant integer,
    cantdev integer
  end RECORD
 OUTPUT
  top margin 2
   bottom margin 3
   left margin 0 
   right margin 132
   page length 66
format
 page HEADER
 let mtime=TIME
 IF mtiprep ="1" THEN
   print column 1,"fecha : ",today," + ",mtime,
         column 145,"pag no. ",pageno using "####"
   skip 1 LINES
   let mp1 = (160-length(mfe_empresa.razsoc clipped))/2
   print column mp1,mfe_empresa.razsoc
   print column 55,"REPORTE SUBSIDIO A LA DEMANDA DE CORTE : ",mfecini," AL ",mfecfin
   skip 3 LINES
 ELSE 
  SKIP 7 LINES
 END IF
  print "------------------------------------------------------------------",
       "------------------------------------------------------------------",
       "------------------------------------"
 PRINT COLUMN 01, "PREF",
        column 07,"SERV",
        column 18,"DESCRIPCION SERVICIO",
        COLUMN 47, "CONCEPTO OBJETO DE LA TARIFA",
        COLUMN 83, "COSTO_UNIT", 
        column 98,"CATEGORIA",
        column 116, "VALOR/PAGADO",
        COLUMN 132, "VECES/FACTU",
        COLUMN 145, "CANT/DEVO" 
 print "------------------------------------------------------------------",
       "------------------------------------------------------------------",
       "-------------------------------------"
on every row
 initialize mest_servicios.* to null
 select * into mest_servicios.* from est_servicios
  where est_servicios.codsersf=tp.codsf
 initialize mfe_servicios.* to null
 select * into mfe_servicios.* from fe_servicios
  where codigo=tp.codser 
 let mcat=NULL
 let mcatt=null
 case
  when tp.codcat="A"
   let mcat="1"
   let mcatt="01"
  when tp.codcat="B"
   let mcat="2"
   let mcatt="02"
  when tp.codcat="C"
   let mcat="3"
   let mcatt="03"
  when tp.codcat="D"
   let mcat="4"
   let mcatt="04"
  when tp.codcat="E"
   let mcat="5"
   let mcatt="05" 
 end case 
 initialize mvilla_catego.* to null
 select * into mvilla_catego.* from villa_catego
  where codigo=mcatt
 IF mcatt = "05" THEN
   LET mvilla_catego.descripcion   = "EMPRESA"
 END if 
 PRINT COLUMN 01 ,tp.prefijo, 
        column 8,tp.codsf,
        column 13,mest_servicios.nombresf[1,25],
        COLUMN 42,mfe_servicios.descripcion[1,35],
        column 80,tp.valor USING "-,---,--&.&&",
        column 97,mcat,
        column 100,mvilla_catego.descripcion[1,12], 
        column 115,tp.valpag USING "-,---,--&.&&",
        column 135,tp.cant USING "--,--&",
        column 147,tp.cantdev USING "--,--&"
ON last row
 --SKIP 2 LINES
 -- PRINT COLUMN 10,"TOTALES.....",
 --     COLUMN 150,SUM(tp.valor) USING "---,---,---,--&.&&"
 skip to top of page
end REPORT

FUNCTION rep_ley115_microd()
DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
DEFINE cnt INTEGER
DEFINE opp,ox,oxx CHAR(1)
DEFINE tpreg RECORD
  tipidafi char(2),
  ideafi char(20),
  tipidben char(2),
  idben char(20),
  cat char(1), 
  nombre char(40),
  detalle_sev char(25),
  detalle_fac char(30),
  valorsub decimal(10,2) 
 END RECORD
DEFINE mprefijo char(5)
 let ubicacion=fgl_getenv("HOME"),"/reportes/det_ley115"
 let ubicacion=ubicacion CLIPPED
--LLENADO DE MESES
 LET mregmes[1].nommes = "ENERO"
 LET mregmes[2].nommes = "FEBRERO"
 LET mregmes[3].nommes = "MARZO"
 LET mregmes[4].nommes = "ABRIL"
 LET mregmes[5].nommes = "MAYO"
 LET mregmes[6].nommes = "JUNIO"
 LET mregmes[7].nommes ="JULIO" 
 LET mregmes[8].nommes = "AGOSTO"
 LET mregmes[9].nommes = "SEPTIEMBRE"
 LET mregmes[10].nommes = "OCTUBRE"
 LET mregmes[11].nommes = "NOVIEMBRE"
 LET mregmes[12].nommes = "DICIEMBRE"
 let mprefijo=NULL
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null THEN 
  RETURN
 end IF
 LET mfecini = NULL
 LET mfecfin = NULL
 let mdeftit="    RELACION DE BENEFICIARIOS "
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL confecr() RETURNING mfecini,mfecfin
 if mfecini is null or mfecfin is null then
   return
 end IF
 LET mmes = month(mfecini)
LET mnommes = "%", mregmes[mmes].nommes clipped, "%"
 LET mtiprep = NULL
 PROMPT " Reporte  1. Texto   2. Excel : " for  mtiprep
 IF mtiprep <> "1" AND mtiprep <> "2" THEN
    RETURN
 END if  
 IF mtiprep ="1" THEN
  START REPORT terley115_txtpp TO ubicacion
 ELSE
  LET handler = configureOutputt("XLS","22cm","28cm",17,"1.5cm")
  --LET handler = configureOutput_excel(90,"5.0cm","3.0cm","0.5cm","0.5cm","XLSX")
  START REPORT terley115_txtpp TO XML HANDLER HANDLER
 END IF
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
  DECLARE terppcur115 CURSOR FOR
   SELECT *
   FROM fe_factura_m, fe_factura_d 
    WHERE fe_factura_m.prefijo = fe_factura_d.prefijo
    AND fe_factura_m.documento = fe_factura_d.documento
    AND fe_factura_m.prefijo = mprefijo 
    AND fe_factura_m.fecha_factura between mfecini and mfecfin
    AND (fe_factura_m.estado ="A" OR
      (fe_factura_m.estado ="N" AND fe_factura_m.fecest > mfecfin))
    AND fe_factura_d.codcat IN ("A", "B")
    AND fe_factura_d.subsi > 0
    AND fe_factura_m.nota1 LIKE mnommes
    ORDER BY fe_factura_m.numfac
   FOREACH terppcur115 INTO mfe_factura_m.*, mfe_factura_d.*
    INITIALIZE tpreg.* TO NULL
    INITIALIZE mfe_servicios.* TO NULL
     SELECT * INTO mfe_servicios.* FROM fe_servicios
      WHERE fe_servicios.codigo = mfe_factura_d.codigo
     INITIALIZE mest_servicios.* TO NULL
     SELECT * INTO mest_servicios.* FROM est_servicios
       WHERE codsersf = mfe_servicios.codser_sf
     IF mest_servicios.codsersf = "2" OR mest_servicios.codsersf = "3" THEN
        CONTINUE FOREACH
     END IF   
     LET tpreg.detalle_fac = mfe_servicios.descripcion
     LET tpreg.detalle_sev = mest_servicios.nombresf
     LET tpreg.cat = mfe_factura_d.codcat   
    INITIALIZE msubsi15.* TO NULL
    SELECT * INTO msubsi15.* FROM subsi15
      WHERE cedtra = mfe_factura_m.nit
    IF msubsi15.cedtra IS NULL then
      SELECT * INTO msubsi15.* FROM subsi15
      WHERE cedtra = mfe_factura_m.cedtra
    END IF 
    IF msubsi15.coddoc = "8" then
      LET tpreg.tipidafi ="6"
    ELSE     
      IF msubsi15.coddoc = "7" THEN
        LET tpreg.tipidafi ="3"
      ELSE 
        LET tpreg.tipidafi = msubsi15.coddoc
      END IF  
    END IF
    LET tpreg.ideafi = msubsi15.cedtra
    DECLARE tterppcur115 CURSOR FOR
    SELECT * FROM fe_factura_ter
    WHERE prefijo=mfe_factura_m.prefijo 
    AND documento=mfe_factura_m.documento 
     ORDER BY cat
    FOREACH tterppcur115 INTO mfe_factura_ter.*
      INITIALIZE msubsi22.* TO NULL
      DECLARE cur_ben2 CURSOR FOR
        SELECT subsi22.* 
         FROM subsi22, subsi23
         WHERE subsi22.codben = subsi23.codben
          AND subsi22.documento = mfe_factura_ter.cedula
          AND subsi23.cedtra = msubsi15.cedtra
      FOREACH cur_ben2 INTO msubsi22.*
        EXIT FOREACH    
      END FOREACH
    -- VALIDACION SI A LA VEZ TUVO SUBSIDIO DE CUOTA MONETARIA (MAYO8/2020)
     LET cnt= 0
     SELECT count(*) INTO cnt
       FROM subsi09, subsi23, subsi22
        WHERE subsi09.cedtra = subsi23.cedtra  
         AND subsi22.codben = subsi09.codben
         AND  subsi22.codben = subsi23.codben
         AND subsi22.documento = mfe_factura_ter.cedula
         AND subsi23.cedtra = mfe_factura_m.nit
         AND subsi09.estado <> "A"
         AND fecgir BETWEEN mfecini AND mfecfin
       IF cnt IS NULL OR cnt = 0 THEN 
         SELECT count(*) INTO cnt
         FROM subsi14, subsi23, subsi22
         WHERE subsi14.cedtra = subsi23.cedtra  
           AND subsi22.codben = subsi14.codben
           AND  subsi22.codben = subsi23.codben
           AND subsi22.documento = mfe_factura_ter.cedula
           AND subsi23.cedtra = mfe_factura_m.nit
           AND subsi14.estado <> "A"
          AND fecgir BETWEEN mfecini AND mfecfin
        IF cnt IS NULL OR cnt = 0 THEN
          CONTINUE FOREACH  
        END IF
       END IF  
      LET tpreg.tipidben = msubsi22.coddoc
      LET tpreg.idben = mfe_factura_ter.cedula
      LET tpreg.nombre = msubsi22.priape clipped, " ", msubsi22.segape CLIPPED," ", 
        msubsi22.nombre 
      CASE  
        WHEN msubsi22.coddoc ="8"
         LET tpreg.tipidben ="6"
        WHEN msubsi22.coddoc ="10"
         LET tpreg.tipidben ="5" 
        WHEN msubsi22.coddoc ="7"
         LET tpreg.tipidben ="3"
        WHEN msubsi22.coddoc ="3"
         LET tpreg.tipidben ="7" 
        WHEN msubsi22.coddoc ="6"
         LET tpreg.tipidben ="1" 
      END CASE
      LET tpreg.valorsub = (mfe_factura_d.subsi* mfe_factura_d.cantidad)  
      OUTPUT TO REPORT terley115_txtpp(mprefijo, tpreg.*)
    END FOREACH 
   END FOREACH
 IF mtiprep ="1" THEN
   finish report terley115_txtpp
   let mdefnom="BENEFICIARIOS LEY 115"
   let mdeflet="condensed"
   let mdeftam=66
   let mhoja="9.5x11"
   call impsn(ubicacion)
 ELSE
   finish report terley115_txtpp 
 END IF  
END FUNCTION

report terley115_txtpp(mprefijo, tpreg)
define op char(1)
define mcaja char(2)
define cnt,musuario integer
define mtitulo char(100)
DEFINE mprefijo char(5)
define msexo,mcat char(1)
define mcatt char(2)
DEFINE mvilla_catego RECORD LIKE villa_catego.*
DEFINE tpreg RECORD
  tipidafi char(2),
  ideafi char(20),
  tipidben char(2),
  idben char(20),
  cat char(2),
  nombre char(40),
  detalle_sev char(25),
  detalle_fac char(30),
  valorsub decimal(10,2) 
 END RECORD
 OUTPUT
  top margin 1
   bottom margin 1
   left margin 0 
   right margin 132
   page length 66
format
 page HEADER
 let mtime=time
 print column 1,"fecha : ",today," + ",mtime,
       column 171,"pag no. ",pageno using "####"
 skip 1 lines
 let mp1 = (180-length(mfe_empresa.razsoc clipped))/2
 print column mp1,mfe_empresa.razsoc
 skip 1 LINES
 print column 80,"REPORTE BENEFICIARIOS A Y B PARA EL PREFIJO : ", mprefijo
 PRINT COLUMN 82,"FACTURADO EN EL RANGO DE FECHAS " ,mfecini," AL ",mfecfin 
 print "------------------------------------------------------------------",
       "------------------------------------------------------------------",
       "--------------------------------------------------------"
  PRINT COLUMN 01, "TID/AF",
        column 10, "DOC/AFILIADO",
        column 26, "TID/BEN",
        column 36, "DOC/BENEF.",
        COLUMN 49, "CAT",
        column 58, "NOMBRE DEL BENEFICIARIO",   
        column 100," NOMBRE DEL SERVICIO", 
        column 130, "CONCEPTO FACTURADO ", 
        column 160, "VR. SUBSIDIO"
print "------------------------------------------------------------------",
      "------------------------------------------------------------------",
      "---------------------------------------------------------"   
on every row
  PRINT COLUMN 03, tpreg.tipidafi,
        column 08, tpreg.ideafi,
        column 28, tpreg.tipidben,
        column 33, tpreg.idben[1,15] ,
        COLUMN 50, tpreg.cat,  
        column 54, tpreg.nombre, 
        column 97, tpreg.detalle_sev,
        column 127,tpreg.detalle_fac,
        column 158,tpreg.valorsub USING "---,---,--&.&&"
ON last row
 SKIP 2 LINES
  PRINT COLUMN 10,"TOTALES.....",
       COLUMN 158,SUM(tpreg.valorsub) USING "---,---,---,---,--&.&&"
 skip to top of page
end REPORT
-- DEVOLUCIONES X TARIFAS
FUNCTION resdev_tarifas()
DEFINE handler om.SaxDocumentHandler
define cnt, mreg integer
DEFINE mprefijo char(5)
DEFINE mvaling decimal(12,2)
define tp RECORD
 prefijo char(4),
 codserssf  char(2),
 codser char(5),
 codcat char(2),
 valor decimal(12,2), 
 auxiliar char(12)
end RECORD
DEFINE mauxiliar char(12)

LET mfecini = NULL
LET mfecfin = NULL
let mdeftit="  DEVOLUCIONES POR TARIFAS    "
let mdefpro="Digite Rango de fechas" #23
let mdeffec1=today
let mdeffec2=today
CALL confecr() RETURNING mfecini,mfecfin
if mfecini is null or mfecfin is null then
 return
end IF
 create TEMP table consoldev
 (
  codser char(5),
  codserssf char(2),
  codcat char(2),
  valor decimal(12,2),
  prefijo CHAR(5),
  auxiliar char(12)
 )
 PROMPT "Formato del  Reporte  1-> Texto   2-> Excel  : " for  mtiprep
 IF mtiprep <> "1" AND mtiprep <> "2" THEN
    RETURN
 END IF 
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
 let ubicacion=fgl_getenv("HOME"),"/reportes/devtarifas"
 let ubicacion=ubicacion CLIPPED
 IF mtiprep = "1" THEN
   START REPORT resumendev_ssf2 TO ubicacion
 ELSE
   LET handler = configureOutput_excel(90,"5.0cm","3.0cm","0.5cm","0.5cm","XLSX")
   START REPORT resumendev_ssf2 TO  XML HANDLER HANDLER
 END IF  
 LET mreg = 0
initialize mfe_factura_m.* to null
declare cr_dtar002 cursor for
 SELECT  fe_nota_m.* from fe_nota_m 
   WHERE fe_nota_m.fecha_nota>=mfecini 
   and fe_nota_m.fecha_nota<=mfecfin
   and fe_nota_m.estado= "A"
  ORDER BY fe_nota_m.prefijo     
 Foreach cr_dtar002 into mfe_nota_m.*
 LET mvaling = 0
 declare cr_dtar02 cursor for
 select * from fe_nota_d,  fe_servicios, est_servicios
   where fe_nota_d.tipo=mfe_nota_m.tipo
     and fe_nota_d.documento=mfe_nota_m.documento
     AND fe_servicios.codigo=fe_nota_d.codigo
     AND fe_servicios.codser_sf = est_servicios.codsersf
    -- AND fe_servicios.cobertura <> "0"
    -- AND fe_servicios.codser_sf <> "0"     
  order by fe_nota_d.codigo
 foreach cr_dtar02 into mfe_nota_d.*, mfe_servicios.*, mest_servicios.*
  DISPLAY "Nota : ", mfe_nota_m.tipo,"-", mfe_nota_m.numnota,
   " Servicio : ", mfe_nota_d.codigo,
   " tipo cobertura : ", mfe_servicios.cobertura, " Cat: ", mfe_nota_d.codcat
   LET mvaling =  (mfe_nota_d.valoruni * mfe_nota_d.cantidad) - 
    mfe_nota_d.subsi - mfe_nota_d.valorbene 
    LET mauxiliar = NULL
   SELECT auxiliaring INTO mauxiliar
     FROM fe_conta1
   WHERE codigo = mfe_servicios.codigo
   insert into consoldev (codser, codserssf, codcat, valor, prefijo, auxiliar )
      values ( mfe_nota_d.codigo, mfe_servicios.codser_sf, mfe_nota_d.codcat, mvaling, 
      mfe_nota_m.prefijo, mauxiliar)
   END FOREACH    
END FOREACH 
declare cr_ding003 cursor for
select prefijo,  codserssf, codser, codcat, sum(valor), auxiliar
  from consoldev
group by prefijo, codserssf, codser, codcat, auxiliar
 order by auxiliar, codserssf, codser, prefijo, codcat
foreach cr_ding003 into tp.*
 output to report resumendev_ssf2(tp.*)
end foreach
finish report resumendev_ssf2
IF mtiprep = "1" THEN
  call impsn(ubicacion)
END IF  
drop table consoldev
END FUNCTION
report resumendev_ssf2(tp)
define op char(1)
define mcaja char(2)
define cnt,musuario integer
define mtitulo char(100)
define mcatt, mcat char(2)
define tp RECORD
 prefijo char(4),
 codserssf  char(2),
 codser char(5),
 codcat char(2),
 valor decimal(12,2), 
 auxiliar char(12)
end RECORD
 OUTPUT
  top margin 0
   bottom margin 0
   left margin 0 
   right margin 132
   page length 66
format
 FIRST page HEADER
 let mtime=time
 print column 1,"fecha : ",today," + ",mtime,
       column 110,"pag no. ",pageno using "####"
 skip 1 lines
 let mp1 = (122-length(mfe_empresa.razsoc clipped))/2
 print column mp1,mfe_empresa.razsoc
 skip 1 LINES
 print column 01,"REPORTE DEVOLUCIONES POR TARIFAS DE CORTE : ",mfecini," AL ",mfecfin 
print "------------------------------------------------------------------",
       "------------------------------------------------------------------",
       "-----------------------------------"
 PRINT COLUMN 01, "PREF",
        column 07,"S/SSF",
        COLUMN 15, "SERV",
        COLUMN 35, "DESC. SERVICIO SSF ",
        column 65,"DESCRIPCION SERVICIO FACT",
        column 110,"CAT",   
        column 125,"TOTAL/DEVOLUCION",
        COLUMN 142," AUXILIAR "
 print "------------------------------------------------------------------",
       "------------------------------------------------------------------",
       "-----------------------------------"     
on every ROW
   initialize mest_servicios.* to NULL
   select * into mest_servicios.* from est_servicios
   where codsersf=tp.codserssf
  INITIALIZE mfe_servicios.* TO NULL
  SELECT * INTO mfe_servicios.* FROM fe_servicios
  WHERE codigo = tp.codser
 let mcat=NULL
 let mcatt=null
 PRINT COLUMN 01 ,tp.prefijo, 
        column 9,tp.codserssf,
        COLUMN 13,tp.codser,
        column 20,mest_servicios.nombresf,
        column 61,mfe_servicios.descripcion clipped,
        column 111,tp.codcat,
        COLUMN 123,tp.valor USING "---,---,---,--&.&&",
        COLUMN 145,tp.auxiliar 
ON last row
 SKIP 2 LINES
  PRINT COLUMN 10,"TOTALES.....",
       COLUMN 123,SUM(tp.valor) USING "---,---,---,--&.&&"
 skip to top of page
end REPORT
