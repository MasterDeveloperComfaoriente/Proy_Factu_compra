GLOBALS "fe_globales.4gl"
DEFINE gserviprefi, tpserviprefi record
  codservicio        like fe_servicios_caja.codservicio,
  detalle_servicio    like fe_servicios_caja.detalle_servicio
END RECORD  
DEFINE gaserviprefi, taserviprefi ARRAY[50] OF RECORD 
  prefijo    like fe_servicios_prefijos.prefijo,
  descripcion         like fe_prefijos.descripcion
END RECORD   
FUNCTION codserviciosusumain()
 DEFINE exist SMALLINT
 OPEN WINDOW w_mserviprefi AT 1,1 WITH FORM "fe_servicios_prefijos"
 LET gmaxarray = 20
 LET gmaxdply = 10
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gserviprefi.* TO NULL
 INITIALIZE tpserviprefi.* TO NULL
 CALL serviprefiinitga()
 CALL serviprefiinitta()
 MENU ""
  COMMAND "Consulta" "Consulta los usuarios por codservicioi"
   LET mcodmen="FE13"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL serviprefiquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL serviprefidetail()
   end if
  COMMAND "Modifica" "Modifica los prefijos por servicio"
   LET mcodmen="FE14"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
          comment= " No existen servicios", 
          image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
    ELSE
     CALL serviprefiupdate()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
    END IF
    CALL serviprefidetail()
   end if
  
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mserviprefi
END FUNCTION 
FUNCTION serviprefiinitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE gaserviprefi[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION serviprefiinitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE taserviprefi[x].* TO NULL
 END FOR
END FUNCTION  
FUNCTION serviprefidetail()
 DEFINE x SMALLINT
   DISPLAY gserviprefi.codservicio TO codservicio
   DISPLAY gserviprefi.detalle_servicio TO detalle_servicio
 FOR x = 1 TO gmaxdply
  DISPLAY gaserviprefi[x].* TO serviprefi[x].*
 END FOR
END FUNCTION  
FUNCTION serviprefitatoga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET gaserviprefi[x].* = taserviprefi[x].*
 END FOR
END FUNCTION  
FUNCTION serviprefigatota()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET taserviprefi[x].* = gaserviprefi[x].*
 END FOR
END FUNCTION  
FUNCTION serviprefirownull( x )
 DEFINE x, rownull SMALLINT
 LET rownull = TRUE
 IF taserviprefi[x].prefijo IS NOT NULL THEN
  LET rownull = FALSE
 END IF
 RETURN rownull
END FUNCTION  
FUNCTION serviprefigetdetail()
 DEFINE x SMALLINT
 CALL serviprefiinitga()
 DECLARE c_gserviprefi CURSOR FOR
 SELECT fe_servicios_prefijos.prefijo, fe_prefijos.descripcion 
   FROM fe_servicios_prefijos, fe_prefijos WHERE  fe_prefijos.prefijo = fe_servicios_prefijos.prefijo
   AND fe_servicios_prefijos.codservicio = gserviprefi.codservicio
  ORDER BY fe_servicios_prefijos.prefijo ASC
 LET x = 1
 FOREACH c_gserviprefi INTO gaserviprefi[x].*
  LET x = x + 1
  IF x > gmaxarray THEN
   EXIT FOREACH
  END IF
 END FOREACH
END FUNCTION  
FUNCTION serviprefiupdate()
 DEFINE currow, scrrow, cnt, x, rownull, toggle, ttlrow SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
  MESSAGE "ESTADO : MODIFICACION DE LOS PREFIJOS POR SERVCIOS" 
 INITIALIZE tpserviprefi.* TO NULL
 CALL serviprefiinitta()
 LET tpserviprefi.* = gserviprefi.*
 LET ttlrow = 1
 FOR x = 1 TO gmaxarray
  LET taserviprefi[x].* = gaserviprefi[x].*
  CALL serviprefirownull( x ) RETURNING rownull
  IF NOT rownull THEN
   INITIALIZE taserviprefi[x].* TO NULL
   LET taserviprefi[ttlrow].* = gaserviprefi[x].*
   LET ttlrow = ttlrow + 1
  ELSE
   EXIT FOR
  END IF
 END FOR
 LET ttlrow = ttlrow - 1
 LABEL serviprefitog2:
 LET toggle = FALSE
 CALL SET_COUNT(ttlrow)
 INPUT ARRAY taserviprefi WITHOUT DEFAULTS FROM serviprefi.*
  AFTER FIELD prefijo
   LET y = arr_curr()
   let z=scr_line()
   IF taserviprefi[y].prefijo IS NULL THEN
    CALL fe_prefijosval() RETURNING taserviprefi[y].prefijo
    DISPLAY taserviprefi[y].prefijo to serviprefi[z].prefijo
    IF taserviprefi[y].prefijo IS NULL THEN
     EXIT INPUT
    END IF
    INITIALIZE mfe_prefijos.* TO NULL
    select * into mfe_prefijos.* from fe_prefijos where prefijo=taserviprefi[y].prefijo
   ELSE
    INITIALIZE mfe_prefijos.* TO NULL
    select * into mfe_prefijos.* from fe_prefijos where prefijo=taserviprefi[y].prefijo
    IF mfe_prefijos.usuario is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo del prefijo no existe", 
       image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
     INITIALIZE taserviprefi[y].* TO NULL
     INITIALIZE mfe_prefijos.* TO NULL
     next field prefijo
    END IF
   END IF
   IF taserviprefi[y].prefijo IS NOT NULL THEN
    FOR l=1 TO gmaxarray 
     IF taserviprefi[y].prefijo=taserviprefi[l].prefijo and l<>y THEN
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El codigo del prefijo ya exite para este servicio",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
      END MENU
      INITIALIZE taserviprefi[y].* TO NULL
      INITIALIZE mfe_prefijos.* TO NULL
      DISPLAY taserviprefi[y].* TO serviprefi[z].*
      NEXT FIELD prefijo
     END IF
    END FOR
   ELSE
     INITIALIZE taserviprefi[y].* TO NULL
     NEXT FIELD prefijo[z]
   END IF
   LET taserviprefi[y].descripcion=mfe_prefijos.descripcion
   DISPLAY taserviprefi[y].descripcion TO serviprefi[z].descripcion
  AFTER INPUT
   IF int_flag THEN
    EXIT INPUT
   END IF
  END INPUT
  IF toggle THEN
   GOTO serviprefitog2
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
   INITIALIZE tpserviprefi.* TO NULL
   CALL serviprefiinitta()
   DISPLAY "" AT 1,1
   RETURN
  END IF
 LET gerrflag = FALSE
 MESSAGE "MODIFICANDO LOS USUARIOS POR codservicio"
 BEGIN WORK
 LET gerrflag = FALSE
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 IF NOT gerrflag THEN
  DELETE FROM fe_servicios_prefijos
   WHERE codservicio = gserviprefi.codservicio
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
   IF taserviprefi[x].prefijo IS NOT NULL THEN
    INSERT INTO fe_servicios_prefijos ( codservicio, prefijo )
      VALUES ( gserviprefi.codservicio, taserviprefi[x].prefijo )
     IF status <> 0 THEN
      LET gerrflag = TRUE
      EXIT FOR
     END IF
   END IF  
  END FOR
 END IF
 IF NOT gerrflag THEN
  COMMIT WORK
  LET gserviprefi.* = tpserviprefi.*
  LET cnt = 1
  FOR x = 1 TO gmaxarray
   INITIALIZE gaserviprefi[x].* TO NULL
   CALL serviprefirownull( x ) RETURNING rownull
   IF NOT rownull THEN
    LET gaserviprefi[cnt].* = taserviprefi[x].*
    LET cnt = cnt + 1
   END IF
  END FOR
   MENU "Información"  ATTRIBUTE( style= "dialog", 
     comment= " los prefijos por servicio fueron actualizados  "  ,
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

FUNCTION serviprefigetcurr( tpcodservicio )
 DEFINE tpcodservicio LIKE fe_servicios_caja.codservicio
 INITIALIZE gserviprefi.* TO NULL
 SELECT codservicio, detalle_servicio
  INTO gserviprefi.* FROM fe_servicios_caja WHERE codservicio = tpcodservicio
 CALL serviprefigetdetail()
END FUNCTION  
FUNCTION serviprefishowcurr( rownum, maxnum )
 DEFINE rownum, maxnum    INTEGER
 DISPLAY "" AT glastline,1
 IF gserviprefi.codservicio IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")" 
 END IF
 CALL serviprefidetail()
END FUNCTION  
FUNCTION serviprefiquery( exist )
 DEFINE answer CHAR(1),
  exist, curr, cnt SMALLINT,
  tpcodservicio LIKE fe_servicios_caja.codservicio,
  where_info, query_text CHAR(400)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO: CONSULTA DE LOS PREFIJOS POR SERVICIOS"
 CLEAR FORM
 CONSTRUCT where_info
  ON  codservicio, detalle_servicio
  FROM  codservicio, detalle_servicio
 IF int_flag THEN
  MENU "Información"  ATTRIBUTE( style= "dialog", 
      comment= " La consulta fue cancelada",image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  RETURN exist
 END IF
 DISPLAY "Buscando los servicios, por favor espere ..." AT 2,1
 LET query_text = " SELECT fe_servicios_caja.codservicio",
                  " FROM fe_servicios_caja WHERE ", where_info CLIPPED,
                  " ORDER BY fe_servicios_caja.codservicio ASC"
 PREPARE s_sserviprefi FROM query_text
 DECLARE c_sserviprefi SCROLL CURSOR FOR s_sserviprefi
 LET cnt = 0
 FOREACH c_sserviprefi INTO tpcodservicio
  LET cnt = cnt + 1
 END FOREACH
 IF ( cnt > 0 ) THEN
  OPEN c_sserviprefi
  FETCH FIRST c_sserviprefi INTO tpcodservicio
  LET curr = 1
  CALL serviprefigetcurr( tpcodservicio )
  CALL serviprefishowcurr( curr, cnt )
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
   FETCH FIRST c_sserviprefi INTO tpcodservicio
   LET curr = 1
   CALL serviprefigetcurr( tpcodservicio )
   CALL serviprefishowcurr( curr, cnt )
  COMMAND "Ultimo" "Desplaza al ultimo registro en consulta" 
   HELP 4
   FETCH LAST c_sserviprefi INTO tpcodservicio
   LET curr = cnt
   CALL serviprefigetcurr( tpcodservicio )
   CALL serviprefishowcurr( curr, cnt )
  COMMAND "Inmediato" "Se desplaza al siguiente registro en consulta"
   HELP 5
   IF ( curr = cnt ) THEN
    FETCH FIRST c_sserviprefi INTO tpcodservicio
    LET curr = 1
   ELSE
    FETCH NEXT c_sserviprefi INTO tpcodservicio
    LET curr = curr + 1
   END IF
   CALL serviprefigetcurr( tpcodservicio )
   CALL serviprefishowcurr( curr, cnt )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_sserviprefi INTO tpcodservicio
    LET curr = cnt
   ELSE
    FETCH PREVIOUS c_sserviprefi INTO tpcodservicio
    LET curr = curr - 1
   END IF
   CALL serviprefigetcurr( tpcodservicio )
   CALL serviprefishowcurr( curr, cnt )
  COMMAND "Modifica" "Modifica los conceptos por linea de credito"
   LET mcodmen="FE14"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF gserviprefi.codservicio IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sserviprefi
     CALL serviprefiupdate()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL serviprefigetcurr( tpcodservicio )
     CALL serviprefishowcurr( curr, cnt )
     OPEN c_sserviprefi
    END IF
   end if
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF gserviprefi.codservicio IS NULL THEN
    LET exist = FALSE
   ELSE
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sserviprefi
 LET gerrflag = FALSE
 IF NOT exist THEN
  INITIALIZE gserviprefi.* TO NULL
  CALL serviprefiinitga()
 END IF
 DISPLAY "" AT glastline,1
 RETURN exist
END FUNCTION  
