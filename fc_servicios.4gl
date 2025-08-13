GLOBALS "fc_globales.4gl"

DEFINE rec_pre ARRAY [15] OF RECORD  
    prex LIKE fc_prefijos_usu.prefijo
END RECORD 
DEFINE  rservicios RECORD LIKE fc_servicios.*
DEFINE buscar_unidades RECORD LIKE fe_unidades.*
DEFINE rec_servicios, gaservicios RECORD 
    codigo LIKE fc_servicios.codigo,
    descripcion LIKE fc_servicios.descripcion,
    tpimpuesto LIKE fc_servicios.tpimpuesto,
    coduni LIKE fc_servicios.coduni,
    mdescripcion LIKE fe_unidades.descripcion,
    prefijo LIKE fc_servicios.prefijo,
    estado LIKE fc_servicios.estado
END RECORD 

 FUNCTION serviciosmain()
 DEFINE exist  SMALLINT
 DEFINE  cb_estadoo, cb_tpimp ui.ComboBox 
 OPEN WINDOW w_mservicios AT 1,1 WITH FORM "fc_servicios"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gaservicios.* TO NULL
 INITIALIZE rec_servicios.* TO NULL
  
 INITIALIZE mest_servicios.* TO NULL
  DECLARE cur_sersf CURSOR FOR
   SELECT * FROM est_servicios
   FOREACH cur_sersf INTO mest_servicios.*
     LET mest_servicios.nombresf = mest_servicios.codsersf CLIPPED, "-", mest_servicios.nombresf 
     
   END FOREACH 
   LET cb_tpimp = ui.ComboBox.forName("fc_servicios.tpimpuesto")
   CALL cb_tpimp.clear()
   CALL cb_tpimp.addItem("1", "GRAVADO")
   CALL cb_tpimp.addItem("2", "EXCLUIDO")
   CALL cb_tpimp.addItem("3", "EXENTO") 
   LET cb_estadoo = ui.ComboBox.forName("fc_servicios.estado")
   CALL cb_estadoo.clear()
   CALL cb_estadoo.addItem("A", "ACTIVO")
   CALL cb_estadoo.addItem("I", "INACTIVO")
  MENU
   COMMAND "Adiciona" "Adiciona la informacion de servicios "
   LET mcodmen="FC08"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL serviciosadd()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
    CALL serviciosdplyg()
  END IF
 COMMAND "Consulta" "Consulta la informacion de un servicios"
   LET mcodmen="FC09"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL serviciosquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL serviciosdplyg()
   END IF
  COMMAND "Modifica" "Modifica el registro de un Servicio"
   LET mcodmen="FC10"
   CALL opcion()  RETURNING op
   if op="S" OR musuario = "532" THEN
  IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " NO HAY INFORMACION DE UN SERVICIO EN CONSULTA ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    ELSE
     CALL serviciosupdate()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
    END IF
    CALL serviciosdplyg()
   END IF
  COMMAND "Borra" "Borra la informacion de un servicio "
   LET mcodmen="FC11"
   CALL opcion() RETURNING op
  if op="S" THEN
   IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
           comment=" NO HAY INFORMACION DE UN SERVICIO EN CONSULTA     ",   
           image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
   ELSE
     CALL serviciosremove()
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CLEAR FORM
      LET exist = FALSE
     END IF
    END IF
    CALL serviciosdplyg()
   END IF
  COMMAND "Reporte" "Reporte de Servicios"
    CALL rep_servicios()
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mservicios
END FUNCTION

FUNCTION serviciosremove()
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : RETIRO DE INFORMACION DE servicios " ATTRIBUTE(BLUE)
 PROMPT "Esta seguro de borrar el registro (s/n)? " FOR CHAR answer

 IF answer MATCHES "[Ss]" THEN
  LET cnt=0
  SELECT count(*) INTO cnt FROM fc_factura_d
   WHERE codigo=gaservicios.codigo
  IF cnt IS null THEN LET cnt=0 END IF
  IF cnt<>0 THEN
   let answer="N"
  END if 
 END if
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO EL REGISTRO " ATTRIBUTE(BLUE)
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  
  DELETE FROM fc_servicios
    WHERE fc_servicios.codigo = gaservicios.descripcion
    
     IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
   IF NOT gerrflag THEN 
   INITIALIZE gaservicios.* TO NULL
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

FUNCTION serviciosdplyg()
  
 
  INITIALIZE rservicios.* TO NULL 
  SELECT * INTO rservicios.* FROM fc_servicios
  WHERE fc_servicios.codigo = gaservicios.descripcion

  DISPLAY rservicios.codigo TO codigo
  DISPLAY rservicios.coduni TO coduni
  DISPLAY rservicios.descripcion TO descripcion
  DISPLAY rservicios.tpimpuesto TO tpimpuesto
  DISPLAY rservicios.estado TO estado
  DISPLAY rservicios.prefijo TO prefijo
    
  INITIALIZE mfe_unidades.* TO NULL
  SELECT * INTO mfe_unidades.* FROM fe_unidades
  WHERE fe_unidades.coduni = rservicios.coduni
    DISPLAY mfe_unidades.descripcion TO mdescripcion
    
END FUNCTION

FUNCTION serviciosadd()
 DEFINE mnumcod, x integer
 DEFINE cnt SMALLINT
 DEFINE cb ui.ComboBox
 DEFINE desc_uni varchar(60,1)   
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 MESSAGE "ESTADO: ADICION DEL REGISTRO DE UN SERVICIO"  ATTRIBUTE(BLUE)
 INITIALIZE rec_servicios.* TO NULL
lABEL Ent_persona:
 INPUT BY NAME rec_servicios.codigo THRU rec_servicios.prefijo WITHOUT DEFAULTS
  BEFORE FIELD codigo

   select max(codigo) into mnumcod from fc_servicios
   if mnumcod is null then let mnumcod=1 end if
   LET cnt = 1
   LET x = mnumcod
   LET rec_servicios.codigo = x USING "&&&&&"
   WHILE cnt <> 0
    SELECT COUNT(*) INTO cnt FROM fc_servicios
     WHERE codigo = rec_servicios.codigo
    IF cnt <> 0 THEN
     LET x = x + 1
     LET rec_servicios.codigo = x USING "&&&&&"
     DISPLAY BY NAME rec_servicios.codigo
    ELSE
     EXIT WHILE
    END IF
   END WHILE
   DISPLAY BY NAME rec_servicios.codigo
   NEXT FIELD descripcion
 
  AFTER FIELD codigo
   IF rec_servicios.codigo IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Codigo del Servicio no fue digitado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD codigo
   END IF
   INITIALIZE mfc_servicios.* TO NULL
   SELECT * into mfc_servicios.* FROM fc_servicios
   WHERE fc_servicios.codigo = rec_servicios.codigo
   IF mfc_servicios.codigo is not null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Codigo digitado ya existe ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
     NEXT field codigo
   END IF

  AFTER FIELD descripcion
   IF rec_servicios.descripcion IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " La Descripcion del Servicio no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD descripcion
   END IF

   AFTER FIELD tpimpuesto
   IF rec_servicios.tpimpuesto IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " El tipo de impuesto no fue seleccionado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD tpimpuesto
   END IF
   
 AFTER FIELD coduni
   IF rec_servicios.coduni IS NULL THEN
      CALL unidval() RETURNING rec_servicios.coduni 
      IF rec_servicios.coduni IS NULL THEN
         MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "La Unidad No fue Digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
          END MENU
       NEXT FIELD coduni
       END IF
    ELSE
        INITIALIZE mfe_unidades.* TO NULL
        SELECT * INTO mfe_unidades.* FROM fe_unidades
        WHERE fe_unidades.coduni = rec_servicios.coduni
        LET rec_servicios.mdescripcion = mfe_unidades.descripcion
        DISPLAY BY NAME rec_servicios.mdescripcion 

   END IF

  
   BEFORE FIELD prefijo
   LET cb = ui.ComboBox.forName("fc_servicios.prefijo")
   LET x=1
   CALL cb.CLEAR()
   DECLARE cursor_pre CURSOR FOR SELECT prefijo FROM fc_prefijos_usu WHERE usu_elabora = musuario
   FOREACH cursor_pre INTO rec_pre[x].prex
            CALL cb.addItem(rec_pre[x].prex,rec_pre[x].prex)
            LET x = x+1
   END FOREACH 


    AFTER FIELD prefijo
  IF rec_servicios.prefijo is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El prefijo asociado no fue seleccionado ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD prefijo
  END IF
  
 
 
   
  AFTER INPUT
  
   IF int_flag THEN
      EXIT INPUT
   ELSE
     IF rec_servicios.codigo is null or rec_servicios.descripcion is NULL
      or rec_servicios.tpimpuesto is NULL or rec_servicios.coduni is NULL
      OR rec_servicios.prefijo IS NULL then 
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
    INITIALIZE rec_servicios.* TO NULL
  RETURN
 END IF
 MESSAGE "ADICIONANDO INFORMACION DEL SERVICIO"  ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT
 select max(codigo) into mnumcod from fc_servicios
   if mnumcod is null then let mnumcod=1 end if
   LET cnt = 1
   LET x = mnumcod
   LET rec_servicios.codigo = x USING "&&&&&"
   WHILE cnt <> 0
    SELECT COUNT(*) INTO cnt FROM fc_servicios
     WHERE codigo = rec_servicios.codigo
    IF cnt <> 0 THEN
     LET x = x + 1
     LET rec_servicios.codigo = x USING "&&&&&"
     DISPLAY BY NAME rec_servicios.codigo
    ELSE
     EXIT WHILE
    END IF
   END WHILE 
 IF rec_servicios.codigo is NOT null 
      or rec_servicios.descripcion is NOT NULL
      or rec_servicios.tpimpuesto IS not NULL 
      or rec_servicios.coduni IS not NULL  
      or rec_servicios.estado is NOT null THEN   
  INSERT INTO fc_servicios
   (codigo, descripcion, tpimpuesto,coduni,estado, fecsis,  usuario, prefijo ) 
   VALUES (rec_servicios.codigo, rec_servicios.descripcion,
            rec_servicios.tpimpuesto,rec_servicios.coduni, 
     "A", today, musuario, rec_servicios.prefijo )
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
  LET gaservicios.* = rec_servicios.*
  INITIALIZE rec_servicios.* TO NULL
 MENU "Información"  ATTRIBUTE( style= "dialog", 
   comment= " La informacion del servicio fue adicionada...  "  ,
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

FUNCTION serviciosupdate()
 DEFINE cnt SMALLINT
 DEFINE cod CHAR(5)
{ DEFINE gaservicios_a RECORD LIKE fc_servicios.*
 DISPLAY }
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION DE LA INFORMACION DE UN SERVICIO"  ATTRIBUTE(BLUE)
 LET gaservicios.codigo=gaservicios.descripcion
 SELECT descripcion INTO gaservicios.descripcion FROM fc_servicios
 WHERE codigo = gaservicios.codigo
 SELECT tpimpuesto INTO gaservicios.tpimpuesto FROM fc_servicios
 WHERE codigo = gaservicios.codigo
 SELECT coduni INTO gaservicios.coduni FROM fc_servicios
 WHERE codigo = gaservicios.codigo
 SELECT prefijo INTO gaservicios.prefijo FROM fc_servicios
 WHERE codigo = gaservicios.codigo
 SELECT estado INTO gaservicios.estado FROM fc_servicios
 WHERE codigo = gaservicios.codigo
 
 
 LET rec_servicios.* = gaservicios.*
 
  
Label  Ent_persona2:
 INPUT BY NAME rec_servicios.codigo THRU rec_servicios.estado WITHOUT DEFAULTS

 AFTER FIELD codigo
   IF rec_servicios.codigo IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Codigo del Servicio no fue digitado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD codigo
   END IF
   IF rec_servicios.codigo<>gaservicios.codigo THEN
    INITIALIZE mfc_servicios.* TO NULL
    SELECT * into mfc_servicios.* FROM fc_servicios
    WHERE fc_servicios.codigo = rec_servicios.codigo
    IF mfc_servicios.codigo is not null THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El Codigo digitado ya existe ", image= "exclamation")
        COMMAND "Aceptar"
         EXIT MENU
      END MENU
      NEXT field codigo
    END IF
   END IF 
   
 
  AFTER FIELD descripcion
   IF rec_servicios.descripcion IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " La Descripcion del Servicio no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD descripcion
   END IF
   
  AFTER FIELD tpimpuesto
   IF rec_servicios.tpimpuesto IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " El tipo de impuesto no fue seleccionado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD tpimpuesto
   END IF
   
   AFTER FIELD coduni
   IF rec_servicios.coduni IS NULL THEN
      CALL unidval() RETURNING rec_servicios.coduni 
    IF rec_servicios.coduni IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "La Unidad No fue Digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD coduni
       ELSE
      INITIALIZE  buscar_unidades.* TO NULL 
     SELECT * into buscar_unidades.* FROM fe_unidades
     WHERE coduni = rec_servicios.coduni
     DISPLAY buscar_unidades.descripcion to mdescripcion
    END IF
     ELSE
     INITIALIZE  buscar_unidades.* TO NULL 
     SELECT * into buscar_unidades.* FROM fe_unidades
     WHERE coduni = rec_servicios.coduni
     DISPLAY buscar_unidades.descripcion to mdescripcion
   END IF
   
  AFTER FIELD prefijo
  IF rec_servicios.prefijo is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El prefijo asociado no fue seleccionado  ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD prefijo
  END IF
  
 AFTER FIELD estado
  IF rec_servicios.estado is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Estado del Servicio no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD estado
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
  INITIALIZE rec_servicios.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION DEL SERVICIO" AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT
 DISPLAY "El codigo: ",gaservicios.codigo  
 UPDATE fc_servicios
 SET (codigo, descripcion,tpimpuesto,coduni, prefijo,estado) 
    =(rec_servicios.codigo, rec_servicios.descripcion,
        rec_servicios.tpimpuesto, rec_servicios.coduni,
        rec_servicios.prefijo, rec_servicios.estado )
 WHERE codigo = gaservicios.codigo
 
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
  LET gaservicios.* = rec_servicios.*
 END IF
END FUNCTION    

FUNCTION serviciosgetcurr( tpcodigo )
  DEFINE tpcodigo LIKE fc_servicios.codigo
  INITIALIZE gaservicios.* TO NULL
  SELECT *  INTO gaservicios.*  FROM fc_servicios
   WHERE fc_servicios.codigo = tpcodigo
END FUNCTION

FUNCTION serviciosshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum INTEGER
  IF gaservicios.codigo IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")"
 END IF
 CALL serviciosdplyg()
END FUNCTION

FUNCTION serviciosquery( exist )
 DEFINE WHERE_info, query_text  CHAR(400),
  answer      CHAR(1),
  exist,
  curr, maxnum integer,
  tpcodigo      LIKE fc_servicios.codigo,
  letras string
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : CONSULTA DE LOS DATOS DEL SERVICIO "  ATTRIBUTE(BLUE)
 CLEAR FORM
 CONSTRUCT WHERE_info
   ON codigo, descripcion, tpimpuesto, prefijo, estado
   FROM codigo, descripcion, tpimpuesto, prefijo, estado 
      
 IF int_flag THEN 
   MENU "Informacion " ATTRIBUTE(style= "dialog", 
  comment= " LA CONSULTA FUE CANCELADA ",  image= "exclamation")
   COMMAND "Aceptar"
     EXIT MENU
   END MENU
  RETURN exist
 END IF
 MESSAGE "Buscando el registro, por favor espere ..." ATTRIBUTE(BLINK)
 LET query_text = " SELECT fc_servicios.codigo",
   " FROM fc_servicios WHERE ",where_info CLIPPED,
   --" FROM fc_servicios WHERE usuario = \"",musuario,"\"",
   --" AND ", where_info CLIPPED,
    " ORDER BY fc_servicios.codigo ASC" 
 PREPARE s_sservicios FROM query_text
 DECLARE c_sservicios SCROLL CURSOR FOR s_sservicios
 LET maxnum = 0
 FOREACH c_sservicios INTO tpcodigo
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_sservicios
  FETCH FIRST c_sservicios INTO tpcodigo
  LET curr = 1
  CALL serviciosgetcurr( tpcodigo)
  CALL serviciosshowcurr( curr, maxnum )
 ELSE
  MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
   comment= " El registro del Servicio no EXISTE", image= "exclamation")
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
    FETCH FIRST c_sservicios INTO tpcodigo
    LET curr = 1
   ELSE
    FETCH NEXT c_sservicios INTO tpcodigo
    LET curr = curr + 1
   END IF
   CALL serviciosgetcurr( tpcodigo )
   CALL serviciosshowcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_sservicios INTO tpcodigo
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_sservicios INTO tpcodigo
    LET curr = curr - 1
   END IF
   CALL serviciosgetcurr( tpcodigo )
   CALL serviciosshowcurr( curr, maxnum )
  COMMAND "Modifica" "Modifica el registro  en consulta"
   LET mcodmen="FC10"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF gaservicios.codigo IS NULL THEN
      CONTINUE MENU
    ELSE
      CLOSE c_sservicios
      CALL serviciosupdate()
      IF gerrflag THEN
       EXIT MENU
      END IF
      IF int_flag THEN
       LET int_flag = FALSE
      END IF
      CALL serviciosgetcurr( tpcodigo)
      CALL serviciosshowcurr( curr, maxnum )
      OPEN c_sservicios
    END IF
  END IF
  COMMAND "Borra" "Borra el registro en consulta"
   LET mcodmen="FC11"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF gaservicios.codigo IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sservicios
     CALL serviciosremove()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CALL serviciosshowcurr( curr, maxnum )
     END IF
     OPEN c_sservicios
    END IF
   END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF gaservicios.codigo IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sservicios
 RETURN exist
END FUNCTION

FUNCTION fc_prefijosval()
 DEFINE tp   RECORD
   prefijo         LIKE fc_prefijos.prefijo,
   descripcion     LIKE fc_prefijos.descripcion
 END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(fc_prefijos.prefijo) INTO maxnum FROM fc_prefijos,fc_prefijos_usu
   WHERE fc_prefijos.prefijo=fc_prefijos_usu.prefijo
     AND fc_prefijos_usu.usu_elabora=musuario
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.prefijo = NULL
  RETURN tp.prefijo
 END IF
 OPEN WINDOW w_vfc_prefijos1 AT 8,32 WITH FORM "fc_prefijosv"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 DECLARE c_vfc_prefijos1 SCROLL CURSOR FOR
  SELECT fc_prefijos.prefijo, fc_prefijos.descripcion FROM fc_prefijos,fc_prefijos_usu
   WHERE fc_prefijos.prefijo=fc_prefijos_usu.prefijo
     AND fc_prefijos_usu.usu_elabora=musuario
   ORDER BY fc_prefijos.prefijo
 OPEN c_vfc_prefijos1
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fc_prefijosrow( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
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
   CALL fc_prefijosrow( currrow, prevrow, pagenum )
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
   CALL fc_prefijosrow( currrow, prevrow, pagenum )
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
   CALL fc_prefijosrow( currrow, prevrow, pagenum )
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
   LET tp.prefijo = NULL
   EXIT MENU
 END MENU
 CLOSE c_vfc_prefijos1
 CLOSE WINDOW w_vfc_prefijos1
 RETURN tp.prefijo
END FUNCTION  
FUNCTION fc_prefijosrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   prefijo         LIKE fc_prefijos.prefijo,
   descripcion     LIKE fc_prefijos.descripcion
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


FUNCTION rep_servicios()
--DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
let nomrep=fgl_getenv("HOME"),"/reportes/servicios"
let nomrep=nomrep CLIPPED
start report rservicios to nomrep
--LET handler = configureOutputt("PDF","28cm","22cm",17,"1.5cm")
--START REPORT rprefijos TO XML HANDLER HANDLER
initialize mfc_servicios.* to null
declare stppre cursor for
select * from fc_servicios 
 order by codigo
foreach stppre into mfc_servicios.*
 output to report rservicios()
end foreach
finish report rservicios
call impsn(nomrep)  --reemplazar de fc_factura
END FUNCTION
REPORT rservicios()
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

 let mp1 = (132-length(mfc_empresa.razsoc clipped))/2
 print column mp1,mfc_empresa.razsoc
 let mp1 = (132-length("LISTADO GENERAL DE SERVICIOS"))/2
 print column mp1,"LISTADO GENERAL DE SERVICIOS"

 skip 1 LINES
 PRINT COLUMN 01, "SERVICIOS PARA EL PREFIJO  : ", mprefijo 
 print "---------------------------------------------------------------",
       "---------------------------------------------------------------"
 print  column 01,"CODIGO",
        column 10,"DESCRIPCION",
        column 65,"VR IVA",
        column 80,"VR IMPC",
        column 95,"CAT",
        column 100,"TAF",
        column 105,"CUO", 
        column 110,"E"
      
 print "---------------------------------------------------------------",
       "---------------------------------------------------------------"
 skip 1 lines
 on every ROW
 print  column 01,mfc_servicios.codigo,
        column 10,mfc_servicios.descripcion,
        
        column 110,mfc_servicios.estado
   on last row       
 --skip to top of page
end report

FUNCTION unidval()
 DEFINE WHERE_info, query_text char(400)
 DEFINE tp   RECORD
   coduni       LIKE fe_unidades.coduni,
   descripcion  LIKE fe_unidades.descripcion
  END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fe_unidades
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.coduni = NULL
  RETURN tp.coduni
 END IF
 OPEN WINDOW w_vunival AT 8,32 WITH FORM "fc_unidv"
 DISPLAY "" AT 1,10
 MESSAGE "Trabajando por favor espere ... " --AT 2,1
CONSTRUCT WHERE_info
   ON coduni, descripcion
   FROM coduni, descripcion
 IF int_flag THEN 
   MENU "Informacion " ATTRIBUTE(style= "dialog", 
  comment= " LA CONSULTA FUE CANCELADA ",  image= "exclamation")
   COMMAND "Aceptar"
     EXIT MENU   
   END MENU
    CLOSE WINDOW w_vunival
  RETURN tp.coduni
  
 END IF
 
 LET query_text = " SELECT coduni, descripcion ",
   " FROM fe_unidades WHERE ", where_info CLIPPED,
    " ORDER BY fe_unidades.coduni ASC" 
 PREPARE s_sunival FROM query_text
  DECLARE c_vunival SCROLL CURSOR FOR s_sunival
 
 SELECT fe_unidades.coduni, fe_unidades.descripcion FROM fe_unidades
 ORDER BY fe_unidades.descripcion ASC 
 OPEN c_vunival
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL univalrow( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
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
   CALL univalrow( currrow, prevrow, pagenum )
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
   CALL univalrow( currrow, prevrow, pagenum )
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
   CALL univalrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vunival INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.coduni = NULL
   EXIT MENU
 END MENU
 CLOSE c_vunival
 CLOSE WINDOW w_vunival
 RETURN tp.coduni
END FUNCTION 

FUNCTION univalrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   coduni    LIKE fe_unidades.coduni,
   descripcion   LIKE fe_unidades.descripcion
  END RECORD,
  scrmax,scrcurr,scrprev,currrow,prevrow,pagenum,newpagenum,x,y,scrfrst INTEGER
 LET scrmax = 20
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
  FETCH ABSOLUTE scrfrst c_vunival INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cenv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO cenv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vunival INTO tp.*
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
  FETCH ABSOLUTE prevrow c_vunival INTO tp.*
  DISPLAY tp.* TO cenv[scrprev].*
  FETCH ABSOLUTE currrow c_vunival INTO tp.*
  DISPLAY tp.* TO cenv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION

FUNCTION initcombobox(cb)
    DEFINE cb ui.ComboBox
    DEFINE sqlquery STRING 
    DEFINE prefijo CHAR (5)
    CALL cb.CLEAR()
    LET sqlquery = "SELECT prefijo FROM fc_prefijos order by prefijo asc"
    PREPARE p_fc_servicios FROM sqlquery
    DECLARE c_fc_servicios CURSOR FOR p_fc_servicios
    FOREACH c_fc_servicios INTO prefijo
        CALL cb.addItem(prefijo, prefijo)
    END FOREACH  
END FUNCTION

