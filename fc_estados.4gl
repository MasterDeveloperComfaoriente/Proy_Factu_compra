GLOBALS "fc_globales.4gl"
DEFINE cb_edo  ui.combobox
FUNCTION edofact_main()
 DEFINE exist  SMALLINT
 OPEN WINDOW w_medofact AT 1,1 WITH FORM "fc_estados"
 LET glastline = 23
 LET exist = FALSE
LET cb_edo = ui.ComboBox.forName("fc_estados.tipo")
   CALL cb_edo .clear()
   CALL cb_edo.addItem("1", "ESTADOS VALIDACION DISPAPELES")
   CALL cb_edo.addItem("2", "RESPUESTA ENVIO DOCUMENTO")
   CALL cb_edo.addItem("3", "ESTADOS VALIDACION DIAN")
   CALL cb_edo.addItem("4", "ESTADOS ENTREGA EMAIL CLIENTE")
   CALL cb_edo.addItem("5", "RESPUESTA DEL CLIENTE")
 
  MENU
   COMMAND "Adiciona" "Adiciona estados de Documentos/notas "
  -- LET mcodmen="T022"
 --  CALL opcion() RETURNING op
   --if op="S" THEN
    CALL edofactadd()
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CLEAR FORM
      LET exist = TRUE
     END IF
    --END IF
 COMMAND "Consulta" "Consulta estados "
  --LET mcodmen="T023"
   --CALL opcion() RETURNING op
   --if op="S" THEN
    CALL edofactquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
   --END IF 
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_medofact
END FUNCTION
FUNCTION edofactgetcurr( tpcodigo)
  DEFINE tpcodigo LIKE fc_estados.codest
  INITIALIZE gfc_estados.* TO NULL
  SELECT *  INTO gfc_estados.*  FROM fc_estados
   WHERE fc_estados.codest = tpcodigo
END FUNCTION
FUNCTION edofactshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum INTEGER
 IF gfc_estados.codest IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum,
          "/ Existen ", maxnum, ")"
 END IF
CALL fc_estadosdplyg()
END FUNCTION
FUNCTION fc_estadosdplyg()
DISPLAY BY NAME gfc_estados.codest THRU gfc_estados.tipo
END FUNCTION
FUNCTION edofactadd()
DEFINE mnumero LIKE fc_estados.codest
DEFINE mnumcod INTEGER
DEFINE  cnt, x, v SMALLINT
 DEFINE control SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 MESSAGE "ESTADO: ADICION DE TIPO DE ESTADO"  ATTRIBUTE(BLUE)
 INITIALIZE tpfc_estados.* TO NULL
 lABEL Ent_estados:
 INPUT BY NAME tpfc_estados.codest THRU tpfc_estados.tipo WITHOUT DEFAULTS

 AFTER FIELD codest
   IF tpfc_estados.codest IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El código no fue digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD codest
   END IF
 
   let mnumero=tpfc_estados.codest
   LET CONTROL = NULL 
   SELECT count(*) INTO control FROM fc_estados
     WHERE fc_estados.codest=mnumero
   IF control<>0 then
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El código ya esta Registrado",
             image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD codest
    END IF
 AFTER FIELD nombre_est
   IF tpfc_estados.nombre_est IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Nombre No fue Digitado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD nombre_est
   END IF
AFTER FIELD tipo
   IF tpfc_estados.tipo IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "Debe Seleccionar el tipo de estado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD tipo
   END IF
--AFTER FIELD codigo
--   IF tpfc_estados.codigo IS NULL THEN
--     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
--      comment= "El código no fue digitado", image= "exclamation")
--       COMMAND "Aceptar"
--        EXIT MENU
--     END MENU
--    NEXT FIELD codigo
--   END IF

  
  AFTER INPUT
   IF int_flag THEN
      EXIT INPUT
   ELSE
    IF tpfc_estados.nombre_est IS NULL 
       OR tpfc_estados.codest IS NULL 
        OR tpfc_estados.tipo IS NULL then 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
        comment= "Hay campos obligatorios vacios, debe completarlos ", image= "exclamation")
         COMMAND "Aceptar"
          EXIT MENU
      END MENU
        GO TO Ent_estados
      end if 
   END IF
 END INPUT
 IF int_flag THEN
  CLEAR FORM
  MENU "Información"  ATTRIBUTE(style= "dialog", 
                  comment= "La adicion fue cancelada      "  ,
                   image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    INITIALIZE tpfc_estados.* TO NULL
  RETURN
 END IF
 MESSAGE "ADICIONANDO INFORMACION"  ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 if tpfc_estados.codest is not null  then 
 INSERT INTO fc_estados
   VALUES (tpfc_estados.*)
   if sqlca.sqlcode <> 0 then    
     MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
                               comment= "NO SE ADICIONO.. REGISTRO REFERENCIADO     "  ,
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
  LET gfc_estados.* = tpfc_estados.*
  INITIALIZE tpfc_estados.* TO NULL
 MENU "Información"  ATTRIBUTE( style= "dialog", 
                   comment= "La informacion fue Adicionada...  "  ,
                   image= "information")
       COMMAND "Aceptar"
       CLEAR FORM
         EXIT MENU
     END MENU
 ELSE
  ROLLBACK WORK
  MENU "Información"  ATTRIBUTE( style= "dialog", 
                            comment= "La adición fue cancelada      "  ,
                            image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
 END IF
 MESSAGE "" 
END FUNCTION  

FUNCTION edofactquery( exist )
 DEFINE where_info, query_text  CHAR(400),
  answer                        CHAR(1),
  exist,  curr, maxnum          integer,
  tpcodigo LIKE fc_estados.codest,
  letras string
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : CONSULTA ESTADOS "  ATTRIBUTE(BLUE)
CLEAR FORM
 CONSTRUCT where_info
  ON codest,nombre_est,descrip_est,tipo
  FROM codest,nombre_est,descrip_est,tipo
 IF int_flag THEN
  MENU "Información"  ATTRIBUTE( style= "dialog", 
                             comment= " La consulta fue cancelada",
                             image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  RETURN exist
 END IF
 DISPLAY "Buscando registro, por favor espere ..." AT 2,1
 LET query_text = " SELECT fc_estados.codest",
      " FROM fc_estados WHERE ", where_info CLIPPED,
      " ORDER BY fc_estados.codest ASC"
 DISPLAY "consulta ", query_text ," ",WHERE_info  
 PREPARE s_sfc_estados FROM query_text
 DECLARE c_sfc_estados SCROLL CURSOR FOR s_sfc_estados
 LET maxnum = 0
 FOREACH c_sfc_estados INTO tpcodigo
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_sfc_estados
  FETCH FIRST c_sfc_estados INTO tpcodigo
  LET curr = 1
  CALL edofactgetcurr( tpcodigo)
  CALL edofactshowcurr( curr, maxnum )
 ELSE
  MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
   comment= " El tipo de Estado No EXISTE", image= "exclamation")
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
    FETCH FIRST c_sfc_estados INTO tpcodigo
    LET curr = 1
   ELSE
    FETCH NEXT c_sfc_estados INTO tpcodigo
    LET curr = curr + 1
   END IF
   CALL edofactgetcurr( tpcodigo )
   CALL edofactshowcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_sfc_estados INTO tpcodigo
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_sfc_estados INTO tpcodigo
    LET curr = curr - 1
   END IF
   CALL edofactgetcurr( tpcodigo )
   CALL edofactshowcurr( curr, maxnum )
   
  COMMAND "Modifica" "Modifica el tipo de contrato en la consulta"
  -- LET mcodmen="T024"
   --CALL opcion() RETURNING op
   --if op="S" THEN
    IF gfc_estados.codest IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_estados
     CALL edofactupdate()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL edofactgetcurr( tpcodigo)
     CALL edofactshowcurr( curr, maxnum )
     OPEN c_sfc_estados
    END IF
 --  END IF
  COMMAND "Borra" "Borra el tipo de Estado en la consulta"
  --LET mcodmen="T025"
   --CALL opcion() RETURNING op
   --if op="S" THEN
    IF gfc_estados.codest  IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_estados
     CALL edofactremove()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CALL edofactshowcurr( curr, maxnum )
     END IF
     OPEN c_sfc_estados
    END IF
   --END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF gfc_estados.codest  IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sfc_estados
 RETURN exist
END FUNCTION
FUNCTION edofactupdate()
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION "  ATTRIBUTE(BLUE)
 LET tpfc_estados.* = gfc_estados.*
 INPUT BY NAME tpfc_estados.nombre_est THRU tpfc_estados.tipo WITHOUT DEFAULTS
 
  AFTER FIELD nombre_est
   IF tpfc_estados.nombre_est IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Nombre No fue Digitado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD nombre_est
   END IF
   AFTER FIELD descrip_est
   IF tpfc_estados.descrip_est IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " La Descripcioón No fue Digitada ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD descrip_est
   END IF 
AFTER FIELD tipo
   IF tpfc_estados.tipo IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "Debe Seleccionar el tipo de estado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD tipo
   END IF
--AFTER FIELD codigo
--   IF tpfc_estados.codigo IS NULL THEN
--     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
--      comment= "El código no fue digitado", image= "exclamation")
--       COMMAND "Aceptar"
--        EXIT MENU
--     END MENU
--    NEXT FIELD codigo
--   END IF
 
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
  INITIALIZE tpfc_estados.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION " AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 UPDATE  fc_estados
 SET (codest,nombre_est,descrip_est,tipo) 
    =(tpfc_estados.codest,tpfc_estados.nombre_est,tpfc_estados.descrip_est,tpfc_estados.tipo)
 WHERE  codest = gfc_estados.codest
 
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
  LET gfc_estados.* = tpfc_estados.*
 END IF
END FUNCTION 
FUNCTION edofactremove()
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : RETIRO DE TIPO DE ESTADOS " ATTRIBUTE(BLUE)
 PROMPT "Esta seguro de borrar  (s/n)? " FOR CHAR answer
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO REGISTRO " ATTRIBUTE(BLUE)
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  DELETE FROM fc_estados
    WHERE fc_estados.codest = gfc_estados.codest
  IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
   IF NOT gerrflag THEN 
   INITIALIZE gfc_estados.* TO NULL
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


