GLOBALS "globales_eps.4gl" 
DEFINE tpeps_generales,geps_generales RECORD
  niteps          LIKE eps_generales.niteps,
  nombre_eps      LIKE eps_generales.nombre_eps,
  codeps          LIKE eps_generales.codeps,
  cedrep          LIKE eps_generales.cedrep,
  nombrerep       LIKE eps_generales.nombrerep,
  cedger          LIKE eps_generales.cedger,
  nombreger       LIKE eps_generales.nombreger,
  cedrev          LIKE eps_generales.cedrev,
  nombrerev       LIKE eps_generales.nombrerev,
  nitrecaudador   LIKE eps_generales.nitrecaudador,
  digverrec       LIKE eps_generales.digverrec,
  nombrerec       LIKE eps_generales.nombrerec,
  periodocar      LIKE eps_generales.periodocar,
  codepss         LIKE eps_generales.codepss,
  soltraslado     LIKE eps_generales.soltraslado,
  sec_gastos_c    LIKE eps_generales.sec_gastos_c,
  sec_gastos_s    LIKE eps_generales.sec_gastos_s
END RECORD 

--declaracion del combobox 
DEFINE  cb_codope ui.combobox
FUNCTION eps_generalesmain()
 DEFINE exist  SMALLINT
 OPEN WINDOW w_meps_generales  AT 1,1 WITH FORM "eps_generales"
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE tpeps_generales.* TO NULL
{ combobox de la bd

 LET cb_codope  = ui.Combobox.forName("eps_beneficiarios_abx.codope")
   CALL cb_codope.clear()
   
}

{ combobox estatico
   LET cmb_estado = ui.ComboBox.forName("nomin02.estado")
   CALL cmb_estado.clear()
   CALL cmb_estado.addItem("A","ACTIVO")
   CALL cmb_estado.addItem("I","INACTIVO")

}
  MENU
   COMMAND "Adiciona" "Adiciona "
  -- LET mcodmen=""
   --CALL opcion() RETURNING op
   --if op="S" THEN
    CALL eps_generalesadd()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
    --END if
 COMMAND "Consulta" "Consultar Información Registrada "
    --LET mcodmen=""
    --CALL opcion() RETURNING op
    --if op="S" THEN
     CALL eps_generalesquery( exist ) RETURNING exist
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CLEAR FORM
     END IF
    --END IF
  call 
 END MENU
 CLOSE WINDOW w_meps_generales 
END FUNCTION

FUNCTION eps_generalesdplyg()
DISPLAY BY NAME geps_generales.niteps THRU geps_generales.sec_gastos_s
END FUNCTION

FUNCTION eps_generalesgetcurr( tpniteps )
  DEFINE letras string
  DEFINE tpniteps LIKE eps_generales.niteps

  INITIALIZE geps_generales.* TO NULL
  SELECT eps_generales.niteps,eps_generales.nombre_eps,eps_generales.codeps,eps_generales.cedrep,eps_generales.nombrerep,
  eps_generales.cedger,eps_generales.nombreger,eps_generales.cedrev,eps_generales.nombrerev,eps_generales.nitrecaudador,
  eps_generales.digverrec,eps_generales.nombrerec,eps_generales.periodocar,
  eps_generales.codepss,eps_generales.soltraslado,eps_generales.sec_gastos_c,eps_generales.sec_gastos_s
   INTO geps_generales.* 
   FROM eps_generales
   WHERE eps_generales.niteps = tpniteps
END FUNCTION

FUNCTION eps_generaleshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum INTEGER
 IF geps_generales.niteps IS NULL  THEN
  MESSAGE "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum, 
          ") ( Borrado )" 
 ELSE
  MESSAGE "Localizacion : ( Actual ", rownum,
          "/ Existen ", maxnum, ")"
 END IF
 CALL eps_generalesdplyg()
END FUNCTION

FUNCTION eps_generalesadd()
 DEFINE mnumero LIKE eps_generales.niteps 
 DEFINE control SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 CLEAR FORM
 MESSAGE "ESTADO: ADICIONANDO REGISTROS"  ATTRIBUTE(BLUE)
 INITIALIZE tpeps_generales.* TO NULL
lABEL Ent_generales:
 INPUT BY NAME tpeps_generales.niteps THRU tpeps_generales.sec_gastos_s WITHOUT DEFAULTS
 
 AFTER FIELD niteps 
   IF tpeps_generales.niteps IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= " El NIT no fue digitado ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD niteps
  END IF
     LET control = NULL 
   SELECT count(*) INTO control FROM eps_generales 
     WHERE eps_generales.niteps=tpeps_generales.niteps 
   DISPLAY ":",control  
   IF control<>0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El NIT ya esta registrado  ",
             image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
      END MENU
      NEXT FIELD niteps
    END IF
    
  AFTER FIELD nombre_eps
   IF tpeps_generales.nombre_eps IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El Nombre dela Eps  no puede estar vacio ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD nombre_eps
   END IF
    
  AFTER FIELD codeps
    IF tpeps_generales.codeps IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El codigo de la Eps No fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD codeps
    END IF
 AFTER FIELD cedrep
    IF tpeps_generales.cedrep IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "La Cedula del Representante No fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD cedrep
    END IF
    
 AFTER FIELD nombrerep
   IF tpeps_generales.nombrerep IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Nombre del Representante No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nombrerep
   END IF 
    AFTER FIELD cedger
   IF tpeps_generales.cedger IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "La cedula del Gerente  No fue Digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD cedger
   END IF
   
 AFTER FIELD nombreger
   IF tpeps_generales.nombreger IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Nombre del Gerente  No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nombreger
   END IF 

  AFTER FIELD cedrev 

     IF tpeps_generales.cedrev IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La cedula del Rev Fiscal No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD cedrev
    END IF 
   
 AFTER FIELD nombrerev
   IF tpeps_generales.nombrerev IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Nombre del Rev Fiscal No fue Digitada",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nombrerev
   END IF

  AFTER FIELD nitrecaudador
   IF tpeps_generales.nitrecaudador IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Nit del Recaudador de Pago No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nitrecaudador
   END IF
  
 AFTER FIELD digverrec
    IF tpeps_generales.digverrec IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El digito de verificacion No fue Digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD digverrec
    END IF

 AFTER FIELD nombrerec
    IF tpeps_generales.nombrerec IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Nombre del Recaudador No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nombrerec
   END IF 
   
 AFTER FIELD periodocar
    IF tpeps_generales.periodocar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "el Periodo No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD periodocar
   END IF
  AFTER FIELD codepss
    IF tpeps_generales.codepss IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Codigo del Epss No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD codepss
   END IF  

     AFTER FIELD soltraslado
    IF tpeps_generales.soltraslado IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Sol. Traslado No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD soltraslado
   END IF  
 
   
  AFTER INPUT
   IF int_flag THEN
      EXIT INPUT
   ELSE
     IF tpeps_generales.niteps IS NULL OR  tpeps_generales.nombre_eps IS NULL OR  tpeps_generales.codeps IS NULL OR tpeps_generales.cedrep IS NULL 
      OR tpeps_generales.nombrerep IS NULL OR tpeps_generales.cedger IS NULL  OR tpeps_generales.nombreger IS NULL
      OR tpeps_generales.cedrev IS NULL  OR tpeps_generales.nombrerev IS NULL OR tpeps_generales.nitrecaudador IS NULL 
      OR tpeps_generales.digverrec IS NULL OR tpeps_generales.nombrerec IS NULL OR tpeps_generales.periodocar IS NULL 
      OR tpeps_generales.codepss IS NULL OR tpeps_generales.soltraslado IS NULL 
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
    INITIALIZE tpeps_generales.* TO NULL
  RETURN
 END IF
 MESSAGE "ADICIONANDO INFORMACION"  ATTRIBUTE(BLUE)
 LET gerrflag = FALSE
 BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 if tpeps_generales.niteps is not null then 
 INSERT INTO eps_generales (niteps,nombre_eps,codeps,cedrep,nombrerep,cedger,nombreger,cedrev,nombrerev,
            nitrecaudador,digverrec,nombrerec,periodocar,codepss,soltraslado,sec_gastos_c,sec_gastos_s)
   VALUES (tpeps_generales.niteps,tpeps_generales.nombre_eps,tpeps_generales.codeps,tpeps_generales.cedrep,tpeps_generales.nombrerep,tpeps_generales.cedger,
    tpeps_generales.nombreger,tpeps_generales.cedrev,tpeps_generales.nombrerev,
    tpeps_generales.nitrecaudador,tpeps_generales.digverrec,tpeps_generales.nombrerec,
    tpeps_generales.periodocar,tpeps_generales.codepss,tpeps_generales.soltraslado,tpeps_generales.sec_gastos_c,tpeps_generales.sec_gastos_s)
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
  LET geps_generales.* = tpeps_generales.*
  INITIALIZE tpeps_generales.* TO NULL
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

FUNCTION eps_generalesquery( exist )
DEFINE where_info, query_text  CHAR(400),
  answer                        CHAR(1),
  exist,  curr, maxnum          integer,
  tpniteps LIKE eps_generales.niteps,
  letras string
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : CONSULTA "  ATTRIBUTE(BLUE)
CLEAR FORM
 CONSTRUCT where_info
  ON niteps,nombre_eps
  FROM niteps,nombre_eps
 IF int_flag THEN 
   MENU "Informacion " ATTRIBUTE(style= "dialog", 
  comment= " LA CONSULTA FUE CANCELADA ",  image= "exclamation")
   COMMAND "Aceptar"
     EXIT MENU
   END MENU
  RETURN exist
 END IF
 MESSAGE "Buscando el registro, por favor espere ..." ATTRIBUTE(BLINK)
   LET query_text = " SELECT eps_generales.niteps",
     " FROM eps_generales WHERE ", where_info CLIPPED,
     " ORDER BY eps_generales.niteps ASC" 

 PREPARE s_seps_generales FROM query_text
 DECLARE c_seps_generales SCROLL CURSOR FOR s_seps_generales
 LET maxnum = 0
 FOREACH c_seps_generales INTO tpniteps
  LET maxnum = maxnum + 1
 END FOREACH
 IF ( maxnum > 0 ) THEN
  OPEN c_seps_generales
  FETCH FIRST c_seps_generales INTO tpniteps
  LET curr = 1
  CALL eps_generalesgetcurr( tpniteps)
  CALL eps_generaleshowcurr( curr, maxnum )
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
    FETCH FIRST c_seps_generales INTO tpniteps
    LET curr = 1
   ELSE
    FETCH NEXT c_seps_generales INTO tpniteps
    LET curr = curr + 1
   END IF
  CALL eps_generalesgetcurr( tpniteps)
  CALL eps_generaleshowcurr( curr, maxnum )
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF ( curr = 1 ) THEN
    FETCH LAST c_seps_generales INTO tpniteps
    LET curr = maxnum
   ELSE
    FETCH PREVIOUS c_seps_generales INTO tpniteps
    LET curr = curr - 1
   END IF
  CALL eps_generalesgetcurr( tpniteps)
  CALL eps_generaleshowcurr( curr, maxnum )
   
  COMMAND "Modifica" "Modifica el Registro en consulta"
 {  LET mcodmen="T004"
   CALL opcion() RETURNING op
   if op="S" THEN }
    IF geps_generales.niteps IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_seps_generales
     CALL eps_generalesupdate()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL eps_generalesgetcurr( tpniteps)
     CALL eps_generaleshowcurr( curr, maxnum )
     OPEN c_seps_generales
    END IF
  -- END IF
  COMMAND "Borra" "Borra el Registro en consulta"
  { LET mcodmen="T005"
   CALL opcion() RETURNING op
   if op="S" THEN} 
    IF geps_generales.niteps IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_seps_generales
     CALL eps_generalesremove()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
       CALL eps_generaleshowcurr( curr, maxnum )
     END IF
     OPEN c_seps_generales
    END IF
   --END IF
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   IF geps_generales.niteps IS NULL THEN
    LET exist = FALSE
   ELSE 
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_seps_generales
 RETURN exist
END FUNCTION

FUNCTION eps_generalesupdate()
 DEFINE mnumero LIKE eps_generales.niteps
 DEFINE cnt,control SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION "  ATTRIBUTE(BLUE)
 LET tpeps_generales.* = geps_generales.*
 INPUT BY NAME  tpeps_generales.nombre_eps THRU tpeps_generales.sec_gastos_s  WITHOUT DEFAULTS

   AFTER FIELD nombre_eps
   IF tpeps_generales.nombre_eps IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El Nombre dela Eps  no puede estar vacio ", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD nombre_eps
   END IF
    
  AFTER FIELD codeps
    IF tpeps_generales.codeps IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "El codigo de la Eps No fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD codeps
    END IF
 AFTER FIELD cedrep
    IF tpeps_generales.cedrep IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
      comment= "La Cedula del Representante No fue Digitado", image= "exclamation")
       COMMAND "Aceptar"
        EXIT MENU
     END MENU
    NEXT FIELD cedrep
    END IF
    
 AFTER FIELD nombrerep
   IF tpeps_generales.nombrerep IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Nombre del Representante No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nombrerep
   END IF 
    AFTER FIELD cedger
   IF tpeps_generales.cedger IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "La cedula del Gerente  No fue Digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD cedger
   END IF
   
 AFTER FIELD nombreger
   IF tpeps_generales.nombreger IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
         comment= "El Nombre del Gerente  No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nombreger
   END IF 

  AFTER FIELD cedrev 

     IF tpeps_generales.cedrev IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "La cedula del Rev Fiscal No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD cedrev
    END IF 
   
 AFTER FIELD nombrerev
   IF tpeps_generales.nombrerev IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Nombre del Rev Fiscal No fue Digitada",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nombrerev
   END IF

  AFTER FIELD nitrecaudador
   IF tpeps_generales.nitrecaudador IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Nit del Recaudador de Pago No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nitrecaudador
   END IF
  
 AFTER FIELD digverrec
    IF tpeps_generales.digverrec IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El digito de verificacion No fue Digitada ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD digverrec
    END IF

 AFTER FIELD nombrerec
    IF tpeps_generales.nombrerec IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Nombre del Recaudador No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD nombrerec
   END IF 
   
 AFTER FIELD periodocar
    IF tpeps_generales.periodocar IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "el Periodo No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD periodocar
   END IF
  AFTER FIELD codepss
    IF tpeps_generales.codepss IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Codigo del Epss No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD codepss
   END IF  

     AFTER FIELD soltraslado
    IF tpeps_generales.soltraslado IS NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog",
            comment= "El Sol. Traslado No fue Digitado ",
                              image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
     END MENU
    NEXT FIELD soltraslado
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
  INITIALIZE tpeps_generales.* TO NULL
  RETURN
 END IF
 LET gerrflag = FALSE
 BEGIN WORK
 DISPLAY "MODIFICANDO LA INFORMACION " AT 1,10 ATTRIBUTE(BLUE)
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 UPDATE  eps_generales
 SET (niteps,nombre_eps,codeps,cedrep,nombrerep,cedger,nombreger,cedrev,nombrerev,nitrecaudador,digverrec,nombrerec,periodocar,codepss,soltraslado,sec_gastos_c,sec_gastos_s) 
    =(tpeps_generales.niteps,tpeps_generales.nombre_eps,tpeps_generales.codeps,tpeps_generales.cedrep,tpeps_generales.nombrerep,
    tpeps_generales.cedger,tpeps_generales.nombreger,tpeps_generales.cedrev,tpeps_generales.nombrerev,
    tpeps_generales.nitrecaudador,tpeps_generales.digverrec,tpeps_generales.nombrerec,tpeps_generales.periodocar,
    tpeps_generales.codepss,tpeps_generales.soltraslado,tpeps_generales.sec_gastos_c,tpeps_generales.sec_gastos_s) 
 WHERE  niteps=geps_generales.niteps 
 
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
  LET geps_generales.* = tpeps_generales.*
 END IF
END FUNCTION 

FUNCTION eps_generalesremove()
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
  DELETE FROM eps_generales
    WHERE eps_generales.niteps = geps_generales.niteps
  IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
   IF NOT gerrflag THEN 
   INITIALIZE geps_generales.* TO NULL
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

