DATABASE empresa
GLOBALS "fc_globales.4gl"



{MAIN

DEFINE arr_usuarios    datos
    CALL f_obtencion_de_datos() RETURNING arr_usuarios 
    CALL f_genera_reporte_simple(arr_usuarios)
END MAIN}

FUNCTION f_obtencion_de_datos(docu,pre)
DEFINE arr_usuarios    datos      
DEFINE rec_detalle RECORD LIKE fc_factura_d.*
DEFINE i INTEGER 
DEFINE rec_services RECORD LIKE fc_servicios.*
DEFINE docu CHAR (7)
DEFINE pre CHAR(5)

CALL arr_usuarios.clear()
LET i=1
INITIALIZE rec_services.* TO NULL 

INITIALIZE rec_detalle.* TO NULL 
DECLARE tp_deptos CURSOR FOR
Select *  from fc_factura_d WHERE fc_factura_d.documento=docu AND fc_factura_d.prefijo=pre
FOREACH tp_deptos into rec_detalle.* 
    LET arr_usuarios[i].codigo= rec_detalle.codigo
    SELECT fc_servicios.descripcion INTO arr_usuarios[i].descripcion FROM fc_servicios
    WHERE fc_servicios.codigo = rec_detalle.codigo
    LET arr_usuarios[i].cantidad = rec_detalle.cantidad
    LET arr_usuarios[i].valor_unitario= rec_detalle.valoruni
    LET arr_usuarios[i].valor_total = rec_detalle.total_pagar
    LET i= i+1
END FOREACH 
   
RETURN arr_usuarios
END FUNCTION

FUNCTION f_genera_reporte_simple(arr_usuarios,docume,pre)
DEFINE arr_usuarios datos    
,lsxd_manejador OM.SAXDOCUMENTHANDLER
,contador INTEGER,
docume CHAR (7),
pre CHAR (5),
nombre CHAR (12)

LET nombre = pre,docume

    LET lsxd_manejador = RW_Inicializa_prueba(nombre,"PDF","lista_empleadosPDF.4rp")
    IF lsxd_manejador IS NULL THEN
    DISPLAY "Error. El manejador no tiene información................."  
    RETURN
    END IF
    
    START REPORT r_imprimeCatEmpleados TO XML HANDLER lsxd_manejador
        FOR contador = 1 TO arr_usuarios.getLength()
        
            OUTPUT TO REPORT r_imprimeCatEmpleados( arr_usuarios[contador].*,docume,pre )
        
        END FOR
    FINISH REPORT r_imprimeCatEmpleados
    
END FUNCTION

FUNCTION RW_Inicializa_prueba(Nombre_reporte,formato,archivo_4rp)
DEFINE 
 Nombre_reporte STRING
,formato STRING
,archivo_4rp STRING
--Manejador. El cual contiene todas las configuraciones 
--para la generación del reporte
,lsxd_manejador OM.SAXDOCUMENTHANDLER   
,ruta_completa STRING
      LET ruta_completa = "/desarrollo/Proyectos_G_3_10/Proy_Factu_compra/Pruebas_Reportes/", Nombre_reporte
      INITIALIZE lsxd_manejador TO NULL
      IF fgl_report_loadCurrentSettings(archivo_4rp) THEN
         CALL fgl_report_setOutputFileName(ruta_completa) 
         CALL fgl_report_selectDevice(formato)
         CALL fgl_report_selectPreview(true)
         CASE formato
            WHEN "PDF"
               CALL fgl_report_configurePDFDevice (null, false, false, false,1, null)
            WHEN "XLSX"
               CALL fgl_report_configureXLSDevice(1, NULL,FALSE,TRUE,NULL,NULL, TRUE)
            WHEN "RTF"
               CALL fgl_report_configureRTFDevice (1, null, null, null)
            WHEN "SVG"
               CALL fgl_report_configureImageDevice (false, false, false, 1, null, "jpg", null, null, null)
            WHEN "HML"
               CALL fgl_report_configureHTMLDevice (1, null, null, null, null, null, null, null, NULL )
            WHEN "Printer"
               CALL fgl_report_configurePDFDevice (null, false, false, false,1, null)
         END CASE
         LET lsxd_manejador = fgl_report_commitCurrentSettings()
      END IF
      RETURN lsxd_manejador
END FUNCTION

REPORT r_imprimeCatEmpleados( r_usuario, docum,prex )
DEFINE r_usuario dato,
    prefijo CHAR (5),
    numfac CHAR(7),
    razsoc CHAR (80),
    nit_prov CHAR (20),
    tel_prov CHAR (15),
    direccion CHAR (50),
    nombreciu varchar(50,0),
    fecha_elab DATE,
    nota CHAR (400),
    docum CHAR(7),
    ld_total DECIMAL(24,6),
    num_auto CHAR (50),
    fec_auto DATE,
    numini INTEGER,
    numfin INTEGER,
    fec_ven DATE, 
    email CHAR (80),
    nombre_usuario CHAR(20),
    digito CHAR (1),
    prex CHAR(5)
DEFINE rec_ter RECORD LIKE fc_terceros.*
DEFINE rec_mae RECORD LIKE fc_factura_m.*
DEFINE rec_pre RECORD LIKE fc_prefijos.*


    ORDER EXTERNAL BY r_usuario.codigo
    
    FORMAT
    
    FIRST PAGE HEADER
        SKIP TO TOP OF PAGE
        INITIALIZE rec_mae.* TO NULL 
        INITIALIZE rec_ter.* TO NULL
        SELECT * INTO rec_mae.* FROM fc_factura_m
        WHERE fc_factura_m.documento = docum AND fc_factura_m.prefijo = prex
        DISPLAY "Este es el prefijo que trae: ",rec_mae.prefijo
        LET fecha_elab = rec_mae.fecha_factura 
        SELECT * INTO rec_ter.* FROM fc_terceros
        WHERE fc_terceros.nit = rec_mae.nit
        DISPLAY "Este es el nit que trae: ",rec_mae.nit
        LET prefijo = prex
        LET numfac = rec_mae.documento
        IF rec_ter.razsoc IS NULL THEN 
            LET razsoc = rec_ter.primer_nombre CLIPPED, " ",rec_ter.segundo_nombre clipped," ",rec_ter.primer_apellido CLIPPED," ",rec_ter.segundo_apellido CLIPPED 
        ELSE 
            LET razsoc = rec_ter.razsoc CLIPPED 
        END IF 
        LET nit_prov = rec_mae.nit
        IF rec_ter.telefono IS NULL THEN 
            LET tel_prov = rec_ter.celular
        ELSE
            LET tel_prov =rec_ter.telefono
        END IF 
        LET direccion = rec_ter.direccion
        SELECT fe_ciudades.nombreciu INTO nombreciu FROM fe_ciudades
        WHERE codciu = rec_ter.zona
        
        IF rec_mae.nota1 IS NULL THEN 
            
        ELSE 
            LET nota = rec_mae.nota1
        END IF 

        INITIALIZE rec_pre.* TO NULL 
        SELECT * INTO rec_pre.* FROM fc_prefijos
        WHERE fc_prefijos.prefijo = rec_mae.prefijo

        LET num_auto = rec_pre.num_auto 
        LET fec_auto = rec_pre.fec_auto 
        LET numini = rec_pre.numini 
        LET numfin = rec_pre.numfin 
        LET fec_ven =rec_pre.fec_ven 
        SELECT fc_terceros.email INTO email FROM fc_terceros
        WHERE fc_terceros.nit=rec_mae.nit
        SELECT fc_terceros.digver INTO digito FROM fc_terceros
        WHERE fc_terceros.nit=rec_mae.nit
        
        PRINTX prefijo
        PRINTX numfac
        PRINTX razsoc
        PRINTX nit_prov
        PRINTX tel_prov
        PRINTX direccion
        PRINTX nombreciu
        PRINTX fecha_elab
        PRINTX num_auto 
        PRINTX fec_auto 
        PRINTX numini 
        PRINTX numfin
        PRINTX fec_ven
        PRINTX email
        PRINTX digito
        
        
    PAGE HEADER
        
        PRINTX razsoc 
        PRINTX nit_prov
        PRINTX tel_prov
        PRINTX direccion
        PRINTX nombreciu
        PRINTX fecha_elab
        PRINTX num_auto 
        PRINTX fec_auto 
        PRINTX numini 
        PRINTX numfin
        PRINTX fec_ven
        PRINTX email
        PRINTX digito

    ON EVERY ROW
        PRINTX r_usuario.codigo
        PRINTX r_usuario.cantidad
        PRINTX r_usuario.descripcion
        PRINTX r_usuario.valor_unitario
        PRINTX r_usuario.valor_total

    ON LAST ROW
        SELECT total_factura INTO ld_total FROM fc_factura_tot
        WHERE fc_factura_tot.prefijo = rec_mae.prefijo
        AND fc_factura_tot.documento = rec_mae.documento
        --LET ld_total = SUM ( r_usuario.valor_total) 
         IF rec_mae.nota1 IS NULL THEN 
            LET nota = null
        ELSE 
            LET nota = rec_mae.nota1
        END IF 

        SELECT gener02.nombre INTO nombre_usuario FROM gener02
        WHERE gener02.usuario=musuario
        DISPLAY "Este es el total que trae: ",ld_total
        PRINTX ld_total 
        PRINTX nota
        PRINTX nombre_usuario
        

END REPORT

----reporte documento soporte texto
FUNCTION reporte_docsop(docu,pre)
DEFINE rec_detalle RECORD LIKE fc_factura_d.*
DEFINE i INTEGER 
DEFINE rec_services RECORD LIKE fc_servicios.*
DEFINE docu CHAR (7)
DEFINE pre CHAR(5)
DEFINE nradicado INTEGER
DEFINE mdes  CHAR (50)
DEFINE mcant  DECIMAL (12,2)
DEFINE mvalun DECIMAL (12,2)
DEFINE mvalt  DECIMAL (12,2)

 let ubicacion=fgl_getenv("HOME"),"/reportes/termlab"
 let ubicacion=ubicacion CLIPPED
START REPORT rep_docsop TO ubicacion
   INITIALIZE rec_detalle.* TO NULL 
   DECLARE cur_sbs91n CURSOR FOR
    Select *  from fc_factura_d WHERE fc_factura_d.documento=docu AND fc_factura_d.prefijo=pre
   FOREACH cur_sbs91n into rec_detalle.* 
    SELECT fc_servicios.descripcion INTO mdes FROM fc_servicios
    WHERE fc_servicios.codigo = rec_detalle.codigo
         
   END FOREACH   
OUTPUT TO REPORT rep_docsop(pre,docu)
FINISH REPORT rep_docsop
CALL impsn(ubicacion)
END FUNCTION

-----
REPORT rep_docsop(pre,docu)
DEFINE rec_detalle RECORD LIKE fc_factura_d.*
DEFINE mdes  CHAR (50)
DEFINE rec_ter RECORD LIKE fc_terceros.*
DEFINE rec_mae RECORD LIKE fc_factura_m.*
DEFINE rec_pre RECORD LIKE fc_prefijos.*
DEFINE pre CHAR(5)
DEFINE docu CHAR (7)
DEFINE mrazsoc CHAR (80)
DEFINE mtel_prov CHAR(15)
DEFINE nombreciu VARCHAR(50)
DEFINE mnota VARCHAR(400)
DEFINE memail VARCHAR(80)
DEFINE mdigito CHAR(1)
DEFINE mnumf VARCHAR(7)
DEFINE numini,numfin VARCHAR(3)
DEFINE fec_ven DATE
DEFINE mld_total decimal(12,2)
DEFINE mnombre_usuario VARCHAR(20)
output
 top margin 3
 bottom margin 3
 left margin 3
 right margin 132
 page length 66
format 
page HEADER
    INITIALIZE rec_mae.* TO NULL 
        INITIALIZE rec_ter.* TO NULL
        SELECT * INTO rec_mae.* FROM fc_factura_m
        WHERE fc_factura_m.documento = docu AND fc_factura_m.prefijo = pre
 let mtime=time
  print column 1,"Fecha : ",today," + ",mtime
  skip 2 lines
  PRINTX "                                                               DOCUMENTO SOPORTE ADQUISIONES NO OBLIGADOS A FACTURAR"
  PRINTX "                                                               PREFIJO : ",rec_mae.prefijo CLIPPED,"   ",rec_mae.documento
 skip 7 lines
 
 on every ROW

    INITIALIZE rec_mae.* TO NULL 
        INITIALIZE rec_ter.* TO NULL
        SELECT * INTO rec_mae.* FROM fc_factura_m
        WHERE fc_factura_m.documento = docu AND fc_factura_m.prefijo = pre
        DISPLAY "Este es el prefijo que trae: ",rec_mae.prefijo
      --  LET fecha_elab = rec_mae.fecha_factura 
        SELECT * INTO rec_ter.* FROM fc_terceros
        WHERE fc_terceros.nit = rec_mae.nit
        --LET prefijo = pre
      --  LET numfac = rec_mae.documento
        IF rec_ter.razsoc IS NULL THEN 
            LET mrazsoc = rec_ter.primer_nombre CLIPPED, " ",rec_ter.segundo_nombre clipped," ",rec_ter.primer_apellido CLIPPED," ",rec_ter.segundo_apellido CLIPPED 
        ELSE 
            LET mrazsoc = rec_ter.razsoc CLIPPED 
        END IF 
       --- LET nit_prov = rec_mae.nit
        IF rec_ter.telefono IS NULL THEN 
            LET mtel_prov = rec_ter.celular
        ELSE
            LET mtel_prov =rec_ter.telefono
        END IF 
       --- LET direccion = rec_ter.direccion
        SELECT fe_ciudades.nombreciu INTO nombreciu FROM fe_ciudades
        WHERE codciu = rec_ter.zona

        SELECT total_factura INTO mld_total FROM fc_factura_tot
        WHERE fc_factura_tot.prefijo = rec_mae.prefijo
        AND fc_factura_tot.documento = rec_mae.documento
        
        IF rec_mae.nota1 IS NULL THEN 
            LET mnota =0
        ELSE 
            LET mnota = rec_mae.nota1
        END IF 

        INITIALIZE rec_pre.* TO NULL 
        SELECT * INTO rec_pre.* FROM fc_prefijos
        WHERE fc_prefijos.prefijo = rec_mae.prefijo

       -- LET num_auto = rec_pre.num_auto 
     --   LET fec_auto = rec_pre.fec_auto 
        LET numini = rec_pre.numini CLIPPED
        LET numfin = rec_pre.numfin CLIPPED
        LET fec_ven =rec_pre.fec_ven 
        SELECT fc_terceros.email INTO memail FROM fc_terceros
        WHERE fc_terceros.nit=rec_mae.nit
        
        SELECT fc_terceros.digver INTO mdigito FROM fc_terceros
        WHERE fc_terceros.nit=rec_mae.nit
        LET mnumf =rec_mae.numfac USING "#######"

        SELECT gener02.nombre INTO mnombre_usuario FROM gener02
        WHERE gener02.usuario=musuario
        display"mnumfac: ",mnumf
       PRINTX "                                                                                                                             Autorización numeración Res. No. "
       PRINTX "                                                                                                                               ",rec_pre.num_auto CLIPPED, " de ",rec_pre.fec_auto CLIPPED
       PRINTX "                                                                                                                            "," del ",numini CLIPPED," al ",numfin CLIPPED," vence el ",rec_pre.fec_ven 
       PRINTX "                                                                                                                                 Emitida por la DIAN"
       PRINTX "                                                                                                                              Fecha Emision: ",rec_mae.fecha_factura 
       skip 3 lines
       print "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
       PRINTX "DATOS DEL PROVEEDOR"
       print "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
       skip 1 lines
      --- PRINTX "PREFIJO : ",rec_mae.prefijo CLIPPED,"       DOCUMENTO:",rec_mae.documento
       PRINTX "NOMBRE: ",mrazsoc 
       PRINTX "NIT:",rec_mae.nit clipped,"-",mdigito,"      ","TELEFONO: ",mtel_prov  
       PRINTX "DIRECCION:",rec_ter.direccion CLIPPED,"    ","CIUDAD: ",nombreciu
       PRINTX "CORREO ELECTRONICO: ",MEMAIL
       skip 1 LINES
       print "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
       PRINTX "DATOS DEL ADQUIRIENTE"
       print "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
       skip 1 lines
       PRINTX "NOMBRE: CAJA DE COMPENSACION DEL ORIENTE COLOMBIANO COMFAORIENTE"
       PRINTX "NIT: 890500675-6","      ","TELEFONO: 5748880"  
       PRINTX "DIRECCION: Avenida 2 No. 13-75 La Playa","    ","CIUDAD: San José de Cúcuta"
       PRINTX "CORREO ELECTRONICO: facturacion@comfaoriente.com"
       print "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
       skip 1 lines
       PRINT COLUMN 1, "CODIGO ",
       COLUMN 10,"DESCRIPCION ",
       COLUMN 100,"CANTIDAD ",
       COLUMN 125,"VALOR UNT.",
       COLUMN 150,"VALOR TOTAL "
       DECLARE cursor_det CURSOR FOR 
       SELECT * FROM fc_factura_d
       WHERE prefijo=rec_mae.prefijo 
       AND documento=rec_mae.documento
       INITIALIZE rec_detalle.* TO NULL
       FOREACH cursor_det INTO rec_detalle.*
           SELECT fc_servicios.descripcion INTO mdes FROM fc_servicios
           WHERE fc_servicios.codigo = rec_detalle.codigo 
           PRINT COLUMN 1,rec_detalle.codigo,
           COLUMN 10,mdes CLIPPED,
           COLUMN 90,rec_detalle.cantidad,
           COLUMN 120,rec_detalle.valoruni,
           COLUMN 147,rec_detalle.total_pagar
       END FOREACH 
       print "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
       skip 1 LINES
       PRINT COLUMN 0,"CONCEPTO: ",mnota CLIPPED
       skip 3 LINES
       PRINT COLUMN 130,"          TOTAL: ",mld_total
       skip 3 LINES
       print  column 29,   mnombre_usuario ,"                      ","__________________________"
       print  column 29,"ELABORADO POR","                          ","       REVISADO POR"
       skip 3 LINES
       PRINTX "                Lo anterior en cumplimiento del Articulo 55 de la Resolución 42 de Mayo de 2020"
       on last ROW  

 skip to top of page    
       
END REPORT

