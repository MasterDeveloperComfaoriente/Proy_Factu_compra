GLOBALS "fe_globales.4gl"
DEFINE gmedpagaux, tpmedpagaux RECORD
  auxiliar_ef    LIKE fe_medio_pago_aux.auxiliar_ef,
  cencos_ef    LIKE fe_medio_pago_aux.cencos_ef,
  auxiliar_tc    LIKE fe_medio_pago_aux.auxiliar_tc,
  cencos_tc    LIKE fe_medio_pago_aux.cencos_tc,
  auxiliar_td    LIKE fe_medio_pago_aux.auxiliar_td,
  cencos_td    LIKE fe_medio_pago_aux.cencos_td,
  auxiliar_co    LIKE fe_medio_pago_aux.auxiliar_co,
  cencos_co    LIKE fe_medio_pago_aux.cencos_co,
  auxiliar_ch    LIKE fe_medio_pago_aux.auxiliar_ch,
  cencos_ch    LIKE fe_medio_pago_aux.cencos_ch,
  auxiliar_tr    LIKE fe_medio_pago_aux.auxiliar_tr,
  cencos_tr    LIKE fe_medio_pago_aux.cencos_tr
END RECORD 
 FUNCTION medpagauxmain()
 DEFINE exist  SMALLINT
 OPEN WINDOW w_mmedpagaux AT 1,1 WITH FORM "fe_medio_pago_aux"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gmedpagaux.* TO NULL
 INITIALIZE tpmedpagaux.* TO NULL
 
   
 CALL medpagauxgetcurr()
 DISPLAY BY NAME gmedpagaux.auxiliar_ef THRU gmedpagaux.auxiliar_tr
 DISPLAY mcon233ef.detalle to formonly.detalle1
 DISPLAY mcon233tc.detalle to formonly.detalle2
 DISPLAY mcon233td.detalle to formonly.detalle3
 DISPLAY mcon233co.detalle to formonly.detalle4
 DISPLAY mcon233ch.detalle to formonly.detalle5
 DISPLAY mcon233tr.detalle to formonly.detalle6
 DISPLAY mcon147ef.detalle to formonly.detalle7
 DISPLAY mcon147tc.detalle to formonly.detalle8
 DISPLAY mcon147td.detalle to formonly.detalle9
 DISPLAY mcon147co.detalle to formonly.detalle10
 DISPLAY mcon147ch.detalle to formonly.detalle11
 DISPLAY mcon147tr.detalle to formonly.detalle12
 MENU 
  COMMAND "Actualiza" "Actualiza el registro de parametros contables "
   LET mcodmen="FE01"
   CALL opcion() RETURNING op
   if op="S" THEN
     CALL medpagauxupdate()
   END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mmedpagaux
END FUNCTION


FUNCTION medpagauxupdate()
 DEFINE cnt SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : ACTUALIZANDO EL REGISTRO DE PARAMETROS"  ATTRIBUTE(BLUE)
 LET tpmedpagaux.* = gmedpagaux.*
 INPUT BY NAME tpmedpagaux.auxiliar_ef THRU tpmedpagaux.cencos_tr WITHOUT DEFAULTS

  AFTER FIELD auxiliar_ef
   IF tpmedpagaux.auxiliar_ef = "?" THEN
    LET op="1"
    LET tpmedpagaux.auxiliar_ef = villac02val()
    LET tpmedpagaux.auxiliar_ef=tpmedpagaux.auxiliar_ef clipped,"000000"
    DISPLAY BY NAME tpmedpagaux.auxiliar_ef
   END IF
   IF tpmedpagaux.auxiliar_ef IS NOT NULL THEN
    LET tpmedpagaux.auxiliar_ef=tpmedpagaux.auxiliar_ef clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpmedpagaux.auxiliar_ef 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpmedpagaux.auxiliar_ef TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliar_ef
    END IF
   END IF
   IF tpmedpagaux.auxiliar_ef IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpmedpagaux.auxiliar_ef
    DISPLAY mniif233.detalle to formonly.detalle1
   END IF

  AFTER FIELD cencos_ef
   IF tpmedpagaux.cencos_ef = "?" THEN
    LET tpmedpagaux.cencos_ef = villac06val()
    DISPLAY BY NAME tpmedpagaux.cencos_ef
   END IF
   IF tpmedpagaux.cencos_ef IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpmedpagaux.cencos_ef
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpmedpagaux.cencos_ef TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencos_ef
    END IF
   END IF
   IF tpmedpagaux.cencos_ef IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpmedpagaux.cencos_ef
    DISPLAY mniif147.detalle to formonly.detalle7
   END IF


   
  AFTER FIELD auxiliar_tc
   IF tpmedpagaux.auxiliar_tc = "?" THEN
    LET op="1"
    LET tpmedpagaux.auxiliar_tc = villac02val()
    LET tpmedpagaux.auxiliar_tc=tpmedpagaux.auxiliar_tc clipped,"000000"
    DISPLAY BY NAME tpmedpagaux.auxiliar_tc
   END IF
   IF tpmedpagaux.auxiliar_tc IS NOT NULL THEN
    LET tpmedpagaux.auxiliar_tc=tpmedpagaux.auxiliar_tc clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpmedpagaux.auxiliar_tc 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpmedpagaux.auxiliar_tc TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliar_tc
    END IF
   END IF
   IF tpmedpagaux.auxiliar_tc IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpmedpagaux.auxiliar_tc
    DISPLAY mniif233.detalle to formonly.detalle2
   END IF 

AFTER FIELD cencos_tc
   IF tpmedpagaux.cencos_tc = "?" THEN
    LET tpmedpagaux.cencos_tc = villac06val()
    DISPLAY BY NAME tpmedpagaux.cencos_tc
   END IF
   IF tpmedpagaux.cencos_tc IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpmedpagaux.cencos_tc
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpmedpagaux.cencos_tc TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencos_tc
    END IF
   END IF
   IF tpmedpagaux.cencos_tc IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpmedpagaux.cencos_tc
    DISPLAY mniif147.detalle to formonly.detalle8
   END IF

   

  AFTER FIELD auxiliar_td
   IF tpmedpagaux.auxiliar_td = "?" THEN
    LET op="1"
    LET tpmedpagaux.auxiliar_td = villac02val()
    LET tpmedpagaux.auxiliar_td=tpmedpagaux.auxiliar_td clipped,"000000"
    DISPLAY BY NAME tpmedpagaux.auxiliar_td
   END IF
   IF tpmedpagaux.auxiliar_td IS NOT NULL THEN
    LET tpmedpagaux.auxiliar_td=tpmedpagaux.auxiliar_td clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpmedpagaux.auxiliar_td 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpmedpagaux.auxiliar_td TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliar_td
    END IF
   END IF
   IF tpmedpagaux.auxiliar_td IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpmedpagaux.auxiliar_td
    DISPLAY mniif233.detalle to formonly.detalle3
   END IF  


AFTER FIELD cencos_td
   IF tpmedpagaux.cencos_td = "?" THEN
    LET tpmedpagaux.cencos_td = villac06val()
    DISPLAY BY NAME tpmedpagaux.cencos_td
   END IF
   IF tpmedpagaux.cencos_td IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpmedpagaux.cencos_td
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpmedpagaux.cencos_td TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencos_td
    END IF
   END IF
   IF tpmedpagaux.cencos_td IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpmedpagaux.cencos_td
    DISPLAY mniif147.detalle to formonly.detalle9
   END IF
   

  AFTER FIELD auxiliar_co
   IF tpmedpagaux.auxiliar_co = "?" THEN
    LET op="1"
    LET tpmedpagaux.auxiliar_co = villac02val()
    LET tpmedpagaux.auxiliar_co=tpmedpagaux.auxiliar_co clipped,"000000"
    DISPLAY BY NAME tpmedpagaux.auxiliar_co
   END IF
   IF tpmedpagaux.auxiliar_co IS NOT NULL THEN
    LET tpmedpagaux.auxiliar_co=tpmedpagaux.auxiliar_co clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpmedpagaux.auxiliar_co 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpmedpagaux.auxiliar_co TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliar_co
    END IF
   END IF
   IF tpmedpagaux.auxiliar_co IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpmedpagaux.auxiliar_co
    DISPLAY mniif233.detalle to formonly.detalle4
   END IF  


AFTER FIELD cencos_co
   IF tpmedpagaux.cencos_co = "?" THEN
    LET tpmedpagaux.cencos_co = villac06val()
    DISPLAY BY NAME tpmedpagaux.cencos_co
   END IF
   IF tpmedpagaux.cencos_co IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpmedpagaux.cencos_co
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpmedpagaux.cencos_co TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencos_co
    END IF
   END IF
   IF tpmedpagaux.cencos_co IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpmedpagaux.cencos_co
    DISPLAY mniif147.detalle to formonly.detalle10
   END IF

   
  AFTER FIELD auxiliar_ch
   IF tpmedpagaux.auxiliar_ch = "?" THEN
    LET op="1"
    LET tpmedpagaux.auxiliar_ch = villac02val()
    LET tpmedpagaux.auxiliar_ch=tpmedpagaux.auxiliar_ch clipped,"000000"
    DISPLAY BY NAME tpmedpagaux.auxiliar_ch
   END IF
   IF tpmedpagaux.auxiliar_ch IS NOT NULL THEN
    LET tpmedpagaux.auxiliar_ch=tpmedpagaux.auxiliar_ch clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpmedpagaux.auxiliar_ch 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpmedpagaux.auxiliar_ch TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliar_ch
    END IF
   END IF
   IF tpmedpagaux.auxiliar_ch IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpmedpagaux.auxiliar_ch
    DISPLAY mniif233.detalle to formonly.detalle5
   END IF  

AFTER FIELD cencos_ch
   IF tpmedpagaux.cencos_ch = "?" THEN
    LET tpmedpagaux.cencos_ch = villac06val()
    DISPLAY BY NAME tpmedpagaux.cencos_ch
   END IF
   IF tpmedpagaux.cencos_ch IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpmedpagaux.cencos_ch
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpmedpagaux.cencos_ch TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencos_ch
    END IF
   END IF
   IF tpmedpagaux.cencos_ch IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpmedpagaux.cencos_ch
    DISPLAY mniif147.detalle to formonly.detalle11
   END IF

   
  AFTER FIELD auxiliar_tr
   IF tpmedpagaux.auxiliar_tr = "?" THEN
    LET op="1"
    LET tpmedpagaux.auxiliar_tr = villac02val()
    LET tpmedpagaux.auxiliar_tr=tpmedpagaux.auxiliar_tr clipped,"000000"
    DISPLAY BY NAME tpmedpagaux.auxiliar_tr
   END IF
   IF tpmedpagaux.auxiliar_tr IS NOT NULL THEN
    LET tpmedpagaux.auxiliar_tr=tpmedpagaux.auxiliar_tr clipped,"000000"
    INITIALIZE mniif233.* TO NULL
    SELECT * INTO mniif233.* FROM niif233
     WHERE auxiliar=tpmedpagaux.auxiliar_tr 
    IF mniif233.auxiliar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Auxiliar Contable No Fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpmedpagaux.auxiliar_tr TO NULL
     INITIALIZE mniif233.* TO NULL
     NEXT FIELD auxiliar_tr
    END IF
   END IF
   IF tpmedpagaux.auxiliar_tr IS NOT NULL THEN
    INITIALIZE mniif233.* TO NULL
    SELECT * into mniif233.* from niif233 where auxiliar=tpmedpagaux.auxiliar_tr
    DISPLAY mniif233.detalle to formonly.detalle5
   END IF  


AFTER FIELD cencos_tr
   IF tpmedpagaux.cencos_tr = "?" THEN
    LET tpmedpagaux.cencos_tr = villac06val()
    DISPLAY BY NAME tpmedpagaux.cencos_tr
   END IF
   IF tpmedpagaux.cencos_tr IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * INTO mniif147.* FROM niif147 WHERE codcen = tpmedpagaux.cencos_tr
    IF mniif147.codcen IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment="El Centro de Costo No fue Digitado",
       image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU  
     INITIALIZE tpmedpagaux.cencos_tr TO NULL
     INITIALIZE mniif147.* TO NULL
     NEXT FIELD cencos_tr
    END IF
   END IF
   IF tpmedpagaux.cencos_tr IS NOT NULL THEN
    INITIALIZE mniif147.* TO NULL
    SELECT * into mniif147.* from niif147 where codcen=tpmedpagaux.cencos_tr
    DISPLAY mniif147.detalle to formonly.detalle12
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
  INITIALIZE tpmedpagaux.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION DE PARAMETROS CONTABLES" AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 LET cnt = 0
 select count(*) INTO cnt FROM fe_medio_pago_aux
 if cnt is null or cnt = 0 then
   INSERT INTO fe_medio_pago_aux
   values (tpmedpagaux.*)
   IF status <> 0 THEN
    MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
     comment= " No se Adiciono.. Registro referenciado  "  , image= "stop")
        COMMAND "Aceptar"
          EXIT MENU
      END MENU
    LET  gerrflag = TRUE
   END IF 
 else
   UPDATE fe_medio_pago_aux
   SET (auxiliar_ef, cencos_ef, auxiliar_tc, cencos_tc, auxiliar_td, cencos_td, auxiliar_co, cencos_co, auxiliar_ch, cencos_ch, auxiliar_tr, cencos_tr )
   = (tpmedpagaux.auxiliar_ef, tpmedpagaux.cencos_ef, tpmedpagaux.auxiliar_tc, tpmedpagaux.cencos_tc, tpmedpagaux.auxiliar_td, tpmedpagaux.cencos_td, tpmedpagaux.auxiliar_co, tpmedpagaux.cencos_co, 
      tpmedpagaux.auxiliar_ch, tpmedpagaux.cencos_ch, tpmedpagaux.auxiliar_tr, tpmedpagaux.cencos_tr)
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
  LET gmedpagaux.* = tpmedpagaux.*
 END IF
END FUNCTION  

FUNCTION medpagauxgetcurr( )
  INITIALIZE gmedpagaux.* TO NULL
  SELECT *  INTO gmedpagaux.*  FROM fe_medio_pago_aux
  initialize mcon233ef.* to null
  select * into mcon233ef.* from niif233 where auxiliar=gmedpagaux.auxiliar_ef
  initialize mcon233tc.* to null
  select * into mcon233tc.* from niif233 where auxiliar=gmedpagaux.auxiliar_tc
  initialize mcon233td.* to null
  select * into mcon233td.* from niif233 where auxiliar=gmedpagaux.auxiliar_td
  initialize mcon233co.* to null
  select * into mcon233co.* from niif233 where auxiliar=gmedpagaux.auxiliar_co
  initialize mcon233ch.* to null
  select * into mcon233ch.* from niif233 where auxiliar=gmedpagaux.auxiliar_ch
  initialize mcon233tr.* to null
  select * into mcon233tr.* from niif233 where auxiliar=gmedpagaux.auxiliar_tr

  initialize mcon147ef.* to null
  select * into mcon147ef.* from niif147 where codcen=gmedpagaux.cencos_ef
  initialize mcon147tc.* to null
  select * into mcon147tc.* from niif147 where codcen=gmedpagaux.cencos_tc
  initialize mcon147td.* to null
  select * into mcon147td.* from niif147 where codcen=gmedpagaux.cencos_td
  initialize mcon147co.* to null
  select * into mcon147co.* from niif147 where codcen=gmedpagaux.cencos_co
  initialize mcon147ch.* to null
  select * into mcon147ch.* from niif147 where codcen=gmedpagaux.cencos_ch
  initialize mcon147tr.* to null
  select * into mcon147tr.* from niif147 where codcen=gmedpagaux.cencos_tr
  
END FUNCTION


