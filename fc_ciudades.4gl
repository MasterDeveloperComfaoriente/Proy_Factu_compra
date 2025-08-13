GLOBALS "fc_globales.4gl"
DEFINE
  gfe_ciudades,tpfe_ciudades RECORD
  codciu      char(6),
  nombreciu   varchar(50,0)
  END RECORD,
  gfe_ciu,tfe_ciu ARRAY[1100] OF RECORD
  codciu      char(6),
  nombreciu   varchar(50,0)
  END RECORD
DEFINE mfe_ciudades RECORD LIKE fe_ciudades.*
FUNCTION fe_ciudades_main()
 DEFINE exist,ttlrow  SMALLINT
 OPEN WINDOW w_mfe_ciudades AT 1,1 WITH FORM "fc_ciudades"
 LET exist = FALSE
 LET gmaxarray = 1100
 LET gmaxdply = 10
 LET glastline = 23
 CALL fe_ciuinitga()
 CALL fe_ciuinitta()
 CALL fe_ciugetdetail() RETURNING ttlrow
 CALL fe_ciudetail()
 MENU 
  COMMAND "Actualiza" "Adiciona y/o Modifica Ciudades"
  -- LET mcodmen="E004"
  -- CALL opcion() RETURNING op
  -- if op="S" THEN
    CALL fe_ciuupdate(ttlrow)
    CALL fe_ciugetdetail() RETURNING ttlrow
    CALL fe_ciudetail()
  -- end if
  COMMAND "Visualiza" "Visualiza Ciudades" 
  -- LET mcodmen="E005"
  -- CALL opcion() RETURNING op
 --  if op="S" THEN
    CALL fe_ciubrowse()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfe_ciudades
END FUNCTION  
FUNCTION fe_ciuinitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE gfe_ciu[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_ciuinitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE tfe_ciu[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_ciugetdetail()
 DEFINE
  tp RECORD
   codciu   LIKE fe_ciudades.codciu,
   nombreciu  LIKE fe_ciudades.nombreciu
  END RECORD,
  ttlrow SMALLINT 
 CALL fe_ciuinitga()
 DECLARE c_gfe_ciu CURSOR FOR
 SELECT fe_ciudades.codciu, fe_ciudades.nombreciu
  FROM fe_ciudades
  ORDER BY fe_ciudades.codciu ASC
 LET ttlrow = 0
 FOREACH c_gfe_ciu INTO tp.*
  LET ttlrow = ttlrow + 1
  IF ttlrow > gmaxarray THEN
   LET ttlrow = ttlrow - 1
   EXIT FOREACH
  ELSE
  LET gfe_ciu[ttlrow].* = tp.*
  END IF
 END FOREACH
 MESSAGE "Total Ciudades: ", ttlrow 
 RETURN ttlrow
END FUNCTION  
FUNCTION fe_ciudetail()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxdply
  DISPLAY gfe_ciu[x].* TO ciudades[x].*
 END FOR
END FUNCTION  
FUNCTION fe_ciuodplyg()
 DISPLAY BY NAME gfe_ciudades.codciu THRU gfe_ciudades.nombreciu
END FUNCTION  
FUNCTION fe_ciuupdate(x)
 DEFINE cnt,x,errflag SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 CALL fe_ciugatota()  
 LABEL fe_ciustart :
 MESSAGE "ESTADO: ACTUALIZACION DE CIUDADES" ATTRIBUTE(BLUE)
 CALL SET_COUNT(x)
 INPUT ARRAY tfe_ciu WITHOUT DEFAULTS FROM ciudades.*
 AFTER FIELD codciu
  LET y = arr_curr()
  IF tfe_ciu[y].codciu IS NOT NULL THEN
   FOR l=1 TO gmaxarray 
    IF tfe_ciu[y].codciu=tfe_ciu[l].codciu and l<>y THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
          comment= " El codigo de la Ciudad ya existe", 
          image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
     NEXT FIELD codciu
    END IF
   END FOR
  END IF
  IF tfe_ciu[y].codciu IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo de la Ciudad no fue digitado", 
       image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
   NEXT FIELD codciu
  END IF
  AFTER FIELD nombreciu
  LET y = arr_curr()
   IF tfe_ciu[y].nombreciu IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
    comment= "el Nombre de la Ciudad no fue digitada", 
     image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
    NEXT FIELD nombreciu
   END IF
 ON KEY (F3)
  LET y = arr_curr()
  LET t = scr_line()
  INITIALIZE tfe_ciu[y].* TO NULL
  DISPLAY tfe_ciu[y].* to ciudades[t].*
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
  CALL fe_ciuinitta()
  CALL fe_ciudetail()
  RETURN
 END IF
 MESSAGE "ACTUALIZANDO CIUDADES " ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 LOCK TABLE fe_ciudades IN SHARE MODE
 IF status <> 0 THEN
  MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
       comment= " NO SE ACTUALIZO.. REGISTRO BLOQUEADO",
       image= "stop")
   COMMAND "Aceptar"
       EXIT MENU
  END MENU
  LET x = ARR_COUNT()
  ROLLBACK WORK
  GOTO fe_ciustart
 END IF
 LET errflag = FALSE
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
  DELETE FROM fe_ciudades 
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
   IF tfe_ciu[x].codciu IS NOT NULL AND
      tfe_ciu[x].nombreciu IS NOT NULL  THEN
     INSERT INTO fe_ciudades (codciu, nombreciu)
     VALUES ( tfe_ciu[x].codciu, tfe_ciu[x].nombreciu)
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
     comment= " La informacion de las Ciudades fueron actualizados  "  ,
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
FUNCTION fe_ciugatota()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET tfe_ciu[x].* = gfe_ciu[x].*
 END FOR
END FUNCTION  
FUNCTION fe_ciugetcurr( tpcodciu)
 DEFINE tpcodciu LIKE fe_ciudades.codciu
 INITIALIZE gfe_ciudades.* TO NULL
 SELECT fe_ciudades.codciu, fe_ciudades.nombreciu INTO gfe_ciudades.*
  FROM fe_ciudades WHERE fe_ciudades.codciu= tpcodciu
END FUNCTION  
FUNCTION fe_ciushowcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 IF gfe_ciudades.codciu IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")" 
 END IF
 CALL fe_ciuodplyg()
END FUNCTION  

FUNCTION fe_ciubrowse()
 DEFINE tp RECORD
  codciu         LIKE fe_ciudades.codciu,
  nombreciu    LIKE fe_ciudades.nombreciu
 END RECORD,
 lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "" 
 MESSAGE "Trabajando por favor espere ... "  ATTRIBUTE(BLINK)
 LET lastline = 23
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fe_ciudades
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
 DECLARE c_bfe_ciu SCROLL CURSOR FOR
 SELECT fe_ciudades.codciu, fe_ciudades.nombreciu
  FROM fe_ciudades ORDER BY fe_ciudades.codciu
 OPEN c_bfe_ciu
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fe_ciushowbrow( currrow, prevrow, pagenum ) RETURNING pagenum, prevrow 
 MESSAGE "Localizacion : ( Actual ", currrow,
          "/ Existen ", maxnum, ")" 
 MENU "VISUALIZA"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL fe_ciushowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL fe_ciushowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key ("R") "aRriba" "Se desplaza una pagina arriba"
   IF (currrow - 10) <= 0 THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow - 10
   END IF
   CALL fe_ciushowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key("B") "aBajo" "Se desplaza una pagina abajo"
   IF (currrow + 10) > maxnum THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow + 10
   END IF
   CALL fe_ciushowbrow( currrow, prevrow, pagenum )
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
   CALL fe_ciushowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   LET int_flag = TRUE
   EXIT MENU
 END MENU
 CLOSE c_bfe_ciu
END FUNCTION  
FUNCTION fe_ciushowbrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
  codciu          LIKE fe_ciudades.codciu,
  nombreciu         LIKE fe_ciudades.nombreciu
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
  FETCH ABSOLUTE scrfrst c_bfe_ciu INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO ciudades[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO ciudades[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_bfe_ciu INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO ciudades[y].*
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
  FETCH ABSOLUTE prevrow c_bfe_ciu INTO tp.*
  DISPLAY tp.* TO ciudades[scrprev].*
  FETCH ABSOLUTE currrow c_bfe_ciu INTO tp.*
  DISPLAY tp.* TO ciudades[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION  
