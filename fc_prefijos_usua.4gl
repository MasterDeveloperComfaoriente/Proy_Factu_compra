GLOBALS "fc_globales.4gl"

DEFINE glincon, tplincon record
  prefijo        like fc_prefijos.prefijo,
  descripcion    like fc_prefijos.descripcion
END RECORD  
DEFINE galincon, talincon ARRAY[20] OF RECORD 
  usu_elabora    like fc_prefijos_usu.usu_elabora,
  nombre         like gener02.nombre
END RECORD   
FUNCTION prefijosusumain()
 DEFINE exist SMALLINT
 OPEN WINDOW w_mlincon AT 1,1 WITH FORM "fc_prefijos_usua"
 LET gmaxarray = 20
 LET gmaxdply = 10
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE glincon.* TO NULL
 INITIALIZE tplincon.* TO NULL
 CALL linconinitga()
 CALL linconinitta()
 MENU ""
  COMMAND "Consulta" "Consulta los usuarios por prefijoi"
   LET mcodmen="FC13"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL linconquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL lincondetail()
   end if
  COMMAND "Modifica" "Modifica los usuarios por prefijo"
   LET mcodmen="FC14"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
          comment= " No existen usuarios para prefijo", 
          image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
    ELSE
     CALL linconupdate()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
    END IF
    CALL lincondetail()
   end if
  
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mlincon
END FUNCTION 
FUNCTION linconinitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE galincon[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION linconinitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE talincon[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION lincondetail()
 DEFINE x SMALLINT
   DISPLAY glincon.prefijo TO prefijo
   DISPLAY glincon.descripcion TO descripcion
 FOR x = 1 TO gmaxdply
  DISPLAY galincon[x].* TO dlincon[x].*
 END FOR
END FUNCTION  
FUNCTION lincontatoga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET galincon[x].* = talincon[x].*
 END FOR
END FUNCTION  
FUNCTION lincongatota()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET talincon[x].* = galincon[x].*
 END FOR
END FUNCTION  
FUNCTION linconrownull( x )
 DEFINE x, rownull SMALLINT
 LET rownull = TRUE
 IF talincon[x].usu_elabora IS NOT NULL THEN
  LET rownull = FALSE
 END IF
 RETURN rownull
END FUNCTION  
FUNCTION lincongetdetail()
 DEFINE x SMALLINT
 CALL linconinitga()
 DECLARE c_glincon CURSOR FOR
 SELECT fc_prefijos_usu.usu_elabora, gener02.nombre 
   FROM fc_prefijos_usu, gener02 WHERE  gener02.usuario = fc_prefijos_usu.usu_elabora
   AND fc_prefijos_usu.prefijo = glincon.prefijo
  ORDER BY fc_prefijos_usu.usu_elabora ASC
 LET x = 1
 FOREACH c_glincon INTO galincon[x].*
  LET x = x + 1
  IF x > gmaxarray THEN
   EXIT FOREACH
  END IF
 END FOREACH
END FUNCTION  
FUNCTION linconupdate()
 DEFINE currow, scrrow, cnt, x, rownull, toggle, ttlrow SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
  MESSAGE "ESTADO : MODIFICACION DE LOS USUARIOS POR PREFIJO" 
 INITIALIZE tplincon.* TO NULL
 CALL linconinitta()
 LET tplincon.* = glincon.*
 LET ttlrow = 1
 FOR x = 1 TO gmaxarray
  LET talincon[x].* = galincon[x].*
  CALL linconrownull( x ) RETURNING rownull
  IF NOT rownull THEN
   INITIALIZE talincon[x].* TO NULL
   LET talincon[ttlrow].* = galincon[x].*
   LET ttlrow = ttlrow + 1
  ELSE
   EXIT FOR
  END IF
 END FOR
 LET ttlrow = ttlrow - 1
 LABEL lincontog2:
 LET toggle = FALSE
 CALL SET_COUNT(ttlrow)
 INPUT ARRAY talincon WITHOUT DEFAULTS FROM dlincon.*
  AFTER FIELD usu_elabora
   LET y = arr_curr()
   let z=scr_line()
   IF talincon[y].usu_elabora IS NULL THEN
    CALL gener02val() RETURNING talincon[y].usu_elabora
    DISPLAY talincon[y].usu_elabora to dlincon[z].usu_elabora
    IF talincon[y].usu_elabora IS NULL THEN
     EXIT INPUT
    END IF
    INITIALIZE mgener02p.* TO NULL
    select * into mgener02p.* from gener02 where usuario=talincon[y].usu_elabora
   ELSE
    INITIALIZE mgener02p.* TO NULL
    select * into mgener02p.* from gener02 where usuario=talincon[y].usu_elabora
    IF mgener02p.usuario is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo del usuario no existe", 
       image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
     INITIALIZE talincon[y].* TO NULL
     INITIALIZE mgener02p.* TO NULL
     next field usu_elabora
    END IF
   END IF
   IF talincon[y].usu_elabora IS NOT NULL THEN
    FOR l=1 TO gmaxarray 
     IF talincon[y].usu_elabora=talincon[l].usu_elabora and l<>y THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo del usuario ya exite para este prefijo",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
      END MENU
      INITIALIZE talincon[y].* TO NULL
      --INITIALIZE mgener02.* TO NULL
      DISPLAY talincon[y].* TO dlincon[z].*
      NEXT FIELD usu_elabora
     END IF
    END FOR
   ELSE
     INITIALIZE talincon[y].* TO NULL
     NEXT FIELD usu_elabora[z]
   END IF
   LET talincon[y].nombre=mgener02p.nombre
   DISPLAY talincon[y].nombre TO dlincon[z].nombre
  AFTER INPUT
   IF int_flag THEN
    EXIT INPUT
   END IF
  END INPUT
  IF toggle THEN
   GOTO lincontog2
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
   INITIALIZE tplincon.* TO NULL
   CALL linconinitta()
   DISPLAY "" AT 1,1
   RETURN
  END IF
 LET gerrflag = FALSE
 MESSAGE "MODIFICANDO LOS USUARIOS POR PREFIJO"
 BEGIN WORK
 LET gerrflag = FALSE
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 IF NOT gerrflag THEN
  DELETE FROM fc_prefijos_usu
   WHERE prefijo = glincon.prefijo
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
   IF talincon[x].usu_elabora IS NOT NULL THEN
    INSERT INTO fc_prefijos_usu ( prefijo, usu_elabora )
      VALUES ( glincon.prefijo, talincon[x].usu_elabora )
     IF status <> 0 THEN
      LET gerrflag = TRUE
      EXIT FOR
     END IF
   END IF  
  END FOR
 END IF
 IF NOT gerrflag THEN
  COMMIT WORK
  LET glincon.* = tplincon.*
  LET cnt = 1
  FOR x = 1 TO gmaxarray
   INITIALIZE galincon[x].* TO NULL
   CALL linconrownull( x ) RETURNING rownull
   IF NOT rownull THEN
    LET galincon[cnt].* = talincon[x].*
    LET cnt = cnt + 1
   END IF
  END FOR
   MENU "Información"  ATTRIBUTE( style= "dialog", 
     comment= " los usuarios por prefijo fueron actualizados  "  ,
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

FUNCTION lincongetcurr( tpprefijo )
 DEFINE tpprefijo LIKE fc_prefijos.prefijo
 INITIALIZE glincon.* TO NULL
 SELECT prefijo, descripcion
  INTO glincon.* FROM fc_prefijos WHERE prefijo = tpprefijo
 CALL lincongetdetail()
END FUNCTION  
FUNCTION linconshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 DISPLAY "" AT glastline,1
 IF glincon.prefijo IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")" 
 END IF
 CALL lincondetail()
END FUNCTION  
FUNCTION linconquery( exist )
 DEFINE answer CHAR(1),
  exist, curr, cnt SMALLINT,
  tpprefijo LIKE fc_prefijos.prefijo,
  where_info, query_text CHAR(400)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO: CONSULTA DE LOS USUARIOS POR PREFIJO "
 CLEAR FORM
 CONSTRUCT where_info
  ON  prefijo, descripcion
  FROM  prefijo, descripcion
 IF int_flag THEN
  MENU "Información"  ATTRIBUTE( style= "dialog", 
      comment= " La consulta fue cancelada",image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  RETURN exist
 END IF
 DISPLAY "Buscando los usuarios, por favor espere ..." AT 2,1
 LET query_text = " SELECT fc_prefijos.prefijo",
                  " FROM fc_prefijos WHERE ", where_info CLIPPED,
                  " ORDER BY fc_prefijos.prefijo ASC"
 PREPARE s_slincon FROM query_text
 DECLARE c_slincon SCROLL CURSOR FOR s_slincon
 LET cnt = 0
 FOREACH c_slincon INTO tpprefijo
  LET cnt = cnt + 1
 END FOREACH
 IF ( cnt > 0 ) THEN
  OPEN c_slincon
  FETCH FIRST c_slincon INTO tpprefijo
  LET curr = 1
  CALL lincongetcurr( tpprefijo )
  CALL linconshowcurr( curr, cnt )
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
   FETCH FIRST c_slincon INTO tpprefijo
   LET curr = 1
   CALL lincongetcurr( tpprefijo )
   CALL linconshowcurr( curr, cnt )
  COMMAND "Ultimo" "Desplaza al ultimo registro en consulta" 
   HELP 4
   FETCH LAST c_slincon INTO tpprefijo
   LET curr = cnt
   CALL lincongetcurr( tpprefijo )
   CALL linconshowcurr( curr, cnt )
  COMMAND "Inmediato" "Se desplaza al siguiente registro en consulta"
   HELP 5
   IF ( curr = cnt ) THEN
    FETCH FIRST c_slincon INTO tpprefijo
    LET curr = 1
   ELSE
    FETCH NEXT c_slincon INTO tpprefijo
    LET curr = curr + 1
   END IF
   CALL lincongetcurr( tpprefijo )
   CALL linconshowcurr( curr, cnt )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_slincon INTO tpprefijo
    LET curr = cnt
   ELSE
    FETCH PREVIOUS c_slincon INTO tpprefijo
    LET curr = curr - 1
   END IF
   CALL lincongetcurr( tpprefijo )
   CALL linconshowcurr( curr, cnt )
  COMMAND "Modifica" "Modifica los conceptos por linea de credito"
   LET mcodmen="FC14"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF glincon.prefijo IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_slincon
     CALL linconupdate()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL lincongetcurr( tpprefijo )
     CALL linconshowcurr( curr, cnt )
     OPEN c_slincon
    END IF
   end if
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF glincon.prefijo IS NULL THEN
    LET exist = FALSE
   ELSE
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_slincon
 LET gerrflag = FALSE
 IF NOT exist THEN
  INITIALIZE glincon.* TO NULL
  CALL linconinitga()
 END IF
 DISPLAY "" AT glastline,1
 RETURN exist
END FUNCTION  
FUNCTION gener02val()
 DEFINE WHERE_info, query_text char(400)
 DEFINE tp   RECORD
   usuario       LIKE gener02.usuario,
   nombre        LIKE gener02.nombre
  END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM gener02
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.usuario = NULL
  RETURN tp.usuario
 END IF
 OPEN WINDOW w_vgener021 AT 8,32 WITH FORM "gen02v"
 DISPLAY "" AT 1,10
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 CONSTRUCT WHERE_info
   ON usuario, nombre
   FROM usuario, nombre
 IF int_flag THEN 
   MENU "Informacion " ATTRIBUTE(style= "dialog", 
  comment= " LA CONSULTA FUE CANCELADA ",  image= "exclamation")
   COMMAND "Aceptar"
     EXIT MENU
   END MENU
  RETURN 
 END IF
 LET query_text = " SELECT usuario, nombre ",
   " FROM gener02 WHERE ", where_info CLIPPED,
    " ORDER BY gener02.usuario ASC" 
 PREPARE s_sgener02 FROM query_text
 DECLARE c_vgener021 SCROLL CURSOR FOR s_sgener02
 OPEN c_vgener021
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL gener02row( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
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
   CALL gener02row( currrow, prevrow, pagenum )
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
   CALL gener02row( currrow, prevrow, pagenum )
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
   CALL gener02row( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vgener021 INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.usuario = NULL
   EXIT MENU
 END MENU
 CLOSE c_vgener021
 CLOSE WINDOW w_vgener021
 RETURN tp.usuario
END FUNCTION  
FUNCTION gener02row( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   usuario    LIKE gener02.usuario,
   nombre   LIKE gener02.nombre
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
  FETCH ABSOLUTE scrfrst c_vgener021 INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cenv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO cenv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vgener021 INTO tp.*
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
  FETCH ABSOLUTE prevrow c_vgener021 INTO tp.*
  DISPLAY tp.* TO cenv[scrprev].*
  FETCH ABSOLUTE currrow c_vgener021 INTO tp.*
  DISPLAY tp.* TO cenv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION

