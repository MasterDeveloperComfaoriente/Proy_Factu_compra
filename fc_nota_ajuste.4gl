DATABASE empresa

GLOBALS "fc_globales.4gl"
GLOBALS "enviarDocumentoProduccion.inc"

DEFINE rec_nota_ajuste, mod_nota_ajuste RECORD
    numerodoc LIKE fc_nota_ajuste.numerodoc,
    numerona LIKE fc_nota_ajuste.numerona,
    fechads LIKE fc_nota_ajuste.fechads,
    cuds LIKE fc_nota_ajuste.cuds,
    prefijo LIKE fc_nota_ajuste.prefijo,
	numerods LIKE fc_nota_ajuste.numerods,
	nit LIKE fc_nota_ajuste.nit,
	valor_totalds LIKE fc_nota_ajuste.valor_totalds,
	valoriva LIKE fc_nota_ajuste.valoriva,
	valords LIKE fc_nota_ajuste.valords,
    estado LIKE fc_nota_ajuste.estado,
    codest LIKE fc_nota_ajuste.codest,
    nota_descripcion LIKE fc_nota_ajuste.nota_descripcion
END RECORD ,
ls_salida STRING,
cbtipd ui.ComboBox,
rec_maestro RECORD LIKE fc_factura_m.*,
rec_detalle RECORD LIKE fc_factura_d.*,
rec_total RECORD LIKE fc_factura_tot.*,
rec_servicio RECORD LIKE fc_servicios.*,
wfechafac DATETIME YEAR TO FRACTION(5),
rec_tercero RECORD LIKE fc_terceros.*,
idEmpresa BIGINT
,idErp VARCHAR(40)
,token VARCHAR(200)
,usuario VARCHAR(40)
,contrasena VARCHAR(200)
,version VARCHAR(1)


FUNCTION fc_nota_ajuste_main()
DEFINE exist SMALLINT
OPEN WINDOW wmfc_nota_ajuste AT 1,1 WITH FORM "fc_nota_ajuste"
MENU "NOTA_AJUSTE"
  COMMAND "Adiciona" "Adiciona un documento de NOTA"
   LET mcodmen="FC35"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL adiciona_nota_ajuste()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
   END if 
  COMMAND "Consulta" "Consulta los documentos de NOTA adicionadas"
   LET mcodmen="FC35"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL consulta_nota (exist) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL fc_nota_ajuste_mdetail()
   END if 
  --COMMAND "Listar" "Lista los servicios del NOTA en consulta"
   --LET mcodmen="fc33"
   --CALL opcion() RETURNING op
   --if op="S" THEN
    --IF NOT exist THEN
     --CALL FGL_WINMESSAGE( "Administrador", " NO HAY NOTA(S) EN CONSULTA ", "stop")
    --ELSE
     --CALL fc_nota_mview()
     --CALL fc_nota_mdetail()
    --END IF
   --END IF 
  --COMMAND "Imprimir Nota" "Imprime La Nota DB - CR"
  --CALL imprime_ordenn()
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 10
   EXIT MENU
 END MENU
 CLOSE WINDOW wmfc_nota_ajuste
END FUNCTION 

FUNCTION adiciona_nota_ajuste()
DEFINE cont INTEGER 
DEFINE toggle SMALLINT 
DEFINE razsoc CHAR (80)
DEFINE fecha_ds DATE 
DEFINE nota1 CHAR(400)

MESSAGE "Estado : ADICIONANDO NOTA DE AJUSTE   " 
iF int_flag THEN
    LET int_flag = FALSE
END IF
DISPLAY "" AT 1,1
MESSAGE ""
MESSAGE "Estado : ADICIONANDO UNA NOTA DE AJUSTE" 
CLEAR FORM 
INITIALIZE rec_nota_ajuste.* TO NULL 
LET cont=0
LABEL adi_nota:
INPUT BY NAME rec_nota_ajuste.numerodoc THRU rec_nota_ajuste.nota_descripcion
BEFORE FIELD numerodoc
    SELECT MAX (numerodoc) INTO cont FROM fc_nota_ajuste
    IF cont IS NULL THEN 
        LET cont=0 
    END IF 
    LET cont=cont+1
    LET rec_nota_ajuste.numerodoc=cont USING "&&&&&&&"
    DISPLAY BY NAME rec_nota_ajuste.numerodoc
    LET rec_nota_ajuste.fechads = TODAY USING "MM/DD/YYYY"
    DISPLAY BY NAME rec_nota_ajuste.fechads
    NEXT FIELD prefijo

BEFORE FIELD prefijo
    CALL fc_prefijosval() RETURNING rec_nota_ajuste.prefijo
    IF rec_nota_ajuste.prefijo IS NULL THEN
        CALL fgl_winmessage("Administrador","No selecciono ningún prefijo","stop")
        NEXT FIELD prefijo
    ELSE 
        NEXT FIELD numerods
    END IF

AFTER FIELD numerods
    DISPLAY rec_nota_ajuste.numerods  
    LET cont=0
    SELECT COUNT(*) INTO cont FROM fc_factura_m
    WHERE prefijo=rec_nota_ajuste.prefijo  
    AND numfac=rec_nota_ajuste.numerods
    AND estado="P"
    IF cont=0 THEN
        CALL fgl_winmessage("Administrador","El prefijo no existe o el documento no es Procesado exitoso","stop")
        NEXT FIELD numerods
    ELSE
        DISPLAY BY NAME rec_nota_ajuste.numerods
        SELECT fecha_factura, nit INTO fecha_ds, rec_nota_ajuste.nit 
        FROM fc_factura_m
        WHERE prefijo= rec_nota_ajuste.prefijo 
        AND numfac=rec_nota_ajuste.numerods
        DISPLAY BY NAME fecha_ds, rec_nota_ajuste.nit
        select trim(primer_apellido) || ' '||trim(segundo_apellido) ||' '||
        trim(primer_nombre) ||' '|| trim(segundo_nombre) 
        INTO razsoc from fc_terceros
        WHERE nit= rec_nota_ajuste.nit 
        LET razsoc=razsoc CLIPPED 
        DISPLAY BY NAME razsoc
        SELECT fc_factura_m.nota1 INTO nota1 FROM fc_factura_m
        WHERE prefijo= rec_nota_ajuste.prefijo 
        AND numfac=rec_nota_ajuste.numerods
        LET nota1=nota1 CLIPPED
        DISPLAY BY NAME nota1

        SELECT importebruto, total_cargos, total_factura 
        INTO rec_nota_ajuste.valords,rec_nota_ajuste.valoriva, rec_nota_ajuste.valor_totalds 
        FROM fc_factura_tot,fc_factura_m
        WHERE fc_factura_tot.prefijo = fc_factura_m.prefijo
        AND fc_factura_tot.documento = fc_factura_m.documento
        AND fc_factura_tot.prefijo= rec_nota_ajuste.prefijo 
        AND fc_factura_m.numfac=rec_nota_ajuste.numerods
        
        DISPLAY BY NAME rec_nota_ajuste.valords,rec_nota_ajuste.valoriva, rec_nota_ajuste.valor_totalds
        LET rec_nota_ajuste.estado="B"
        DISPLAY BY NAME rec_nota_ajuste.estado
    END IF

AFTER INPUT
    IF rec_nota_ajuste.numerodoc IS NULL THEN
        CALL fgl_winmessage ("Administrador","El campo numero interno está vacio","stop")
        GOTO adi_nota
    END IF 

    IF rec_nota_ajuste.prefijo IS NULL THEN
        CALL fgl_winmessage ("Administrador","El campo prefijo está vacio","stop")
        GOTO adi_nota
    END IF 

    IF rec_nota_ajuste.numerods IS NULL THEN
        CALL fgl_winmessage ("Administrador","El campo Descripción está vacio","stop")
        GOTO adi_nota
    END IF

    IF rec_nota_ajuste.nit IS NULL THEN
        CALL fgl_winmessage ("Administrador","El campo NIT está vacio","stop")
        GOTO adi_nota
    END IF

    IF nota1 IS NULL THEN
        CALL fgl_winmessage ("Administrador","El campo numero documento está vacio","stop")
        GOTO adi_nota
    END IF

    IF rec_nota_ajuste.valords IS NULL 
    OR rec_nota_ajuste.valoriva IS NULL 
    OR rec_nota_ajuste.valor_totalds IS NULL THEN
        CALL fgl_winmessage ("Administrador","Los campos de valores están vacios está vacio","stop")
        GOTO adi_nota
    END IF
END INPUT 

IF int_flag THEN
      CLEAR FORM
      DISPLAY "" AT 1,10
      CALL FGL_WINMESSAGE( "Administrador", "LA MODIFICACION FUE CANCELADA", "exclamation")
      INITIALIZE rec_nota_ajuste.* TO NULL
      CALL fc_factura_minitta()
      RETURN
END IF

BEGIN WORK
WHENEVER ERROR CONTINUE
SET LOCK MODE TO WAIT
IF rec_nota_ajuste.numerodoc IS NOT NULL THEN 
    INSERT INTO fc_nota_ajuste (
    numerodoc,
    fechads,
    horads,
    prefijo,
    numerods,
    nit,
    valords,
    valoriva,
    valor_totalds,
    estado,
    nota_descripcion) 
    VALUES (
    rec_nota_ajuste.numerodoc,
    rec_nota_ajuste.fechads,
    CURRENT HOUR TO SECOND,
    rec_nota_ajuste.prefijo,
    rec_nota_ajuste.numerods,
    rec_nota_ajuste.nit,
    rec_nota_ajuste.valords,
    rec_nota_ajuste.valoriva,
    rec_nota_ajuste.valor_totalds,
    rec_nota_ajuste.estado,
    rec_nota_ajuste.nota_descripcion)
    IF status < 0 THEN --4
        LET gerrflag = TRUE
        DISPLAY "El error: " , STATUS, " " , SQLERRMESSAGE
    END IF 
    if sqlca.sqlcode <> 0 then   --3 
        MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
            comment= " NO SE ADICIONO.. REGISTRO REFERENCIADO     "  ,                     image= "stop")
            COMMAND "Aceptar"
              EXIT MENU
         END MENU
         ROLLBACK WORK 
    ELSE 
        CALL fgl_winmessage("Administrador","Se Adicionó exitosamente la Nota de Ajuste","information")
        COMMIT WORK 
    END IF 
END IF 
END FUNCTION

FUNCTION consulta_nota (exist)
DEFINE exist,curr SMALLINT, 
where_info,query_text CHAR(400),
tpprefijo LIKE fc_nota_ajuste.prefijo,
tpdocumento LIKE fc_nota_ajuste.numerods

IF int_flag THEN
    LET int_flag = FALSE
END IF
DISPLAY "" AT 1,1
MESSAGE  "Estado : CONSULTA DE NOTAS" 
CLEAR FORM
CONSTRUCT where_info
ON  numerodoc,numerona,prefijo,numerods,nit,nota1,valords,
valoriva,valor_totalds,estado,codest,nota_descripcion 
FROM  numerodoc,numerona,prefijo,numerods,nit,nota1,valords,
valoriva,valor_totalds,estado,codest,nota_descripcion
IF int_flag THEN
    CALL FGL_WINMESSAGE( "Administrador", " CONSULTA CANCELADA", "stop")
    RETURN exist
END IF
MESSAGE  "Buscando la(s) nota(s), porfavor espere ..." --AT 2,1
LET query_text = " SELECT fc_nota_ajuste.prefijo,fc_nota_ajuste.numerodoc",
                 " FROM fc_nota_ajuste WHERE ", where_info CLIPPED
PREPARE s_sfc_nota_ajuste FROM query_text
DECLARE c_sfc_nota_ajuste SCROLL CURSOR FOR s_sfc_nota_ajuste
LET cnt = 0

FOREACH c_sfc_nota_ajuste INTO tpprefijo,tpdocumento
  LET cnt = cnt + 1
END FOREACH
IF ( cnt > 0 ) THEN
  OPEN c_sfc_nota_ajuste
  FETCH FIRST c_sfc_nota_ajuste INTO tpprefijo,tpdocumento
  LET curr = 1
  CALL fc_nota_ajuste_mgetcurr( tpprefijo,tpdocumento )
  CALL fc_nota_ajuste_mshowcurr( curr, cnt )
ELSE
  CALL FGL_WINMESSAGE( "Administrador", " LA NOTA NO EXISTE  ", "stop")
  RETURN exist
END IF
DISPLAY "" AT 2,1
MENU ":"
  COMMAND "Primero" "Desplaza al primer Documento en consulta"
   HELP 5
   FETCH FIRST c_sfc_nota_ajuste INTO tpprefijo,tpdocumento
   LET curr = 1
   CALL fc_nota_ajuste_mgetcurr( tpprefijo,tpdocumento )
   CALL fc_nota_ajuste_mshowcurr( curr, cnt )
  COMMAND "Ultimo" "Desplaza al ultimo Documento en consulta"
   HELP 6
   FETCH LAST c_sfc_nota_ajuste INTO tpprefijo,tpdocumento
   LET curr = cnt
   CALL fc_nota_ajuste_mgetcurr( tpprefijo,tpdocumento )
   CALL fc_nota_ajuste_mshowcurr( curr, cnt )
  COMMAND "Inmediato" "Se desplaza al sigiente Documento en consulta"
   HELP 7
   IF ( curr = cnt ) THEN
    FETCH FIRST c_sfc_nota_ajuste INTO tpprefijo,tpdocumento
    LET curr = 1
   ELSE
    FETCH NEXT c_sfc_nota_ajuste INTO tpprefijo,tpdocumento
    LET curr = curr + 1
   END IF
   CALL fc_nota_ajuste_mgetcurr( tpprefijo,tpdocumento )
   CALL fc_nota_ajuste_mshowcurr( curr, cnt )
  COMMAND "Anterior" "Se desplaza al factura anterior"
   HELP 8
   IF ( curr = 1 ) THEN
    FETCH LAST c_sfc_nota_ajuste INTO tpprefijo,tpdocumento
    LET curr = cnt
   ELSE
    FETCH PREVIOUS c_sfc_nota_ajuste INTO tpprefijo,tpdocumento
    LET curr = curr - 1
   END IF
   CALL fc_nota_ajuste_mgetcurr( tpprefijo,tpdocumento )
   CALL fc_nota_ajuste_mshowcurr( curr, cnt )
  {COMMAND "Listar" "Lista los servicios del factura en consulta"
   LET mcodmen="FC33"
   CALL opcion() RETURNING op
   if op="S" THEN 
    IF rec_nota_ajuste.numerods IS NULL THEN
     CONTINUE MENU
    ELSE
     CALL fc_factura_mview()
    
    END IF
   END IF} 
  COMMAND "Modifica" "Modifica la Factura Para El Envio a La DIAN."
   LET mcodmen="FC35"
   CALL opcion() RETURNING op
   if op="S" THEN 
    IF rec_nota_ajuste.numerodoc IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_nota_ajuste
     CALL fc_nota_ajuste_mupdate()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL fc_nota_ajuste_mgetcurr( tpprefijo, tpdocumento )
     --CALL fc_factura_mshowcurr( curr, cnt )
     OPEN c_sfc_nota_ajuste
    end if 
   end IF
  COMMAND "Borra" "Elimina la Nota de Ajuste en consulta."
   LET mcodmen="FC36"
   CALL opcion() RETURNING op
   if op="S" THEN 
    IF rec_nota_ajuste.numerods IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_nota_ajuste
     CALL fc_factura_mremove()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      --CALL fc_factura_mshowcurr( curr, cnt )
     END if 
     OPEN c_sfc_nota_ajuste
    end if 
   end if 
  COMMAND "Aprobar" "Aprobar la Nota de Ajuste como definitivo para enumerarlo"
   LET mcodmen="FC35"
   CALL opcion() RETURNING op
   if op="S" THEN 
    IF rec_nota_ajuste.numerods IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_nota_ajuste
     --LET mentra="N"
     IF rec_nota_ajuste.estado="B" THEN
        CALL aprobar_nota_ajuste (tpprefijo, rec_nota_ajuste.numerods,"1",0)
     ELSE
      CALL FGL_WINMESSAGE( "Administrador", "EL ESTADO DE EL DOCUMENTO SOPORTE NO ES BORRADOR", "stop")
     END if  
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     --CALL fc_nota_ajuste_mshowcurr( curr, cnt )
     OPEN c_sfc_nota_ajuste
    END IF
   end IF

   COMMAND "Imprimir" "Imprimir el Documento Soporte aprobado"
    IF rec_nota_ajuste.numerods IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_nota_ajuste
     --LET mentra="N"
     IF rec_nota_ajuste.estado="P" THEN
        --CALL f_obtencion_de_datos(rec_factura_m.documento,rec_factura_m.prefijo) RETURNING arr_usuarios 
        --CALL f_genera_reporte_simple(arr_usuarios, rec_factura_m.documento,rec_factura_m.prefijo)
        CALL descarga_documento("10", "DSNC", rec_nota_ajuste.numerona)
       
     ELSE
      CALL FGL_WINMESSAGE( "Administrador", "EL ESTADO DE EL DOCUMENTO SOPORTE NO ESTA APROBADO", "stop")
     END IF  
     END IF 
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
  IF rec_nota_ajuste.numerodoc IS NULL THEN
    LET exist = FALSE
   ELSE
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 RETURN exist
END FUNCTION 

FUNCTION fc_nota_ajuste_mgetcurr( tpprefijo, tpdocumento )
 DEFINE tpdocumento LIKE fc_nota_ajuste.numerodoc
 DEFINE tpprefijo LIKE fc_nota_ajuste.prefijo
 INITIALIZE rec_nota_ajuste.* TO NULL
 SELECT fc_nota_ajuste.numerodoc,fc_nota_ajuste.numerona,
 fc_nota_ajuste.fechads,fc_nota_ajuste.cuds,fc_nota_ajuste.prefijo,
 fc_nota_ajuste.numerods,fc_nota_ajuste.nit,fc_nota_ajuste.valords,
 fc_nota_ajuste.valoriva,fc_nota_ajuste.valor_totalds,
 fc_nota_ajuste.estado,fc_nota_ajuste.codest,fc_nota_ajuste.nota_descripcion
INTO rec_nota_ajuste.*
FROM fc_nota_ajuste
WHERE fc_nota_ajuste.prefijo = tpprefijo
AND fc_nota_ajuste.numerodoc = tpdocumento
ORDER BY  fc_nota_ajuste.numerodoc, fc_nota_ajuste.prefijo  

END FUNCTION

FUNCTION fc_nota_ajuste_mdetail()
 DEFINE nombre CHAR(80)
 DEFINE nota CHAR(400)
DISPLAY BY NAME rec_nota_ajuste.numerodoc THRU rec_nota_ajuste.nota_descripcion
  INITIALIZE tpcom_proveedores.* TO NULL
  SELECT * into tpcom_proveedores.* FROM fc_terceros
  WHERE nit = rec_nota_ajuste.nit
  IF tpcom_proveedores.razsoc IS NOT NULL  THEN 
   DISPLAY tpcom_proveedores.razsoc TO razsoc
  ELSE 
    LET nombre = tpcom_proveedores.primer_nombre CLIPPED," ",tpcom_proveedores.segundo_nombre CLIPPED," ",tpcom_proveedores.primer_apellido CLIPPED," ",tpcom_proveedores.segundo_apellido CLIPPED
    DISPLAY  nombre TO razsoc
  END IF 
   CASE 
        WHEN rec_nota_ajuste.estado = "B"
            DISPLAY "BORRADOR" TO estado
        WHEN rec_nota_ajuste.estado = "S"
            DISPLAY "TRANSMITIDA" TO estado
        WHEN rec_nota_ajuste.estado = "P" 
            DISPLAY "PROCESADA EXITOSA" TO estado
        WHEN rec_nota_ajuste.estado = "G" 
            DISPLAY "CONTINGENCIA" TO estado   
        WHEN rec_nota_ajuste.estado = "R"
            DISPLAY "RECHAZADA CLIENTE" TO estado
        WHEN rec_nota_ajuste.estado = "D"
            DISPLAY "RECHAZADA DIAN" TO estado
        WHEN rec_nota_ajuste.estado = "X"
            DISPLAY "RECHAZADA DISPAPELES" TO estado
        WHEN rec_nota_ajuste.estado = "N"
            DISPLAY "ANULADA POR NOTA AJUSTE" TO estado
   END CASE 

   CASE 
        WHEN rec_nota_ajuste.codest = "0"
            DISPLAY "CON ERROR" TO codest
        WHEN rec_nota_ajuste.codest = "1"
            DISPLAY "EXITOSO" TO codest
        WHEN rec_nota_ajuste.codest = "2" 
            DISPLAY "CON NOTIFICACIONES" TO codest
        WHEN rec_nota_ajuste.codest = "3" 
            DISPLAY "ENVIADO DOBLE" TO codest  
        WHEN rec_nota_ajuste.codest = "4"
            DISPLAY "NO ACEPTADA DIAN" TO codest
        WHEN rec_nota_ajuste.codest = "19"
            DISPLAY "FALLO ENVIO DISPAPELES" TO codest
        WHEN rec_nota_ajuste.codest = "24"
            DISPLAY "CONTINGENCIA DIAN" TO codest
        WHEN rec_nota_ajuste.codest IS NULL 
            DISPLAY "" TO codest
   END CASE 

SELECT nota1 INTO nota FROM fc_factura_m
WHERE prefijo=rec_nota_ajuste.prefijo AND numfac=rec_nota_ajuste.numerods

DISPLAY nota TO nota1

   
  
END FUNCTION

FUNCTION fc_nota_ajuste_mshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum  INTEGER
 DISPLAY "" AT glastline,1
 IF rec_nota_ajuste.numerodoc IS NULL THEN
  MESSAGE  "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum,") Borrado" --AT glastline,33
 ELSE
  MESSAGE  "Localizacion : ( Actual ", rownum,"/ Existen ", maxnum, ")" --AT glastline,1
 END IF
 CALL fc_nota_ajuste_mdetail()
END FUNCTION

FUNCTION fc_nota_ajuste_mupdate()

DEFINE z, cnt, x, v, y, t, rownull, currow,
        scrrow, toggle, ttlrow, lin, lin2 SMALLINT
DEFINE controlador SMALLINT 
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION DE NOTA DE AJUSTE" 
 INITIALIZE mod_nota_ajuste.* TO NULL
 --CALL fc_factura_minitta()
 LET mod_nota_ajuste.* = rec_nota_ajuste.*

 IF mod_nota_ajuste.estado<>"B" THEN
  CALL FGL_WINMESSAGE( "Administrador", " LA NOTA DE AJUSTE NO SE PUEDE MODIFICAR POR QUE NO ESTA EN ESTADO BORRADOR","information") 
  RETURN
 END IF
 LET cnt=0
 SELECT count(*) INTO cnt FROM fc_prefijos_usu
  WHERE prefijo=mod_nota_ajuste.prefijo AND usu_elabora=musuario
 IF cnt IS NULL THEN LET cnt=0 END IF
 IF cnt=0 THEN
  CALL FGL_WINMESSAGE( "Administrador", " EL USUARIO NO ESTA AUTORIZADO PARA MODIFICAR FACTURAS DE ESTE PREFIJO","information") 
  RETURN
 END IF  
LET controlador=TRUE 
LABEL entrada_nota:
INPUT BY NAME mod_nota_ajuste.prefijo THRU mod_nota_ajuste.valor_totalds WITHOUT DEFAULTS
    AFTER FIELD prefijo
        IF mod_nota_ajuste.prefijo IS NULL THEN  
            CALL FGL_WINMESSAGE( "Administrador", " EL PREFIJO DEL DOCUMENTO SOPORTE DEBE SER OBLIGATORIO","information")
           NEXT FIELD prefijo 
        ELSE
            NEXT FIELD numerods
        END IF
    AFTER FIELD numerods
        IF mod_nota_ajuste.numerods IS NULL THEN
            CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DEL DOCUMENTO SOPORTE DEBE SER OBLIGATORIO","information")
            NEXT FIELD numerods
        ELSE
            LET cnt=0
            SELECT COUNT(*) INTO cnt FROM fc_factura_m
            WHERE prefijo=mod_nota_ajuste.prefijo
            AND documento=mod_nota_ajuste.numerods
            AND estado="P"
            IF cnt>0 THEN
                NEXT FIELD nit
            ELSE 
               CALL FGL_WINMESSAGE( "Administrador", " EL DOCUMENTO SOPORTE NO EXISTE O NO ESTA EN ESTADO PROCESADO EXITOSO","information")
               NEXT FIELD numerods
            END IF 
        END IF 

    AFTER FIELD nit 
        DISPLAY "OK"
        
END INPUT
 LET controlador=true
 IF int_flag THEN
  CLEAR FORM
  DISPLAY "" AT 1,10
  CALL FGL_WINMESSAGE( "Administrador", "LA MODIFICACION FUE CANCELADA", "exclamation")
  INITIALIZE  mod_nota_ajuste.* TO NULL
  RETURN
 END IF
 

MESSAGE "MODIFICANDO LA NOTA DE AJUSTE" 
BEGIN WORK
WHENEVER ERROR CONTINUE
SET LOCK MODE TO WAIT

IF controlador=TRUE THEN 
  update fc_nota_ajuste SET ( prefijo,  numerods, nit, 
   valords, valoriva,valor_totalds )
  = ( mod_nota_ajuste.prefijo, 
   mod_nota_ajuste.numerods,
   mod_nota_ajuste.nit, mod_nota_ajuste.valords,
   mod_nota_ajuste.valoriva,mod_nota_ajuste.valor_totalds )
  WHERE prefijo = mod_nota_ajuste.prefijo
    AND numerodoc =  mod_nota_ajuste.numerodoc

     IF status < 0 THEN --4
                LET gerrflag = TRUE
                DISPLAY "El error: " , STATUS, " " , SQLERRMESSAGE
               
     END IF
ELSE 
  

 message "                                                        "
 INITIALIZE mod_nota_ajuste.* TO NULL
 LET rec_nota_ajuste.* = mod_nota_ajuste.*
 IF NOT gerrflag THEN
  COMMIT WORK
  LET cnt = 1
  CALL fc_nota_ajuste_mdetail()
  CALL FGL_WINMESSAGE( "Administrador", "LA NOTA DE AJUSTE FUE ADICIONADA Y ACTUALIZADA", "information")
 ELSE
  ROLLBACK WORK
  CALL FGL_WINMESSAGE( "Administrador", "LA NOTA DE AJUSTE FUE CANCELADA", "information") 
 END IF
 SLEEP 2

 END IF 
END FUNCTION 

FUNCTION enviar_nota_ajuste ()
DEFINE prex CHAR (6)
DEFINE numerodoc,numero, cont INTEGER

LET prex = "DSNC"

PROMPT "Numero de Nota de Ajuste: " FOR numerodoc
LET cont=0

SELECT COUNT (*) INTO cont FROM fc_nota_ajuste
WHERE fc_nota_ajuste.numerona = numerodoc
AND fc_nota_ajuste.estado IN ("A")

IF cont = 0 THEN
    CALL fgl_winmessage("Administrador","La nota no existe o ya está rechazada","stop" )
    RETURN 
END IF 


SELECT fc_nota_ajuste.prefijo INTO prex FROM fc_nota_ajuste
WHERE fc_nota_ajuste.numerona = numerodoc

LET prex = prex CLIPPED 

SELECT fc_nota_ajuste.numerods into numero FROM fc_nota_ajuste
WHERE fc_nota_ajuste.prefijo=prex AND fc_nota_ajuste.numerona = numerodoc

CALL aprobar_nota_ajuste(prex,numero,"2",numerodoc)

END FUNCTION 

FUNCTION aprobar_nota_ajuste (tpprefijo, tpnumerods, direccion,numero)
DEFINE tpprefijo LIKE fc_factura_m.prefijo
DEFINE tpnumerods LIKE fc_factura_m.numfac
DEFINE rec_documento RECORD LIKE fc_factura_m.*
DEFINE rec_documento_d RECORD LIKE fc_factura_d.*
DEFINE rec_documento_tot RECORD LIKE fc_factura_tot.*
DEFINE tipodoc CHAR(2)
DEFINE consecutivo INTEGER 
DEFINE fecha DATETIME YEAR TO FRACTION(5)
DEFINE wsstatus INTEGER,
idEmpresa LIKE fe_dispapeles_acceso.idempresa,
usuario LIKE fe_dispapeles_acceso.usuario,
contrasena LIKE fe_dispapeles_acceso.contrasena,
token LIKE fe_dispapeles_acceso.token,
version LIKE fe_dispapeles_acceso.version,
idErp CHAR(1),
wcantidad,numero INTEGER,
i INTEGER,
rec_servicios RECORD LIKE fc_servicios.*,
rec_tercero RECORD LIKE fc_terceros.*,
contadorMensajes INTEGER,
prex CHAR(4)
DEFINE direccion CHAR (1)

LET tipodoc ="10"
LET fecha = CURRENT YEAR TO SECOND
LET prex="DSNC"

INITIALIZE rec_documento.* TO  NULL
INITIALIZE rec_documento_d.* TO  NULL
INITIALIZE rec_documento_tot.* TO  NULL

select DISTINCT fc_factura_m.*, fc_factura_tot.*
INTO rec_documento.*, rec_documento_tot.*
from fc_factura_m, fc_factura_d,fc_factura_tot
where fc_factura_m.prefijo=fc_factura_tot.prefijo
and fc_factura_m.documento=fc_factura_tot.documento
and fc_factura_m.numfac =tpnumerods
and fc_factura_m.prefijo=tpprefijo
AND fc_factura_m.estado="P"



IF rec_documento.prefijo IS NULL THEN
    CALL fgl_winmessage ("Administrador","EL DOCUMENTO SOPORTE A ANULAR NO ESTA PROCESADO EXITOSO","stop")
    RETURN 
ELSE 
    SELECT COUNT(*) INTO wcantidad
    FROM fc_factura_d, fc_factura_m
    WHERE fc_factura_d.prefijo = fc_factura_m.prefijo
    AND fc_factura_d.documento = fc_factura_m.documento
    and fc_factura_m.numfac =tpnumerods
    and fc_factura_m.prefijo=tpprefijo    
END IF 

IF direccion = "1" THEN 
    select fc_prefijos.numero INTO consecutivo from fc_prefijos
    where prefijo="DSNC"

    UPDATE fc_prefijos SET numero = consecutivo +1
    where prefijo="DSNC"
ELSE
    LET consecutivo=numero
END IF 



LET ls_salida =""
 OPEN WINDOW w_vista WITH FORM "Vista" DIALOG ATTRIBUTES(UNBUFFERED)
    INPUT tipodoc,prex,consecutivo,ls_salida
     FROM  txt_tipodoc,txt_prefijo,txt_folio_manual,txt_salida
     ATTRIBUTES( WITHOUT DEFAULTS) 
     END INPUT
  BEFORE  DIALOG
   LET cbtipd = ui.ComboBox.forName("txt_tipodoc")
   CALL cbtipd.clear()
   CALL cbtipd.addItem("7","DOCUMENTO SOPORTE")
   CALL cbtipd.addItem("10","NOTA AJUSTE")

   EXECUTE IMMEDIATE "set encryption password ""0r13nt3"""
   select fe_dispapeles_acceso.idEmpresa
       ,""
       ,fe_dispapeles_acceso.usuario
       ,decrypt_char(fe_dispapeles_acceso.contrasena) as contrasena
       ,decrypt_char(fe_dispapeles_acceso.token) as token
       ,fe_dispapeles_acceso.version
   INTO idEmpresa,idErp,usuario,contrasena,token,version
   from fe_dispapeles_acceso

LET enviarDocumento.felCabezaDocumento.idEmpresa=idEmpresa clipped--"488"
LET enviarDocumento.felCabezaDocumento.usuario=usuario clipped--"EmpCOMFAORIENTE"
LET enviarDocumento.felCabezaDocumento.contrasenia=contrasena clipped--"Pwc0mf40r1ent3"
LET enviarDocumento.felCabezaDocumento.token=token clipped--"eaab450239c82b4efb6a0a894583d7aa5ffe886c"
LET enviarDocumento.felCabezaDocumento.version=version clipped--"12"
LET enviarDocumento.felCabezaDocumento.tipodocumento=tipodoc CLIPPED 
LET enviarDocumento.felCabezaDocumento.prefijo=prex clipped
LET enviarDocumento.felCabezaDocumento.consecutivo=consecutivo
LET enviarDocumento.felCabezaDocumento.fechafacturacion=fecha
LET enviarDocumento.felCabezaDocumento.codigoPlantillaPdf=14
LET enviarDocumento.felCabezaDocumento.idErp=""
LET enviarDocumento.felCabezaDocumento.cantidadLineas=wcantidad
LET enviarDocumento.felCabezaDocumento.tiponota="2"
LET enviarDocumento.felCabezaDocumento.aplicafel="NO"
LET enviarDocumento.felCabezaDocumento.pago.moneda=rec_documento_tot.moneda CLIPPED 
LET enviarDocumento.felCabezaDocumento.pago.totalimportebruto=rec_documento_tot.importebruto
LET enviarDocumento.felCabezaDocumento.pago.totalbaseimponible=0 
LET enviarDocumento.felCabezaDocumento.pago.totalbaseconimpuestos=rec_documento_tot.baseconimpu
LET enviarDocumento.felCabezaDocumento.pago.totalfactura=rec_documento_tot.total_factura
LET enviarDocumento.felCabezaDocumento.pago.tipocompra=rec_documento.forma_pago
LET enviarDocumento.felCabezaDocumento.pago.codigoMonedaCambio=rec_documento_tot.moneda CLIPPED
--LET enviarDocumento.felCabezaDocumento.pago.tipoPago="T"
LET enviarDocumento.felCabezaDocumento.pago.totalfacturaTotalParcial=0.0

DECLARE detalle CURSOR FOR
SELECT fc_factura_d.* 
FROM fc_factura_d, fc_factura_m
WHERE fc_factura_d.prefijo = fc_factura_m.prefijo
AND fc_factura_d.documento = fc_factura_m.documento
and fc_factura_m.numfac =tpnumerods
and fc_factura_m.prefijo=tpprefijo

LET i=1

INITIALIZE rec_servicios.* TO NULL

FOREACH detalle INTO rec_documento_d.*
    SELECT * INTO rec_servicios.* FROM fc_servicios
    WHERE fc_servicios.codigo=rec_documento_d.codigo
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].nombreProducto=rec_servicios.descripcion CLIPPED 
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].codigoproducto=rec_servicios.codigo clipped
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].tipocodigoproducto="999"
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].cantidad=rec_documento_d.cantidad
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].unidadmedida=rec_servicios.coduni clipped
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].valorunitario=rec_documento_d.valoruni
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].preciosinimpuestos=rec_documento_d.valoruni*rec_documento_d.cantidad   
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].preciototal=rec_documento_d.valoruni*rec_documento_d.cantidad
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].posicion=0
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].tamanio=0
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].muestracomercial=0
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].muestracomercialcodigo=0            
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].listaCamposAdicionales[1].nombreCampo="PERIODO_FACTURACION"
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].listaCamposAdicionales[1].valorCampo="2"
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].listaCamposAdicionales[1].seccion=0
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].listaCamposAdicionales[1].orden=0
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].listaCamposAdicionales[1].fecha=fecha
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].valorUnitarioPorCantidad=0.0
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].tipoImpuesto=rec_servicios.tpimpuesto
    LET i=i+1
END FOREACH 

LET enviarDocumento.felCabezaDocumento.listaCamposAdicionales[1].nombreCampo="TIPO_PROCEDENCIA"
LET enviarDocumento.felCabezaDocumento.listaCamposAdicionales[1].seccion=0
LET enviarDocumento.felCabezaDocumento.listaCamposAdicionales[1].orden=0

INITIALIZE rec_tercero.* TO NULL

SELECT * INTO rec_tercero.* FROM fc_terceros
WHERE nit = rec_documento.nit

LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].tipoPersona= rec_tercero.tipo_persona
IF rec_tercero.razsoc IS NULL THEN 
    LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].nombreCompleto=rec_tercero.primer_nombre clipped," ",rec_tercero.segundo_nombre CLIPPED," ",rec_tercero.primer_apellido CLIPPED," ",rec_tercero.segundo_apellido CLIPPED
ELSE 
    LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].nombreCompleto=rec_tercero.razsoc clipped 
END IF 
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].tipoIdentificacion="31"--rec_tercero.tipid
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].digitoverificacion=rec_tercero.digver
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].numeroIdentificacion=rec_tercero.nit CLIPPED
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].pais=rec_tercero.pais CLIPPED 
SELECT nombrepais INTO  enviarDocumento.felCabezaDocumento.listaAdquirentes[1].paisnombre FROM fe_paises
WHERE codpais= enviarDocumento.felCabezaDocumento.listaAdquirentes[1].pais 
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].paisnombre=enviarDocumento.felCabezaDocumento.listaAdquirentes[1].paisnombre clipped
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].departamento=rec_tercero.zona[1,2]
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].codigoCiudad=rec_tercero.zona CLIPPED
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].ciudad =rec_tercero.zona CLIPPED 
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].telefono=rec_tercero.telefono CLIPPED 
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].direccion=rec_tercero.direccion CLIPPED 
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].tipoobligacion="R-99-PN"
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].codigoPostal="540001"

SELECT fe_ciudades.nombreciu INTO enviarDocumento.felCabezaDocumento.listaAdquirentes[1].descripcionCiudad
FROM   fe_ciudades 
WHERE  fe_ciudades.codciu = enviarDocumento.felCabezaDocumento.listaAdquirentes[1].codigoCiudad

LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].descripcionCiudad = enviarDocumento.felCabezaDocumento.listaAdquirentes[1].descripcionCiudad CLIPPED

SELECT nombredep INTO  enviarDocumento.felCabezaDocumento.listaAdquirentes[1].nombredepartamento 
FROM  fe_deptos
WHERE fe_deptos.coddep = enviarDocumento.felCabezaDocumento.listaAdquirentes[1].departamento

LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].nombredepartamento = enviarDocumento.felCabezaDocumento.listaAdquirentes[1].nombredepartamento  CLIPPED   


LET enviarDocumento.felCabezaDocumento.listaMediosPagos[1].medioPago="45"

LET enviarDocumento.felCabezaDocumento.listaFacturasModificadas[1].consecutivoFacturaModificada=rec_documento.numfac--22
LET enviarDocumento.felCabezaDocumento.listaFacturasModificadas[1].cufeFacturaModificada=rec_documento.cufe CLIPPED --"ca69789d9850f1c587df457a11f0dfc6f75ca1cf1fc5929e56be5ca8505a35fa3ee436b40984489daac1497d06832508"
LET enviarDocumento.felCabezaDocumento.listaFacturasModificadas[1].fechaFacturaModificada=rec_documento.fecha_factura--"2022-08-02T04:32-0500"
LET enviarDocumento.felCabezaDocumento.listaFacturasModificadas[1].tipoDocumentoFacturaModificada="7"            
LET enviarDocumento.felCabezaDocumento.listaFacturasModificadas[1].prefijoFacturaModificada=rec_documento.prefijo clipped--"SETT"
LET enviarDocumento.felCabezaDocumento.listaFacturasModificadas[1].observacion=rec_nota_ajuste.nota_descripcion CLIPPED 

LET enviarDocumento.felCabezaDocumento.tipoOperacion="10"

CALL enviarDocumento_g() RETURNING wsstatus

IF wsstatus = 0 then
    DISPLAY "Consecutivo:            ",enviarDocumentoResponse.return.consecutivo
    DISPLAY "Cufe:                   ",enviarDocumentoResponse.RETURN.cufe
    DISPLAY "Descripción del Proceso:",enviarDocumentoResponse.return.descripcionProceso
    DISPLAY "Descripción del Mensaje:",enviarDocumentoResponse.return.listaMensajesProceso[1].descripcionMensaje
ELSE
    DISPLAY wsError.description
END IF 

LET ls_salida = ls_salida,"\n+++++++++++++++++++++Consulta Método Respuesta Envio +++++++++++++++++++++"
CALL ui.Interface.refresh()
LET ls_salida = ls_salida,"\nDocumento afectado prefijo: ",rec_documento.prefijo, " # ",rec_documento.numfac
LET ls_salida = ls_salida,"\nRespuesta Protocolo: "
LET ls_salida = ls_salida,"\n",sqlca.sqlerrm
LET ls_salida = ls_salida,"\nRespuesta Proceso: "
LET ls_salida = ls_salida, enviarDocumentoResponse.return.estadoProceso CLIPPED, "-",  enviarDocumentoResponse.return.descripcionProceso

LET cnt =0
SELECT COUNT(*) INTO cnt
FROM fc_respenvio
WHERE tpdocumento = tipodoc
AND prefijo = enviarDocumentoResponse.return.prefijo
AND numfac = enviarDocumentoResponse.return.consecutivo
IF cnt IS NULL THEN LET cnt = 0 END IF
IF cnt = 0 THEN  
        INSERT INTO fc_respenvio
        (tpdocumento,prefijo,numfac, cufe, fecfactura, fecresp, fecexped, codest)
        VALUES 
        (enviarDocumentoResponse.return.tipoDocumento, enviarDocumentoResponse.return.prefijo, enviarDocumentoResponse.return.consecutivo,enviarDocumentoResponse.return.cufe, enviarDocumentoResponse.return.fechaFactura,enviarDocumentoResponse.return.fechaRespuesta,
        enviarDocumentoResponse.return.fechaExpedicion,enviarDocumentoResponse.return.estadoProceso)
        IF sqlca.sqlcode = 0 THEN
            display  "OK"
        ELSE
            display "Ocurrió un error al conectar a la Base de Datos " , STATUS ,
                    "\n" , SQLERRMESSAGE
        END IF
ELSE
       UPDATE fc_respenvio
       SET ( cufe, fecfactura, fecresp, fecexped, codest)
       =  (enviarDocumentoResponse.return.cufe, enviarDocumentoResponse.return.fechaFactura,enviarDocumentoResponse.return.fechaRespuesta,
        enviarDocumentoResponse.return.fechaExpedicion,enviarDocumentoResponse.return.estadoProceso)
       WHERE tpdocumento = tipodoc
        AND prefijo = enviarDocumentoResponse.return.prefijo
        AND documento = enviarDocumentoResponse.return.consecutivo
        IF sqlca.sqlcode = 0 THEN
            display  "OK respenvio"
        ELSE
            display "Ocurrió un error al conectar a la Base de Datos " , STATUS ,
            "\n" , SQLERRMESSAGE
        END IF
END IF 

LET mtime=TIME
IF enviarDocumentoResponse.return.estadoProceso = "1" OR enviarDocumentoResponse.return.estadoProceso = "2" 
OR enviarDocumentoResponse.return.estadoProceso = "3" THEN --2
            IF enviarDocumentoResponse.return.cufe IS NOT NULL THEN--3
                UPDATE fc_nota_ajuste SET fc_nota_ajuste.cuds = enviarDocumentoResponse.return.cufe,
                fc_nota_ajuste.fechads=enviarDocumentoResponse.return.fechaFactura,
                fc_nota_ajuste.estado="P", fecest=enviarDocumentoResponse.return.fechaRespuesta,
                fc_nota_ajuste.codest = enviarDocumentoResponse.return.estadoProceso, horads=mtime,
                fc_nota_ajuste.numerona = enviarDocumentoResponse.return.consecutivo--,
                --tipodocumento=enviarDocumentoResponse.return.tipoDocumento
                WHERE fc_nota_ajuste.prefijo=rec_nota_ajuste.prefijo
                AND fc_nota_ajuste.numerodoc=rec_nota_ajuste.numerodoc
                
                IF sqlca.sqlcode = 0 THEN--4
                    display  "OK"
                ELSE
                    display "Ocurrió un error al conectar a la Base de Datos " , STATUS ,
                 "\n" , SQLERRMESSAGE
                END IF--4

                UPDATE fc_factura_m SET fc_factura_m.estado="N", fc_factura_m.fecest=enviarDocumentoResponse.return.fechaRespuesta
                WHERE  fc_factura_m.prefijo=rec_documento.prefijo
                AND    fc_factura_m.numfac=rec_documento.numfac
            ELSE
               
            END IF --3
ELSE
     UPDATE fc_nota_ajuste SET 
                fc_nota_ajuste.fechads=enviarDocumentoResponse.return.fechaFactura,
                fc_nota_ajuste.estado="A", fecest=enviarDocumentoResponse.return.fechaRespuesta,
                fc_nota_ajuste.codest = enviarDocumentoResponse.return.estadoProceso, horads=mtime,
                fc_nota_ajuste.numerona = enviarDocumentoResponse.return.consecutivo--,
                --tipodocumento=enviarDocumentoResponse.return.tipoDocumento
                WHERE fc_nota_ajuste.prefijo=rec_nota_ajuste.prefijo
                AND fc_nota_ajuste.numerodoc=rec_nota_ajuste.numerodoc
END IF --2
FOR contadorMensajes = 1 TO enviarDocumentoResponse.return.listaMensajesProceso.getLength()
           
                LET ls_salida = ls_salida,"\nMensaje: "
                LET ls_salida = ls_salida,enviarDocumentoResponse.return.listaMensajesProceso[contadorMensajes].descripcionMensaje
                LET ls_salida = ls_salida,"\nNotificacion Rechazo: "
                LET ls_salida = ls_salida,enviarDocumentoResponse.return.listaMensajesProceso[contadorMensajes].rechazoNotificacion
                CALL ui.Interface.refresh()
END FOR    

 ON ACTION bt_cerrar
            EXIT DIALOG
    END DIALOG
    CLOSE WINDOW w_vista

END FUNCTION 


