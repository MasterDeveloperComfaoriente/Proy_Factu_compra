GLOBALS "fc_globales.4gl" 
DEFINE tpfe_datos_ips,gfe_datos_ips RECORD
  prefijo            LIKE fe_datos_ips.prefijo,
  documento          LIKE fe_datos_ips.documento,
  codprestador       LIKE fe_datos_ips.codprestador,
  tipdoc_usuario     LIKE fe_datos_ips.tipdoc_usuario,
  doc_usuario        LIKE fe_datos_ips.doc_usuario,
  priape_u           LIKE fe_datos_ips.priape_u,
  segape_u           LIKE fe_datos_ips.segape_u,
  prinom_u           LIKE fe_datos_ips.prinom_u,
  segnom_u           LIKE fe_datos_ips.segnom_u,
  tipusu             LIKE fe_datos_ips.tipusu,
  modcontrato        LIKE fe_datos_ips.modcontrato,
  tipcob             LIKE fe_datos_ips.tipcob,
  numauto            LIKE fe_datos_ips.numauto,
  nummipres          LIKE fe_datos_ips.nummipres,
  numcontrato        LIKE fe_datos_ips.numcontrato,
  numpoliza          LIKE fe_datos_ips.numpoliza,
  fecini             LIKE fe_datos_ips.fecini,
  fecfin             LIKE fe_datos_ips.fecfin,
  valcopago          LIKE fe_datos_ips.valcopago,
  valcuotam          LIKE fe_datos_ips.valcuotam,
  valrecup           LIKE fe_datos_ips.valrecup,
  pago_compartido    LIKE fe_datos_ips.pago_compartido
END RECORD 
DEFINE cb_tpdocusu,cb_tpusuario,cb_modct,cb_tipcob ui.combobox 
DEFINE num integer
FUNCTION fe_datos_ipsmain()
 DEFINE exist  SMALLINT
 OPEN WINDOW w_mfe_datos_ips  AT 1,1 WITH FORM "fe_datos_ips"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE tpfe_datos_ips.* TO NULL
   LET  cb_tpdocusu = ui.ComboBox.forName("fe_datos_ips.tipdoc_usuario")
   CALL  cb_tpdocusu.clear()
   CALL  cb_tpdocusu.addItem("CC", "CEDULA CIUDADANIA")
   CALL  cb_tpdocusu.addItem("CE", "CEDULA DE EXTRANJERIA")
   CALL  cb_tpdocusu.addItem("CD", "CARNET DIPLOMATICO")
   CALL  cb_tpdocusu.addItem("PA", "PASAPORTE")
   CALL  cb_tpdocusu.addItem("SC", "SALVOCONDUCTO")
   CALL  cb_tpdocusu.addItem("PE", "PERMISO ESPECIAL DE PERMANENCIA") 
   CALL  cb_tpdocusu.addItem("RC", "REGISTRO CIVIL DE NACIMIENTO") 
   CALL  cb_tpdocusu.addItem("TI", "TARJETA DE IDENTIDAD")
   CALL  cb_tpdocusu.addItem("CN", "CERTIFICADO DE NACIDO VIVO")
   CALL  cb_tpdocusu.addItem("AS", "ADULTO SIN IDENTIFICAR")
   CALL  cb_tpdocusu.addItem("MS", "MENOR SIN IDENTIFICAR")
   CALL  cb_tpdocusu.addItem("DE", "DOCUMENTO EXTRANJERO")
   CALL  cb_tpdocusu.addItem("SI", "SIN IDENTIFICACION")

  LET  cb_tpusuario = ui.ComboBox.forName("fe_datos_ips.tipusu")
   CALL cb_tpusuario.clear()
   CALL cb_tpusuario.addItem("1", "CONTRIBUTIVO COTIZANTE")
   CALL cb_tpusuario.addItem("2", "CONTRIBUTIVO BENEFICIARIO")
   CALL cb_tpusuario.addItem("3", "CONTRIBUYENTE ADICIONAL")
   CALL cb_tpusuario.addItem("4", "SUBSIDIADO")
   CALL cb_tpusuario.addItem("5", "SIN REGIMEN")
   CALL cb_tpusuario.addItem("6", "ESPECIALES O DE EXCEPCION COTIZANTE")
   CALL cb_tpusuario.addItem("7", "ESPECIALES O DE EXCEPCION BENEFICIARIO")
   CALL cb_tpusuario.addItem("8", "PARTICULAR")
   CALL cb_tpusuario.addItem("9", "TOMADOR/AMPARADO ARL")
   CALL cb_tpusuario.addItem("10", "TOMADOR/AMPARADO SOAT")
   CALL cb_tpusuario.addItem("11", "TOMADOR/AMPARADO PLANES VOLUNTARIO DE SALUD")

  LET  cb_modct = ui.ComboBox.forName("fe_datos_ips.modcontrato")
   CALL cb_modct.clear()
   CALL cb_modct.addItem("1", "PAQUETE/CANASTA/CONJUNTO INTG. SLAUD")
   CALL cb_modct.addItem("2", "GRUPOS RELAC. POR DIAGNOSTICO")
   CALL cb_modct.addItem("3", "INTEGRAL POR GRUPO DE RIESGO")
   CALL cb_modct.addItem("4", "PAGO POR CONTACTO POR ESPECIALIDAD")
   CALL cb_modct.addItem("5", "PAGO POR ESCENARIO DE ATENCION")
   CALL cb_modct.addItem("6", "PAGO POR TIPO DE SERVICIO")
   CALL cb_modct.addItem("7", "PAGO GLOBAL PROSPECTIVO POR EPISODIO")
   CALL cb_modct.addItem("8", "PAGO GLOBAL PROSPECTIVO POR GRUPO DE RIESGO")
   CALL cb_modct.addItem("9", "PAGO GLOBAL PROSPECTIVO POR ESPECIALIDAD")
   CALL cb_modct.addItem("10", "PAGO GLOBAL PROSPECTIVO POR NIVEL DE COMPLEJIDAD")
   CALL cb_modct.addItem("11", "CAPITACION")
   CALL cb_modct.addItem("12", "POR SERVICIO")

   
  LET  cb_tipcob = ui.ComboBox.forName("fe_datos_ips.tipcob")
   CALL cb_tipcob.clear()
      CALL cb_tipcob.addItem("01","PLAN DE BENEFICIOS EN SALUD  FINANCIADO CON UPC")
     CALL cb_tipcob.addItem("02","PRESUPUESTO MÀXIMO")
     CALL cb_tipcob.addItem("03","PRIMA EPS/EOC, NO ASEGURADOS SOAT")
     CALL cb_tipcob.addItem("04","COBERTURA POLIZA SOAT")
     CALL cb_tipcob.addItem("05","COBERTURA ARL")
     CALL cb_tipcob.addItem("06","COBERTURA ADRES")
     CALL cb_tipcob.addItem("07","COBERTURA SALUD PUBLICA")
     CALL cb_tipcob.addItem("08","COBERTURA ENTIDAD TERRITORIAL, RECURSOS DE OFERTA")
     CALL cb_tipcob.addItem("09","URGENCIAS POBLACION MIGRANTE")
     CALL cb_tipcob.addItem("10"," PLAN COMPLEMENTARIO EN SALUD")   
     CALL cb_tipcob.addItem("11","PLAN MEDICINA PREPAGADA")
     CALL cb_tipcob.addItem("12","OTRAS POLIZAS EN SALUD")
     CALL cb_tipcob.addItem("13","COBERTURA REGIMEN ESPECIAL O EXCEPCION")
     CALL cb_tipcob.addItem("14","COBERTURA FONDO NAC. DE SALUD DE LAS PERSONAS PRIVADAS DE LA LIBERTAD")
     CALL cb_tipcob.addItem("15","PARTICULAR")

 
 SELECT COUNT(*) INTO num  FROM fe_datos_ips
 WHERE prefijo= tpfc_factura_m.prefijo AND documento = tpfc_factura_m.documento
display"num:   ",num
 IF num<>'0' THEN
  call cargar_datos()
  ELSE 
  CALL fe_datos_ipsadd()
  END IF
 CLOSE WINDOW w_mfe_datos_ips 
END FUNCTION

FUNCTION fe_datos_ipsdplyg()
DISPLAY BY NAME gfe_datos_ips. prefijo THRU gfe_datos_ips.pago_compartido
END FUNCTION


FUNCTION fe_datos_ipsadd()
 DEFINE control SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 MESSAGE "ESTADO: ADICIONANDO REGISTROS"  ATTRIBUTE(BLUE)
 INITIALIZE tpfe_datos_ips.* TO NULL
lABEL Ent_datosips:
 INPUT BY NAME tpfe_datos_ips.documento THRU tpfe_datos_ips.pago_compartido WITHOUT DEFAULTS
  BEFORE INPUT
    LET tpfe_datos_ips.prefijo= tpfc_factura_m.prefijo
    DISPLAY tpfe_datos_ips.prefijo TO prefijo
 
 AFTER FIELD documento 
  LET tpfe_datos_ips.documento= tpfc_factura_m.documento
  DISPLAY "documento3:   ",tpfe_datos_ips.documento
   DISPLAY tpfe_datos_ips.documento TO documento
   IF tpfe_datos_ips.documento IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El documento no puede estar vacio ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD documento
  END IF

  AFTER FIELD codprestador
    IF tpfe_datos_ips.codprestador IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El Cod. Prestador del Servicio de Salud No fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD codprestador
    END IF
 AFTER FIELD tipdoc_usuario
   IF tpfe_datos_ips.tipdoc_usuario IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Tipo Documento del Usuario No fue Digitado",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD tipdoc_usuario
   END IF
    
 AFTER FIELD doc_usuario
   IF tpfe_datos_ips.doc_usuario IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Documento del Usuario No fue Digitado",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD doc_usuario
   END IF 
AFTER FIELD priape_u
  IF tpfe_datos_ips.priape_u IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Primer Apellido del usuario no fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD priape_u
   END IF
   
 AFTER FIELD segape_u
 { IF tpfe_datos_ips.segape_u IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Segundo Apellido del usuario no fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD segape_u
   END IF}
   
 AFTER FIELD prinom_u
   IF tpfe_datos_ips.prinom_u IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Primer Nombre del usuario no fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD prinom_u
   END IF 

  AFTER FIELD segnom_u 
   { IF tpfe_datos_ips.segnom_u IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Segundo Nombre del usuario no fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD segnom_u
    END IF }
   
 AFTER FIELD tipusu
   IF tpfe_datos_ips.tipusu IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El tipo de Usuario No fue Digitado",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD tipusu
   END IF

  AFTER FIELD modcontrato
   IF tpfe_datos_ips.modcontrato IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La Modalidad de contratacion No fue seleccionada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD modcontrato
   END IF
  
 AFTER FIELD tipcob
    IF tpfe_datos_ips.tipcob IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= " El Tipo de Cobro No fue Registrado",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD tipcob
    END IF

 AFTER FIELD numauto
    IF tpfe_datos_ips.numauto IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Número de Autorización  No fue difgitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numauto
   END IF
   
   AFTER FIELD nummipres
    IF tpfe_datos_ips.nummipres IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Numero de mi Preescripcion No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nummipres
   END IF 
 
   AFTER FIELD numcontrato
    IF tpfe_datos_ips.numcontrato IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Número de Contrato no fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numcontrato
   END IF 
 

    AFTER FIELD numpoliza 
    IF tpfe_datos_ips.numpoliza  IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Número de la Póliza no fue Registrado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numpoliza 
   END IF

 AFTER FIELD fecini 
    IF tpfe_datos_ips.fecini IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La Fecha de Inicio no fue digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD fecini  
   END IF

    AFTER FIELD fecfin
    IF tpfe_datos_ips.fecfin IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "la Fecha Final no fue digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD fecfin  
   END IF

    AFTER FIELD valcopago 
    IF tpfe_datos_ips.valcopago IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Valor del Copago no fue Registrado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD valcopago   
   END IF

    AFTER FIELD valcuotam 
    IF tpfe_datos_ips.valcuotam IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Valor de la cuota moderadora no fue digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD valcuotam   
   END IF

    AFTER FIELD valrecup  
    IF tpfe_datos_ips.valrecup  IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El valor de la cuota de recuperación no fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD valrecup   
   END IF

    AFTER FIELD pago_compartido 
    IF tpfe_datos_ips.pago_compartido IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Pago Compartido no fueron digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD pago_compartido 
   END IF 
  AFTER INPUT
   IF int_flag THEN
      EXIT INPUT
   ELSE
    --  IF tpfe_datos_ips.prefijo IS NULL OR  tpfe_datos_ips.documento IS NULL OR
      IF tpfe_datos_ips.codprestador IS NULL 
      OR tpfe_datos_ips.doc_usuario IS NULL  OR tpfe_datos_ips.priape_u IS NULL  OR tpfe_datos_ips.prinom_u IS NULL
     -- OR tpfe_datos_ips.segnom_u IS NULL 
      OR tpfe_datos_ips.tipusu IS NULL OR tpfe_datos_ips.modcontrato IS NULL 
      OR tpfe_datos_ips.tipcob IS NULL OR tpfe_datos_ips.numauto IS NULL OR tpfe_datos_ips.nummipres IS NULL
      OR tpfe_datos_ips.numcontrato IS NULL OR tpfe_datos_ips.numpoliza IS NULL OR tpfe_datos_ips.fecini IS NULL 
      OR tpfe_datos_ips.fecfin IS NULL OR tpfe_datos_ips.valcopago IS NULL OR tpfe_datos_ips.valcuotam IS NULL
      OR tpfe_datos_ips.valrecup IS NULL OR tpfe_datos_ips.pago_compartido IS NULL then
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
        comment= "Hay campos vacios, debe completarlos ", image= "exclamation")
         COMMAND "Aceptar"
          EXIT MENU
      END MENU
        GO TO Ent_datosips
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
    INITIALIZE tpfe_datos_ips.* TO NULL
  RETURN
 END IF
 MESSAGE "ADICIONANDO INFORMACION"  ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 if tpfe_datos_ips.documento is not null then 
 INSERT INTO fe_datos_ips ( prefijo,documento,codprestador,tipdoc_usuario,doc_usuario,priape_u,segape_u,prinom_u,segnom_u,tipusu,
            modcontrato,tipcob,numauto,nummipres,numcontrato,numpoliza , fecini , fecfin,valcopago , valcuotam ,valrecup ,pago_compartido)
   VALUES (tpfe_datos_ips.prefijo,tpfe_datos_ips.documento,tpfe_datos_ips.codprestador,tpfe_datos_ips.tipdoc_usuario,tpfe_datos_ips.doc_usuario,tpfe_datos_ips.priape_u,tpfe_datos_ips.segape_u,
   tpfe_datos_ips.prinom_u,tpfe_datos_ips.segnom_u,tpfe_datos_ips.tipusu,
    tpfe_datos_ips.modcontrato,tpfe_datos_ips.tipcob,tpfe_datos_ips.numauto,tpfe_datos_ips.nummipres,tpfe_datos_ips.numcontrato,
    tpfe_datos_ips.numpoliza , tpfe_datos_ips.fecini , tpfe_datos_ips.fecfin,           
    tpfe_datos_ips.valcopago , tpfe_datos_ips.valcuotam , tpfe_datos_ips.valrecup , tpfe_datos_ips.pago_compartido)
   if sqlca.sqlcode <> 0 then    
     MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
                               comment= " NO SE ADICIONO.. REGISTRO REFERENCIADO     "  ,
                               image= "stop")
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
  LET gfe_datos_ips.* = tpfe_datos_ips.*
  INITIALIZE tpfe_datos_ips.* TO NULL
 MENU "Información"  ATTRIBUTE( style= "dialog", 
                   comment= " La información fue Adicionada...  "  ,
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



FUNCTION fe_datos_ipsupdate()
 DEFINE mnumero LIKE fe_datos_ips.documento
 DEFINE cnt,control SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION "  ATTRIBUTE(BLUE)
 LET tpfe_datos_ips.* = gfe_datos_ips.*
 INPUT BY NAME  tpfe_datos_ips.documento THRU tpfe_datos_ips.pago_compartido  WITHOUT DEFAULTS
BEFORE INPUT
 LET gfe_datos_ips.prefijo= tpfc_factura_m.prefijo
 LET gfe_datos_ips.documento=tpfc_factura_m.documento
 DISPLAY gfe_datos_ips.prefijo TO prefijo
 DISPLAY gfe_datos_ips.documento TO documento
 AFTER FIELD documento 
   IF tpfe_datos_ips.documento IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El documento no puede estar vacio ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD documento
  END IF

  AFTER FIELD codprestador
    IF tpfe_datos_ips.codprestador IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El Cod. Prestador del Servicio de Salud No fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD codprestador
    END IF
 AFTER FIELD tipdoc_usuario
   IF tpfe_datos_ips.tipdoc_usuario IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Tipo Documento del Usuario No fue Digitado",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD tipdoc_usuario
   END IF
    
 AFTER FIELD doc_usuario
   IF tpfe_datos_ips.doc_usuario IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Documento del Usuario No fue Digitado",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD doc_usuario
   END IF 
AFTER FIELD priape_u
  IF tpfe_datos_ips.priape_u IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Primer Apellido del usuario no fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD priape_u
   END IF
   
 AFTER FIELD segape_u
 { IF tpfe_datos_ips.segape_u IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Segundo Apellido del usuario no fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD segape_u
   END IF}
   
 AFTER FIELD prinom_u
   IF tpfe_datos_ips.prinom_u IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Primer Nombre del usuario no fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD prinom_u
   END IF 

  AFTER FIELD segnom_u 
  {  IF tpfe_datos_ips.segnom_u IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Segundo Nombre del usuario no fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD segnom_u
    END IF }
   
 AFTER FIELD tipusu
   IF tpfe_datos_ips.tipusu IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El tipo de Usuario No fue Digitado",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD tipusu
   END IF

  AFTER FIELD modcontrato
   IF tpfe_datos_ips.modcontrato IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La Modalidad de contratacion No fue seleccionada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD modcontrato
   END IF
  
 AFTER FIELD tipcob
    IF tpfe_datos_ips.tipcob IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= " El Tipo de Cobro No fue Registrado",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD tipcob
    END IF

 AFTER FIELD numauto
    IF tpfe_datos_ips.numauto IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Número de Autorización  No fue difgitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numauto
   END IF
   
   AFTER FIELD nummipres
    IF tpfe_datos_ips.nummipres IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Numero de mi Preescripcion No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nummipres
   END IF 
 
   AFTER FIELD numcontrato
    IF tpfe_datos_ips.numcontrato IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Número de Contrato no fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numcontrato
   END IF 
 

    AFTER FIELD numpoliza 
    IF tpfe_datos_ips.numpoliza  IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Número de la Póliza no fue Registrado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numpoliza 
   END IF

 AFTER FIELD fecini 
    IF tpfe_datos_ips.fecini IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La Fecha de Inicio no fue digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD fecini  
   END IF

    AFTER FIELD fecfin
    IF tpfe_datos_ips.fecfin IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "la Fecha Final no fue digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD fecfin  
   END IF

    AFTER FIELD valcopago 
    IF tpfe_datos_ips.valcopago IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Valor del Copago no fue Registrado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD valcopago   
   END IF

    AFTER FIELD valcuotam 
    IF tpfe_datos_ips.valcuotam IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Valor de la cuota moderadora no fue digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD valcuotam   
   END IF

    AFTER FIELD valrecup  
    IF tpfe_datos_ips.valrecup  IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El valor de la cuota de recuperación no fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD valrecup   
   END IF

    AFTER FIELD pago_compartido 
    IF tpfe_datos_ips.pago_compartido IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Pago Compartido no fueron digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD pago_compartido 
   END IF 
   AFTER INPUT
   IF int_flag THEN
      EXIT INPUT
   END IF
   END INPUT
 MESSAGE "" 
 IF int_flag THEN
  CLEAR FORM
  MENU "Información"  ATTRIBUTE( style= "dialog", 
                             comment= " La modificación fue cancelada      "  ,
                             image= "information")
       COMMAND "Aceptar"
         EXIT MENU
  END MENU
  INITIALIZE tpfe_datos_ips.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION " AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
-- display"prefijo1: ",tpfe_datos_ips.prefijo
 --display"doc1: ",tpfe_datos_ips.documento
-- display"codprestador: ",tpfe_datos_ips.codprestador
 
 UPDATE  fe_datos_ips
 SET ( prefijo,documento,codprestador,tipdoc_usuario,doc_usuario,priape_u,segape_u,prinom_u,segnom_u,tipusu,modcontrato,tipcob,numauto,nummipres,numcontrato,
    numpoliza , fecini , fecfin,valcopago , valcuotam ,valrecup ,pago_compartido) 
    =(tpfe_datos_ips.prefijo,tpfe_datos_ips.documento,tpfe_datos_ips.codprestador,tpfe_datos_ips.tipdoc_usuario,tpfe_datos_ips.doc_usuario,tpfe_datos_ips.priape_u,
    tpfe_datos_ips.segape_u,tpfe_datos_ips.prinom_u,tpfe_datos_ips.segnom_u,tpfe_datos_ips.tipusu,
    tpfe_datos_ips.modcontrato,tpfe_datos_ips.tipcob,tpfe_datos_ips.numauto,tpfe_datos_ips.nummipres,tpfe_datos_ips.numcontrato,
    tpfe_datos_ips.numpoliza, tpfe_datos_ips.fecini , tpfe_datos_ips.fecfin,           
    tpfe_datos_ips.valcopago , tpfe_datos_ips.valcuotam , tpfe_datos_ips.valrecup , tpfe_datos_ips.pago_compartido) 
 WHERE prefijo=gfe_datos_ips.prefijo  AND  documento=gfe_datos_ips.documento  
 
 IF status <> 0 THEN
  MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
                             comment= " No se modificó.. Registro referenciado     "  , 
                             image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  LET gerrflag = TRUE
 END IF
 IF NOT gerrflag THEN 
 MENU "Información"  ATTRIBUTE( style= "dialog", 
                             comment= " La modificación fue realizada",
                             image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   COMMIT WORK
 ELSE
  MENU "Información"  ATTRIBUTE( style= "dialog", 
                             comment= " La modificación fue cancelada   "  ,
                             image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   ROLLBACK WORK
 END IF
 IF NOT gerrflag THEN 
  LET gfe_datos_ips.* = tpfe_datos_ips.*
 END IF
END FUNCTION 


FUNCTION cargar_datos()
  DEFINE tpprefijo   LIKE fe_datos_ips.prefijo
  DEFINE tpdocumento LIKE fe_datos_ips.documento
 LET tpprefijo =tpfc_factura_m.prefijo
 LET tpdocumento= tpfc_factura_m.documento
  INITIALIZE gfe_datos_ips.* TO NULL
  SELECT fe_datos_ips.prefijo,fe_datos_ips.documento,fe_datos_ips.codprestador,fe_datos_ips.tipdoc_usuario,fe_datos_ips.doc_usuario,
  fe_datos_ips.priape_u, fe_datos_ips.segape_u,fe_datos_ips.prinom_u,fe_datos_ips.segnom_u,fe_datos_ips.tipusu,fe_datos_ips.modcontrato,
  fe_datos_ips.tipcob,fe_datos_ips.numauto,fe_datos_ips.nummipres,fe_datos_ips.numcontrato,
  fe_datos_ips.numpoliza,fe_datos_ips.fecini,fe_datos_ips.fecfin,fe_datos_ips.valcopago,fe_datos_ips.valcuotam,fe_datos_ips.valrecup,fe_datos_ips.pago_compartido
   INTO gfe_datos_ips.* 
   FROM fe_datos_ips
   WHERE fe_datos_ips.prefijo = tpprefijo AND
         fe_datos_ips.documento=tpdocumento

 LET tpfe_datos_ips.codprestador= gfe_datos_ips.codprestador
 LET tpfe_datos_ips.tipdoc_usuario =gfe_datos_ips.tipdoc_usuario
 LET tpfe_datos_ips.doc_usuario = gfe_datos_ips.doc_usuario
 LET tpfe_datos_ips.priape_u = gfe_datos_ips.priape_u
 LET tpfe_datos_ips.segape_u = gfe_datos_ips.segape_u
 LET tpfe_datos_ips.prinom_u = gfe_datos_ips.prinom_u
 LET tpfe_datos_ips.segnom_u = gfe_datos_ips.segnom_u
 LET tpfe_datos_ips.tipusu = gfe_datos_ips.tipusu
 LET tpfe_datos_ips.modcontrato = gfe_datos_ips.modcontrato
 LET tpfe_datos_ips.tipcob =gfe_datos_ips.tipcob
 LET tpfe_datos_ips.numauto = gfe_datos_ips.numauto
 LET tpfe_datos_ips.nummipres = gfe_datos_ips.nummipres
 LET tpfe_datos_ips.numcontrato = gfe_datos_ips.numcontrato
 LET tpfe_datos_ips.numpoliza = gfe_datos_ips.numpoliza
 LET tpfe_datos_ips.fecini = gfe_datos_ips.fecini
 LET tpfe_datos_ips.fecfin = gfe_datos_ips.fecfin
 LET tpfe_datos_ips.valcopago=gfe_datos_ips.valcopago
 LET tpfe_datos_ips.valcuotam =  gfe_datos_ips.valcuotam
 LET tpfe_datos_ips.valrecup = gfe_datos_ips.valrecup
 LET tpfe_datos_ips.pago_compartido = gfe_datos_ips.pago_compartido
 DISPLAY "codprestador:   ",gfe_datos_ips.codprestador
 
 DISPLAY gfe_datos_ips.prefijo TO prefijo
 DISPLAY gfe_datos_ips.documento TO documento
 DISPLAY tpfe_datos_ips.codprestador TO codprestador
 DISPLAY tpfe_datos_ips.tipdoc_usuario TO tipdoc_usuario
 DISPLAY tpfe_datos_ips.doc_usuario TO doc_usuario
 DISPLAY tpfe_datos_ips.priape_u TO priape_u
 DISPLAY tpfe_datos_ips.segape_u TO segape_u
 DISPLAY tpfe_datos_ips.prinom_u TO prinom_u
 DISPLAY tpfe_datos_ips.segnom_u TO segnom_u
 DISPLAY tpfe_datos_ips.tipusu TO tipusu
 DISPLAY tpfe_datos_ips.modcontrato TO modcontrato
 DISPLAY tpfe_datos_ips.tipcob TO tipcob
 DISPLAY tpfe_datos_ips.numauto TO numauto
 DISPLAY tpfe_datos_ips.nummipres TO nummipres
 DISPLAY tpfe_datos_ips.numcontrato TO numcontrato
 DISPLAY tpfe_datos_ips.numpoliza TO numpoliza
 DISPLAY tpfe_datos_ips.fecini TO fecini
 DISPLAY tpfe_datos_ips.fecfin TO fecfin
 DISPLAY tpfe_datos_ips.valcopago TO valcopago
 DISPLAY tpfe_datos_ips.valcuotam TO valcuotam
 DISPLAY tpfe_datos_ips.valrecup TO valrecup
 DISPLAY tpfe_datos_ips.pago_compartido TO pago_compartido
menu
 ON ACTION bt_mod
 CALL fe_datos_ipsupdate()
   COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END menu

END function

