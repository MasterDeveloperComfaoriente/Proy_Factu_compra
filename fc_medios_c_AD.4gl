GLOBALS "fe_globales.4gl"

 FUNCTION fe_mediosc_ADmain()
 DEFINE exist  SMALLINT

 OPEN WINDOW w_mfe_mediosc_AD AT 1,1 WITH FORM "fe_mediosc_AD"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE  gfe_mediosc.* TO NULL
 INITIALIZE  tpfe_mediosc.* TO NULL

   
  MENU
   COMMAND "Adiciona" "Adiciona "
    CALL fe_mediocdd()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF

 COMMAND "Consulta" "Consulta Medios de Compra "

    CALL fe_mediocquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF

    
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfe_mediosc_AD
END FUNCTION

FUNCTION fe_mediocdplyg()
DISPLAY BY NAME gfe_mediosc.codmed THRU gfe_mediosc.detalle
END FUNCTION

FUNCTION fe_mediocdd()
DEFINE mnumero LIKE fe_medios_c.codmed
DEFINE mnumcod INTEGER
DEFINE  cnt, x, v SMALLINT


 DEFINE control SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 MESSAGE "ESTADO: ADICION MEDIOS DE COMPRA"  ATTRIBUTE(BLUE)
 INITIALIZE tpfe_mediosc.* TO NULL
 INPUT BY NAME tpfe_mediosc.codmed THRU tpfe_mediosc.detalle WITHOUT DEFAULTS

  BEFORE FIELD codmed
  select max(codmed) into mnumcod  from fe_medios_c
    WHERE codmed=tpfe_mediosc.codmed
   if mnumcod  is NULL  then let mnumcod =1 end if
   LET cnt = 1
   LET x = mnumcod 
   LET tpfe_mediosc.codmed = x USING "&&"
   WHILE cnt <> 0
   SELECT COUNT(*) INTO cnt FROM fe_medios_c
     WHERE codmed = tpfe_mediosc.codmed 
    IF cnt <> 0 THEN
     LET x = x + 1
     LET tpfe_mediosc.codmed = x USING "&&"
     DISPLAY BY NAME tpfe_mediosc.codmed
    ELSE
     EXIT WHILE
    END IF
   END WHILE
   DISPLAY BY NAME tpfe_mediosc.codmed
  --NEXT FIELD detalle

 
 AFTER FIELD codmed
   IF tpfe_mediosc.codmed IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El código no fue digitada ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD codmed
   END IF
 
   
   let mnumero=tpfe_mediosc.codmed
   LET CONTROL = NULL 
   SELECT count(*) INTO control FROM fe_medios_c
     WHERE fe_medios_c.codmed=mnumero
   DISPLAY ":",control  
   IF control<>0 then
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El código del medio de comrpa ya esta Sistematizado ",
             image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD codmed
    END IF

   
  AFTER FIELD detalle
   IF tpfe_mediosc.detalle IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " La Descripción No fue Digitada ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD detalle
   END IF
  

   
  AFTER INPUT
   IF int_flag THEN
      EXIT INPUT
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
    INITIALIZE tpfe_mediosc.* TO NULL
  RETURN
 END IF
 MESSAGE "ADICIONANDO INFORMACION"  ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 if tpfe_mediosc.codmed is not null and tpfe_mediosc.detalle is not null  then 
 INSERT INTO fe_medios_c
   VALUES (tpfe_mediosc.*)
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
  LET gfe_mediosc.* = tpfe_mediosc.*
  INITIALIZE tpfe_mediosc.* TO NULL
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


---FIN ADICIONA

FUNCTION fe_mediocupdate()
DEFINE mnumero LIKE fe_medios_c.codmed

 DEFINE cnt,control SMALLINT
 --DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION "  ATTRIBUTE(BLUE)
 LET tpfe_mediosc.* = gfe_mediosc.*
 INPUT BY NAME tpfe_mediosc.detalle THRU tpfe_mediosc.detalle  WITHOUT DEFAULTS
 
 
  AFTER FIELD detalle
   IF tpfe_mediosc.detalle  IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " La Descripción No fue Digitada ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD detalle
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
  INITIALIZE tpfe_mediosc.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION " AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 UPDATE  fe_medios_c
 SET (codmed,detalle) 
    =(tpfe_mediosc.codmed, tpfe_mediosc.detalle)
 WHERE  codmed = gfe_mediosc.codmed
 
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
  LET gfe_mediosc.* = tpfe_mediosc.*
 END IF
END FUNCTION  




FUNCTION fe_medioscgetcurr( tpcodmed)
  DEFINE letras string
  DEFINE tpcodmed LIKE fe_medios_c.codmed
  
  INITIALIZE gfe_mediosc.* TO NULL
  SELECT *  INTO gfe_mediosc.*  FROM fe_medios_c
   WHERE fe_medios_c.codmed = tpcodmed
END FUNCTION



FUNCTION fe_medioschowcurr( rownum, maxnum )
 DEFINE rownum, maxnum INTEGER
 IF gfe_mediosc.codmed IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum,
          "/ Existen ", maxnum, ")"
 END IF
CALL fe_mediocdplyg()
END FUNCTION


FUNCTION fe_mediocquery( exist )
 DEFINE where_info, query_text  CHAR(400),
  answer                        CHAR(1),
  exist,  curr, maxnum          integer,
  tpcodmed LIKE fe_medios_c.codmed,
  
  letras string
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : CONSULTA "  ATTRIBUTE(BLUE)
CLEAR FORM
 CONSTRUCT where_info
  ON codmed, detalle
  FROM codmed, detalle
 IF int_flag THEN
  MENU "Información"  ATTRIBUTE( style= "dialog", 
                             comment= " La consulta fue cancelada",
                             image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  RETURN exist
 END IF
 DISPLAY "Buscando el medio de compra, por favor espere ..." AT 2,1
 LET query_text = " SELECT fe_medios_c.codmed",
      " FROM fe_medios_c WHERE ", where_info CLIPPED,
      " ORDER BY fe_medios_c.codmed ASC"
 DISPLAY "consulta ", query_text ," ",WHERE_info  
 PREPARE s_sfe_medios_c FROM query_text
 DECLARE c_sfe_medios_c SCROLL CURSOR FOR s_sfe_medios_c
 LET maxnum = 0
 FOREACH c_sfe_medios_c INTO tpcodmed
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_sfe_medios_c
  FETCH FIRST c_sfe_medios_c INTO tpcodmed
  LET curr = 1
  CALL fe_medioscgetcurr( tpcodmed)
  CALL fe_medioschowcurr( curr, maxnum )
 ELSE
  MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
   comment= " El medio de compra No EXISTE", image= "exclamation")
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
    FETCH FIRST c_sfe_medios_c INTO tpcodmed
    LET curr = 1
   ELSE
    FETCH NEXT c_sfe_medios_c INTO tpcodmed
    LET curr = curr + 1
   END IF
   CALL fe_medioscgetcurr( tpcodmed )
   CALL fe_medioschowcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_sfe_medios_c INTO tpcodmed
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_sfe_medios_c INTO tpcodmed
    LET curr = curr - 1
   END IF
   CALL fe_medioscgetcurr( tpcodmed )
   CALL fe_medioschowcurr( curr, maxnum )
   
  COMMAND "Modifica" "Modifica el medio de compra en la consulta"
    IF gfe_mediosc.codmed IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfe_medios_c
     CALL fe_mediocupdate()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL fe_medioscgetcurr( tpcodmed)
     CALL fe_medioschowcurr( curr, maxnum )
     OPEN c_sfe_medios_c
    END IF
 --END IF
 
  COMMAND "Borra" "Borra el medio de compra en consulta"

    IF gfe_mediosc.codmed  IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfe_medios_c
     CALL fe_medioscremove()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CALL fe_medioschowcurr( curr, maxnum )
     END IF
     OPEN c_sfe_medios_c
    END IF
  -- END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF gfe_mediosc.codmed  IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sfe_medios_c
 RETURN exist
END FUNCTION


----FIN CONSULTA


FUNCTION fe_medioscremove()
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : RETIRO DE MEDIOS DE COMPRA " ATTRIBUTE(BLUE)
 PROMPT "Esta seguro de borrar  (s/n)? " FOR CHAR answer
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO  MEDIOS DE COMPRA " ATTRIBUTE(BLUE)
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  DELETE FROM fe_medios_c
    WHERE fe_medios_c.codmed = gfe_mediosc.codmed
  IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
   IF NOT gerrflag THEN 
   INITIALIZE gfe_mediosc.* TO NULL
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


