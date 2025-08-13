GLOBALS "fc_globales.4gl"
DEFINE mrazsoc char(35)
DEFINE mregimen char(1)
DEFINE mdetexp char(10)
DEFINE rec_proveedores_t, g_proveedores_t RECORD 
    tipid LIKE fc_terceros.tipid,
    nit LIKE fc_terceros.nit,
    digver LIKE fc_terceros.digver,
    tipo_persona LIKE fc_terceros.tipo_persona,
    regimen  LIKE fc_terceros.regimen,
    razsoc LIKE fc_terceros.razsoc,
    primer_apellido LIKE fc_terceros.primer_apellido,
    segundo_apellido LIKE fc_terceros.segundo_apellido,
    primer_nombre LIKE fc_terceros.primer_nombre,
    segundo_nombre LIKE fc_terceros.segundo_nombre,
    direccion LIKE fc_terceros.direccion,
    telefono LIKE fc_terceros.telefono,
    celular LIKE fc_terceros.celular,
    zona LIKE fc_terceros.zona,
    pais LIKE fc_terceros.pais,
    medio_recep LIKE fc_terceros.medio_recep,
    email LIKE fc_terceros.email,
    estado LIKE fc_terceros.estado
END RECORD 
DEFINE nitu LIKE fc_terceros.nit
DEFINE detciu CHAR (1)
DEFINE detpais CHAR (1)
    

FUNCTION tercerosmain()
 DEFINE exist  SMALLINT
 DEFINE mnomfac char(40)
 DEFINE cb_medio, cb_estado, cb_tipid, cb_tipper,  cb_tc       ui.ComboBox
 OPEN WINDOW w_mterceros AT 1,1 WITH FORM "fc_terceros"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE g_proveedores_t.* TO NULL
 INITIALIZE rec_proveedores_t.* TO NULL
   --LET cb_tc = ui.ComboBox.forName("fc_terceros.nit_facturador")
   --CALL cb_tc.clear()
   --DECLARE tc_cur CURSOR FOR
   --Select *  from fe_facturador
   -- ORDER BY razsoc
   --FOREACH tc_cur into mfc_facturador.*
   --   LET mnomfac = mfc_facturador.razsoc
   --   CALL cb_tc.addItem(mfc_facturador.nit, mnomfac)
   --END FOREACH   
   --LENADO DEL COMBO DE TIPOS DE DOCUMENTOS
   LET cb_tipid = ui.ComboBox.forName("fc_terceros.tipid")
   CALL cb_tipid.clear()
   CALL cb_tipid.addItem("11", "REGISTRO CIVIL")
   CALL cb_tipid.addItem("12", "TARJETA IDENTIDAD")
   CALL cb_tipid.addItem("13", "CEDULA CIUDADANIA")
   CALL cb_tipid.addItem("21", "TARJETA EXTRANJERIA")
   CALL cb_tipid.addItem("22", "CEDULA EXTRANJERIA")
   CALL cb_tipid.addItem("31", "NIT")
   CALL cb_tipid.addItem("41", "PASAPORTE")
   CALL cb_tipid.addItem("42", "DOCU.IDEN.EXTRANJERO")
   CALL cb_tipid.addItem("47", "PEP (PERMISO ESPECIAL DE PERMANENCIA)" CLIPPED)
   CALL cb_tipid.addItem("48", "PPT (PERMISO DE PROTECCION TEMPORAL" CLIPPED)
   CALL cb_tipid.addItem("50", "NIT DE OTRO PAÍS")
   CALL cb_tipid.addItem("91", "NUIP")
   LET cb_tipper = ui.ComboBox.forName("fc_terceros.tipo_persona")
   CALL cb_tipper.clear()
   CALL cb_tipper.addItem("1", "JURIDICA")
   CALL cb_tipper.addItem("2", "NATURAL")
   
   LET cb_medio = ui.ComboBox.forName("fc_terceros.medio_recep")
   CALL cb_medio.clear()
   CALL cb_medio.addItem("1", "EMAIL")
   CALL cb_medio.addItem("4", "SIN EMAIL")
   LET cb_estado = ui.ComboBox.forName("fc_terceros.estado")
   CALL cb_estado.clear()
   CALL cb_estado.addItem("A", "ACTIVO")
   CALL cb_estado.addItem("I", "INACTIVO")
  MENU
   COMMAND "Adiciona" "Adiciona la informacion de terceros "
   LET mcodmen="FC24"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL tercerosadd()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
    CALL tercerosdplyg()
  END IF
 COMMAND "Consulta" "Consulta la informacion de un nit"
   LET mcodmen="FC25"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL tercerosquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL tercerosdplyg()
   END IF
  { 
  COMMAND "Modifica" "Modifica el registro de un nit"
    
   LET mcodmen="FC26"
   SELECT fc_terceros.nit INTO nitu FROM fc_terceros WHERE fc_terceros.nit = rec_proveedores_t.nit
   DISPLAY "El nit es:", nitu
   CALL opcion() RETURNING op
   if op="S" THEN
    IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " NO HAY INFORMACION DE UN nit EN CONSULTA ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
           
     END MENU
    ELSE
     CALL tercerosupdate()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
    END IF
    CALL tercerosdplyg()
   END IF}
  {
 
  COMMAND "Borra" "Borra la informacion de un nit "
   LET mcodmen="FC27"
   CALL opcion() RETURNING op
  if op="S" THEN
   IF NOT exist THEN
     MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
           comment=" NO HAY INFORMACION DE UN nit EN CONSULTA     ",   
           image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
   ELSE
     CALL tercerosremove()
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CLEAR FORM
      LET exist = FALSE
     END IF
    END IF
    CALL tercerosdplyg()
   END IF}

  --COMMAND "Obligac/Tribut" "Obligaciones tributarias del Adquiriente"
    --IF NOT exist THEN
     --MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      --comment= " NO HAY INFORMACION DE UN NIT EN CONSULTA ",
        --image= "exclamation")
         --COMMAND "Aceptar"
           --EXIT MENU
       --END MENU
   --ELSE
      --CALL terobligacionmain()
      --IF int_flag THEN
       --LET int_flag = FALSE
      --END IF
      --CLEAR FORM
    --END IF
    --CALL tercerosdplyg()
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mterceros
END FUNCTION

FUNCTION tercerosremove()
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : RETIRO DE INFORMACION DE terceros " ATTRIBUTE(BLUE)
 PROMPT "Esta seguro de borrar el registro (s/n)? " FOR CHAR answer
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO EL REGISTRO " ATTRIBUTE(BLUE)
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  DELETE FROM fc_terceros
    WHERE fc_terceros.nit = g_proveedores_t.nit
    
     IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
   IF NOT gerrflag THEN 
   INITIALIZE g_proveedores_t.* TO NULL
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

FUNCTION tercerosdplyg()
  DEFINE record_proveedores RECORD LIKE fc_terceros.*
  INITIALIZE record_proveedores.* TO NULL 
  SELECT * INTO record_proveedores.* FROM fc_terceros
  WHERE nit = g_proveedores_t.nit

  DISPLAY record_proveedores.tipid TO tipid
  DISPLAY record_proveedores.nit TO nit 
  DISPLAY record_proveedores.digver TO digver
  DISPLAY record_proveedores.tipo_persona TO tipo_persona
  DISPLAY record_proveedores.regimen TO regimen 
  IF record_proveedores.regimen = "0" THEN 
    DISPLAY "NO RESPONS. DE IVA" TO ed_regimen
  ELSE
    DISPLAY "RESPONSABLE DE IVA" TO ed_regimen
  END IF 
  DISPLAY record_proveedores.razsoc TO razsoc
  DISPLAY record_proveedores.primer_apellido TO primer_apellido
  DISPLAY record_proveedores.segundo_apellido TO segundo_apellido
  DISPLAY record_proveedores.primer_nombre TO primer_nombre
  DISPLAY record_proveedores.segundo_nombre TO segundo_nombre
  DISPLAY record_proveedores.direccion TO direccion
  DISPLAY record_proveedores.telefono TO telefono
  DISPLAY record_proveedores.celular TO celular
  DISPLAY record_proveedores.zona TO zona
  DISPLAY record_proveedores.medio_recep TO medio_recep
  DISPLAY record_proveedores.email TO email
  DISPLAY record_proveedores.estado TO estado
 
  INITIALIZE mgener09.* TO NULL
  SELECT * into mgener09.* FROM gener09
  WHERE codzon = record_proveedores.zona
  DISPLAY mgener09.detzon TO detciu
  INITIALIZE mfe_pais.* TO NULL
  SELECT * into mfe_pais.* FROM fe_pais
  WHERE pais = record_proveedores.pais
  DISPLAY mfe_pais.pais TO pais
  DISPLAY mfe_pais.detalle TO detpais
  
END FUNCTION

FUNCTION tercerosadd()
 DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 MESSAGE "ESTADO: ADICION DEL REGISTRO DE UN PROVEEDOR
"  ATTRIBUTE(GREEN)
 INITIALIZE rec_proveedores_t.* TO NULL
lABEL Ent_persona:
 INPUT BY NAME rec_proveedores_t.tipid THRU rec_proveedores_t.estado WITHOUT DEFAULTS

 AFTER FIELD tipid
   IF rec_proveedores_t.tipid IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Tipo de identificacion No fue Digitada ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD tipid
   END IF
   
   IF rec_proveedores_t.tipid="31" THEN
    LET rec_proveedores_t.tipo_persona="1"
    DISPLAY BY NAME rec_proveedores_t.tipo_persona
   END IF 
   
  AFTER FIELD nit
   IF rec_proveedores_t.nit IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El numero de nit no fue digitado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD nit
   END IF
   INITIALIZE mfc_terceros.* TO NULL
   SELECT * into mfc_terceros.* FROM fc_terceros
   WHERE fc_terceros.nit = rec_proveedores_t.nit
   IF mfc_terceros.nit is not null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El nit digitado ya existe ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
     NEXT field nit
     ELSE
     let mnit=rec_proveedores_t.nit
     call digver()
     let rec_proveedores_t.digver=mdigver
     DISPLAY mdigver TO digver
     NEXT FIELD digver
    END IF
----
 
 ------   
 AFTER FIELD digver
 IF rec_proveedores_t.tipid="31" AND rec_proveedores_t.digver IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= "Digite el codigo de verificaion   ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD digver
 END IF

  AFTER FIELD tipo_persona
   IF rec_proveedores_t.tipo_persona IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " El tipo_persona del nit no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD tipo_persona
   ELSE
        IF rec_proveedores_t.tipo_persona = "2" THEN
            IF rec_proveedores_t.regimen IS NULL THEN
                  LET rec_proveedores_t.regimen="0" 
                 DISPLAY rec_proveedores_t.regimen TO regimen
                 DISPLAY "NO RESPONS. DE IVA" TO ed_regimen
                 
            END IF
            NEXT FIELD primer_apellido
        ELSE
            IF rec_proveedores_t.regimen IS NULL THEN
                  LET rec_proveedores_t.regimen="0" 
                 DISPLAY rec_proveedores_t.regimen TO regimen
                 DISPLAY "NO RESPONS. DE IVA" TO ed_regimen
                 NEXT FIELD razsoc  
            END IF
            NEXT FIELD razsoc
        END IF 
        
        
   END IF
 
  BEFORE FIELD regimen
   IF rec_proveedores_t.regimen IS NULL THEN
      LET rec_proveedores_t.regimen="0" 
     DISPLAY rec_proveedores_t.regimen TO regimen
     DISPLAY "NO RESPONS. DE IVA" TO ed_regimen
     NEXT FIELD razsoc  
   END IF

  BEFORE FIELD razsoc
   LET rec_proveedores_t.estado="A"
   DISPLAY BY NAME rec_proveedores_t.estado
   LET rec_proveedores_t.pais="CO"
   DISPLAY BY NAME rec_proveedores_t.pais
   INITIALIZE mfe_pais.* TO NULL
   SELECT * INTO mfe_pais.* FROM fe_pais WHERE fe_pais.pais = rec_proveedores_t.pais
   DISPLAY mfe_pais.detalle TO detpais 

  
   IF rec_proveedores_t.tipo_persona="1" THEN
    INITIALIZE mconta04.* TO NULL
    SELECT * INTO mconta04.* FROM conta04 WHERE nit=rec_proveedores_t.nit
    INITIALIZE msubsi02.* TO NULL
    SELECT * INTO msubsi02.* FROM subsi02 WHERE nit=rec_proveedores_t.nit
    IF mconta04.nit IS NOT NULL THEN
     let rec_proveedores_t.razsoc=mconta04.razsoc
     DISPLAY BY NAME rec_proveedores_t.razsoc
     let rec_proveedores_t.direccion=mconta04.direccion
     DISPLAY BY NAME rec_proveedores_t.direccion
     let rec_proveedores_t.telefono=mconta04.telefono
     DISPLAY BY NAME rec_proveedores_t.telefono
     let rec_proveedores_t.zona=mconta04.codzon
     DISPLAY BY NAME rec_proveedores_t.zona
     let rec_proveedores_t.email=msubsi02.email
     DISPLAY BY NAME rec_proveedores_t.email
    ELSE
     let rec_proveedores_t.razsoc=msubsi02.razsoc
     DISPLAY BY NAME rec_proveedores_t.razsoc
     let rec_proveedores_t.direccion=msubsi02.direccion
     DISPLAY BY NAME rec_proveedores_t.direccion
     let rec_proveedores_t.telefono=msubsi02.telefono
     DISPLAY BY NAME rec_proveedores_t.telefono
     let rec_proveedores_t.zona=msubsi02.codzon
     DISPLAY BY NAME rec_proveedores_t.zona
     let rec_proveedores_t.email=msubsi02.email
     DISPLAY BY NAME rec_proveedores_t.email
    END if 
   ELSE
    INITIALIZE msubsi15.* TO NULL
    SELECT * INTO msubsi15.* FROM subsi15 WHERE cedtra=rec_proveedores_t.nit
    IF msubsi15.cedtra IS NOT NULL THEN 
     let rec_proveedores_t.primer_apellido=msubsi15.priape
     DISPLAY BY NAME rec_proveedores_t.primer_apellido
     let rec_proveedores_t.segundo_apellido=msubsi15.segape
     DISPLAY BY NAME rec_proveedores_t.segundo_apellido
     CALL partir_nombret(msubsi15.nombre)
     LET rec_proveedores_t.primer_nombre=mprinom
     LET rec_proveedores_t.segundo_nombre=msegnom
     DISPLAY BY NAME rec_proveedores_t.primer_nombre
     DISPLAY BY NAME rec_proveedores_t.segundo_nombre
     let rec_proveedores_t.direccion=msubsi15.direccion
     DISPLAY BY NAME rec_proveedores_t.direccion
     let rec_proveedores_t.telefono=msubsi15.telefono
     DISPLAY BY NAME rec_proveedores_t.telefono
     let rec_proveedores_t.zona=msubsi15.codzon
     DISPLAY BY NAME rec_proveedores_t.zona
     let rec_proveedores_t.email=msubsi15.email
     DISPLAY BY NAME rec_proveedores_t.email
     NEXT FIELD primer_apellido
    ELSE
     INITIALIZE msubsi20.* TO NULL
     SELECT * INTO msubsi20.* FROM subsi20 WHERE cedcon=rec_proveedores_t.nit
     IF msubsi20.cedcon IS NOT NULL THEN 
      let rec_proveedores_t.primer_apellido=msubsi20.priape
      DISPLAY BY NAME rec_proveedores_t.primer_apellido
      let rec_proveedores_t.segundo_apellido=msubsi20.segape
      DISPLAY BY NAME rec_proveedores_t.segundo_apellido
      CALL partir_nombret(msubsi20.nombre)
      LET rec_proveedores_t.primer_nombre=mprinom
      LET rec_proveedores_t.segundo_nombre=msegnom
      DISPLAY BY NAME rec_proveedores_t.primer_nombre
      DISPLAY BY NAME rec_proveedores_t.segundo_nombre
      let rec_proveedores_t.direccion=msubsi20.direccion
      DISPLAY BY NAME rec_proveedores_t.direccion
      let rec_proveedores_t.telefono=msubsi20.telefono
      DISPLAY BY NAME rec_proveedores_t.telefono
      let rec_proveedores_t.zona=msubsi20.codzon
      DISPLAY BY NAME rec_proveedores_t.zona
      let rec_proveedores_t.email=msubsi20.email
      DISPLAY BY NAME rec_proveedores_t.email
      NEXT FIELD primer_apellido
     ELSE
      INITIALIZE msubsi22.* TO NULL
      SELECT * INTO msubsi22.* FROM subsi22 WHERE documento=rec_proveedores_t.nit
      IF msubsi22.documento IS NOT NULL THEN 
       let rec_proveedores_t.primer_apellido=msubsi22.priape
       DISPLAY BY NAME rec_proveedores_t.primer_apellido
       let rec_proveedores_t.segundo_apellido=msubsi22.segape
       DISPLAY BY NAME rec_proveedores_t.segundo_apellido
       CALL partir_nombret(msubsi22.nombre)
       LET rec_proveedores_t.primer_nombre=mprinom
       LET rec_proveedores_t.segundo_nombre=msegnom
       DISPLAY BY NAME rec_proveedores_t.primer_nombre
       DISPLAY BY NAME rec_proveedores_t.segundo_nombre
       NEXT FIELD primer_apellido
      END if 
     END if 
    END if  
   END if  

  AFTER FIELD razsoc
   IF rec_proveedores_t.tipo_persona="1" THEN
    IF rec_proveedores_t.razsoc IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "La Razon Social no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
     NEXT FIELD razsoc
    END IF
   END IF 

 BEFORE FIELD primer_apellido
  IF rec_proveedores_t.tipo_persona="1" THEN
   NEXT FIELD direccion
  END if 
   
 AFTER FIELD primer_apellido
  IF rec_proveedores_t.tipo_persona="2" THEN
   IF rec_proveedores_t.primer_apellido IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El primer Apellido no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD primer_apellido
   END IF
  END if 
  
 AFTER FIELD segundo_apellido
  IF rec_proveedores_t.tipo_persona="2" THEN
   IF rec_proveedores_t.segundo_apellido IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Segundo Apellido no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    --NEXT FIELD segundo_apellido
   END IF
  END if 
 
 AFTER FIELD primer_nombre
  IF rec_proveedores_t.tipo_persona="2" THEN
   IF rec_proveedores_t.primer_nombre IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Primer Nombre no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD primer_nombre
   END IF
  END if 

 AFTER FIELD segundo_nombre
  IF rec_proveedores_t.tipo_persona="2" THEN
   IF rec_proveedores_t.segundo_nombre IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Segundo Nombre no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    --NEXT FIELD segundo_nombre
   END IF
  END if 


 AFTER FIELD direccion
  IF rec_proveedores_t.direccion is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " La direccion no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD direccion
  END IF

 AFTER FIELD telefono
  IF rec_proveedores_t.telefono is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Numero de Telefono Fijo no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD telefono
  END IF

AFTER FIELD celular
  IF rec_proveedores_t.celular is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Numero de Celular no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    --NEXT FIELD celular
  END IF

 
 AFTER FIELD zona
  IF rec_proveedores_t.zona IS NULL THEN
   CALL gener09val() RETURNING rec_proveedores_t.zona
   IF rec_proveedores_t.zona is NULL THEN 
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
    comment= "Debe escoger una Zona ", image= "exclamation")
     COMMAND "Aceptar"
        EXIT MENU
    END MENU
    NEXT FIELD zona
   ELSE
    INITIALIZE  mgener09.* TO NULL 
    SELECT * into mgener09.*  FROM gener09
    WHERE codzon = rec_proveedores_t.zona
    display mgener09.detzon to detciu
   END IF 
  ELSE
    INITIALIZE  mgener09.* TO NULL 
    SELECT * into mgener09.*  FROM gener09
    WHERE codzon = rec_proveedores_t.zona
    if mgener09.codzon is null then
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
          comment= " El codigo de la ciudad no existe ", image= "exclamation")
         COMMAND "Aceptar"
        EXIT MENU
     END MENU
     LET rec_proveedores_t.zona = NULL 
     display BY NAME rec_proveedores_t.zona
     NEXT FIELD zona
    else
      display mgener09.detzon to detciu
    end IF 
  END IF

   AFTER FIELD pais
    IF rec_proveedores_t.pais is null then
      CALL fe_paisval() RETURNING rec_proveedores_t.pais
      IF rec_proveedores_t.pais is NULL THEN 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " Debe escoger un pais ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD pais
      ELSE
        INITIALIZE mfe_pais.* TO NULL
        SELECT * INTO mfe_pais.* FROM fe_pais WHERE fe_pais.pais = rec_proveedores_t.pais
        DISPLAY mfe_pais.detalle TO detpais 
      END IF 
    ELSE
     INITIALIZE mfe_pais.* TO NULL
     SELECT * INTO mfe_pais.*
      FROM fe_pais
      WHERE fe_pais.pais = rec_proveedores_t.pais
      IF mfe_pais.pais is NULL THEN 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " Debe escoger un pais ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD pais
      ELSE 
       DISPLAY mfe_pais.detalle TO detpais
      END if
     END IF  
   
 AFTER FIELD medio_recep
  IF rec_proveedores_t.medio_recep is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El medio de recepcion no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD medio_recep
    
  END IF
  CASE
   when rec_proveedores_t.medio_recep="1"
    NEXT field email

   when rec_proveedores_t.medio_recep="4"
    DISPLAY "" TO email
    NEXT field estado 
  END CASE  

     
  ON ACTION bt_zona
   CALL gener09val() RETURNING rec_proveedores_t.zona
   DISPLAY BY NAME rec_proveedores_t.zona
   INITIALIZE  mgener09.* TO NULL 
   SELECT * into mgener09.*  FROM gener09
   WHERE codzon = rec_proveedores_t.zona
   display mgener09.detzon to detciu
  
   ON ACTION bt_pais
    CALL fe_paisval() RETURNING rec_proveedores_t.pais
    DISPLAY BY NAME rec_proveedores_t.pais
    INITIALIZE mfe_pais.* TO NULL
    SELECT * INTO mfe_pais.* FROM fe_pais WHERE fe_pais.pais = rec_proveedores_t.pais
    DISPLAY mfe_pais.detalle TO detpais 

  

  
 AFTER FIELD email
  IF rec_proveedores_t.medio_recep="1" THEN
   IF rec_proveedores_t.email is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El corre electronico no fue digitado ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD email
   END IF
  ELSE
   NEXT FIELD estado 
  END IF 
 
 AFTER FIELD estado
  IF rec_proveedores_t.estado is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Estado del cliente no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD estado
  END IF

  AFTER INPUT
   IF int_flag THEN
      EXIT INPUT
   ELSE
     IF rec_proveedores_t.tipid is null or rec_proveedores_t.nit is null 
      or rec_proveedores_t.tipo_persona is null or rec_proveedores_t.regimen is NULL
      or rec_proveedores_t.direccion is NULL  or rec_proveedores_t.zona is NULL 
      or rec_proveedores_t.pais is null
      or rec_proveedores_t.medio_recep is null 
      or rec_proveedores_t.estado is null then 
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
    INITIALIZE rec_proveedores_t.* TO NULL
  RETURN
 END IF
 MESSAGE "ADICIONANDO INFORMACION DEL NIT"  ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 --WHENEVER ERROR CONTINUE
 -- SET LOCK MODE TO WAIT 
 IF rec_proveedores_t.tipid is NOT null or rec_proveedores_t.nit is NOT null 
      or rec_proveedores_t.tipo_persona is NOT null or rec_proveedores_t.regimen is NOT NULL
      or rec_proveedores_t.direccion is NOT NULL
      or rec_proveedores_t.zona is NOT null or rec_proveedores_t.pais is NOT null
      or rec_proveedores_t.medio_recep is NOT null
      or rec_proveedores_t.estado is NOT null THEN   
  INSERT INTO fc_terceros
    (tipid, nit, digver,tipo_persona, regimen, razsoc, primer_apellido, segundo_apellido, primer_nombre, 
      segundo_nombre, direccion, telefono, celular, zona, pais, medio_recep,  email, 
      estado, fecsis, usuario ) 
   VALUES (rec_proveedores_t.tipid, rec_proveedores_t.nit, rec_proveedores_t.digver,rec_proveedores_t.tipo_persona, rec_proveedores_t.regimen, rec_proveedores_t.razsoc, rec_proveedores_t.primer_apellido, 
      rec_proveedores_t.segundo_apellido, rec_proveedores_t.primer_nombre, rec_proveedores_t.segundo_nombre, rec_proveedores_t.direccion,
      rec_proveedores_t.telefono, rec_proveedores_t.celular, rec_proveedores_t.zona, rec_proveedores_t.pais, 
      rec_proveedores_t.medio_recep,  rec_proveedores_t.email,
      rec_proveedores_t.estado, today, musuario )
   if sqlca.sqlcode <> 0 THEN 
    DISPLAY "El error: " , STATUS, " " , SQLERRMESSAGE
     MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
      comment= " NO SE ADICIONO.. REGISTRO REFERENCIADO " , image= "stop")
        COMMAND "Aceptar"
          EXIT MENU
     END MENU
     LET gerrflag = TRUE
   END IF  
 else
  LET gerrflag = TRUE
 end IF
 IF NOT gerrflag THEN
  LET cnt=0
  SELECT count(*) INTO cnt FROM conta04 WHERE nit=rec_proveedores_t.nit
  IF cnt IS NULL THEN LET cnt=0 END IF
  IF cnt=0 THEN
   let mnit=rec_proveedores_t.nit
   call digver()
   LET mrazsoc=null
   IF rec_proveedores_t.tipo_persona="1" THEN
    LET mrazsoc=rec_proveedores_t.razsoc
   ELSE
    LET mrazsoc=rec_proveedores_t.primer_apellido clipped," ",
                rec_proveedores_t.segundo_apellido clipped," ",
                rec_proveedores_t.primer_nombre clipped," ",
                rec_proveedores_t.segundo_nombre clipped," "
   LET mregimen=null             
   END IF
   CASE
    WHEN rec_proveedores_t.regimen="0"
     LET mregimen="4"
    WHEN rec_proveedores_t.regimen="2"
     LET mregimen="2"
   END case 
   INSERT INTO conta04
   ( nit, digver, razsoc, direccion, telefono, codzon, vendedor, tipcon, nota, email, fecsis ) 
   VALUES ( rec_proveedores_t.nit, mdigver, mrazsoc, rec_proveedores_t.direccion, rec_proveedores_t.telefono, rec_proveedores_t.zona, "N", mregimen,
      "CLIENTE COMPRA SERVICIOS", rec_proveedores_t.email, TODAY )  
   if sqlca.sqlcode <> 0 then    
     MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
      comment= " NO SE ADICIONO.. REGISTRO REFERENCIADO " , image= "stop")
        COMMAND "Aceptar"
          EXIT MENU
     END MENU
     LET gerrflag = TRUE
   END IF
  
  END if   
 END if
 IF NOT gerrflag THEN
  COMMIT WORK
  LET g_proveedores_t.* = rec_proveedores_t.*
  INITIALIZE rec_proveedores_t.* TO NULL
 MENU "Información"  ATTRIBUTE( style= "dialog", 
   comment= " La informacion del nit fue adicionada...  "  ,
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

FUNCTION tercerosupdate()
 DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION DE LA INFORMACION DE UN PROVEEDOR"  ATTRIBUTE(BLUE)
 LET rec_proveedores_t.* = g_proveedores_t.*
Label  Ent_persona2:
 INPUT BY NAME rec_proveedores_t.tipid THRU rec_proveedores_t.estado WITHOUT DEFAULTS

    AFTER FIELD tipid 
        IF rec_proveedores_t.tipid IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " El tipo identificacion no fue seleccionado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD tipid
   END IF
        
  AFTER FIELD tipo_persona
   IF rec_proveedores_t.tipo_persona IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " El tipo_persona del nit no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD tipo_persona
   END IF
 
  AFTER FIELD regimen
   IF rec_proveedores_t.regimen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
             comment= " El Regimen del nit no fue digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD regimen
   END IF
  BEFORE FIELD razsoc
  
   IF rec_proveedores_t.tipo_persona="1" THEN
   ELSE
    NEXT FIELD primer_apellido
   END if  

  AFTER FIELD razsoc
   IF rec_proveedores_t.tipo_persona="1" THEN
    IF rec_proveedores_t.razsoc IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "La Razon Social no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
     NEXT FIELD razsoc
    END IF
   END IF 

 BEFORE FIELD primer_apellido
  IF rec_proveedores_t.tipo_persona="1" THEN
   NEXT FIELD direccion
  END if 
 
 AFTER FIELD primer_apellido
  IF rec_proveedores_t.tipo_persona="2" THEN
   IF rec_proveedores_t.primer_apellido IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El primer Apellido no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD primer_apellido
   END IF
  END if 
  
 AFTER FIELD segundo_apellido
  IF rec_proveedores_t.tipo_persona="2" THEN
   IF rec_proveedores_t.segundo_apellido IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Segundo Apellido no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    --NEXT FIELD segundo_apellido
   END IF
  END if 
 
 AFTER FIELD primer_nombre
  IF rec_proveedores_t.tipo_persona="2" THEN
   IF rec_proveedores_t.primer_nombre IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Primer Nombre no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD primer_nombre
   END IF
  END if 

 AFTER FIELD segundo_nombre
  IF rec_proveedores_t.tipo_persona="2" THEN
   IF rec_proveedores_t.segundo_nombre IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
        comment= "El Segundo Nombre no fue Digitado ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    --NEXT FIELD segundo_nombre
   END IF
  END if 


 AFTER FIELD direccion
  IF rec_proveedores_t.direccion is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " La direccion no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD direccion
  END IF

 AFTER FIELD telefono
  IF rec_proveedores_t.telefono is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Numero de Telefono Fijo no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD telefono
  END IF

 AFTER FIELD celular
  IF rec_proveedores_t.celular is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Numero de Celular no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD celular
  END IF


 AFTER FIELD zona
  IF rec_proveedores_t.zona IS NULL THEN
   CALL gener09val() RETURNING rec_proveedores_t.zona
   IF rec_proveedores_t.zona is NULL THEN 
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
    comment= "Debe escoger una Zona ", image= "exclamation")
     COMMAND "Aceptar"
        EXIT MENU
    END MENU
    NEXT FIELD zona
   ELSE
    INITIALIZE  mgener09.* TO NULL 
    SELECT * into mgener09.*  FROM gener09
    WHERE codzon = rec_proveedores_t.zona
    display mgener09.detzon to detciu
   END IF 
  ELSE
    INITIALIZE  mgener09.* TO NULL 
    SELECT * into mgener09.*  FROM gener09
    WHERE codzon = rec_proveedores_t.zona
    if mgener09.codzon is null then
      MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
          comment= " El codigo de la ciudad no existe ", image= "exclamation")
         COMMAND "Aceptar"
        EXIT MENU
     END MENU
     LET rec_proveedores_t.zona = NULL 
     display BY NAME rec_proveedores_t.zona
     NEXT FIELD zona
    else
      display mgener09.detzon to detciu
    end IF 
  END IF

 ON ACTION bt_zona
  CALL gener09val() RETURNING rec_proveedores_t.zona
  DISPLAY BY NAME rec_proveedores_t.zona
  INITIALIZE  mgener09.* TO NULL 
  SELECT * into mgener09.*  FROM gener09
  WHERE codzon = rec_proveedores_t.zona
  display mgener09.detzon to detciu
    
  
   AFTER FIELD pais
    IF rec_proveedores_t.pais is null then
      CALL fe_paisval() RETURNING rec_proveedores_t.pais
      IF rec_proveedores_t.pais is NULL THEN 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " Debe escoger un pais ", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD pais
      ELSE
        INITIALIZE mfe_pais.* TO NULL
        SELECT * INTO mfe_pais.* FROM fe_pais WHERE fe_pais.pais = rec_proveedores_t.pais
        DISPLAY mfe_pais.detalle TO detpais 
      END IF 
    ELSE
     INITIALIZE mfe_pais.* TO NULL
     SELECT * INTO mfe_pais.*
      FROM fe_pais
      WHERE fe_pais.pais = rec_proveedores_t.pais
      IF mfe_pais.pais is NULL THEN 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " Debe escoger un pais ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD pais
      ELSE 
       DISPLAY mfe_pais.detalle TO detpais
      END if
     END IF  

    ON ACTION bt_pais
    CALL fe_paisval() RETURNING rec_proveedores_t.pais
    DISPLAY BY NAME rec_proveedores_t.pais
    INITIALIZE mfe_pais.* TO NULL
    SELECT * INTO mfe_pais.* FROM fe_pais WHERE fe_pais.pais = rec_proveedores_t.pais
    DISPLAY mfe_pais.detalle TO detpais 

 AFTER FIELD medio_recep
  IF rec_proveedores_t.medio_recep is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El medio de recepcion no fue digitada ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD medio_recep
  END IF
{
 BEFORE FIELD nit_facturador
  CASE
   when rec_proveedores_t.medio_recep="1"
    NEXT field email
   when rec_proveedores_t.medio_recep="2"
    NEXT field estado
   when rec_proveedores_t.medio_recep="3"
    NEXT field nit_facturador
   when rec_proveedores_t.medio_recep="4"
    NEXT field estado 
  END CASE  }
  
 
 
   
  
  {AFTER FIELD nit_facturador
   IF rec_proveedores_t.medio_recep="3" then
    IF rec_proveedores_t.nit_facturador is null then
      CALL fe_facturadorval() RETURNING rec_proveedores_t.nit_facturador
      IF rec_proveedores_t.nit_facturador is NULL THEN 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " Debe escoger un nit facturador ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD nit_facturador
      ELSE
        INITIALIZE mfc_facturador.* TO NULL
        SELECT * INTO mfc_facturador.*
         FROM fe_facturador
         WHERE fe_facturador.nit = rec_proveedores_t.nit_facturador
        DISPLAY mfc_facturador.razsoc TO detnit 
      END IF 
    ELSE
     INITIALIZE mfc_facturador.* TO NULL
     SELECT * INTO mfc_facturador.*
      FROM fe_facturador
      WHERE fe_facturador.nit = rec_proveedores_t.nit_facturador
      IF mfc_facturador.nit is NULL THEN 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " Debe escoger un nit facturador ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD nit_facturador
      ELSE
       DISPLAY mfc_facturador.razsoc TO detnit
      END if
     END IF  
   END if}  

  
 AFTER FIELD email
  IF rec_proveedores_t.medio_recep="1" THEN
   IF rec_proveedores_t.email is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El EMAIL no fue digitado ",image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD email
   END IF
  ELSE
   NEXT FIELD estado
  END IF 

  
 AFTER FIELD estado
  IF rec_proveedores_t.estado is null then
    MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
       comment= " El Estado del nit no fue seleccionado ",image= "exclamation")
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
  INITIALIZE rec_proveedores_t.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION DEL nit" AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 UPDATE fc_terceros
 SET (tipid, nit, digver,
      tipo_persona, regimen, razsoc, 
      primer_apellido,segundo_apellido, primer_nombre, 
      segundo_nombre,direccion, telefono, 
      celular,zona, pais, 
      medio_recep,email, estado )  
    =( rec_proveedores_t.tipid, rec_proveedores_t.nit, rec_proveedores_t.digver,
       rec_proveedores_t.tipo_persona, rec_proveedores_t.regimen, rec_proveedores_t.razsoc, 
       rec_proveedores_t.primer_apellido, rec_proveedores_t.segundo_apellido, rec_proveedores_t.primer_nombre, 
       rec_proveedores_t.segundo_nombre, rec_proveedores_t.direccion, rec_proveedores_t.telefono, 
       rec_proveedores_t.celular, rec_proveedores_t.zona, rec_proveedores_t.pais, 
       rec_proveedores_t.medio_recep,  rec_proveedores_t.email, rec_proveedores_t.estado )
 WHERE nit = g_proveedores_t.nit
 DISPLAY status
 IF status <> 0 THEN
    DISPLAY "el nit es: ",g_proveedores_t.nit
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
  LET g_proveedores_t.* = rec_proveedores_t.*
 END IF
END FUNCTION  

FUNCTION tercerosgetcurr( tpnit )
  DEFINE letras string
  DEFINE tpnit LIKE fc_terceros.nit
  INITIALIZE g_proveedores_t.* TO NULL
  SELECT *  INTO g_proveedores_t.*  FROM fc_terceros
   WHERE fc_terceros.nit = tpnit
END FUNCTION

FUNCTION tercerosshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum INTEGER
  IF g_proveedores_t.nit IS NULL THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, ")"
 END IF
 CALL tercerosdplyg()
END FUNCTION

FUNCTION tercerosquery( exist )
 DEFINE WHERE_info, query_text  CHAR(400),
  answer      CHAR(1),
  exist,
  curr, maxnum integer,
  tpnit      LIKE fc_terceros.nit,
  letras string
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : CONSULTA DE LOS DATOS DEL nit "  ATTRIBUTE(BLUE)
 CLEAR FORM
 CONSTRUCT WHERE_info
   ON tipid, nit, digver,tipo_persona, regimen, razsoc, primer_apellido, segundo_apellido, primer_nombre, 
      segundo_nombre, direccion, zona, pais, medio_recep, email, estado
   FROM tipid, nit, digver,tipo_persona, regimen, razsoc, primer_apellido, segundo_apellido, primer_nombre, 
      segundo_nombre, direccion, zona, pais, medio_recep, email, estado
 IF int_flag THEN 
   MENU "Informacion " ATTRIBUTE(style= "dialog", 
  comment= " LA CONSULTA FUE CANCELADA ",  image= "exclamation")
   COMMAND "Aceptar"
     EXIT MENU
   END MENU
  RETURN exist
 END IF
 MESSAGE "Buscando el registro, por favor espere ..." ATTRIBUTE(BLINK)
 LET query_text = " SELECT fc_terceros.nit",
   " FROM fc_terceros WHERE ", where_info CLIPPED,
    " ORDER BY fc_terceros.nit ASC" 
 PREPARE s_sterceros FROM query_text
 DECLARE c_sterceros SCROLL CURSOR FOR s_sterceros
 LET maxnum = 0
 FOREACH c_sterceros INTO tpnit
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_sterceros
  FETCH FIRST c_sterceros INTO tpnit
  LET curr = 1
  CALL tercerosgetcurr( tpnit)
  CALL tercerosshowcurr( curr, maxnum )
 ELSE
  MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
   comment= " El registro del nit no EXISTE", image= "exclamation")
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
    FETCH FIRST c_sterceros INTO tpnit
    LET curr = 1
   ELSE
    FETCH NEXT c_sterceros INTO tpnit
    LET curr = curr + 1
   END IF
   CALL tercerosgetcurr( tpnit )
   CALL tercerosshowcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_sterceros INTO tpnit
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_sterceros INTO tpnit
    LET curr = curr - 1
   END IF
   CALL tercerosgetcurr( tpnit )
   CALL tercerosshowcurr( curr, maxnum )
  COMMAND "Modifica" "Modifica el registro  en consulta"
   LET mcodmen="FC26"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF g_proveedores_t.nit IS NULL THEN
      CONTINUE MENU
    ELSE
      CLOSE c_sterceros
      CALL tercerosupdate()
      IF gerrflag THEN
       EXIT MENU
      END IF
      IF int_flag THEN
       LET int_flag = FALSE
      END IF
      CALL tercerosgetcurr( tpnit)
      CALL tercerosshowcurr( curr, maxnum )
      OPEN c_sterceros
    END IF
  END IF
  COMMAND "Borra" "Borra el registro en consulta"
   LET mcodmen="FC27"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF g_proveedores_t.nit IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sterceros
     CALL tercerosremove()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CALL tercerosshowcurr( curr, maxnum )
     END IF
     OPEN c_sterceros
    END IF
   END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF g_proveedores_t.nit IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sterceros
 RETURN exist
END FUNCTION

FUNCTION fe_paisval()
 DEFINE tp   RECORD
   pais         LIKE fe_pais.pais,
   detalle     LIKE fe_pais.detalle
 END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fe_pais
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.pais = NULL
  RETURN tp.pais
 END IF
 OPEN WINDOW w_vfe_pais1 AT 8,32 WITH FORM "fe_paisv"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 DECLARE c_vfe_pais1 SCROLL CURSOR FOR
  SELECT fe_pais.pais, fe_pais.detalle FROM fe_pais
   ORDER BY fe_pais.pais
 OPEN c_vfe_pais1
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fe_paisrow( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
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
   CALL fe_paisrow( currrow, prevrow, pagenum )
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
   CALL fe_paisrow( currrow, prevrow, pagenum )
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
   CALL fe_paisrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vfe_pais1 INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.pais = NULL
   EXIT MENU
 END MENU
 CLOSE c_vfe_pais1
 CLOSE WINDOW w_vfe_pais1
 RETURN tp.pais
END FUNCTION  
FUNCTION fe_paisrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   pais         LIKE fe_pais.pais,
   detalle     LIKE fe_pais.detalle
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
  FETCH ABSOLUTE scrfrst c_vfe_pais1 INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cenv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO cenv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vfe_pais1 INTO tp.*
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
  FETCH ABSOLUTE prevrow c_vfe_pais1 INTO tp.*
  DISPLAY tp.* TO cenv[scrprev].*
  FETCH ABSOLUTE currrow c_vfe_pais1 INTO tp.*
  DISPLAY tp.* TO cenv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION

FUNCTION fe_facturadorval()
 DEFINE tp   RECORD
   nit         LIKE fe_facturador.nit,
   razsoc      LIKE fe_facturador.razsoc
 END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fe_facturador
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.nit = NULL
  RETURN tp.nit
 END IF
 OPEN WINDOW w_vfe_facturador1 AT 8,32 WITH FORM "fe_facturadorv"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 DECLARE c_vfe_facturador1 SCROLL CURSOR FOR
  SELECT fe_facturador.nit, fe_facturador.razsoc FROM fe_facturador
   ORDER BY fe_facturador.nit
 OPEN c_vfe_facturador1
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fe_facturadorrow( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
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
   CALL fe_facturadorrow( currrow, prevrow, pagenum )
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
   CALL fe_facturadorrow( currrow, prevrow, pagenum )
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
   CALL fe_facturadorrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vfe_facturador1 INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.nit = NULL
   EXIT MENU
 END MENU
 CLOSE c_vfe_facturador1
 CLOSE WINDOW w_vfe_facturador1
 RETURN tp.nit
END FUNCTION  
FUNCTION fe_facturadorrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   nit         LIKE fe_facturador.nit,
   razsoc      LIKE fe_facturador.razsoc
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
  FETCH ABSOLUTE scrfrst c_vfe_facturador1 INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cenv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO cenv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vfe_facturador1 INTO tp.*
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
  FETCH ABSOLUTE prevrow c_vfe_facturador1 INTO tp.*
  DISPLAY tp.* TO cenv[scrprev].*
  FETCH ABSOLUTE currrow c_vfe_facturador1 INTO tp.*
  DISPLAY tp.* TO cenv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION

FUNCTION partir_nombret(mnombre)
 DEFINE mnombre char(50)
 LET mprinom = ""
 LET msegnom = ""
 FOR i = 1 TO 49
   IF mnombre[i,i] = " " THEN
      EXIT FOR
   END IF
 END FOR
 LET mprinom = mnombre[1,i]
 IF i >= 49 THEN
 LET msegnom = mnombre[49,49]
 ELSE
 LET msegnom = mnombre[i+1,49]
 END IF
 IF mprinom[1,1] = " " AND msegnom[1,1] <> " " THEN
    LET mprinom = msegnom
    LET msegnom = ""
 END IF
END FUNCTION

FUNCTION gener09val()
 DEFINE tp   RECORD
   codzon         LIKE gener09.codzon,
   detzon     LIKE gener09.detzon
 END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM gener09
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.codzon = NULL
  RETURN tp.codzon
 END IF
 OPEN WINDOW w_vgener091 AT 8,32 WITH FORM "fc_zonav"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 DECLARE c_vgener091 SCROLL CURSOR FOR
  SELECT gener09.codzon, gener09.detzon FROM gener09
   ORDER BY gener09.codzon
 OPEN c_vgener091
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL gener09row( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
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
   CALL gener09row( currrow, prevrow, pagenum )
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
   CALL gener09row( currrow, prevrow, pagenum )
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
   CALL gener09row( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vgener091 INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.codzon = NULL
   EXIT MENU
 END MENU
 CLOSE c_vgener091
 CLOSE WINDOW w_vgener091
 RETURN tp.codzon
END FUNCTION  
FUNCTION gener09row( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   codzon         LIKE gener09.codzon,
   detzon     LIKE gener09.detzon
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
  FETCH ABSOLUTE scrfrst c_vgener091 INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cenv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO cenv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vgener091 INTO tp.*
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
  FETCH ABSOLUTE prevrow c_vgener091 INTO tp.*
  DISPLAY tp.* TO cenv[scrprev].*
  FETCH ABSOLUTE currrow c_vgener091 INTO tp.*
  DISPLAY tp.* TO cenv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION

FUNCTION migra_cliente()
 DEFINE mtipdoc char(2)
 DEFINE mnombre char(30)
 DEFINE cnt integer
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : MIGRA ADQUIRIENTE A CAPACITACION " ATTRIBUTE(BLUE)
 PROMPT "Esta seguro de migrar el Adquiriente (s/n)? " FOR CHAR answer
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "MIGRANDO EL ADQUIRIENTE " ATTRIBUTE(BLUE)
  LET cnt=0
  SELECT count(*) INTO cnt FROM banco:cliente
   WHERE banco:cliente.nro_doc = g_proveedores_t.nit
  IF cnt IS NULL THEN LET cnt=0 END IF
  IF cnt=0 THEN  
   LET gerrflag = FALSE
   BEGIN WORK
   WHENEVER ERROR CONTINUE
   SET LOCK MODE TO WAIT
   LET mtipdoc=null
   CASE 
    WHEN g_proveedores_t.tipid="22"
     LET mtipdoc="CC"
    WHEN g_proveedores_t.tipid="11"
     LET mtipdoc="RC" 
    WHEN g_proveedores_t.tipid="12"
     LET mtipdoc="TI" 
    OTHERWISE
     LET mtipdoc="CC"
   END CASE
   LET mnombre=NULL
   LET mnombre=g_proveedores_t.primer_nombre clipped," ",g_proveedores_t.segundo_nombre clipped
   INSERT INTO banco:cliente ( tipo_doc, nro_doc, cp_apell1, cp_apell2, cp_nombres, telefono, codzon, direccion, email ) 
   VALUES ( g_proveedores_t.nit, mtipdoc, g_proveedores_t.primer_apellido, g_proveedores_t.segundo_apellido, mnombre, g_proveedores_t.telefono, g_proveedores_t.zona, g_proveedores_t.direccion, g_proveedores_t.email )
   IF status <> 0 THEN
    MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se Adiciono .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
   END IF
   IF NOT gerrflag THEN 
    INITIALIZE g_proveedores_t.* TO NULL
    MENU "Información"  ATTRIBUTE( style= "dialog", 
        comment= " La Migracion Fue Procesada", image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    COMMIT WORK
   ELSE
    MENU "Información"  ATTRIBUTE( style= "dialog", 
     comment= " La Migracion Fue Cancelada",  image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    ROLLBACK WORK
   END IF
  ELSE
   MENU "Información"  ATTRIBUTE( style= "dialog", 
    comment= " El Adquiriente Ya existe",image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  LET int_flag = TRUE
  END if 
 ELSE
  MENU "Información"  ATTRIBUTE( style= "dialog", 
    comment= " La Migracion Fue Cancelada",image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  LET int_flag = TRUE
 END IF
END FUNCTION 

FUNCTION act_digver_vacios()
 DEFINE mdigv char(1)
  INITIALIZE mfc_terceros.* TO NULL
  DECLARE cur_corrdig CURSOR FOR
  SELECT * FROM fc_terceros
   WHERE tipo_persona = "1"
  FOREACH cur_corrdig INTO mfc_terceros.*
   DISPLAY "Tercero : ", mfc_terceros.nit
    LET mdigv = ""
    SELECT digver INTO mdigv
      FROM conta04
     WHERE nit = mfc_terceros.nit
    IF mdigv IS NOT NULL  THEN
      UPDATE fc_terceros
      SET digver = mdigv
      WHERE nit = mfc_terceros.nit
    END IF
  END FOREACH 
    
END FUNCTION