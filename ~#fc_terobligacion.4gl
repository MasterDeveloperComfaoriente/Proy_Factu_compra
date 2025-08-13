GLOBALS "fc_globales.4gl"
DEFINE gteroblig, tpteroblig record
  nit        LIKE fe_terceros.nit,
  tpersona   LIKE fe_terceros.tipo_persona,
  razsoc     LIKE fe_terceros.razsoc,
  papellido  LIKE fe_terceros.primer_apellido,
  spellido   LIKE fe_terceros.segundo_apellido, 
  pnombre    LIKE fe_terceros.primer_nombre,
  snombre    LIKE fe_terceros.segundo_nombre
END RECORD  
DEFINE gateroblig, tateroblig ARRAY[20] OF RECORD 
  codigo_oblig         like fe_terobligacion.codigo_oblig,
  descripcion          LIKE fe_tipobligacion.descripcion
END RECORD   
FUNCTION terobligacionmain()
 DEFINE exist SMALLINT
 OPEN WINDOW w_mteroblig AT 1,1 WITH FORM "fc_terobligacion"
 LET gmaxarray = 20
 LET gmaxdply = 10
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gteroblig.* TO NULL
 INITIALIZE tpteroblig.* TO NULL

 CALL terobliginitga() 
 CALL terobliginitta() 
 CALL terobliggetcurr()
 DISPLAY BY NAME gteroblig.nit THRU gteroblig.nit
 LET gteroblig.nit= gterceros.nit
      CALL  terobligdetail()
 MENU ""
  COMMAND "Actualiza" "Modifica los usuarios por prefijo"
     CALL terobligupdate()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
    CALL terobligdetail()
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mteroblig
 
END FUNCTION
FUNCTION terobliginitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE gateroblig[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION terobliginitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE tateroblig[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION terobligdetail()
 DEFINE x SMALLINT
   DISPLAY gteroblig.nit TO nit
 IF gteroblig.tpersona="1" THEN
         DISPLAY gteroblig.razsoc TO  primer_nombre
       ELSE
         LET mnombre=NULL
         LET mnombre=gteroblig.pnombre clipped," ",gteroblig.snombre clipped," ",
            gteroblig.papellido clipped," ",gteroblig.spellido clipped," "
         DISPLAY mnombre TO  primer_nombre          
       END IF
  
 FOR x = 1 TO gmaxdply
  DISPLAY gateroblig[x].* TO dteroblig[x].*
 END FOR
END FUNCTION  
FUNCTION terobligtatoga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET gateroblig[x].* = tateroblig[x].*
 END FOR
END FUNCTION  
FUNCTION terobliggatota()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET tateroblig[x].* = gateroblig[x].*
 END FOR
END FUNCTION  
FUNCTION terobligrownull( x )
 DEFINE x, rownull SMALLINT
 LET rownull = TRUE
 IF tateroblig[x].codigo_oblig IS NOT NULL THEN
  LET rownull = FALSE
 END IF
 RETURN rownull
END FUNCTION  
FUNCTION terobliggetdetail()
 DEFINE x SMALLINT
 CALL terobliginitga()
 DECLARE c_gteroblig CURSOR FOR
 SELECT  fe_terobligacion.codigo_oblig,fe_tipobligacion.descripcion
   FROM fe_terobligacion, fe_tipobligacion WHERE fe_tipobligacion.codigo_oblig = fe_terobligacion.codigo_oblig 
        AND fe_terobligacion.nit = gteroblig.nit
 ORDER BY fe_terobligacion.codigo_oblig ASC
 LET x = 1
 FOREACH c_gteroblig INTO gateroblig[x].*
  LET x = x + 1
  IF x > gmaxarray THEN
   EXIT FOREACH
  END IF
 END FOREACH
END FUNCTION  
FUNCTION terobligupdate()
 DEFINE currow, scrrow, cnt, x, rownull, toggle, ttlrow SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
  MESSAGE "ESTADO : MODIFICACION DE LAS OBLIGACIONES POR NIT" 
 INITIALIZE tpteroblig.* TO NULL
 CALL terobliginitta()
 LET tpteroblig.* = gteroblig.*
 LET ttlrow = 1
 FOR x = 1 TO gmaxarray
  LET tateroblig[x].* = gateroblig[x].*
  CALL terobligrownull( x ) RETURNING rownull
  IF NOT rownull THEN
   INITIALIZE tateroblig[x].* TO NULL
   LET tateroblig[ttlrow].* = gateroblig[x].*
   LET ttlrow = ttlrow + 1
  ELSE
   EXIT FOR
  END IF
 END FOR
 LET ttlrow = ttlrow - 1
 LABEL terobligtog2:
 LET toggle = FALSE
 CALL SET_COUNT(ttlrow)
 INPUT ARRAY tateroblig WITHOUT DEFAULTS FROM dteroblig.*
  AFTER FIELD codigo_oblig
   LET y = arr_curr()
   let z=scr_line()
   IF tateroblig[y].codigo_oblig IS NULL THEN
    CALL terval() RETURNING tateroblig[y].codigo_oblig
    DISPLAY tateroblig[y].codigo_oblig to dteroblig[z].codigo_oblig
    IF tateroblig[y].codigo_oblig IS NULL THEN
     EXIT INPUT
    END IF
    INITIALIZE mterobligp.* TO NULL
    select * into mterobligp.* from fe_tipobligacion where codigo_oblig=tateroblig[y].codigo_oblig
   ELSE
    INITIALIZE mterobligp.* TO NULL
    select * into mterobligp.* from fe_tipobligacion where codigo_oblig=tateroblig[y].codigo_oblig
    IF mterobligp.codigo_oblig is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo de la Obligación no existe", 
       image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
     INITIALIZE tateroblig[y].* TO NULL
     INITIALIZE mterobligp.* TO NULL
     next field codigo_oblig
    END IF
   END IF
   IF tateroblig[y].codigo_oblig IS NOT NULL THEN
    FOR l=1 TO gmaxarray 
     IF tateroblig[y].codigo_oblig=tateroblig[l].codigo_oblig and l<>y THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo de la Obligacion ya exite para este Nit",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
      END MENU
      INITIALIZE tateroblig[y].* TO NULL
      INITIALIZE mterobligp.* TO NULL
      DISPLAY tateroblig[y].* TO dteroblig[z].*
      NEXT FIELD codigo_oblig
     END IF
    END FOR
   ELSE
     INITIALIZE tateroblig[y].* TO NULL
     NEXT FIELD codigo_oblig[z]
   END IF
   LET tateroblig[y].descripcion=mterobligp.descripcion
   DISPLAY tateroblig[y].descripcion TO dteroblig[z].descripcion
  AFTER INPUT
   IF int_flag THEN
    EXIT INPUT
   END IF
  END INPUT
  IF toggle THEN
   GOTO terobligtog2
  END IF
  IF int_flag THEN
   CLEAR FORM
  CLEAR FORM
   MENU "Información"  ATTRIBUTE(style= "dialog", 
     comment= " La modificacion fue cancelada      "  ,
     image= "information")
       COMMAND "Aceptar"
         EXIT MENU
   END MENU
   INITIALIZE tpteroblig.* TO NULL
   CALL terobliginitta()
   DISPLAY "" AT 1,1
   RETURN
  END IF
 LET gerrflag = FALSE
 MESSAGE "MODIFICANDO LAS OBLIGACIONES POR NIT"
 BEGIN WORK
 LET gerrflag = FALSE
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 IF NOT gerrflag THEN
  DELETE FROM fe_terobligacion
   WHERE nit = gteroblig.nit
  IF status <> 0 THEN
    MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
     comment= " EL REGISTRO ESTA REFERENCIADO",
      image= "stop")
     COMMAND "Aceptar"
       EXIT MENU
    END MENU
   LET gerrflag = TRUE
  END IF
 END IF
 IF NOT gerrflag THEN
  FOR x = 1 TO ARR_COUNT()
   IF tateroblig[x].codigo_oblig IS NOT NULL THEN
    INSERT INTO fe_terobligacion ( nit, codigo_oblig )
      VALUES ( gteroblig.nit, tateroblig[x].codigo_oblig )
     IF status <> 0 THEN
      LET gerrflag = TRUE
      EXIT FOR
     END IF
   END IF  
  END FOR
 END IF
 IF NOT gerrflag THEN
  COMMIT WORK
  LET gteroblig.* = tpteroblig.*
  LET cnt = 1
  FOR x = 1 TO gmaxarray
   INITIALIZE gateroblig[x].* TO NULL
   CALL terobligrownull( x ) RETURNING rownull
   IF NOT rownull THEN
    LET gateroblig[cnt].* = tateroblig[x].*
    LET cnt = cnt + 1
   END IF
  END FOR
   MENU "Información"  ATTRIBUTE( style= "dialog", 
     comment= " Las Obligaciones por Nit fueron actualizados  "  ,
      image= "information")
       COMMAND "Aceptar"
         EXIT MENU
   END MENU 
 ELSE
  MENU "Información"  ATTRIBUTE( style= "dialog", 
     comment= " La actualizacion fue cancelada      "  ,
      image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  ROLLBACK WORK
 END IF
END FUNCTION 

FUNCTION terobliggetcurr()-- ( tpnit)
 DEFINE tpnit LIKE fe_terceros.nit
 LET tpnit= gterceros.nit 
 INITIALIZE gteroblig.* TO NULL
 SELECT nit,tipo_persona,razsoc,primer_apellido,segundo_apellido,primer_nombre,segundo_nombre
  INTO gteroblig.* FROM fe_terceros WHERE nit = tpnit
 CALL terobliggetdetail()
END FUNCTION  
FUNCTION terobligshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 DISPLAY "" AT glastline,1
 IF gteroblig.nit IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")" 
 END IF
 CALL terobligdetail()
END FUNCTION  
{FUNCTION terobligquery( exist )
 DEFINE answer CHAR(1),
  exist, curr, cnt SMALLINT,
  tpnit LIKE fe_terceros.nit,
  where_info, query_text CHAR(400)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO: CONSULTA DE LAS OBLIGACIONES POR NIT "
 CLEAR FORM
 CONSTRUCT where_info
  ON  nit--,tipo_persona,razsoc,primer_apellido,segundo_apellido,primer_nombre,segundo_nombre
  FROM  nit--,tipo_persona,razsoc,primer_apellido,segundo_apellido,primer_nombre,segundo_nombre
 IF int_flag THEN
  MENU "Información"  ATTRIBUTE( style= "dialog", 
      comment= " La consulta fue cancelada",image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  RETURN exist
 END IF
 DISPLAY "Buscando el NIT, por favor espere ..." AT 2,1
 LET query_text = " SELECT fe_terceros.nit",
                  " FROM fe_terceros WHERE ", where_info CLIPPED,
                  " ORDER BY fe_terceros.nit ASC"
 PREPARE s_steroblig FROM query_text
 DECLARE c_steroblig SCROLL CURSOR FOR s_steroblig
 LET cnt = 0

 FOREACH c_steroblig INTO tpnit

 LET cnt = cnt + 1
 END FOREACH
 IF ( cnt > 0 ) THEN
  OPEN c_steroblig
  FETCH FIRST c_steroblig INTO tpnit
  LET curr = 1
  CALL terobliggetcurr( tpnit)
  CALL terobligshowcurr( curr, cnt )
 ELSE
   MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
       comment= " No hay registros para visualizar",
       image= "exclamation")
    COMMAND "Aceptar"
      EXIT MENU
  END MENU
  RETURN exist
 END IF
 LET gerrflag = FALSE
 DISPLAY "" AT 2,1
 MENU ""
  COMMAND "Primero" "Desplaza al primer registro en consulta"
   HELP 0
   FETCH FIRST c_steroblig INTO tpnit
   LET curr = 1
   CALL terobliggetcurr( tpnit)
   CALL terobligshowcurr( curr, cnt )
  COMMAND "Ultimo" "Desplaza al ultimo registro en consulta" 
   HELP 4
   FETCH LAST c_steroblig INTO tpnit
   LET curr = cnt
   CALL terobliggetcurr( tpnit)
   CALL terobligshowcurr( curr, cnt )
  COMMAND "Inmediato" "Se desplaza al siguiente registro en consulta"
   HELP 5
   IF ( curr = cnt ) THEN
    FETCH FIRST c_steroblig INTO tpnit
    LET curr = 1
   ELSE
    FETCH NEXT c_steroblig INTO tpnit
    LET curr = curr + 1
   END IF
   CALL terobliggetcurr( tpnit)
   CALL terobligshowcurr( curr, cnt )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_steroblig INTO tpnit
    LET curr = cnt
   ELSE
    FETCH PREVIOUS c_steroblig INTO tpnit
    LET curr = curr - 1
   END IF
   CALL terobliggetcurr( tpnit)
   CALL terobligshowcurr( curr, cnt )
  COMMAND "Modifica" "Modifica los conceptos por linea de credito"
   --LET mcodmen="FC14"
   --CALL opcion() RETURNING op
   --if op="S" THEN
    IF gteroblig.nit IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_steroblig
     CALL terobligupdate()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL terobliggetcurr( tpnit)
     CALL terobligshowcurr( curr, cnt )
     OPEN c_steroblig
    END IF
  -- end if
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF gteroblig.nit IS NULL THEN
    LET exist = FALSE
   ELSE
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_steroblig
 LET gerrflag = FALSE
 IF NOT exist THEN
  INITIALIZE gteroblig.* TO NULL
  CALL terobliginitga()
 END IF
 DISPLAY "" AT glastline,1
 RETURN exist
END FUNCTION } 
FUNCTION terval()
 DEFINE WHERE_info, query_text char(400)
 DEFINE tp   RECORD
   codigo_oblig             LIKE fe_tipobligacion.codigo_oblig,
   descripcion              LIKE fe_tipobligacion.descripcion
  END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fe_tipobligacion
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.codigo_oblig = NULL
  RETURN tp.codigo_oblig
 END IF
 OPEN WINDOW w_vtpoblig AT 8,32 WITH FORM "tpobligv"
 DISPLAY "" AT 1,10
 DISPLAY "Trabajando por favor espere ... " AT 2,1

DECLARE c_vtpoblig SCROLL CURSOR FOR
  SELECT fe_tipobligacion.codigo_oblig,fe_tipobligacion.descripcion
  FROM fe_tipobligacion
 ORDER BY  fe_tipobligacion.codigo_oblig
 OPEN c_vtpoblig 
  LET currrow = 1
  LET prevrow = 1
  LET pagenum = 0
 CALL tpobligrow( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
 DISPLAY "" AT lastline,1
 MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
 MENU ":"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   HELP 5
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL tpobligrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL tpobligrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Vaya" "Se desplaza al registro No.()."
   HELP 9
   LET status = -1
   WHILE ( status < 0 )
    LET status = 1
    PROMPT "Entre el numero de la posicion (1 - ", maxnum, "): " FOR gotorow
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
   CALL tpobligrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vtpoblig INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.codigo_oblig = NULL
   EXIT MENU
 END MENU
 CLOSE c_vtpoblig
 CLOSE WINDOW w_vtpoblig
 RETURN tp.codigo_oblig
END FUNCTION  
FUNCTION tpobligrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   codigo_oblig        LIKE fe_tipobligacion.codigo_oblig,
   descripcion         LIKE fe_tipobligacion.descripcion
  END RECORD,
  scrmax,scrcurr,scrprev,currrow,prevrow,pagenum,newpagenum,x,y,scrfrst INTEGER
 LET scrmax = 5
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
  FETCH ABSOLUTE scrfrst c_vtpoblig INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cenv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO cenv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vtpoblig INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO cenv[y].*
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
  FETCH ABSOLUTE prevrow c_vtpoblig INTO tp.*
  DISPLAY tp.* TO cenv[scrprev].*
  FETCH ABSOLUTE currrow c_vtpoblig INTO tp.*
  DISPLAY tp.* TO cenv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION

