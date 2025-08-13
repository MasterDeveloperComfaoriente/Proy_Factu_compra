GLOBALS "fe_globales.4gl"
FUNCTION fe_conta2main()
 DEFINE exist SMALLINT
 OPEN WINDOW w_mfe_conta2 AT 1,1 WITH FORM "fe_contable2"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gfe_conta2.* TO NULL
 INITIALIZE tpfe_conta2.* TO NULL
 MENU
  COMMAND "Adiciona" "Adiciona codigos contable" 
    CALL fe_conta2add()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
    CALL fe_conta2dplyg()
  
  COMMAND "Consulta" "Consulta los codigos contables adicionados" 
    CALL fe_conta2query( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL fe_conta2dplyg()
  COMMAND "Modifica" "Modifica el codigo contable en consultado"
    IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="No Existen Codigos En Consulta",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    ELSE
     CALL fe_conta2update()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
    END IF
    CALL fe_conta2dplyg()
  COMMAND "Borrar" "Borra el codigo contable en consulta" 
    IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="No Existen Codigos En Consulta",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    ELSE
     CALL fe_conta2remove()
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CLEAR FORM
      LET exist = FALSE
     END IF
    END IF
    CALL fe_conta2dplyg()
  
  COMMAND key ("esc","S") "Salir" "Retrocede de menu"
   HELP 1
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfe_conta2
END FUNCTION

FUNCTION fe_conta2dplyg()
 DISPLAY BY NAME gfe_conta2.codigo THRU gfe_conta2.proyecto
 DISPLAY mfe_servicios.descripcion to formonly.mdetser
END FUNCTION
 
FUNCTION fe_conta2add()
 DEFINE cnt  SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 DISPLAY "" AT 1,1
 DISPLAY "" AT 2,1
 MESSAGE "Estado : " --AT 1,1
 MESSAGE "ADICIONANDO UN CODIGO CONTABLE" --AT 1,10 ATTRIBUTE(REVERSE)
 INITIALIZE tpfe_conta2.* TO NULL
 INPUT BY NAME tpfe_conta2.codigo THRU tpfe_conta2.proyecto
  AFTER FIELD codigo
   IF tpfe_conta2.codigo IS NULL THEN
    CALL fe_serviciosval() RETURNING tpfe_conta2.codigo
    DISPLAY BY NAME tpfe_conta2.codigo
    INITIALIZE mfe_servicios.* TO NULL
    select * into mfe_servicios.* from fe_servicios 
     where codigo=tpfe_conta2.codigo
   ELSE
    INITIALIZE mfe_servicios.* TO NULL
    select * into mfe_servicios.* from fe_servicios 
     where codigo=tpfe_conta2.codigo
    if mfe_servicios.codigo is null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Del Servicio No Existe ",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE mfe_servicios.* TO NULL
     initialize tpfe_conta2.codigo to null
     next field codigo
    END IF
   END IF
   if mfe_servicios.codigo is null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Del Servicio No Existe ",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  

    INITIALIZE mfe_servicios.* TO NULL
    initialize tpfe_conta2.codigo to null
    next field codigo
   END IF
   if mfe_servicios.estado="I" then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Servicio Se Encuentra Inactivo",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    INITIALIZE mfe_servicios.* TO NULL
    initialize tpfe_conta2.codigo to null
    next field codigo
   END IF
   display mfe_servicios.descripcion to mdetser
  
   LET cnt = 0
   SELECT COUNT(*) INTO cnt FROM fe_conta2
    WHERE  fe_conta2.codigo = tpfe_conta2.codigo

   IF cnt <> 0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo contable Ya Existe",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codigo
   END IF
   
  AFTER FIELD area
   IF tpfe_conta2.area IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El AREA no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD area
   END IF
   
  AFTER FIELD centro
   IF tpfe_conta2.centro IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El CENTRO no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD centro
   END IF
 

 
  AFTER FIELD sucursal
   IF tpfe_conta2.sucursal IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El AREA no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD sucursal
   END IF
 
  AFTER FIELD proyecto
   IF tpfe_conta2.proyecto IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El PROYECTO no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD proyecto
   END IF
 
  
  AFTER INPUT
   IF int_flag THEN
    EXIT INPUT
   END IF
   LET cnt = 0
   SELECT COUNT(*) INTO cnt FROM fe_conta2
    WHERE  fe_conta2.codigo = tpfe_conta2.codigo

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
   INITIALIZE tpfe_conta2.* TO NULL
   RETURN
  END IF
  MESSAGE "ADICIONANDO EL CODIGO CONTABLE" -- AT 1,10 ATTRIBUTE(REVERSE)
  SLEEP 3
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  INSERT INTO fe_conta2 ( codigo, area,
     centro, sucursal, proyecto )
   VALUES  ( tpfe_conta2.codigo, 
             tpfe_conta2.area,
             tpfe_conta2.centro, 
             tpfe_conta2.sucursal, 
             tpfe_conta2.proyecto )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  DISPLAY "" AT 1,10
  IF NOT gerrflag THEN
   COMMIT WORK
   LET gfe_conta2.* = tpfe_conta2.*
   INITIALIZE tpfe_conta2.* TO NULL
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Contable Fue Adicionado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
--   DISPLAY "EL CODIGO CONTABLE FUE ADICIONADA" AT 1,10 ATTRIBUTE(REVERSE)
  ELSE
   ROLLBACK WORK
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="La Adicion Fue Cancelada",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
--  DISPLAY "LA ADICION FUE CANCELADA" AT 1,10 ATTRIBUTE(REVERSE)
  END IF
  SLEEP 2
END FUNCTION

FUNCTION fe_conta2update()
 DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 DISPLAY "" AT 1,1
 DISPLAY "" AT 2,1
 MESSAGE "Estado : " --AT 1,1
 MESSAGE "MODIFICACION DE CODIGOS CONTABLE" --AT 1,10 ATTRIBUTE(REVERSE)
 LET tpfe_conta2.* = gfe_conta2.*
 INPUT BY NAME tpfe_conta2.codigo THRU tpfe_conta2.proyecto WITHOUT DEFAULTS
  AFTER FIELD codigo
   IF tpfe_conta2.codigo IS NULL THEN
    CALL fe_serviciosval() RETURNING tpfe_conta2.codigo
    DISPLAY BY NAME tpfe_conta2.codigo
    INITIALIZE mfe_servicios.* TO NULL
    select * into mfe_servicios.* from fe_servicios 
     where codigo=tpfe_conta2.codigo
   ELSE
    INITIALIZE mfe_servicios.* TO NULL
    select * into mfe_servicios.* from fe_servicios 
     where codigo=tpfe_conta2.codigo
    if mfe_servicios.codigo is null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Del Servicio No Existe",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE mfe_servicios.* TO NULL
     initialize tpfe_conta2.codigo to null
     next field codigo
    END IF
   END IF
   if mfe_servicios.codigo is null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo Del Servicio No Existe",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    INITIALIZE mfe_servicios.* TO NULL
    initialize tpfe_conta2.codigo to null
    next field codigo
   END IF
   if mfe_servicios.estado="I" then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Servicio Se Encuentra Inactivo",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  

    INITIALIZE mfe_servicios.* TO NULL
    initialize tpfe_conta2.codigo to null
    next field codigo
   END IF
   display mfe_servicios.descripcion to mdetser
   IF tpfe_conta2.codigo <> gfe_conta2.codigo then
    LET cnt = 0
    SELECT COUNT(*) INTO cnt FROM fe_conta2
     WHERE  fe_conta2.codigo = tpfe_conta2.codigo
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
   
  AFTER FIELD area
   IF tpfe_conta2.area IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El AREA No fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD area
   END IF
   
  AFTER FIELD centro
   IF tpfe_conta2.centro IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El CENTRO no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD centro
   END IF

 AFTER FIELD sucursal
   IF tpfe_conta2.sucursal IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El AREA no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD sucursal
   END IF
 

  AFTER FIELD proyecto
   IF tpfe_conta2.proyecto IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El PROYECTO no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD proyecto
   END IF

  


  
  AFTER INPUT
   IF int_flag THEN
    EXIT INPUT
   END IF
   IF tpfe_conta2.codigo <> gfe_conta2.codigo then
    LET cnt = 0
    SELECT COUNT(*) INTO cnt FROM fe_conta2
     WHERE  fe_conta2.codigo = tpfe_conta2.codigo
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
  INITIALIZE tpfe_conta2.* TO NULL
  RETURN
 END IF
 MESSAGE "MODIFICANDO EL CODIGO CONTABLE" --AT 1,10 ATTRIBUTE(REVERSE)
 LET gerrflag = FALSE
 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 UPDATE fe_conta2 
  SET ( codigo, area,
     centro, sucursal, proyecto )
   =  ( tpfe_conta2.codigo,
        tpfe_conta2.area,
   tpfe_conta2.centro, tpfe_conta2.sucursal, tpfe_conta2.proyecto )
  WHERE  fe_conta2.codigo = gfe_conta2.codigo
 
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
  LET gfe_conta2.* = tpfe_conta2.*
 END IF
 SLEEP 2
END FUNCTION

FUNCTION fe_conta2remove()
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
  DELETE FROM fe_conta2
   WHERE  fe_conta2.codigo = gfe_conta2.codigo

  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  DISPLAY "" AT 1,10
  IF NOT gerrflag THEN 
   INITIALIZE gfe_conta2.* TO NULL
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

FUNCTION fe_conta2getcurr( tpcodigo )
 DEFINE tpcodigo LIKE fe_conta2.codigo
 INITIALIZE gfe_conta2.* TO NULL
 SELECT fe_conta2.codigo,
   fe_conta2.area,
   fe_conta2.centro, fe_conta2.sucursal, fe_conta2.proyecto
  INTO gfe_conta2.*
  FROM fe_conta2
  WHERE fe_conta2.codigo = tpcodigo

  initialize mfe_servicios.* to null
  select * into mfe_servicios.* from fe_servicios 
   where codigo=gfe_conta2.codigo
  
END FUNCTION

FUNCTION fe_conta2showcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 DISPLAY "" AT glastline,1
 IF gfe_conta2.codigo IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" --AT glastline,1
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum,
          "/ Existen ", maxnum, ")" ---AT glastline,1
 END IF
 CALL fe_conta2dplyg()
END FUNCTION

FUNCTION fe_conta2query( exist )
 DEFINE where_info, query_text CHAR(400),
 answer CHAR(1),
 exist, curr, maxnum  SMALLINT,
 tpcodigo LIKE fe_conta2.codigo

 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 DISPLAY "" AT 1,1
 DISPLAY "" AT 2,1
 MESSAGE "Estado : " --AT 1,1
 MESSAGE "CONSULTA DE CODIGO(S) CONTABLE" --AT 1,10 ATTRIBUTE(REVERSE)
 CLEAR FORM
 CONSTRUCT where_info
  ON codigo, area,
   centro, sucursal, proyecto
  FROM codigo, area,
   centro, sucursal, proyecto
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
 LET query_text = " SELECT fe_conta2.codigo",
                  " FROM fe_conta2 WHERE ", where_info CLIPPED,
                  " ORDER BY fe_conta2.codigo ASC" 
 PREPARE s_sfe_conta2 FROM query_text
 DECLARE c_sfe_conta2 SCROLL CURSOR FOR s_sfe_conta2
 LET maxnum = 0
 FOREACH c_sfe_conta2 INTO tpcodigo
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_sfe_conta2
  FETCH FIRST c_sfe_conta2 INTO tpcodigo
  LET curr = 1
  CALL fe_conta2getcurr( tpcodigo )
  CALL fe_conta2showcurr( curr, maxnum )
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
    FETCH FIRST c_sfe_conta2 INTO tpcodigo
    LET curr = 1
   ELSE
    FETCH NEXT c_sfe_conta2 INTO tpcodigo
    LET curr = curr + 1
   END IF
   CALL fe_conta2getcurr( tpcodigo )
   CALL fe_conta2showcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al registro anterior"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_sfe_conta2 INTO tpcodigo
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_sfe_conta2 INTO tpcodigo
    LET curr = curr - 1
   END IF
   CALL fe_conta2getcurr( tpcodigo )
   CALL fe_conta2showcurr( curr, maxnum )
  COMMAND "Modifica" "Modifica el codigo contable en consulta" 
    IF gfe_conta2.codigo IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfe_conta2
     CALL fe_conta2update()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL fe_conta2getcurr( tpcodigo )
     CALL fe_conta2showcurr( curr, maxnum )
     OPEN c_sfe_conta2
    END IF
  COMMAND "Borrar" "Borra el codigo contable en consulta" 
    IF gfe_conta2.codigo IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfe_conta2
     CALL fe_conta2remove()
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CALL fe_conta2showcurr( curr, maxnum )
     END IF
     OPEN c_sfe_conta2
    END IF
  COMMAND key("esc","S") "Salir" "Retocede de menu"
   HELP 1
   IF gfe_conta2.codigo IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sfe_conta2
 DISPLAY "" AT glastline,1
 RETURN exist
END FUNCTION
