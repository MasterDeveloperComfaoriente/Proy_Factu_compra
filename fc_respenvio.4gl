GLOBALS "fc_globales.4gl"
DEFINE gfc_respenvio RECORD LIKE fc_respenvio.*
FUNCTION con_hisrespenvio()
DEFINE WHERE_info, query_text  CHAR(400),
  answer      CHAR(1),
  mnombre     char(40),
  mrazsoc     char(50),
  exist, curr, maxnum integer

DEFINE cb_est ui.combobox
DEFINE cb_tpdoc   ui.combobox
DEFINE tpprefijo   LIKE fc_respenvio.prefijo
DEFINE tpnumfac    like fc_respenvio.numfac
--DEFINE tpdocumento    like fc_factura_m.documento
LET gmaxdply = 12
IF int_flag THEN
 LET int_flag = FALSE
END IF
OPEN WINDOW w_histrespenvio AT 1,1 WITH FORM "fc_respenvio"
  LET cb_tpdoc = ui.ComboBox.forName("fc_respenvio.tpdocumento")
   CALL cb_tpdoc.clear()
   CALL cb_tpdoc.addItem("1","DOCUMENTO SOPORTE")
   CALL cb_tpdoc.addItem("2","NOTA-CREDITO")
   CALL cb_tpdoc.addItem("3","NOTA-DEBITO")

-- LLENADO DEL COMBO DE ESTADOS
   LET cb_est = ui.ComboBox.forName("fc_respenvio.codest")
   CALL cb_est.clear()
   CALL cb_est.addItem("0","ERROR")
   CALL cb_est.addItem("1","EXITOSO")
   CALL cb_est.addItem("2","EXITOSO CON NOTIFICACIONES")
   CALL cb_est.addItem("3","DOCUMENTO INGRESADO PREVIAMENTE")
   CALL cb_est.addItem("4","EL DOCUMENTO ESTA SIENDO PROCESADO")
   CALL cb_est.addItem("24","CONTINGENCIA DIAN")
   
LABEL cons_hist_e:
 --INITIALIZE tpfe_facturam.* TO NULL 
 CLEAR FORM
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CONSTRUCT where_info
  ON tpdocumento,prefijo,numfac,cufe,fecfactura,fecresp,fecexped,codest
  FROM tpdocumento,prefijo,numfac,cufe,fecfactura,fecresp,fecexped,codest
 IF int_flag THEN
  MENU "Información"  ATTRIBUTE( style= "dialog", 
      comment= " La consulta fue cancelada",image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
 CLOSE WINDOW w_histrespenvio   
  RETURN
 END IF
 MESSAGE "Buscando el historico de estados de los documentos soporte, por favor espere ..." ATTRIBUTE(BLINK)
 LET query_text = " SELECT fc_respenvio.prefijo,fc_respenvio.numfac",
      " FROM fc_respenvio WHERE ", WHERE_info CLIPPED,
      " ORDER BY fc_respenvio.prefijo,fc_respenvio.numfac ASC" 
 PREPARE s_shistfact FROM query_text
 DECLARE c_shistrespenvio SCROLL CURSOR FOR s_shistfact
 LET maxnum = 0
 FOREACH c_shistrespenvio INTO tpprefijo, tpnumfac
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_shistrespenvio
  FETCH FIRST c_shistrespenvio INTO tpprefijo, tpnumfac
  LET curr = 1
  CALL histrespgetcurr( tpprefijo, tpnumfac)
  CALL histrespshowcurr( curr, maxnum )
 ELSE
  MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
       comment= " No hay registros para la consulta ",  image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
  END MENU
  LET int_flag = TRUE
  GO TO cons_hist_e 
 END IF
 MESSAGE "" 
 LET gerrflag = FALSE 
 MENU 
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla"
   IF ( curr = maxnum ) THEN
    FETCH FIRST c_shistrespenvio INTO tpprefijo, tpnumfac
    LET curr = 1
   ELSE
    FETCH NEXT c_shistrespenvio INTO tpprefijo, tpnumfac
    LET curr = curr + 1
   END IF
   CALL histrespgetcurr( tpprefijo, tpnumfac )
   CALL histrespshowcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   IF ( curr = 1 ) THEN
    FETCH LAST c_shistrespenvio INTO tpprefijo, tpnumfac
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_shistrespenvio INTO tpprefijo, tpnumfac
    LET curr = curr - 1
   END IF
   CALL histrespgetcurr( tpprefijo, tpnumfac )
   CALL histrespshowcurr( curr, maxnum )
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF gfc_respenvio.prefijo IS NULL AND gfc_respenvio.numfac IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_shistrespenvio
 IF int_flag THEN
 CLEAR FORM
  MENU "Informacion " ATTRIBUTE(style= "dialog", 
  comment= "  LA CONSULTA FUE CANCELADA  ",  image= "exclamation")
    COMMAND "Aceptar"
       EXIT MENU
    END MENU
   CLOSE WINDOW w_histrespenvio
   RETURN 
 END IF
 CLOSE WINDOW w_histrespenvio
 RETURN 
END FUNCTION


FUNCTION histrespgetcurr( tpprefijo, tpnumfac )
 DEFINE tpprefijo LIKE fc_respenvio.prefijo
 DEFINE tpnumfac LIKE fc_respenvio.numfac
 
 INITIALIZE gfc_respenvio.* TO NULL
 
 SELECT fc_respenvio.tpdocumento,fc_respenvio.prefijo,fc_respenvio.numfac,fc_respenvio.cufe,
 fc_respenvio.fecfactura,fc_respenvio.fecresp,fc_respenvio.fecexped,fc_respenvio.codest
 INTO gfc_respenvio.* 
 FROM fc_respenvio
  WHERE fc_respenvio.prefijo = tpprefijo AND-- numfac > 0 
        fc_respenvio.numfac = tpnumfac

END FUNCTION 
 
FUNCTION histrespshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum INTEGER
 IF gfc_respenvio.prefijo IS NULL AND gfc_respenvio.numfac IS null  THEN --AND  tpfc_factura_m.documento IS NULL AND tpfc_factura_m.numfac IS null  THEN
  MESSAGE "Localizacion : (
  Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum,
          "/ Existen ", maxnum, ")"
 END IF
 CALL histrespdplyg()
END FUNCTION

FUNCTION histrespdplyg()
--DEFINE x integer
 DISPLAY BY NAME gfc_respenvio.tpdocumento THRU gfc_respenvio.codest

 INITIALIZE mfc_factura_m.* TO NULL
  SELECT * INTO mfc_factura_m.* FROM fc_factura_m
  WHERE fc_factura_m.prefijo = gfc_respenvio.prefijo
  AND fc_factura_m.numfac = gfc_respenvio.numfac

  DISPLAY mfc_factura_m.documento TO numint

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
    DISPLAY mnombre TO mnombre
   END IF 
  
 --DISPLAY mnombre to mnombre
-- DISPLAY mrazsoc to mrazsoc

END FUNCTION


