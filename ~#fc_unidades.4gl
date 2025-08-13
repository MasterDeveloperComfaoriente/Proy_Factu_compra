GLOBALS "fc_globales.4gl"
DEFINE
  gfe_unidades,tpfe_unidades RECORD
  coduni      char(4),
  descripcion      varchar(60)
  END RECORD,
  gfe_unid,tfe_unid ARRAY[1100] OF RECORD
  coduni      char(4),
  descripcion      varchar(60)
  END RECORD
DEFINE mfe_unidades RECORD LIKE fe_unidades.*
FUNCTION fc_unidades_main()
 DEFINE exist,ttlrow  SMALLINT
 OPEN WINDOW w_mfe_unidades AT 1,1 WITH FORM "fc_unidades"
 LET exist = FALSE
 LET gmaxarray = 1100
 LET gmaxdply = 10
 LET glastline = 23
 CALL fe_unidinitga()
 CALL fe_unidinitta()
 CALL fe_unidgetdetail() RETURNING ttlrow
 CALL fe_uniddetail()
 MENU 
  COMMAND "Actualiza" "Adiciona y/o Modifica las Unidades"
  -- LET mcodmen="E004"
  -- CALL opcion() RETURNING op
  -- if op="S" THEN
    CALL fe_unidupdate(ttlrow)
    CALL fe_unidgetdetail() RETURNING ttlrow
    CALL fe_uniddetail()
  -- end if
  COMMAND "Visualiza" "Visualiza las Unidades" 
  -- LET mcodmen="E005"
  -- CALL opcion() RETURNING op
 --  if op="S" THEN
    CALL fe_unidbrowse()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
  -- end if
 { COMMAND "Reporte" "Reporte general de los niveles de estudio"
   lET mcodmen="E006"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL rep_nivesc()
   END IF}
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfe_unidades
END FUNCTION  
FUNCTION fe_unidinitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE gfe_unid[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_unidinitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE tfe_unid[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_unidgetdetail()
 DEFINE
  tp RECORD
   coduni   LIKE fe_unidades.coduni,
   descripcion  LIKE fe_unidades.descripcion
  END RECORD,
  ttlrow SMALLINT 
 CALL fe_unidinitga()
 DECLARE c_gfe_unid CURSOR FOR
 SELECT fe_unidades.coduni, fe_unidades.descripcion
  FROM fe_unidades
  ORDER BY fe_unidades.coduni ASC
 LET ttlrow = 0
 FOREACH c_gfe_unid INTO tp.*
  LET ttlrow = ttlrow + 1
  IF ttlrow > gmaxarray THEN
   LET ttlrow = ttlrow - 1
   EXIT FOREACH
  ELSE
  LET gfe_unid[ttlrow].* = tp.*
  END IF
 END FOREACH
 MESSAGE "Total de Unidades: ", ttlrow 
 RETURN ttlrow
END FUNCTION  
FUNCTION fe_uniddetail()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxdply
  DISPLAY gfe_unid[x].* TO unidades[x].*
 END FOR
END FUNCTION  
FUNCTION fe_unidodplyg()
 DISPLAY BY NAME gfe_unidades.coduni THRU gfe_unidades.descripcion
END FUNCTION  
FUNCTION fe_unidupdate(x)
 DEFINE cnt,x,errflag SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 CALL fe_unidgatota()  
 LABEL fe_unidstart :
 MESSAGE "ESTADO: ACTUALIZACION DE UNIDADES" ATTRIBUTE(BLUE)
 CALL SET_COUNT(x)
 INPUT ARRAY tfe_unid WITHOUT DEFAULTS FROM unidades.*
 AFTER FIELD coduni
  LET y = arr_curr()
  IF tfe_unid[y].coduni IS NOT NULL THEN
   FOR l=1 TO gmaxarray 
    IF tfe_unid[y].coduni=tfe_unid[l].coduni and l<>y THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
          comment= " El codigo de  la Unidad ya existe", 
          image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
     NEXT FIELD coduni
    END IF
   END FOR
  END IF
  IF tfe_unid[y].coduni IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo de la Unidad no fue digitado", 
       image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
   NEXT FIELD coduni
  END IF
  AFTER FIELD descripcion
  LET y = arr_curr()
   IF tfe_unid[y].descripcion IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
    comment= "La descripcion de la Unidad no fue digitada", 
     image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
    NEXT FIELD descripcion
   END IF
 ON KEY (F3)
  LET y = arr_curr()
  LET t = scr_line()
  INITIALIZE tfe_unid[y].* TO NULL
  DISPLAY tfe_unid[y].* to unidades[t].*
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
  CALL fe_unidinitta()
  CALL fe_uniddetail()
  RETURN
 END IF
 MESSAGE "ACTUALIZANDO LAS UNIDADES " ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 LOCK TABLE fe_unidades IN SHARE MODE
 IF status <> 0 THEN
  MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
       comment= " NO SE ACTUALIZO.. REGISTRO BLOQUEADO",
       image= "stop")
   COMMAND "Aceptar"
       EXIT MENU
  END MENU
  LET x = ARR_COUNT()
  ROLLBACK WORK
  GOTO fe_unidstart
 END IF
 LET errflag = FALSE
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
  DELETE FROM fe_unidades 
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
   IF tfe_unid[x].coduni IS NOT NULL AND
      tfe_unid[x].descripcion IS NOT NULL  THEN
     INSERT INTO fe_unidades (coduni, descripcion)
     VALUES ( tfe_unid[x].coduni, tfe_unid[x].descripcion)
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
     comment= " La informacion de las Unidades fueron actualizadas  "  ,
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
FUNCTION fe_unidgatota()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET tfe_unid[x].* = gfe_unid[x].*
 END FOR
END FUNCTION  
FUNCTION fe_unidgetcurr( tpcoduni)
 DEFINE tpcoduni LIKE fe_unidades.coduni
 INITIALIZE gfe_unidades.* TO NULL
 SELECT fe_unidades.coduni, fe_unidades.descripcion INTO gfe_unidades.*
  FROM fe_unidades WHERE fe_unidades.coduni= tpcoduni
END FUNCTION  
FUNCTION fe_unidshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 IF gfe_unidades.coduni IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")" 
 END IF
 CALL fe_unidodplyg()
END FUNCTION  

FUNCTION fe_unidbrowse()
 DEFINE tp RECORD
  coduni         LIKE fe_unidades.coduni,
  descripcion    LIKE fe_unidades.descripcion
 END RECORD,
 lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "" 
 MESSAGE "Trabajando por favor espere ... "  ATTRIBUTE(BLINK)
 LET lastline = 23
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fe_unidades
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
 DECLARE c_bfe_unid SCROLL CURSOR FOR
 SELECT fe_unidades.coduni, fe_unidades.descripcion
  FROM fe_unidades ORDER BY fe_unidades.coduni
 OPEN c_bfe_unid
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fe_unidshowbrow( currrow, prevrow, pagenum ) RETURNING pagenum, prevrow 
 MESSAGE "Localizacion : ( Actual ", currrow,
          "/ Existen ", maxnum, ")" 
 MENU "VISUALIZA"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL fe_unidshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL fe_unidshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key ("R") "aRriba" "Se desplaza una pagina arriba"
   IF (currrow - 10) <= 0 THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow - 10
   END IF
   CALL fe_unidshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key("B") "aBajo" "Se desplaza una pagina abajo"
   IF (currrow + 10) > maxnum THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow + 10
   END IF
   CALL fe_unidshowbrow( currrow, prevrow, pagenum )
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
   CALL fe_unidshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   LET int_flag = TRUE
   EXIT MENU
 END MENU
 CLOSE c_bfe_unid
END FUNCTION  
FUNCTION fe_unidshowbrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
  coduni          LIKE fe_unidades.coduni,
  descripcion         LIKE fe_unidades.descripcion
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
  FETCH ABSOLUTE scrfrst c_bfe_unid INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO unidades[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO unidades[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_bfe_unid INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO unidades[y].*
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
  FETCH ABSOLUTE prevrow c_bfe_unid INTO tp.*
  DISPLAY tp.* TO unidades[scrprev].*
  FETCH ABSOLUTE currrow c_bfe_unid INTO tp.*
  DISPLAY tp.* TO unidades[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION  

