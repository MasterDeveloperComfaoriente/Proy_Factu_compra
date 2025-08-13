GLOBALS "fc_globales.4gl"
FUNCTION fc_conta1main()
 DEFINE exist SMALLINT
 OPEN WINDOW w_mfc_conta1 AT 1,1 WITH FORM "fc_contable1"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gfc_conta1.* TO NULL
 INITIALIZE tpfc_conta1.* TO NULL
 MENU
  COMMAND "Adiciona" "Adiciona codigos contable" 
    CALL fc_conta1add()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
    CALL fc_conta1dplyg()
  COMMAND "Consulta" "Consulta los codigos contables adicionados" 
    CALL fc_conta1query( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL fc_conta1dplyg()
  COMMAND "Modifica" "Modifica el codigo contable en consultado"
    IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="No Existen Codigos En Consulta",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    ELSE
     CALL fc_conta1update()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
    END IF
    CALL fc_conta1dplyg()
  COMMAND "Borrar" "Borra el codigo contable en consulta" 
    IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="No Existen Codigos En Consulta",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    ELSE
     CALL fc_conta1remove()
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CLEAR FORM
      LET exist = FALSE
     END IF
    END IF
    CALL fc_conta1dplyg()
  COMMAND "Reporte/Gen" "Reporte General de Enlaces Contables"
    CALL rep_conta()
  COMMAND "Reporte/Pre" "Reporte x prefijo de Enlaces Contables"
    CALL rep_conta2()  
  COMMAND key ("esc","S") "Salir" "Retrocede de menu"
   HELP 1
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfc_conta1
END FUNCTION

FUNCTION fc_conta1dplyg()
 DISPLAY BY NAME gfc_conta1.codigo THRU gfc_conta1.cencoscars
 DISPLAY mfc_servicios.descripcion to formonly.mdetser
 DISPLAY mcon233iva.detalle to formonly.detalle1
 DISPLAY mcon147iva.detalle to formonly.detalle2
 DISPLAY mcon233ing.detalle to formonly.detalle3
 DISPLAY mcon147ing.detalle to formonly.detalle4
 DISPLAY mcon233impc.detalle to formonly.detalle5
 DISPLAY mcon147impc.detalle to formonly.detalle6
 DISPLAY mcon233car.detalle to formonly.detalle7
 DISPLAY mcon147car.detalle to formonly.detalle8
 DISPLAY mcon233subsi.detalle to formonly.detalle9
 DISPLAY mcon147subsi.detalle to formonly.detalle10
 DISPLAY mcon233ant.detalle to formonly.detalle11
 DISPLAY mcon147ant.detalle to formonly.detalle12
 DISPLAY mcon233caja.detalle to formonly.detalle13
 DISPLAY mcon147caja.detalle to formonly.detalle14
 DISPLAY mcon233banco.detalle to formonly.detalle15
 DISPLAY mcon147banco.detalle to formonly.detalle16
 DISPLAY mcon233cars.detalle to formonly.detalle17
 DISPLAY mcon147cars.detalle to formonly.detalle18
 
END FUNCTION
 
FUNCTION fc_conta1add()
 DEFINE cnt  SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 DISPLAY "" AT 1,1
 DISPLAY "" AT 2,1
 MESSAGE "Estado : " --AT 1,1
 MESSAGE "ADICIONANDO UN CODIGO CONTABLE" --AT 1,10 ATTRIBUTE(REVERSE)
 INITIALIZE tpfc_conta1.* TO NULL
 INPUT BY NAME tpfc_conta1.codigo THRU tpfc_conta1.cencoscars
  AFTER FIELD codigo
   IF tpfc_conta1.codigo IS NULL THEN
    CALL fc_serviciosval() RETURNING tpfc_conta1.codigo
    DISPLAY BY NAME tpfc_conta1.codigo
    INITIALIZE mfc_servicios.* TO NULL
    select * into mfc_servicios.* from fc_servicios 
     where codigo=tpfc_conta1.codigo
   ELSE
    INITIALIZE mfc_servicios.* TO NULL
    select * into mfc_servicios.* from fc_servicios 
     where codigo=tpfc_conta1.codigo
    if mfc_servicios.codigo is null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Del Servicio No Existe ",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE mfc_servicios.* TO NULL
     initialize tpfc_conta1.codigo to null
     next field codigo
    END IF
   END IF
   if mfc_servicios.codigo is null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Del Servicio No Existe ",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  

    INITIALIZE mfc_servicios.* TO NULL
    initialize tpfc_conta1.codigo to null
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
    initialize tpfc_conta1.codigo to null
    next field codigo
   END IF
   display mfc_servicios.descripcion to mdetser
  
   LET cnt = 0
   SELECT COUNT(*) INTO cnt FROM fc_conta1
    WHERE  fc_conta1.codigo = tpfc_conta1.codigo

   IF cnt <> 0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El parametro contable ya Existe",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codigo
   END IF
  
  AFTER FIELD auxiliariva
   IF tpfc_conta1.auxiliariva = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliariva = villac02val()
    LET tpfc_conta1.auxiliariva=tpfc_conta1.auxiliariva clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliariva
   END IF
   IF tpfc_conta1.auxiliariva IS NOT NULL THEN
    LET tpfc_conta1.auxiliariva=tpfc_conta1.auxiliariva clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliariva 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliariva TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliariva
    END IF
   END IF
   IF tpfc_conta1.auxiliariva IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliariva
    DISPLAY mniif233.detalle to formonly.detalle1
   END IF
  AFTER FIELD cencosiva
   IF tpfc_conta1.cencosiva = "?" THEN
    LET tpfc_conta1.cencosiva = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencosiva
   END IF
   IF tpfc_conta1.cencosiva IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencosiva
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencosiva TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencosiva
    END IF
   END IF
   IF tpfc_conta1.cencosiva IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencosiva
    DISPLAY mniif147.detalle to formonly.detalle2
   END IF

  AFTER FIELD auxiliarimpc
   IF tpfc_conta1.auxiliarimpc = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarimpc = villac02val()
    LET tpfc_conta1.auxiliarimpc=tpfc_conta1.auxiliarimpc clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarimpc
   END IF
   IF tpfc_conta1.auxiliarimpc IS NOT NULL THEN
    LET tpfc_conta1.auxiliarimpc=tpfc_conta1.auxiliarimpc clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarimpc 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarimpc TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarimpc
    END IF
   END IF
   IF tpfc_conta1.auxiliarimpc IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarimpc
    DISPLAY mniif233.detalle to formonly.detalle5
   END IF
  AFTER FIELD cencosimpc
   IF tpfc_conta1.cencosimpc = "?" THEN
    LET tpfc_conta1.cencosimpc = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencosimpc
   END IF
   IF tpfc_conta1.cencosimpc IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencosimpc
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencosimpc TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencosimpc
    END IF
   END IF
   IF tpfc_conta1.cencosimpc IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencosimpc
    DISPLAY mniif147.detalle to formonly.detalle6
   END IF

  AFTER FIELD auxiliaring
   IF tpfc_conta1.auxiliaring = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliaring = villac02val()
    LET tpfc_conta1.auxiliaring=tpfc_conta1.auxiliaring clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliaring
   END IF
   IF tpfc_conta1.auxiliaring IS NOT NULL THEN
    LET tpfc_conta1.auxiliaring=tpfc_conta1.auxiliaring clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliaring 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliaring TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliaring
    END IF
   END IF
   IF tpfc_conta1.auxiliaring IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliaring
    DISPLAY mniif233.detalle to formonly.detalle3
   END IF
  AFTER FIELD cencosing
   IF tpfc_conta1.cencosing = "?" THEN
    LET tpfc_conta1.cencosing = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencosing
   END IF
   IF tpfc_conta1.cencosing IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencosing
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencosing TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencosing
    END IF
   END IF
   IF tpfc_conta1.cencosing IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencosing
    DISPLAY mniif147.detalle to formonly.detalle4
   END IF

AFTER FIELD auxiliarcar
   IF tpfc_conta1.auxiliarcar = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarcar = villac02val()
    LET tpfc_conta1.auxiliarcar=tpfc_conta1.auxiliarcar clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarcar
   END IF
   IF tpfc_conta1.auxiliarcar IS NOT NULL THEN
    LET tpfc_conta1.auxiliarcar=tpfc_conta1.auxiliarcar clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarcar 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarcar TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarcar
    END IF
   END IF
   IF tpfc_conta1.auxiliarcar IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarcar
    DISPLAY mniif233.detalle to formonly.detalle7
   END IF
  AFTER FIELD cencoscar
   IF tpfc_conta1.cencoscar = "?" THEN
    LET tpfc_conta1.cencoscar = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencoscar
   END IF
   IF tpfc_conta1.cencoscar IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencoscar
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencoscar TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencoscar
    END IF
   END IF
   IF tpfc_conta1.cencoscar IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencoscar
    DISPLAY mniif147.detalle to formonly.detalle8
   END IF
  AFTER FIELD auxiliarsubsi
   IF tpfc_conta1.auxiliarsubsi = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarsubsi = villac02val()
    LET tpfc_conta1.auxiliarsubsi=tpfc_conta1.auxiliarsubsi clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarsubsi
   END IF
   IF tpfc_conta1.auxiliarsubsi IS NOT NULL THEN
    LET tpfc_conta1.auxiliarsubsi=tpfc_conta1.auxiliarsubsi clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarsubsi 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarsubsi TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarsubsi
    END IF
   END IF
   IF tpfc_conta1.auxiliarsubsi IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarsubsi
    DISPLAY mniif233.detalle to formonly.detalle9
   END IF
  AFTER FIELD cencossubsi
   IF tpfc_conta1.cencossubsi = "?" THEN
    LET tpfc_conta1.cencossubsi = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencossubsi
   END IF
   IF tpfc_conta1.cencossubsi IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencossubsi
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencossubsi TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencossubsi
    END IF
   END IF
   IF tpfc_conta1.cencossubsi IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencossubsi
    DISPLAY mniif147.detalle to formonly.detalle10
   END IF

  AFTER FIELD auxiliarant
   IF tpfc_conta1.auxiliarant = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarant = villac02val()
    LET tpfc_conta1.auxiliarant=tpfc_conta1.auxiliarant clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarant
   END IF
   IF tpfc_conta1.auxiliarant IS NOT NULL THEN
    LET tpfc_conta1.auxiliarant=tpfc_conta1.auxiliarant clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarant 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarant TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarant
    END IF
   END IF
   IF tpfc_conta1.auxiliarant IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarant
    DISPLAY mniif233.detalle to formonly.detalle11
   END IF
  AFTER FIELD cencosant
   IF tpfc_conta1.cencosant = "?" THEN
    LET tpfc_conta1.cencosant = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencosant
   END IF
   IF tpfc_conta1.cencosant IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencosant
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencosant TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencosant
    END IF
   END IF
   IF tpfc_conta1.cencosant IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencosant
    DISPLAY mniif147.detalle to formonly.detalle12
   END IF


  AFTER FIELD auxiliarcaja
   IF tpfc_conta1.auxiliarcaja = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarcaja = villac02val()
    LET tpfc_conta1.auxiliarcaja=tpfc_conta1.auxiliarcaja clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarcaja
   END IF
   IF tpfc_conta1.auxiliarcaja IS NOT NULL THEN
    LET tpfc_conta1.auxiliarcaja=tpfc_conta1.auxiliarcaja clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarcaja 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarcaja TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarcaja
    END IF
   END IF
   IF tpfc_conta1.auxiliarcaja IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarcaja
    DISPLAY mniif233.detalle to formonly.detalle13
   END IF
  AFTER FIELD cencoscaja
   IF tpfc_conta1.cencoscaja = "?" THEN
    LET tpfc_conta1.cencoscaja = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencoscaja
   END IF
   IF tpfc_conta1.cencoscaja IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencoscaja
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencoscaja TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencoscaja
    END IF
   END IF
   IF tpfc_conta1.cencoscaja IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencoscaja
    DISPLAY mniif147.detalle to formonly.detalle14
   END IF
   AFTER FIELD auxiliarbanco
   IF tpfc_conta1.auxiliarbanco = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarbanco = villac02val()
    LET tpfc_conta1.auxiliarbanco=tpfc_conta1.auxiliarbanco clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarbanco
   END IF
   IF tpfc_conta1.auxiliarbanco IS NOT NULL THEN
    LET tpfc_conta1.auxiliarbanco=tpfc_conta1.auxiliarbanco clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarbanco 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarbanco TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarbanco
    END IF
   END IF
   IF tpfc_conta1.auxiliarbanco IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarbanco
    DISPLAY mniif233.detalle to formonly.detalle15
   END IF
  AFTER FIELD cencosbanco
   IF tpfc_conta1.cencosbanco = "?" THEN
    LET tpfc_conta1.cencosbanco = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencosbanco
   END IF
   IF tpfc_conta1.cencosbanco IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencosbanco
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencosbanco TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencosbanco
    END IF
   END IF
   IF tpfc_conta1.cencosbanco IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencosbanco
    DISPLAY mniif147.detalle to formonly.detalle16
   END IF
  AFTER FIELD auxiliarcars
   IF tpfc_conta1.auxiliarcars = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarcars = villac02val()
    LET tpfc_conta1.auxiliarcars=tpfc_conta1.auxiliarcars clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarcars
   END IF
   IF tpfc_conta1.auxiliarcars IS NOT NULL THEN
    LET tpfc_conta1.auxiliarcars=tpfc_conta1.auxiliarcars clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarcars 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarcars TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarcars
    END IF
   END IF
   IF tpfc_conta1.auxiliarcars IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarcars
    DISPLAY mniif233.detalle to formonly.detalle17
   END IF
  AFTER FIELD cencoscars
   IF tpfc_conta1.cencoscars = "?" THEN
    LET tpfc_conta1.cencoscars = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencoscars
   END IF
   IF tpfc_conta1.cencoscars IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencoscars
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencoscars TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencoscars
    END IF
   END IF
   IF tpfc_conta1.cencoscars IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencoscars
    DISPLAY mniif147.detalle to formonly.detalle18
   END IF
   AFTER INPUT
   IF int_flag THEN
    EXIT INPUT
   END IF
   LET cnt = 0
   SELECT COUNT(*) INTO cnt FROM fc_conta1
    WHERE  fc_conta1.codigo = tpfc_conta1.codigo

   IF cnt <> 0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo contable Ya Existe",
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
       comment="La Adicion Fue Cancelada",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
--   DISPLAY "LA ADICION FUE CANCELADA" AT 1,10 ATTRIBUTE(REVERSE)
   SLEEP 2
   DISPLAY "" AT 1,10
   INITIALIZE tpfc_conta1.* TO NULL
   RETURN
  END IF
  MESSAGE "ADICIONANDO EL CODIGO CONTABLE" -- AT 1,10 ATTRIBUTE(REVERSE)
  SLEEP 3
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  INSERT INTO fc_conta1 ( codigo, auxiliariva, cencosiva, auxiliarimpc, cencosimpc,
    auxiliaring, cencosing, auxiliarcar, cencoscar, auxiliarsubsi, cencossubsi,
    auxiliarant, cencosant, auxiliarcaja, cencoscaja, auxiliarbanco, cencosbanco, auxiliarcars, cencoscars)
   VALUES  ( tpfc_conta1.codigo, 
             tpfc_conta1.auxiliariva,  tpfc_conta1.cencosiva, 
             tpfc_conta1.auxiliarimpc, tpfc_conta1.cencosimpc, 
             tpfc_conta1.auxiliaring,  tpfc_conta1.cencosing, 
             tpfc_conta1.auxiliarcar, tpfc_conta1.cencoscar,
             tpfc_conta1.auxiliarsubsi, tpfc_conta1.cencossubsi,
             tpfc_conta1.auxiliarant, tpfc_conta1.cencosant,
             tpfc_conta1.auxiliarcaja, tpfc_conta1.cencoscaja,
             tpfc_conta1.auxiliarbanco, tpfc_conta1.cencosbanco, tpfc_conta1.auxiliarcars, tpfc_conta1.cencoscars )
             
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  DISPLAY "" AT 1,10
  IF NOT gerrflag THEN
   COMMIT WORK
   LET gfc_conta1.* = tpfc_conta1.*
   INITIALIZE tpfc_conta1.* TO NULL
     MENU "Informacion" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Contable Fue Adicionado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
  ELSE
   ROLLBACK WORK
     MENU "Informacion" ATTRIBUTE(style= "dialog", 
       comment="La Adicion fue Cancelada",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
  END IF
END FUNCTION

FUNCTION fc_conta1update()
 DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 DISPLAY "" AT 1,1
 DISPLAY "" AT 2,1
 MESSAGE "Estado : MODIFICACION DE CODIGOS CONTABLE" --AT 1,10 ATTRIBUTE(REVERSE)
 LET tpfc_conta1.* = gfc_conta1.*
 INPUT BY NAME tpfc_conta1.auxiliariva THRU tpfc_conta1.cencoscars WITHOUT DEFAULTS
 {
  AFTER FIELD codigo
   IF tpfc_conta1.codigo IS NULL THEN
    CALL fc_serviciosval() RETURNING tpfc_conta1.codigo
    DISPLAY BY NAME tpfc_conta1.codigo
    INITIALIZE mfc_servicios.* TO NULL
    select * into mfc_servicios.* from fc_servicios 
     where codigo=tpfc_conta1.codigo
   ELSE
    INITIALIZE mfc_servicios.* TO NULL
    select * into mfc_servicios.* from fc_servicios 
     where codigo=tpfc_conta1.codigo
    if mfc_servicios.codigo is null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Del Servicio No Existe",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE mfc_servicios.* TO NULL
     initialize tpfc_conta1.codigo to null
     next field codigo
    END IF
   END IF
   if mfc_servicios.codigo is null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Del Servicio No Existe",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    INITIALIZE mfc_servicios.* TO NULL
    initialize tpfc_conta1.codigo to null
    next field codigo
   END IF
   if mfc_servicios.estado="I" then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Servicio se encuentra Inactivo",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  

    INITIALIZE mfc_servicios.* TO NULL
    initialize tpfc_conta1.codigo to null
    next field codigo
   END IF
   display mfc_servicios.descripcion to mdetser
   IF tpfc_conta1.codigo <> gfc_conta1.codigo then
    LET cnt = 0
    SELECT COUNT(*) INTO cnt FROM fc_conta1
     WHERE  fc_conta1.codigo = tpfc_conta1.codigo
    IF cnt <> 0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Contable Ya Existe",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     NEXT FIELD codigo
    END IF
   END IF

   }
   
  AFTER FIELD auxiliariva
   IF tpfc_conta1.auxiliariva = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliariva = villac02val()
    LET tpfc_conta1.auxiliariva=tpfc_conta1.auxiliariva clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliariva
   END IF
   IF tpfc_conta1.auxiliariva IS NOT NULL THEN
    LET tpfc_conta1.auxiliariva=tpfc_conta1.auxiliariva clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliariva 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar contable No fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliariva TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliariva
    END IF
   END IF
   IF tpfc_conta1.auxiliariva IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliariva
    DISPLAY mniif233.detalle to formonly.detalle1
   END IF
  AFTER FIELD cencosiva
   IF tpfc_conta1.cencosiva = "?" THEN
    LET tpfc_conta1.cencosiva = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencosiva
   END IF
   IF tpfc_conta1.cencosiva IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencosiva
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencosiva TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencosiva
    END IF
   END IF
   IF tpfc_conta1.cencosiva IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencosiva
    DISPLAY mniif147.detalle to formonly.detalle2
   END IF

 AFTER FIELD auxiliarimpc
   IF tpfc_conta1.auxiliarimpc = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarimpc = villac02val()
    LET tpfc_conta1.auxiliarimpc=tpfc_conta1.auxiliarimpc clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarimpc
   END IF
   IF tpfc_conta1.auxiliarimpc IS NOT NULL THEN
    LET tpfc_conta1.auxiliarimpc=tpfc_conta1.auxiliarimpc clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarimpc 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarimpc TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarimpc
    END IF
   END IF
   IF tpfc_conta1.auxiliarimpc IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarimpc
    DISPLAY mniif233.detalle to formonly.detalle5
   END IF
  AFTER FIELD cencosimpc
   IF tpfc_conta1.cencosimpc = "?" THEN
    LET tpfc_conta1.cencosimpc = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencosimpc
   END IF
   IF tpfc_conta1.cencosimpc IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencosimpc
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencosimpc TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencosimpc
    END IF
   END IF
   IF tpfc_conta1.cencosimpc IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencosimpc
    DISPLAY mniif147.detalle to formonly.detalle6
   END IF
  AFTER FIELD auxiliaring
   IF tpfc_conta1.auxiliaring = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliaring = villac02val()
    LET tpfc_conta1.auxiliaring=tpfc_conta1.auxiliaring clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliaring
   END IF
   IF tpfc_conta1.auxiliaring IS NOT NULL THEN
    LET tpfc_conta1.auxiliaring=tpfc_conta1.auxiliaring clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliaring 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliaring TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliaring
    END IF
   END IF
   IF tpfc_conta1.auxiliaring IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliaring
    DISPLAY mniif233.detalle to formonly.detalle3
   END IF
  AFTER FIELD cencosing
   IF tpfc_conta1.cencosing = "?" THEN
    LET tpfc_conta1.cencosing = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencosing
   END IF
   IF tpfc_conta1.cencosing IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencosing
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro De Costo No fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencosing TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencosing
    END IF
   END IF
   IF tpfc_conta1.cencosing IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencosing
    DISPLAY mniif147.detalle to formonly.detalle5
   END IF

   AFTER FIELD auxiliarcar
   IF tpfc_conta1.auxiliarcar = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarcar = villac02val()
    LET tpfc_conta1.auxiliarcar=tpfc_conta1.auxiliarcar clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarcar
   END IF
   IF tpfc_conta1.auxiliarcar IS NOT NULL THEN
    LET tpfc_conta1.auxiliarcar=tpfc_conta1.auxiliarcar clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarcar 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarcar TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarcar
    END IF
   END IF
   IF tpfc_conta1.auxiliarcar IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarcar
    DISPLAY mniif233.detalle to formonly.detalle7
   END IF
  AFTER FIELD cencoscar
   IF tpfc_conta1.cencoscar = "?" THEN
    LET tpfc_conta1.cencoscar = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencoscar
   END IF
   IF tpfc_conta1.cencoscar IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencoscar
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencoscar TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencoscar
    END IF
   END IF
   IF tpfc_conta1.cencoscar IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencoscar
    DISPLAY mniif147.detalle to formonly.detalle8
   END IF

  AFTER FIELD auxiliarsubsi
   IF tpfc_conta1.auxiliarsubsi = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarsubsi = villac02val()
    LET tpfc_conta1.auxiliarsubsi=tpfc_conta1.auxiliarsubsi clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarsubsi
   END IF
   IF tpfc_conta1.auxiliarsubsi IS NOT NULL THEN
    LET tpfc_conta1.auxiliarsubsi=tpfc_conta1.auxiliarsubsi clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarsubsi 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarsubsi TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarsubsi
    END IF
   END IF
   IF tpfc_conta1.auxiliarsubsi IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarsubsi
    DISPLAY mniif233.detalle to formonly.detalle9
   END IF
  AFTER FIELD cencossubsi
   IF tpfc_conta1.cencossubsi = "?" THEN
    LET tpfc_conta1.cencossubsi = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencossubsi
   END IF
   IF tpfc_conta1.cencossubsi IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencossubsi
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencossubsi TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencossubsi
    END IF
   END IF
   IF tpfc_conta1.cencossubsi IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencossubsi
    DISPLAY mniif147.detalle to formonly.detalle10
   END IF

  AFTER FIELD auxiliarant
   IF tpfc_conta1.auxiliarant = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarant = villac02val()
    LET tpfc_conta1.auxiliarant=tpfc_conta1.auxiliarant clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarant
   END IF
   IF tpfc_conta1.auxiliarant IS NOT NULL THEN
    LET tpfc_conta1.auxiliarant=tpfc_conta1.auxiliarant clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarant 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarant TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarant
    END IF
   END IF
   IF tpfc_conta1.auxiliarant IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarant
    DISPLAY mniif233.detalle to formonly.detalle11
   END IF
  AFTER FIELD cencosant
   IF tpfc_conta1.cencosant = "?" THEN
    LET tpfc_conta1.cencosant = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencosant
   END IF
   IF tpfc_conta1.cencosant IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencosant
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencosant TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencosant
    END IF
   END IF
   IF tpfc_conta1.cencosant IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencosant
    DISPLAY mniif147.detalle to formonly.detalle12
   END IF

   AFTER FIELD auxiliarcaja
   IF tpfc_conta1.auxiliarcaja = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarcaja = villac02val()
    LET tpfc_conta1.auxiliarcaja=tpfc_conta1.auxiliarcaja clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarcaja
   END IF
   IF tpfc_conta1.auxiliarcaja IS NOT NULL THEN
    LET tpfc_conta1.auxiliarcaja=tpfc_conta1.auxiliarcaja clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarcaja 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarcaja TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarcaja
    END IF
   END IF
   IF tpfc_conta1.auxiliarcaja IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarcaja
    DISPLAY mniif233.detalle to formonly.detalle13
   END IF
  AFTER FIELD cencoscaja
   IF tpfc_conta1.cencoscaja = "?" THEN
    LET tpfc_conta1.cencoscaja = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencoscaja
   END IF
   IF tpfc_conta1.cencoscaja IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencoscaja
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencoscaja TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencoscaja
    END IF
   END IF
   IF tpfc_conta1.cencoscaja IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencoscaja
    DISPLAY mniif147.detalle to formonly.detalle14
   END IF



   AFTER FIELD auxiliarbanco
   IF tpfc_conta1.auxiliarbanco = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarbanco = villac02val()
    LET tpfc_conta1.auxiliarbanco=tpfc_conta1.auxiliarbanco clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarbanco
   END IF
   IF tpfc_conta1.auxiliarbanco IS NOT NULL THEN
    LET tpfc_conta1.auxiliarbanco=tpfc_conta1.auxiliarbanco clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarbanco 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarbanco TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarbanco
    END IF
   END IF
   IF tpfc_conta1.auxiliarbanco IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarbanco
    DISPLAY mniif233.detalle to formonly.detalle15
   END IF
  AFTER FIELD cencosbanco
   IF tpfc_conta1.cencosbanco = "?" THEN
    LET tpfc_conta1.cencosbanco = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencosbanco
   END IF
   IF tpfc_conta1.cencosbanco IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencosbanco
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencosbanco TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencosbanco
    END IF
   END IF
   IF tpfc_conta1.cencosbanco IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencosbanco
    DISPLAY mniif147.detalle to formonly.detalle16
   END IF


  AFTER FIELD auxiliarcars
   IF tpfc_conta1.auxiliarcars = "?" THEN
    LET op="1"
    LET tpfc_conta1.auxiliarcars = villac02val()
    LET tpfc_conta1.auxiliarcars=tpfc_conta1.auxiliarcars clipped,"000000"
    DISPLAY BY NAME tpfc_conta1.auxiliarcars
   END IF
   IF tpfc_conta1.auxiliarcars IS NOT NULL THEN
    LET tpfc_conta1.auxiliarcars=tpfc_conta1.auxiliarcars clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpfc_conta1.auxiliarcars 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.auxiliarcars TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarcars
    END IF
   END IF
   IF tpfc_conta1.auxiliarcars IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpfc_conta1.auxiliarcars
    DISPLAY mniif233.detalle to formonly.detalle17
   END IF
  AFTER FIELD cencoscars
   IF tpfc_conta1.cencoscars = "?" THEN
    LET tpfc_conta1.cencoscars = villac06val()
    DISPLAY BY NAME tpfc_conta1.cencoscars
   END IF
   IF tpfc_conta1.cencoscars IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpfc_conta1.cencoscars
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No Fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpfc_conta1.cencoscars TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencoscars
    END IF
   END IF
   IF tpfc_conta1.cencoscars IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpfc_conta1.cencoscars
    DISPLAY mniif147.detalle to formonly.detalle18
   END IF



 

   

  AFTER INPUT
   IF int_flag THEN
    EXIT INPUT
   END IF
   IF tpfc_conta1.codigo <> gfc_conta1.codigo then
    LET cnt = 0
    SELECT COUNT(*) INTO cnt FROM fc_conta1
     WHERE  fc_conta1.codigo = tpfc_conta1.codigo
    IF cnt <> 0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Contable Ya Existe Existe",
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
       comment="La Modificacion Fue Cancelada",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
--  DISPLAY "LA MODIFICACION FUE CANCELADA" AT 1,10 ATTRIBUTE(REVERSE)
  SLEEP 2
  DISPLAY "" AT 1,10
  INITIALIZE tpfc_conta1.* TO NULL
  RETURN
 END IF
 MESSAGE "MODIFICANDO EL CODIGO CONTABLE" --AT 1,10 ATTRIBUTE(REVERSE)
 LET gerrflag = FALSE
 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 UPDATE fc_conta1 
  SET ( codigo, auxiliariva, cencosiva, auxiliarimpc, cencosimpc, 
      auxiliaring, cencosing, auxiliarcar, cencoscar, auxiliarsubsi, cencossubsi,
    auxiliarant, cencosant, auxiliarcaja, cencoscaja, auxiliarbanco, cencosbanco, auxiliarcars, cencoscars )
    =  ( tpfc_conta1.codigo,
    tpfc_conta1.auxiliariva, tpfc_conta1.cencosiva, tpfc_conta1.auxiliarimpc, tpfc_conta1.cencosimpc,
    tpfc_conta1.auxiliaring, tpfc_conta1.cencosing, tpfc_conta1.auxiliarcar, tpfc_conta1.cencoscar,
    tpfc_conta1.auxiliarsubsi, tpfc_conta1.cencossubsi, tpfc_conta1.auxiliarant, tpfc_conta1.cencosant , tpfc_conta1.auxiliarcaja, tpfc_conta1.cencoscaja,
    tpfc_conta1.auxiliarbanco, tpfc_conta1.cencosbanco, tpfc_conta1.auxiliarcars, tpfc_conta1.cencoscars )
  WHERE  fc_conta1.codigo = gfc_conta1.codigo
 
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 DISPLAY "" AT 1,10
 IF NOT gerrflag THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Contable Fue Modificado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
 
--  DISPLAY "EL CODIGO CONTABLE FUE MODIFICADO" AT 1,10 ATTRIBUTE(REVERSE)
  COMMIT WORK
 ELSE
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="La modificacion Fue Cancelada",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  

--  DISPLAY "LA MODIFICACION FUE CANCELADA" AT 1,10 ATTRIBUTE(REVERSE)
  ROLLBACK WORK
 END IF
 IF NOT gerrflag THEN 
  LET gfc_conta1.* = tpfc_conta1.*
 END IF
 SLEEP 2
END FUNCTION

FUNCTION fc_conta1remove()
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 DISPLAY "" AT 1,1
 DISPLAY "" AT 2,1
 MESSAGE "Estado : " --AT 1,1
 MESSAGE "RETIRO DE CODIGOS CONTABLES" --AT 1,10 ATTRIBUTE(REVERSE)
 PROMPT "Seguro de borrar el codigo contable (s/n)? " FOR CHAR answer HELP 1117
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO EL CODIGO CONTABLE" --AT 1,10 ATTRIBUTE(REVERSE)
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  DELETE FROM fc_conta1
   WHERE  fc_conta1.codigo = gfc_conta1.codigo

  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  DISPLAY "" AT 1,10
  IF NOT gerrflag THEN 
   INITIALIZE gfc_conta1.* TO NULL
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Contable Fue Retirado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
--   DISPLAY "EL CODIGO CONTABLE FUE RETIRADO" AT 1,10 ATTRIBUTE(REVERSE)
   COMMIT WORK
  ELSE
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Retiro fue Cancelado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  

  --   MESSAGE "EL RETIRO FUE CANCELADO " --AT 1,10 ATTRIBUTE(REVERSE)
   ROLLBACK WORK
  END IF
 ELSE
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Retiro fue Cancelado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  

--  DISPLAY "EL RETIRO FUE CANCELADO "AT 1,10 ATTRIBUTE(REVERSE)
  LET int_flag = TRUE
 END IF
 SLEEP 2
END FUNCTION

FUNCTION fc_conta1getcurr( tpcodigo )
 DEFINE tpcodigo LIKE fc_conta1.codigo
 INITIALIZE gfc_conta1.* TO NULL
 SELECT *
  INTO gfc_conta1.*
  FROM fc_conta1
  WHERE fc_conta1.codigo = tpcodigo
  initialize mfc_servicios.* to null
  select * into mfc_servicios.* from fc_servicios 
   where codigo=gfc_conta1.codigo
   
  initialize mcon233iva.* to null
  select * into mcon233iva.* from niif233 where auxiliar=gfc_conta1.auxiliariva
  initialize mcon233impc.* to null
  select * into mcon233impc.* from niif233 where auxiliar=gfc_conta1.auxiliarimpc
  initialize mcon233ing.* to null
  select * into mcon233ing.* from niif233 where auxiliar=gfc_conta1.auxiliaring
  initialize mcon233car.* to null
  select * into mcon233car.* from niif233 where auxiliar=gfc_conta1.auxiliarcar
  initialize mcon233subsi.* to NULL
  select * into mcon233subsi.* from niif233 where auxiliar=gfc_conta1.auxiliarsubsi  
  initialize mcon233ant.* to NULL
  select * into mcon233ant.* from niif233 where auxiliar=gfc_conta1.auxiliarant  
  initialize mcon233caja.* to NULL
  select * into mcon233caja.* from niif233 where auxiliar=gfc_conta1.auxiliarcaja  
  initialize mcon233banco.* to NULL
  select * into mcon233banco.* from niif233 where auxiliar=gfc_conta1.auxiliarbanco  
  initialize mcon233cars.* to NULL
  select * into mcon233cars.* from niif233 where auxiliar=gfc_conta1.auxiliarcars  
  
  initialize mcon147iva.* to null
  select * into mcon147iva.* from niif147 where codcen=gfc_conta1.cencosiva
  initialize mcon147impc.* to null
  select * into mcon147impc.* from niif147 where codcen=gfc_conta1.cencosimpc
  initialize mcon147ing.* to null
  select * into mcon147ing.* from niif147 where codcen=gfc_conta1.cencosing
  initialize mcon147car.* to null
  select * into mcon147car.* from niif147 where codcen=gfc_conta1.cencoscar
  initialize mcon147subsi.* to null
  select * into mcon147subsi.* from niif147 where codcen=gfc_conta1.cencossubsi
  initialize mcon147ant.* to null
  select * into mcon147ant.* from niif147 where codcen=gfc_conta1.cencosant
  initialize mcon147caja.* to null
  select * into mcon147caja.* from niif147 where codcen=gfc_conta1.cencoscaja
  initialize mcon147banco.* to null
  select * into mcon147banco.* from niif147 where codcen=gfc_conta1.cencosbanco
  initialize mcon147cars.* to null
  select * into mcon147cars.* from niif147 where codcen=gfc_conta1.cencoscars
  
END FUNCTION

FUNCTION fc_conta1showcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 DISPLAY "" AT glastline,1
 IF gfc_conta1.codigo IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" --AT glastline,1
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum,
          "/ Existen ", maxnum, ")" ---AT glastline,1
 END IF
 CALL fc_conta1dplyg()
END FUNCTION

FUNCTION fc_conta1query( exist )
 DEFINE where_info, query_text CHAR(400),
 answer CHAR(1),
 exist, curr, maxnum  SMALLINT,
 tpcodigo LIKE fc_conta1.codigo

 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 DISPLAY "" AT 1,1
 DISPLAY "" AT 2,1
 MESSAGE "Estado : " --AT 1,1
 MESSAGE "CONSULTA DE CODIGO(S) CONTABLE" --AT 1,10 ATTRIBUTE(REVERSE)
 CLEAR FORM
 CONSTRUCT where_info
  ON codigo, 
   auxiliariva, cencosiva, auxiliarimpc, cencosimpc, auxiliaring, cencosing, auxiliarcar, cencoscar, auxiliarsubsi, cencossubsi, auxiliarant, cencosant, auxiliarcaja, cencoscaja, auxiliarbanco, cencosbanco, auxiliarcars, cencoscars
  FROM codigo,
   auxiliariva, cencosiva,  auxiliarimpc, cencosimpc, auxiliaring, cencosing, auxiliarcar, cencoscar, auxiliarsubsi, cencossubsi, auxiliarant, cencosant, auxiliarcaja, cencoscaja, auxiliarbanco, cencosbanco, auxiliarcars, cencoscars
 IF int_flag THEN
  --DISPLAY "" AT 1,10
  --DISPLAY "LA CONSULTA FUE CANCELADA" AT 1,10 ATTRIBUTE(REVERSE)
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="La Consulta Fue Cancelad",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
    END MENU  
  SLEEP 2
  DISPLAY "" AT 1,10
  RETURN exist
 END IF
 MESSAGE "Buscando el codigo(s) contable, por favor espere ..." --AT 2,1 
 LET query_text = " SELECT fc_conta1.codigo",
                  " FROM fc_conta1 WHERE ", where_info CLIPPED,
                  " ORDER BY fc_conta1.codigo ASC" 
 PREPARE s_sfc_conta1 FROM query_text
 DECLARE c_sfc_conta1 SCROLL CURSOR FOR s_sfc_conta1
 LET maxnum = 0
 FOREACH c_sfc_conta1 INTO tpcodigo
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_sfc_conta1
  FETCH FIRST c_sfc_conta1 INTO tpcodigo
  LET curr = 1
  CALL fc_conta1getcurr( tpcodigo )
  CALL fc_conta1showcurr( curr, maxnum )
 ELSE
  --DISPLAY "" AT 1,10
  --DISPLAY "" AT 2,1
  --DISPLAY "EL CODIGO(S) CONTABLE NO EXISTE" AT 1,10 ATTRIBUTE(REVERSE)
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo contable No Existe",
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
    FETCH FIRST c_sfc_conta1 INTO tpcodigo
    LET curr = 1
   ELSE
    FETCH NEXT c_sfc_conta1 INTO tpcodigo
    LET curr = curr + 1
   END IF
   CALL fc_conta1getcurr( tpcodigo )
   CALL fc_conta1showcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al registro anterior"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_sfc_conta1 INTO tpcodigo
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_sfc_conta1 INTO tpcodigo
    LET curr = curr - 1
   END IF
   CALL fc_conta1getcurr( tpcodigo )
   CALL fc_conta1showcurr( curr, maxnum )
  COMMAND "Modifica" "Modifica el codigo contable en consulta" 
    IF gfc_conta1.codigo IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_conta1
     CALL fc_conta1update()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL fc_conta1getcurr( tpcodigo )
     CALL fc_conta1showcurr( curr, maxnum )
     OPEN c_sfc_conta1
    END IF
  COMMAND "Borrar" "Borra el codigo contable en consulta" 
    IF gfc_conta1.codigo IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_conta1
     CALL fc_conta1remove()
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CALL fc_conta1showcurr( curr, maxnum )
     END IF
     OPEN c_sfc_conta1
    END IF
  COMMAND key("esc","S") "Salir" "Retocede de menu"
   HELP 1
   IF gfc_conta1.codigo IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sfc_conta1
 DISPLAY "" AT glastline,1
 RETURN exist
END FUNCTION
FUNCTION villac02val()
 DEFINE tp   RECORD
   auxiliar  LIKE niif233.auxiliar,
   detalle   LIKE niif233.detalle
  END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 initialize mniif233.auxuno to null
 LET lastline = 16
 LET maxnum = 0
 case
  when op="1"
   SELECT COUNT(*) INTO maxnum FROM niif233
    WHERE nivel="A"
  when op="2"
   SELECT COUNT(*) INTO maxnum FROM niif233
    WHERE nivel="A" and ajuste="S"
  when op="3"
   SELECT COUNT(*) INTO maxnum FROM niif233
    WHERE nivel="A" and activos="S"
  when op="4"
   SELECT COUNT(*) INTO maxnum FROM niif233
    WHERE nivel="A" and centros="S"
  when op="5"
   SELECT COUNT(*) INTO maxnum FROM niif233
    WHERE nivel="A" and banco="S"
  when op="6"
   SELECT COUNT(*) INTO maxnum FROM niif233
    WHERE nivel="A" and tercero="S"
  when op="7"
   SELECT COUNT(*) INTO maxnum FROM niif233
    WHERE nivel="A" and tercero="R"
  when op="8"
   SELECT COUNT(*) INTO maxnum FROM niif233
    WHERE nivel="A" and detalla="I"
  when op="9"
   SELECT COUNT(*) INTO maxnum FROM niif233
    WHERE nivel="A" and facret<>0
 end case
 IF NOT maxnum THEN
  ERROR "                         NO HAY REGISTROS PARA VISUALIZAR   ",
        "                   "
  SLEEP 2
  ERROR ""
  LET tp.auxiliar = NULL
  RETURN tp.auxiliar
 END IF
 OPEN WINDOW w_vniif233 AT 8,28 WITH FORM "villac02v"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 case
  when op="1"
   DECLARE c_vniif2331 SCROLL CURSOR FOR
    SELECT niif233.auxiliar, niif233.detalle
    FROM niif233
     WHERE niif233.nivel="A"
     ORDER BY niif233.auxiliar
   OPEN c_vniif2331
  when op="2"
   DECLARE c_vniif2332 SCROLL CURSOR FOR
    SELECT niif233.auxiliar, niif233.detalle
    FROM niif233
     WHERE niif233.nivel="A" and ajuste="S"
     ORDER BY niif233.auxiliar
   OPEN c_vniif2332
  when op="3"
   DECLARE c_vniif2333 SCROLL CURSOR FOR
    SELECT niif233.auxiliar, niif233.detalle
    FROM niif233
     WHERE niif233.nivel="A" and activos="S"
     ORDER BY niif233.auxiliar
   OPEN c_vniif2333
  when op="4"
   DECLARE c_vniif2334 SCROLL CURSOR FOR
    SELECT niif233.auxiliar, niif233.detalle
    FROM niif233
     WHERE niif233.nivel="A" and centros="S"
     ORDER BY niif233.auxiliar
   OPEN c_vniif2334
  when op="5"
   DECLARE c_vniif2335 SCROLL CURSOR FOR
    SELECT niif233.auxiliar, niif233.detalle
    FROM niif233
     WHERE niif233.nivel="A" and banco="S"
     ORDER BY niif233.auxiliar
   OPEN c_vniif2335
  when op="6"
   DECLARE c_vniif2336 SCROLL CURSOR FOR
    SELECT niif233.auxiliar, niif233.detalle
    FROM niif233
     WHERE niif233.nivel="A" and tercero="S"
     ORDER BY niif233.auxiliar
   OPEN c_vniif2336
  when op="7"
   DECLARE c_vniif2337 SCROLL CURSOR FOR
    SELECT niif233.auxiliar, niif233.detalle
    FROM niif233
     WHERE niif233.nivel="A" and tercero="R"
     ORDER BY niif233.auxiliar
   OPEN c_vniif2337
  when op="8"
   DECLARE c_vniif2338 SCROLL CURSOR FOR
    SELECT niif233.auxiliar, niif233.detalle
    FROM niif233
     WHERE niif233.nivel="A" and detalla="I"
     ORDER BY niif233.auxiliar
   OPEN c_vniif2338
  when op="9"
   DECLARE c_vniif2339 SCROLL CURSOR FOR
    SELECT niif233.auxiliar, niif233.detalle
    FROM niif233
     WHERE niif233.nivel="A" and facret<>0
     ORDER BY niif233.auxiliar
   OPEN c_vniif2339
 end case
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL niif233row(currrow,prevrow,pagenum) RETURNING pagenum, prevrow 
 DISPLAY "" AT lastline,1
 DISPLAY "Localizacion : ( Actual ", currrow,
          "/ Existen ", maxnum, ")" AT lastline,1
 MENU ":"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   HELP 5
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL niif233row( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
   DISPLAY "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" AT lastline,1
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL niif233row( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
   DISPLAY "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" AT lastline,1
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
   CALL niif233row( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
   DISPLAY "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   case
    when op="1"
     FETCH ABSOLUTE currrow c_vniif2331 INTO tp.*
    when op="2"
     FETCH ABSOLUTE currrow c_vniif2332 INTO tp.*
    when op="3"
     FETCH ABSOLUTE currrow c_vniif2333 INTO tp.*
    when op="4"
     FETCH ABSOLUTE currrow c_vniif2334 INTO tp.*
    when op="5"
     FETCH ABSOLUTE currrow c_vniif2335 INTO tp.*
    when op="6"
     FETCH ABSOLUTE currrow c_vniif2336 INTO tp.*
    when op="7"
     FETCH ABSOLUTE currrow c_vniif2337 INTO tp.*
    when op="8"
     FETCH ABSOLUTE currrow c_vniif2338 INTO tp.*
    when op="9"
     FETCH ABSOLUTE currrow c_vniif2339 INTO tp.*
   end case
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.auxiliar = NULL
   EXIT MENU
 END MENU
 case
  when op="1"
   CLOSE c_vniif2331
  when op="2"
   CLOSE c_vniif2332
  when op="3"
   CLOSE c_vniif2333
  when op="4"
   CLOSE c_vniif2334
  when op="5"
   CLOSE c_vniif2335
  when op="6"
   CLOSE c_vniif2336
  when op="7"
   CLOSE c_vniif2337
  when op="8"
   CLOSE c_vniif2338
  when op="9"
   CLOSE c_vniif2339
 end case
 CLOSE WINDOW w_vniif233
 RETURN tp.auxiliar
END FUNCTION

FUNCTION niif233row( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   auxiliar  LIKE niif233.auxiliar,
   detalle   LIKE niif233.detalle
  END RECORD,
  scrmax, scrcurr, scrprev,
  currrow, prevrow,
  pagenum, newpagenum,
  x, y, scrfrst INTEGER
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
  case
   when op="1"
    FETCH ABSOLUTE scrfrst c_vniif2331 INTO tp.*
   when op="2"
    FETCH ABSOLUTE scrfrst c_vniif2332 INTO tp.*
   when op="3"
    FETCH ABSOLUTE scrfrst c_vniif2333 INTO tp.*
   when op="4"
    FETCH ABSOLUTE scrfrst c_vniif2334 INTO tp.*
   when op="5"
    FETCH ABSOLUTE scrfrst c_vniif2335 INTO tp.*
   when op="6"
    FETCH ABSOLUTE scrfrst c_vniif2336 INTO tp.*
   when op="7"
    FETCH ABSOLUTE scrfrst c_vniif2337 INTO tp.*
   when op="8"
    FETCH ABSOLUTE scrfrst c_vniif2338 INTO tp.*
   when op="9"
    FETCH ABSOLUTE scrfrst c_vniif2339 INTO tp.*
  end case
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO planv[x].* ATTRIBUTE(REVERSE)
   ELSE
    DISPLAY tp.* TO planv[x].*
   END IF
   IF x < scrmax THEN
    case
     when op="1"
      FETCH c_vniif2331 INTO tp.*
     when op="2"
      FETCH c_vniif2332 INTO tp.*
     when op="3"
      FETCH c_vniif2333 INTO tp.*
     when op="4"
      FETCH c_vniif2334 INTO tp.*
     when op="5"
      FETCH c_vniif2335 INTO tp.*
     when op="6"
      FETCH c_vniif2336 INTO tp.*
     when op="7"
      FETCH c_vniif2337 INTO tp.*
     when op="8"
      FETCH c_vniif2338 INTO tp.*
     when op="9"
      FETCH c_vniif2339 INTO tp.*
    end case
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO planv[y].*
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
  case
   when op="1"
    FETCH ABSOLUTE prevrow c_vniif2331 INTO tp.*
    DISPLAY tp.* TO planv[scrprev].*
    FETCH ABSOLUTE currrow c_vniif2331 INTO tp.*
    DISPLAY tp.* TO planv[scrcurr].* ATTRIBUTE(REVERSE)
   when op="2"
    FETCH ABSOLUTE prevrow c_vniif2332 INTO tp.*
    DISPLAY tp.* TO planv[scrprev].*
    FETCH ABSOLUTE currrow c_vniif2332 INTO tp.*
    DISPLAY tp.* TO planv[scrcurr].* ATTRIBUTE(REVERSE)
   when op="3"
    FETCH ABSOLUTE prevrow c_vniif2333 INTO tp.*
    DISPLAY tp.* TO planv[scrprev].*
    FETCH ABSOLUTE currrow c_vniif2333 INTO tp.*
    DISPLAY tp.* TO planv[scrcurr].* ATTRIBUTE(REVERSE)
   when op="4"
    FETCH ABSOLUTE prevrow c_vniif2334 INTO tp.*
    DISPLAY tp.* TO planv[scrprev].*
    FETCH ABSOLUTE currrow c_vniif2334 INTO tp.*
    DISPLAY tp.* TO planv[scrcurr].* ATTRIBUTE(REVERSE)
   when op="5"
    FETCH ABSOLUTE prevrow c_vniif2335 INTO tp.*
    DISPLAY tp.* TO planv[scrprev].*
    FETCH ABSOLUTE currrow c_vniif2335 INTO tp.*
    DISPLAY tp.* TO planv[scrcurr].* ATTRIBUTE(REVERSE)
   when op="6"
    FETCH ABSOLUTE prevrow c_vniif2336 INTO tp.*
    DISPLAY tp.* TO planv[scrprev].*
    FETCH ABSOLUTE currrow c_vniif2336 INTO tp.*
    DISPLAY tp.* TO planv[scrcurr].* ATTRIBUTE(REVERSE)
   when op="7"
    FETCH ABSOLUTE prevrow c_vniif2337 INTO tp.*
    DISPLAY tp.* TO planv[scrprev].*
    FETCH ABSOLUTE currrow c_vniif2337 INTO tp.*
    DISPLAY tp.* TO planv[scrcurr].* ATTRIBUTE(REVERSE)
   when op="8"
    FETCH ABSOLUTE prevrow c_vniif2338 INTO tp.*
    DISPLAY tp.* TO planv[scrprev].*
    FETCH ABSOLUTE currrow c_vniif2338 INTO tp.*
    DISPLAY tp.* TO planv[scrcurr].* ATTRIBUTE(REVERSE)
   when op="9"
    FETCH ABSOLUTE prevrow c_vniif2339 INTO tp.*
    DISPLAY tp.* TO planv[scrprev].*
    FETCH ABSOLUTE currrow c_vniif2339 INTO tp.*
    DISPLAY tp.* TO planv[scrcurr].* ATTRIBUTE(REVERSE)
  end case
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION
FUNCTION villac06val()
 DEFINE tp   RECORD
   codcen       LIKE niif147.codcen,
   detalle      LIKE niif147.detalle
  END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM niif147
 IF NOT maxnum THEN
  ERROR "                         NO HAY REGISTROS PARA VISUALIZAR   ",
        "                   "
  SLEEP 2
  ERROR ""
  LET tp.codcen = NULL
  RETURN tp.codcen
 END IF
 OPEN WINDOW w_vniif1471 AT 8,32 WITH FORM "villac06v"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 DECLARE c_vniif1471 SCROLL CURSOR FOR
  SELECT niif147.codcen, niif147.detalle FROM niif147
   ORDER BY niif147.codcen
 OPEN c_vniif1471
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL niif147row( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
 DISPLAY "" AT lastline,1
 DISPLAY "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" AT lastline,1
 MENU ":"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   HELP 5
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL niif147row( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
   DISPLAY "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" AT lastline,1
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL niif147row( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
   DISPLAY "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" AT lastline,1
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
   CALL niif147row( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
   DISPLAY "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vniif1471 INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.codcen = NULL
   EXIT MENU
 END MENU
 CLOSE c_vniif1471
 CLOSE WINDOW w_vniif1471
 RETURN tp.codcen
END FUNCTION  
FUNCTION niif147row( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   codcen    LIKE niif147.codcen,
   detalle   LIKE niif147.detalle
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
  FETCH ABSOLUTE scrfrst c_vniif1471 INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cenv[x].* ATTRIBUTE(REVERSE)
   ELSE
    DISPLAY tp.* TO cenv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vniif1471 INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO cenv[y].*
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
  FETCH ABSOLUTE prevrow c_vniif1471 INTO tp.*
  DISPLAY tp.* TO cenv[scrprev].*
  FETCH ABSOLUTE currrow c_vniif1471 INTO tp.*
  DISPLAY tp.* TO cenv[scrcurr].* ATTRIBUTE(REVERSE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION

FUNCTION rep_conta()
define ubicacion char(100)
DISPLAY "" AT 2,1
DISPLAY "Trabajando por favor espere ... " AT 2,1
let ubicacion=fgl_getenv("HOME"),"/reportes/cod_conta"
let ubicacion=ubicacion clipped
start report rconta to ubicacion
initialize mfc_conta1.* to null
declare pconta cursor for
select * from fc_conta1 order by codigo
foreach pconta into mfc_conta1.*
 output to report rconta()
end foreach
finish report rconta
call impsn(ubicacion)
END FUNCTION
REPORT rconta()
output
 top margin 4
 bottom margin 4
 left margin 0
 right margin 132
 page length 66
format
 page header
 let mtime=time
 print column 1,"Fecha : ",today," + ",mtime,
       column 121,"Pag No. ",pageno using "####"
 skip 1 LINES
 let mp1 = (132-length(mfe_empresa.razsoc clipped))/2
 print column mp1,mfe_empresa.razsoc
 let mp1 = (132-length("LISTADO GENERAL DE ENLACES CONTABLES"))/2
 print column mp1,"LISTADO GENERAL DE ENLACES CONTABLES"

 skip 1 lines
 print "----------------------------------------",
       "---------------------------------------------------------------",
       "---------------------------------------------------------------"
 print  column 01,"SERVICIO",
        column 10,"DESCRIPCION",
        column 40,"AUXILIAR/IVA",
        column 55,"AUXILIAR/IMPC",
        column 70,"AUXILIAR/ING",
        column 85,"AUXILIAR/CAR",
        column 100,"AUXILIAR/SUBS",
        column 115,"AUXILIAR/ANT",
        column 130,"AUXILIAR/CAJA",
        column 145,"AUXILIAR/BAN"
        
       
 print "----------------------------------------",
       "---------------------------------------------------------------",
       "---------------------------------------------------------------"

 skip 1 lines
 on every row
 initialize mfc_servicios.* to null
 select * into mfc_servicios.* from fc_servicios
 where codigo=mfc_conta1.codigo
 
 print  column 01,mfc_conta1.codigo,
        column 10,mfc_servicios.descripcion[1,25],
        column 40,mfc_conta1.auxiliariva,
        column 55,mfc_conta1.auxiliarimpc,
        column 70,mfc_conta1.auxiliaring,
        column 85,mfc_conta1.auxiliarcar,
        column 100,mfc_conta1.auxiliarsubsi,
        column 115,mfc_conta1.auxiliarant,
        column 130,mfc_conta1.auxiliarcaja,
        column 145,mfc_conta1.auxiliarbanco
      
 on last row
 skip to top of page
end report

FUNCTION rep_conta2()
define ubicacion char(100)
DEFINE mprefijo char(5)
DISPLAY "" AT 2,1
let mprefijo=null
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null then 
  return
 end if
DISPLAY "Trabajando por favor espere ... " AT 2,1
let ubicacion=fgl_getenv("HOME"),"/reportes/cod_conta2"
let ubicacion=ubicacion clipped
start report rconta2 to ubicacion
initialize mfc_conta1.* to null
declare pconta2 cursor for
select fc_conta1.* from fc_conta1, fc_conta3
WHERE fc_conta1.codigo = fc_conta3.codigo
 AND fc_conta3.prefijo = mprefijo 
order by codigo
foreach pconta2 into mfc_conta1.*
 output to report rconta2(mprefijo)
end foreach
finish report rconta2
call impsn(ubicacion)
END FUNCTION
REPORT rconta2(mprefijo)
DEFINE mprefijo char(5)
output
 top margin 4
 bottom margin 4
 left margin 0
 right margin 132
 page length 66
format
 page header
 let mtime=time
 print column 1,"Fecha : ",today," + ",mtime,
       column 121,"Pag No. ",pageno using "####"
 skip 1 LINES
 let mp1 = (132-length(mfe_empresa.razsoc clipped))/2
 print column mp1,mfe_empresa.razsoc
 let mp1 = (132-length("LISTADO GENERAL DE ENLACES CONTABLES"))/2
 print column mp1,"LISTADO GENERAL DE ENLACES CONTABLES PARA EL PREFIJO : ", mprefijo

 skip 1 lines
 print "----------------------------------------",
       "---------------------------------------------------------------",
       "---------------------------------------------------------------"
 print  column 01,"SERVICIO",
        column 10,"DESCRIPCION",
        column 40,"AUXILIAR/IVA",
        column 55,"AUXILIAR/IMPC",
        column 70,"AUXILIAR/ING",
        column 85,"AUXILIAR/CAR",
        column 100,"AUXILIAR/SUBS",
        column 115,"AUXILIAR/ANT",
        column 130,"AUXILIAR/CAJA",
        column 145,"AUXILIAR/BAN"
        
       
 print "----------------------------------------",
       "---------------------------------------------------------------",
       "---------------------------------------------------------------"

 skip 1 lines
 on every row
 initialize mfc_servicios.* to null
 select * into mfc_servicios.* from fc_servicios
 where codigo=mfc_conta1.codigo
 
 print  column 01,mfc_conta1.codigo,
        column 10,mfc_servicios.descripcion[1,25],
        column 40,mfc_conta1.auxiliariva,
        column 55,mfc_conta1.auxiliarimpc,
        column 70,mfc_conta1.auxiliaring,
        column 85,mfc_conta1.auxiliarcar,
        column 100,mfc_conta1.auxiliarsubsi,
        column 115,mfc_conta1.auxiliarant,
        column 130,mfc_conta1.auxiliarcaja,
        column 145,mfc_conta1.auxiliarbanco
      
 on last row
 skip to top of page
end report

