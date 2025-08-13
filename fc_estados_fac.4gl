GLOBALS "fc_globales.4gl"
 DEFINE ind INTEGER
 DEFINE gfc_estados_fac RECORD LIKE fc_estados_fac.*
FUNCTION con_hisfact()
DEFINE WHERE_info, query_text  CHAR(400),
  answer      CHAR(1),
  mnombre     char(40),
  mrazsoc     char(50),
  exist, curr, maxnum integer

DEFINE cb_est ,cb_tpdoc  ui.combobox
DEFINE tpprefijo   LIKE fc_estados_fac.prefijo
DEFINE tpnumfac    like fc_estados_fac.numfac
--DEFINE tpdocumento    like fc_factura_m.documento
LET gmaxdply = 12
IF int_flag THEN
 LET int_flag = FALSE
END IF
OPEN WINDOW w_histfact AT 1,1 WITH FORM "fc_estados_fac"
-- LLENADO DEL COMBO DE ESTADOS
   LET cb_est = ui.ComboBox.forName("fc_estados_fac.codest")
   CALL cb_est.clear()
   CALL cb_est.addItem("0","ERROR")
   CALL cb_est.addItem("1","EXITOSO")
   CALL cb_est.addItem("2","EXITOSO CON NOTIFICACIONES")
   CALL cb_est.addItem("3","DOCUMENTO INGRESADO PREVIAMENTE")
   CALL cb_est.addItem("4","EL DOCUMENTO ESTA SIENDO PROCESADO")
   CALL cb_est.addItem("24","CONTINGENCIA DIAN")
   LET cb_tpdoc = ui.ComboBox.forName("fc_estados_fac.tpdocumento")
   CALL cb_tpdoc.clear()
   CALL cb_tpdoc.addItem("1","DOCUMENTO SOPORTE")
   CALL cb_tpdoc.addItem("2","NOTA CREDITO")
   CALL cb_tpdoc.addItem("3","NOTA DEBITO")
   
LABEL cons_hist_e:
 --INITIALIZE tpfc_factura_m.* TO NULL 
 CLEAR FORM
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CONSTRUCT where_info
  ON  tpdocumento,prefijo,numfac,fecfactura,cufe,codult_estdisp,des_ult_estdisp,
  fecres_ultestdisp,cod_ult_estdian,des_ult_estdian,fecres_ultestdian,cod_ult_estmail,
  des_ult_estmail,fecres_ultestmail,cod_ult_estadq,des_ult_estadq,fecres_ultestadq, 
  codest,fecest,fecrep
  FROM tpdocumento,prefijo,numfac,fecfactura,cufe,codult_estdisp,des_ult_estdisp,
  fecres_ultestdisp,cod_ult_estdian,des_ult_estdian,fecres_ultestdian,cod_ult_estmail,
  des_ult_estmail,fecres_ultestmail,cod_ult_estadq,des_ult_estadq,fecres_ultestadq,
  codest,fecest,fecrep
 IF int_flag THEN
  MENU "Información"  ATTRIBUTE( style= "dialog", 
      comment= " La consulta fue cancelada",image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
 CLOSE WINDOW w_histfact   
  RETURN
 END IF
 MESSAGE "Buscando el historico de estados de la facturacion, por favor espere ..." ATTRIBUTE(BLINK)
 LET query_text = " SELECT fc_estados_fac.prefijo,fc_estados_fac.numfac",
      " FROM fc_estados_fac WHERE ", WHERE_info CLIPPED,
      " ORDER BY fc_estados_fac.prefijo,fc_estados_fac.numfac ASC" 
 PREPARE s_shistfact FROM query_text
 DECLARE c_shistfact SCROLL CURSOR FOR s_shistfact
 LET maxnum = 0
 FOREACH c_shistfact INTO tpprefijo, tpnumfac
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_shistfact
  FETCH FIRST c_shistfact INTO tpprefijo, tpnumfac
  LET curr = 1
  CALL hisfactgetcurr( tpprefijo, tpnumfac)
  CALL hisfactshowcurr( curr, maxnum )
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
    FETCH FIRST c_shistfact INTO tpprefijo, tpnumfac
    LET curr = 1
   ELSE
    FETCH NEXT c_shistfact INTO tpprefijo, tpnumfac
    LET curr = curr + 1
   END IF
   CALL hisfactgetcurr( tpprefijo, tpnumfac )
   CALL hisfactshowcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   IF ( curr = 1 ) THEN
    FETCH LAST c_shistfact INTO tpprefijo, tpnumfac
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_shistfact INTO tpprefijo, tpnumfac
    LET curr = curr - 1
   END IF
   CALL hisfactgetcurr( tpprefijo, tpnumfac )
   CALL hisfactshowcurr( curr, maxnum )
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF gfc_estados_fac.prefijo  IS NULL and  gfc_estados_fac.numfac IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_shistfact
 IF int_flag THEN
 CLEAR FORM
  MENU "Informacion " ATTRIBUTE(style= "dialog", 
  comment= "  LA CONSULTA FUE CANCELADA  ",  image= "exclamation")
    COMMAND "Aceptar"
       EXIT MENU
    END MENU
   CLOSE WINDOW w_histfact
   RETURN 
 END IF
 CLOSE WINDOW w_histfact
 RETURN 
END FUNCTION

FUNCTION hisfactgetcurr( tpprefijo, tpnumfac )
 DEFINE tpprefijo LIKE fc_estados_fac.prefijo
 DEFINE tpnumfac LIKE fc_estados_fac.numfac
 INITIALIZE gfc_estados_fac.* TO NULL
 SELECT tpdocumento,prefijo,numfac,fecfactura,cufe,codult_estdisp,des_ult_estdisp,
  fecres_ultestdisp,cod_ult_estdian,des_ult_estdian,fecres_ultestdian,cod_ult_estmail,
  des_ult_estmail,fecres_ultestmail,cod_ult_estadq,des_ult_estadq,fecres_ultestadq, codest,fecest,fecrep
   INTO gfc_estados_fac.*
   FROM fc_estados_fac
  WHERE fc_estados_fac.prefijo = tpprefijo AND
        fc_estados_fac.numfac = tpnumfac 
END FUNCTION 
 
FUNCTION hisfactshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum INTEGER
 IF gfc_estados_fac.prefijo IS NULL AND gfc_estados_fac.numfac IS NULL THEN
  MESSAGE "Localizacion : (
  Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum,
          "/ Existen ", maxnum, ")"
 END IF
 CALL histfacdplyg()
END FUNCTION

FUNCTION histfacdplyg()
--DEFINE x integer
 CLEAR FORM
 DISPLAY BY NAME gfc_estados_fac.tpdocumento THRU gfc_estados_fac.fecrep

 INITIALIZE mfc_factura_m.* TO NULL
  SELECT * INTO mfc_factura_m.* FROM fc_factura_m
  WHERE fc_factura_m.prefijo = gfc_estados_fac.prefijo
  AND fc_factura_m.numfac = gfc_estados_fac.numfac

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

INITIALIZE mfc_estados.* TO NULL
SELECT *  INTO mfc_estados.* FROM fe_estados
WHERE fe_estados.codest =gfc_estados_fac.cod_ult_estadq

IF mfc_estados.tipo='5' THEN
DISPLAY mfc_estados.nombre_est TO des_ult_estadq
END IF

INITIALIZE mfe_estemail.* TO NULL
SELECT *  INTO mfe_estemail.* FROM fe_estados
WHERE fe_estados.codest =gfc_estados_fac.cod_ult_estmail

IF mfe_estemail.tipo='4' THEN
DISPLAY mfe_estemail.nombre_est TO des_ult_estmail
END IF

INITIALIZE mfe_estdisp.* TO NULL
SELECT *  INTO mfe_estdisp.* FROM fe_estados
WHERE fe_estados.codest =gfc_estados_fac.codult_estdisp

IF mfe_estdisp.tipo='1' THEN
DISPLAY mfe_estdisp.nombre_est TO des_ult_estdisp
END IF
 

END FUNCTION


