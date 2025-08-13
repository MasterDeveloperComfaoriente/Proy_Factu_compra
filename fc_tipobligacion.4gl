GLOBALS "fc_globales.4gl"
DEFINE
  gfe_tipobligacion,tpfe_tipobligacion RECORD
  codigo_oblig      char(7),
  descripcion       char(35)
  END RECORD,
  gfe_tipoblig,tfe_tipoblig ARRAY[100] OF RECORD
  codigo_oblig      char(7),
  descripcion       char(35)
  END RECORD
DEFINE mfe_tipobligacion RECORD LIKE fe_tipobligacion.*
FUNCTION fe_tipobligacion_main()
 DEFINE exist,ttlrow  SMALLINT
 OPEN WINDOW w_mfe_tipobligacion AT 1,1 WITH FORM "fc_tipobligacion"
 LET exist = FALSE
 LET gmaxarray = 100
 LET gmaxdply = 10
 LET glastline = 23
 CALL fe_tipobliginitga()
 CALL fe_tipobliginitta()
 CALL fe_tipobliggetdetail() RETURNING ttlrow
 CALL fe_tipobligdetail()
 MENU 
  COMMAND "Actualiza" "Adiciona y/o Modifica obligaciones"
  -- LET mcodmen="E004"
  -- CALL opcion() RETURNING op
  -- if op="S" THEN
    CALL fe_tipobligupdate(ttlrow)
    CALL fe_tipobliggetdetail() RETURNING ttlrow
    CALL fe_tipobligdetail()
  -- end if
  COMMAND "Visualiza" "Visualiza obligaciones" 
  -- LET mcodmen="E005"
  -- CALL opcion() RETURNING op
 --  if op="S" THEN
    CALL fe_tipobligbrowse()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfe_tipobligacion
END FUNCTION  
FUNCTION fe_tipobliginitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE gfe_tipoblig[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_tipobliginitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE tfe_tipoblig[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_tipobliggetdetail()
 DEFINE
  tp RECORD
   codigo_oblig   LIKE fe_tipobligacion.codigo_oblig,
   descripcion    LIKE fe_tipobligacion.descripcion
  END RECORD,
  ttlrow SMALLINT 
 CALL fe_tipobliginitga()
 DECLARE c_gfe_tipoblig CURSOR FOR
 SELECT fe_tipobligacion.codigo_oblig, fe_tipobligacion.descripcion
  FROM fe_tipobligacion
  ORDER BY fe_tipobligacion.codigo_oblig ASC
 LET ttlrow = 0
 FOREACH c_gfe_tipoblig INTO tp.*
  LET ttlrow = ttlrow + 1
  IF ttlrow > gmaxarray THEN
   LET ttlrow = ttlrow - 1
   EXIT FOREACH
  ELSE
  LET gfe_tipoblig[ttlrow].* = tp.*
  END IF
 END FOREACH
 MESSAGE "Total de Obligaciones: ", ttlrow 
 RETURN ttlrow
END FUNCTION  
FUNCTION fe_tipobligdetail()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxdply
  DISPLAY gfe_tipoblig[x].* TO obligaciones[x].*
 END FOR
END FUNCTION  
FUNCTION fe_tipobligodplyg()
 DISPLAY BY NAME gfe_tipobligacion.codigo_oblig THRU gfe_tipobligacion.descripcion
END FUNCTION  
FUNCTION fe_tipobligupdate(x)
 DEFINE cnt,x,errflag SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 CALL fe_tipobliggatota()  
 LABEL fe_tipobligstart :
 MESSAGE "ESTADO: ACTUALIZACION DE OBLIGACIONES" ATTRIBUTE(BLUE)
 CALL SET_COUNT(x)
 INPUT ARRAY tfe_tipoblig WITHOUT DEFAULTS FROM obligaciones.*
 AFTER FIELD codigo_oblig
  LET y = arr_curr()
  IF tfe_tipoblig[y].codigo_oblig IS NOT NULL THEN
   FOR l=1 TO gmaxarray 
    IF tfe_tipoblig[y].codigo_oblig=tfe_tipoblig[l].codigo_oblig and l<>y THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
          comment= " El codigo de la Obligación ya existe", 
          image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
     NEXT FIELD codigo_oblig
    END IF
   END FOR
  END IF
  IF tfe_tipoblig[y].codigo_oblig IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo de la Obligacion no fue digitado", 
       image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
   NEXT FIELD codigo_oblig
  END IF
  AFTER FIELD descripcion
  LET y = arr_curr()
   IF tfe_tipoblig[y].descripcion IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
    comment= "La Descripcion de la Obligación no fue digitada", 
     image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
    NEXT FIELD descripcion
   END IF
 ON KEY (F3)
  LET y = arr_curr()
  LET t = scr_line()
  INITIALIZE tfe_tipoblig[y].* TO NULL
  DISPLAY tfe_tipoblig[y].* to obligaciones[t].*
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
  CALL fe_tipobliginitta()
  CALL fe_tipobligdetail()
  RETURN
 END IF
 MESSAGE "ACTUALIZANDO OBLIGACIONES" ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 LOCK TABLE fe_tipobligacion IN SHARE MODE
 IF status <> 0 THEN
  MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
       comment= " NO SE ACTUALIZO.. REGISTRO BLOQUEADO",
       image= "stop")
   COMMAND "Aceptar"
       EXIT MENU
  END MENU
  LET x = ARR_COUNT()
  ROLLBACK WORK
  GOTO fe_tipobligstart
 END IF
 LET errflag = FALSE
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
  DELETE FROM fe_tipobligacion 
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
   IF tfe_tipoblig[x].codigo_oblig IS NOT NULL AND
      tfe_tipoblig[x].descripcion IS NOT NULL  THEN
     INSERT INTO fe_tipobligacion (codigo_oblig, descripcion)
     VALUES ( tfe_tipoblig[x].codigo_oblig, tfe_tipoblig[x].descripcion)
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
     comment= " La informacion de las Obligaciones fueron actualizadas  "  ,
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
FUNCTION fe_tipobliggatota()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET tfe_tipoblig[x].* = gfe_tipoblig[x].*
 END FOR
END FUNCTION  
FUNCTION fe_tipobliggetcurr( tpcodigo_oblig)
 DEFINE tpcodigo_oblig LIKE fe_tipobligacion.codigo_oblig
 INITIALIZE gfe_tipobligacion.* TO NULL
 SELECT fe_tipobligacion.codigo_oblig, fe_tipobligacion.descripcion INTO gfe_tipobligacion.*
  FROM fe_tipobligacion WHERE fe_tipobligacion.codigo_oblig= tpcodigo_oblig 
END FUNCTION  
FUNCTION fe_tipobligshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 IF gfe_tipobligacion.codigo_oblig IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")" 
 END IF
 CALL fe_tipobligodplyg()
END FUNCTION  

FUNCTION fe_tipobligbrowse()
 DEFINE tp RECORD
  codigo_oblig         LIKE fe_tipobligacion.codigo_oblig,
  descripcion          LIKE fe_tipobligacion.descripcion
 END RECORD,
 lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "" 
 MESSAGE "Trabajando por favor espere ... "  ATTRIBUTE(BLINK)
 LET lastline = 23
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fe_tipobligacion
 ORDER BY  fe_tipobligacion.codigo_oblig
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
 DECLARE c_bfe_tipoblig SCROLL CURSOR FOR
 SELECT fe_tipobligacion.codigo_oblig, fe_tipobligacion.descripcion
  FROM fe_tipobligacion 
  ORDER BY fe_tipobligacion.codigo_oblig
 OPEN c_bfe_tipoblig
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fe_tipobligshowbrow( currrow, prevrow, pagenum ) RETURNING pagenum, prevrow 
 MESSAGE "Localizacion : ( Actual ", currrow,
          "/ Existen ", maxnum, ")" 
 MENU "VISUALIZA"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL fe_tipobligshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL fe_tipobligshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key ("R") "aRriba" "Se desplaza una pagina arriba"
   IF (currrow - 10) <= 0 THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow - 10
   END IF
   CALL fe_tipobligshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key("B") "aBajo" "Se desplaza una pagina abajo"
   IF (currrow + 10) > maxnum THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow + 10
   END IF
   CALL fe_tipobligshowbrow( currrow, prevrow, pagenum )
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
   CALL fe_tipobligshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   LET int_flag = TRUE
   EXIT MENU
 END MENU
 CLOSE c_bfe_tipoblig
END FUNCTION  
FUNCTION fe_tipobligshowbrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
  codigo_oblig          LIKE fe_tipobligacion.codigo_oblig,
  descripcion           LIKE fe_tipobligacion.descripcion
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
  FETCH ABSOLUTE scrfrst c_bfe_tipoblig INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO obligaciones[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO obligaciones[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_bfe_tipoblig INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO obligaciones[y].*
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
  FETCH ABSOLUTE prevrow c_bfe_tipoblig INTO tp.*
  DISPLAY tp.* TO obligaciones[scrprev].*
  FETCH ABSOLUTE currrow c_bfe_tipoblig INTO tp.*
  DISPLAY tp.* TO obligaciones[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION  
