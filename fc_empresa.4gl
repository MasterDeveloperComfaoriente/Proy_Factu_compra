GLOBALS "fc_globales.4gl"
 DEFINE gemp, tpemp RECORD
  nit                 LIKE fc_empresa.nit,
  digver              LIKE fc_empresa.digver,
  razsoc              LIKE fc_empresa.razsoc,
  gran_contri         LIKE fc_empresa.gran_contri,
  res_gran            LIKE fc_empresa.res_gran,
  fec_gran            LIKE fc_empresa.fec_gran,
  autoret             LIKE fc_empresa.autoret,
  res_autoret         LIKE fc_empresa.res_autoret,
  fec_autoret         LIKE fc_empresa.fec_autoret,
  autoica             LIKE fc_empresa.autoica,
  res_autoica         LIKE fc_empresa.res_autoica,
  fec_autoica         LIKE fc_empresa.fec_autoica,
  codreg              LIKE fc_empresa.codreg,
  regimen             LIKE fc_empresa.regimen,
  moneda              LIKE fc_empresa.moneda,
  numnota_d           LIKE fc_empresa.numnota_d,
  numnota_c           LIKE fc_empresa.numnota_c,
  codcop_notad        LIKE fc_empresa.codcop_notad,
  codcop_notac        LIKE fc_empresa.codcop_notac,
  codcop_notad_eps    LIKE fc_empresa.codcop_notad_eps,
  codcop_notac_eps    LIKE fc_empresa.codcop_notac_eps,
  codcop_notad_epsc   LIKE fc_empresa.codcop_notad_epsc,
  codcop_notac_epsc   LIKE fc_empresa.codcop_notac_epsc,
  codcop_notad_ips    LIKE fc_empresa.codcop_notad_ips,
  codcop_notac_ips    LIKE fc_empresa.codcop_notac_ips,
  codcop_notad_cre    LIKE fc_empresa.codcop_notad_cre,
  codcop_notac_cre    LIKE fc_empresa.codcop_notac_cre,
  leyenda_enc         LIKE fc_empresa.leyenda_enc,
  piepag_1            LIKE fc_empresa.piepag_1,
  piepag_2            LIKE fc_empresa.piepag_2,
  piepag_3            LIKE fc_empresa.piepag_3
END RECORD 
 FUNCTION empmain()
 DEFINE exist  SMALLINT
 DEFINE cb_contri, cb_auto, cb_reg, cb_ica     ui.ComboBox
 OPEN WINDOW w_memp AT 1,1 WITH FORM "fc_empresa"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gemp.* TO NULL
 INITIALIZE tpemp.* TO NULL
 LET cb_contri = ui.ComboBox.forName("fc_empresa.gran_contri")
   CALL cb_contri.clear()
   CALL cb_contri.addItem("S", "SI GRAN CONTRIBUYENTE")
   CALL cb_contri.addItem("N", "NO GRAN CONTRIBUYENTE")
  LET cb_auto = ui.ComboBox.forName("fc_empresa.autoret")
   CALL cb_auto.clear()
   CALL cb_auto.addItem("S", "SI AUTORETENEDOR")
   CALL cb_auto.addItem("N", "NO AUTORETENEDOR")
  LET cb_ica = ui.ComboBox.forName("fc_empresa.autoica")
   CALL cb_ica.clear()
   CALL cb_ica.addItem("S", "SI AUTORETENEDOR")
   CALL cb_ica.addItem("N", "NO AUTORETENEDOR")
 CALL empgetcurr()
 DISPLAY BY NAME gemp.nit THRU gemp.codcop_notac
 MENU 
  COMMAND "Actualiza" "Actualiza el registro de control "
   LET mcodmen="FC01"
   CALL opcion() RETURNING op
   if op="S" THEN
     CALL empupdate()
   END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_memp
END FUNCTION


FUNCTION empupdate()
 DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : ACTUALIZANDO EL REGISTRO DE CONTROL"  ATTRIBUTE(BLUE)
 LET tpemp.* = gemp.*
 INPUT BY NAME tpemp.nit THRU tpemp.piepag_3 WITHOUT DEFAULTS

  AFTER FIELD nit
   IF tpemp.nit IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
          comment= " el nit de la empresa no fue digitado",
                  image= "exclamation")
         COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD nit
   END IF
   let mnit=tpemp.nit
   call digver()
   let tpemp.digver=mdigver
   DISPLAY BY NAME tpemp.digver
   NEXT FIELD digver

 AFTER FIELD digver
   IF tpemp.digver IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
          comment= " El digito de verificacion no fue digitado ",
                  image= "exclamation")
         COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD digver
   END IF 

   
  AFTER FIELD razsoc
   IF tpemp.razsoc IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
          comment= " El nombre de la entidad no fue digitado ",
                  image= "exclamation")
         COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD razsoc
   END IF 
   
 AFTER FIELD gran_contri
  IF tpemp.gran_contri is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " Debe seleccionar si la empresa es Gran Contribuyente o No ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD gran_contri
  END IF

 AFTER FIELD res_gran
  IF tpemp.gran_contri="S" THEN
   IF tpemp.res_gran is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " La Resolucion No fue Digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
    END MENU
    NEXT FIELD res_gran
   END IF
  END if 

 AFTER FIELD fec_gran
  IF tpemp.gran_contri="S" THEN
   IF tpemp.fec_gran is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " La Fecha De Resolucion No fue Digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
     NEXT FIELD fec_gran
    END if 
  END IF

 AFTER FIELD autoret
  IF tpemp.autoret is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " Debe seleccionar si la empresa es AUTORETENEDORA o No ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD autoret
  END IF

 AFTER FIELD res_autoret
  IF tpemp.autoret="S" THEN
   IF tpemp.res_autoret is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " La Resolucion No fue Digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
    END MENU
    NEXT FIELD res_autoret
   END IF
  END if 

 AFTER FIELD fec_autoret
  IF tpemp.autoret="S" THEN
   IF tpemp.fec_autoret is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " La Fecha De Resolucion No fue Digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
     NEXT FIELD fec_autoret
    END if 
  END IF

 AFTER FIELD autoica
  IF tpemp.autoica is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " Debe seleccionar si la empresa es AUTORETENEDORA o No ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD autoica
  END IF

 AFTER FIELD res_autoica
  IF tpemp.autoica="S" THEN
   IF tpemp.res_autoica is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " La Resolucion No fue Digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
    END MENU
    NEXT FIELD res_autoica
   END IF
  END if 

 AFTER FIELD fec_autoica
  IF tpemp.autoica="S" THEN
   IF tpemp.fec_autoica is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " La Fecha De Resolucion No fue Digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
     NEXT FIELD fec_autoica
    END if 
  END IF
  
 AFTER FIELD codreg
  IF tpemp.codreg is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " Debe ingresar el codigo del  Regimen de la empresa ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD codreg
  END IF
 
 AFTER FIELD regimen
  IF tpemp.regimen is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " Debe seleccionar el Regimen de la empresa ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD regimen
  END IF

 AFTER FIELD moneda
  IF tpemp.moneda is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " Debe seleccionar la Moneda ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD moneda
  ELSE  
    INITIALIZE  mfc_moneda.* TO NULL 
    SELECT * into mfc_moneda.*  FROM fe_moneda
    WHERE moneda = tpemp.moneda
    if mfc_moneda.moneda is null then
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
          comment= " El codigo de la moneda no existe ", image= "exclamation")
         COMMAND "Aceptar"
        EXIT MENU
     END MENU
     LET tpemp.moneda = NULL 
     display BY NAME tpemp.moneda
     NEXT FIELD moneda
    end IF 
  END IF

 AFTER FIELD numnota_d
  IF tpemp.numnota_d is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " Debe Digitar el Consecutivo Aprobado por la Dian Para la Nota Debito ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numnota_d
  END IF

AFTER FIELD numnota_c
  IF tpemp.numnota_c is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " Debe Digitar el Consecutivo Aprobado por la Dian Para la Nota Credito ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD numnota_c
  END IF

  AFTER FIELD codcop_notad
   IF tpemp.codcop_notad IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo del Comprobante no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codcop_notad
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpemp.codcop_notad 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpemp.codcop_notad TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_notad
    END IF 
   END IF
 
  AFTER FIELD codcop_notac
   IF tpemp.codcop_notac IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo del Comprobante no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codcop_notac
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpemp.codcop_notac 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpemp.codcop_notac TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_notac
    END IF 
   END IF

    AFTER FIELD codcop_notad_eps
   IF tpemp.codcop_notad_eps IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo del Comprobante de la EPS Subsidiado no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codcop_notad_eps
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpemp.codcop_notad_eps
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpemp.codcop_notad_eps TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_notad_eps
    END IF 
   END IF
 
  AFTER FIELD codcop_notac_eps
   IF tpemp.codcop_notac_eps IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo del Comprobante de la EPS Subsidiado no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codcop_notac_eps
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpemp.codcop_notac_eps 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpemp.codcop_notac_eps TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_notac_eps
    END IF 
   END IF

  AFTER FIELD codcop_notad_epsc
   IF tpemp.codcop_notad_epsc IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo del Comprobante de la EPS Contributivo no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codcop_notad_epsc
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpemp.codcop_notad_epsc
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpemp.codcop_notad_epsc TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_notad_epsc
    END IF 
   END IF
 
  AFTER FIELD codcop_notac_epsc
   IF tpemp.codcop_notac_epsc IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo del Comprobante de la EPS Contributivo no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codcop_notac_epsc
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpemp.codcop_notac_epsc 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpemp.codcop_notac_epsc TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_notac_epsc
    END IF 
   END IF
   
  AFTER FIELD codcop_notad_ips
   IF tpemp.codcop_notad_ips IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo del Comprobante de la IPS no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codcop_notad_ips
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpemp.codcop_notad_ips
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpemp.codcop_notad_ips TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_notad_ips
    END IF 
   END IF
 
  AFTER FIELD codcop_notac_ips
   IF tpemp.codcop_notac_ips IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo del Comprobante de la IPS no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codcop_notac_ips
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpemp.codcop_notac_ips 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpemp.codcop_notac_ips TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_notac_ips
    END IF 
   END IF

  AFTER FIELD codcop_notad_cre
   IF tpemp.codcop_notad_cre IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo del Comprobante en Creditos no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codcop_notad_cre
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpemp.codcop_notad_cre
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpemp.codcop_notad_cre TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_notad_cre
    END IF 
   END IF
 
  AFTER FIELD codcop_notac_cre
   IF tpemp.codcop_notac_cre IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Codigo del Comprobante en Creditos no fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
    NEXT FIELD codcop_notac_cre
   ELSE
    INITIALIZE mniif148.* TO NULL
    SELECT * INTO mniif148.* FROM niif148
     WHERE niif148.codcop=tpemp.codcop_notac_cre 
    IF mniif148.codcop IS NULL THEN
	 CALL FGL_WINMESSAGE( "Administrador", "EL CODIGO DEL COMPROBANTE NO EXISTE", "stop")
     INITIALIZE tpemp.codcop_notac_cre TO NULL
     INITIALIZE mniif148.* TO NULL
     next field codcop_notac_cre
    END IF 
   END IF 
 AFTER FIELD leyenda_enc
  IF tpemp.leyenda_enc is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " Debe registrar la Leyenda del Encabezado",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD leyenda_enc
  END IF
AFTER FIELD piepag_1
  IF tpemp.piepag_1 is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El pie de pagina de factura no fue registrado",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD piepag_1
  END IF

  AFTER FIELD piepag_2
  IF tpemp.piepag_2 is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El pie de pagina de factura no fue registrado",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD piepag_2
  END IF
  
AFTER FIELD piepag_3
  IF tpemp.piepag_3 is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El pie de pagina de factura no fue registrado",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD piepag_3
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
     comment= " La actualizacion fue cancelada "  , image= "information")
       COMMAND "Aceptar"
         EXIT MENU
  END MENU
  INITIALIZE tpemp.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION DE LA EMPRESA" AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 LET cnt = 0
 select count(*) INTO cnt FROM fc_empresa
 if cnt is null or cnt = 0 then
   INSERT INTO fc_empresa
   values (tpemp.*)
   IF status <> 0 THEN
    MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
     comment= " No se Adiciono.. Registro referenciado  "  , image= "stop")
        COMMAND "Aceptar"
          EXIT MENU
      END MENU
    LET  gerrflag = TRUE
   END IF 
 else
   UPDATE fc_empresa
   SET (nit, digver, razsoc, gran_contri, res_gran, fec_gran, 
     autoret, res_autoret, fec_autoret, autoica, res_autoica, fec_autoica,codreg, regimen, moneda, numnota_d, numnota_c, codcop_notad, codcop_notac,
      codcop_notad_eps, codcop_notac_eps, codcop_notad_ips,codcop_notac_ips,codcop_notad_epsc, codcop_notac_epsc,codcop_notad_cre, codcop_notac_cre,leyenda_enc,piepag_1,piepag_2,piepag_3)
   = (tpemp.nit, tpemp.digver, tpemp.razsoc, tpemp.gran_contri, tpemp.res_gran, tpemp.fec_gran, 
     tpemp.autoret, tpemp.res_autoret, tpemp.fec_autoret,
     tpemp.autoica, tpemp.res_autoica, tpemp.fec_autoica,
     tpemp.codreg, tpemp.regimen, tpemp.moneda, tpemp.numnota_d, tpemp.numnota_c, tpemp.codcop_notad, tpemp.codcop_notac,
     tpemp.codcop_notad_eps, tpemp.codcop_notac_eps, tpemp.codcop_notad_ips, tpemp.codcop_notac_ips,
     tpemp.codcop_notad_epsc, tpemp.codcop_notac_epsc, tpemp.codcop_notad_cre, tpemp.codcop_notac_cre,
     tpemp.leyenda_enc,tpemp.piepag_1,tpemp.piepag_2,tpemp.piepag_3)
  IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
    comment= " No se modificó.. Registro referenciado  "  , image= "stop")
        COMMAND "Aceptar"
          EXIT MENU
      END MENU
   LET  gerrflag = TRUE
  END IF
END IF  
 IF NOT gerrflag THEN 
 MENU "Información"  ATTRIBUTE( style= "dialog", 
        comment= " La actualizacion fue realizada", image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   COMMIT WORK
 ELSE
  MENU "Información"  ATTRIBUTE( style= "dialog", 
   comment= " La actualizacion fue cancelada   "  , image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   ROLLBACK WORK
 END IF
 IF NOT gerrflag THEN 
  LET gemp.* = tpemp.*
 END IF
END FUNCTION  

FUNCTION empgetcurr( )
  INITIALIZE gemp.* TO NULL
  SELECT *  INTO gemp.*  FROM fc_empresa
END FUNCTION


FUNCTION digver()
DEFINE mi ARRAY[14] OF integer
define a char(1)
define l,i,j,y,s integer
# ASIGNACION DE LOS NUMEROS PRIMOS
let mi[1]=3
let mi[2]=7
let mi[3]=13
let mi[4]=17
let mi[5]=19
let mi[6]=23
let mi[7]=29
let mi[8]=37
let mi[9]=41
let mi[10]=43
let mi[11]=47
let mi[12]=53
let mi[13]=59
let mi[14]=67
let mnit = corregir_nit(mnit)
for i=1 to 14
 let a=mnit[i,i]
 if a =" " or a is null then
   exit for
 end if
end for
LET i = i-1
LET s = 0
LET j= 1
FOR l=i TO 1 step -1
  let a=mnit[l,l]
  LET s = s + (mi[j] * a)
  LET j= j + 1
END FOR
let i=s/11
let y=s-(i*11)
case
 when y=0
  let mdigver=0
 when y=1
  let mdigver=1
 otherwise
  let mdigver=11-y
end case
END FUNCTION

FUNCTION corregir_nit(mnit)
  DEFINE mnit char(14)
  FOR i = 1 TO 13
   IF mnit[i,i] = "-" THEN
     EXIT FOR
   END IF
  END FOR
LET mnit = mnit[1,i-1]
RETURN mnit
END FUNCTION





