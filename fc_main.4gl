--IMPORT FGL seguridad_val
GLOBALS "fc_globales.4gl"
DEFINE mentrada1 char(40)
DEFINE musr CHAR(41), mfec CHAR(50)
DEFINE mlogin char(15)
DEFINE tipo_reporte VARCHAR(20)
--SCHEMA  empresa

MAIN
 DEFINE tasa1, tasa2 decimal(12,2)
 DEFINE per  integer
{ call ui.Interface.loadStyles("c_style")
 DEFER INTERRUPT 
 CLOSE WINDOW SCREEN
 CALL STARTLOG("factucompra_error.log")
 IF NOT ingreso("formulario.png") THEN
    CALL fgl_winmessage ("Administrador","Fallo en la validación del usuario","stop")
    RETURN 
 END IF}
    call ui.Interface.loadStyles("c_style.4st")  
            LET ip_adress = FGL_GETENV("FGL_WEBSERVER_REMOTE_ADDR")
            IF ip_adress IS NULL THEN 
                LET ip_adress=FGL_GETENV("FGLSERVER")
                DISPLAY "ip escritorio: ",ip_adress
            ELSE 
                LET  ip_adress = FGL_GETENV("FGL_WEBSERVER_REMOTE_ADDR")
                DISPLAY "ip web: ",ip_adress
            END IF  
            LET ubicacion = fgl_getenv("HOME"), "/rep"  
            LET ubicacion=ubicacion CLIPPED
            CALL STARTLOG("error.log")
            DEFER INTERRUPT 
            CLOSE WINDOW SCREEN

            SELECT * INTO lr_usuario_pc.* FROM usuario_pc  WHERE usuario_pc.ip_adress = ip_adress
            DISPLAY "ip: ",ip_adress, " usuario: ",lr_usuario_pc.usuario,"  ipadress: ",lr_usuario_pc.ip_adress
            IF lr_usuario_pc.ip_adress IS NULL OR (lr_usuario_pc.ip_adress <>ip_adress)  THEN
                IF NOT ingreso("formulario3.png") THEN 
                    CALL fgl_winmessage ("Administrador","Fallo en la validación del usuario","stop")
                    RETURN 
                END IF

            ELSE
                    LET musuario=lr_usuario_pc.usuario 
            END IF    
       

 LET mcodmen="FC00"
 CALL opcion() RETURNING op
 if op="S" THEN
 ELSE
  MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     comment= " EL USUARIO NO TIENE PERMISO DE INGRESO ",
      image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  return
 END if
 INITIALIZE mconta01.* TO NULL
 select * into mconta01.* from conta01
 -- varibles usadas en la actualizacion de comprobantes
 let mcla=mconta01.clase
 let mgru=mconta01.grupo
 let mcta=mconta01.cta
 let msct=mconta01.subcta
 let maux1=mconta01.auxuno
 let maux2=mconta01.auxdos
 let maux3=mconta01.auxtre
 let mnumdig=mconta01.numdig
 INITIALIZE mfc_empresa.* to NULL
 SELECT * INTO mfc_empresa.* FROM fc_empresa
 OPEN WINDOW w_prin AT 1,1 WITH FORM "fc_principal"
 SELECT nombre INTO musr FROM gener02 WHERE usuario = musuario
 LET musr=musr clipped," ",musuario using "&&&"
 LET mfec = nommes(MONTH(TODAY)) CLIPPED," ",
                   DAY(TODAY) USING "&&"," DE ",YEAR(TODAY) USING "&&&&"
  LET mfec= mfec CLIPPED, "  HORA: ", TIME 
  DISPLAY musr TO musuario
  DISPLAY mfec TO mingreso
  LET mlogin=FGL_GETENV("LOGNAME")
  DISPLAY mlogin TO mlogin
  LET mentrada1 = "GENERAL"
  DISPLAY mentrada1 TO mcontab
 MENU
 --FUNCIONES BLOQUE1 - BASICAS
-- ON ACTION op3
  --   CALL ui.Interface.loadActionDefaults("acciones") 
    --  LET tipo_reporte = "Reporte_simple"
      --CALL f_salida_reporte(tipo_reporte)
   ON ACTION empresas
     call empmain()
   ON ACTION prefijos
    LET mcodmen="FC02"
    CALL opcion() RETURNING op
    if op="S" THEN
      call prefijosmain()
    END IF  
   ON ACTION servicios
    LET mcodmen="FC07"
    CALL opcion() RETURNING op
    if op="S" THEN
      call serviciosmain()
    END IF
   ON ACTION subservicios
    LET mcodmen="FC07"
    CALL opcion() RETURNING op
    if op="S" THEN
      CALL sub_serviciosmain()
    END IF 
   --catalogos Dian 
   ON ACTION unidades
    CALL fc_unidades_main()
   ON ACTION paises
    CALL fe_paises_main()
   ON ACTION deptos
    CALL fe_deptos_main()
   ON ACTION ciudades
    CALL fe_ciudades_main()
   ON ACTION descuentos
    CALL fe_descuentos_main()
   ON ACTION impuestos
    CALL fe_impuestos_main()
   ON ACTION tpobligacion
     CALL fe_tipobligacion_main()  
   ON ACTION  traer_represent_factu
      CALL generar_pdf_factu() 
   ON ACTION nota_ajuste
      CALL fc_nota_ajuste_main()

    ON ACTION transmitir_nota
        CALL enviar_nota_ajuste ()
  --FUNCIONES BLOQUE2     
   ON ACTION prefijos_usu
    LET mcodmen="FC12"
    CALL opcion() RETURNING op
    if op="S" THEN
     call prefijosusumain()
    END if 
   ON ACTION prefijos_usuu
    LET mcodmen="FC15"
    CALL opcion() RETURNING op
    if op="S" THEN
     call prefijosusuumain()
    END IF 
    ON ACTION proveedores
        LET mcodmen="FC23"
        CALL opcion() RETURNING op
        IF op="S" THEN 
            CALL tercerosmain()
        END IF 
   ON ACTION terceros
    LET mcodmen="FC23"
    CALL opcion() RETURNING op
    if op="S" THEN
     CALL tercerosmain()
    END if 
   ON ACTION factura
    LET mcodmen="FC30"
    CALL opcion() RETURNING op
    if op="S" THEN
      CALL fc_factura_mmain()
    END IF
   ON ACTION enviar_factura
    CALL enviar_factura_dian() 
   ON ACTION consulta_est_webs1
     CALL consulta_estados_factu("7")
    ON ACTION consulta_estado_nota1
        CALL consulta_estados_nota("10")
   ON ACTION consulta_est_webs3
     --CALL consulta_estados_factu_masivo()  
   ON ACTION factu1
     CALL rep_facturas()
   ON ACTION factu2
     CALL rep_facturas_nit()
   ON ACTION factu3
     CALL rep_facturas_pago()
   ON ACTION factu4
     CALL rep_facturas_pagoo()
   ON ACTION factu8
     CALL rep_facturas_estados() 
 -- ON ACTION impfac_masiva
   --  CALL imprime_factu_rr() 
   ON ACTION aprueba_masivo 
    LET mcodmen="FC34"
    CALL opcion() RETURNING op
    if op="S" THEN 
      CALL aprueba_masivo()
    END IF

   ON ACTION edofact
    --CALL edofact_main()
  ON ACTION consul_respenv
   CALL con_hisrespenvio()  
  ON ACTION  consul_estfac
   CALL con_hisfact()
 ----------
  ON ACTION salir
     EXIT PROGRAM
 END MENU
  CLOSE WINDOW w_prin
END MAIN

{function clave()
  DEFINE valida smallint
  DEFINE mclaver char(5)
  DEFINE m_mensaje char(55)
OPEN WINDOW w_clave  WITH FORM "fc_clave"
 let j=0
 let mclave=null 
 let musuario = null
 let mnombre = null
 let valida = FALSE
label ciclo_clave:
INPUT BY NAME mclave --ATTRIBUTES( ACCEPT=FALSE )
AFTER FIELD mclave
 IF mclave is not null then
 CALL encripta()
 LET mclave=mclaenc
 INITIALIZE mgener02.* TO NULL
 select * into mgener02.* from gener02 where clave=mclave
 if mgener02.cedtra IS NULL then
  MESSAGE "LA CLAVE DIGITADA NO EXISTE " ATTRIBUTE(BLUE)
  DISPLAY "" to mclave
  let j=j+1
  if j>=3 then
    let l=0
    let musuario = null
    let mnombre = null
    EXIT INPUT
  end if 
 else 
  LET valida = TRUE
  let l=1
  let musuario = mgener02.usuario
  let mnombre = mgener02.nombre
  EXIT INPUT
 end if
else 
   MESSAGE "NO HA DIGITADO LA CLAVE" 
end if
GOTO ciclo_clave
END INPUT
CLOSE WINDOW w_clave
 IF not VALIDA then
   EXIT PROGRAM 
 end if
end function}

{FUNCTION encripta()
 DEFINE mkeyval,i,b,x SMALLINT 
 define d decimal(10,2)
 IF mclave IS NULL THEN
  MESSAGE "  LA CLAVE NO FUE DIGITADA POR FAVOR VERIFIQUELA"
             
  RETURN
 END IF
 FOR i = 1 TO 5
  let d=i/2  
  let b=d
  if b=d then
   let x=6
  else
   let x=-4
  end if
  LET mkeyval = FGL_KEYVAL(mclave[i,i])
  LET mclaenc[i,i] = ASCII (mkeyval+x+5)
 END FOR 
END FUNCTION}

FUNCTION opcion()
DEFINE op CHAR(1)
LET mtime=time
INITIALIZE mgener04.* TO NULL
select * into mgener04.* from gener04
 where codmen=mcodmen and usuario=musuario
if mgener04.codmen is not null
 and mtime>=mgener04.horini and mtime<=mgener04.horfin then
 LET op="S"
 IF mgener01.audtra="S" THEN
  while true
   BEGIN WORK
   UPDATE audit06 set (codmen,fecmen,hormen)=(mcodmen,today,mtime)
    WHERE audit06.usuario=musuario
   IF status <> 0 THEN
    ROLLBACK WORK
   ELSE
    COMMIT WORK
    exit while
   END IF
  end while
 END IF
else
 LET op="N"
    CALL FGL_WINMESSAGE ("Administrador","EL USUARIO NO TIENE PERMISO EN ESTE MODULO","stop")
    --MENU "Mensaje" ATTRIBUTE(style= "dialog", 
    --comment= " EL USUARIO NO TIENE PERMISO EN ESTE MODULO   ",  image= "exclamation")
         --COMMAND "Aceptar"
           --EXIT MENU
    --END MENU
end if
RETURN op
END FUNCTION

FUNCTION nommes( mmes )
 DEFINE mmes  CHAR(2), mes INTEGER
 DEFINE mfmes CHAR(10)
 LET mes = mmes
 CASE mes
  WHEN 1 LET mfmes = "ENERO"
  WHEN 2 LET mfmes = "FEBRERO"
  WHEN 3 LET mfmes = "MARZO"
  WHEN 4 LET mfmes = "ABRIL"
  WHEN 5 LET mfmes = "MAYO"
  WHEN 6 LET mfmes = "JUNIO"
  WHEN 7 LET mfmes = "JULIO"
  WHEN 8 LET mfmes = "AGOSTO"
  WHEN 9 LET mfmes = "SEPTIEMBRE"
  WHEN 10 LET mfmes = "OCTUBRE"
  WHEN 11 LET mfmes = "NOVIEMBRE"
  WHEN 12 LET mfmes = "DICIEMBRE"
 END CASE
 RETURN mfmes
END FUNCTION


{FUNCTION configureOutputt(device,tx,ty,tl,mi)
 DEFINE tl INTEGER 
 DEFINE tx,ty VARCHAR(4)
 DEFINE device CHAR(3)
 DEFINE mi CHAR(5)}
-- DEFINE msup,minf,mizq,mder CHAR(5)
    {IF NOT fgl_report_loadCurrentSettings(NULL) THEN
        RETURN NULL
    END IF}

    {CALL fgl_report_selectDevice(device)}
   { CALL fgl_report_configureXLSDevice(1,NULL,TRUE,TRUE,NULL,NULL,TRUE)}
   { CALL fgl_report_setXLSXMergeCells(TRUE)}

    --fromPage INTEGER,
    --toPage INTEGER,
    --removeWhitespace INTEGER,
    --ignoreRowAlignment INTEGER,
    --ignoreColumnAlignment INTEGER,
    --removeBackgroundImages INTEGER,
    --mergePages INTEGER) 


--fromPage : selecciona el límite inferior del rango de páginas para incluir en 
   --el documento XLS. El valor predeterminado es 1.
--toPage - Selecciona el límite superior del rango de páginas para incluir en el 
    --documento XLS. Por defecto, todas las páginas están incluidas.
--removeWhitespace : controla si las celdas deben crearse para cadenas vacías. 
   --Por defecto, el espacio en blanco se elimina del documento.
--ignoreRowAlignment : cuando se establece, solo los objetos que están completamente
   -- por encima o completamente debajo uno del otro irán en filas separadas.
   -- Cuando se establece, la opción reduce la cantidad de filas, perdiendo así la
   -- alineación horizontal. La ubicación no se cambia para que los elementos apilados
   -- permanezcan apilados. Por defecto, la alineación de filas se ignora.
--ignoreColumnAlignment : cuando se establece, solo aquellos objetos que están
   -- completamente a la izquierda o completamente a la derecha de cada uno irán 
   --en columnas separadas. Cuando se establece, la opción reduce la cantidad de columnas,
   -- perdiendo así la alineación vertical. La ubicación no se cambia para que los 
   -- elementos adyacentes permanezcan adyacentes. Por defecto, la alineación de columna
   -- se ignora.
--removeBackgroundImages - Controla el comportamiento en caso de que un IMAGEBOX
   -- quede parcialmente oculto por otro elemento. Cuando se establece, la imagen
   -- se elimina del documento resultante; de lo contrario, la manipulación es como
   -- con cualquier otro caso de elementos superpuestos. Por defecto, las imágenes 
   --de fondo se eliminan.
--mergePages : controla el comportamiento cuando el informe tiene más de una página.
   -- Por defecto, se crea una hoja por página. Establecer este parámetro hace que las
   -- páginas se combinen, creando una única hoja de resultados a menos que la hoja 
   --tenga más de 65536 filas; en ese caso, las filas excedentes se desbordan en hojas
   -- adicionales. Establecer este parámetro y usar un tamaño de página estándar es la
   -- forma recomendada para producir una sola hoja de salida; usar un gran tamaño de 
    --página personalizado en su lugar puede afectar adversamente la recuperación y 
    --el rendimiento de la memoria.


    {call fgl_report_configurePDFDevice(NULL,FALSE,FALSE,FALSE,1,NULL) } 
    {CALL fgl_report_configureSVGDevice(TRUE,TRUE,TRUE,"DEFAULT")}
   
   {{ CALL fgl_report_selectPreview(TRUE)}
    {CALL fgl_report_setPageMargins("3cm","1cm","0.0cm","0.0cm")}
   { CALL fgl_report_setAutoformatType ("COMPATIBILITY")}
    --CALL fgl_report_configureCompatibilityOutput(132,"courier",FALSE,NULL,NULL,NULL)
 --   CALL fgl_report_configureCompatibilityOutput(132,"courier 10 Pitch",FALSE,NULL,NULL,NULL)
    {{ CALL fgl_report_configureCompatibilityOutput(tl,"Calibri",false,NULL,NULL,NULL) --Tamaño de la letra en reportes AScii}

    {{CALL fgl_report_configurePageSize ("LETTERwidth", "LETTERlength")}
    
    --sans serif
   -- CALL fgl_report_configureCompatibilityOutput(17,"courier new",NULL,NULL,"","") --Tamaño de la letra en reportes AScii
    --CALL fgl_report_configureCompatibilityOutput(tl,"courier",NULL,NULL,"","") --Tamaño de la letra en reportes AScii

    --CALL fgl_report_setPageMargins("0.5cm","0cm",mi,"2.5cm")
   
 
    --CALL fgl_report_configurePageSize(tx,ty)
    {RETURN fgl_report_commitCurrentSettings()}
{END FUNCTION}


{FUNCTION configureOutput_excel(mtam,msup,minf,mizq,mder,device)
 DEFINE mtam INTEGER
 DEFINE device CHAR(4)
 DEFINE msup,minf,mizq,mder CHAR(5)}
    {IF NOT fgl_report_loadCurrentSettings(NULL) THEN
        RETURN NULL
    END IF}

    --CALL fgl_report_configureXLSDevice(1,NULL,TRUE,TRUE,NULL,NULL,5000)
    {CALL fgl_report_selectPreview(TRUE)}
    {{CALL fgl_report_configureCompatibilityOutput(mtam,"sans-serif",true,NULL,"","")}
   { CALL fgl_report_setAutoformatType ("COMPATIBILITY")}
    {CALL fgl_report_setPageMargins(msup,minf,mizq,mder)}
    {CALL fgl_report_selectDevice(device)}
   { CALL fgl_report_setXLSXMergeCells(TRUE) }

    {RETURN fgl_report_commitCurrentSettings()}
{END FUNCTION}




 

FUNCTION configureOutput_x(device)
 DEFINE tl INTEGER
 DEFINE tx,ty VARCHAR(4)
 DEFINE device CHAR(3)
 DEFINE mi CHAR(5)
-- DEFINE msup,minf,mizq,mder CHAR(5)
    {IF NOT fgl_report_loadCurrentSettings(NULL) THEN
        RETURN NULL
    END IF
}
   { CALL fgl_report_selectDevice(device)}
   { CALL fgl_report_configureXLSDevice(1,NULL,TRUE,TRUE,NULL,NULL,5000)}

    --fromPage INTEGER,
    --toPage INTEGER,
    --removeWhitespace INTEGER,
    --ignoreRowAlignment INTEGER,
    --ignoreColumnAlignment INTEGER,
    --removeBackgroundImages INTEGER,
    --mergePages INTEGER)


--fromPage : selecciona el lï¿½mite inferior del rango de pï¿½ginas para incluir en
   --el documento XLS. El valor predeterminado es 1.
--toPage - Selecciona el lï¿½mite superior del rango de pï¿½ginas para incluir en el
    --documento XLS. Por defecto, todas las pï¿½ginas estï¿½n incluidas.
--removeWhitespace : controla si las celdas deben crearse para cadenas vacï¿½as.
   --Por defecto, el espacio en blanco se elimina del documento.
--ignoreRowAlignment : cuando se establece, solo los objetos que estï¿½n completamente
   -- por encima o completamente debajo uno del otro irï¿½n en filas separadas.
   -- Cuando se establece, la opciï¿½n reduce la cantidad de filas, perdiendo asï¿½ la
   -- alineaciï¿½n horizontal. La ubicaciï¿½n no se cambia para que los elementos apilados
   -- permanezcan apilados. Por defecto, la alineaciï¿½n de filas se ignora.
--ignoreColumnAlignment : cuando se establece, solo aquellos objetos que estï¿½n
   -- completamente a la izquierda o completamente a la derecha de cada uno irï¿½n
   --en columnas separadas. Cuando se establece, la opciï¿½n reduce la cantidad de columnas,
   -- perdiendo asï¿½ la alineaciï¿½n vertical. La ubicaciï¿½n no se cambia para que los
   -- elementos adyacentes permanezcan adyacentes. Por defecto, la alineaciï¿½n de columna
   -- se ignora.
--removeBackgroundImages - Controla el comportamiento en caso de que un IMAGEBOX
   -- quede parcialmente oculto por otro elemento. Cuando se establece, la imagen
   -- se elimina del documento resultante; de lo contrario, la manipulaciï¿½n es como
   -- con cualquier otro caso de elementos superpuestos. Por defecto, las imï¿½genes
   --de fondo se eliminan.
--mergePages : controla el comportamiento cuando el informe tiene mï¿½s de una pï¿½gina.
   -- Por defecto, se crea una hoja por pï¿½gina. Establecer este parï¿½metro hace que las
   -- pï¿½ginas se combinen, creando una ï¿½nica hoja de resultados a menos que la hoja
   --tenga mï¿½s de 65536 filas; en ese caso, las filas excedentes se desbordan en hojas
   -- adicionales. Establecer este parï¿½metro y usar un tamaï¿½o de pï¿½gina estï¿½ndar es la
   -- forma recomendada para producir una sola hoja de salida; usar un gran tamaï¿½o de
    --pï¿½gina personalizado en su lugar puede afectar adversamente la recuperaciï¿½n y
    --el rendimiento de la memoria.


    {call fgl_report_configurePDFDevice(NULL,FALSE,FALSE,FALSE,1,NULL)  }
   { CALL fgl_report_configureSVGDevice(TRUE,TRUE,TRUE,"DEFAULT")}

   
    {CALL fgl_report_selectPreview(TRUE)}
    {CALL fgl_report_setPageMargins("1.5cm","0.5cm","1.0cm","0.0cm")}
   { CALL fgl_report_setAutoformatType ("COMPATIBILITY")}
    {CALL fgl_report_configureCompatibilityOutput(132,"courier",FALSE,NULL,NULL,NULL)}
   
   
   { CALL fgl_report_configurePageSize ("a4width", "a4length")}
   
    --sans serif
   -- CALL fgl_report_configureCompatibilityOutput(17,"courier new",NULL,NULL,"","") --Tamaï¿½o de la letra en reportes AScii
    --CALL fgl_report_configureCompatibilityOutput(tl,"courier",NULL,NULL,"","") --Tamaï¿½o de la letra en reportes AScii

    --CALL fgl_report_setPageMargins("0.5cm","0cm",mi,"2.5cm")
   
 
    --CALL fgl_report_configurePageSize(tx,ty)
    {RETURN fgl_report_commitCurrentSettings()}
END FUNCTION

FUNCTION confccr()
 OPEN WINDOW w_fecha AT 04,6 WITH FORM "confccr"
 let int_flag = false
 display mdeftit to titulo  ATTRIBUTE(BLUE)
 display mdefpro to prompt 
 let v=0
 let w=0
 INPUT mfecini,mfecfin from fecha1,fecha2
  BEFORE FIELD fecha1
   if v=0 then
    let v=1
    let mfecini=mdeffec1
    DISPLAY mfecini TO fecha1
   end if
  AFTER FIELD fecha1
   IF mfecini IS NULL THEN
    ERROR "                           EL VALOR NO FUE DIGITADO       ",
          "                     "
    sleep 2
    error ""
    NEXT FIELD fecha1
   end if
  BEFORE FIELD fecha2
   if w=0 then
    let w=1
    let mfecfin=mdeffec2
    DISPLAY mfecfin TO fecha2
   end if
  AFTER FIELD fecha2
   IF mfecfin IS NULL THEN
    ERROR "                           EL VALOR NO FUE DIGITADO       ",
          "                     "
    sleep 2
    error ""
    NEXT FIELD fecha2
   end if
   IF mfecini>mfecfin THEN
    LET mfecfin=mfecini
    DISPLAY mfecfin TO fecha2
   END IF
 AFTER INPUT
  IF int_flag THEN
   let mfecini = null
   let mfecfin = null
   EXIT INPUT
  END IF
 END INPUT
 CLOSE WINDOW w_fecha
 OPTIONS
  ACCEPT KEY ESCAPE
 RETURN mfecini,mfecfin
END FUNCTION 
FUNCTION confec()
 OPTIONS
  ACCEPT KEY CONTROL-M 
 OPEN WINDOW w_fecha AT 04,18 WITH FORM "confec"
 let int_flag = false
 display mdeftit to titulo ATTRIBUTE(BLUE)
 display mdefpro to prompt
 let v=0
 INPUT mfecha from fecha 
  BEFORE FIELD fecha
   if v=0 then
    let v=1
    let mfecha=mdeffec
    DISPLAY mfecha TO fecha
   end if
  AFTER FIELD fecha
   IF mfecha IS NULL THEN
    ERROR "                           EL VALOR NO FUE DIGITADO       ",
          "                     "
    sleep 2
    error ""
    NEXT FIELD fecha 
   end if
 AFTER INPUT
  IF int_flag THEN
   let mfecha = null
   EXIT INPUT
  END IF
 END INPUT
 CLOSE WINDOW w_fecha
 OPTIONS
  ACCEPT KEY ESCAPE
 RETURN mfecha
END FUNCTION 

FUNCTION fe_nit()
 DEFINE mnombre char(30)
 OPEN WINDOW w_nit AT 04,16 WITH FORM "fenit"
 let int_flag = false
 display mdeftit to titulo ATTRIBUTE(BLUE)
 display mdefpro to prompt 
 INPUT mnit from nit 
  AFTER FIELD nit
   IF mnit IS NULL THEN
    ERROR "           EL NIT DEL TERCERO NO FUE DIGITADO ",
          "             "
    sleep 2
    ERROR ""
    INITIALIZE mnit TO NULL
    next field nit
   ELSE
    INITIALIZE mfc_terceros.* TO NULL
    SELECT * INTO mfc_terceros.* FROM fc_terceros WHERE fc_terceros.nit=mnit
    IF mfc_terceros.nit IS NULL THEN
     ERROR "           EL NIT DEL TERCERO NO EXISTE ",
           "             "
     sleep 2
     ERROR ""
     INITIALIZE mnit TO NULL
     INITIALIZE mfc_terceros.* TO NULL
     next field nit
    END IF
   END IF
   IF mfc_terceros.tipo_persona="2" THEN
    LET mnombre=NULL
    LET mnombre=mfc_terceros.primer_apellido clipped, " ",mfc_terceros.segundo_apellido clipped ," ",mfc_terceros.primer_nombre CLIPPED," ",mfc_terceros.segundo_nombre CLIPPED
    display mnombre to razsoc 
   ELSE
    display mfc_terceros.razsoc to razsoc
   END if
 AFTER INPUT
  IF int_flag THEN
   let mnit = null
   EXIT INPUT
  END IF
 END INPUT
 CLOSE WINDOW w_nit
 OPTIONS
  ACCEPT KEY ESCAPE
 RETURN mnit
END FUNCTION 



{FUNCTION configureOutput_p(mtam,msup,minf,mizq,mder,device)
 DEFINE mtam INTEGER
 DEFINE device CHAR(3)}
 --DEFINE msup,minf,mizq,mder DECIMAL(3,2)
{ DEFINE msup,minf,mizq,mder CHAR(5)}
    {IF NOT fgl_report_loadCurrentSettings(NULL) THEN
        RETURN NULL
    END IF}
   { DISPLAY "Archivo de configuracion:",mtam,msup,minf,mizq,mder,device  }
    --CALL fgl_report_configureCompatibilityOutput(150,"",true,NULL,"","")
    --CALL fgl_report_configureCompatibilityOutput(mtam,"italic",true,NULL,"","") --90
    {CALL fgl_report_configureAutoformatOutput("courier",150,true,NULL,"","")}
    --CALL fgl_report_selectLogicalPageMapping("multipage")
    --CALL fgl_report_configureMultipageOutput(2, 4, TRUE)
    --CALL fgl_report_setAutoformatType("COMPATIBILITY")
    --CALL fgl_report_setPrinterResolution(8)
    {CALL fgl_report_setPageMargins(msup,minf,mizq,mder)}
    --CALL fgl_report_setPaperMargins("50mm", "5mm", "20mm", "4mm")
    --CALL fgl_report_configurePageSize("a3length","a3width")
    -- CALL fgl_report_configurePageSize(nalegal|legal)(width|length) ---(nalegal|legal)(width|length)
    --CALL fgl_report_setPageMargins("0.5cm","0cm","0.5cm","0cm")
    --CALL fgl_report_setPrinterOrientationRequested("portrait")
    --CALL fgl_report_selectDevice("PDF")
   { CALL fgl_report_selectDevice(device)}
   { CALL fgl_report_selectDevice(getPreviewDevice())}
  -- CALL fgl_report_configureXLSDevice(1,NULL,TRUE,TRUE,NULL,NULL,5000)
    --CALL fgl_report_selectPreview(TRUE)
    --CALL fgl_report_setPrinterWriteToFile("c:/prueba.prn")
    {RETURN fgl_report_commitCurrentSettings()}
{END FUNCTION}


FUNCTION getPreviewDevice()
    DEFINE fename String
    CALL ui.interface.frontcall("standard", "feinfo", ["fename"],[fename])
    DISPLAY ":",fename
    IF fename == "Genero Desktop Client" THEN
        RETURN "SVG"
        --RETURN "XLS"
    ELSE
        RETURN "PDF"
        --RETURN "SVG"
    END IF        
END FUNCTION


{FUNCTION configureOutput_reportes(device)
 DEFINE tl INTEGER 
 DEFINE tx,ty VARCHAR(4)
 DEFINE device CHAR(3)
 DEFINE mi CHAR(5)}
-- DEFINE msup,minf,mizq,mder CHAR(5)
    {IF NOT fgl_report_loadCurrentSettings(NULL) THEN
        RETURN NULL
    END IF}

  {  CALL fgl_report_selectDevice(device)}
   { CALL fgl_report_selectPreview(TRUE)}
   { CALL fgl_report_setPageMargins("1.5cm","0.5cm","1.0cm","0.0cm")}
   { CALL fgl_report_setAutoformatType ("COMPATIBILITY")}
    {CALL fgl_report_configureCompatibilityOutput(10,"courier new",FALSE,NULL,NULL,NULL)}
   -- CALL fgl_report_configurePageSize ("a4width", "a4length") 
    
    --sans serif
   -- CALL fgl_report_configureCompatibilityOutput(17,"courier new",NULL,NULL,"","") --Tamaï¿½o de la letra en reportes AScii
    --CALL fgl_report_configureCompatibilityOutput(tl,"courier",NULL,NULL,"","") --Tamaï¿½o de la letra en reportes AScii

    --CALL fgl_report_setPageMargins("0.5cm","0cm",mi,"2.5cm")
   
 
    {CALL fgl_report_configurePageSize("a4length","a4width")}
    {RETURN fgl_report_commitCurrentSettings()}
{END FUNCTION}
