GLOBALS "fe_globales.4gl"
DEFINE mdeflinc, mdeflinc2 char(200)

DEFINE mpasajeros  char(60)

DEFINE mfe_factura_m RECORD
  prefijo              char(5),
  documento            char(7),
  numfac               integer,
  cufe  char(400),
  fecha_elaboracion  date,
  fecha_factura date,
  hora  char(8),
  nit char(20),
  fecha_vencimiento  date,
  medio_pago char(1),
  forma_pago char(1),
  franquicia  char(1),
  numche char(15),
  nota1  char(400),
  cuotas integer,
  parti  integer,
  estado char(1),
  codest char(3),
  fecest date,
  horaest char(8),
  usuario_add integer,
  usuario_apru  integer
 END RECORD
 

FUNCTION com_exttc()

DEFINE mopcc SMALLINT
 DEFINE msaldo decimal(12,0)
 DEFINE mcodser LIKE fe_factura_d.codigo
 LET mfecini = NULL
 LET mfecfin = NULL
 let mdeftit="              REPORTE DE COMPRAS " #32
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL comfec() RETURNING mfecini,mfecfin
 if mfecini is null or mfecfin is null then
   return
 end if
 let mopcc = NULL
 PROMPT " Digite el codigo de la tarjeta a procesar o Presione [Enter] para seleccionar  "   for mopcc   --linea que muestra la ventana de ayuda
  
 IF mopcc is null THEN
 CALL fe_factura_mediocval() RETURNING mopcc
 IF mopcc is null THEN
   RETURN
 END IF
 END IF
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
 start report rpcartipccf to "rep"
   initialize mfe_compras.* to NULL  
   DECLARE cartip1ccf CURSOR FOR
   select * from fe_compras
   where fecha between mfecini and mfecfin   AND medioc=mopcc
    order by numfac
   FOREACH cartip1ccf into mfe_compras.*
     LET msaldo = 0
    INITIALIZE mfe_factura_m.*  TO NULL 
    SELECT * INTO mfe_factura_m.* FROM fe_factura_m
     WHERE fe_factura_m.prefijo = mfe_compras.prefijo
     AND fe_factura_m.numfac = mfe_compras.numfac
    LET mpasajeros = "" 
    DECLARE mfactura_ter CURSOR FOR
    SELECT * FROM fe_factura_ter  
    WHERE fe_factura_ter.prefijo=mfe_factura_m.prefijo AND
          fe_factura_ter.documento= mfe_factura_m.documento
     ORDER BY fe_factura_ter.cedula
    FOREACH mfactura_ter INTO mfe_factura_ter.*  
      LET mpasajeros =mfe_factura_ter.nombre CLIPPED, ", ",mpasajeros
    END FOREACH 
    
    initialize mfe_factura_d.* to NULL
    DECLARE cur_detfac CURSOR FOR 
     select * from fe_factura_d
     where fe_factura_d.prefijo = mfe_factura_m.prefijo
     AND fe_factura_d.documento= mfe_factura_m.documento
    FOREACH cur_detfac INTO mfe_factura_d.*
      EXIT FOREACH  
    END FOREACH  
    initialize mfe_servicios.* to NULL  
    select * into mfe_servicios.* from fe_servicios
    where fe_servicios.codigo = mfe_factura_d.codigo
    initialize mfe_sub_servicios.* to null
    select * into mfe_sub_servicios.* from fe_sub_servicios
    WHERE fe_sub_servicios.codigo = mfe_factura_d.subcodigo
    initialize mfe_mediosc.* to NULL 
       Select * INTO mfe_mediosc.* from fe_medios_c
       WHERE fe_medios_c.codmed = mfe_compras.medioc
    output to report rpcartipccf(mfe_compras.*, msaldo)
  END FOREACH

 Finish report rpcartipccf
--let mdefnom="CREDITOS POR MODALIDAD"
--let mdeflet="condensed"
-- let mdeftam=66
-- let mhoja="14.8x11"
 call manimp()
END FUNCTION

REPORT rpcartipccf(mfe_compras,msaldo)

DEFINE mfe_compras RECORD LIKE fe_compras.*
DEFINE mfe_factura_m RECORD LIKE fe_factura_m.*
DEFINE mdetalle char(30)
DEFINE mnombre char(25)
DEFINE mnom char(25)
DEFINE mdservicios char(25)
DEFINE msub_servicios char(25)
DEFINE mnota1 char(70)
DEFINE mrazon char(28)
DEFINE sec integer
DEFINE msaldo, mvalsub decimal (12,0)
DEFINE mtotpre, mtotcre decimal(10,2)
DEFINE mestado char(10)


output
 top margin 4
 bottom margin 6
 left margin 0
 right margin 240
 page length 66
format
 page header
 if pageno = 1 then
    let mtotpre = 0
    let mtotcre = 0
 end if
 let mtime=time
 print column 1,"Fecha : ",today," + ",mtime,
      column 158,"Pag No. ",pageno using "####"
 skip 1 lines
 let mp1 = (170-length(mgener01.razsoc clipped))/2
 print column mp1,mgener01.razsoc
 print column 53,"REPORTE COMPRAS EXTRACTO TARJETA DESDE ", mfecini, " HASTA " , mfecfin
 skip 1 LINES
 print column 1, "Tarjeta de Compra: " ," ", mfe_mediosc.detalle
 print "------------------------------------------------------------",
       "------------------------------------------------------------",
       "------------------------------------------------------------",
       "------------------------------------------------------------",
       "------------------------------------------------------------",
       "---------"
 print 
        COLUMN 01,"N°FACTURA",
        COLUMN 15,"PREFIJO",
        column 23,"FECHA COMPRA",
        column 40,"DESCRIP. SUBSERVICIO",
        column 90,"DESCRIPCIÓN COMPRA",
        column 140,"PASAJEROS",
        column 210,"SOPORTE",
        column 255,"VR.COMPRA",
        column 270,"SUBTOTAL",
        column 285,"IVA",
        column 300,"TOTAL"

 print "------------------------------------------------------------",
       "------------------------------------------------------------",
       "------------------------------------------------------------",
       "------------------------------------------------------------",
       "------------------------------------------------------------",
       "---------"

 
 on every ROW
    PRINT column 2,  mfe_compras.numfac,
          column 15, mfe_compras.prefijo,
          column 23, mfe_compras.fecha,
          COLUMN 40,mfe_sub_servicios.descripcion,
          COLUMN 70, mfe_servicios.descripcion,
          column 115, mpasajeros,
          COLUMN 210,mfe_compras.soporte,
          COLUMN 250, mfe_compras.valcomp using  "---,---,---",
          COLUMN 265, mfe_factura_d.valoruni using  "---,---,---",
          COLUMN 280, mfe_factura_d.iva using  "---,---,---",
          COLUMN 295, ((mfe_factura_d.valoruni + mfe_factura_d.iva + mfe_factura_d.impc)- mfe_factura_d.subsi)* mfe_factura_d.cantidad using  "---,---,---"

  on last row
   SKIP 1 LINES
print "------------------------------------------------------------",
       "------------------------------------------------------------",
       "------------------------------------------------------------",
       "------------------------------------------------------------",
       "------------------------------------------------------------",
       "---------"
 PRINT column 1,  "TOTAL GENERAL............................." ,
         column 245, sum(mfe_compras.valcomp) using "--,---,---,---.--",
         column 290, sum(((mfe_factura_d.valoruni + mfe_factura_d.iva + mfe_factura_d.impc)- mfe_factura_d.subsi)* mfe_factura_d.cantidad) using "--,---,---,---.--"
 skip to top of page
END REPORT


