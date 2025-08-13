GLOBALS "fc_globales.4gl"
{
DEFINE mdetexp char(10)
DEFINE mprefijo char(5)
 FUNCTION tarifasmain()
 DEFINE exist  SMALLINT
 DEFINE cb_tpvr, cb_estadoo, cb_tcp, cb_cat  ui.ComboBox
 DEFINE mciudad        char(40)
 OPEN WINDOW w_mtarifas AT 1,1 WITH FORM "fc_tarifas"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gtarifas.* TO NULL
 INITIALIZE tptarifas.* TO NULL
   LET cb_cat = ui.ComboBox.forName("fc_tarifas.codcat")
   CALL cb_cat.clear()
   CALL cb_cat.addItem("A", "CAT A")
   CALL cb_cat.addItem("B", "CAT B")
   CALL cb_cat.addItem("C", "CAT C")
   CALL cb_cat.addItem("D", "CAT D")
   CALL cb_cat.addItem("E", "CAT E")
  MENU
   COMMAND "Adiciona" "Adiciona la informacion de tarifas "
   LET mcodmen="FC19"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL tarifasadd()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
    CALL tarifasdplyg()
  END IF
 COMMAND "Consulta" "Consulta la informacion de un tarifas"
   LET mcodmen="FC20"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL tarifasquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL tarifasdplyg()
   END IF
  COMMAND "Modifica" "Modifica el registro de una tarifa"
   LET mcodmen="FC21"
   CALL opcion() RETURNING op
   if op="S" THEN
  IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " NO HAY INFORMACION DE UNA TARIFA EN CONSULTA ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    ELSE
     CALL tarifasupdate()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
    END IF
    CALL tarifasdplyg()
   END IF
  COMMAND "Borra" "Borra la informacion de un servicio "
   LET mcodmen="FC22"
   CALL opcion() RETURNING op
  if op="S" THEN
   IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
           comment=" NO HAY INFORMACION DE UNA TARIFA EN CONSULTA     ",   
           image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
   ELSE
     CALL tarifasremove()
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CLEAR FORM
      LET exist = FALSE
     END IF
    END IF
    CALL tarifasdplyg()
   END IF
  COMMAND "Reporte" "Reporte de Tarifas"
    CALL rep_tarifas()
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mtarifas
END FUNCTION

FUNCTION tarifasremove()
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : RETIRO DE INFORMACION DE tarifas " ATTRIBUTE(BLUE)
 PROMPT "Esta seguro de borrar el registro (s/n)? " FOR CHAR answer
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO EL REGISTRO " ATTRIBUTE(BLUE)
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  DELETE FROM fc_tarifas
    WHERE fc_tarifas.codigo = gtarifas.codigo
      AND fc_tarifas.prefijo = gtarifas.prefijo
      AND fc_tarifas.codcat = gtarifas.codcat
      AND fc_tarifas.vigencia = gtarifas.vigencia 
     IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
   IF NOT gerrflag THEN 
   INITIALIZE gtarifas.* TO NULL
   MENU "Información"  ATTRIBUTE( style= "dialog", 
        comment= " El Registro  fue retirado", image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   COMMIT WORK
  ELSE
   MENU "Información"  ATTRIBUTE( style= "dialog", 
     comment= " El retiro del registro fue cancelado",  image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   ROLLBACK WORK
  END IF
 ELSE
  MENU "Información"  ATTRIBUTE( style= "dialog", 
    comment= " El retiro del registro fue cancelado",image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  LET int_flag = TRUE
 END IF
END FUNCTION 

FUNCTION tarifasdplyg()
  DISPLAY BY NAME gtarifas.codigo THRU gtarifas.valorsub
  INITIALIZE mfc_prefijos.* TO NULL
  SELECT * into mfc_prefijos.* FROM fc_prefijos
   WHERE prefijo = gtarifas.prefijo
  DISPLAY mfc_prefijos.descripcion TO detprefijo
  INITIALIZE mfc_servicios.* TO NULL
  SELECT * INTO mfc_servicios.* FROM fc_servicios
   WHERE fc_servicios.codigo = gtarifas.codigo
  DISPLAY mfc_servicios.descripcion TO detcodigo
END FUNCTION

FUNCTION tarifasadd()
 DEFINE mnumcod, x integer
 DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 MESSAGE "ESTADO: ADICION DEL REGISTRO DE UN SERVICIO"  ATTRIBUTE(BLUE)
 INITIALIZE tptarifas.* TO NULL
lABEL Ent_persona:
 INPUT BY NAME tptarifas.codigo THRU tptarifas.valorsub WITHOUT DEFAULTS
  AFTER FIELD codigo
    IF tptarifas.codigo is null then
      CALL fc_serviciosval() RETURNING tptarifas.codigo
      IF tptarifas.codigo is NULL THEN 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " Debe escoger un Servicio ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD codigo
      ELSE
        INITIALIZE mfc_servicios.* TO NULL
        SELECT * INTO mfc_servicios.*
         FROM fc_servicios
         WHERE fc_servicios.codigo = tptarifas.codigo
        DISPLAY mfc_servicios.descripcion TO detcodigo 
      END IF 
    ELSE
        INITIALIZE mfc_servicios.* TO NULL
        SELECT * INTO mfc_servicios.*
         FROM fc_servicios
         WHERE fc_servicios.codigo = tptarifas.codigo
        DISPLAY mfc_servicios.descripcion TO detcodigo
    END IF  
 
  BEFORE FIELD prefijo
   INITIALIZE mfc_prefijos_usu.* TO NULL
   SELECT * INTO mfc_prefijos_usu.* FROM fc_prefijos_usu
    WHERE usu_elabora=musuario
   LET tptarifas.prefijo = mfc_prefijos_usu.prefijo 
   DISPLAY BY NAME tptarifas.prefijo
  
  AFTER FIELD prefijo
    IF tptarifas.prefijo is null then
      CALL fc_prefijosval() RETURNING tptarifas.prefijo
      IF tptarifas.prefijo is NULL THEN 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " Debe escoger un Prefijo ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD prefijo
      ELSE
        INITIALIZE mfc_prefijos.* TO NULL
        SELECT * INTO mfc_prefijos.*
         FROM fc_prefijos
         WHERE fc_prefijos.prefijo = tptarifas.prefijo
        DISPLAY mfc_prefijos.descripcion TO detprefijo 
      END IF 
    ELSE
     INITIALIZE mfc_prefijos.* TO NULL
     SELECT * INTO mfc_prefijos.*
      FROM fc_prefijos
      WHERE fc_prefijos.prefijo = tptarifas.prefijo
      DISPLAY mfc_prefijos.descripcion TO detprefijo     
    END IF  

    LET cnt=0
    SELECT count(*) INTO cnt FROM fc_prefijos_usu
     WHERE prefijo=tptarifas.prefijo AND usu_elabora=musuario
    IF cnt IS NULL THEN LET cnt=0 END IF
    IF cnt=0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El usuario No puede Crear tarifas Para este Prefijo ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD prefijo
    END IF  
 AFTER FIELD codcat
  IF tptarifas.codcat is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " La Categoria no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD codcat
  END IF
  AFTER FIELD vigencia
   IF tptarifas.vigencia IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " La Vigencia de la Tarifa no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD vigencia
   END IF
   LET cnt=0
   SELECT count(*) INTO cnt FROM fc_tarifas
    WHERE codigo=tptarifas.codigo
      AND prefijo=tptarifas.prefijo
      AND codcat=tptarifas.codcat
      AND vigencia=tptarifas.vigencia
   IF cnt IS NULL THEN LET cnt=0 END IF
   IF cnt<>0 THEN
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " La Tarifa Digitada Ya Existe ",
       image= "exclamation")
        COMMAND "Aceptar"
          EXIT MENU
      END MENU
      LET tptarifas.vigencia=NULL
      DISPLAY BY NAME tptarifas.vigencia   
      NEXT FIELD vigencia
   END IF  
  AFTER FIELD valor
   IF tptarifas.valor IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Valor de la tarifa no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD valor
   END IF
 AFTER FIELD valorsub
   IF tptarifas.valorsub IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Valor Subsidiado de la tarifa no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD valorsub
   END IF
AFTER INPUT
   IF int_flag THEN
      EXIT INPUT
   ELSE
     IF tptarifas.codigo is null or tptarifas.prefijo is null 
      or tptarifas.codcat is null or tptarifas.vigencia is NULL
      or tptarifas.valor is NULL or tptarifas.valorsub is null then 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
        comment= "Hay campos obligatorios vacios debe completarlos ", image= "exclamation")
         COMMAND "Aceptar"
          EXIT MENU
      END MENU
        GO TO Ent_persona
      end if 
   END IF
  END INPUT
 IF int_flag THEN
  CLEAR FORM
  MENU "Información"  ATTRIBUTE(style= "dialog", 
     comment= " La adicion fue cancelada "  , image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    INITIALIZE tptarifas.* TO NULL
  RETURN
 END IF
 MESSAGE "ADICIONANDO INFORMACION DE LA TARIFA"  ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT
  IF tptarifas.codigo is NOT null or tptarifas.prefijo is NOT null 
      or tptarifas.codcat is NOT null or tptarifas.vigencia is NOT NULL
      or tptarifas.valor is NOT NULL or tptarifas.valorsub is NOT null THEN   
  INSERT INTO fc_tarifas
   (codigo, prefijo, codcat, vigencia, valor, valorsub, fecsis, usuario ) 
   VALUES (tptarifas.codigo, tptarifas.prefijo, tptarifas.codcat, tptarifas.vigencia, 
     tptarifas.valor, tptarifas.valorsub, today, musuario )
   if sqlca.sqlcode <> 0 then    
     MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
      comment= " NO SE ADICIONO.. REGISTRO REFERENCIADO " , image= "stop")
        COMMAND "Aceptar"
          EXIT MENU
     END MENU
     LET gerrflag = TRUE
   END IF  
 else
  LET gerrflag = TRUE
 end if
 IF NOT gerrflag THEN
  COMMIT WORK
  LET gtarifas.* = tptarifas.*
  INITIALIZE tptarifas.* TO NULL
 MENU "Información"  ATTRIBUTE( style= "dialog", 
   comment= " La informacion de la tarifa fue adicionada...  "  ,
            image= "information")
       COMMAND "Aceptar"
       CLEAR FORM
         EXIT MENU
     END MENU
 ELSE
  ROLLBACK WORK
  MENU "Información"  ATTRIBUTE( style= "dialog", 
                            comment= " La adición fue cancelada      "  ,
                            image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
 END IF
 MESSAGE "" 
END FUNCTION  

FUNCTION tarifasupdate()
 DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION DE LA INFORMACION DE UNA EMPRESA"  ATTRIBUTE(BLUE)
 LET tptarifas.* = gtarifas.*
Label  Ent_persona2:
 INPUT BY NAME tptarifas.vigencia THRU tptarifas.valorsub WITHOUT DEFAULTS

 AFTER FIELD vigencia
   IF tptarifas.vigencia IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " La Vigencia de la Tarifa no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD vigencia
   END IF
   IF tptarifas.vigencia<>gtarifas.vigencia THEN
    LET cnt=0
    SELECT count(*) INTO cnt FROM fc_tarifas
    WHERE codigo=tptarifas.codigo
      AND prefijo=tptarifas.prefijo
      AND codcat=tptarifas.codcat
      AND vigencia=tptarifas.vigencia
    IF cnt IS NULL THEN LET cnt=0 END IF
    IF cnt<>0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " La Tarifa Digitada Ya Existe ",
       image= "exclamation")
        COMMAND "Aceptar"
          EXIT MENU
      END MENU
      LET tptarifas.vigencia=NULL
      DISPLAY BY NAME tptarifas.vigencia   
      NEXT FIELD vigencia
    END IF  
   END if 
 
  AFTER FIELD valor
   IF tptarifas.valor IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Valor de la tarifa no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD valor
   END IF

  AFTER FIELD valorsub
   IF tptarifas.valorsub IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Valor Subsidiado de la tarifa no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD valorsub
   END IF
 
 END INPUT
 MESSAGE "" 
 IF int_flag THEN
  CLEAR FORM
  MENU "Información"  ATTRIBUTE( style= "dialog", 
     comment= " La modificación fue cancelada "  , image= "information")
       COMMAND "Aceptar"
         EXIT MENU
  END MENU
  INITIALIZE tptarifas.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION DEL SERVICIO" AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 UPDATE fc_tarifas
 SET (codigo, prefijo, codcat, vigencia, valor, valorsub) 
    =(tptarifas.codigo, tptarifas.prefijo, tptarifas.codcat, tptarifas.vigencia, tptarifas.valor, tptarifas.valorsub )
 WHERE codigo = gtarifas.codigo
   AND prefijo = gtarifas.prefijo
   AND codcat = gtarifas.codcat
   AND vigencia = gtarifas.vigencia
 
 IF status <> 0 THEN
  MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
   comment= " No se modificó.. Registro referenciado  "  , image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  LET gerrflag = TRUE
 END IF
  IF NOT gerrflag THEN 
 MENU "Información"  ATTRIBUTE( style= "dialog", 
        comment= " La modificación fue realizada", image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   COMMIT WORK
 ELSE
  MENU "Información"  ATTRIBUTE( style= "dialog", 
   comment= " La modificación fue cancelada   "  , image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   ROLLBACK WORK
 END IF
 IF NOT gerrflag THEN 
  LET gtarifas.* = tptarifas.*
 END IF
END FUNCTION  

FUNCTION tarifasgetcurr( tpcodigo, tpprefijo, tpcodcat, tpvigencia )
  DEFINE letras string
  DEFINE tpcodigo LIKE fc_tarifas.codigo
  DEFINE tpprefijo LIKE fc_tarifas.prefijo
  DEFINE tpcodcat LIKE fc_tarifas.codcat
  DEFINE tpvigencia LIKE fc_tarifas.vigencia
  INITIALIZE gtarifas.* TO NULL
  SELECT *  INTO gtarifas.*  FROM fc_tarifas
   WHERE fc_tarifas.codigo = tpcodigo
   AND fc_tarifas.prefijo = tpprefijo
   AND fc_tarifas.codcat = tpcodcat
   AND fc_tarifas.vigencia = tpvigencia
END FUNCTION

FUNCTION tarifasshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum INTEGER
  IF gtarifas.codigo IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")"
 END IF
 CALL tarifasdplyg()
END FUNCTION

FUNCTION tarifasquery( exist )
 DEFINE WHERE_info, query_text  CHAR(400),
  answer      CHAR(1),
  exist,
  curr, maxnum integer,
  tpcodigo      LIKE fc_tarifas.codigo,
  tpprefijo LIKE fc_tarifas.prefijo,
  tpcodcat LIKE fc_tarifas.codcat,
  tpvigencia LIKE fc_tarifas.vigencia,
  letras string
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : CONSULTA DE LAS TARIFAS "  ATTRIBUTE(BLUE)
 CLEAR FORM
 CONSTRUCT WHERE_info
   ON codigo, prefijo, codcat, vigencia, valor, valorsub
   FROM codigo, prefijo, codcat, vigencia, valor, valorsub 
      
 IF int_flag THEN 
   MENU "Informacion " ATTRIBUTE(style= "dialog", 
  comment= " LA CONSULTA FUE CANCELADA ",  image= "exclamation")
   COMMAND "Aceptar"
     EXIT MENU
   END MENU
  RETURN exist
 END IF
 MESSAGE "Buscando el registro, por favor espere ..." ATTRIBUTE(BLINK)
 LET query_text = " SELECT fc_tarifas.codigo,fc_tarifas.prefijo,fc_tarifas.codcat,fc_tarifas.vigencia",
  " FROM fc_tarifas WHERE ",where_info CLIPPED, 
   --" FROM fc_tarifas WHERE usuario = \"",musuario,"\"",
   --" AND ", where_info CLIPPED,
    " ORDER BY fc_tarifas.codigo ASC" 
 PREPARE s_starifas FROM query_text
 DECLARE c_starifas SCROLL CURSOR FOR s_starifas
 LET maxnum = 0
 FOREACH c_starifas INTO tpcodigo,tpprefijo,tpcodcat,tpvigencia
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_starifas
  FETCH FIRST c_starifas INTO tpcodigo,tpprefijo,tpcodcat,tpvigencia
  LET curr = 1
  CALL tarifasgetcurr( tpcodigo,tpprefijo,tpcodcat,tpvigencia)
  CALL tarifasshowcurr( curr, maxnum )
 ELSE
  MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
   comment= " El registro del Prefijo no EXISTE", image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
  END MENU
  LET int_flag = TRUE
  RETURN exist
 END IF
 MESSAGE "" 
 LET gerrflag = FALSE 
 MENU 
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla"
   IF ( curr = maxnum ) THEN
    FETCH FIRST c_starifas INTO tpcodigo,tpprefijo,tpcodcat,tpvigencia
    LET curr = 1
   ELSE
    FETCH NEXT c_starifas INTO tpcodigo,tpprefijo,tpcodcat,tpvigencia
    LET curr = curr + 1
   END IF
   CALL tarifasgetcurr( tpcodigo,tpprefijo,tpcodcat,tpvigencia )
   CALL tarifasshowcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_starifas INTO tpcodigo,tpprefijo,tpcodcat,tpvigencia
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_starifas INTO tpcodigo,tpprefijo,tpcodcat,tpvigencia
    LET curr = curr - 1
   END IF
   CALL tarifasgetcurr( tpcodigo,tpprefijo,tpcodcat,tpvigencia )
   CALL tarifasshowcurr( curr, maxnum )
  COMMAND "Modifica" "Modifica el registro  en consulta"
   LET mcodmen="FC21"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF gtarifas.codigo IS NULL THEN
      CONTINUE MENU
    ELSE
      CLOSE c_starifas
      CALL tarifasupdate()
      IF gerrflag THEN
       EXIT MENU
      END IF
      IF int_flag THEN
       LET int_flag = FALSE
      END IF
      CALL tarifasgetcurr( tpcodigo,tpprefijo,tpcodcat,tpvigencia)
      CALL tarifasshowcurr( curr, maxnum )
      OPEN c_starifas
    END IF
  END IF
  COMMAND "Borra" "Borra el registro en consulta"
   LET mcodmen="FC22"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF gtarifas.codigo IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_starifas
     CALL tarifasremove()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CALL tarifasshowcurr( curr, maxnum )
     END IF
     OPEN c_starifas
    END IF
   END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF gtarifas.codigo IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_starifas
 RETURN exist
END FUNCTION
}
FUNCTION fc_serviciosval()
 DEFINE tp   RECORD
   codigo         LIKE fc_servicios.codigo,
   descripcion    LIKE fc_servicios.descripcion
 END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(fc_servicios.codigo) INTO maxnum FROM fc_servicios,fc_prefijos_usu, fc_conta3
   WHERE fc_servicios.codigo = fc_conta3.codigo
   AND fc_prefijos_usu.prefijo = fc_conta3.prefijo
   AND fc_prefijos_usu.usu_elabora=musuario
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.codigo = NULL
  RETURN tp.codigo
 END IF
 OPEN WINDOW w_vfc_prefijos1 AT 8,32 WITH FORM "fc_serviciosv"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 DECLARE c_vfc_prefijos1 SCROLL CURSOR FOR
  SELECT fc_servicios.codigo, fc_servicios.descripcion 
  FROM fc_servicios,fc_prefijos_usu, fc_conta3
   WHERE fc_servicios.codigo = fc_conta3.codigo
   AND fc_prefijos_usu.prefijo = fc_conta3.prefijo
   AND fc_prefijos_usu.usu_elabora=musuario
   ORDER BY fc_servicios.descripcion
 OPEN c_vfc_prefijos1
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fc_tarifasrown( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
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
   CALL fc_tarifasrown( currrow, prevrow, pagenum )
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
   CALL fc_tarifasrown( currrow, prevrow, pagenum )
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
   CALL fc_tarifasrown( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vfc_prefijos1 INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.codigo = NULL
   EXIT MENU
 END MENU
 CLOSE c_vfc_prefijos1
 CLOSE WINDOW w_vfc_prefijos1
 RETURN tp.codigo
END FUNCTION  

FUNCTION fc_tarifasrown( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   codigo          LIKE fc_servicios.codigo,
   descripcion     LIKE fc_servicios.descripcion
  END RECORD,
  scrmax,scrcurr,scrprev,currrow,prevrow,pagenum,newpagenum,x,y,scrfrst INTEGER
 LET scrmax = 8
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
    FETCH ABSOLUTE scrfrst c_vfc_prefijos1 INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cenv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO cenv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vfc_prefijos1 INTO tp.*
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
  FETCH ABSOLUTE prevrow c_vfc_prefijos1 INTO tp.*
  DISPLAY tp.* TO cenv[scrprev].*
  FETCH ABSOLUTE currrow c_vfc_prefijos1 INTO tp.*
  DISPLAY tp.* TO cenv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION

FUNCTION fc_sub_serviciosval()
 DEFINE tp   RECORD
   codigo         LIKE fc_sub_servicios.codigo,
   descripcion     LIKE fc_sub_servicios.descripcion
 END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fc_sub_servicios
   WHERE fc_sub_servicios.codser=mcodser
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.codigo = NULL
  RETURN tp.codigo
 END IF
 OPEN WINDOW xw_vfc_prefijos1 AT 8,32 WITH FORM "fc_sub_serviciosv"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 DECLARE xc_vfc_prefijos1 SCROLL CURSOR FOR
  SELECT fc_sub_servicios.codigo, fc_sub_servicios.descripcion FROM fc_sub_servicios
   WHERE fc_sub_servicios.codser=mcodser
   ORDER BY fc_sub_servicios.descripcion
 OPEN xc_vfc_prefijos1
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fc_tarifasroww( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
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
   CALL fc_tarifasroww( currrow, prevrow, pagenum )
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
   CALL fc_tarifasroww( currrow, prevrow, pagenum )
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
   CALL fc_tarifasroww( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow xc_vfc_prefijos1 INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.codigo = NULL
   EXIT MENU
 END MENU
 CLOSE xc_vfc_prefijos1
 CLOSE WINDOW xw_vfc_prefijos1
 RETURN tp.codigo
END FUNCTION 

FUNCTION fc_tarifasroww( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   codigo         LIKE fc_sub_servicios.codigo,
   descripcion     LIKE fc_sub_servicios.descripcion
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
  FETCH ABSOLUTE scrfrst xc_vfc_prefijos1 INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cenv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO cenv[x].*
   END IF
   IF x < scrmax THEN
    FETCH xc_vfc_prefijos1 INTO tp.*
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
  FETCH ABSOLUTE prevrow xc_vfc_prefijos1 INTO tp.*
  DISPLAY tp.* TO cenv[scrprev].*
  FETCH ABSOLUTE currrow xc_vfc_prefijos1 INTO tp.*
  DISPLAY tp.* TO cenv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION

FUNCTION fc_serviciosval2(mprefijo)
 DEFINE tp   RECORD
 
   codigo         LIKE fc_servicios.codigo,
   descripcion    LIKE fc_servicios.descripcion
 END RECORD,
 mprefijo LIKE fc_prefijos.prefijo,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(fc_servicios.codigo) INTO maxnum FROM fc_servicios
   WHERE fc_servicios.prefijo=mprefijo
    
  IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.codigo = NULL
  RETURN tp.codigo
 END IF
 OPEN WINDOW w_vfc_prefijos1x AT 8,32 WITH FORM "fc_serviciosv"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 DECLARE c_vfc_prefijos1e SCROLL CURSOR FOR
  SELECT fc_servicios.codigo, fc_servicios.descripcion FROM fc_servicios
   WHERE fc_servicios.prefijo=mprefijo
   ORDER BY fc_servicios.codigo
 OPEN c_vfc_prefijos1e
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fc_tarifasrow( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
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
   CALL fc_tarifasrow( currrow, prevrow, pagenum )
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
   CALL fc_tarifasrow( currrow, prevrow, pagenum )
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
   CALL fc_tarifasrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vfc_prefijos1e INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.codigo = NULL
   EXIT MENU
 END MENU
 CLOSE c_vfc_prefijos1e
 CLOSE WINDOW w_vfc_prefijos1x
 RETURN tp.codigo
END FUNCTION  

FUNCTION fc_tarifasrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   codigo          LIKE fc_servicios.codigo,
   descripcion     LIKE fc_servicios.descripcion
  END RECORD,
  scrmax,scrcurr,scrprev,currrow,prevrow,pagenum,newpagenum,x,y,scrfrst INTEGER
 LET scrmax = 8
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
    FETCH ABSOLUTE scrfrst c_vfc_prefijos1e INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cenv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO cenv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vfc_prefijos1e INTO tp.*
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
  FETCH ABSOLUTE prevrow c_vfc_prefijos1e INTO tp.*
  DISPLAY tp.* TO cenv[scrprev].*
  FETCH ABSOLUTE currrow c_vfc_prefijos1e INTO tp.*
  DISPLAY tp.* TO cenv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION
{
FUNCTION rep_tarifas()
--DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
LET mano=NULL
PROMPT "DIGITE LA VIGENCIA ====== " FOR mano
IF mano IS NULL THEN
 RETURN
END IF
let mprefijo=null
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null then 
  return
 end if 
let nomrep=fgl_getenv("HOME"),"/reportes/tarifas"
let nomrep=nomrep CLIPPED
start report rtarifas to nomrep
--LET handler = configureOutputt("PDF","28cm","22cm",17,"1.5cm")
--START REPORT rprefijos TO XML HANDLER HANDLER
initialize mfc_tarifas.* to null
declare tppre cursor for
select * from fc_tarifas WHERE vigencia=mano
AND prefijo = mprefijo 
order by prefijo,codigo,codcat
foreach tppre into mfc_tarifas.*
 output to report rtarifas()
end foreach
finish report rtarifas
call impsn(nomrep)  
END FUNCTION
REPORT rtarifas()
output
 top margin 4
 bottom  margin 4
 left  margin 0
 right margin 132
 page length 66
format
 page header
 let mtime=time
 print column 1,"Fecha : ",today," + ",mtime,
       column 121,"Pag No. ",pageno using "####"
 skip 1 LINES
 let mp1 = (132-length(mfe_empresa.razsoc clipped))/2
 print column mp1,mfe_empresa.razsoc
 let mp1 = (132-length("LISTADO GENERAL DE TARIFAS VIGENCIA "))/2
 print column mp1,"LISTADO GENERAL DE TARIFAS VIGENCIA ",mano
 skip 1 lines
 print "---------------------------------------------------------------",
       "---------------------------------------------------------------"
 print  column 01,"PREFIJO",
        column 10,"SERVICIO",
        column 20,"DESCRIPCION",
        column 75,"CAT",
        column 80,"VALOR",
        column 100,"VALOR-SUB",
        COLUMN 115, "% IVA",
        COLUMN 122, "% IMPO"
 print "---------------------------------------------------------------",
       "---------------------------------------------------------------"
       
 skip 1 lines
 on every ROW
 initialize mfc_servicios.* to null
 select * into mfc_servicios.* from fc_servicios
 where codigo=mfc_tarifas.codigo
 print  column 02,mfc_tarifas.prefijo,
        column 10,mfc_tarifas.codigo,
        column 17,mfc_servicios.descripcion,
        column 76,mfc_tarifas.codcat,
        column 79,mfc_tarifas.valor using "##,###,##&.&&",
        column 95,mfc_tarifas.valorsub using "##,###,##&.&&",
        column 116,mfc_servicios.iva,
        column 116,mfc_servicios.impc
   on last row       
 --skip to top of page
end REPORT
}
