GLOBALS "fe_globales.4gl"
DEFINE mniif233_1 RECORD LIKE niif233.*
 FUNCTION beneficiosmain()
 DEFINE exist  SMALLINT
 DEFINE cb_estadoo  ui.ComboBox
 OPEN WINDOW w_mbeneficios AT 1,1 WITH FORM "fe_beneficios"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gbeneficios.* TO NULL
 INITIALIZE tpbeneficios.* TO NULL
   LET cb_estadoo = ui.ComboBox.forName("fe_beneficios.estado")
   CALL cb_estadoo.clear()
   CALL cb_estadoo.addItem("A", "ACTIVO")
   CALL cb_estadoo.addItem("I", "INACTIVO")
    
 MENU
  COMMAND "Adiciona" "Adiciona conceptos de beneficios y/o descuentos "
   LET mcodmen="FE41"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL beneficiosadd()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
     END IF
   END IF
 COMMAND "Consulta" "Consulta conceptos de beneficios y/o descuentos "
   LET mcodmen="FE42"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL beneficiosquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL beneficiosdplyg()
   END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mbeneficios
END FUNCTION
FUNCTION beneficiosgetcurr( tpcodigo )
  DEFINE tpcodigo LIKE fe_beneficios.codigo
  INITIALIZE gbeneficios.* TO NULL
  SELECT *  INTO gbeneficios.*  FROM fe_beneficios
   WHERE fe_beneficios.codigo = tpcodigo
END FUNCTION

FUNCTION beneficiosshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum INTEGER
  IF gbeneficios.codigo IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")"
 END IF
 CALL beneficiosdplyg()
END FUNCTION
FUNCTION beneficiosdplyg()
  DISPLAY BY NAME gbeneficios.codigo THRU gbeneficios.estado
  INITIALIZE mniif233.* TO NULL
  SELECT * into mniif233.* from niif233 
   where auxiliar=gbeneficios.auxiliardb
   DISPLAY mniif233.detalle to detalle1
   INITIALIZE mniif233_1.* TO NULL
  SELECT * into mniif233_1.* from niif233 
   where auxiliar=gbeneficios.auxiliarcr
   DISPLAY mniif233_1.detalle to detalle2
  END FUNCTION
FUNCTION beneficiosadd()
 DEFINE mnumcod, x integer
 DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 MESSAGE "ESTADO: Adición, conceptos de beneficios y/o descuentos "  ATTRIBUTE(BLUE)
 INITIALIZE tpbeneficios.* TO NULL
lABEL Ent_persona:
 INPUT BY NAME tpbeneficios.codigo THRU tpbeneficios.estado WITHOUT DEFAULTS
 BEFORE FIELD codigo
   select max(codigo) into mnumcod from fe_beneficios
   if mnumcod is null then let mnumcod=1 end if
   LET cnt = 1
   LET x = mnumcod
   LET tpbeneficios.codigo = x USING "&&"
   WHILE cnt <> 0
    SELECT COUNT(*) INTO cnt FROM fe_beneficios
     WHERE codigo = tpbeneficios.codigo
    IF cnt <> 0 THEN
     LET x = x + 1
     LET tpbeneficios.codigo = x USING "&&"
     DISPLAY BY NAME tpbeneficios.codigo
    ELSE
     EXIT WHILE
    END IF
   END WHILE
   DISPLAY BY NAME tpbeneficios.codigo
   NEXT FIELD descripcion
  AFTER FIELD codigo
   IF tpbeneficios.codigo IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Código del  beneficio y/o descuento  no fue digitado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD codigo
   END IF
   INITIALIZE mfe_beneficios.* TO NULL
   SELECT * into mfe_beneficios.* FROM fe_beneficios
   WHERE fe_beneficios.codigo = tpbeneficios.codigo
   IF mfe_beneficios.codigo is not null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Código digitado ya existe ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
     NEXT field codigo
   END IF
  AFTER FIELD descripcion
   IF tpbeneficios.descripcion IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " La Descripción del Beneficio y/o descuento  no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD descripcion
   END IF
  AFTER FIELD auxiliardb
   IF tpbeneficios.auxiliardb IS null THEN
    LET op="1"
    LET tpbeneficios.auxiliardb = villac02val()
    LET tpbeneficios.auxiliardb=tpbeneficios.auxiliardb clipped,"000000"
    DISPLAY BY NAME tpbeneficios.auxiliardb
   END IF
   IF tpbeneficios.auxiliardb IS NOT NULL THEN
    LET tpbeneficios.auxiliardb=tpbeneficios.auxiliardb clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpbeneficios.auxiliardb
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable debito no fue digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
     INITIALIZE tpbeneficios.auxiliardb TO NULL
     INITIALIZE mniif233.* TO NULL
     --NEXT FIELD auxiliardb
    END IF
   END IF
   IF tpbeneficios.auxiliardb IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpbeneficios.auxiliardb
    DISPLAY mniif233.detalle to formonly.detalle1
   END IF
  AFTER FIELD auxiliarcr
   IF tpbeneficios.auxiliarcr IS null THEN
    LET op="1"
    LET tpbeneficios.auxiliarcr= villac02val()
    LET tpbeneficios.auxiliarcr=tpbeneficios.auxiliarcr clipped,"000000"
    DISPLAY BY NAME tpbeneficios.auxiliarcr
   END IF
   IF tpbeneficios.auxiliarcr IS NOT NULL THEN
    LET tpbeneficios.auxiliarcr=tpbeneficios.auxiliarcr clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar =tpbeneficios.auxiliarcr
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable credito no due digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
     INITIALIZE tpbeneficios.auxiliarcr TO NULL
     INITIALIZE mniif233.* TO NULL
     --NEXT FIELD auxiliarcr
    END IF
   END IF
   IF tpbeneficios.auxiliarcr IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpbeneficios.auxiliarcr
    DISPLAY mniif233.detalle to formonly.detalle2
   END IF  

  AFTER FIELD codcop
   IF tpbeneficios.codcop IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpbeneficios.codcop
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpbeneficios.codcop TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop
    END IF 
   END IF

 AFTER FIELD codcop2
   IF tpbeneficios.codcop2 IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop2
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpbeneficios.codcop2
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpbeneficios.codcop2 TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop2
    END IF 
   END IF

   
 AFTER FIELD estado
  IF tpbeneficios.estado is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Estado del Beneficio y/o descuento  no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD estado
  END IF
  AFTER INPUT
   IF int_flag THEN
      EXIT INPUT
   ELSE
     IF tpbeneficios.codigo is null 
      or tpbeneficios.descripcion is NULL or tpbeneficios.auxiliardb is NULL
      or tpbeneficios.estado is null then 
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
     comment= " La adición fue cancelada "  , image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    INITIALIZE tpbeneficios.* TO NULL
  RETURN
 END IF
 MESSAGE "Adicionando Información de beneficios y/o descuentos "  ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT
 select max(codigo) into mnumcod from fe_beneficios
   if mnumcod is null then let mnumcod=1 end if
   LET cnt = 1
   LET x = mnumcod
   LET tpbeneficios.codigo = x USING "&&"
   WHILE cnt <> 0
    SELECT COUNT(*) INTO cnt FROM fe_beneficios
     WHERE codigo = tpbeneficios.codigo
    IF cnt <> 0 THEN
     LET x = x + 1
     LET tpbeneficios.codigo = x USING "&&"
     DISPLAY BY NAME tpbeneficios.codigo
    ELSE
     EXIT WHILE
    END IF
   END WHILE 
 IF tpbeneficios.codigo is NOT null 
      or tpbeneficios.descripcion is NOT null or tpbeneficios.auxiliardb is NOT NULL
      or tpbeneficios.estado is NOT null THEN   
  INSERT INTO fe_beneficios
   (codigo, descripcion,auxiliardb, auxiliarcr, codcop, codcop2, estado,
      fecsis, usuario ) 
   VALUES (tpbeneficios.codigo, tpbeneficios.descripcion, tpbeneficios.auxiliardb, 
     tpbeneficios.auxiliarcr, tpbeneficios.codcop, tpbeneficios.codcop2, tpbeneficios.estado,  today, musuario )
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
  LET gbeneficios.* = tpbeneficios.*
  INITIALIZE tpbeneficios.* TO NULL
 MENU "Información"  ATTRIBUTE( style= "dialog", 
   comment= " La información del beneficio y/o descuento fue adicionada...  "  ,
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
FUNCTION beneficiosquery( exist )
 DEFINE WHERE_info, query_text  CHAR(400),
  answer      CHAR(1),
  exist,
  curr, maxnum integer,
  tpcodigo      LIKE fe_beneficios.codigo,
  letras string
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : Consulta los datos del beneficio y/o descuento  "  ATTRIBUTE(BLUE)
 CLEAR FORM
 CONSTRUCT WHERE_info
   ON codigo,descripcion,auxiliardb,codcop,codcop2,estado
   FROM codigo,descripcion,auxiliardb,codcop,codcop2,estado
 IF int_flag THEN 
   MENU "Informacion " ATTRIBUTE(style= "dialog", 
  comment= " LA CONSULTA FUE CANCELADA ",  image= "exclamation")
   COMMAND "Aceptar"
     EXIT MENU
   END MENU
  RETURN exist
 END IF
 MESSAGE "Buscando el registro, por favor espere ..." ATTRIBUTE(BLINK)
 LET query_text = " SELECT fe_beneficios.codigo",
   " FROM fe_beneficios WHERE ",where_info CLIPPED,
    " ORDER BY fe_beneficios.codigo ASC" 
 PREPARE s_sbeneficios FROM query_text
 DECLARE c_sbeneficios SCROLL CURSOR FOR s_sbeneficios
 LET maxnum = 0
 FOREACH c_sbeneficios INTO tpcodigo
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_sbeneficios
  FETCH FIRST c_sbeneficios INTO tpcodigo
  LET curr = 1
  CALL beneficiosgetcurr( tpcodigo)
  CALL beneficiosshowcurr( curr, maxnum )
 ELSE
  MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
   comment= " El registro del beneficio y/o descuento no Existe", image= "exclamation")
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
    FETCH FIRST c_sbeneficios INTO tpcodigo
    LET curr = 1
   ELSE
    FETCH NEXT c_sbeneficios INTO tpcodigo
    LET curr = curr + 1
   END IF
   CALL beneficiosgetcurr( tpcodigo )
   CALL beneficiosshowcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_sbeneficios INTO tpcodigo
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_sbeneficios INTO tpcodigo
    LET curr = curr - 1
   END IF
   CALL beneficiosgetcurr( tpcodigo )
   CALL beneficiosshowcurr( curr, maxnum )
  COMMAND "Modifica" "Modifica el registro en consulta"
   LET mcodmen="FE43"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF gbeneficios.codigo IS NULL THEN
     CONTINUE MENU
     ELSE
      CLOSE c_sbeneficios
      CALL beneficiosupdate()
      IF gerrflag THEN
       EXIT MENU
      END IF
      IF int_flag THEN
       LET int_flag = FALSE
      END IF
      CALL beneficiosgetcurr( tpcodigo)
      CALL beneficiosshowcurr( curr, maxnum )
      OPEN c_sbeneficios
     END IF
  END IF
  COMMAND "Borra" "Borra el registro en consulta"
   LET mcodmen="FE44"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF gbeneficios.codigo IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sbeneficios
     CALL beneficiosremove()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CALL beneficiosshowcurr( curr, maxnum )
     END IF
     OPEN c_sbeneficios
    END IF
   END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF gbeneficios.codigo IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sbeneficios
 RETURN exist
END FUNCTION 
FUNCTION beneficiosupdate()
 DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACIÓN DE LA INFORMACIÓN DE BENEFICIOS Y/O DESCUENTOS "  ATTRIBUTE(BLUE)
 LET tpbeneficios.* = gbeneficios.*
Label  Ent_persona2:
 INPUT BY NAME tpbeneficios.descripcion THRU tpbeneficios.estado WITHOUT DEFAULTS

  AFTER FIELD descripcion
   IF tpbeneficios.descripcion IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " La Descripcion del Beneficio y/o descuento no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD descripcion
   END IF
 AFTER FIELD auxiliardb
   IF tpbeneficios.auxiliardb IS null THEN
    LET op="1"
    LET tpbeneficios.auxiliardb = villac02val()
    LET tpbeneficios.auxiliardb=tpbeneficios.auxiliardb clipped,"000000"
    DISPLAY BY NAME tpbeneficios.auxiliardb
   END IF
   IF tpbeneficios.auxiliardb IS NOT NULL THEN
    LET tpbeneficios.auxiliardb=tpbeneficios.auxiliardb clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpbeneficios.auxiliardb
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpbeneficios.auxiliardb TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliardb
    END IF
   END IF
   IF tpbeneficios.auxiliardb IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpbeneficios.auxiliardb
    DISPLAY mniif233.detalle to formonly.detalle1
   END IF
  AFTER FIELD auxiliarcr
   IF tpbeneficios.auxiliarcr IS null THEN
    LET op="1"
    LET tpbeneficios.auxiliarcr= villac02val()
    LET tpbeneficios.auxiliarcr=tpbeneficios.auxiliarcr clipped,"000000"
    DISPLAY BY NAME tpbeneficios.auxiliarcr
   END IF
   IF tpbeneficios.auxiliarcr IS NOT NULL THEN
    LET tpbeneficios.auxiliarcr=tpbeneficios.auxiliarcr clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar =tpbeneficios.auxiliarcr
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable credito no due digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
     INITIALIZE tpbeneficios.auxiliarcr TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliarcr
    END IF
   END IF
   IF tpbeneficios.auxiliarcr IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpbeneficios.auxiliarcr
    DISPLAY mniif233.detalle to formonly.detalle2
   END IF  

  AFTER FIELD codcop
   IF tpbeneficios.codcop IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpbeneficios.codcop
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpbeneficios.codcop TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop
    END IF 
   END IF

 AFTER FIELD codcop2
   IF tpbeneficios.codcop2 IS NULL THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     --  comment="El Codigo del Comprobante no fue Digitado",
     --  image= "exclamation")
     --  COMMAND "Aceptar"
     --    EXIT MENU
     --END MENU  
    --NEXT FIELD codcop2
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpbeneficios.codcop2
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpbeneficios.codcop2 TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop2
    END IF 
   END IF

   
 AFTER FIELD estado
  IF tpbeneficios.estado is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Estado del Beneficio y/o descuento no fue digitado ",image= "exclamation")
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
  INITIALIZE tpbeneficios.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION DEL BENEFICIO Y/O DESCUENTO" AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 UPDATE fe_beneficios
 SET (codigo, descripcion,auxiliardb, auxiliarcr, codcop,  codcop2, estado) 
    =(tpbeneficios.codigo, tpbeneficios.descripcion, tpbeneficios.auxiliardb, 
    tpbeneficios.auxiliarcr, tpbeneficios.codcop, tpbeneficios.codcop2, tpbeneficios.estado )
 WHERE codigo = gbeneficios.codigo
 
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
  LET gbeneficios.* = tpbeneficios.*
 END IF
END FUNCTION  
FUNCTION beneficiosremove()
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : Retiro Información de beneficios y/o descuentos " ATTRIBUTE(BLUE)
 PROMPT "Esta seguro de borrar el registro (s/n)? " FOR CHAR answer
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO EL REGISTRO " ATTRIBUTE(BLUE)
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  DELETE FROM fe_beneficios
    WHERE fe_beneficios.codigo = gbeneficios.codigo
    
     IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
   IF NOT gerrflag THEN 
   INITIALIZE gbeneficios.* TO NULL
   MENU "Información"  ATTRIBUTE( style= "dialog", 
        comment= " El Registro fue retirado", image= "information")
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


FUNCTION fe_beneficiosval()
 DEFINE tp   RECORD
   codigo         LIKE fe_beneficios.codigo,
   descripcion     LIKE fe_beneficios.descripcion
 END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fe_beneficios
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.codigo = NULL
  RETURN tp.codigo
 END IF
 OPEN WINDOW bxw_vfe_prefijos1 AT 8,32 WITH FORM "fe_beneficiosv"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 DECLARE bxc_vfe_prefijos1 SCROLL CURSOR FOR
  SELECT fe_beneficios.codigo, fe_beneficios.descripcion FROM fe_beneficios
   ORDER BY fe_beneficios.codigo
 OPEN bxc_vfe_prefijos1
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL bfe_tarifasroww( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
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
   CALL bfe_tarifasroww( currrow, prevrow, pagenum )
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
   CALL bfe_tarifasroww( currrow, prevrow, pagenum )
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
   CALL bfe_tarifasroww( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow bxc_vfe_prefijos1 INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.codigo = NULL
   EXIT MENU
 END MENU
 CLOSE bxc_vfe_prefijos1
 CLOSE WINDOW bxw_vfe_prefijos1
 RETURN tp.codigo
END FUNCTION  
FUNCTION bfe_tarifasroww( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   codigo         LIKE fe_beneficios.codigo,
   descripcion     LIKE fe_beneficios.descripcion
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
  FETCH ABSOLUTE scrfrst bxc_vfe_prefijos1 INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cenv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO cenv[x].*
   END IF
   IF x < scrmax THEN
    FETCH bxc_vfe_prefijos1 INTO tp.*
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
  FETCH ABSOLUTE prevrow bxc_vfe_prefijos1 INTO tp.*
  DISPLAY tp.* TO cenv[scrprev].*
  FETCH ABSOLUTE currrow bxc_vfe_prefijos1 INTO tp.*
  DISPLAY tp.* TO cenv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION




