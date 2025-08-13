GLOBALS "fc_globales.4gl"
DEFINE mvuni,mviva,mvimp decimal(12,2)
DEFINE cb_mc  ui.combobox

 FUNCTION fc_comprasmain()
 DEFINE exist  SMALLINT

 OPEN WINDOW w_mfc_compras AT 1,1 WITH FORM "fc_compras"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gfc_compras.* TO NULL
 INITIALIZE tpfc_compras.* TO NULL
 INITIALIZE tpfactura_m.* TO NULL
 INITIALIZE fcfact_medioc.* TO NULL
 --LENADO DEL COMBO MEDIOS DE COMPRAS
   LET cb_mc = ui.ComboBox.forName("fc_compras.medioc")
   CALL cb_mc.clear()
   DECLARE mc_cur CURSOR FOR
   Select *  from fc_medios_c
   FOREACH mc_cur into  fcfact_medioc.*
      CALL cb_mc.addItem( fcfact_medioc.codmed, fcfact_medioc.detalle)
   END FOREACH 
--------------
  MENU
   COMMAND "Adiciona" "Adiciona Pago de Agencia"
    CALL fc_comprasadd()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
 COMMAND "Consulta" "Consulta Personas "
    CALL fc_comprasquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfc_compras
END FUNCTION


FUNCTION fc_comprasdplyg()

DISPLAY BY NAME gfc_compras.prefijo THRU gfc_compras.soporte

  INITIALIZE mfc_prefijos.* TO NULL
  SELECT * INTO mfc_prefijos.* FROM fc_prefijos
  WHERE fc_prefijos.prefijo = gfc_compras.prefijo
  DISPLAY mfc_prefijos.descripcion TO mprefijo

  INITIALIZE mfc_factura_m.* TO NULL
  SELECT * INTO mfc_factura_m.* FROM fc_factura_m
  WHERE fc_factura_m.prefijo = gfc_compras.prefijo
  AND fc_factura_m.numfac = gfc_compras.numfac
  DISPLAY mfc_factura_m.documento TO numint
  DISPLAY mfc_factura_m.nota1 TO mnota1
  DISPLAY mfc_factura_m.numfac TO numfac

   initialize mfc_terceros.* to null
    select * into mfc_terceros.* from fc_terceros 
    where fc_terceros.nit = mfc_factura_m.nit
    
   DISPLAY mfc_factura_m.nit TO mnit
   IF mfc_terceros.tipo_persona="1" THEN
    DISPLAY mfc_terceros.razsoc TO mrazsoc
   ELSE
    LET mnombre=NULL
    LET mnombre=mfc_terceros.primer_nombre clipped," ",mfc_terceros.segundo_nombre clipped," ",
                mfc_terceros.primer_apellido clipped," ",mfc_terceros.segundo_apellido clipped," "
    DISPLAY mnombre TO mrazsoc
   END IF 

  LET mvalor=0
  INITIALIZE mfc_factura_d.* TO NULL
  SELECT SUM((fc_factura_d.valoruni)* fc_factura_d.cantidad)  INTO mvalor FROM fc_factura_d
   WHERE fc_factura_d.prefijo = mfc_factura_m.prefijo
   AND fc_factura_d.documento = mfc_factura_m.documento
    DISPLAY mvalor TO dvalor


  LET mvuni=0
  INITIALIZE mfc_factura_d.* TO NULL
  SELECT SUM((fc_factura_d.valoruni)* fc_factura_d.cantidad)  INTO mvuni FROM fc_factura_d
   WHERE fc_factura_d.prefijo = mfc_factura_m.prefijo
   AND fc_factura_d.documento = mfc_factura_m.documento
    DISPLAY mvuni TO dvuni

  LET mviva=0
  INITIALIZE mfc_factura_d.* TO NULL
  SELECT SUM((fc_factura_d.iva)* fc_factura_d.cantidad)  INTO mviva FROM fc_factura_d
   WHERE fc_factura_d.prefijo = mfc_factura_m.prefijo
   AND fc_factura_d.documento = mfc_factura_m.documento
    DISPLAY mviva TO dviva

  LET mvimp=0
  INITIALIZE mfc_factura_d.* TO NULL
  SELECT SUM((fc_factura_d.impc)* fc_factura_d.cantidad)  INTO mvimp FROM fc_factura_d
   WHERE fc_factura_d.prefijo = mfc_factura_m.prefijo
   AND fc_factura_d.documento = mfc_factura_m.documento
    DISPLAY mvimp TO dvimp

END FUNCTION


FUNCTION fc_comprasadd()
DEFINE control smallint
DEFINE mnumero LIKE fc_compras.prefijo
DEFINE mnumf   LIKE fc_compras.numfac
 DEFINE z, cnt, x, v, y, t, rownull, currow,
        scrrow, toggle, ttlrow, lin, lin2 SMALLINT
 IF int_flag THEN
 LET int_flag = FALSE
 END IF
 DISPLAY "" AT 1,1
 MESSAGE ""
 MESSAGE "ESTADO: Adicionando pagos de Agencia"  ATTRIBUTE(BLUE)
 CLEAR FORM
 INITIALIZE tpfc_compras.* TO NULL
  lABEL Ent_compras:
 INPUT BY NAME tpfc_compras.prefijo THRU tpfc_compras.soporte WITHOUT DEFAULTS
  BEFORE INPUT  
   let tpfc_compras.fecha=TODAY
   DISPLAY BY NAME tpfc_compras.fecha

  AFTER FIELD prefijo
   IF  tpfc_compras.prefijo IS NULL THEN
    CALL fc_factura_mval() RETURNING tpfc_compras.prefijo,tpfc_compras.numfac
    IF tpfc_compras.prefijo IS  NULL THEN 
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " Debe escoger un Prefijo ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
      END MENU
     NEXT FIELD prefijo
   ELSE
     INITIALIZE  fcfact_m.* TO NULL 
     SELECT * into fcfact_m.* FROM fc_factura_m
     WHERE prefijo = tpfc_compras.prefijo AND numfac= tpfc_compras.numfac
     DISPLAY fcfact_m.documento to numint
     CALL mostrar_datos_factura()
   END IF
  END if 
 AFTER FIELD numfac
  IF  tpfc_compras.numfac IS NULL THEN
   CALL fc_factura_mval() RETURNING tpfc_compras.prefijo,tpfc_compras.numfac
    IF tpfc_compras.numfac IS  NULL THEN 
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " Debe escoger una factura ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
      END MENU
      NEXT FIELD numfac
    ELSE
     INITIALIZE  fcfact_m.* TO NULL 
      SELECT * into fcfact_m.*  FROM fc_factura_m
      WHERE prefijo = tpfactura_m.prefijo AND numfac=tpfactura_m.numfac
      DISPLAY  fcfact_m.documento to numint
      CALL mostrar_datos_factura()
    END IF
  ELSE
   INITIALIZE  fcfact_m.* TO NULL 
    SELECT * into fcfact_m.*  FROM fc_factura_m
    WHERE prefijo = tpfactura_m.prefijo AND numfac=tpfactura_m.numfac
    DISPLAY  fcfact_m.documento to numint
    CALL mostrar_datos_factura()
  END IF
  LET control = NULL 
   SELECT count(*) INTO control FROM fc_compras 
     WHERE fc_compras.prefijo=tpfc_compras.prefijo and fc_compras.numfac=tpfc_compras.numfac
   DISPLAY ":",control  
   IF control<>0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El numero de Factura ya tiene pago asociado ",
             image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
      END MENU
      INITIALIZE tpfc_compras.* TO NULL
      CLEAR FORM
      NEXT FIELD numfac
    END IF
 AFTER FIELD medioc
  IF tpfc_compras.medioc  IS  NULL THEN 
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " DEBE ESCOGER EL MEDIO DE LA COMPRA ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD medioc
  END IF
 AFTER FIELD fecha
   IF tpfc_compras.fecha IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA FECHA NO FUE DIGITADA ", "stop")
    NEXT FIELD fecha
   END IF
   
AFTER FIELD valcomp 
   IF tpfc_compras.valcomp IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Valor de la compra No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD valcomp
   END IF

 AFTER FIELD soporte

  AFTER INPUT
   IF int_flag THEN
      EXIT INPUT
   ELSE
     IF  tpfc_compras.medioc IS NULL
      OR tpfc_compras.valcomp IS NULL then 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
        comment= "Hay campos obligatorios vacios debe completarlos ", image= "exclamation")
         COMMAND "Aceptar"
          EXIT MENU
      END MENU
        GO TO Ent_compras
      end if 
   END IF
 
 END INPUT
 IF int_flag THEN
  CLEAR FORM
  MENU "Información"  ATTRIBUTE(style= "dialog", 
                  comment= " La adicion fue cancelada      "  ,
                   image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    INITIALIZE tpfc_compras.* TO NULL
  RETURN
 END IF
 MESSAGE "ADICIONANDO INFORMACION"  ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 if tpfc_compras.prefijo is not null and tpfc_compras.numfac is not null  then 
 INSERT INTO fc_compras
   VALUES (tpfc_compras.*)
   if sqlca.sqlcode <> 0 then    
     MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
                               comment= " NO SE ADICIONO.. REGISTRO REFERENCIADO     "  ,
                               image= "stop")
        COMMAND "Aceptar"
          EXIT MENU
     END MENU
     LET gerrflag = TRUE
   END IF  
 else
  LET gerrflag = TRUE
 end if
 IF NOT gerrflag THEN
  COMMIT WORK
  LET gfc_compras.* = tpfc_compras.*
  INITIALIZE tpfc_compras.* TO NULL
 MENU "Información"  ATTRIBUTE( style= "dialog", 
                   comment= " La informacion fue Adicionada...  "  ,
                   image= "information")
       COMMAND "Aceptar"
       CLEAR FORM
         EXIT MENU
     END MENU
 ELSE
  ROLLBACK WORK
  MENU "Información"  ATTRIBUTE( style= "dialog", 
                            comment= " La adición fue cancelada      "  ,
                            image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
 END IF
 MESSAGE "" 
END FUNCTION  



FUNCTION fc_comprasgetcurr( tpprefijo, tpnumfac )
  DEFINE letras string
  DEFINE tpprefijo LIKE fc_compras.prefijo
  DEFINE tpnumfac  LIKE fc_compras.numfac

  
  INITIALIZE gfc_compras.* TO NULL
  SELECT fc_compras.prefijo,fc_compras.numfac,fc_compras.medioc,
         fc_compras.fecha,fc_compras.valcomp,fc_compras.soporte
   INTO gfc_compras.* 
   FROM fc_compras
   WHERE fc_compras.prefijo = tpprefijo AND
         fc_compras.numfac  = tpnumfac

END FUNCTION

FUNCTION fc_comprashowcurr( rownum, maxnum )
 DEFINE rownum, maxnum INTEGER
 IF gfc_compras.prefijo IS NULL  AND gfc_compras.numfac IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum,
          "/ Existen ", maxnum, ")"
 END IF
 CALL fc_comprasdplyg()

END FUNCTION


FUNCTION fc_factura_mval()
 DEFINE tp   RECORD
   pref         LIKE fc_factura_m.prefijo,
   doc          LIKE fc_factura_m.documento,
   numf         LIKE fc_factura_m.numfac

 END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fc_factura_m
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.pref = NULL
  RETURN tp.pref
 END IF
 OPEN WINDOW w_vfcfact_m AT 8,32 WITH FORM "fc_factura_prefijos"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 DECLARE c_vfcfact_m SCROLL CURSOR FOR
  SELECT fc_factura_m.prefijo,fc_factura_m.documento,fc_factura_m.numfac FROM fc_factura_m 
  WHERE fc_factura_m.prefijo='AGE' AND fc_factura_m.estado='A'
 OPEN c_vfcfact_m
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fcfact_mrow( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
 DISPLAY "" AT lastline,1
 MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
 MENU ":"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   HELP 5
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL fcfact_mrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL fcfact_mrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Vaya" "Se desplaza al registro No.()."
   HELP 9
   LET status = -1
   WHILE ( status < 0 )
    LET status = 1
    PROMPT "Entre el numero de la posicion (1 - ", maxnum, "): " FOR gotorow
    HELP 4
   END WHILE
   IF gotorow IS NULL OR int_flag THEN
    LET int_flag = FALSE
    LET gotorow = currrow
   END IF
   IF gotorow > maxnum THEN
    LET gotorow = maxnum
   END IF
   IF gotorow < 1 THEN
    LET gotorow = 1
   END IF
   LET currrow = gotorow
   CALL fcfact_mrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vfcfact_m INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.doc = NULL
   EXIT MENU
 END MENU
 CLOSE c_vfcfact_m
 CLOSE WINDOW w_vfcfact_m
 RETURN tp.pref, tp.numf
END FUNCTION  

FUNCTION fcfact_mrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD

   pref         LIKE fc_factura_m.prefijo,
   doc          LIKE fc_factura_m.documento,
   numf         LIKE fc_factura_m.numfac

   
  END RECORD,
  scrmax,scrcurr,scrprev,currrow,prevrow,pagenum,newpagenum,x,y,scrfrst INTEGER
 LET scrmax = 5
 LET newpagenum = 1
 LET scrcurr = currrow MOD scrmax
 IF scrcurr > 0 THEN
  LET newpagenum = ( currrow/scrmax ) + 1
 ELSE
  LET scrcurr = scrmax
  LET newpagenum = ( currrow/scrmax )
 END IF
 IF newpagenum <> pagenum THEN
  LET pagenum = newpagenum
  LET scrfrst = currrow - scrcurr + 1
  FETCH ABSOLUTE scrfrst c_vfcfact_m INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO prefv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO prefv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vfcfact_m INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO prefv[y].*
     END FOR
     EXIT FOR
    END IF
   END IF
  END FOR
 ELSE
  LET scrprev = prevrow MOD scrmax
  IF scrprev = 0 THEN
   LET scrprev = scrmax
  END IF
  FETCH ABSOLUTE prevrow c_vfcfact_m INTO tp.*
  DISPLAY tp.* TO prefv[scrprev].*
  FETCH ABSOLUTE currrow c_vfcfact_m INTO tp.*
  DISPLAY tp.* TO prefv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION


FUNCTION fc_factura_mediocval()
 DEFINE tmc   RECORD
   codmed       LIKE  fc_medios_c.codmed,
   detalle      LIKE  fc_medios_c.detalle
 END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fc_medios_c
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tmc.codmed = NULL
  RETURN tmc.codmed
 END IF
 OPEN WINDOW w_vfcfact_medioc AT 8,32 WITH FORM "fc_mediosc"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 DECLARE c_vfcfact_medioc SCROLL CURSOR FOR
  SELECT fc_medios_c.codmed, fc_medios_c.detalle FROM fc_medios_c
   ORDER BY fc_medios_c.codmed
 OPEN c_vfcfact_medioc
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fcfact_mediocrow( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
 DISPLAY "" AT lastline,1
 MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
 MENU ":"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   HELP 5
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL fcfact_mediocrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL fcfact_mediocrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Vaya" "Se desplaza al registro No.()."
   HELP 9
   LET status = -1
   WHILE ( status < 0 )
    LET status = 1
    PROMPT "Entre el numero de la posicion (1 - ", maxnum, "): " FOR gotorow
    HELP 4
   END WHILE
   IF gotorow IS NULL OR int_flag THEN
    LET int_flag = FALSE
    LET gotorow = currrow
   END IF
   IF gotorow > maxnum THEN
    LET gotorow = maxnum
   END IF
   IF gotorow < 1 THEN
    LET gotorow = 1
   END IF
   LET currrow = gotorow
   CALL fcfact_mediocrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vfcfact_medioc INTO tmc.*
   EXIT MENU

  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tmc.detalle = NULL
   EXIT MENU
 END MENU
 CLOSE c_vfcfact_medioc
 CLOSE WINDOW w_vfcfact_medioc
 RETURN tmc.codmed
END FUNCTION 

FUNCTION fcfact_mediocrow( currrow, prevrow, pagenum )
 DEFINE tmc RECORD
   codmed       LIKE  fc_medios_c.codmed,
   detalle      LIKE  fc_medios_c.detalle
  END RECORD,
  scrmax,scrcurr,scrprev,currrow,prevrow,pagenum,newpagenum,x,y,scrfrst INTEGER
 LET scrmax = 5
 LET newpagenum = 1
 LET scrcurr = currrow MOD scrmax
 IF scrcurr > 0 THEN
  LET newpagenum = ( currrow/scrmax ) + 1
 ELSE
  LET scrcurr = scrmax
  LET newpagenum = ( currrow/scrmax )
 END IF
 IF newpagenum <> pagenum THEN
  LET pagenum = newpagenum
  LET scrfrst = currrow - scrcurr + 1
  FETCH ABSOLUTE scrfrst c_vfcfact_medioc INTO tmc.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tmc.* TO medioscv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tmc.* TO medioscv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vfcfact_medioc INTO tmc.*
    IF status = NOTFOUND THEN
     INITIALIZE tmc.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tmc.* TO medioscv[y].*
     END FOR
     EXIT FOR
    END IF
   END IF
  END FOR
 ELSE
  LET scrprev = prevrow MOD scrmax
  IF scrprev = 0 THEN
   LET scrprev = scrmax
  END IF
  FETCH ABSOLUTE prevrow c_vfcfact_medioc INTO tmc.*
  DISPLAY tmc.* TO medioscv[scrprev].*
  FETCH ABSOLUTE currrow c_vfcfact_medioc INTO tmc.*
  DISPLAY tmc.* TO medioscv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION


FUNCTION fc_comprasquery( exist )
DEFINE where_info, query_text  CHAR(400),
  answer                        CHAR(1),
  exist,  curr, maxnum          integer,
  tpprefijo LIKE fc_compras.prefijo,
  tpnumfac  LIKE fc_compras.numfac,
  
  letras string
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : CONSULTA "  ATTRIBUTE(BLUE)
CLEAR FORM
 CONSTRUCT where_info
  ON prefijo,numfac,medioc,fecha,valcomp,soporte
  FROM prefijo,numfac,medioc,fecha,valcomp,soporte
 IF int_flag THEN
  MENU "Información"  ATTRIBUTE( style= "dialog", 
                             comment= " La consulta fue cancelada",
                             image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  RETURN exist
 END IF
 
 DISPLAY "Buscando la factura(s), por favor espere ..." AT 2,1
 LET query_text = " SELECT fc_compras.prefijo,fc_compras.numfac",
      " FROM fc_compras WHERE ", where_info CLIPPED,
      " ORDER BY fc_compras.numfac ASC"
 DISPLAY "consulta ", query_text ," ",WHERE_info  

 PREPARE s_sfc_compras FROM query_text
 DECLARE c_sfc_compras SCROLL CURSOR FOR s_sfc_compras
 LET maxnum = 0
 FOREACH c_sfc_compras INTO tpprefijo,tpnumfac
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_sfc_compras
  FETCH FIRST c_sfc_compras INTO tpprefijo,tpnumfac
  LET curr = 1
  CALL fc_comprasgetcurr( tpprefijo,tpnumfac)
  CALL fc_comprashowcurr( curr, maxnum )
 ELSE
  MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
   comment= " La factura No EXISTE", image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
  END MENU
  LET int_flag = TRUE
  RETURN exist
 END IF
 MESSAGE "" 
 LET gerrflag = FALSE 

 MENU 
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla"
   IF ( curr = maxnum ) THEN
    FETCH FIRST c_sfc_compras INTO tpprefijo,tpnumfac
    LET curr = 1
   ELSE
    FETCH NEXT c_sfc_compras INTO tpprefijo,tpnumfac
    LET curr = curr + 1
   END IF
  CALL fc_comprasgetcurr( tpprefijo,tpnumfac)
  CALL fc_comprashowcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_sfc_compras INTO tpprefijo,tpnumfac
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_sfc_compras INTO tpprefijo,tpnumfac
    LET curr = curr - 1
   END IF
  CALL fc_comprasgetcurr( tpprefijo,tpnumfac)
  CALL fc_comprashowcurr( curr, maxnum )
   
  COMMAND "Modifica" "Modifica la factura en consulta"

    IF gfc_compras.prefijo IS NULL AND gfc_compras.numfac IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_compras
     CALL fc_comprasupdate()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL fc_comprasgetcurr( tpprefijo,tpnumfac)
     CALL fc_comprashowcurr( curr, maxnum )
     OPEN c_sfc_compras
    END IF
 --END IF
 
  COMMAND "Borra" "Borra la factura en consulta"
    IF gfc_compras.prefijo IS NULL AND gfc_compras.numfac IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_compras
     CALL fc_comprasremove()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
       CALL fc_comprashowcurr( curr, maxnum )
     END IF
     OPEN c_sfc_compras
    END IF
  -- END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF gfc_compras.prefijo IS NULL AND gfc_compras.numfac IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sfc_compras
 RETURN exist
END FUNCTION

----FIN CONSULTA


FUNCTION fc_comprasupdate()
DEFINE mnumero LIKE fc_compras.numfac

 DEFINE cnt,control SMALLINT
 --DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION "  ATTRIBUTE(BLUE)
 LET tpfc_compras.* = gfc_compras.*
 LABEL ingreso_prefijo:
 INPUT BY NAME  tpfc_compras.medioc THRU  tpfc_compras.soporte  WITHOUT DEFAULTS
 
 
  AFTER FIELD medioc
   IF tpfc_compras.medioc  IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El medio de compras No fue Digitada ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD medioc
   END IF

AFTER FIELD fecha
   IF tpfc_compras.fecha  IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " La Fecha No fue Digitada ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD fecha
   END IF

   AFTER FIELD valcomp
   IF tpfc_compras.valcomp  IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El valor de la compra No fue Digitada ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD valcomp
   END IF
   

   AFTER FIELD soporte
   IF tpfc_compras.soporte  IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Soporte No fue Digitado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD soporte
   END IF
   

   AFTER INPUT
   IF int_flag THEN
      EXIT INPUT
   END IF
   END INPUT
 MESSAGE "" 
 IF int_flag THEN
  CLEAR FORM
  MENU "Información"  ATTRIBUTE( style= "dialog", 
                             comment= " La modificación fue cancelada      "  ,
                             image= "information")
       COMMAND "Aceptar"
         EXIT MENU
  END MENU
  INITIALIZE tpfc_compras.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION " AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 UPDATE  fc_compras
 SET (prefijo,numfac,medioc,fecha,valcomp,soporte) 
    =(tpfc_compras.prefijo, tpfc_compras.numfac,tpfc_compras.medioc,tpfc_compras.fecha,tpfc_compras.valcomp,tpfc_compras.soporte)
 WHERE  prefijo=gfc_compras.prefijo AND  numfac = gfc_compras.numfac
 
 IF status <> 0 THEN
  MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
                             comment= " No se modificó.. Registro referenciado     "  , 
                             image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  LET gerrflag = TRUE
 END IF
 IF NOT gerrflag THEN 
 MENU "Información"  ATTRIBUTE( style= "dialog", 
                             comment= " La modificación fue realizada",
                             image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   COMMIT WORK
 ELSE
  MENU "Información"  ATTRIBUTE( style= "dialog", 
                             comment= " La modificación fue cancelada   "  ,
                             image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   ROLLBACK WORK
 END IF
 IF NOT gerrflag THEN 
  LET gfc_compras.* = tpfc_compras.*
 END IF
END FUNCTION 

FUNCTION fc_comprasremove()
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : RETIRO DE FACTURA" ATTRIBUTE(BLUE)
 PROMPT "Esta seguro de borrar  (s/n)? " FOR CHAR answer
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO  FACTURA " ATTRIBUTE(BLUE)
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  DELETE FROM fc_compras
    WHERE fc_compras.numfac = gfc_compras.numfac
  IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
   IF NOT gerrflag THEN 
   INITIALIZE gfc_compras.* TO NULL
   MENU "Información"  ATTRIBUTE( style= "dialog", 
                             comment= " El Registro fue Retirado",
                             image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   COMMIT WORK
  ELSE
   MENU "Información"  ATTRIBUTE( style= "dialog", 
     comment= " El Retiro del Registro fue Cancelado",  image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   ROLLBACK WORK
  END IF
 ELSE
  MENU "Información"  ATTRIBUTE( style= "dialog", 
    comment= " El Retiro del Registro fue Cancelado",image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  LET int_flag = TRUE
 END IF
END FUNCTION 


FUNCTION mostrar_datos_factura()
 
  DISPLAY fcfact_m.documento to numint
 --se agrego para mostrar la descripcion del prefijo  
  INITIALIZE mfc_prefijos.* TO NULL
  SELECT * INTO mfc_prefijos.* FROM fc_prefijos
   WHERE fc_prefijos.prefijo = tpfc_compras.prefijo
      DISPLAY mfc_prefijos.descripcion TO mprefijo
--trae los datos de la tabla fc_factura para relacionarlos con las demas tablas
  INITIALIZE mfc_factura_m.* TO NULL
  SELECT * INTO mfc_factura_m.* FROM fc_factura_m
   WHERE fc_factura_m.prefijo = tpfc_compras.prefijo
   AND fc_factura_m.numfac = tpfc_compras.numfac
    DISPLAY mfc_factura_m.nota1 TO mnota1
  DISPLAY mfc_factura_m.documento to numint 
--------------------------------------------------------------
---terceros
   initialize mfc_terceros.* to null
    select * into mfc_terceros.* from fc_terceros 
    where fc_terceros.nit = mfc_factura_m.nit
   DISPLAY mfc_factura_m.nit TO mnit
   IF mfc_terceros.tipo_persona="1" THEN
    DISPLAY mfc_terceros.razsoc TO mrazsoc
   ELSE
    LET mnombre=NULL
    LET mnombre=mfc_terceros.primer_nombre clipped," ",mfc_terceros.segundo_nombre clipped," ",
                mfc_terceros.primer_apellido clipped," ",mfc_terceros.segundo_apellido clipped," "
    DISPLAY mnombre TO mrazsoc
   END IF 
----------- fin terceros

-------PARA SUM valor
  LET mvalor=0
  INITIALIZE mfc_factura_d.* TO NULL
  SELECT SUM((fc_factura_d.valoruni + fc_factura_d.iva + fc_factura_d.impc-fc_factura_d.subsi)* fc_factura_d.cantidad)  INTO mvalor FROM fc_factura_d
   WHERE fc_factura_d.prefijo = mfc_factura_m.prefijo
   AND fc_factura_d.documento = mfc_factura_m.documento
    DISPLAY mvalor TO dvalor
  LET mvuni=0
  INITIALIZE mfc_factura_d.* TO NULL
  SELECT SUM((fc_factura_d.valoruni)* fc_factura_d.cantidad)  INTO mvuni FROM fc_factura_d
   WHERE fc_factura_d.prefijo = mfc_factura_m.prefijo
   AND fc_factura_d.documento = mfc_factura_m.documento
    DISPLAY mvuni TO dvuni
  LET mviva=0
  INITIALIZE mfc_factura_d.* TO NULL
  SELECT SUM((fc_factura_d.iva)* fc_factura_d.cantidad)  INTO mviva FROM fc_factura_d
   WHERE fc_factura_d.prefijo = mfc_factura_m.prefijo
   AND fc_factura_d.documento = mfc_factura_m.documento
    DISPLAY mviva TO dviva
  LET mvimp=0
  INITIALIZE mfc_factura_d.* TO NULL
  SELECT SUM((fc_factura_d.impc)* fc_factura_d.cantidad)  INTO mvimp FROM fc_factura_d
   WHERE fc_factura_d.prefijo = mfc_factura_m.prefijo
   AND fc_factura_d.documento = mfc_factura_m.documento
    DISPLAY mvimp TO dvimp
---------- fin sum valor
END function
