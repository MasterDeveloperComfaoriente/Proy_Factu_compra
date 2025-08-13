GLOBALS "fc_globales.4gl"
SCHEMA empresa
DEFINE tpfc_proveedores, gpfc_proveedores RECORD 
    radicado LIKE com_proveedores.radicado,
    fecrad LIKE com_proveedores.fecrad,
    inscrip LIKE com_proveedores.inscrip,
    fecrec LIKE com_proveedores.fecrec,
    recibo LIKE com_proveedores.recibo,
    az LIKE com_proveedores.az,
    fecapro LIKE com_proveedores.fecapro,
    razsoc LIKE com_proveedores.razsoc,
    nit LIKE com_proveedores.nit,
    digver LIKE com_proveedores.digver,
    cedrep LIKE com_proveedores.inscrip,
    nomrep LIKE com_proveedores.nomrep,
    dpto LIKE com_proveedores.dpto,
    ciudad LIKE com_proveedores.ciudad,
    telefono LIKE com_proveedores.telefono,
    direccion LIKE com_proveedores.direccion,
    fax LIKE com_proveedores.fax,
    mail LIKE com_proveedores.mail,
    tip_prov LIKE com_proveedores.tip_prov,
    g_contrib LIKE com_proveedores.g_contrib,
    autoret LIKE com_proveedores.autoret,
    actividad1 LIKE com_proveedores.actividad1,
    actividad2 LIKE com_proveedores.actividad2,
    actividad3 LIKE com_proveedores.actividad3,
    actividad4 LIKE com_proveedores.actividad4,
    cl_soc LIKE com_proveedores.cl_soc,
    cl_emp LIKE com_proveedores.cl_emp,
    resolg LIKE com_proveedores.resolg,
    resola LIKE com_proveedores.resola,
    regimen LIKE com_proveedores.regimen,
    codcaja LIKE com_proveedores.codcaja,
    exento_imp LIKE com_proveedores.exento_imp,
    estado LIKE com_proveedores.estado,
    aficaja LIKE com_proveedores.aficaja
END RECORD 

DEFINE rec_ciudades RECORD LIKE fe_ciudades.*
DEFINE rec_dptos RECORD LIKE fe_deptos.*

DEFINE cb_tip_prov, cb_g_contrib, cb_autoret,
        cb_exento_imp, cb_estado,cb_regimen,
       cb_aficaja, cb_dpto, cb_ciudad,
       cb_actividad2, cb_actividad3, cb_actividad4 ui.combobox

DEFINE codigo  STRING    
    
FUNCTION fc_proveemain()
 DEFINE exist SMALLINT
 OPEN WINDOW w_proveedores AT 1,1 WITH FORM "fc_proveedores"
 
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE tpfc_proveedores.* TO NULL
 
LET cb_tip_prov = ui.ComboBox.forName("com_proveedores.tip_prov")
CALL cb_tip_prov.CLEAR()
CALL cb_tip_prov.addItem("E","Exento")
CALL cb_tip_prov.addItem("R","Retenedor") 

LET cb_g_contrib=ui.ComboBox.forName("com_proveedores.g_contrib")
CALL cb_g_contrib.CLEAR()
CALL cb_g_contrib.addItem("1","Si")
CALL cb_g_contrib.addItem("0","No")

LET cb_autoret = ui.ComboBox.forName("com_proveedores.autoret")
CALL cb_autoret.CLEAR()
CALL cb_autoret.addItem("1","Si")
CALL cb_autoret.addItem("0","No")

LET cb_exento_imp = ui.ComboBox.forName("com_proveedores.exento_imp")
CALL cb_exento_imp.CLEAR()
CALL cb_exento_imp.addItem("1","Sí")
CALL cb_exento_imp.addItem("0","No")

LET cb_estado = ui.ComboBox.forName("com_proveedores.estado")
CALL cb_estado.CLEAR()
CALL cb_estado.addItem("A","Activo")
CALL cb_estado.addItem("D","Preguntar")

LET cb_regimen = ui.ComboBox.forName("com_proveedores.regimen")
CALL cb_regimen.CLEAR()
CALL cb_regimen.addItem("S","Simplificado")
CALL cb_regimen.addItem("C","Contributivo")

LET cb_aficaja=ui.ComboBox.forName("com_proveedores.aficaja")
CALL cb_aficaja.CLEAR()
CALL cb_aficaja.addItem("1","Si")
CALL cb_aficaja.addItem("2","No")

LET cb_dpto=ui.ComboBox.forName("dpto")
CALL cb_dpto.CLEAR()
DECLARE tp_deptos CURSOR FOR
   Select *  from fe_deptos
   FOREACH tp_deptos into rec_dptos.*
      CALL cb_dpto.addItem(rec_dptos.coddep, rec_dptos.nombredep)
   END FOREACH 

 


{LET cb_ciudad=ui.ComboBox.forName("ciudad")
CALL cb_ciudad.CLEAR()}
{DECLARE tp_ciudad CURSOR FOR
   Select *  from fe_ciudades WHERE fe_ciudades.codciu[1,2] = codigo
   FOREACH  tp_ciudad into rec_ciudades.*
      CALL cb_ciudad.addItem(rec_ciudades.codciu, rec_ciudades.nombreciu)
   END FOREACH 
}

    MENU
        {COMMAND "Adiciona" "Adiciona "
         CALL proveedoresadd()
        IF int_flag THEN
         LET int_flag = FALSE
        ELSE
         CLEAR FORM
         LET exist = TRUE
        END IF}
    --END if
        COMMAND "Consulta" "Consultar Información Registrada "
    --LET mcodmen=""
    --CALL opcion() RETURNING op
    --if op="S" THEN
        CALL com_proveedoresquery( exist ) RETURNING exist
        IF int_flag THEN
        LET int_flag = FALSE
        ELSE
        CLEAR FORM
        END IF

        --COMMAND "Modifica" "Modificar Información Registrada "
    --LET mcodmen=""
    --CALL opcion() RETURNING op
    --if op="S" THEN
        --CALL com_proveedoresupdate() 
        --IF int_flag THEN
       -- LET int_flag = FALSE
        --ELSE
        --CLEAR FORM
        --END IF
    --END IF
        COMMAND key ("esc","S") "Salir" "Retrocede de menu"
        HELP 1
        EXIT MENU
    END MENU 
 CLOSE WINDOW w_proveedores
END FUNCTION


FUNCTION llenar_combo_actividad_2(cb, a)
    DEFINE cb ui.ComboBox
    DEFINE codact STRING
    DEFINE detalle STRING 
    DEFINE a SMALLINT
    DEFINE sqlquery STRING  
   
   CASE 
     
        WHEN a = 2
            CALL cb.CLEAR()
            LET sqlquery= "SELECT codact,detalle FROM subsi04 WHERE codact <> "|| tpfc_proveedores.actividad1 || " ORDER BY codact ASC"
            DISPLAY sqlquery
            PREPARE p_subsi07 FROM sqlquery
            DECLARE c_subsi07 CURSOR FOR p_subsi07
            FOREACH c_subsi07 INTO codact, detalle
            CALL cb.addItem(codact, (codact||" - "||detalle))
        END FOREACH 

     WHEN a = 3
        CALL cb.CLEAR()
            LET sqlquery= "SELECT codact,detalle FROM subsi04 WHERE codact <> "|| tpfc_proveedores.actividad2 || " and codact <> "|| tpfc_proveedores.actividad1 || " ORDER BY codact ASC "
            DISPLAY sqlquery
            PREPARE p_subsi08 FROM sqlquery
            DECLARE c_subsi08 CURSOR FOR p_subsi08
            FOREACH c_subsi08 INTO codact, detalle
            CALL cb.addItem(codact, (codact||" - "||detalle))
        END FOREACH
      
     WHEN a = 4
        CALL cb.CLEAR()
            CALL cb.CLEAR()
            LET sqlquery= "SELECT codact,detalle FROM subsi04 WHERE codact <> "|| tpfc_proveedores.actividad3 || " and codact <> "|| tpfc_proveedores.actividad2 || " and codact <> "|| tpfc_proveedores.actividad1 ||" ORDER BY codact ASC "
            DISPLAY sqlquery
            PREPARE p_subsi09 FROM sqlquery
            DECLARE c_subsi09 CURSOR FOR p_subsi09
            FOREACH c_subsi09 INTO codact, detalle
            CALL cb.addItem(codact, (codact||" - "||detalle))
        END FOREACH
    
       
    END CASE
    
END FUNCTION 

FUNCTION llenar_combo_actividad(cb)
    DEFINE cb ui.ComboBox
    DEFINE sqlquery STRING 
    DEFINE codact STRING
    DEFINE detalle STRING 
  
    CALL cb.CLEAR()
    LET sqlquery = "SELECT codact,detalle FROM subsi04 order by codact asc"
    PREPARE p_subsi04 FROM sqlquery
    DECLARE c_subsi04 CURSOR FOR p_subsi04
    FOREACH c_subsi04 INTO codact, detalle
        CALL cb.addItem(codact, (codact||" - "||detalle))
    END FOREACH  
END FUNCTION 

FUNCTION proveedoresadd()
    --DEFINE mnumero LIKE com_proveedores.radicado
    DEFINE control SMALLINT
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CLEAR FORM
     MESSAGE "ESTADO: ADICIONANDO PROVEEDORES"  ATTRIBUTE(BLUE)
     INITIALIZE tpfc_proveedores.* TO NULL
lABEL Ent_generales:
 INPUT BY NAME tpfc_proveedores.radicado THRU tpfc_proveedores.aficaja WITHOUT DEFAULTS
 
 AFTER FIELD radicado
   IF tpfc_proveedores.radicado IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El Radicado no fue digitado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD radicado
  END IF
     LET control = NULL 
   SELECT count(*) INTO control FROM com_proveedores 
     WHERE com_proveedores.radicado = tpfc_proveedores.radicado 
   DISPLAY ":",control  
   IF control<>0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El Radicado ya esta registrado  ",
             image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
      END MENU
      NEXT FIELD radicado
    END IF

     AFTER FIELD fecrad
   IF tpfc_proveedores.fecrad IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "La fecha de radicada no puede estar vacia ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD fecrad
   END IF

   AFTER FIELD inscrip
    IF tpfc_proveedores.inscrip IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El Inscrip??? No fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD inscrip
    END IF

    AFTER FIELD fecrec
    IF tpfc_proveedores.fecrec IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "La fecha de rec??? No fue Digitada", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD fecrec
    END IF

    AFTER FIELD recibo
    IF tpfc_proveedores.recibo IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El número de recibo No fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD recibo
    END IF

    AFTER FIELD az
    IF tpfc_proveedores.az IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El número de AZ No fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD az
    END IF

    AFTER FIELD fecapro
    IF tpfc_proveedores.fecapro IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "La fecha de Aprobación NO fue Digitada", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD fecapro
    END IF

    AFTER FIELD razsoc
    IF tpfc_proveedores.razsoc IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "La fecha de Aprobación NO fue Digitada", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD razsoc
    END IF

    AFTER FIELD nit
    IF tpfc_proveedores.nit IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "el NIT NO fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD nit
    END IF

    AFTER FIELD digver
    IF tpfc_proveedores.digver IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "el Digito de verificación NO fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD digver
    END IF

    AFTER FIELD cedrep
    IF tpfc_proveedores.cedrep IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "La cédula del representante NO fue Digitada", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD cedrep
    END IF

    AFTER FIELD nomrep
    IF tpfc_proveedores.nomrep IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El nombre del representante NO fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD nomrep
    END IF
--ojo aqui
    AFTER FIELD dpto
    IF tpfc_proveedores.dpto IS NULL THEN
        MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El Departamento NO fue Seleccionado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
        NEXT FIELD dpto
     ELSE 
        DECLARE tp_ciudad CURSOR FOR
        Select *  from fe_ciudades WHERE fe_ciudades.codciu[1,2] = tpfc_proveedores.dpto
        FOREACH  tp_ciudad into rec_ciudades.*
            CALL cb_ciudad.addItem(rec_ciudades.codciu, rec_ciudades.nombreciu)
        END FOREACH
         NEXT FIELD ciudad
    END IF

    AFTER FIELD ciudad
    IF tpfc_proveedores.ciudad IS NULL THEN
    
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "La ciudad  NO fue Seleccionada", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
     
    NEXT FIELD ciudad
    END IF

     

  AFTER FIELD direccion
    IF tpfc_proveedores.direccion IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "La dirección NO fue digitada", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD direccion
    END IF
    
    AFTER FIELD fax
    IF tpfc_proveedores.fax IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El fax NO fue digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD fax
    END IF    

     AFTER FIELD mail
    IF tpfc_proveedores.mail IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El E-mail NO fue digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD mail
    END IF

    AFTER FIELD tip_prov
    IF tpfc_proveedores.tip_prov IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El Tipo de Proveedor NO fue seleccionado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD tip_prov
    END IF

     AFTER FIELD g_contrib
    IF tpfc_proveedores.g_contrib IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "Si es Gran Contribuyente NO fue seleccionado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD g_contrib
    END IF

     AFTER FIELD autoret
    IF tpfc_proveedores.autoret IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "Si es Autoretenedor NO fue seleccionado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD autoret
    END IF

    AFTER FIELD actividad1
    IF tpfc_proveedores.actividad1 IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "La actividad 1 NO fue seleccionada", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD actividad1
    ELSE
        LET cb_actividad2=ui.ComboBox.forName("actividad2")
        CALL cb_actividad2.CLEAR()
        CALL llenar_combo_actividad_2(cb_actividad2, 2)
        NEXT FIELD actividad2
    END IF

    AFTER FIELD actividad2
    IF tpfc_proveedores.actividad2 IS NULL THEN
        
        NEXT FIELD cl_soc
    ELSE
        LET cb_actividad3=ui.ComboBox.forName("actividad3")
        CALL cb_actividad3.CLEAR()
        CALL llenar_combo_actividad_2(cb_actividad3, 3)
        NEXT FIELD actividad3
    END IF

    AFTER FIELD actividad3
    IF tpfc_proveedores.actividad3 IS NULL THEN
        NEXT FIELD cl_soc
    NEXT FIELD actividad3
    ELSE
        LET cb_actividad4=ui.ComboBox.forName("actividad4")
        CALL cb_actividad4.CLEAR()
        CALL llenar_combo_actividad_2(cb_actividad4, 4)
        NEXT FIELD actividad4
    END IF

    AFTER FIELD actividad4
    IF tpfc_proveedores.actividad4 IS NULL THEN
        NEXT FIELD cl_soc
    NEXT FIELD actividad4
    END IF

    AFTER FIELD cl_soc
    IF tpfc_proveedores.cl_soc IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El Cl_soc?? NO fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD cl_soc
    END IF

    AFTER FIELD cl_emp
    IF tpfc_proveedores.cl_emp IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El cl_emp?? NO fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD cl_emp
    END IF

     AFTER FIELD resolg
    IF tpfc_proveedores.resolg IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El resolg?? NO fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD resolg
    END IF

     AFTER FIELD resola
    IF tpfc_proveedores.resola IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El resola?? NO fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD resola
    END IF

     AFTER FIELD regimen
    IF tpfc_proveedores.regimen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El regimen NO fue Seleccionado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD regimen
    END IF

    AFTER FIELD codcaja
    IF tpfc_proveedores.codcaja IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El Código de Caja NO fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD codcaja
    END IF

    AFTER FIELD exento_imp
    IF tpfc_proveedores.exento_imp IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "Si es exento de impuesto NO fue seleccionado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD exento_imp
    END IF

    AFTER FIELD estado
    IF tpfc_proveedores.estado IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El estado NO fue seleccionado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD estado
    END IF

    AFTER FIELD aficaja
    IF tpfc_proveedores.aficaja IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "Si es afiliado a caja NO fue seleccionado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD aficaja
    END IF

    AFTER INPUT
    IF int_flag THEN
        EXIT INPUT
    ELSE
        IF tpfc_proveedores.radicado IS NULL OR tpfc_proveedores.fecrad IS NULL OR tpfc_proveedores.inscrip IS NULL OR
            tpfc_proveedores.fecrec IS NULL OR tpfc_proveedores.recibo IS NULL OR tpfc_proveedores.az IS NULL OR
            tpfc_proveedores.fecapro IS NULL OR tpfc_proveedores.razsoc IS NULL OR tpfc_proveedores.nit IS NULL OR
            tpfc_proveedores.digver IS NULL OR tpfc_proveedores.cedrep IS NULL OR tpfc_proveedores.nomrep IS NULL OR
            tpfc_proveedores.dpto IS NULL OR tpfc_proveedores.ciudad IS NULL OR tpfc_proveedores.direccion IS NULL OR
            tpfc_proveedores.fax IS NULL OR tpfc_proveedores.mail IS NULL OR tpfc_proveedores.tip_prov IS NULL OR
            tpfc_proveedores.g_contrib IS NULL OR tpfc_proveedores.autoret IS NULL OR tpfc_proveedores.actividad1 IS NULL OR
            tpfc_proveedores.cl_soc IS NULL OR tpfc_proveedores.cl_emp IS NULL OR tpfc_proveedores.resolg IS NULL OR
            tpfc_proveedores.resola IS NULL OR tpfc_proveedores.regimen IS NULL OR tpfc_proveedores.codcaja IS NULL OR
            tpfc_proveedores.exento_imp IS NULL OR tpfc_proveedores.estado IS NULL OR tpfc_proveedores.aficaja IS NULL 
        THEN  
        MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
            comment= "Hay campos vacios, debe completarlos ", image= "exclamation")
            COMMAND "Aceptar"
            EXIT MENU
        END MENU
        GO TO Ent_generales
        end if 
   END IF
 
 END INPUT
 --AQUI VOY
  IF int_flag THEN
  CLEAR FORM
  MENU "Información"  ATTRIBUTE(style= "dialog", 
                  comment= " La adicion fue cancelada      "  ,
                   image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    INITIALIZE tpfc_proveedores.* TO NULL
  RETURN
 END IF
 MESSAGE "ADICIONANDO INFORMACION"  ATTRIBUTE(BLUE)  

 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 if tpfc_proveedores.radicado is not null then 
 INSERT INTO com_proveedores (radicado, fecrad,inscrip,recibo, fecrec,nit,digver,razsoc,az,cedrep,
                              nomrep,direccion,dpto,ciudad,telefono,fax,mail,actividad1,actividad2,
                              actividad3,actividad4,cl_soc,tip_prov,regimen,cl_emp,g_contrib,
                              resolg, autoret,resola,exento_imp,aficaja,codcaja,fecapro,estado)
   VALUES (tpfc_proveedores.radicado, tpfc_proveedores.fecrad, tpfc_proveedores.inscrip, tpfc_proveedores.recibo,
           tpfc_proveedores.fecrec, tpfc_proveedores.nit, tpfc_proveedores.digver, tpfc_proveedores.razsoc, 
           tpfc_proveedores.az, tpfc_proveedores.cedrep, tpfc_proveedores.nomrep,tpfc_proveedores.direccion,
           tpfc_proveedores.dpto,tpfc_proveedores.ciudad,tpfc_proveedores.telefono,tpfc_proveedores.fax,
           tpfc_proveedores.mail,tpfc_proveedores.actividad1,tpfc_proveedores.actividad2,  tpfc_proveedores.actividad3,
           tpfc_proveedores.actividad4, tpfc_proveedores.cl_soc, tpfc_proveedores.tip_prov, tpfc_proveedores.regimen,
           tpfc_proveedores.cl_emp, tpfc_proveedores.g_contrib, tpfc_proveedores.resolg, tpfc_proveedores.autoret,
           tpfc_proveedores.resola,tpfc_proveedores.exento_imp, tpfc_proveedores.aficaja,tpfc_proveedores.codcaja,
           tpfc_proveedores.fecapro,tpfc_proveedores.estado)
   if sqlca.sqlcode <> 0 THEN
       

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
 end IF 
 IF NOT gerrflag THEN
  COMMIT WORK
  LET gpfc_proveedores.* = tpfc_proveedores.*
  INITIALIZE tpfc_proveedores.* TO NULL
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

FUNCTION com_proveedoresquery( exist )
DEFINE where_info, query_text  CHAR(400),
  answer                        CHAR(1),
  exist,  curr, maxnum          integer,
  tpradicado LIKE com_proveedores.radicado,
  letras string
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : CONSULTA "  ATTRIBUTE(BLUE)
CLEAR FORM
 CONSTRUCT where_info
  ON radicado, nit
  FROM radicado,nit
 IF int_flag THEN 
   MENU "Informacion " ATTRIBUTE(style= "dialog", 
  comment= " LA CONSULTA FUE CANCELADA ",  image= "exclamation")
   COMMAND "Aceptar"
     EXIT MENU
   END MENU
  RETURN exist
 END IF
 MESSAGE "Buscando el registro, por favor espere ..." ATTRIBUTE(BLINK) 
   LET query_text = " SELECT com_proveedores.radicado",
     " FROM com_proveedores WHERE ", where_info CLIPPED,
     " ORDER BY com_proveedores.radicado ASC" 

 PREPARE s_com_proveedores FROM query_text
 DECLARE c_com_proveedores SCROLL CURSOR FOR s_com_proveedores
 LET maxnum = 0
 FOREACH c_com_proveedores INTO tpradicado
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_com_proveedores
  FETCH FIRST c_com_proveedores INTO tpradicado
  LET curr = 1
  CALL com_proveedoresgetcurr( tpradicado)
  CALL com_proveedoreshowcurr( curr, maxnum )
 ELSE
  MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
   comment= "El Registro No EXISTE", image= "exclamation")
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
    FETCH FIRST c_com_proveedores INTO tpradicado
    LET curr = 1
   ELSE
    FETCH NEXT c_com_proveedores INTO tpradicado
    LET curr = curr + 1
   END IF
  CALL com_proveedoresgetcurr( tpradicado)
  CALL com_proveedoreshowcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_com_proveedores INTO tpradicado
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_com_proveedores INTO tpradicado
    LET curr = curr - 1
   END IF
  CALL com_proveedoresgetcurr( tpradicado)
  CALL com_proveedoreshowcurr( curr, maxnum )
  
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF gpfc_proveedores.radicado IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_com_proveedores
 RETURN exist
END FUNCTION

FUNCTION com_proveedoresupdate()
 DEFINE mnumero LIKE com_proveedores.radicado
 DEFINE cnt,control SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION "  ATTRIBUTE(BLUE)
 LET tpfc_proveedores.* = gpfc_proveedores.*
 INPUT BY NAME  tpfc_proveedores.radicado THRU tpfc_proveedores.aficaja  WITHOUT DEFAULTS

   AFTER FIELD radicado
   IF tpfc_proveedores.radicado IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El radicado no  puede estar vacio ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD radicado
   END IF
    
  AFTER FIELD fecrad
    IF tpfc_proveedores.fecrad IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "La fecha de radicación no puede estar vacia", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD fecrad
    END IF
 AFTER FIELD inscrip
    IF tpfc_proveedores.inscrip IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El código inscrip?? No fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD inscrip
    END IF
    
 AFTER FIELD fecrec
   IF tpfc_proveedores.fecrec IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "La fecha de recibido no fue establecida ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD fecrec
   END IF 
    AFTER FIELD recibo
   IF tpfc_proveedores.recibo IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El número de recibo No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD recibo
   END IF
   
 AFTER FIELD az
   IF tpfc_proveedores.az IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "Elaz??  No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD az
   END IF 

  AFTER FIELD fecapro 

     IF tpfc_proveedores.fecapro IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La fecha de aprobación no fue seleccionada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD fecapro
    END IF 
   
 AFTER FIELD razsoc
   IF tpfc_proveedores.razsoc IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La razón social no fue digitada",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD razsoc
   END IF

  AFTER FIELD nit
   IF tpfc_proveedores.nit IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Nit del proveedor No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nit
   END IF
  
 AFTER FIELD digver
    IF tpfc_proveedores.digver IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El digito de verificacion No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD digver
    END IF

 AFTER FIELD cedrep
    IF tpfc_proveedores.cedrep IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= " La cédula del representante NO fue digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD cedrep
   END IF 
   
 AFTER FIELD nomrep
    IF tpfc_proveedores.nomrep IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "el Nombre del representante no fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nomrep
   END IF
  AFTER FIELD dpto
    IF tpfc_proveedores.dpto IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El departamento no fue seleccionado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD dpto
   END IF  

     AFTER FIELD ciudad
    IF tpfc_proveedores.ciudad IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La ciudad no fue seleccionada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD ciudad
   END IF  

    AFTER FIELD telefono
    IF tpfc_proveedores.telefono IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El telefono no fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD telefono
   END IF  

    AFTER FIELD direccion
    IF tpfc_proveedores.direccion IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La dirección no fue digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD dirección
   END IF  

   AFTER FIELD fax
    IF tpfc_proveedores.fax IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La dirección no fue digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD fax
   END IF  

   AFTER FIELD mail
    IF tpfc_proveedores.mail IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El E-mail no fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD mail
   END IF  

   AFTER FIELD g_contrib
    IF tpfc_proveedores.g_contrib IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "Si es gran Contribuyente no fue seleccionado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD g_contrib
   END IF  

    AFTER FIELD autoret
    IF tpfc_proveedores.autoret IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "Si es Auto Retenedor no fue seleccionado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD autoret
   END IF  

    AFTER FIELD actividad1
    IF tpfc_proveedores.actividad1 IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La actividad 1 NO fue seleccionada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD actividad1
   END IF  

   AFTER FIELD actividad2
    IF tpfc_proveedores.actividad2 IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La actividad 2 NO fue seleccionada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD actividad2
   END IF 

  AFTER FIELD actividad3
    IF tpfc_proveedores.actividad3 IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La actividad 3 NO fue seleccionada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD actividad3
   END IF  

   AFTER FIELD actividad4
    IF tpfc_proveedores.actividad4 IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La actividad 4 NO fue seleccionada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD actividad4
   END IF 
 
     AFTER FIELD cl_soc
    IF tpfc_proveedores.cl_soc IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La cl_soc NO fue digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD cl_soc
   END IF 
   
    AFTER FIELD cl_emp
    IF tpfc_proveedores.cl_emp IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La cl_emp NO fue digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD cl_emp
   END IF 

    AFTER FIELD resolg
    IF tpfc_proveedores.resolg IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La resolg NO fue digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD resolg
   END IF 

   AFTER FIELD resola
    IF tpfc_proveedores.resolg IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La resola NO fue digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD resola
   END IF 

    AFTER FIELD regimen
    IF tpfc_proveedores.regimen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La regimen NO fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD regimen
   END IF 

   AFTER FIELD codcaja
    IF tpfc_proveedores.codcaja IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La Código de Caja NO fue digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD codcaja
   END IF 

   AFTER FIELD exento_imp
    IF tpfc_proveedores.exento_imp IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "Si es exento de impuestos no fue seleccionado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD exento_imp
   END IF 

   AFTER FIELD estado
    IF tpfc_proveedores.estado IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El estado no fue seleccionado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD estado
   END IF 

    AFTER FIELD aficaja
    IF tpfc_proveedores.aficaja IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "Si es afiliado a la caja no fue seleccionado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD aficaja
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
  INITIALIZE tpfc_proveedores.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION " AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 UPDATE  com_proveedores
 SET (radicado,fecrad,inscrip,fecrec,recibo,az,fecapro,razsoc,nit,digver,cedrep,nomrep,dpto,ciudad,
      telefono,direccion,fax,mail,g_contrib,autoret,actividad1,actividad2,actividad3,actividad4,cl_soc,cl_emp,
      resolg,resola,regimen,codcaja,exento_imp,estado,aficaja) 
    =(tpfc_proveedores.radicado,tpfc_proveedores.fecrad,tpfc_proveedores.inscrip,tpfc_proveedores.fecrec,tpfc_proveedores.recibo,
    tpfc_proveedores.az,tpfc_proveedores.fecapro,tpfc_proveedores.razsoc,tpfc_proveedores.nit,tpfc_proveedores.digver,
    tpfc_proveedores.cedrep,tpfc_proveedores.nomrep,tpfc_proveedores.dpto,tpfc_proveedores.ciudad,
    tpfc_proveedores.telefono,tpfc_proveedores.direccion,tpfc_proveedores.fax,tpfc_proveedores.mail,
    tpfc_proveedores.g_contrib,tpfc_proveedores.autoret,tpfc_proveedores.actividad1,tpfc_proveedores.actividad2,
    tpfc_proveedores.actividad3,tpfc_proveedores.actividad4,tpfc_proveedores.cl_soc,tpfc_proveedores.cl_emp,
    tpfc_proveedores.resolg,tpfc_proveedores.resola,tpfc_proveedores.regimen,tpfc_proveedores.codcaja,
    tpfc_proveedores.exento_imp,tpfc_proveedores.estado,tpfc_proveedores.aficaja) 
 WHERE  radicado=gpfc_proveedores.radicado
 
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
  LET gpfc_proveedores.* = tpfc_proveedores.*
 END IF
END FUNCTION  

FUNCTION com_proveedoresgetcurr( tpradicado )
  DEFINE letras string
  DEFINE tpradicado LIKE com_proveedores.radicado

  INITIALIZE gpfc_proveedores.* TO NULL
  SELECT com_proveedores.radicado,com_proveedores.fecrad,com_proveedores.inscrip,com_proveedores.fecrec,com_proveedores.recibo,
        com_proveedores.az,com_proveedores.fecapro,com_proveedores.razsoc,com_proveedores.nit,com_proveedores.digver,
        com_proveedores.cedrep,com_proveedores.nomrep,com_proveedores.dpto,ciudad,
        com_proveedores.telefono,com_proveedores.direccion,com_proveedores.fax,com_proveedores.mail,
        com_proveedores.g_contrib,com_proveedores.autoret,com_proveedores.actividad1,com_proveedores.actividad2,
        com_proveedores.actividad3,com_proveedores.actividad4,com_proveedores.cl_soc,com_proveedores.cl_emp,
        com_proveedores.resolg,com_proveedores.resola,com_proveedores.regimen,com_proveedores.codcaja,
        com_proveedores.exento_imp,com_proveedores.estado,com_proveedores.aficaja
   INTO gpfc_proveedores.* 
   FROM com_proveedores
   WHERE com_proveedores.radicado = tpradicado
END FUNCTION

FUNCTION com_proveedoreshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum INTEGER
 IF gpfc_proveedores.radicado IS NULL  THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum,
          "/ Existen ", maxnum, ")"
 END IF
 CALL com_proveedoresdplyg()
END FUNCTION

FUNCTION com_proveedoresremove()
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : RETIRO DE REGISTROS" ATTRIBUTE(BLUE)
 PROMPT "Esta seguro de borrar  (s/n)? " FOR CHAR answer
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO  REGISTRO " ATTRIBUTE(BLUE)
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  DELETE FROM com_proveedores
    WHERE com_proveedores.radicado =gpfc_proveedores.radicado
  IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
   IF NOT gerrflag THEN 
   INITIALIZE gpfc_proveedores.* TO NULL
   MENU "Información"  ATTRIBUTE( style= "dialog", 
                             comment= " El Registro fue Retirado",
                             image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   COMMIT WORK
  ELSE
   MENU "Información"  ATTRIBUTE( style= "dialog", 
     comment= " El Retiro del Registro fue Cancelado",  image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   ROLLBACK WORK
  END IF
 ELSE
  MENU "Información"  ATTRIBUTE( style= "dialog", 
    comment= " El Retiro del Registro fue Cancelado",image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  LET int_flag = TRUE
 END IF
END FUNCTION

FUNCTION com_proveedoresdplyg()
DISPLAY BY NAME gpfc_proveedores.radicado THRU gpfc_proveedores.aficaja
END FUNCTION
