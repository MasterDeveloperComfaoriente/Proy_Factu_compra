GLOBALS "fc_globales.4gl"
DEFINE mdetexp char(10)
{
 FUNCTION sub_serviciosmain()
 DEFINE exist  SMALLINT
 DEFINE cb_tpvr, cb_estadoo, cb_tcp, cb_cat  ui.ComboBox
 DEFINE mciudad        char(40)
 OPEN WINDOW w_msub_servicios AT 1,1 WITH FORM "fc_sub_servicios"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gsub_servicios.* TO NULL
 INITIALIZE tpsub_servicios.* TO NULL

   
   LET cb_estadoo = ui.ComboBox.forName("fc_sub_servicios.estado")
   CALL cb_estadoo.clear()
   CALL cb_estadoo.addItem("A", "ACTIVO")
   CALL cb_estadoo.addItem("I", "INACTIVO")
    
  MENU
   COMMAND "Adiciona" "Adiciona la informacion de sub_servicios "
   LET mcodmen="FC08"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL sub_serviciosadd()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
    CALL sub_serviciosdplyg()
  END IF
 COMMAND "Consulta" "Consulta la informacion de un sub_servicios"
   LET mcodmen="FC09"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL sub_serviciosquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL sub_serviciosdplyg()
   END IF
  COMMAND "Modifica" "Modifica el registro de un Servicio"
   LET mcodmen="FC10"
   CALL opcion() RETURNING op
   if op="S" THEN
  IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " NO HAY INFORMACION DE UN SERVICIO EN CONSULTA ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    ELSE
     CALL sub_serviciosupdate()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
    END IF
    CALL sub_serviciosdplyg()
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
     CALL sub_serviciosremove()
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CLEAR FORM
      LET exist = FALSE
     END IF
    END IF
    CALL sub_serviciosdplyg()
   END IF
  
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_msub_servicios
END FUNCTION
}
{
FUNCTION sub_serviciosremove()
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : RETIRO DE INFORMACION DE sub_servicios " ATTRIBUTE(BLUE)
 PROMPT "Esta seguro de borrar el registro (s/n)? " FOR CHAR answer
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO EL REGISTRO " ATTRIBUTE(BLUE)
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  DELETE FROM fc_sub_servicios
    WHERE fc_sub_servicios.codigo = gsub_servicios.codigo
    
     IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
   IF NOT gerrflag THEN 
   INITIALIZE gsub_servicios.* TO NULL
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
}
{
FUNCTION sub_serviciosdplyg()
  DISPLAY BY NAME gsub_servicios.codigo THRU gsub_servicios.estado
  INITIALIZE mfc_prefijos.* TO NULL
  SELECT * into mfc_prefijos.* FROM fc_prefijos
  WHERE prefijo = gsub_servicios.prefijo
  DISPLAY mfc_prefijos.descripcion TO detprefijo
END FUNCTION
}
{
FUNCTION sub_serviciosadd()
 DEFINE mnumcod, x integer
 DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 MESSAGE "ESTADO: ADICION DEL REGISTRO DE UN SERVICIO"  ATTRIBUTE(BLUE)
 INITIALIZE tpsub_servicios.* TO NULL
lABEL Ent_persona:
 INPUT BY NAME tpsub_servicios.codigo THRU tpsub_servicios.estado WITHOUT DEFAULTS


 BEFORE FIELD codigo
   select max(codigo) into mnumcod from fc_sub_servicios
   if mnumcod is null then let mnumcod=1 end if
   LET cnt = 1
   LET x = mnumcod
   LET tpsub_servicios.codigo = x USING "&&&&&"
   WHILE cnt <> 0
    SELECT COUNT(*) INTO cnt FROM fc_sub_servicios
     WHERE codigo = tpsub_servicios.codigo
    IF cnt <> 0 THEN
     LET x = x + 1
     LET tpsub_servicios.codigo = x USING "&&&&&"
     DISPLAY BY NAME tpsub_servicios.codigo
    ELSE
     EXIT WHILE
    END IF
   END WHILE
   DISPLAY BY NAME tpsub_servicios.codigo
   NEXT FIELD codconta
 
  AFTER FIELD codigo
   IF tpsub_servicios.codigo IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Codigo del Servicio no fue digitado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD codigo
   END IF
   INITIALIZE mfc_sub_servicios.* TO NULL
   SELECT * into mfc_sub_servicios.* FROM fc_sub_servicios
   WHERE fc_sub_servicios.codigo = tpsub_servicios.codigo
   IF mfc_sub_servicios.codigo is not null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Codigo digitado ya existe ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
     NEXT field codigo
   END IF


  AFTER FIELD codconta
   IF tpsub_servicios.codconta IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
    comment= "El codigo de la Contabilidad no fue digitado  ", image= "exclamation")
     COMMAND "Aceptar"
        EXIT MENU
    END MENU
   ELSE
    INITIALIZE  mconta328.* TO NULL 
    SELECT * into mconta328.*  FROM conta328
    WHERE codconta = tpsub_servicios.codconta
    if mconta328.codconta is null then
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
          comment= " El codigo de la contabilidad no existe ", image= "exclamation")
         COMMAND "Aceptar"
        EXIT MENU
     END MENU
     LET tpsub_servicios.codconta = NULL 
     display by NAME tpsub_servicios.codconta
     NEXT FIELD codconta
    end IF 
   END IF 


 AFTER FIELD codcop
  IF tpsub_servicios.codcop is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El TIPO DE COMPROBANTE NO FUE DIGITADO ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD codcop
  END IF
  LET cnt=0
  SELECT count(*) INTO cnt FROM niif148
   WHERE codcop=tpsub_servicios.codcop
  IF cnt IS NULL THEN LET cnt=0 END IF
  IF cnt=0 THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El TIPO DE COMPROBANTE NO EXISTE ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD codcop
  END if   
  
  
 
   
  BEFORE FIELD prefijo
   INITIALIZE mfc_prefijos_usu.* TO NULL
   SELECT * INTO mfc_prefijos_usu.* FROM fc_prefijos_usu
    WHERE usu_elabora=musuario
   LET tpsub_servicios.prefijo = mfc_prefijos_usu.prefijo 
   DISPLAY BY NAME tpsub_servicios.prefijo
  

  AFTER FIELD prefijo
    IF tpsub_servicios.prefijo is null then
      CALL fc_prefijosval() RETURNING tpsub_servicios.prefijo
      IF tpsub_servicios.prefijo is NULL THEN 
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
         WHERE fc_prefijos.prefijo = tpsub_servicios.prefijo
        DISPLAY mfc_prefijos.descripcion TO detprefijo 
      END IF 
    ELSE
     INITIALIZE mfc_prefijos.* TO NULL
     SELECT * INTO mfc_prefijos.*
      FROM fc_prefijos
      WHERE fc_prefijos.prefijo = tpsub_servicios.prefijo
      DISPLAY mfc_prefijos.descripcion TO detprefijo     
    END IF  

    LET cnt=0
    SELECT count(*) INTO cnt FROM fc_prefijos_usu
     WHERE prefijo=tpsub_servicios.prefijo AND usu_elabora=musuario
    IF cnt IS NULL THEN LET cnt=0 END IF
    IF cnt=0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El usuario No puede Crear sub_servicios Para este Prefijo ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD prefijo
    END if  
   
  AFTER FIELD descripcion
   IF tpsub_servicios.descripcion IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " La Descripcion del Servicio no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD descripcion
   END IF
 
 
  AFTER FIELD iva
   IF tpsub_servicios.iva IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Valor del IVA no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD iva
   ELSE 
    IF tpsub_servicios.iva<0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Valor del IVA no puede ser menor de Cero ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
     NEXT FIELD iva
    END IF
   END if 
   
 
  
 AFTER FIELD impc
   IF tpsub_servicios.impc IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Valor del Impuesto Al Consumo no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD impc
   ELSE 
    IF tpsub_servicios.impc<0 IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Valor del Impuesto Al Consumo no pude ser menor de cero ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
     NEXT FIELD impc
    ELSE 
     IF tpsub_servicios.iva<>0 THEN
      IF tpsub_servicios.impc<>0 THEN
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Servicio Debe Tener Solo Un Impuesto ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD iva
      END IF
     END if 
    END if
   END IF

 AFTER FIELD maneja_cat
   IF tpsub_servicios.maneja_cat IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "Si el Servicio maneja Tarifa Categorizada no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD maneja_cat
   END IF

  AFTER FIELD cuotas
   IF tpsub_servicios.cuotas IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "Digite el tope de Cuotas cuando la Factura es a Credito ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD cuotas
   END IF

 

 
 AFTER FIELD estado
  IF tpsub_servicios.estado is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Estado del Servicio no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD estado
  END IF
 
   
  AFTER INPUT
   IF int_flag THEN
      EXIT INPUT
   ELSE
     IF tpsub_servicios.codigo is null or tpsub_servicios.prefijo is null 
      or tpsub_servicios.descripcion is null or tpsub_servicios.iva is NULL
      or tpsub_servicios.impc is NULL or tpsub_servicios.maneja_cat is NULL
      or tpsub_servicios.cuotas is null or tpsub_servicios.estado is null then 
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
    INITIALIZE tpsub_servicios.* TO NULL
  RETURN
 END IF
 MESSAGE "ADICIONANDO INFORMACION DEL SERVICIO"  ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT
 select max(codigo) into mnumcod from fc_sub_servicios
   if mnumcod is null then let mnumcod=1 end if
   LET cnt = 1
   LET x = mnumcod
   LET tpsub_servicios.codigo = x USING "&&&&&"
   WHILE cnt <> 0
    SELECT COUNT(*) INTO cnt FROM fc_sub_servicios
     WHERE codigo = tpsub_servicios.codigo
    IF cnt <> 0 THEN
     LET x = x + 1
     LET tpsub_servicios.codigo = x USING "&&&&&"
     DISPLAY BY NAME tpsub_servicios.codigo
    ELSE
     EXIT WHILE
    END IF
   END WHILE 
 IF tpsub_servicios.codigo is NOT null or tpsub_servicios.prefijo is NOT null 
      or tpsub_servicios.descripcion is NOT null or tpsub_servicios.iva is NOT NULL
      or tpsub_servicios.impc is NOT NULL or tpsub_servicios.maneja_cat is NOT NULL
      or tpsub_servicios.cuotas is NOT NULL or tpsub_servicios.estado is NOT null THEN   
  INSERT INTO fc_sub_servicios
   (codigo, codconta, codcop, prefijo, descripcion, iva, impc, maneja_cat, cuotas,  
      estado, fecsis, usuario ) 
   VALUES (tpsub_servicios.codigo, tpsub_servicios.codconta, tpsub_servicios.codcop, tpsub_servicios.prefijo, tpsub_servicios.descripcion, tpsub_servicios.iva, 
      tpsub_servicios.impc, tpsub_servicios.maneja_cat, tpsub_servicios.cuotas,   
      tpsub_servicios.estado, today, musuario )
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
  LET gsub_servicios.* = tpsub_servicios.*
  INITIALIZE tpsub_servicios.* TO NULL
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

FUNCTION sub_serviciosupdate()
 DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION DE LA INFORMACION DE UNA EMPRESA"  ATTRIBUTE(BLUE)
 LET tpsub_servicios.* = gsub_servicios.*
Label  Ent_persona2:
 INPUT BY NAME tpsub_servicios.codconta THRU tpsub_servicios.estado WITHOUT DEFAULTS}
{
 AFTER FIELD codigo
   IF tpsub_servicios.codigo IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Codigo del Servicio no fue digitado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD codigo
   END IF
   IF tpsub_servicios.codigo<>gsub_servicios.codigo THEN
    INITIALIZE mfc_sub_servicios.* TO NULL
    SELECT * into mfc_sub_servicios.* FROM fc_sub_servicios
    WHERE fc_sub_servicios.codigo = tpsub_servicios.codigo
    IF mfc_sub_servicios.codigo is not null THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El Codigo digitado ya existe ", image= "exclamation")
        COMMAND "Aceptar"
         EXIT MENU
      END MENU
      NEXT field codigo
    END IF
   END IF 

 } 
{
  AFTER FIELD codconta
   IF tpsub_servicios.codconta IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
    comment= "El codigo de la Contabilidad no fue digitado  ", image= "exclamation")
     COMMAND "Aceptar"
        EXIT MENU
    END MENU
   ELSE
    INITIALIZE  mconta328.* TO NULL 
    SELECT * into mconta328.*  FROM conta328
    WHERE codconta = tpsub_servicios.codconta
    if mconta328.codconta is null then
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
          comment= " El codigo de la contabilidad no existe ", image= "exclamation")
         COMMAND "Aceptar"
        EXIT MENU
     END MENU
     LET tpsub_servicios.codconta = NULL 
     display by NAME tpsub_servicios.codconta
     NEXT FIELD codconta
    end IF 
   END IF 


 AFTER FIELD codcop
  IF tpsub_servicios.codcop is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El TIPO DE COMPROBANTE NO FUE DIGITADO ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD codcop
  END IF
  LET cnt=0
  SELECT count(*) INTO cnt FROM niif148
   WHERE codcop=tpsub_servicios.codcop
  IF cnt IS NULL THEN LET cnt=0 END IF
  IF cnt=0 THEN
   MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El TIPO DE COMPROBANTE NO EXISTE ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD codcop
  END if   
  
  

 
  AFTER FIELD prefijo
    IF tpsub_servicios.prefijo is null then
      CALL fc_prefijosval() RETURNING tpsub_servicios.prefijo
      IF tpsub_servicios.prefijo is NULL THEN 
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
         WHERE fc_prefijos.prefijo = tpsub_servicios.prefijo
        DISPLAY mfc_prefijos.descripcion TO detprefijo 
      END IF 
    ELSE
     INITIALIZE mfc_prefijos.* TO NULL
     SELECT * INTO mfc_prefijos.*
      FROM fc_prefijos
      WHERE fc_prefijos.prefijo = tpsub_servicios.prefijo
      DISPLAY mfc_prefijos.descripcion TO detprefijo     
    END IF  

 
    
  AFTER FIELD descripcion
   IF tpsub_servicios.descripcion IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " La Descripcion del Servicio no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD descripcion
   END IF
 
 
  AFTER FIELD iva
   IF tpsub_servicios.iva IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Valor del IVA no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD iva
   ELSE 
    IF tpsub_servicios.iva<0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Valor del IVA no puede ser menor de Cero ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
     NEXT FIELD iva
    END IF
   END if 
   
 
  
 AFTER FIELD impc
   IF tpsub_servicios.impc IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Valor del Impuesto Al Consumo no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD impc
   ELSE 
    IF tpsub_servicios.impc<0 IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Valor del Impuesto Al Consumo no pude ser menor de cero ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
     NEXT FIELD impc
    ELSE 
     IF tpsub_servicios.iva<>0 THEN
      IF tpsub_servicios.impc<>0 THEN
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Servicio Debe Tener Solo Un Impuesto ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD iva
      END IF
     END if 
    END if
   END IF

 AFTER FIELD maneja_cat
   IF tpsub_servicios.maneja_cat IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "Si el Servicio maneja Tarifa Categorizada no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD maneja_cat
   END IF

 
 AFTER FIELD cuotas
   IF tpsub_servicios.cuotas IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "Digite el tope de Cuotas cuando la Factura es a Credito ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD cuotas
   END IF


 
 AFTER FIELD estado
  IF tpsub_servicios.estado is null then
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
  INITIALIZE tpsub_servicios.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION DEL SERVICIO" AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 UPDATE fc_sub_servicios
 SET (codigo, codconta, codcop, prefijo, descripcion, iva, impc, maneja_cat, cuotas, estado) 
    =(tpsub_servicios.codigo, tpsub_servicios.codconta, tpsub_servicios.codcop, tpsub_servicios.prefijo, tpsub_servicios.descripcion, tpsub_servicios.iva, 
      tpsub_servicios.impc, tpsub_servicios.maneja_cat, tpsub_servicios.cuotas,  tpsub_servicios.estado )
 WHERE codigo = gsub_servicios.codigo
 
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
  LET gsub_servicios.* = tpsub_servicios.*
 END IF
END FUNCTION 
}
{
FUNCTION sub_serviciosgetcurr( tpcodigo )
  DEFINE letras string
  DEFINE tpcodigo LIKE fc_sub_servicios.codigo
  INITIALIZE gsub_servicios.* TO NULL
  SELECT *  INTO gsub_servicios.*  FROM fc_sub_servicios
   WHERE fc_sub_servicios.codigo = tpcodigo
END FUNCTION

FUNCTION sub_serviciosshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum INTEGER
  IF gsub_servicios.codigo IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")"
 END IF
 CALL sub_serviciosdplyg()
END FUNCTION
}
{
FUNCTION sub_serviciosquery( exist )
 DEFINE WHERE_info, query_text  CHAR(400),
  answer      CHAR(1),
  exist,
  curr, maxnum integer,
  tpcodigo      LIKE fc_sub_servicios.codigo,
  letras string
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : CONSULTA DE LOS DATOS DEL SERVICIO "  ATTRIBUTE(BLUE)
 CLEAR FORM
 CONSTRUCT WHERE_info
   ON codigo, codconta, codcop, prefijo, descripcion, iva, impc, maneja_cat, cuotas, estado
   FROM codigo, codconta, codcop, prefijo, descripcion, iva, impc, maneja_cat, cuotas, estado 
      
 IF int_flag THEN 
   MENU "Informacion " ATTRIBUTE(style= "dialog", 
  comment= " LA CONSULTA FUE CANCELADA ",  image= "exclamation")
   COMMAND "Aceptar"
     EXIT MENU
   END MENU
  RETURN exist
 END IF
 MESSAGE "Buscando el registro, por favor espere ..." ATTRIBUTE(BLINK)
 LET query_text = " SELECT fc_sub_servicios.codigo",
   " FROM fc_sub_servicios WHERE usuario = \"",musuario,"\"",
   " AND ", where_info CLIPPED,
    " ORDER BY fc_sub_servicios.codigo ASC" 
 PREPARE s_ssub_servicios FROM query_text
 DECLARE c_ssub_servicios SCROLL CURSOR FOR s_ssub_servicios
 LET maxnum = 0
 FOREACH c_ssub_servicios INTO tpcodigo
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_ssub_servicios
  FETCH FIRST c_ssub_servicios INTO tpcodigo
  LET curr = 1
  CALL sub_serviciosgetcurr( tpcodigo)
  CALL sub_serviciosshowcurr( curr, maxnum )
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
    FETCH FIRST c_ssub_servicios INTO tpcodigo
    LET curr = 1
   ELSE
    FETCH NEXT c_ssub_servicios INTO tpcodigo
    LET curr = curr + 1
   END IF
   CALL sub_serviciosgetcurr( tpcodigo )
   CALL sub_serviciosshowcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_ssub_servicios INTO tpcodigo
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_ssub_servicios INTO tpcodigo
    LET curr = curr - 1
   END IF
   CALL sub_serviciosgetcurr( tpcodigo )
   CALL sub_serviciosshowcurr( curr, maxnum )
  COMMAND "Modifica" "Modifica el registro  en consulta"
   LET mcodmen="FC10"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF gsub_servicios.codigo IS NULL THEN
      CONTINUE MENU
    ELSE
      CLOSE c_ssub_servicios
      CALL sub_serviciosupdate()
      IF gerrflag THEN
       EXIT MENU
      END IF
      IF int_flag THEN
       LET int_flag = FALSE
      END IF
      CALL sub_serviciosgetcurr( tpcodigo)
      CALL sub_serviciosshowcurr( curr, maxnum )
      OPEN c_ssub_servicios
    END IF
  END IF
  COMMAND "Borra" "Borra el registro en consulta"
   LET mcodmen="FC11"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF gsub_servicios.codigo IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_ssub_servicios
     CALL sub_serviciosremove()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CALL sub_serviciosshowcurr( curr, maxnum )
     END IF
     OPEN c_ssub_servicios
    END IF
   END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF gsub_servicios.codigo IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_ssub_servicios
 RETURN exist
END FUNCTION
}




