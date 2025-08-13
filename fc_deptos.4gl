GLOBALS "fc_globales.4gl"
DEFINE
  gfe_deptos,tpfe_deptos RECORD
  coddep      char(2),
  nombredep   varchar(50,0)
  END RECORD,
  gfe_dept,tfe_dept ARRAY[1100] OF RECORD
  coddep      char(2),
  nombredep   varchar(50,0)
  END RECORD
DEFINE mfe_deptos RECORD LIKE fe_deptos.*
FUNCTION fe_deptos_main()
 DEFINE exist,ttlrow  SMALLINT
 OPEN WINDOW w_mfe_deptos AT 1,1 WITH FORM "fc_deptos"
 LET exist = FALSE
 LET gmaxarray = 1100
 LET gmaxdply = 10
 LET glastline = 23
 CALL fe_deptinitga()
 CALL fe_deptinitta()
 CALL fe_deptgetdetail() RETURNING ttlrow
 CALL fe_deptdetail()
 MENU 
  COMMAND "Actualiza" "Adiciona y/o Modifica Departamentos"
  -- LET mcodmen="E004"
  -- CALL opcion() RETURNING op
  -- if op="S" THEN
    CALL fe_deptupdate(ttlrow)
    CALL fe_deptgetdetail() RETURNING ttlrow
    CALL fe_deptdetail()
  -- end if
  COMMAND "Visualiza" "Visualiza Departamentos" 
  -- LET mcodmen="E005"
  -- CALL opcion() RETURNING op
 --  if op="S" THEN
    CALL fe_deptbrowse()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfe_deptos
END FUNCTION  
FUNCTION fe_deptinitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE gfe_dept[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_deptinitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE tfe_dept[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION fe_deptgetdetail()
 DEFINE
  tp RECORD
   coddep   LIKE fe_deptos.coddep,
   nombredep  LIKE fe_deptos.nombredep
  END RECORD,
  ttlrow SMALLINT 
 CALL fe_deptinitga()
 DECLARE c_gfe_dept CURSOR FOR
 SELECT fe_deptos.coddep, fe_deptos.nombredep
  FROM fe_deptos
  ORDER BY fe_deptos.coddep ASC
 LET ttlrow = 0
 FOREACH c_gfe_dept INTO tp.*
  LET ttlrow = ttlrow + 1
  IF ttlrow > gmaxarray THEN
   LET ttlrow = ttlrow - 1
   EXIT FOREACH
  ELSE
  LET gfe_dept[ttlrow].* = tp.*
  END IF
 END FOREACH
 MESSAGE "Total Departamentos: ", ttlrow 
 RETURN ttlrow
END FUNCTION  
FUNCTION fe_deptdetail()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxdply
  DISPLAY gfe_dept[x].* TO deptos[x].*
 END FOR
END FUNCTION  
FUNCTION fe_deptodplyg()
 DISPLAY BY NAME gfe_deptos.coddep THRU gfe_deptos.nombredep
END FUNCTION  
FUNCTION fe_deptupdate(x)
 DEFINE cnt,x,errflag SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 CALL fe_deptgatota()  
 LABEL fe_deptstart :
 MESSAGE "ESTADO: ACTUALIZACION DE DEPARTAMENTOS" ATTRIBUTE(BLUE)
 CALL SET_COUNT(x)
 INPUT ARRAY tfe_dept WITHOUT DEFAULTS FROM deptos.*
 AFTER FIELD coddep
  LET y = arr_curr()
  IF tfe_dept[y].coddep IS NOT NULL THEN
   FOR l=1 TO gmaxarray 
    IF tfe_dept[y].coddep=tfe_dept[l].coddep and l<>y THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
          comment= " El codigo del Departamento ya existe", 
          image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
     NEXT FIELD coddep
    END IF
   END FOR
  END IF
  IF tfe_dept[y].coddep IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo del Departamento no fue digitado", 
       image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
   NEXT FIELD coddep
  END IF
  AFTER FIELD nombredep
  LET y = arr_curr()
   IF tfe_dept[y].nombredep IS NULL THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
    comment= "el Nombre del Departamento no fue digitada", 
     image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
    NEXT FIELD nombredep
   END IF
 ON KEY (F3)
  LET y = arr_curr()
  LET t = scr_line()
  INITIALIZE tfe_dept[y].* TO NULL
  DISPLAY tfe_dept[y].* to deptos[t].*
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
  CALL fe_deptinitta()
  CALL fe_deptdetail()
  RETURN
 END IF
 MESSAGE "ACTUALIZANDO DEPARTAMENTOS " ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 LOCK TABLE fe_deptos IN SHARE MODE
 IF status <> 0 THEN
  MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
       comment= " NO SE ACTUALIZO.. REGISTRO BLOQUEADO",
       image= "stop")
   COMMAND "Aceptar"
       EXIT MENU
  END MENU
  LET x = ARR_COUNT()
  ROLLBACK WORK
  GOTO fe_deptstart
 END IF
 LET errflag = FALSE
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
  DELETE FROM fe_deptos 
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
   IF tfe_dept[x].coddep IS NOT NULL AND
      tfe_dept[x].nombredep IS NOT NULL  THEN
     INSERT INTO fe_deptos (coddep, nombredep)
     VALUES ( tfe_dept[x].coddep, tfe_dept[x].nombredep)
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
     comment= " La informacion de los Departamentos fueron actualizados  "  ,
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
FUNCTION fe_deptgatota()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET tfe_dept[x].* = gfe_dept[x].*
 END FOR
END FUNCTION  
FUNCTION fe_deptgetcurr( tpcoddep)
 DEFINE tpcoddep LIKE fe_deptos.coddep
 INITIALIZE gfe_deptos.* TO NULL
 SELECT fe_deptos.coddep, fe_deptos.nombredep INTO gfe_deptos.*
  FROM fe_deptos WHERE fe_deptos.coddep= tpcoddep
END FUNCTION  
FUNCTION fe_deptshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 IF gfe_deptos.coddep IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")" 
 END IF
 CALL fe_deptodplyg()
END FUNCTION  

FUNCTION fe_deptbrowse()
 DEFINE tp RECORD
  coddep         LIKE fe_deptos.coddep,
  nombredep    LIKE fe_deptos.nombredep
 END RECORD,
 lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "" 
 MESSAGE "Trabajando por favor espere ... "  ATTRIBUTE(BLINK)
 LET lastline = 23
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fe_deptos
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
 DECLARE c_bfe_dept SCROLL CURSOR FOR
 SELECT fe_deptos.coddep, fe_deptos.nombredep
  FROM fe_deptos ORDER BY fe_deptos.coddep
 OPEN c_bfe_dept
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fe_deptshowbrow( currrow, prevrow, pagenum ) RETURNING pagenum, prevrow 
 MESSAGE "Localizacion : ( Actual ", currrow,
          "/ Existen ", maxnum, ")" 
 MENU "VISUALIZA"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL fe_deptshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL fe_deptshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key ("R") "aRriba" "Se desplaza una pagina arriba"
   IF (currrow - 10) <= 0 THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow - 10
   END IF
   CALL fe_deptshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND key("B") "aBajo" "Se desplaza una pagina abajo"
   IF (currrow + 10) > maxnum THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow + 10
   END IF
   CALL fe_deptshowbrow( currrow, prevrow, pagenum )
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
   CALL fe_deptshowbrow( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   MESSAGE "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" 
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   LET int_flag = TRUE
   EXIT MENU
 END MENU
 CLOSE c_bfe_dept
END FUNCTION  
FUNCTION fe_deptshowbrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
  coddep          LIKE fe_deptos.coddep,
  nombredep         LIKE fe_deptos.nombredep
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
  FETCH ABSOLUTE scrfrst c_bfe_dept INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO deptos[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO deptos[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_bfe_dept INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO deptos[y].*
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
  FETCH ABSOLUTE prevrow c_bfe_dept INTO tp.*
  DISPLAY tp.* TO deptos[scrprev].*
  FETCH ABSOLUTE currrow c_bfe_dept INTO tp.*
  DISPLAY tp.* TO deptos[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION  
