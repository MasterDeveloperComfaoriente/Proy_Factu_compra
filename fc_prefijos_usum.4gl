GLOBALS "fc_globales.4gl"
DEFINE glincon, tplincon record
  prefijo        like fc_prefijos.prefijo,
  descripcion    like fc_prefijos.descripcion
END RECORD 
 
DEFINE galincon, talincon ARRAY[20] OF RECORD 
  usu_autoriza    like fc_prefijos_usuu.usu_autoriza,
  nombre         like gener02.nombre
END RECORD 
  
FUNCTION prefijosusuumain()
 DEFINE exist SMALLINT
 OPEN WINDOW w_mlincon AT 1,1 WITH FORM "fc_prefijos_usum"
 LET gmaxarray = 20
 LET gmaxdply = 10
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE glincon.* TO NULL
 INITIALIZE tplincon.* TO NULL
 CALL linconinitgaa()
 CALL linconinittaa()
 MENU ""
  COMMAND "Consulta" "Consulta los usuarios por prefijoi"
   LET mcodmen="FC16"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL linconqueryy( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL lincondetaill()
   end if
  COMMAND "Modifica" "Modifica los usuarios por prefijo"
   LET mcodmen="FC17"
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
     CALL linconupdatee()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
    END IF
    CALL lincondetaill()
   end if
  
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mlincon
END FUNCTION 
FUNCTION linconinitgaa()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE galincon[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION linconinittaa()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE talincon[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION lincondetaill()
 DEFINE x SMALLINT
   DISPLAY glincon.prefijo TO prefijo
   DISPLAY glincon.descripcion TO descripcion
 FOR x = 1 TO gmaxdply
  DISPLAY galincon[x].* TO dlincon[x].*
 END FOR
END FUNCTION  
FUNCTION lincontatogaa()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET galincon[x].* = talincon[x].*
 END FOR
END FUNCTION  
FUNCTION lincongatotaa()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET talincon[x].* = galincon[x].*
 END FOR
END FUNCTION  
FUNCTION linconrownulll( x )
 DEFINE x, rownull SMALLINT
 LET rownull = TRUE
 IF talincon[x].usu_autoriza IS NOT NULL THEN
  LET rownull = FALSE
 END IF
 RETURN rownull
END FUNCTION  
FUNCTION lincongetdetaill()
 DEFINE x SMALLINT
 CALL linconinitgaa()
 DECLARE c_glincon CURSOR FOR
 SELECT fc_prefijos_usuu.usu_autoriza, gener02.nombre, fc_prefijos_usuu.email, fc_prefijos_usuu.emaill
   FROM fc_prefijos_usuu, gener02 WHERE  gener02.usuario = fc_prefijos_usuu.usu_autoriza
   AND fc_prefijos_usuu.prefijo = glincon.prefijo
  ORDER BY fc_prefijos_usuu.usu_autoriza ASC
 LET x = 1
 FOREACH c_glincon INTO galincon[x].*
  LET x = x + 1
  IF x > gmaxarray THEN
   EXIT FOREACH
  END IF
 END FOREACH
END FUNCTION  
FUNCTION linconupdatee()
 DEFINE currow, scrrow, cnt, x, rownull, toggle, ttlrow SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
  MESSAGE "ESTADO : MODIFICACION DE LOS USUARIOS POR PREFIJO" 
 INITIALIZE tplincon.* TO NULL
 CALL linconinittaa()
 LET tplincon.* = glincon.*
 LET ttlrow = 1
 FOR x = 1 TO gmaxarray
  LET talincon[x].* = galincon[x].*
  CALL linconrownulll( x ) RETURNING rownull
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
  AFTER FIELD usu_autoriza
   LET y = arr_curr()
   let z=scr_line()
   IF talincon[y].usu_autoriza IS NULL THEN
    CALL gener02val() RETURNING talincon[y].usu_autoriza
    DISPLAY talincon[y].usu_autoriza to dlincon[z].usu_autoriza
    IF talincon[y].usu_autoriza IS NULL THEN
     EXIT INPUT
    END IF
    INITIALIZE mgener02p.* TO NULL
    select * into mgener02p.* from gener02 where usuario=talincon[y].usu_autoriza
   ELSE
    INITIALIZE mgener02p.* TO NULL
    select * into mgener02p.* from gener02 where usuario=talincon[y].usu_autoriza
    IF mgener02p.usuario is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo del usuario no existe", 
       image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
     INITIALIZE talincon[y].* TO NULL
     INITIALIZE mgener02p.* TO NULL
     next field usu_autoriza
    END IF
   END IF
   IF talincon[y].usu_autoriza IS NOT NULL THEN
    FOR l=1 TO gmaxarray 
     IF talincon[y].usu_autoriza=talincon[l].usu_autoriza and l<>y THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo del usuario ya exite para este prefijo",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
      END MENU
      INITIALIZE talincon[y].* TO NULL
      --INITIALIZE mgener02.* TO NULL
      DISPLAY talincon[y].* TO dlincon[z].*
      NEXT FIELD usu_autoriza
     END IF
    END FOR
   ELSE
     INITIALIZE talincon[y].* TO NULL
     NEXT FIELD usu_autoriza[z]
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
   CALL linconinittaa()
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
  DELETE FROM fc_prefijos_usuu
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
   IF talincon[x].usu_autoriza IS NOT NULL THEN
    INSERT INTO fc_prefijos_usuu ( prefijo, usu_autoriza)
      VALUES ( glincon.prefijo, talincon[x].usu_autoriza)
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
   CALL linconrownulll( x ) RETURNING rownull
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

FUNCTION lincongetcurrr( tpprefijo )
 DEFINE tpprefijo LIKE fc_prefijos.prefijo
 INITIALIZE glincon.* TO NULL
 SELECT prefijo, descripcion
  INTO glincon.* FROM fc_prefijos WHERE prefijo = tpprefijo
 CALL lincongetdetaill()
END FUNCTION  
FUNCTION linconshowcurrr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 DISPLAY "" AT glastline,1
 IF glincon.prefijo IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")" 
 END IF
 CALL lincondetaill()
END FUNCTION  
FUNCTION linconqueryy( exist )
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
  CALL lincongetcurrr( tpprefijo )
  CALL linconshowcurrr( curr, cnt )
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
   CALL lincongetcurrr( tpprefijo )
   CALL linconshowcurrr( curr, cnt )
  COMMAND "Ultimo" "Desplaza al ultimo registro en consulta" 
   HELP 4
   FETCH LAST c_slincon INTO tpprefijo
   LET curr = cnt
   CALL lincongetcurrr( tpprefijo )
   CALL linconshowcurrr( curr, cnt )
  COMMAND "Inmediato" "Se desplaza al siguiente registro en consulta"
   HELP 5
   IF ( curr = cnt ) THEN
    FETCH FIRST c_slincon INTO tpprefijo
    LET curr = 1
   ELSE
    FETCH NEXT c_slincon INTO tpprefijo
    LET curr = curr + 1
   END IF
   CALL lincongetcurrr( tpprefijo )
   CALL linconshowcurrr( curr, cnt )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_slincon INTO tpprefijo
    LET curr = cnt
   ELSE
    FETCH PREVIOUS c_slincon INTO tpprefijo
    LET curr = curr - 1
   END IF
   CALL lincongetcurrr( tpprefijo )
   CALL linconshowcurrr( curr, cnt )
  COMMAND "Modifica" "Modifica los conceptos por linea de credito"
   LET mcodmen="FC17"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF glincon.prefijo IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_slincon
     CALL linconupdatee()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL lincongetcurrr( tpprefijo )
     CALL linconshowcurrr( curr, cnt )
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
  CALL linconinitgaa()
 END IF
 DISPLAY "" AT glastline,1
 RETURN exist
END FUNCTION  
