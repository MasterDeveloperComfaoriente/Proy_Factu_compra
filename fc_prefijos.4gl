GLOBALS "fc_globales.4gl"
DEFINE mdetexp char(10)
DEFINE rec_prefijos,gaprefijos RECORD
    prefijo LIKE fc_prefijos.prefijo,
    descripcion LIKE fc_prefijos.descripcion,
    numini LIKE fc_prefijos.numini,
    numfin LIKE fc_prefijos.numfin,
    numero LIKE fc_prefijos.numero,
    num_auto LIKE fc_prefijos.num_auto,
    fec_auto LIKE fc_prefijos.fec_auto,
    fec_ven LIKE fc_prefijos.fec_ven,
    direccion LIKE fc_prefijos.direccion,
    zona LIKE fc_prefijos.zona,
     dias_cred LIKE fc_prefijos.dias_cred,
     telefono LIKE fc_prefijos.telefono,
    tarifa_vigente LIKE fc_prefijos.tarifa_vigente,
    redondeo CHAR (1),
    nota LIKE fc_prefijos.nota,
    
    estado like fc_prefijos.estado 
END RECORD 
 FUNCTION prefijosmain()
 DEFINE exist  SMALLINT
 DEFINE {cb_planti,} cb_estado, cb_conta, cb_redon       ui.ComboBox
 DEFINE mciudad        char(40)
  
 OPEN WINDOW w_mprefijos AT 1,1 WITH FORM "fc_prefijos"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gaprefijos.* TO NULL
 INITIALIZE rec_prefijos.* TO NULL
  { LET cb_planti = ui.ComboBox.forName("fc_prefijos.num_plantilla")
   CALL cb_planti.clear()
   CALL cb_planti.addItem("2", "PLANTILLA LOGOS CAJA")
   CALL cb_planti.addItem("1", "PLANTILLA LOGOS SALUD")}
   LET cb_estado = ui.ComboBox.forName("fc_prefijos.estado")
   CALL cb_estado.clear()
   CALL cb_estado.addItem("A", "ACTIVO")
   CALL cb_estado.addItem("I", "INACTIVO")
   LET cb_conta = ui.ComboBox.forName("redondeo")
   CALL cb_conta.clear()
   CALL cb_conta.addItem("S", "SI")
   CALL cb_conta.addItem("N", "NO")
  MENU
   COMMAND "Adiciona" "Adiciona la informacion de prefijos "
   LET mcodmen="FC03"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL prefijosadd()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
    CALL prefijosdplyg()
  END IF
 COMMAND "Consulta" "Consulta la informacion de un Prefijo"
   LET mcodmen="FC04"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL prefijosquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL prefijosdplyg()
   END IF
  COMMAND "Modifica" "Modifica el registro de un Prefijo"
   LET mcodmen="FC05"
   CALL opcion() RETURNING op
   if op="S" THEN
  IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " NO HAY INFORMACION DE UN PREFIJO EN CONSULTA ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    ELSE
     CALL prefijosupdate()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
    END IF
    CALL prefijosdplyg()
   END IF
  COMMAND "Borra" "Borra la informacion de un prefijo "
   LET mcodmen="FC06"
   CALL opcion() RETURNING op
  if op="S" THEN
   IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
           comment=" NO HAY INFORMACION DE UN PREFIJO EN CONSULTA",   
           image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
   ELSE
     CALL prefijosremove()
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CLEAR FORM
      LET exist = FALSE
     END IF
    END IF
    CALL prefijosdplyg()
   END IF
   COMMAND "Reporte" "Reporte de Prefijos"
    CALL rep_prefijos()
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mprefijos
END FUNCTION

FUNCTION prefijosremove()
DEFINE control SMALLINT
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : RETIRO DE INFORMACION DE prefijos " ATTRIBUTE(BLUE)
 PROMPT "Esta seguro de borrar el registro (s/n)? " FOR CHAR answer
 IF answer MATCHES "[Ss]" THEN
  LET control=0
  SELECT count(*) INTO control FROM fc_factura_m
   WHERE prefijo=gaprefijos.prefijo
  IF control IS null THEN LET control=0 END IF
  IF control<>0 THEN
   let answer="N"
  END if 
 END if
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO EL REGISTRO " ATTRIBUTE(BLUE)
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  DELETE FROM fc_prefijos
    WHERE fc_prefijos.prefijo = gaprefijos.prefijo

    
     IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
   IF NOT gerrflag THEN 
   INITIALIZE gaprefijos.* TO NULL
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

FUNCTION prefijosdplyg()
    DEFINE record_pre RECORD LIKE fc_prefijos.*
    INITIALIZE record_pre.* TO NULL 
    SELECT * INTO record_pre.* FROM fc_prefijos
    WHERE prefijo = gaprefijos.prefijo
    DISPLAY record_pre.prefijo TO prefijo
    DISPLAY record_pre.descripcion TO descripcion
    DISPLAY record_pre.numini TO numini
    DISPLAY record_pre.numfin TO numfin
    DISPLAY record_pre.numero TO numero 
    DISPLAY record_pre.num_auto TO num_auto
    DISPLAY record_pre.fec_auto TO fec_auto
    DISPLAY record_pre.fec_ven TO fec_ven
    DISPLAY record_pre.direccion TO direccion
    DISPLAY record_pre.zona TO zona 
    DISPLAY record_pre.dias_cred TO dias_cred
    DISPLAY record_pre.telefono TO telefono
    DISPLAY record_pre.tarifa_vigente TO tarifa_vigente
    DISPLAY record_pre.nota TO nota
    DISPLAY record_pre.estado TO estado
  
  INITIALIZE mgener09.* TO NULL
  SELECT * into mgener09.* FROM gener09
  WHERE codzon = gaprefijos.zona
  DISPLAY mgener09.detzon TO detciu
  
END FUNCTION

FUNCTION prefijosadd()
 
   
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
     MESSAGE "ESTADO: ADICIONANDO PREFIJOS"  ATTRIBUTE(BLUE)
     INITIALIZE rec_prefijos.* TO NULL

lABEL Ent_persona:
 INPUT BY NAME rec_prefijos.prefijo THRU rec_prefijos.estado WITHOUT DEFAULTS
 
  AFTER FIELD prefijo
   IF rec_prefijos.prefijo IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El numero de Prefijo no fue digitado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD prefijo
   END IF
   INITIALIZE mfc_prefijos.* TO NULL
   SELECT * into mfc_prefijos.* FROM fc_prefijos
   WHERE fc_prefijos.prefijo = rec_prefijos.prefijo
   IF mfc_prefijos.prefijo is not null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Prefijo digitado ya existe ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
     NEXT field prefijo
   END IF
  
  AFTER FIELD descripcion
   IF rec_prefijos.descripcion IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " La Descripcion del Prefijo no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD descripcion
   END IF

  AFTER FIELD numini
   IF rec_prefijos.numini IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Numero Inicial de Facturacion no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numini
   END IF
 AFTER FIELD numfin
   IF rec_prefijos.numfin IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Numero Final de Facturacion no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numfin
   END IF
 AFTER FIELD numero
   IF rec_prefijos.numero IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Numero Inicial Donde Arranca La Facturacion no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numero
   END IF 
 AFTER FIELD num_auto
   IF rec_prefijos.num_auto IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Numero De Autorizacion De Facturacion no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD num_auto
   END IF
 
 AFTER FIELD fec_auto
   IF rec_prefijos.fec_auto IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "La Fecha De Autorizacion De Facturacion no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD fec_auto
   END IF

  AFTER FIELD fec_ven
   IF rec_prefijos.fec_ven IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "La Fecha De Vencimiento de la Autorizacion De Facturacion no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD fec_ven
   END IF
   
 {AFTER FIELD num_plantilla
   IF rec_prefijos.num_plantilla IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Numero de Plantilla no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD num_plantilla
   END IF}

 AFTER FIELD direccion
  IF rec_prefijos.direccion is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " La direccion no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD direccion
  END IF
  
 AFTER FIELD zona
  IF rec_prefijos.zona IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
    comment= "El codigo de ciudad no fue digitado  ", image= "exclamation")
     COMMAND "Aceptar"
        EXIT MENU
    END MENU
  ELSE
    INITIALIZE  mgener09.* TO NULL 
    SELECT * into mgener09.*  FROM gener09
    WHERE codzon = rec_prefijos.zona
    if mgener09.codzon is null then
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
          comment= " El codigo de la ciudad no existe ", image= "exclamation")
         COMMAND "Aceptar"
        EXIT MENU
     END MENU
     LET rec_prefijos.zona = NULL 
     display BY NAME rec_prefijos.zona
     NEXT FIELD zona
    else
      display mgener09.detzon to detciu
    end IF 
  END IF
 AFTER FIELD dias_cred
  IF rec_prefijos.dias_cred is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " Los Dias Para la Factura Venta a Credito no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD dias_cred
  END IF
AFTER FIELD telefono
  IF rec_prefijos.telefono is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Numero de Telefono no fue digitado ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD telefono
  END IF

 

  AFTER FIELD tarifa_vigente
   IF rec_prefijos.tarifa_vigente IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " La Tarifa Vigente no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD tarifa_vigente
   END IF
 AFTER FIELD redondeo
  IF rec_prefijos.redondeo is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " La Bandera si el Prefijo maneja redondeo no fue seleccionada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD redondeo
  END IF  
 AFTER FIELD estado
  IF rec_prefijos.estado is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Estado del Prefijo no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD estado
  END IF

 AFTER INPUT
   IF int_flag THEN
      EXIT INPUT
   ELSE
     IF rec_prefijos.prefijo is null  
      or rec_prefijos.descripcion is null or rec_prefijos.numini is NULL
      or rec_prefijos.numfin is null OR rec_prefijos.numero IS null 
      OR rec_prefijos.num_auto is NULL
      or rec_prefijos.fec_auto is NULL or rec_prefijos.fec_ven is NULL 
      {or rec_prefijos.num_plantilla is null }
      or rec_prefijos.direccion is null or rec_prefijos.zona is null
      or rec_prefijos.dias_cred is null or rec_prefijos.telefono is NULL 
      or rec_prefijos.estado is null then 
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
                  comment= " La adicion fue cancelada      "  ,
                   image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    INITIALIZE rec_prefijos.* TO NULL
  RETURN
 END IF
 MESSAGE "ADICIONANDO INFORMACION"  ATTRIBUTE(BLUE)  

 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 IF rec_prefijos.prefijo is NOT null 
      or rec_prefijos.descripcion is NOT null or rec_prefijos.numini is NOT NULL
      or rec_prefijos.numfin is NOT NULL OR rec_prefijos.numero IS NOT null 
      or rec_prefijos.num_auto is NOT NULL
      or rec_prefijos.fec_auto is NOT NULL or rec_prefijos.fec_ven is NOT NULL 
      or rec_prefijos.direccion is NOT null or rec_prefijos.zona is NOT null
      or rec_prefijos.dias_cred is NOT null or rec_prefijos.telefono is NOT NULL or rec_prefijos.estado is NOT null THEN   
  INSERT INTO fc_prefijos
   (prefijo, descripcion, numini, numfin, numero, num_auto, fec_auto, fec_ven,
      direccion, zona, dias_cred, telefono, tarifa_vigente, redondeo, nota, estado, fecsis, usuario ) 
   VALUES (rec_prefijos.prefijo, rec_prefijos.descripcion, rec_prefijos.numini, rec_prefijos.numfin, rec_prefijos.numero, 
      rec_prefijos.num_auto, rec_prefijos.fec_auto, rec_prefijos.fec_ven, rec_prefijos.direccion, rec_prefijos.zona, 
      rec_prefijos.dias_cred, rec_prefijos.telefono, rec_prefijos.tarifa_vigente,  rec_prefijos.redondeo,
      rec_prefijos.nota, rec_prefijos.estado, today, musuario )
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
  CLEAR FORM
 end IF
 
 IF NOT gerrflag THEN
  COMMIT WORK
  LET gaprefijos.* = rec_prefijos.*
  INITIALIZE rec_prefijos.* TO NULL
 MENU "Información"  ATTRIBUTE( style= "dialog", 
   comment= " La informacion del prefijo fue adicionada...  "  ,
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

FUNCTION prefijosupdate()
 DEFINE control SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION DE LA INFORMACION DE UN PREFIJO"  ATTRIBUTE(BLUE)
 LET rec_prefijos.* = gaprefijos.*
Label  Ent_persona2:
 INPUT BY NAME rec_prefijos.prefijo THRU rec_prefijos.estado WITHOUT DEFAULTS

 AFTER FIELD prefijo
   IF rec_prefijos.prefijo IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El numero de Prefijo no fue digitado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD prefijo
   END IF
   IF rec_prefijos.prefijo<>gaprefijos.prefijo THEN
    LET control=0
    SELECT count(*) INTO control FROM fc_factura_m
     WHERE prefijo=gaprefijos.prefijo
    IF control IS NULL THEN LET control=0 END IF
    IF control<>0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El Prefijo Ya Fue utilizado No se puede Modificar ", image= "exclamation")
        COMMAND "Aceptar"
         EXIT MENU
      END MENU
      LET rec_prefijos.prefijo=gaprefijos.prefijo
      display BY NAME rec_prefijos.prefijo
      NEXT field prefijo
    END if 
  
    INITIALIZE mfc_prefijos.* TO NULL
    SELECT * into mfc_prefijos.* FROM fc_prefijos
    WHERE fc_prefijos.prefijo = rec_prefijos.prefijo
    IF mfc_prefijos.prefijo is not null THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El Prefijo digitado ya existe ", image= "exclamation")
        COMMAND "Aceptar"
         EXIT MENU
      END MENU
      NEXT field prefijo
    END IF
   END IF 
   
  AFTER FIELD descripcion
   IF rec_prefijos.descripcion IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " La Descripcion del Prefijo no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD descripcion
   END IF
  AFTER FIELD numini
   IF rec_prefijos.numini IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Numero Inicial del Documento no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numini
   END IF
 AFTER FIELD numfin
   IF rec_prefijos.numfin IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Numero Final de Facturacion no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numfin
   END IF

 AFTER FIELD numero
   IF rec_prefijos.numero IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Numero Inicial Donde Arranca La Facturacion no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numero
   END IF 
 AFTER FIELD num_auto
   IF rec_prefijos.num_auto IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Numero De Autorizacion De Facturacion no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD num_auto
   END IF
 
 AFTER FIELD fec_auto
   IF rec_prefijos.fec_auto IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "La Fecha De Autorizacion De Facturacion no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD fec_auto
   END IF

  AFTER FIELD fec_ven
   IF rec_prefijos.fec_ven IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "La Fecha De Vencimiento de la Autorizacion De Facturacion no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD fec_ven
   END IF
{  
 AFTER FIELD num_plantilla
   IF rec_prefijos.num_plantilla IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Numero de Plantilla no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD num_plantilla
   END IF
}
 AFTER FIELD direccion
  IF rec_prefijos.direccion is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " La direccion no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD direccion
  END IF
  
 AFTER FIELD zona
  IF rec_prefijos.zona IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
    comment= "El codigo de ciudad no fue digitado  ", image= "exclamation")
     COMMAND "Aceptar"
        EXIT MENU
    END MENU
  ELSE
    INITIALIZE  mgener09.* TO NULL 
    SELECT * into mgener09.*  FROM gener09
    WHERE codzon = rec_prefijos.zona
    if mgener09.codzon is null then
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
          comment= " El codigo de la ciudad no existe ", image= "exclamation")
         COMMAND "Aceptar"
        EXIT MENU
     END MENU
     LET rec_prefijos.zona = NULL 
     display BY NAME rec_prefijos.zona
     NEXT FIELD zona
    else
      display mgener09.detzon to detciu
    end IF 
  END IF

 AFTER FIELD dias_cred
  IF rec_prefijos.dias_cred is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " Los Dias Para la Factura Venta a Credito no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD dias_cred
  END IF

AFTER FIELD telefono
  IF rec_prefijos.telefono is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Numero de Telefono no fue digitado ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD telefono
  END IF

 

 AFTER FIELD tarifa_vigente
   IF rec_prefijos.tarifa_vigente IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " La Tarifa Vigente no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD tarifa_vigente
   END IF

 AFTER FIELD estado
  IF rec_prefijos.estado is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Estado del Prefijo no fue digitada ",image= "exclamation")
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
  INITIALIZE rec_prefijos.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION DEL PREFIJO" AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 UPDATE fc_prefijos
 SET (prefijo, descripcion, numini, numfin, numero, num_auto, fec_auto, fec_ven,
      {num_plantilla,} direccion, zona, dias_cred, telefono, tarifa_vigente, redondeo, nota, estado) 
    =(rec_prefijos.prefijo, rec_prefijos.descripcion, rec_prefijos.numini, rec_prefijos.numfin, rec_prefijos.numero, 
      rec_prefijos.num_auto, rec_prefijos.fec_auto, rec_prefijos.fec_ven, {rec_prefijos.num_plantilla,} rec_prefijos.direccion, 
      rec_prefijos.zona,  rec_prefijos.dias_cred, rec_prefijos.telefono,  rec_prefijos.tarifa_vigente, 
       rec_prefijos.redondeo, rec_prefijos.nota, rec_prefijos.estado )
 WHERE prefijo = gaprefijos.prefijo
 
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
  LET gaprefijos.* = rec_prefijos.*
 END IF
END FUNCTION  

FUNCTION prefijosgetcurr( tpprefijo )
  DEFINE letras string
  DEFINE tpprefijo LIKE fc_prefijos.prefijo
  INITIALIZE gaprefijos.* TO NULL
  SELECT *  INTO gaprefijos.*  FROM fc_prefijos
   WHERE fc_prefijos.prefijo = tpprefijo
   
END FUNCTION

FUNCTION prefijosshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum INTEGER
  IF gaprefijos.prefijo IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")"
 END IF
 CALL prefijosdplyg()
END FUNCTION

FUNCTION prefijosquery( exist )
 DEFINE WHERE_info, query_text  CHAR(400),
  answer      CHAR(1),
  exist,
  curr, maxnum integer,
  tpprefijo      LIKE fc_prefijos.prefijo,
  letras string
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : CONSULTA DE LOS DATOS DEL PREFIJO "  ATTRIBUTE(BLUE)
 CLEAR FORM
 CONSTRUCT WHERE_info
   ON prefijo, descripcion, numini, numfin, numero, num_auto, fec_auto, fec_ven, 
      direccion, zona, dias_cred, telefono, tarifa_vigente, estado
   FROM prefijo, descripcion, numini, numfin, numero, num_auto, fec_auto, fec_ven,
     direccion, zona, dias_cred, telefono,  tarifa_vigente, estado
 IF int_flag THEN 
   MENU "Informacion " ATTRIBUTE(style= "dialog", 
  comment= " LA CONSULTA FUE CANCELADA ",  image= "exclamation")
   COMMAND "Aceptar"
     EXIT MENU
   END MENU
  RETURN exist
 END IF
 MESSAGE "Buscando el registro, por favor espere ..." ATTRIBUTE(BLINK)
 LET query_text = " SELECT fc_prefijos.prefijo",
   " FROM fc_prefijos WHERE ", where_info CLIPPED,
    " ORDER BY fc_prefijos.prefijo ASC" 
 PREPARE s_sprefijos FROM query_text
 DECLARE c_sprefijos SCROLL CURSOR FOR s_sprefijos
 LET maxnum = 0
 FOREACH c_sprefijos INTO tpprefijo
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_sprefijos
  FETCH FIRST c_sprefijos INTO tpprefijo
  LET curr = 1
  CALL prefijosgetcurr( tpprefijo)
  CALL prefijosshowcurr( curr, maxnum )
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
    FETCH FIRST c_sprefijos INTO tpprefijo
    LET curr = 1
   ELSE
    FETCH NEXT c_sprefijos INTO tpprefijo
    LET curr = curr + 1
   END IF
   CALL prefijosgetcurr( tpprefijo )
   CALL prefijosshowcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_sprefijos INTO tpprefijo
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_sprefijos INTO tpprefijo
    LET curr = curr - 1
   END IF
   CALL prefijosgetcurr( tpprefijo )
   CALL prefijosshowcurr( curr, maxnum )
  COMMAND "Modifica" "Modifica el registro  en consulta"
   LET mcodmen="FC05"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF gaprefijos.prefijo IS NULL THEN
      CONTINUE MENU
    ELSE
      CLOSE c_sprefijos
      CALL prefijosupdate()
      IF gerrflag THEN
       EXIT MENU
      END IF
      IF int_flag THEN
       LET int_flag = FALSE
      END IF
      CALL prefijosgetcurr( tpprefijo)
      CALL prefijosshowcurr( curr, maxnum )
      OPEN c_sprefijos
    END IF
  END IF
  COMMAND "Borra" "Borra el registro en consulta"
   LET mcodmen="FC06"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF gaprefijos.prefijo IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sprefijos
     CALL prefijosremove()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CALL prefijosshowcurr( curr, maxnum )
     END IF
     OPEN c_sprefijos
    END IF
   END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF gaprefijos.prefijo IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sprefijos
 RETURN exist
END FUNCTION

FUNCTION rep_prefijos()
--DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
let nomrep=fgl_getenv("HOME"),"/reportes/prefijos"
let nomrep=nomrep CLIPPED
start report rprefijos to nomrep
--LET handler = configureOutputt("PDF","28cm","22cm",17,"1.5cm")
--START REPORT rprefijos TO XML HANDLER HANDLER
initialize mfc_prefijos.* to null
declare ppre cursor for
select * from fc_prefijos order by prefijo
foreach ppre into mfc_prefijos.*
 output to report rprefijos()
end foreach
finish report rprefijos
call impsn(nomrep)  --esta en fc_factura
END FUNCTION
REPORT rprefijos()
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
       column 151,"Pag No. ",pageno using "####"
 skip 1 LINES
 let mp1 = (160-length(mfc_empresa.razsoc clipped))/2
 print column mp1,mfc_empresa.razsoc
 let mp1 = (160-length("LISTADO GENERAL DE PREFIJOS"))/2
 print column mp1,"LISTADO GENERAL DE PREFIJOS"

 skip 1 lines
 print "---------------------------------------------------------------",
       "---------------------------------------------------------------",
       "----------------------------------"
 print  column 01,"PREF",
        column 12,"DESCRIPCION",
        column 55,"NUMINI",
        column 65,"NUMFIN",
        column 75,"NUMERO",
        column 97,"DIRECCION",
        column 130,"FEC_VENC"
 print "---------------------------------------------------------------",
       "---------------------------------------------------------------",
       "----------------------------------"
 skip 1 lines
 on every row
 print  column 01,mfc_prefijos.prefijo,
        column 6,mfc_prefijos.descripcion,
        column 54,mfc_prefijos.numini USING "-------&",
        column 64,mfc_prefijos.numfin USING "-------&",
        column 74,mfc_prefijos.numero USING "-------&",
        column 85,mfc_prefijos.direccion,
        COLUMN 130, mfc_prefijos.fec_ven
  on last ROW       
   skip to top of page
end report
