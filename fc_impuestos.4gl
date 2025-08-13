GLOBALS "fc_globales.4gl"
DEFINE
  gfe_impuestos,tpfe_impuestos RECORD
  codimpu         char(2),
  nombreimpu      char(20),
  descripcionimpu char(50)
  END RECORD,
  gfe_imp,tfe_imp ARRAY[1100] OF RECORD
  codimpu         char(2),
  nombreimpu      char(20),
  descripcionimpu char(50)
  END RECORD
DEFINE mfe_impuestos RECORD LIKE fe_impuestos.*
FUNCTION fe_impuestos_main()
 DEFINE exist,ttlrow  SMALLINT
 OPEN WINDOW w_mfe_impuestos AT 1,1 WITH FORM "fc_impuestos"
 LET exist = FALSE
 LET gmaxarray = 1100
 LET gmaxdply = 10
 LET glastline = 23
 CALL fe_impinitga()
 CALL fe_impinitta()
 CALL fe_impgetdetail() RETURNING ttlrow
 CALL fe_impdetail()
 MENU 
  COMMAND "Actualiza" "Adiciona y/o Modifica Impuestos"
  -- LET mcodmen="E004"
  -- CALL opcion() RETURNING op
  -- if op="S" THEN
    CALL fe_impupdate(ttlrow)
    CALL fe_impgetdetail() RETURNING ttlrow
    CALL fe_impdetail()
  -- end if
  COMMAND "Visualiza" "Visualiza Impuestos" 
  -- LET mcodmen="E005"
  -- CALL opcion() RETURNING op
 --  if op="S" THEN
    CALL fe_impbrowse()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfe_impuestos
END FUNCTION  
FUNCTION fe_impinitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE gfe_imp[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_impinitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE tfe_imp[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_impgetdetail()
 DEFINE
  tp RECORD
   codimpu             LIKE fe_impuestos.codimpu,
   nombreimpu          LIKE fe_impuestos.nombreimpu,
   descripcionimpu     LIKE fe_impuestos.descripcionimpu
  END RECORD,
  ttlrow SMALLINT 
 CALL fe_impinitga()
 DECLARE c_gfe_imp CURSOR FOR
 SELECT fe_impuestos.codimpu, fe_impuestos.nombreimpu,fe_impuestos.descripcionimpu
  FROM fe_impuestos
  ORDER BY fe_impuestos.codimpu ASC
 LET ttlrow = 0
 FOREACH c_gfe_imp INTO tp.*
  LET ttlrow = ttlrow + 1
  IF ttlrow > gmaxarray THEN
   LET ttlrow = ttlrow - 1
   EXIT FOREACH
  ELSE
  LET gfe_imp[ttlrow].* = tp.*
  END IF
 END FOREACH
 MESSAGE "Total Impuestos: ", ttlrow 
 RETURN ttlrow
END FUNCTION  
FUNCTION fe_impdetail()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxdply
  DISPLAY gfe_imp[x].* TO impuestos[x].*
 END FOR
END FUNCTION  
FUNCTION fe_impodplyg()
 DISPLAY BY NAME gfe_impuestos.codimpu THRU gfe_impuestos.descripcionimpu
END FUNCTION  
FUNCTION fe_impupdate(x)
 DEFINE cnt,x,errflag SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 CALL fe_impgatota()  
 LABEL fe_impstart :
 MESSAGE "ESTADO: ACTUALIZACION DE IMPUESTOS" ATTRIBUTE(BLUE)
 CALL SET_COUNT(x)
 INPUT ARRAY tfe_imp WITHOUT DEFAULTS FROM impuestos.*
 AFTER FIELD codimpu
  LET y = arr_curr()
  IF tfe_imp[y].codimpu IS NOT NULL THEN
   FOR l=1 TO gmaxarray 
    IF tfe_imp[y].codimpu=tfe_imp[l].codimpu and l<>y THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
          comment= " El codigo del Impuesto ya existe", 
          image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
     NEXT FIELD codimpu
    END IF
   END FOR
  END IF
  IF tfe_imp[y].codimpu IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo del Impuesto no fue digitado", 
       image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
   NEXT FIELD codimpu
  END IF
  AFTER FIELD nombreimpu
  LET y = arr_curr()
   IF tfe_imp[y].nombreimpu IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
    comment= "El nombre del Descuento no fue digitado", 
     image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
    NEXT FIELD nombreimpu
   END IF
 AFTER FIELD descripcionimpu
  LET y = arr_curr()
   IF tfe_imp[y].descripcionimpu IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
    comment= "La descripcion del Impuesto no fue digitado", 
     image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
    NEXT FIELD descripcionimpu
   END IF
   
 ON KEY (F3)
  LET y = arr_curr()
  LET t = scr_line()
  INITIALIZE tfe_imp[y].* TO NULL
  DISPLAY tfe_imp[y].* to impuestos[t].*
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
  CALL fe_impinitta()
  CALL fe_impdetail()
  RETURN
 END IF
 MESSAGE "ACTUALIZANDO IMPUESTOS " ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 LOCK TABLE fe_impuestos IN SHARE MODE
 IF status <> 0 THEN
  MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
       comment= " NO SE ACTUALIZO.. REGISTRO BLOQUEADO",
       image= "stop")
   COMMAND "Aceptar"
       EXIT MENU
  END MENU
  LET x = ARR_COUNT()
  ROLLBACK WORK
  GOTO fe_impstart
 END IF
 LET errflag = FALSE
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
  DELETE FROM fe_impuestos 
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
   IF tfe_imp[x].codimpu IS NOT NULL AND
      tfe_imp[x].nombreimpu IS NOT NULL AND
      tfe_imp[x].descripcionimpu IS NOT NULL  THEN
     INSERT INTO fe_impuestos (codimpu, nombreimpu,descripcionimpu)
     VALUES ( tfe_imp[x].codimpu, tfe_imp[x].nombreimpu,tfe_imp[x].descripcionimpu)
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
     comment= " La informacion de los Impuestos fueron actualizados  "  ,
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
FUNCTION fe_impgatota()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET tfe_imp[x].* = gfe_imp[x].*
 END FOR
END FUNCTION  
FUNCTION fe_impgetcurr( tpcodimpu)
 DEFINE tpcodimpu LIKE fe_impuestos.codimpu
 INITIALIZE gfe_impuestos.* TO NULL
 SELECT fe_impuestos.codimpu, fe_impuestos.nombreimpu, fe_impuestos.descripcionimpu INTO gfe_impuestos.*
  FROM fe_impuestos WHERE fe_impuestos.codimpu= tpcodimpu
END FUNCTION  
FUNCTION fe_impshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 IF gfe_impuestos.codimpu IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")" 
 END IF
 CALL fe_impodplyg()
END FUNCTION  

FUNCTION fe_impbrowse()
 DEFINE tp RECORD
  codimpu           LIKE fe_impuestos.codimpu,
  nombreimpu        LIKE fe_impuestos.nombreimpu,
  descripcionimpu   LIKE fe_impuestos.descripcionimpu
 END RECORD,
 lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "" 
 MESSAGE "Trabajando por favor espere ... "  ATTRIBUTE(BLINK)
 LET lastline = 23
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fe_impuestos
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
 DECLARE c_bfe_imp SCROLL CURSOR FOR
 SELECT fe_impuestos.codimpu, fe_impuestos.nombreimpu,fe_impuestos.descripcionimpu
  FROM fe_impuestos ORDER BY fe_impuestos.codimpu
 OPEN c_bfe_imp
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fe_impshowbrow( currrow, prevrow, pagenum ) RETURNING pagenum, prevrow 
 MESSAGE "Localizacion : ( Actual ", currrow,
          "/ Existen ", maxnum, ")" 
 MENU "VISUALIZA"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL fe_impshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL fe_impshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key ("R") "aRriba" "Se desplaza una pagina arriba"
   IF (currrow - 10) <= 0 THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow - 10
   END IF
   CALL fe_impshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key("B") "aBajo" "Se desplaza una pagina abajo"
   IF (currrow + 10) > maxnum THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow + 10
   END IF
   CALL fe_impshowbrow( currrow, prevrow, pagenum )
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
   CALL fe_impshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   LET int_flag = TRUE
   EXIT MENU
 END MENU
 CLOSE c_bfe_imp
END FUNCTION  
FUNCTION fe_impshowbrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
  codimpu           LIKE fe_impuestos.codimpu,
  nombreimpu        LIKE fe_impuestos.nombreimpu,
  descripcionimpu   LIKE fe_impuestos.descripcionimpu
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
  FETCH ABSOLUTE scrfrst c_bfe_imp INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO impuestos[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO impuestos[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_bfe_imp INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO impuestos[y].*
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
  FETCH ABSOLUTE prevrow c_bfe_imp INTO tp.*
  DISPLAY tp.* TO impuestos[scrprev].*
  FETCH ABSOLUTE currrow c_bfe_imp INTO tp.*
  DISPLAY tp.* TO impuestos[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION  
