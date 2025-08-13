GLOBALS "fc_globales.4gl"
DEFINE
  gfe_paises,tpfe_paises RECORD
  codpais      char(2),
  nombrepais   char(50)
  END RECORD,
  gfe_pais,tfe_pais ARRAY[1100] OF RECORD
  codpais      char(2),
  nombrepais   char(50)
  END RECORD
DEFINE mfe_paises RECORD LIKE fe_paises.*
FUNCTION fe_paises_main()
 DEFINE exist,ttlrow  SMALLINT
 OPEN WINDOW w_mfe_paises AT 1,1 WITH FORM "fc_paises"
 LET exist = FALSE
 LET gmaxarray = 1100
 LET gmaxdply = 10
 LET glastline = 23
 CALL fe_paisinitga()
 CALL fe_paisinitta()
 CALL fe_paisgetdetail() RETURNING ttlrow
 CALL fe_paisdetail()
 MENU 
  COMMAND "Actualiza" "Adiciona y/o Modifica Paises"
  -- LET mcodmen="E004"
  -- CALL opcion() RETURNING op
  -- if op="S" THEN
    CALL fe_paisupdate(ttlrow)
    CALL fe_paisgetdetail() RETURNING ttlrow
    CALL fe_paisdetail()
  -- end if
  COMMAND "Visualiza" "Visualiza Paises" 
  -- LET mcodmen="E005"
  -- CALL opcion() RETURNING op
 --  if op="S" THEN
    CALL fe_paisbrowse()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfe_paises
END FUNCTION  
FUNCTION fe_paisinitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE gfe_pais[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_paisinitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE tfe_pais[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_paisgetdetail()
 DEFINE
  tp RECORD
   codpais   LIKE fe_paises.codpais,
   nombrepais  LIKE fe_paises.nombrepais
  END RECORD,
  ttlrow SMALLINT 
 CALL fe_paisinitga()
 DECLARE c_gfe_pais CURSOR FOR
 SELECT fe_paises.codpais, fe_paises.nombrepais
  FROM fe_paises
  ORDER BY fe_paises.codpais ASC
 LET ttlrow = 0
 FOREACH c_gfe_pais INTO tp.*
  LET ttlrow = ttlrow + 1
  IF ttlrow > gmaxarray THEN
   LET ttlrow = ttlrow - 1
   EXIT FOREACH
  ELSE
  LET gfe_pais[ttlrow].* = tp.*
  END IF
 END FOREACH
 MESSAGE "Total de Paises: ", ttlrow 
 RETURN ttlrow
END FUNCTION  
FUNCTION fe_paisdetail()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxdply
  DISPLAY gfe_pais[x].* TO paises[x].*
 END FOR
END FUNCTION  
FUNCTION fe_paisodplyg()
 DISPLAY BY NAME gfe_paises.codpais THRU gfe_paises.nombrepais
END FUNCTION  
FUNCTION fe_paisupdate(x)
 DEFINE cnt,x,errflag SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 CALL fe_paisgatota()  
 LABEL fe_paisstart :
 MESSAGE "ESTADO: ACTUALIZACION DE PAISES" ATTRIBUTE(BLUE)
 CALL SET_COUNT(x)
 INPUT ARRAY tfe_pais WITHOUT DEFAULTS FROM paises.*
 AFTER FIELD codpais
  LET y = arr_curr()
  IF tfe_pais[y].codpais IS NOT NULL THEN
   FOR l=1 TO gmaxarray 
    IF tfe_pais[y].codpais=tfe_pais[l].codpais and l<>y THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
          comment= " El codigo del pais ya existe", 
          image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
     NEXT FIELD codpais
    END IF
   END FOR
  END IF
  IF tfe_pais[y].codpais IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo de la Pais no fue digitado", 
       image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
   NEXT FIELD codpais
  END IF
  AFTER FIELD nombrepais
  LET y = arr_curr()
   IF tfe_pais[y].nombrepais IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
    comment= "el Nombre del Pais no fue digitada", 
     image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
    NEXT FIELD nombrepais
   END IF
 ON KEY (F3)
  LET y = arr_curr()
  LET t = scr_line()
  INITIALIZE tfe_pais[y].* TO NULL
  DISPLAY tfe_pais[y].* to paises[t].*
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
  CALL fe_paisinitta()
  CALL fe_paisdetail()
  RETURN
 END IF
 MESSAGE "ACTUALIZANDO PAISES " ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 LOCK TABLE fe_paises IN SHARE MODE
 IF status <> 0 THEN
  MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
       comment= " NO SE ACTUALIZO.. REGISTRO BLOQUEADO",
       image= "stop")
   COMMAND "Aceptar"
       EXIT MENU
  END MENU
  LET x = ARR_COUNT()
  ROLLBACK WORK
  GOTO fe_paisstart
 END IF
 LET errflag = FALSE
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
  DELETE FROM fe_paises 
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
   IF tfe_pais[x].codpais IS NOT NULL AND
      tfe_pais[x].nombrepais IS NOT NULL  THEN
     INSERT INTO fe_paises (codpais, nombrepais)
     VALUES ( tfe_pais[x].codpais, tfe_pais[x].nombrepais)
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
     comment= " La informacion de los paises fueron actualizadas  "  ,
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
FUNCTION fe_paisgatota()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET tfe_pais[x].* = gfe_pais[x].*
 END FOR
END FUNCTION  
FUNCTION fe_paisgetcurr( tpcodpais)
 DEFINE tpcodpais LIKE fe_paises.codpais
 INITIALIZE gfe_paises.* TO NULL
 SELECT fe_paises.codpais, fe_paises.nombrepais INTO gfe_paises.*
  FROM fe_paises WHERE fe_paises.codpais= tpcodpais 
END FUNCTION  
FUNCTION fe_paisshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 IF gfe_paises.codpais IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")" 
 END IF
 CALL fe_paisodplyg()
END FUNCTION  

FUNCTION fe_paisbrowse()
 DEFINE tp RECORD
  codpais         LIKE fe_paises.codpais,
  nombrepais    LIKE fe_paises.nombrepais
 END RECORD,
 lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "" 
 MESSAGE "Trabajando por favor espere ... "  ATTRIBUTE(BLINK)
 LET lastline = 23
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fe_paises
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
 DECLARE c_bfe_pais SCROLL CURSOR FOR
 SELECT fe_paises.codpais, fe_paises.nombrepais
  FROM fe_paises ORDER BY fe_paises.codpais
 OPEN c_bfe_pais
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fe_paisshowbrow( currrow, prevrow, pagenum ) RETURNING pagenum, prevrow 
 MESSAGE "Localizacion : ( Actual ", currrow,
          "/ Existen ", maxnum, ")" 
 MENU "VISUALIZA"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL fe_paisshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL fe_paisshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key ("R") "aRriba" "Se desplaza una pagina arriba"
   IF (currrow - 10) <= 0 THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow - 10
   END IF
   CALL fe_paisshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key("B") "aBajo" "Se desplaza una pagina abajo"
   IF (currrow + 10) > maxnum THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow + 10
   END IF
   CALL fe_paisshowbrow( currrow, prevrow, pagenum )
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
   CALL fe_paisshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   LET int_flag = TRUE
   EXIT MENU
 END MENU
 CLOSE c_bfe_pais
END FUNCTION  
FUNCTION fe_paisshowbrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
  codpais          LIKE fe_paises.codpais,
  nombrepais         LIKE fe_paises.nombrepais
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
  FETCH ABSOLUTE scrfrst c_bfe_pais INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO paises[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO paises[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_bfe_pais INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO paises[y].*
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
  FETCH ABSOLUTE prevrow c_bfe_pais INTO tp.*
  DISPLAY tp.* TO paises[scrprev].*
  FETCH ABSOLUTE currrow c_bfe_pais INTO tp.*
  DISPLAY tp.* TO paises[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION  
