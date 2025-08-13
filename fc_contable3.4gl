GLOBALS "fc_globales.4gl"
FUNCTION fc_conta3main()
 DEFINE exist SMALLINT
 OPEN WINDOW w_mfc_conta3 AT 1,1 WITH FORM "fc_contable3"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gfc_conta3.* TO NULL
 INITIALIZE tpfc_conta3.* TO NULL
 MENU
  COMMAND "Adiciona" "Adiciona codigos contable" 
    CALL fc_conta3add()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
    CALL fc_conta3dplyg()
  COMMAND "Consulta" "Consulta los codigos contables adicionados" 
    CALL fc_conta3query( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL fc_conta3dplyg()
  COMMAND "Modifica" "Modifica el codigo contable en consultado"
    IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="no existen Codigos En Consulta",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    ELSE
     CALL fc_conta3update()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
    END IF
    CALL fc_conta3dplyg()
  COMMAND "Borrar" "Borra el codigo contable en consulta" 
    IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="no existen codigos en consulta",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    ELSE
     CALL fc_conta3remove()
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CLEAR FORM
      LET exist = FALSE
     END IF
    END IF
    CALL fc_conta3dplyg()
  
  COMMAND key ("esc","S") "Salir" "Retrocede de menu"
   HELP 1
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfc_conta3
END FUNCTION

FUNCTION fc_conta3dplyg()
 DISPLAY BY NAME gfc_conta3.codigo THRU gfc_conta3.codcop_nrs
 DISPLAY mfc_servicios.descripcion to formonly.mdetser
 INITIALIZE mfc_prefijos.* TO NULL
 SELECT * into mfc_prefijos.* FROM fc_prefijos
  WHERE prefijo = gfc_conta3.prefijo
 DISPLAY mfc_prefijos.descripcion TO detprefijo
 INITIALIZE mconta328.* TO NULL
 SELECT * INTO mconta328.* FROM conta328
  WHERE conta328.codconta=gfc_conta3.codconta
 DISPLAY mconta328.detalle TO detconta 
 INITIALIZE mconta24n.* TO NULL
 SELECT * INTO mconta24n.* FROM conta24n
  WHERE conta24n.tipcru=gfc_conta3.tipcru
 DISPLAY mconta24n.detalle TO dettipcru 
 INITIALIZE mconta24n.* TO NULL
 SELECT * INTO mconta24n.* FROM conta24n
  WHERE conta24n.tipcru=gfc_conta3.tipcruu
 DISPLAY mconta24n.detalle TO dettipcru1 
END FUNCTION
 
FUNCTION fc_conta3add()
 DEFINE cnt  SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 DISPLAY "" AT 1,1
 DISPLAY "" AT 2,1
 MESSAGE "Estado : ADICIONANDO UN CODIGO CONTABLE" --AT 1,10 ATTRIBUTE(REVERSE)
 INITIALIZE tpfc_conta3.* TO NULL
 INPUT BY NAME tpfc_conta3.codigo THRU tpfc_conta3.codcop_nrs
  AFTER FIELD codigo
   IF tpfc_conta3.codigo IS NULL THEN
    CALL fc_serviciosval() RETURNING tpfc_conta3.codigo
    DISPLAY BY NAME tpfc_conta3.codigo
    INITIALIZE mfc_servicios.* TO NULL
    select * into mfc_servicios.* from fc_servicios 
     where codigo=tpfc_conta3.codigo
   ELSE
    INITIALIZE mfc_servicios.* TO NULL
    select * into mfc_servicios.* from fc_servicios 
     where codigo=tpfc_conta3.codigo
    if mfc_servicios.codigo is null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Del Servicio no existe ",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE mfc_servicios.* TO NULL
     initialize tpfc_conta3.codigo to null
     next field codigo
    END IF
   END IF
   if mfc_servicios.codigo is null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Del Servicio no existe ",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  

    INITIALIZE mfc_servicios.* TO NULL
    initialize tpfc_conta3.codigo to null
    next field codigo
   END IF
   if mfc_servicios.estado="I" then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Servicio Se Encuentra Inactivo",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    INITIALIZE mfc_servicios.* TO NULL
    initialize tpfc_conta3.codigo to null
    next field codigo
   END IF
   display mfc_servicios.descripcion to mdetser
  
   LET cnt = 0
   SELECT COUNT(*) INTO cnt FROM fc_conta3
    WHERE  fc_conta3.codigo = tpfc_conta3.codigo

   IF cnt <> 0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo contable ya existe",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codigo
   END IF

  AFTER FIELD prefijo
    IF tpfc_conta3.prefijo is null then
      CALL fc_prefijosval() RETURNING tpfc_conta3.prefijo
      IF tpfc_conta3.prefijo is NULL THEN 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " Debe escoger un Prefijo ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD prefijo
      ELSE
        INITIALIZE mfc_prefijos.* TO NULL
        SELECT * INTO mfc_prefijos.*
         FROM fc_prefijos
         WHERE fc_prefijos.prefijo = tpfc_conta3.prefijo
        DISPLAY mfc_prefijos.descripcion TO detprefijo 
      END IF 
    ELSE
     INITIALIZE mfc_prefijos.* TO NULL
     SELECT * INTO mfc_prefijos.*
      FROM fc_prefijos
      WHERE fc_prefijos.prefijo = tpfc_conta3.prefijo
      IF mfc_prefijos.prefijo is NULL THEN 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El Prefijo no existe ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD prefijo
      ELSE 
       DISPLAY mfc_prefijos.descripcion TO detprefijo
      END if     
    END IF  


  AFTER FIELD codconta
   IF tpfc_conta3.codconta IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo de la Contabilidad no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codconta
   ELSE
    INITIALIZE mconta328.* TO NULL
    SELECT * INTO mconta328.* FROM conta328
     WHERE conta328.codconta=tpfc_conta3.codconta
    IF mconta328.codconta IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DE LA CONTABILIDAD NO EXISTE", "stop")
     INITIALIZE tpfc_conta3.codconta TO NULL
     INITIALIZE mconta328.* TO NULL
     next field codconta
    END IF 
   END IF
   DISPLAY mconta328.detalle TO detconta
 

  AFTER FIELD tipcru
   IF tpfc_conta3.tipcru IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Tipo de Cruce no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD tipcru
   ELSE
    INITIALIZE mconta24n.* TO NULL
    SELECT * INTO mconta24n.* FROM conta24n
     WHERE conta24n.tipcru=tpfc_conta3.tipcru
    IF mconta24n.tipcru IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL Tipo de Cruce no existe", "stop")
     INITIALIZE tpfc_conta3.tipcru TO NULL
     INITIALIZE mconta24n.* TO NULL
     next field tipcru
    END IF 
   END IF
   DISPLAY mconta24n.detalle TO dettipcru



  AFTER FIELD tipcruu
   IF tpfc_conta3.tipcruu IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Tipo de Cruce no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD tipcruu
   ELSE
    INITIALIZE mconta24n.* TO NULL
    SELECT * INTO mconta24n.* FROM conta24n
     WHERE conta24n.tipcru=tpfc_conta3.tipcruu
    IF mconta24n.tipcru IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL Tipo de Cruce no existe", "stop")
     INITIALIZE tpfc_conta3.tipcruu TO NULL
     INITIALIZE mconta24n.* TO NULL
     next field tipcruu
    END IF 
   END IF
   DISPLAY mconta24n.detalle TO dettipcru1
   
   AFTER FIELD codcop_ef
   IF tpfc_conta3.codcop_ef IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop_ef
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpfc_conta3.codcop_ef 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpfc_conta3.codcop_ef TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_ef
    END IF 
   END IF

  AFTER FIELD codcop_ba
   IF tpfc_conta3.codcop_ba IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop_ba
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpfc_conta3.codcop_ba 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpfc_conta3.codcop_ba TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_ba
    END IF 
   END IF

  
  AFTER FIELD codcop_cr
   IF tpfc_conta3.codcop_cr IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop_cr
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpfc_conta3.codcop_cr 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpfc_conta3.codcop_cr TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_cr
    END IF 
   END IF


  AFTER FIELD codcop_su
   IF tpfc_conta3.codcop_su IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop_cr
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpfc_conta3.codcop_su 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpfc_conta3.codcop_su TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_su
    END IF 
   END IF

  AFTER FIELD codcop_an
   IF tpfc_conta3.codcop_an IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop_cr
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpfc_conta3.codcop_an 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpfc_conta3.codcop_an TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_an
    END IF 
   END IF

  AFTER FIELD codcop_nrs
   IF tpfc_conta3.codcop_nrs IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop_nrs
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpfc_conta3.codcop_nrs 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpfc_conta3.codcop_nrs TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_nrs
    END IF 
   END IF

   
   AFTER INPUT
   IF int_flag THEN
    EXIT INPUT
   END IF
   LET cnt = 0
   SELECT COUNT(*) INTO cnt FROM fc_conta3
    WHERE  fc_conta3.codigo = tpfc_conta3.codigo

   IF cnt <> 0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo contable ya existe",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codigo
   END IF
  END INPUT
  DISPLAY "" AT 1,10
  DISPLAY "" AT 2,1
  IF int_flag THEN
   CLEAR FORM
        MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="La Adicion fue cancelada",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
--   DISPLAY "LA ADICION FUE CANCELADA" AT 1,10 ATTRIBUTE(REVERSE)
   SLEEP 2
   DISPLAY "" AT 1,10
   INITIALIZE tpfc_conta3.* TO NULL
   RETURN
  END IF
  MESSAGE "ADICIONANDO EL CODIGO CONTABLE" -- AT 1,10 ATTRIBUTE(REVERSE)
  SLEEP 3
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  INSERT INTO fc_conta3 ( codigo, prefijo, codconta, tipcru, tipcruu, codcop_ef, codcop_ba, codcop_cr, codcop_su, codcop_an, codcop_nrs ) 
     VALUES  ( tpfc_conta3.codigo, tpfc_conta3.prefijo, tpfc_conta3.codconta, tpfc_conta3.tipcru, tpfc_conta3.tipcruu, tpfc_conta3.codcop_ef, tpfc_conta3.codcop_ba, tpfc_conta3.codcop_cr, tpfc_conta3.codcop_su, tpfc_conta3.codcop_an, tpfc_conta3.codcop_nrs)
             
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  DISPLAY "" AT 1,10
  IF NOT gerrflag THEN
   COMMIT WORK
   LET gfc_conta3.* = tpfc_conta3.*
   INITIALIZE tpfc_conta3.* TO NULL
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Contable fue Adicionado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
--   DISPLAY "EL CODIGO CONTABLE FUE ADICIONADA" AT 1,10 ATTRIBUTE(REVERSE)
  ELSE
   ROLLBACK WORK
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="La Adicion fue cancelada",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
--  DISPLAY "LA ADICION FUE CANCELADA" AT 1,10 ATTRIBUTE(REVERSE)
  END IF
  SLEEP 2
END FUNCTION

FUNCTION fc_conta3update()
 DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 DISPLAY "" AT 1,1
 DISPLAY "" AT 2,1
 MESSAGE "Estado : " --AT 1,1
 MESSAGE "MODIFICACION DE CODIGOS CONTABLE" --AT 1,10 ATTRIBUTE(REVERSE)
 LET tpfc_conta3.* = gfc_conta3.*
 INPUT BY NAME tpfc_conta3.codconta THRU tpfc_conta3.codcop_nrs WITHOUT DEFAULTS
  AFTER FIELD codconta
   IF tpfc_conta3.codconta IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo de la Contabilidad no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codconta
   ELSE
    INITIALIZE mconta328.* TO NULL
    SELECT * INTO mconta328.* FROM conta328
     WHERE conta328.codconta=tpfc_conta3.codconta
    IF mconta328.codconta IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DE LA CONTABILIDAD NO EXISTE", "stop")
     INITIALIZE tpfc_conta3.codconta TO NULL
     INITIALIZE mconta328.* TO NULL
     next field codconta
    END IF 
   END IF
 
  AFTER FIELD tipcru
   IF tpfc_conta3.tipcru IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Tipo de Cruce no fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD tipcru
   ELSE
    INITIALIZE mconta24n.* TO NULL
    SELECT * INTO mconta24n.* FROM conta24n
     WHERE conta24n.tipcru=tpfc_conta3.tipcru
    IF mconta24n.tipcru IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL Tipo de Cruce no existe", "stop")
     INITIALIZE tpfc_conta3.tipcru TO NULL
     INITIALIZE mconta24n.* TO NULL
     next field tipcru
    END IF 
   END IF
   DISPLAY mconta24n.detalle TO dettipcru

  AFTER FIELD tipcruu
   IF tpfc_conta3.tipcruu IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Tipo de Cruce no fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD tipcruu
   ELSE
    INITIALIZE mconta24n.* TO NULL
    SELECT * INTO mconta24n.* FROM conta24n
     WHERE conta24n.tipcru=tpfc_conta3.tipcruu
    IF mconta24n.tipcru IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL Tipo de Cruce no existe", "stop")
     INITIALIZE tpfc_conta3.tipcruu TO NULL
     INITIALIZE mconta24n.* TO NULL
     next field tipcruu
    END IF 
   END IF
   DISPLAY mconta24n.detalle TO dettipcru1

 
  AFTER FIELD codcop_ef
   IF tpfc_conta3.codcop_ef IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del comprobante no fue digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop_ef
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpfc_conta3.codcop_ef 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "El codigo del comprobante no existe", "stop")
     INITIALIZE tpfc_conta3.codcop_ef TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_ef
    END IF 
   END IF


  AFTER FIELD codcop_ba
   IF tpfc_conta3.codcop_ba IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop_ba
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpfc_conta3.codcop_ba 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "El codigo del comprobante no existe", "stop")
     INITIALIZE tpfc_conta3.codcop_ba TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_ba
    END IF 
   END IF

  AFTER FIELD codcop_cr
   IF tpfc_conta3.codcop_cr IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop_cr
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpfc_conta3.codcop_cr 
    IF mniif148.codcop IS NULL THEN
	  CALL FGL_WINMESSAGE( "Administrador", "El codigo del comprobante no existe", "stop")
     INITIALIZE tpfc_conta3.codcop_cr TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_cr
    END IF 
   END IF

AFTER FIELD codcop_su
   IF tpfc_conta3.codcop_su IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop_cr
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpfc_conta3.codcop_su 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpfc_conta3.codcop_su TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_su
    END IF 
   END IF

  AFTER FIELD codcop_an
   IF tpfc_conta3.codcop_an IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop_cr
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpfc_conta3.codcop_an 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpfc_conta3.codcop_an TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_an
    END IF 
   END IF

  AFTER FIELD codcop_nrs
   IF tpfc_conta3.codcop_nrs IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop_nrs
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpfc_conta3.codcop_nrs 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpfc_conta3.codcop_nrs TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_nrs
    END IF 
   END IF

   
  AFTER INPUT
   IF int_flag THEN
    EXIT INPUT
   END IF
   IF tpfc_conta3.codigo <> gfc_conta3.codigo then
    LET cnt = 0
    SELECT COUNT(*) INTO cnt FROM fc_conta3
     WHERE  fc_conta3.codigo = tpfc_conta3.codigo
    IF cnt <> 0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Contable ya existe ",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     NEXT FIELD codigo
    END IF
   END IF
 END INPUT
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 IF int_flag THEN
  CLEAR FORM
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="La Modificacion fue cancelada",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
--  DISPLAY "LA MODIFICACION FUE CANCELADA" AT 1,10 ATTRIBUTE(REVERSE)
  SLEEP 2
  DISPLAY "" AT 1,10
  INITIALIZE tpfc_conta3.* TO NULL
  RETURN
 END IF
 MESSAGE "MODIFICANDO EL CODIGO CONTABLE" --AT 1,10 ATTRIBUTE(REVERSE)
 LET gerrflag = FALSE
 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 UPDATE fc_conta3 
   SET ( codconta, tipcru, tipcruu, codcop_ef, codcop_ba, codcop_cr, codcop_su, codcop_an, codcop_nrs ) 
    =  ( tpfc_conta3.codconta, tpfc_conta3.tipcru, tpfc_conta3.tipcruu, tpfc_conta3.codcop_ef, tpfc_conta3.codcop_ba, tpfc_conta3.codcop_cr, tpfc_conta3.codcop_su, tpfc_conta3.codcop_an, tpfc_conta3.codcop_nrs )
  WHERE  fc_conta3.codigo = gfc_conta3.codigo
 
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 DISPLAY "" AT 1,10
 IF NOT gerrflag THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Contable fue modificado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
 
--  DISPLAY "EL CODIGO CONTABLE FUE MODIFICADO" AT 1,10 ATTRIBUTE(REVERSE)
  COMMIT WORK
 ELSE
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="La modificacion fue cancelada",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  

--  DISPLAY "LA MODIFICACION FUE CANCELADA" AT 1,10 ATTRIBUTE(REVERSE)
  ROLLBACK WORK
 END IF
 IF NOT gerrflag THEN 
  LET gfc_conta3.* = tpfc_conta3.*
 END IF
 SLEEP 2
END FUNCTION

FUNCTION fc_conta3remove()
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 DISPLAY "" AT 1,1
 DISPLAY "" AT 2,1
 MESSAGE "Estado : RETIRO DE CODIGOS CONTABLES" 
 PROMPT "Seguro de borrar el codigo contable (s/n)? " FOR CHAR answer HELP 1117
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO EL CODIGO CONTABLE" 
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  DELETE FROM fc_conta3
   WHERE  fc_conta3.codigo = gfc_conta3.codigo

  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  DISPLAY "" AT 1,10
  IF NOT gerrflag THEN 
   INITIALIZE gfc_conta3.* TO NULL
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Contable fue retirado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
   COMMIT WORK
  ELSE
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Retiro fue cancelado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
   ROLLBACK WORK
  END IF
 ELSE
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Retiro fue cancelado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
  LET int_flag = TRUE
 END IF
 SLEEP 2
END FUNCTION

FUNCTION fc_conta3getcurr( tpcodigo )
 DEFINE tpcodigo LIKE fc_conta3.codigo
 INITIALIZE gfc_conta3.* TO NULL
 SELECT fc_conta3.codigo, fc_conta3.prefijo, fc_conta3.codconta, fc_conta3.tipcru, fc_conta3.tipcruu,
   fc_conta3.codcop_ef, fc_conta3.codcop_ba, fc_conta3.codcop_cr, fc_conta3.codcop_su, fc_conta3.codcop_an, fc_conta3.codcop_nrs
  INTO gfc_conta3.*
  FROM fc_conta3
  WHERE fc_conta3.codigo = tpcodigo

  initialize mfc_servicios.* to null
  select * into mfc_servicios.* from fc_servicios 
   where codigo=gfc_conta3.codigo
  
END FUNCTION

FUNCTION fc_conta3showcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 DISPLAY "" AT glastline,1
 IF gfc_conta3.codigo IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum,
          "/ existen ", maxnum, ")" 
 END IF
 CALL fc_conta3dplyg()
END FUNCTION

FUNCTION fc_conta3query( exist )
 DEFINE where_info, query_text CHAR(400),
 answer CHAR(1),
 exist, curr, maxnum  SMALLINT,
 tpcodigo LIKE fc_conta3.codigo

 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 DISPLAY "" AT 1,1
 DISPLAY "" AT 2,1
 MESSAGE "Estado : CONSULTA DE CODIGO(S) CONTABLE" --AT 1,10 ATTRIBUTE(REVERSE)
 CLEAR FORM
 CONSTRUCT where_info
  ON codigo, prefijo, codconta, tipcru, tipcruu,
   codcop_ef, codcop_ba, codcop_cr, codcop_su, codcop_an, codcop_nrs
   FROM codigo, prefijo, codconta, tipcru, tipcruu,
   codcop_ef, codcop_ba, codcop_cr, codcop_su, codcop_an, codcop_nrs
 IF int_flag THEN
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="La Consulta fue cancelada",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
    END MENU  
  SLEEP 2
  DISPLAY "" AT 1,10
  RETURN exist
 END IF
 MESSAGE "Buscando el codigo(s) contable, por favor espere ..." --AT 2,1 
 LET query_text = " SELECT fc_conta3.codigo",
                  " FROM fc_conta3 WHERE ", where_info CLIPPED,
                  " ORDER BY fc_conta3.codigo ASC" 
 PREPARE s_sfc_conta3 FROM query_text
 DECLARE c_sfc_conta3 SCROLL CURSOR FOR s_sfc_conta3
 LET maxnum = 0
 FOREACH c_sfc_conta3 INTO tpcodigo
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_sfc_conta3
  FETCH FIRST c_sfc_conta3 INTO tpcodigo
  LET curr = 1
  CALL fc_conta3getcurr( tpcodigo )
  CALL fc_conta3showcurr( curr, maxnum )
 ELSE
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     comment="El Codigo contable no existe",
     image= "exclamation")
     COMMAND "Aceptar"
        EXIT MENU
   END MENU  
  LET int_flag = TRUE
  sleep 4
  RETURN exist
 END IF
 DISPLAY "" AT 2,1
 MENU "CONSULTA"
  COMMAND "Inmediato" "Se desplaza al siguiente registro"
   HELP 5
   IF ( curr = maxnum ) THEN
    FETCH FIRST c_sfc_conta3 INTO tpcodigo
    LET curr = 1
   ELSE
    FETCH NEXT c_sfc_conta3 INTO tpcodigo
    LET curr = curr + 1
   END IF
   CALL fc_conta3getcurr( tpcodigo )
   CALL fc_conta3showcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al registro anterior"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_sfc_conta3 INTO tpcodigo
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_sfc_conta3 INTO tpcodigo
    LET curr = curr - 1
   END IF
   CALL fc_conta3getcurr( tpcodigo )
   CALL fc_conta3showcurr( curr, maxnum )
  COMMAND "Modifica" "Modifica el codigo contable en consulta" 
    IF gfc_conta3.codigo IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_conta3
     CALL fc_conta3update()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL fc_conta3getcurr( tpcodigo )
     CALL fc_conta3showcurr( curr, maxnum )
     OPEN c_sfc_conta3
    END IF
  COMMAND "Borrar" "Borra el codigo contable en consulta" 
    IF gfc_conta3.codigo IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_conta3
     CALL fc_conta3remove()
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CALL fc_conta3showcurr( curr, maxnum )
     END IF
     OPEN c_sfc_conta3
    END IF
  COMMAND key("esc","S") "Salir" "Retocede de menu"
   HELP 1
   IF gfc_conta3.codigo IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sfc_conta3
 DISPLAY "" AT glastline,1
 RETURN exist
END FUNCTION
