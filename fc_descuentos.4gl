GLOBALS "fc_globales.4gl"
DEFINE
  gfe_descuentos,tpfe_descuentos RECORD
  coddesc      char(2),
  nombredes    char(50)
  END RECORD,
  gfe_des,tfe_des ARRAY[1100] OF RECORD
  coddesc      char(2),
  nombredes    char(50)
  END RECORD
DEFINE mfe_descuentos RECORD LIKE fe_descuentos.*
FUNCTION fe_descuentos_main()
 DEFINE exist,ttlrow  SMALLINT
 OPEN WINDOW w_mfe_descuentos AT 1,1 WITH FORM "fc_descuentos"
 LET exist = FALSE
 LET gmaxarray = 1100
 LET gmaxdply = 10
 LET glastline = 23
 CALL fe_desinitga()
 CALL fe_desinitta()
 CALL fe_desgetdetail() RETURNING ttlrow
 CALL fe_desdetail()
 MENU 
  COMMAND "Actualiza" "Adiciona y/o Modifica Descuentos"
  -- LET mcodmen="E004"
  -- CALL opcion() RETURNING op
  -- if op="S" THEN
    CALL fe_desupdate(ttlrow)
    CALL fe_desgetdetail() RETURNING ttlrow
    CALL fe_desdetail()
  -- end if
  COMMAND "Visualiza" "Visualiza Descuentos" 
  -- LET mcodmen="E005"
  -- CALL opcion() RETURNING op
 --  if op="S" THEN
    CALL fe_desbrowse()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfe_descuentos
END FUNCTION  
FUNCTION fe_desinitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE gfe_des[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_desinitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE tfe_des[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_desgetdetail()
 DEFINE
  tp RECORD
   coddesc   LIKE fe_descuentos.coddesc,
   nombredes LIKE fe_descuentos.nombredes
  END RECORD,
  ttlrow SMALLINT 
 CALL fe_desinitga()
 DECLARE c_gfe_des CURSOR FOR
 SELECT fe_descuentos.coddesc, fe_descuentos.nombredes
  FROM fe_descuentos
  ORDER BY fe_descuentos.coddesc ASC
 LET ttlrow = 0
 FOREACH c_gfe_des INTO tp.*
  LET ttlrow = ttlrow + 1
  IF ttlrow > gmaxarray THEN
   LET ttlrow = ttlrow - 1
   EXIT FOREACH
  ELSE
  LET gfe_des[ttlrow].* = tp.*
  END IF
 END FOREACH
 MESSAGE "Total Descuentos: ", ttlrow 
 RETURN ttlrow
END FUNCTION  
FUNCTION fe_desdetail()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxdply
  DISPLAY gfe_des[x].* TO descuentos[x].*
 END FOR
END FUNCTION  
FUNCTION fe_desodplyg()
 DISPLAY BY NAME gfe_descuentos.coddesc THRU gfe_descuentos.nombredes
END FUNCTION  
FUNCTION fe_desupdate(x)
 DEFINE cnt,x,errflag SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 CALL fe_desgatota()  
 LABEL fe_desstart :
 MESSAGE "ESTADO: ACTUALIZACION DE DESCUENTOS" ATTRIBUTE(BLUE)
 CALL SET_COUNT(x)
 INPUT ARRAY tfe_des WITHOUT DEFAULTS FROM descuentos.*
 AFTER FIELD coddesc
  LET y = arr_curr()
  IF tfe_des[y].coddesc IS NOT NULL THEN
   FOR l=1 TO gmaxarray 
    IF tfe_des[y].coddesc=tfe_des[l].coddesc and l<>y THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
          comment= " El codigo del Descuento ya existe", 
          image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
     NEXT FIELD coddesc
    END IF
   END FOR
  END IF
  IF tfe_des[y].coddesc IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo del Descuento no fue digitado", 
       image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
   NEXT FIELD coddesc
  END IF
  AFTER FIELD nombredes
  LET y = arr_curr()
   IF tfe_des[y].nombredes IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
    comment= "La descripcion del Descuento no fue digitada", 
     image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
    NEXT FIELD nombredes
   END IF
 ON KEY (F3)
  LET y = arr_curr()
  LET t = scr_line()
  INITIALIZE tfe_des[y].* TO NULL
  DISPLAY tfe_des[y].* to descuentos[t].*
  AFTER INPUT
   IF int_flag THEN
    EXIT INPUT
   END IF
 END INPUT
 MESSAGE "" 
 IF int_flag THEN
  CLEAR FORM
   MENU "Información"  ATTRIBUTE(style= "dialog", 
     comment= " La actualización fue cancelada      "  ,
     image= "information")
       COMMAND "Aceptar"
         EXIT MENU
   END MENU
  CALL fe_desinitta()
  CALL fe_desdetail()
  RETURN
 END IF
 MESSAGE "ACTUALIZANDO DESCUENTOS " ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 LOCK TABLE fe_descuentos IN SHARE MODE
 IF status <> 0 THEN
  MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
       comment= " NO SE ACTUALIZO.. REGISTRO BLOQUEADO",
       image= "stop")
   COMMAND "Aceptar"
       EXIT MENU
  END MENU
  LET x = ARR_COUNT()
  ROLLBACK WORK
  GOTO fe_desstart
 END IF
 LET errflag = FALSE
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
  DELETE FROM fe_descuentos 
  IF status <> 0 THEN
    MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
     comment= " EL REGISTRO ESTA REFERENCIADO",
      image= "stop")
     COMMAND "Aceptar"
       EXIT MENU
    END MENU
    LET errflag = TRUE
  END IF
 IF NOT errflag THEN
  FOR x = 1 TO ARR_COUNT()
   IF tfe_des[x].coddesc IS NOT NULL AND
      tfe_des[x].nombredes IS NOT NULL  THEN
     INSERT INTO fe_descuentos (coddesc, nombredes)
     VALUES ( tfe_des[x].coddesc, tfe_des[x].nombredes)
     IF status <> 0 THEN
      LET errflag = TRUE
      EXIT FOR
     END IF
   END IF
  END FOR
 END IF
 IF NOT errflag THEN
  COMMIT WORK
  MENU "Información"  ATTRIBUTE( style= "dialog", 
     comment= " La informacion de los Descuentos fueron actualizados  "  ,
      image= "information")
       COMMAND "Aceptar"
         EXIT MENU
   END MENU 
 ELSE
  ROLLBACK WORK
  MENU "Información"  ATTRIBUTE( style= "dialog", 
     comment= " La actualizacion fue cancelada      "  ,
      image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  END IF
END FUNCTION  
FUNCTION fe_desgatota()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET tfe_des[x].* = gfe_des[x].*
 END FOR
END FUNCTION  
FUNCTION fe_desgetcurr( tpcoddesc)
 DEFINE tpcoddesc LIKE fe_descuentos.coddesc
 INITIALIZE gfe_descuentos.* TO NULL
 SELECT fe_descuentos.coddesc, fe_descuentos.nombredes INTO gfe_descuentos.*
  FROM fe_descuentos WHERE fe_descuentos.coddesc= tpcoddesc
END FUNCTION  
FUNCTION fe_desshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 IF gfe_descuentos.coddesc IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")" 
 END IF
 CALL fe_desodplyg()
END FUNCTION  

FUNCTION fe_desbrowse()
 DEFINE tp RECORD
  coddesc         LIKE fe_descuentos.coddesc,
  nombredes   LIKE fe_descuentos.nombredes
 END RECORD,
 lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "" 
 MESSAGE "Trabajando por favor espere ... "  ATTRIBUTE(BLINK)
 LET lastline = 23
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fe_descuentos
 IF NOT maxnum THEN
   MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
       comment= " No hay registros para visualizar",
       image= "exclamation")
    COMMAND "Aceptar"
      EXIT MENU
  END MENU
  LET int_flag = TRUE
  RETURN
 END IF
 MESSAGE "" 
 MESSAGE "Trabajando por favor espere ... " 
 DECLARE c_bfe_des SCROLL CURSOR FOR
 SELECT fe_descuentos.coddesc, fe_descuentos.nombredes
  FROM fe_descuentos ORDER BY fe_descuentos.coddesc
 OPEN c_bfe_des
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fe_desshowbrow( currrow, prevrow, pagenum ) RETURNING pagenum, prevrow 
 MESSAGE "Localizacion : ( Actual ", currrow,
          "/ Existen ", maxnum, ")" 
 MENU "VISUALIZA"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL fe_desshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL fe_desshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key ("R") "aRriba" "Se desplaza una pagina arriba"
   IF (currrow - 10) <= 0 THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow - 10
   END IF
   CALL fe_desshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key("B") "aBajo" "Se desplaza una pagina abajo"
   IF (currrow + 10) > maxnum THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow + 10
   END IF
   CALL fe_desshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND "Vaya" "Se desplaza al registro No.()."
   LET status = -1
   WHILE ( status < 0 )
    LET status = 1
    PROMPT "Enter el numero de la posicion (1 - ", maxnum, "): " FOR gotorow
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
   CALL fe_desshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   LET int_flag = TRUE
   EXIT MENU
 END MENU
 CLOSE c_bfe_des
END FUNCTION  
FUNCTION fe_desshowbrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
  coddesc          LIKE fe_descuentos.coddesc,
  nombredes        LIKE fe_descuentos.nombredes
 END RECORD,
 scrmax, scrcurr, scrprev, currrow, prevrow,
 pagenum, newpagenum, x, y, scrfrst INTEGER
 LET scrmax = 10
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
  FETCH ABSOLUTE scrfrst c_bfe_des INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO descuentos[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO descuentos[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_bfe_des INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO descuentos[y].*
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
  FETCH ABSOLUTE prevrow c_bfe_des INTO tp.*
  DISPLAY tp.* TO descuentos[scrprev].*
  FETCH ABSOLUTE currrow c_bfe_des INTO tp.*
  DISPLAY tp.* TO descuentos[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION  
