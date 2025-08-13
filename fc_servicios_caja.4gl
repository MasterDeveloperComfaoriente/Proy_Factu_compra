GLOBALS "fe_globales.4gl"
DEFINE
  gfe_servicios_caja, tpfe_servicios_caja RECORD
  codservicio        char(2),
  detalle_servicio   char(40)
  END RECORD,
  gfe_serv,tfe_serv ARRAY[100] OF RECORD
  codservicio        char(2),
  detalle_servicio   char(40)
  END RECORD
DEFINE mfe_servicios_caja RECORD LIKE fe_servicios_caja.*
FUNCTION fe_servicios_caja_main()
 DEFINE exist,ttlrow  SMALLINT
 OPEN WINDOW w_mfe_servicios_caja AT 1,1 WITH FORM "fe_servicios_caja"
 LET exist = FALSE
 LET gmaxarray = 100
 LET gmaxdply = 10
 LET glastline = 23
 CALL fe_servinitga()
 CALL fe_servinitta()
 CALL fe_servgetdetail() RETURNING ttlrow
 CALL fe_servdetail()
 MENU 
  COMMAND "Actualiza" "Adiciona y/o Modifica Servicios"
  -- LET mcodmen="E004"
  -- CALL opcion() RETURNING op
  -- if op="S" THEN
    CALL fe_servupdate(ttlrow)
    CALL fe_servgetdetail() RETURNING ttlrow
    CALL fe_servdetail()
  -- end if
  COMMAND "Visualiza" "Visualiza Servicios" 
  -- LET mcodmen="E005"
  -- CALL opcion() RETURNING op
 --  if op="S" THEN
    CALL fe_servbrowse()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfe_servicios_caja
END FUNCTION  
FUNCTION fe_servinitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE gfe_serv[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_servinitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE tfe_serv[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_servgetdetail()
 DEFINE
  tp RECORD
   codservicio       LIKE fe_servicios_caja.codservicio,
   detalle_servicio  LIKE fe_servicios_caja.detalle_servicio
  END RECORD,
  ttlrow SMALLINT 
 CALL fe_servinitga()
 DECLARE c_gfe_serv CURSOR FOR
 SELECT fe_servicios_caja.codservicio, fe_servicios_caja.detalle_servicio
  FROM fe_servicios_caja
  ORDER BY fe_servicios_caja.codservicio ASC
 LET ttlrow = 0
 FOREACH c_gfe_serv INTO tp.*
  LET ttlrow = ttlrow + 1
  IF ttlrow > gmaxarray THEN
   LET ttlrow = ttlrow - 1
   EXIT FOREACH
  ELSE
  LET gfe_serv[ttlrow].* = tp.*
  END IF
 END FOREACH
 MESSAGE "Total de Servicios: ", ttlrow 
 RETURN ttlrow
END FUNCTION  
FUNCTION fe_servdetail()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxdply
  DISPLAY gfe_serv[x].* TO servicios[x].*
 END FOR
END FUNCTION  
FUNCTION fe_servodplyg()
 DISPLAY BY NAME gfe_servicios_caja.codservicio THRU gfe_servicios_caja.detalle_servicio
END FUNCTION  
FUNCTION fe_servupdate(x)
 DEFINE cnt,x,errflag SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 CALL fe_servgatota()  
 LABEL fe_servstart :
 MESSAGE "ESTADO: ACTUALIZACION DE SERVICIOS" ATTRIBUTE(BLUE)
 CALL SET_COUNT(x)
 INPUT ARRAY tfe_serv WITHOUT DEFAULTS FROM servicios.*
 AFTER FIELD codservicio
  LET y = arr_curr()
  IF tfe_serv[y].codservicio IS NOT NULL THEN
   FOR l=1 TO gmaxarray 
    IF tfe_serv[y].codservicio=tfe_serv[l].codservicio and l<>y THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
          comment= " El codigo del Servico ya existe", 
          image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
     NEXT FIELD codservicio
    END IF
   END FOR
  END IF
  IF tfe_serv[y].codservicio IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo del Servicio no fue digitado", 
       image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
   NEXT FIELD codservicio
  END IF
  AFTER FIELD detalle_servicio
  LET y = arr_curr()
   IF tfe_serv[y].detalle_servicio IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
    comment= "el Detalle del Servicio no fue digitado", 
     image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
    NEXT FIELD detalle_servicio
   END IF
 ON KEY (F3)
  LET y = arr_curr()
  LET t = scr_line()
  INITIALIZE tfe_serv[y].* TO NULL
  DISPLAY tfe_serv[y].* to servicios[t].*
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
  CALL fe_servinitta()
  CALL fe_servdetail()
  RETURN
 END IF
 MESSAGE "ACTUALIZANDO SERVICIOS" ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 LOCK TABLE fe_servicios_caja IN SHARE MODE
 IF status <> 0 THEN
  MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
       comment= " NO SE ACTUALIZO.. REGISTRO BLOQUEADO",
       image= "stop")
   COMMAND "Aceptar"
       EXIT MENU
  END MENU
  LET x = ARR_COUNT()
  ROLLBACK WORK
  GOTO fe_servstart
 END IF
 LET errflag = FALSE
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
  DELETE FROM fe_servicios_caja 
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
   IF tfe_serv[x].codservicio IS NOT NULL AND
      tfe_serv[x].detalle_servicio IS NOT NULL  THEN
     INSERT INTO fe_servicios_caja (codservicio, detalle_servicio)
     VALUES ( tfe_serv[x].codservicio, tfe_serv[x].detalle_servicio)
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
     comment= " La informacion de los Servicios fueron actualizadas  "  ,
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
FUNCTION fe_servgatota()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET tfe_serv[x].* = gfe_serv[x].*
 END FOR
END FUNCTION  
FUNCTION fe_servgetcurr( tpcodservicio)
 DEFINE tpcodservicio LIKE fe_servicios_caja.codservicio
 INITIALIZE gfe_servicios_caja.* TO NULL
 SELECT fe_servicios_caja.codservicio, fe_servicios_caja.detalle_servicio INTO gfe_servicios_caja.*
  FROM fe_servicios_caja WHERE fe_servicios_caja.codservicio= tpcodservicio 
END FUNCTION  
FUNCTION fe_servshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 IF gfe_servicios_caja.codservicio IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")" 
 END IF
 CALL fe_servodplyg()
END FUNCTION  

FUNCTION fe_servbrowse()
 DEFINE tp RECORD
  codservicio         LIKE fe_servicios_caja.codservicio,
  detalle_servicio    LIKE fe_servicios_caja.detalle_servicio
 END RECORD,
 lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "" 
 MESSAGE "Trabajando por favor espere ... "  ATTRIBUTE(BLINK)
 LET lastline = 23
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fe_servicios_caja
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
 DECLARE c_bfe_serv SCROLL CURSOR FOR
 SELECT fe_servicios_caja.codservicio, fe_servicios_caja.detalle_servicio
  FROM fe_servicios_caja ORDER BY fe_servicios_caja.codservicio
 OPEN c_bfe_serv
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fe_servshowbrow( currrow, prevrow, pagenum ) RETURNING pagenum, prevrow 
 MESSAGE "Localizacion : ( Actual ", currrow,
          "/ Existen ", maxnum, ")" 
 MENU "VISUALIZA"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL fe_servshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL fe_servshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key ("R") "aRriba" "Se desplaza una pagina arriba"
   IF (currrow - 10) <= 0 THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow - 10
   END IF
   CALL fe_servshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key("B") "aBajo" "Se desplaza una pagina abajo"
   IF (currrow + 10) > maxnum THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow + 10
   END IF
   CALL fe_servshowbrow( currrow, prevrow, pagenum )
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
   CALL fe_servshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   LET int_flag = TRUE
   EXIT MENU
 END MENU
 CLOSE c_bfe_serv
END FUNCTION  
FUNCTION fe_servshowbrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
  codservicio              LIKE fe_servicios_caja.codservicio,
  detalle_servicio         LIKE fe_servicios_caja.detalle_servicio
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
  FETCH ABSOLUTE scrfrst c_bfe_serv INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO servicios[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO servicios[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_bfe_serv INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO servicios[y].*
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
  FETCH ABSOLUTE prevrow c_bfe_serv INTO tp.*
  DISPLAY tp.* TO servicios[scrprev].*
  FETCH ABSOLUTE currrow c_bfe_serv INTO tp.*
  DISPLAY tp.* TO servicios[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION  
