IMPORT FGL Enlace_Archivo_bbl
IMPORT FGL Enlace_Doc_bbl
IMPORT FGL Enlace_DocEstado_bbl
GLOBALS "fc_globales.4gl"
 DEFINE
   mfe_deptos RECORD LIKE fe_deptos.*,
   mfe_ciudades RECORD LIKE fe_ciudades.*,
   mfe_paises  RECORD LIKE fe_paises.*,
   mfe_regimen RECORD LIKE fe_regimen.*,
   aplicafel VARCHAR(2)
   ,cantidadLineas INTEGER
   ,codigoPlantillaPdf INTEGER
   ,idEmpresa BIGINT
   ,idErp VARCHAR(40)
   ,token VARCHAR(200)
   ,usuario VARCHAR(40)
   ,contrasena VARCHAR(200)
   ,version VARCHAR(1)
   ,tiponota VARCHAR(2)
   ,departamento VARCHAR(50)
   ,nombreCompleto VARCHAR(200)
   ,tipoobligacion VARCHAR(200)
   ,envioPorEmailPlataforma VARCHAR(10)
   ,nitProveedorTecnologico VARCHAR(30)
   ,campoAdicional1 STRING
   ,campoAdicional2 STRING
   ,campoAdicional3 STRING
   ,campoAdicional4 STRING
   ,campoAdicional5 STRING
   ,campoAdicional6 FLOAT
   ,campoAdicional7 CHAR(30)
   ,campoAdicional8 CHAR(30)
   ,campoAdicional9 FLOAT
   ,fechavencimiento DATETIME YEAR TO FRACTION(5)
   ,periododepago SMALLINT
   ,muestracomercial smallint
   ,nombreProducto VARCHAR(240)
   ,descuento FLOAT
   ,porcentajeDescuento FLOAT
   ,TotalSub, TotalBen, TotalIva, TotalImpc FLOAT
   ,descuentoUni, Subtotal       FLOAT
   ,mhoy DATETIME YEAR TO FRACTION(5)
   ,posicion INTEGER
   ,ciudadFacturador VARCHAR(100)
   ,telefonoFacturador VARCHAR(100)
   ,DesMedioPago VARCHAR(100)
   ,DesTipoNota VARCHAR(100)
   ,isAutoRetenido BOOLEAN
   ,lineaResDian1 VARCHAR(200)
   ,lineaResDian2 VARCHAR(200)
   ,lineaNota1 VARCHAR(100)
   ,lineaNota2 VARCHAR(100)
   ,lineaNota3 VARCHAR(100)
   ,lineaNota4 VARCHAR(100)
   ,lineaMonto1 VARCHAR(200)
   ,lineaMonto2 VARCHAR(200)
   ,lineaMonto3 VARCHAR(200)
   ,NombreElaboro CHAR(100)
   ,NombreAprobo CHAR(100)
-- Nuevas variables version 9
    ,nombreImpresora VARCHAR(240)
    ,subtotalfac FLOAT
    ,valorEnLetrasSubTotal VARCHAR(240)
    ,valorAdicional1 VARCHAR(240)
    ,valorAdicional2 VARCHAR(240)
    ,valorAdicional3 VARCHAR(240)
    ,valorAdicional4 VARCHAR(240)
    ,valorAdicional5 VARCHAR(240)
    ,redondeoTotalFactura FLOAT
    ,nombreSector VARCHAR(240)
DEFINE cbtipd ui.ComboBox
DEFINE rec_mfc_servicios RECORD LIKE fc_servicios.*   
DEFINE ls_salida STRING
  -- variables respuesta de envio
    ,contadorMensajes SMALLINT
    ,codigoQr VARCHAR(2000)
    ,consecutivo_r BIGINT
    ,cufe STRING
    ,descripcionProceso STRING
    ,estadoProceso INTEGER
    ,fechaExpedicion DATETIME YEAR TO FRACTION(5)
    ,fechaFactura DATETIME YEAR TO FRACTION(5)
    ,fechaRespuesta DATETIME YEAR TO FRACTION(5)
    ,firmaDelDocumento STRING
    ,idErp_r STRING
    ,prefijo_r VARCHAR(5)
    ,selloDeValidacion STRING
    ,tipoDocumento_r VARCHAR(1)
   -- variables respuesta de envio mensajes
    ,codigoMensaje VARCHAR(50)
    ,descripcionMensaje VARCHAR(240)
    ,rechazoNotificacion VARCHAR(2)
   -- variables respuesta de archivo
    , indice               INTEGER
    , codigoRespuesta      INTEGER
    , descripcionRespuesta VARCHAR(240)
   
DEFINE 
     formato               VARCHAR(4)
   , mimeType              VARCHAR(240)
   , nameFile              VARCHAR(240)
   , newnameFile           VARCHAR(240)
   , streamFile            STRING 
DEFINE
     codigoUltimoEstadoAdquirente         INTEGER 
   , codigoUltimoEstadoDian               INTEGER 
   , codigoUltimoEstadoDispapeles         INTEGER 
   , codigoUltimoEstadoEmail              INTEGER 
   , descripcionUltimoEstadoAdquirente    VARCHAR(240) 
   , descripcionUltimoEstadoDian          VARCHAR(240) 
   , descripcionUltimoEstadoDispapeles    VARCHAR(240) 
   , descripcionUltimoEstadoEmail         VARCHAR(240) 
   , fechaRespuestaUltimoEstadoAdquirente DATETIME YEAR TO FRACTION(5) 
   , fechaRespuestaUltimoEstadoDian       DATETIME YEAR TO FRACTION(5) 
   , fechaRespuestaUltimoEstadoDispapeles DATETIME YEAR TO FRACTION(5) 
   , fechaRespuestaUltimoEstadoEmail      DATETIME YEAR TO FRACTION(5) 
   , idLote                               VARCHAR(240) 
   ,ruta_descarga STRING
   ,consulta STRING
   
FUNCTION envio_documento(tipodoc, prefijo,numfactu)
  DEFINE tipodoc, mtipdoc   LIKE    fc_factura_m.tipodocumento
  DEFINE prefijo            LIKE    fc_factura_m.prefijo
  DEFINE numfactu           LIKE    fc_factura_m.numfac      
   EXECUTE IMMEDIATE "set encryption password ""Confaoriente2020"""
   select fc_dispapeles_acceso.idEmpresa 
       ,""               -- iderp
       ,fc_dispapeles_acceso.usuario
       ,decrypt_char(fc_dispapeles_acceso.contrasena) as contrasena
       ,decrypt_char(fc_dispapeles_acceso.token) as token
       ,fc_dispapeles_acceso.version
   INTO idEmpresa,idErp,usuario,contrasena,token,version
   from fc_dispapeles_acceso
 LET ls_salida =""
 OPEN WINDOW w_vista WITH FORM "Vista" DIALOG ATTRIBUTES(UNBUFFERED)
    INPUT tipodoc,prefijo,numfactu,ls_salida
     FROM  txt_tipodoc,txt_prefijo,txt_folio_manual,txt_salida
     ATTRIBUTES( WITHOUT DEFAULTS) 
     END INPUT
  BEFORE  DIALOG
   LET cbtipd = ui.ComboBox.forName("txt_tipodoc")
   CALL cbtipd.clear()
   CALL cbtipd.addItem("7","DOCUMENTO SOPORTE")
   CASE
    WHEN tipodoc = "7"
      CALL envio_documento_fact(tipodoc, prefijo, numfactu)
    WHEN tipodoc = "2" OR tipodoc ="3"
      CALL envio_documento_nota(tipodoc, prefijo, numfactu)
   END CASE
  LET ls_salida = ls_salida,"\n+++++++++++++++++++++Consulta Método Respuesta Envio +++++++++++++++++++++"
   CALL ui.Interface.refresh()
   CALL Enlace_Doc_bbl.f_RespuestaEnvio_Recupera()
     RETURNING codigoQr,consecutivo_r,cufe,descripcionProceso,estadoProceso,
      fechaExpedicion,fechaFactura,fechaRespuesta,firmaDelDocumento,idErp_r,prefijo_r,
      selloDeValidacion,tipoDocumento_r
    LET ls_salida = ls_salida,"\nRespuesta Protocolo: "
    LET ls_salida = ls_salida,sqlca.sqlerrm
    LET ls_salida = ls_salida,"\nRespuesta Proceso: "
    LET ls_salida = ls_salida, descripcionProceso
    IF cufe IS NOT NULL THEN
      LET cnt =0
      SELECT COUNT(*) INTO cnt
        FROM fc_respenvio
        WHERE tpdocumento = tipodoc
        AND prefijo = prefijo
        AND numfac = numfactu
       IF cnt IS NULL THEN LET cnt = 0 END IF
     IF cnt = 0 THEN  
       INSERT INTO fc_respenvio
       (tpdocumento,prefijo,numfac, cufe, fecfactura, fecresp, fecexped, codest)
       VALUES 
        (tipoDocumento_r, prefijo_r, consecutivo_r,cufe, fechaFactura,fechaRespuesta,
        fechaExpedicion,estadoProceso)
      END IF 
    END if 
      FOR contadorMensajes = 1 TO Enlace_Doc_bbl.f_MensajesProceso_Conteo()
           CALL Enlace_Doc_bbl.f_MensajesProceso_Recupera(contadorMensajes)
            RETURNING codigoMensaje,descripcionMensaje,rechazoNotificacion
                LET ls_salida = ls_salida,"\nMensaje: "
                LET ls_salida = ls_salida,descripcionMensaje
                LET ls_salida = ls_salida,"\nNotificacion REchazo: "
                LET ls_salida = ls_salida,rechazoNotificacion
                CALL ui.Interface.refresh()
     END FOR
        ON ACTION bt_cerrar
            EXIT DIALOG
    END DIALOG
    CLOSE WINDOW w_vista
   --ACTUALIZAR LA FACTURA O NOTA DE ACUERDO A LOS DATOS DE LA RESPUESTA.
   IF tipodoc = "1" OR tipodoc = "4" THEN
    LET mtime=TIME
    CASE 
     WHEN estadoProceso= "1" AND cufe IS NOT NULL 
       UPDATE fc_factura_m
        SET cufe = cufe, fecha_factura = fechaFactura, estado ="S", fecest = fechaRespuesta,
         codest = estadoProceso, hora = mtime     
        WHERE fc_factura_m.prefijo = prefijo
       AND fc_factura_m.numfac = numfactu
      WHEN estadoProceso= "24"  
       UPDATE fc_factura_m
        SET fecha_factura = fechaFactura, estado ="G", fecest = fechaRespuesta,
         codest = estadoProceso, hora = mtime     
        WHERE fc_factura_m.prefijo = prefijo
       AND fc_factura_m.numfac = numfactu
    END CASE
  ELSE
    if estadoProceso= "1" AND cufe IS NOT NULL THEN 
       UPDATE fc_nota_m
        SET cude = cufe, fecha_nota = fechaFactura, estado ="S", fecest = fechaRespuesta,
         codest = estadoProceso, hora = mtime     
        WHERE fc_nota_m.tipo = prefijo
       AND fc_nota_m.numnota = numfactu
    END IF    
  END if 
END FUNCTION

FUNCTION descarga_documento(tipodoc, prefijo, numfac)
  DEFINE tipodoc CHAR(1)
  DEFINE prefijo CHAR(4)
  DEFINE numfac  INTEGER
  DEFINE resope INTEGER
  DEFINE mfecha_eje DATE
  DEFINE mhora_eje  CHAR(10)
  CASE
  WHEN tipodoc = "7"
    LET newnamefile = fgl_getenv("HOME"),"/",mprefijo CLIPPED, "/",
       mprefijo CLIPPED, mnumfac USING "&&&&&&&"
  WHEN tipodoc = "2"  
    LET newnamefile = fgl_getenv("HOME"),"/NOTAC/NC", mnumfac USING "&&&&&&&"
  WHEN tipodoc = "3" 
    LET newnamefile = fgl_getenv("HOME"),"/NOTAD/ND", mnumfac USING "&&&&&&&"
  END CASE
  --LET ruta_descarga = "C:\\FacturasEscenarios\\Archivos\\"
  LET ruta_descarga = "/home/jinformix/"
  EXECUTE IMMEDIATE "set encryption password ""Confaoriente2020"""
   select fc_dispapeles_acceso.idEmpresa
       ,""
       ,fc_dispapeles_acceso.usuario
       ,decrypt_char(fc_dispapeles_acceso.contrasena) as contrasena
       ,decrypt_char(fc_dispapeles_acceso.token) as token
       ,fc_dispapeles_acceso.version
   INTO idEmpresa,idErp,usuario,contrasena,token,version
   from fc_dispapeles_acceso
   LET ls_salida ="" 
  OPEN WINDOW w_vista WITH FORM "Vista" DIALOG ATTRIBUTES(UNBUFFERED)
     INPUT ls_salida,tipodoc,prefijo,numfac  
     FROM  txt_salida,txt_tipodoc,txt_prefijo, txt_folio_manual
     ATTRIBUTES (WITHOUT DEFAULTS)
    END INPUT 
  BEFORE DIALOG 
  LET cbtipd = ui.ComboBox.forName("txt_tipodoc")
   CALL cbtipd.clear()
   CALL cbtipd.addItem("7","DOCUMENTO SOPORTE")
   CALL cbtipd.addItem("2","NOTA CREDITO")
   CALL cbtipd.addItem("3","NOTA DEBITO")
   CALL cbtipd.addItem("4","FACTURA CONTINGENCIA")
  IF tipodoc = "1" THEN
   LET ls_salida = ls_salida,"\n+++++++++++++++++++++Descarga PDF Documento Soporte +++++++++++++++++++++"
  ELSE
   LET ls_salida = ls_salida,"\n+++++++++++++++++++++Descarga PDF Nota  +++++++++++++++++++++"
  END IF 
  CALL ui.Interface.refresh()
  --Inicializa la información para llevar a cabo la consulta de archivos
    CALL Enlace_Archivo_bbl.f_consultarFacturaArchivo_Agrega(
      numfac           --consecutivo  
     ,contrasena       --contrasena  
     ,idEmpresa        --idEmpresa  
     ,"DS"          --prefijo CLIPPED         -- OJO PRUEBA  
     ,1                --Solo trae el "PDF"
     ,tipodoc          --tipoDocumento  
     ,token            --token  
     ,usuario          --usuario  
     ,version          --version 
     )
     --Recupera la información referente a la consulta de archivos
      CALL Enlace_Archivo_bbl.f_RespuestaDescargaDocumentos_Recupera()
         RETURNING  codigoRespuesta, numfac, descripcionRespuesta, 
         estadoProceso, idErp, prefijo, tipodoc
      LET ls_salida = ls_salida, "\nCódigo de error       = "
      IF NOT SQLCA.sqlerrm IS NULL THEN
        LET ls_salida = ls_salida||SQLCA.sqlerrm
      END IF
      LET ls_salida = ls_salida,"\nCodigo Respuesta      = "
      IF NOT SQLCA.sqlerrm IS NULL THEN
        LET ls_salida = ls_salida||codigoRespuesta
      END IF
      LET ls_salida = ls_salida,"\nDescripción respuesta = "
      IF NOT SQLCA.sqlerrm IS NULL THEN
        LET ls_salida = ls_salida, descripcionRespuesta
      END IF
     --Recupera todos los mensajes resultantes de la consulta
     FOR indice = 1 TO Enlace_Archivo_bbl.f_RespuestaTamanoConsultarArchivos_listaMensajes_Recupera()
        CALL Enlace_Archivo_bbl.f_RespuestaMensajesProcesoArchivo_Recupera(indice)
           RETURNING codigoMensaje
                , descripcionMensaje
                , rechazoNotificacion
              LET ls_salida = ls_salida,"\nMensaje: ",codigoMensaje," - ", descripcionMensaje
     END FOR
     --Guarda todos los archivos resultantes de la consulta
      CALL Enlace_Archivo_bbl.f_ConsultarArchivos_Guardar(ruta_descarga)
     --Recupera todos los archivos resultantes de la consulta
      FOR indice = 1 TO Enlace_Archivo_bbl.f_RespuestaTamanoConsultarArchivos_listaArchivos_Recupera()
        CALL Enlace_Archivo_bbl.f_RespuestaArchivos_Recupera(indice)
         RETURNING  formato
            ,mimeType
            ,nameFile
            ,streamFile
          LET ls_salida = ls_salida,"\nArchivo = "
          LET ls_salida = ls_salida,nameFile
          LET ls_salida = ls_salida,"\nRuta Descarga = ", ruta_descarga CLIPPED, nameFile
          CALL ui.Interface.refresh()
          CALL FGL_PUTFILE(ruta_descarga||nameFile,prefijo||"-"||numfac||"."||formato)
          --CALL ui.Interface.frontCall("standard", "shellexec", ruta_descarga||nameFile, resope)
      END FOR
   ON ACTION bt_cerrar
        EXIT DIALOG
    END DIALOG
    CLOSE WINDOW w_vista
END FUNCTION

FUNCTION consulta_estado_documento(tipodoc, prefijo, numfac)
  DEFINE tipodoc, tipodocumento CHAR(1)
  DEFINE prefijo, prefijo_factu CHAR(4)
  DEFINE numfac,numfactura  INTEGER
  DEFINE mfecha_eje DATE
  DEFINE mhora_eje  CHAR(10)
  LET ls_salida ="" 
   EXECUTE IMMEDIATE "set encryption password ""Confaoriente2020"""
   select fc_dispapeles_acceso.idEmpresa
       ,""
       ,fc_dispapeles_acceso.usuario
       ,decrypt_char(fc_dispapeles_acceso.contrasena) as contrasena
       ,decrypt_char(fc_dispapeles_acceso.token) as token
       ,fc_dispapeles_acceso.version
   INTO idEmpresa,idErp,usuario,contrasena,token,version
   from fc_dispapeles_acceso
  LET tipodocumento = tipodoc
  LET prefijo_factu = prefijo
  LET numfactura= numfac
  LET ls_salida ="" 
  OPEN WINDOW w_vista WITH FORM "Vista"
  DIALOG ATTRIBUTES(UNBUFFERED)
    INPUT ls_salida,tipodoc,prefijo,numfac
     FROM  txt_salida,txt_tipodoc,txt_prefijo, txt_folio_manual
     ATTRIBUTES (WITHOUT DEFAULTS)
     END INPUT 
  BEFORE DIALOG 
   LET cbtipd = ui.ComboBox.forName("txt_tipodoc")
   CALL cbtipd.clear()
   CALL cbtipd.addItem("7","DOCUMENTO SOPORTE")
   CALL cbtipd.addItem("2","NOTA CREDITO")
   CALL cbtipd.addItem("3","NOTA DEBITO")
   CALL cbtipd.addItem("4","FACTURA CONTINGENCIA")
   LET ls_salida = ls_salida,"\n----------------------------Consultar Estado Documento -----------------------------------------"
   CALL Enlace_DocEstado_bbl.f_ConsultarEstado_Agrega(
                  numfactura      --consecutivo
                , contrasena      --contrasena
                , idEmpresa       --idEmpresa
                , prefijo_factu CLIPPED   --prefijo
                , tipodocumento   --tipoDocumento
                , token           --token
                , usuario         --usuario
                , version         --version
            )
  --Recupera el resultado de la consulta del Estado de la factura
    CALL Enlace_DocEstado_bbl.f_RespuestaConsultarEstado_Recupera()
      RETURNING  codigoQr 
                , codigoUltimoEstadoAdquirente 
                , codigoUltimoEstadoDian 
                , codigoUltimoEstadoDispapeles 
                , codigoUltimoEstadoEmail 
                , numfactura 
                , cufe 
                , descripcionUltimoEstadoAdquirente 
                , descripcionUltimoEstadoDian 
                , descripcionUltimoEstadoDispapeles 
                , descripcionUltimoEstadoEmail 
                , estadoProceso 
                , fechaFactura 
                , fechaRespuesta 
                , fechaRespuestaUltimoEstadoAdquirente 
                , fechaRespuestaUltimoEstadoDian 
                , fechaRespuestaUltimoEstadoDispapeles 
                , fechaRespuestaUltimoEstadoEmail 
                , firmaDelDocumento 
                , idErp 
                , idLote 
                , prefijo_factu 
                , selloDeValidacion 
                , tipodocumento
    LET ls_salida = ls_salida,"\nMensaje de error: ",sqlca.sqlerrm
    LET ls_salida = ls_salida,"\ncodigoQR      = ",codigoQr
    LET ls_salida = ls_salida,"\nDescripcion_Ultimo_Estado_Dian       = ",descripcionUltimoEstadoDian
    LET ls_salida = ls_salida,"\ndescripcion_Ultimo_Estado_Adquirente = ",descripcionUltimoEstadoAdquirente
    LET mfecha_eje = TODAY
    IF fechaRespuesta IS NOT NULL AND numfactura IS NOT NULL THEN
      LET cnt = 0 
      SELECT COUNT(*) INTO cnt 
       FROM fc_estados_fac
       WHERE fc_estados_fac.prefijo = prefijo
       AND fc_estados_fac.numfac = numfac
       AND fc_estados_fac.tpdocumento = tipodoc
      IF cnt IS NULL THEN LET cnt= 0 END IF
      DISPLAY " no hay regsitro insertando", cnt
      IF cnt = 0 THEN 
        INSERT INTO fc_estados_fac
       (tpdocumento, prefijo, numfac, fecfactura, cufe, codult_estdisp, des_ult_estdisp,
        fecres_ultestdisp, cod_ult_estdian, des_ult_estdian, fecres_ultestdian, cod_ult_estmail,
        des_ult_estmail, fecres_ultestmail, cod_ult_estadq, des_ult_estadq, fecres_ultestadq, 
        codest,fecest, fecrep)
        VALUES (tipodoc, prefijo, numfac, fechaFactura, cufe, codigoUltimoEstadoDispapeles,
         descripcionUltimoEstadoDispapeles, fechaRespuestaUltimoEstadoDispapeles, 
         codigoUltimoEstadoDian, descripcionUltimoEstadoDian, fechaRespuestaUltimoEstadoDian, 
         codigoUltimoEstadoEmail, descripcionUltimoEstadoEmail,fechaRespuestaUltimoEstadoEmail,                     
         codigoUltimoEstadoAdquirente, descripcionUltimoEstadoAdquirente, fechaRespuestaUltimoEstadoAdquirente,  
         estadoProceso, fechaRespuesta, fechaFactura)
      ELSE    
       UPDATE fc_estados_fac
       SET (cufe, codult_estdisp, des_ult_estdisp,fecres_ultestdisp, cod_ult_estdian, des_ult_estdian, fecres_ultestdian, cod_ult_estmail,
        des_ult_estmail, fecres_ultestmail, cod_ult_estadq, des_ult_estadq, fecres_ultestadq, 
        codest,fecest, fecrep  )
        = ( cufe, codigoUltimoEstadoDispapeles,
         descripcionUltimoEstadoDispapeles, fechaRespuestaUltimoEstadoDispapeles, 
         codigoUltimoEstadoDian, descripcionUltimoEstadoDian, fechaRespuestaUltimoEstadoDian, 
         codigoUltimoEstadoEmail, descripcionUltimoEstadoEmail,fechaRespuestaUltimoEstadoEmail,                     
         codigoUltimoEstadoAdquirente, descripcionUltimoEstadoAdquirente, fechaRespuestaUltimoEstadoAdquirente,  
         estadoProceso, fechaRespuesta, fechaFactura)
        WHERE fc_estados_fac.tpdocumento = tipodoc
         AND  fc_estados_fac.prefijo = prefijo
         AND  fc_estados_fac.numfac = numfac
      END if  
      -- Se consultan todos los mensajes asociados a la respuesta al consumo del método "consultarEstado"
      FOR indice = 1 TO Enlace_DocEstado_bbl.f_RespuestaTamanoConsultarEstado_listaMensajes_Recupera()
        LET mhora_eje = TIME 
         CALL f_RespuestaMensajesProceso_Recupera(indice)
          RETURNING  codigoMensaje
          , descripcionMensaje
          , rechazoNotificacion
           LET ls_salida = ls_salida,"\nMensaje = ",descripcionMensaje
        END FOR
      IF estadoProceso= "1" AND codigoUltimoEstadoAdquirente <> "3" 
      AND cufe IS NOT null THEN   -- EXITOSO
         CASE 
          WHEN tipodoc = "7"   
           UPDATE fc_factura_m
           SET  estado ="P", fecest = fechaRespuesta,  codest = estadoProceso    
           WHERE fc_factura_m.prefijo = prefijo
           AND fc_factura_m.numfac = numfac
           AND fc_factura_m.estado NOT IN ("N", "X","D", "R")
          WHEN tipodoc = "2" OR tipodoc ="3"   
           UPDATE fc_nota_m
            SET estado ="P", fecest = fechaRespuesta, codest = estadoProceso    
            WHERE fc_nota_m.tipo = prefijo
           AND fc_nota_m.numnota = numfac
           AND fc_nota_m.estado NOT IN ( "X","D", "R")
        END CASE
      END IF
      IF codigoUltimoEstadoAdquirente = "3"  THEN     -- RECHAZADA CLIENTE
         CASE 
          WHEN tipodoc = "7"   
           UPDATE fc_factura_m
           SET  estado ="R", fecest = DATE(fechaRespuestaUltimoEstadoAdquirente), codest = codigoUltimoEstadoAdquirente    
           WHERE fc_factura_m.prefijo = prefijo
           AND fc_factura_m.numfac = numfac
          WHEN tipodoc = "2" OR tipodoc ="3"   
           UPDATE fc_nota_m
            SET estado ="R", fecest = DATE(fechaRespuestaUltimoEstadoAdquirente),  codest = codigoUltimoEstadoAdquirente  
            WHERE fc_nota_m.tipo = prefijo
           AND fc_nota_m.numnota = numfac
        END CASE
      END IF
     IF codigoUltimoEstadoDispapeles = "19" THEN      -- RECHAZADA X DISPAPELES
        CASE 
          WHEN tipodoc = "7"   
           UPDATE fc_factura_m
           SET  estado ="X", fecest = DATE(fechaRespuestaUltimoEstadoDispapeles),  codest = codigoUltimoEstadoDispapeles    
           WHERE fc_factura_m.prefijo = prefijo
           AND fc_factura_m.numfac = numfac
          WHEN tipodoc = "2" OR tipodoc ="3"   
           UPDATE fc_nota_m
            SET estado ="X", fecest =  DATE(fechaRespuestaUltimoEstadoDispapeles), codest = codigoUltimoEstadoDispapeles
            WHERE fc_nota_m.tipo = prefijo
           AND fc_nota_m.numnota = numfac
         END CASE
      END IF  
      IF  codigoUltimoEstadoDian = "4" THEN      -- RECHAZADA X LA DIAN
        CASE 
          WHEN tipodoc = "7"   
           UPDATE fc_factura_m
           SET  estado ="D", fecest =  DATE(fechaRespuestaUltimoEstadoDian),  codest = codigoUltimoEstadoDian    
           WHERE fc_factura_m.prefijo = prefijo
           AND fc_factura_m.numfac = numfac
          WHEN tipodoc = "2" OR tipodoc ="3"   
           UPDATE fc_nota_m
            SET estado ="D", fecest =  DATE(fechaRespuestaUltimoEstadoDian), codest =  codigoUltimoEstadoDian
            WHERE fc_nota_m.tipo = prefijo
           AND fc_nota_m.numnota = numfac
         END CASE
      END IF  
    END IF  
    DISPLAY ls_salida
    ON ACTION bt_cerrar
        EXIT DIALOG
    END DIALOG
    CLOSE WINDOW w_vista
END FUNCTION

FUNCTION envio_documento_fact(tipodoc, prefijo, numfactu)
  DEFINE tipodoc, mtipdoc   LIKE    fc_factura_m.tipodocumento
  DEFINE prefijo            LIKE    fc_factura_m.prefijo
  DEFINE numfactu           LIKE    fc_factura_m.numfac 
  DEFINE mdocumento         CHAR(7) 
  LET DesMedioPago =""
  LET lineaNota1= ""
  LET lineaNota2= ""
  LET lineaNota3= ""
  LET lineaNota4= ""
  LET NombreAprobo=""
  LET NombreElaboro=""  
  LET ls_salida = ""
  LET tiponota = "0"
  INITIALIZE mfc_factura_m.* TO NULL
  SELECT * INTO mfc_factura_m.*
    FROM fc_factura_m
     WHERE fc_factura_m.prefijo = prefijo
     AND fc_factura_m.numfac = numfactu
  LET mdocumento = mfc_factura_m.documento 
    LET ls_salida = ls_salida,"\n---------------------------------- Proceso Metodo Enviar Documento Soporte--------------------------------------------"
    LET ls_salida = ls_salida,"\n+++++++++++++++++++++Inicia obtencion de datos+++++++++++++++++++++"
    CALL ui.Interface.refresh()
    LET ls_salida = ls_salida, "\nResultado del Encabezado Factura -  Documento Interno: ", mfc_factura_m.documento
  CASE mfc_factura_m.medio_pago 
    WHEN "10"
     LET DesMedioPago = "EFECTIVO"
   WHEN "20"
     LET DesMedioPago = "CHEQUE"
   WHEN "42"
     LET DesMedioPago ="CONSIGNACION"
   WHEN "45"
     LET DesMedioPago ="TRANSFERENCIA"
   WHEN "48"
     LET DesMedioPago = "TARJETA DE CREDITO"
   WHEN "49"
     LET DesMedioPago = "TARJETA DEBITO"
  END CASE 
  LET lineaNota1 = mfc_factura_m.nota1[1,70]
  LET lineaNota2 = mfc_factura_m.nota1[71,140]
  LET lineaNota3 = mfc_factura_m.nota1[141,210]
  LET lineaNota4 = mfc_factura_m.nota1[211,280]
  SELECT nombre INTO NombreAprobo 
    FROM gener02
   WHERE gener02.usuario = mfc_factura_m.usuario_apru
  SELECT nombre INTO NombreElaboro 
    FROM gener02
   WHERE gener02.usuario = mfc_factura_m.usuario_add
  LET cantidadLineas = 0  
  SELECT COUNT(*) INTO cantidadLineas
    FROM fc_factura_d
     WHERE trim(fc_factura_d.prefijo) = prefijo
     AND fc_factura_d.documento = mdocumento
    LET ls_salida = ls_salida, "\nNumero de items en venta : ", cantidadLineas
  INITIALIZE mfc_terceros.* TO NULL
  SELECT * INTO mfc_terceros.*
    FROM fc_terceros
     WHERE fc_terceros.nit = mfc_factura_m.nit
  LET tipoobligacion=""
 {INITIALIZE mfc_terobligacion.* TO NULL
  DECLARE cur_obli_adq CURSOR FOR
  SELECT * 
   FROM fc_terobligacion
   WHERE fc_terobligacion.nit =  mfc_terceros.nit
   FOREACH cur_obli_adq INTO  mfc_terobligacion.*
     LET tipoobligacion = mfc_terobligacion.codigo_oblig
     EXIT FOREACH
   END FOREACH}
   IF tipoobligacion IS NULL OR tipoobligacion ="" THEN
     LET tipoobligacion ="R-99-PN"
  {ELSE
     DECLARE cur_obli_adq2 CURSOR FOR
     SELECT * FROM fc_terobligacion
     WHERE fc_terobligacion.nit =  mfc_terceros.nit
     FOREACH cur_obli_adq2 INTO  mfc_terobligacion.*
       LET tipoobligacion = tipoobligacion CLIPPED, ";" , mfc_terobligacion.codigo_oblig
     END FOREACH}
   END if  
  INITIALIZE mfe_ciudades.* TO NULL
  SELECT * INTO mfe_ciudades.* 
   FROM fe_ciudades
    WHERE fe_ciudades.codciu = mfc_terceros.zona  
  LET departamento = mfc_terceros.zona[1,2]
  INITIALIZE mfe_deptos.* TO NULL 
  SELECT * INTO mfe_deptos.*
   FROM fe_deptos
    WHERE fe_deptos.coddep = departamento
  INITIALIZE mfe_paises.* TO NULL 
  SELECT * INTO mfe_paises.*
   FROM fe_paises
    WHERE fe_paises.codpais = mfc_terceros.pais
  INITIALIZE nombreCompleto TO NULL 
  IF mfc_terceros.tipo_persona = "1" THEN 
    LET nombreCompleto = mfc_terceros.razsoc 
  ELSE 
   LET nombreCompleto =  mfc_terceros.primer_nombre CLIPPED, ' ', mfc_terceros.segundo_nombre CLIPPED,
    ' ', mfc_terceros.primer_apellido CLIPPED,' ', mfc_terceros.segundo_apellido CLIPPED
  END IF
  LET ls_salida = ls_salida, "\nAdquiriente : ", mfc_terceros.nit CLIPPED , " " , nombreCompleto
  {IF mfc_terceros.tipid =  "31"  THEN  -- tipo de identificadion NIT
    IF mfc_terceros.digver = "" OR mfc_terceros.digver IS NULL THEN
      CALL FGL_WINMESSAGE( "Mensaje de error ", "El Cliente no tiene registrado el digito de verificación ","stop") 
      RETURN
    END IF
  END IF}
  INITIALIZE mfe_regimen.* TO NULL
  SELECT * INTO mfe_regimen.*
   FROM fe_regimen
    WHERE regimen = mfc_terceros.regimen
  LET aplicafel ="NO"
  INITIALIZE envioPorEmailPlataforma TO NULL 
  IF mfc_terceros.email IS NOT NULL THEN
    LET envioPorEmailPlataforma = "EMAIL"
    LET aplicafel ="SI"
  END IF 
  LET nitProveedorTecnologico = "" 
  LET mhoy = CURRENT YEAR TO MINUTE  
  LET codigoPlantillaPdf = 0
  LET ciudadFacturador =""
  LET telefonoFacturador= ""
  LET lineaResDian1= ""
  LET lineaResDian2= ""
   INITIALIZE mfc_prefijos.*  TO NULL
   SELECT * INTO mfc_prefijos.*
    FROM fc_prefijos
     WHERE fc_prefijos.prefijo = mfc_factura_m.prefijo
   SELECT detzon INTO ciudadFacturador 
     FROM gener09
     WHERE gener09.codzon = mfc_prefijos.zona
    LET telefonoFacturador = " TELEFONO:  ", mfc_prefijos.telefono
    LET lineaResDian1 = " Autorización numeración: ", mfc_prefijos.num_auto CLIPPED, 
      " de ", mfc_prefijos.fec_auto USING "dd/mm/yyyy"
    LET lineaResDian2= "Rango autorizado ", mfc_prefijos.prefijo CLIPPED , " del ",
    mfc_prefijos.numini USING "-----&", " - ", mfc_prefijos.numfin USING "------&", " ", 
    " vence el ", mfc_prefijos.fec_ven USING "dd/mm/yyyy"  
   -- LLAMADO CABEZA DE DOCUMENTO
   CALL Enlace_Doc_bbl.f_CabezaDocumento_Agrega(
     aplicafel,
     cantidadLineas,
     "",                 -- centroCostos,
     codigoPlantillaPdf,
     "",                 --  codigovendedor
     mfc_factura_m.numfac,  
     contrasena,
     "",              --  descripcionCentroCostos
     mhoy,        -- mfc_factura_m.fecha_factura,                 --  en el envio la fecha de la factura es el dia 
     idEmpresa,
     idErp,
     "",                   -- incoterm
     "",                   --  nombrevendedor
    "DS",      -- mfc_factura_m.prefijo CLIPPED, (PREFIJO DE PRUEBAS OJO)
     "",                   --  Sucursal
     mfc_factura_m.tipoope,
     mfc_factura_m.tipodocumento,
     tiponota,
     token,usuario,version,
     nombreImpresora,
     campoAdicional1,
     campoAdicional2,
     campoAdicional3,
     campoAdicional4,
     campoAdicional5)
   -- LLAMADO DATOS DEL ADQUIRIENTE
   CALL Enlace_Doc_bbl.f_Adquirente_Agrega(
        "",        --barioLocalidad 1
       mfe_ciudades.nombreciu CLIPPED, -- Nombre ciudad duplicado 2
       "",        --codigoCIUU (Actividad economica) --3
       mfc_terceros.zona CLIPPED, --codigo ciudad
       "",        --codigoPostal --4
       departamento, --5
       mfe_ciudades.nombreciu CLIPPED, --6   
       mfc_terceros.digver, --7
       mfc_terceros.direccion CLIPPED, --8
       mfc_terceros.email CLIPPED, --9
       envioPorEmailPlataforma, --10
       "",        --matriculaMercantil, --11
       nitProveedorTecnologico, --12
       nombreCompleto CLIPPED, --13
       mfe_deptos.nombredep CLIPPED, --14
       mfc_terceros.nit CLIPPED,  --15
       mfc_terceros.pais CLIPPED, --16
       mfe_paises.nombrepais CLIPPED, --17
       "", --18
       mfe_regimen.codreg, --19
       mfc_terceros.telefono CLIPPED, --20
       mfc_terceros.tipid, --21
       mfc_terceros.tipo_persona, --22
       tipoobligacion  CLIPPED --23
       )
 -- LLAMADO DETALLE DEL DOCUMENTO
   LET campoAdicional1 = "" 
   LET campoAdicional2 = ""
   LET campoAdicional3 = ""
   LET campoAdicional4 = ""
   LET campoAdicional5 = ""
   LET subtotalfac = 0
   LET valorEnLetrasSubTotal = 0
   LET valorAdicional1 =""
   LET valorAdicional2 =""
   LET valorAdicional3 =""
   LET valorAdicional4= ""
   LET valorAdicional5=""
   LET posicion = 0
   LET TotalIva = 0
   LET TotalBen = 0
   LET TotalSub = 0
   LET TotalImpc = 0
   LET descuento = 0
   LET Subtotal = 0
    DECLARE Cur_DetDocto CURSOR FOR
    SELECT * FROM fc_factura_d
     WHERE trim(fc_factura_d.prefijo) = mfc_factura_m.prefijo
     AND fc_factura_d.documento = mfc_factura_m.documento  
    ORDER BY fc_factura_d.codigo
    FOREACH Cur_DetDocto INTO mfc_factura_d.*
      LET posicion = posicion + 1
      LET Subtotal = Subtotal + (mfc_factura_d.valoruni * mfc_factura_d.cantidad)
      INITIALIZE rec_mfc_servicios.* TO NULL
      SELECT * INTO rec_mfc_servicios.* 
        FROM fc_servicios
         WHERE fc_servicios.codigo = mfc_factura_d.codigo
      LET nombreProducto = rec_mfc_servicios.descripcion CLIPPED 
      --ojo con subcodigo
      IF mfc_factura_d.subcodigo IS NOT NULL AND mfc_factura_d.subcodigo <> "0" THEN
        INITIALIZE mfc_sub_servicios.* TO NULL
        SELECT * INTO mfc_sub_servicios.* 
        FROM fc_sub_servicios
         WHERE fc_sub_servicios.codigo = mfc_factura_d.subcodigo
        LET nombreProducto = nombreProducto CLIPPED, ' ', mfc_sub_servicios.descripcion CLIPPED
      END IF
      LET muestracomercial= 0
      CALL Enlace_Doc_bbl.f_DetalleDocumento_Agrega(
        "no",          --aplicaMandato,
        0,             -- CampoAdicional1
        0,             --campoAdicional2,
        0,             --campoAdicional3,
        0,             --campoAdicional4,
        0,             --campoAdicional5,
        mfc_factura_d.cantidad,
        mfc_factura_d.codigo,
        "",             --descripcion,
        "",             --familia,
        "",             --fechaSuscripcionContrato,
        "",             --gramaje,
        "",
        "",             --marca,
        "",             --modelo,
        muestracomercial,
        0,             --muestracomercialcodigo,
        nombreProducto,
        posicion,
        mfc_factura_d.base_imponible,
        mfc_factura_d.total_pagar,
        "",             --referencia,
        "",             --seriales,
        0,             --tamanio,
        rec_mfc_servicios.tpimpuesto,          -- tipoImpuesto  OJO EXENTO
        "999",            --tipocodigoproducto,  
        rec_mfc_servicios.coduni  CLIPPED,
        mfc_factura_d.valoruni,   
        0    -- valorunitarioporcantidad
        )
          
     -- LLAMADO A AGREGAR LISTA DE IMPUESTOS
      LET isAutoRetenido = 0
      --IF mfc_factura_d.iva =  0  AND mfc_factura_d.impc =0 THEN 
          CALL Enlace_Doc_bbl.f_Impuesto_Detalle_Agrega(
          mfc_factura_d.base_imponible,          
          "01",                     --codigoImpuestoRetencion  -  IVA
          isAutoRetenido,
          0,--rec_mfc_servicios.iva,
          0) --mfc_factura_d.total_iva)
     -- END IF
     {IF mfc_factura_d.iva > 0  THEN 
          CALL Enlace_Doc_bbl.f_Impuesto_Detalle_Agrega(
          mfc_factura_d.base_imponible,          
          "01",                     --codigoImpuestoRetencion  -  IVA
          isAutoRetenido,
          rec_mfc_servicios.iva,
          mfc_factura_d.total_iva)
      END IF
      IF mfc_factura_d.impc > 0  THEN
          CALL Enlace_Doc_bbl.f_Impuesto_Detalle_Agrega(
          mfc_factura_d.base_imponible,          
          "02",                     --codigoImpuestoRetencion  -  IVA
          isAutoRetenido,
          rec_mfc_servicios.impc,
          mfc_factura_d.total_impc) 
      END IF  }  
      -- LLAMADO A AGREGAR LISTA DE DESCUENTOS  ( EN NUESTRO CASOS SUBSIDIOS
    END FOREACH  
    -- LLAMADO A IMPUESTOS GLOBALES
    INITIALIZE mfc_factura_imp.* TO NULL
    DECLARE cur_impglo CURSOR FOR  
    SELECT * FROM fc_factura_imp
     WHERE trim(fc_factura_imp.prefijo) = mfc_factura_m.prefijo
     AND fc_factura_imp.documento = mfc_factura_m.documento  
    FOREACH cur_impglo INTO mfc_factura_imp.*
       CALL Enlace_Doc_bbl.f_Impuesto_Agrega(
          mfc_factura_imp.base,
          mfc_factura_imp.codimp,
          mfc_factura_imp.autoret,
          mfc_factura_imp.porcentaje,
          mfc_factura_imp.valor
          )
       CASE 
        WHEN mfc_factura_imp.codimp = "01"  
          LET TotalIva = TotalIva + mfc_factura_imp.valor 
        WHEN mfc_factura_imp.codimp = "02"  
          LET TotalImpc = TotalImpc + mfc_factura_imp.valor
       END CASE  
    END FOREACH
  -- LLAMADO A TOTALES DE FACTURA  (PAGOS)
  IF mfc_factura_m.forma_pago ="2" THEN 
    LET fechaVencimiento =  mfc_factura_m.fecha_vencimiento
    LET periododepago = mfc_prefijos.dias_cred
  ELSE
    LET fechaVencimiento = NULL
    LET periododepago = 0
  END IF  
  IF mfc_factura_m.fecha_vencimiento < TODAY THEN
     LET fechavencimiento = DATE( CURRENT )+60
  END IF
   INITIALIZE mfc_factura_tot.* TO NULL
    SELECT * INTO mfc_factura_tot.* 
     FROM fc_factura_tot
     WHERE trim(fc_factura_tot.prefijo) = mfc_factura_m.prefijo
     AND fc_factura_tot.documento = mfc_factura_m.documento  
    CALL Enlace_Doc_bbl.f_Pagos_Agrega(
      mfc_empresa.moneda,       --codigoMonedaCambio
      NULL,         --  mfc_factura_tot.fecha_trm,
      fechaVencimiento,  
      mfc_factura_tot.moneda, 
      mfc_factura_tot.total_anticipos,
      periododepago,
      mfc_factura_m.forma_pago,
      mfc_factura_tot.total_cargos,
      0, -- mfc_factura_tot.total_descuentos,
      mfc_factura_tot.baseconimpu,
      mfc_factura_tot.baseimponible,
      mfc_factura_tot.total_factura,
      mfc_factura_tot.importebruto,
      mfc_factura_tot.trm, 
      NULL,          --trm_alterna,
      subtotalfac,
      valorEnLetrasSubTotal,
      valorAdicional1,
      valorAdicional2,
      valorAdicional3,
      valorAdicional4,
      valorAdicional5,
      "",       --valorEnLetras1
      "",       --valorEnLetras2
      "",       --valorEnLetras3
      "",       --valorEnLetras4
      "",       --valorEnLetras5
      redondeoTotalFactura
      )
      CALL Enlace_Doc_bbl.f_MedioPago_Agrega(mfc_factura_m.medio_pago)
   -- LLAMADOS PARA AGREGAR CAMPOS ADICIONALES EN EL DISEÑO DE LA FACTURA.
   {  LET mvalche = mfc_factura_tot.total_factura
     CALL letras()
     LET lineaMonto1 = mletras1[1,69]
     LET lineaMonto2 = mletras2[1,70]
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Regimen",1,1,mfc_empresa.regimen CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"DirFacturador",1,1,mfc_prefijos.direccion CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"CiudadFacturador",1,1,ciudadFacturador CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"TelefonoFacturador",1,1,telefonoFacturador CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"ResolucionDianlinea1",1,1,lineaResDian1 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"ResolucionDianlinea2",1,1,lineaResDian2 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"LeyendaEncab1",1,1,mfc_empresa.leyenda_enc CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"DescMedioP",1,1,DesMedioPago CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"nota1",1,1,lineaNota1 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"nota2",1,1,lineaNota2 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"nota3",1,1,lineaNota3 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"nota4",1,1,lineaNota4 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"ValorLetras1",1,1,lineaMonto1 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"ValorLetras2",1,1,lineaMonto2 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"ValorLetras3",1,1,lineaMonto3 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta1",1,1,"Subtotal                  :","")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta2",1,1,"Subsidio                   :","")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta3",1,1,"Otros Beneficios     :","")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta4",1,1,"Anticipos                   :","")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta5",1,1,"Total IVA                   :","")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta6",1,1,"Total Imp/Consumo  :","")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta7",1,1,"Total a pagar            :","")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Subtotal",1,1,Subtotal,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Totalsub",1,1,TotalSub,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Totalben",1,1,TotalBen,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Totaliva",1,1,TotalIva,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"TotalImpoc",1,1,TotalImpc,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"PiePagina2",1,1,mfc_empresa.piepag_2,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"PiePagina3",1,1,mfc_empresa.piepag_3,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"NombreElaboro",1,1,NombreElaboro,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"NombreAprobo",1,1,NombreAprobo,"")}
END FUNCTION

FUNCTION enviar_factura_dian()
 DEFINE mpref       LIKE   fc_factura_m.prefijo
 DEFINE mnumfactu   LIKE   fc_factura_m.numfac
  LET mpref = NULL 
  LET mnumfactu = 0
  PROMPT "Prefijo  ===> : "    FOR mpref
  LET mpref = upshift(mpref) 
  IF mpref IS NULL THEN 
    RETURN
  END IF
  PROMPT "Numero Documento Soporte  :  "   FOR mnumfactu
  IF mnumfactu IS NULL OR mnumfactu = 0 THEN
    RETURN
   END IF
  INITIALIZE mfc_factura_m.* TO NULL
  SELECT * INTO mfc_factura_m.*
    FROM fc_factura_m
  WHERE prefijo = mpref
   AND numfac = mnumfactu
  IF mfc_factura_m.numfac IS NULL THEN
    CALL FGL_WINMESSAGE( "Mensaje de error ", "El Documento soporte no fue encontrada","stop")
    RETURN
  END IF
  IF mfc_factura_m.estado <> "A" AND mfc_factura_m.estado <> "S" AND mfc_factura_m.estado <> "G" THEN
    CALL FGL_WINMESSAGE( "Mensaje de error ", "El documento soporte no esta en un estado valido para ser transmitida","stop")
    RETURN
  END IF
  {CALL act_totales_factura( mfc_factura_m.prefijo, mfc_factura_m.documento)}
  CALL envio_documento("7", mfc_factura_m.prefijo, mfc_factura_m.numfac)
END FUNCTION

{FUNCTION enviar_nota_dian()
 DEFINE mtiponota       CHAR(2)     
 DEFINE mnumnota        LIKE   fc_nota_m.numnota
  LET mtiponota = NULL 
  LET mnumnota = 0
  PROMPT "Tipo de Nota [NC/ND] : "    FOR mtiponota
  LET mtiponota = upshift(mtiponota) 
  IF mtiponota IS NULL THEN 
    RETURN
  END IF
  PROMPT "Numero Nota  :  "   FOR mnumnota
  IF mnumnota IS NULL OR mnumnota = 0 THEN
    RETURN
   END IF
  INITIALIZE mfc_nota_m.* TO NULL
  SELECT * INTO mfc_nota_m.*
    FROM fc_nota_m
  WHERE tipo = mtiponota
   AND numnota = mnumnota
  IF mfc_nota_m.numnota IS NULL THEN
    CALL FGL_WINMESSAGE( "Mensaje de error ", "El numero de la nota no fue encontrada","stop")
    RETURN
  END IF
  IF mfc_nota_m.estado = "B" THEN
    CALL FGL_WINMESSAGE( "Información", "La Nota aun se encuentra en estado Borrador","information")
    RETURN
  END IF
  CALL act_totales_nota( mfc_nota_m.tipo, mfc_nota_m.documento)
  IF mtiponota ="NC" THEN
     CALL envio_documento("2",mtiponota, mfc_nota_m.numnota)
  ELSE
     CALL envio_documento("3",mtiponota, mfc_nota_m.numnota)
  END IF   
END FUNCTION}

FUNCTION consulta_estados_factu()
 DEFINE mpref       LIKE   fc_factura_m.prefijo
 DEFINE mnumfactu   LIKE   fc_factura_m.numfac
  LET mpref = NULL 
  LET mnumfactu = 0
  PROMPT "Prefijo  ===> : "    FOR mpref
  LET mpref = upshift(mpref) 
  IF mpref IS NULL THEN 
    RETURN
  END IF
  PROMPT "Numero de Documento  :  "   FOR mnumfactu
  IF mnumfactu IS NULL OR mnumfactu = 0 THEN
    RETURN
   END IF
  INITIALIZE mfc_factura_m.* TO NULL
  SELECT * INTO mfc_factura_m.*
    FROM fc_factura_m
  WHERE prefijo = mpref
   AND numfac = mnumfactu
  IF mfc_factura_m.numfac IS NULL THEN
    CALL FGL_WINMESSAGE( "Mensaje de error ", "El numero de documento no fue encontrado","stop")
    RETURN
  END IF
  IF mfc_factura_m.estado = "B"  THEN
    CALL FGL_WINMESSAGE( "Información", "El documento no ha sido trasmitido","information")
    RETURN
  END IF
  CALL consulta_estado_documento("1",mfc_factura_m.prefijo, mfc_factura_m.numfac)
END FUNCTION

FUNCTION consulta_estados_factu_masivo()
 DEFINE mpref       LIKE   fc_factura_m.prefijo
 DEFINE  mnumfactu, mnumfactu1, mnumfactu2   LIKE   fc_factura_m.numfac
  LET mpref = NULL 
  LET mnumfactu1 = 0
  LET mnumfactu2 = 0
  PROMPT "Prefijo  ===> : "    FOR mpref
  LET mpref = upshift(mpref) 
  IF mpref IS NULL THEN 
    RETURN
  END IF
  PROMPT "Numero de Documento (Inicial)  :  "   FOR mnumfactu1
  IF mnumfactu1 IS NULL OR mnumfactu1 = 0 THEN
    RETURN
   END IF
  PROMPT "Numero de Documento (Final)  :  "   FOR mnumfactu2
  IF mnumfactu2 IS NULL OR mnumfactu2 = 0 THEN
    RETURN
   END IF 
  FOR mnumfactu = mnumfactu1 TO mnumfactu2 
    INITIALIZE mfc_factura_m.* TO NULL
    SELECT * INTO mfc_factura_m.*
     FROM fc_factura_m
   WHERE prefijo = mpref
    AND numfac = mnumfactu
   IF mfc_factura_m.numfac IS NOT NULL THEN
     IF mfc_factura_m.estado <> "B"  THEN
        CALL consulta_estado_documento_2("1",mfc_factura_m.prefijo, mfc_factura_m.numfac)
    END IF
   END IF
  END FOR  
END FUNCTION

FUNCTION generar_pdf_factu()
 DEFINE mpref       LIKE   fc_factura_m.prefijo
 DEFINE mnumfactu   LIKE   fc_factura_m.numfac
  LET mpref = NULL 
  LET mnumfactu = 0
  PROMPT "Prefijo  ===> : "    FOR mpref
  LET mpref = upshift(mpref) 
  IF mpref IS NULL THEN 
    RETURN
  END IF
  PROMPT "Numero de Documento Soporte  :  "   FOR mnumfactu
  IF mnumfactu IS NULL OR mnumfactu = 0 THEN
    RETURN
   END IF
  INITIALIZE mfc_factura_m.* TO NULL
  SELECT * INTO mfc_factura_m.*
    FROM fc_factura_m
  WHERE prefijo = mpref
   AND numfac = mnumfactu
  IF mfc_factura_m.numfac IS NULL THEN
    CALL FGL_WINMESSAGE( "Mensaje de error ", "El numero de Documento no fue encontrado","stop")
    RETURN
  END IF
  IF mfc_factura_m.estado = "B"  THEN
    CALL FGL_WINMESSAGE( "Información", "La factura no ha sido trasmitida","information")
    RETURN
  END IF
  CALL descarga_documento("7",mfc_factura_m.prefijo, mfc_factura_m.numfac)
END FUNCTION

FUNCTION consulta_estados_nota()
 DEFINE mtiponota       CHAR(2)     
 DEFINE mnumnota        LIKE   fc_nota_m.numnota
  LET mtiponota = NULL 
  LET mnumnota = 0
  PROMPT "Tipo de Nota [NC/ND] : "    FOR mtiponota
  LET mtiponota = upshift(mtiponota) 
  IF mtiponota IS NULL THEN 
    RETURN
  END IF
  PROMPT "Numero Nota  :  "   FOR mnumnota
  IF mnumnota IS NULL OR mnumnota = 0 THEN
    RETURN
   END IF
  INITIALIZE mfc_nota_m.* TO NULL
  SELECT * INTO mfc_nota_m.*
    FROM fc_nota_m
  WHERE tipo = mtiponota
   AND numnota = mnumnota
  IF mfc_nota_m.numnota IS NULL THEN
    CALL FGL_WINMESSAGE( "Mensaje de error ", "El numero de la Nota no fue encontrada","stop")
    RETURN
  END IF
  IF mfc_nota_m.estado = "B" THEN
    CALL FGL_WINMESSAGE( "Información", "La Nota no ha sido transmitida","information")
    RETURN
  END IF
  IF mtiponota ="NC" THEN
    CALL consulta_estado_documento("2",mtiponota, mfc_nota_m.numnota)
  ELSE
    CALL consulta_estado_documento("3",mtiponota, mfc_nota_m.numnota)
  END IF  
END FUNCTION

FUNCTION generar_pdf_nota()
DEFINE mtiponota       CHAR(2)     
 DEFINE mnumnota        LIKE   fc_nota_m.numnota
  LET mtiponota = NULL 
  LET mnumnota = 0
  PROMPT "Tipo de Nota [NC/ND] : "    FOR mtiponota
  LET mtiponota = upshift(mtiponota) 
  IF mtiponota IS NULL THEN 
    RETURN
  END IF
  PROMPT "Numero Nota  :  "   FOR mnumnota
  IF mnumnota IS NULL OR mnumnota = 0 THEN
    RETURN
   END IF
  INITIALIZE mfc_nota_m.* TO NULL
  SELECT * INTO mfc_nota_m.*
    FROM fc_nota_m
  WHERE tipo = mtiponota
   AND numnota = mnumnota
  IF mfc_nota_m.numnota IS NULL THEN
    CALL FGL_WINMESSAGE( "Mensaje de error ", "El numero de la Nota no fue encontrada","stop")
    RETURN
  END IF
  IF mfc_nota_m.estado = "B" THEN
    CALL FGL_WINMESSAGE( "Información", "La Nota no ha sido transmitida","information")
    RETURN
  END IF
  IF mtiponota ="NC" THEN
    CALL descarga_documento("2",mtiponota, mfc_nota_m.numnota)
  ELSE
    CALL descarga_documento("3",mtiponota, mfc_nota_m.numnota)
  END IF
END FUNCTION

FUNCTION envio_documento_nota(tipodoc, prefijo, numfactu)
  DEFINE tipodoc, mtipdoc   LIKE    fc_nota_m.tipodocumento
  DEFINE prefijo            LIKE    fc_nota_m.tipo
  DEFINE numfactu           LIKE    fc_nota_m.numnota
  DEFINE mdocumento         CHAR(7) 
  LET lineaNota1= ""
  LET lineaNota2= ""
  LET lineaNota3= ""
  LET lineaNota4= ""
  LET NombreAprobo=""
  LET NombreElaboro=""  
  LET ls_salida = ""
  LET tiponota = "0"
  INITIALIZE mfc_nota_m.* TO NULL
  SELECT * INTO mfc_nota_m.*
    FROM fc_nota_m
     WHERE fc_nota_m.tipo = prefijo
     AND fc_nota_m.numnota = numfactu
  LET mdocumento = mfc_nota_m.documento 
    LET ls_salida = ls_salida,"\n--------------------------Proceso Metodo Enviar Nota (Debito/Credito)---------------------------------"
    LET ls_salida = ls_salida,"\n+++++++++++++++++++++Inicia obtencion de datos+++++++++++++++++++++"
    CALL ui.Interface.refresh()
    LET ls_salida = ls_salida, "\nResultado del Encabezado Nota -  Documento Interno: ", mfc_factura_m.documento
  LET lineaNota1 = mfc_nota_m.nota1[1,70]
  LET lineaNota2 = mfc_nota_m.nota1[71,140]
  LET lineaNota3 = mfc_nota_m.nota1[141,210]
  LET lineaNota4 = mfc_nota_m.nota1[211,280]
  SELECT nombre INTO NombreAprobo 
    FROM gener02
   WHERE gener02.usuario = mfc_nota_m.usuario_apru
  SELECT nombre INTO NombreElaboro 
    FROM gener02
   WHERE gener02.usuario = mfc_nota_m.usuario_add
  LET cantidadLineas = 0  
  INITIALIZE mfc_factura_m.* TO NULL
  SELECT * INTO mfc_factura_m.*
   FROM fc_factura_m
  WHERE fc_factura_m.prefijo = mfc_nota_m.prefijo 
    AND fc_factura_m.numfac = mfc_nota_m.numfac 
  SELECT COUNT(*) INTO cantidadLineas
    FROM fc_nota_d
     WHERE trim(fc_nota_d.tipo) = prefijo
     AND fc_nota_d.documento = mdocumento
   CASE   
     WHEN mfc_nota_m.tipo = "NC"
       IF mfc_factura_m.cufe IS NOT NULL THEN 
         LET mfc_nota_m.tipoope = "20"
       ELSE
         LET mfc_nota_m.tipoope = "22"
       END IF   
    WHEN mfc_nota_m.tipo = "NC"
      IF mfc_factura_m.cufe IS NOT NULL THEN 
        LET mfc_nota_m.tipoope = "30"
      ELSE
        LET mfc_nota_m.tipoope = "32"
      END IF  
   END CASE   
    LET ls_salida = ls_salida, "\nNumero de items en nota : ", cantidadLineas
  INITIALIZE mfc_terceros.* TO NULL
  SELECT * INTO mfc_terceros.*
    FROM fc_terceros
     WHERE fc_terceros.nit = mfc_factura_m.nit
  INITIALIZE mfc_terobligacion.* TO NULL
  LET tipoobligacion=""
  DECLARE cur_ob_adq CURSOR FOR
  SELECT * 
   FROM fc_terobligacion
   WHERE fc_terobligacion.nit =  mfc_terceros.nit
   FOREACH cur_ob_adq INTO  mfc_terobligacion.*
     LET tipoobligacion = mfc_terobligacion.codigo_oblig
     EXIT FOREACH
   END FOREACH
   IF tipoobligacion IS NULL OR tipoobligacion ="" THEN
     LET tipoobligacion ="R-99-PN"
   ELSE
     DECLARE cur_ob_adq2 CURSOR FOR
     SELECT * FROM fc_terobligacion
     WHERE fc_terobligacion.nit =  mfc_terceros.nit
     FOREACH cur_ob_adq2 INTO  mfc_terobligacion.*
       LET tipoobligacion = tipoobligacion CLIPPED, ";" , mfc_terobligacion.codigo_oblig
     END FOREACH
   END if    
  INITIALIZE mfe_ciudades.* TO NULL
  SELECT * INTO mfe_ciudades.* 
   FROM fe_ciudades
    WHERE fe_ciudades.codciu = mfc_terceros.zona  
  LET departamento = mfc_terceros.zona[1,2]
  INITIALIZE mfe_deptos.* TO NULL 
  SELECT * INTO mfe_deptos.*
   FROM fe_deptos
    WHERE fe_deptos.coddep = departamento
  INITIALIZE mfe_paises.* TO NULL 
  SELECT * INTO mfe_paises.*
   FROM fe_paises
    WHERE fe_paises.codpais = mfc_terceros.pais
  INITIALIZE nombreCompleto TO NULL 
  IF mfc_terceros.tipo_persona = "1" THEN 
    LET nombreCompleto = mfc_terceros.razsoc 
  ELSE 
   LET nombreCompleto =  mfc_terceros.primer_nombre CLIPPED, ' ', mfc_terceros.segundo_nombre CLIPPED,
    ' ', mfc_terceros.primer_apellido CLIPPED,' ', mfc_terceros.segundo_apellido CLIPPED
  END IF
  LET ls_salida = ls_salida, "\nAdquiriente : ", mfc_terceros.nit CLIPPED , " " , nombreCompleto
  INITIALIZE mfe_regimen.* TO NULL
  SELECT * INTO mfe_regimen.*
   FROM fe_regimen
    WHERE regimen = mfc_terceros.regimen
  LET aplicafel ="NO"
  INITIALIZE envioPorEmailPlataforma TO NULL 
  IF mfc_terceros.email IS NOT NULL THEN
    LET envioPorEmailPlataforma = "EMAIL"
    LET aplicafel ="SI"
  END IF 
  LET nitProveedorTecnologico = "" 
  {IF mfc_terceros.medio_recep = "3" AND mfc_terceros.nit_facturador IS NOT NULL THEN
    LET envioPorEmailPlataforma = "PLATAFORMA"
    LET nitProveedorTecnologico = mfc_terceros.nit_facturador
  END IF  }
  LET mhoy = CURRENT YEAR TO MINUTE  
  LET codigoPlantillaPdf = 0
  LET ciudadFacturador =""
  LET telefonoFacturador= ""
  LET DesTipoNota =""
  LET lineaResDian1= ""
  LET lineaResDian2= ""
CASE mfc_nota_m.tipo_nota
  WHEN 1
   LET DesTipoNota = "NC-DEVOLUCION DE PARTE DE LOS BIENES"
  WHEN 2
   LET DesTipoNota = "NC-ANULACION DE LA FACTURA"
  WHEN 3
   LET DesTipoNota = "NC-REBAJA TOTAL APLICADA"
  WHEN 4
   LET DesTipoNota = "NC-DESCUENTO TOTAL APLICADO"
  WHEN 5
   LET DesTipoNota = "NC-NULIDAD POR FALTA DE REQUISITOS"
  WHEN 6
   LET DesTipoNota = "NC-OTROS CONCEPTOS"
  WHEN 7
   LET DesTipoNota = "ND-INTERESES GENERADOS"
  WHEN 8
   LET DesTipoNota = "ND-GASTOS POR COBRAR"
  WHEN 9
   LET DesTipoNota = "ND-CAMBIO DEL VALOR"
  WHEN 10
   LET DesTipoNota = "ND-OTROS CONCEPTOS"
  END CASE  
   INITIALIZE mfc_prefijos.*  TO NULL
   SELECT * INTO mfc_prefijos.*
    FROM fc_prefijos
     WHERE fc_prefijos.prefijo = mfc_nota_m.prefijo
   SELECT detzon INTO ciudadFacturador 
     FROM gener09
     WHERE gener09.codzon = mfc_prefijos.zona
    LET telefonoFacturador = " TELEFONO:  ", mfc_prefijos.telefono
    --LET lineaResDian1 = " Autorización numeración: ", mfc_prefijos.num_auto CLIPPED, 
    --  " de ", mfc_prefijos.fec_auto USING "dd/mm/yyyy"
    --LET lineaResDian2= "Rango autorizado ", mfc_prefijos.prefijo CLIPPED , " del ",
    --mfc_prefijos.numini USING "&&&&&&&", " - ", mfc_prefijos.numfin USING "&&&&&&&", " ", 
    --" vence el ", mfc_prefijos.fec_ven USING "dd/mm/yyyy"  
   -- LLAMADO CABEZA DE DOCUMENTO
   CALL Enlace_Doc_bbl.f_CabezaDocumento_Agrega(
     aplicafel,
     cantidadLineas,
     "",                    -- centroCostos,
     codigoPlantillaPdf,
     "",                    --  codigovendedor
     mfc_nota_m.numnota,  
     contrasena,
     "",                    --  descripcionCentroCostos
     mhoy,                  -- mfc_factura_m.fecha_factura,  --  en el envio la fecha de la factura es el dia 
     idEmpresa,
     idErp,
     "DAP",                 -- incoterm
     "",                    --  nombrevendedor
     mfc_nota_m.tipo,       -- prefijo   (para pruebas es NC o ND)
     "",                    --  Sucursal
     mfc_nota_m.tipoope,
     tipodoc,
     mfc_nota_m.tipo_nota,
     token,usuario,version,
     nombreImpresora,
     campoAdicional1,
     campoAdicional2,
     campoAdicional3,
     campoAdicional4,
     campoAdicional5)
   -- LLAMADO DATOS DEL ADQUIRIENTE
   CALL Enlace_Doc_bbl.f_Adquirente_Agrega(
       "",        --barioLocalidad 1
       mfc_terceros.zona CLIPPED, --2
       "",        --codigoCIUU (Actividad economica) --3
       "", --codigo ciudad
       "",        --codigoPostal --4
       departamento, --5
       mfe_ciudades.nombreciu CLIPPED, --6   
       mfc_terceros.digver, --7
       mfc_terceros.direccion CLIPPED, --8
       mfc_terceros.email CLIPPED, --9
       envioPorEmailPlataforma, --10
       "",        --matriculaMercantil, --11
       nitProveedorTecnologico, --12
       nombreCompleto CLIPPED, --13
       mfe_deptos.nombredep CLIPPED, --14
       mfc_terceros.nit CLIPPED,  --15
       mfc_terceros.pais CLIPPED, --16
       mfe_paises.nombrepais CLIPPED, --17
       "", --18
       mfe_regimen.codreg, --19
       mfc_terceros.telefono CLIPPED, --20
       mfc_terceros.tipid, --21
       mfc_terceros.tipo_persona, --22
       tipoobligacion  CLIPPED --23
       
       )
 -- CUFE SE ESTABA CAPTURANDO TRUNCADO (29/01/2020) 
   LET cufe = null
   INITIALIZE mfc_estados_fac.* TO NULL
   SELECT * INTO mfc_estados_fac.*
     FROM fc_estados_fac
      WHERE fc_estados_fac.prefijo = mfc_nota_m.prefijo
      AND fc_estados_fac.numfac = mfc_nota_m.numfac
    IF mfc_estados_fac.cufe IS NOT NULL THEN
      LET cufe = mfc_estados_fac.cufe
    END IF   
    IF mfc_nota_m.tipoope = "20" OR  mfc_nota_m.tipoope = "30" THEN   
      CALL Enlace_Doc_bbl.f_FacturaModificada_Agrega( 
        mfc_nota_m.numfac,                  --consecutivoFacturaModificada,
        cufe CLIPPED,                      --cufeFacturaModificada,
        mfc_factura_m.fecha_factura,        --fechaFacturaModificada,
        "",                                 --observacion,
        mfc_nota_m.prefijo CLIPPED,                 -- prefijoFacturaModificada,
        1                                  -- tipoDocumentoFacturaModificada
        )
    END IF    
    { CALL Enlace_Doc_bbl.f_FacturaModificada_Agrega( 
        "14018",                  --consecutivoFacturaModificada,
        "f3b28cdbd29f7bc9e0ea04a329d035b7379939f7108b18c31ee",       --cufeFacturaModificada,
        "08/21/2020",        --fechaFacturaModificada,
        "factura de prueba",                                 --observacion,
        "SETT",                 -- prefijoFacturaModificada,
        1                                  -- tipoDocumentoFacturaModificada
        ) }  
 -- LLAMADO DETALLE DEL DOCUMENTO
   LET campoAdicional1 = "" 
   LET campoAdicional2 = ""
   LET campoAdicional3 = ""
   LET campoAdicional4 = ""
   LET campoAdicional5 = ""
   LET subtotalfac = 0
   LET valorEnLetrasSubTotal = 0
   LET valorAdicional1 =""
   LET valorAdicional2 =""
   LET valorAdicional3 =""
   LET valorAdicional4= ""
   LET valorAdicional5=""
   LET posicion = 0
   LET TotalIva = 0
   LET TotalBen = 0
   LET TotalSub = 0
   LET TotalImpc = 0
   LET descuento = 0
   LET Subtotal = 0
   DECLARE Cur_DetNota CURSOR FOR
    SELECT * FROM fc_nota_d
     WHERE trim(fc_nota_d.tipo) = mfc_nota_m.tipo
     AND fc_nota_d.documento = mfc_nota_m.documento  
    ORDER BY fc_nota_d.codigo
    FOREACH Cur_DetNota INTO mfc_nota_d.*
      LET posicion = posicion + 1
      LET TotalSub = TotalSub + (mfc_nota_d.subsi * mfc_nota_d.cantidad)
      LET TotalBen = TotalBen+ (mfc_nota_d.valorbene * mfc_nota_d.cantidad)
      LET descuento = (mfc_nota_d.subsi + mfc_nota_d.valorbene) * mfc_nota_d.cantidad
      LET Subtotal = Subtotal + (mfc_nota_d.valoruni * mfc_nota_d.cantidad)
      INITIALIZE rec_mfc_servicios.* TO NULL
      SELECT * INTO rec_mfc_servicios.* 
        FROM fc_servicios
         WHERE fc_servicios.codigo = mfc_nota_d.codigo
      LET nombreProducto = rec_mfc_servicios.descripcion CLIPPED 
      IF mfc_nota_d.subcodigo IS NOT NULL AND mfc_nota_d.subcodigo <> "0" THEN
        INITIALIZE mfc_sub_servicios.* TO NULL
        SELECT * INTO mfc_sub_servicios.* 
        FROM fc_sub_servicios
         WHERE fc_sub_servicios.codigo = mfc_nota_d.subcodigo
        LET nombreProducto = nombreProducto CLIPPED, ' ', mfc_sub_servicios.descripcion CLIPPED
      END IF
      LET muestracomercial= 0
      IF mfc_nota_d.total_pagar = 0 THEN
        LET muestracomercial = "2"     -- SE INDICA QUE ES REGALO CUANDO ES TOTALMENTE SUBSIDIADO
      END IF
      LET descuentoUni = (mfc_nota_d.subsi + mfc_nota_d.valorbene) --Descuento unitario rep. grafica
      CALL Enlace_Doc_bbl.f_DetalleDocumento_Agrega(
        "no",           --aplicaMandato,
        0,             -- CampoAdicional1
        0,             --campoAdicional2,
        0,             --campoAdicional3,
        0,             --campoAdicional4,
        0,            --campoAdicional5,
        mfc_nota_d.cantidad,
        mfc_nota_d.codigo,
        "",             --descripcion,
        "",             --familia,
        "",             --fechaSuscripcionContrato,
        "",             --gramaje,
        mfc_nota_d.codcat,
        "",             --marca,
        "",             --modelo,
        muestracomercial,
        0,             --muestracomercialcodigo,
        nombreProducto,
        posicion,
        mfc_nota_d.base_imponible,
        mfc_nota_d.total_pagar,
        "",             --referencia,
        "",             --seriales,
        0,             --tamanio,
        "",
        "999",            --tipocodigoproducto,
        rec_mfc_servicios.coduni CLIPPED,
        mfc_nota_d.valoruni,
        0    -- valorunitarioporcantidad
        )
      CALL Enlace_Doc_bbl.f_CampoAdicional_Detalle_Agrega(
        null --fecha
       ,"DescuentoUni" --nombreCampo
       ,0 --orden
       ,0 --seccion
       ,descuentoUni
       ,""  -- NombreSector
        )     
      -- LLAMADO A AGREGAR LISTA DE IMPUESTOS
      LET isAutoRetenido = 0
     
      -- LLAMADO A AGREGAR LISTA DE DESCUENTOS  ( EN NUESTRO CASOS SUBSIDIOS
      IF descuento>0 THEN
         LET porcentajeDescuento= 100*descuento/(mfc_nota_d.valoruni*mfc_nota_d.cantidad)  -- exigido DIAN
         CALL Enlace_Doc_bbl.f_Descuento_Detalle_Agrega(
         "11",                                  --codigoDescuento,
         "SUBSIDIO EN TARIFA Y/O ESPECIE",       --descuento_descripcion,
         descuento,
         porcentajeDescuento)
      END IF 
   END FOREACH  
    -- LLAMADO A IMPUESTOS GLOBALES
    INITIALIZE mfc_factura_imp.* TO NULL
    DECLARE cur_impglo_not CURSOR FOR  
    SELECT * FROM fc_nota_imp
     WHERE trim(fc_nota_imp.prefijo) = mfc_nota_m.tipo
     AND fc_nota_imp.documento = mfc_nota_m.documento  
    FOREACH cur_impglo_not INTO mfc_nota_imp.*
       CALL Enlace_Doc_bbl.f_Impuesto_Agrega(
          mfc_nota_imp.base,
          mfc_nota_imp.codimp,
          mfc_nota_imp.autoret,
          mfc_nota_imp.porcentaje,
          mfc_nota_imp.valor
          )
       CASE 
        WHEN mfc_nota_imp.codimp = "01"  
          LET TotalIva =  TotalIva +  mfc_nota_imp.valor
        WHEN mfc_nota_imp.codimp = "02"  
          LET TotalImpc = TotalImpc + mfc_nota_imp.valor
       END CASE  
    END FOREACH
  -- LLAMADO A TOTALES DE NOTA (PAGOS)
  LET fechaVencimiento = NULL
  LET periododepago = 0
  INITIALIZE mfc_nota_tot.* TO NULL
    SELECT * INTO mfc_nota_tot.* 
     FROM fe_nota_tot
     WHERE trim(fe_nota_tot.prefijo) = mfc_nota_m.tipo
     AND fe_nota_tot.documento = mfc_nota_m.documento  
    CALL Enlace_Doc_bbl.f_Pagos_Agrega(
      mfc_empresa.moneda,       --codigoMonedaCambio
      NULL,         --  mfc_factura_tot.fecha_trm,
      fechaVencimiento,  
      mfc_nota_tot.moneda, 
      mfc_nota_tot.total_anticipos,
      periododepago,
      "1",       ---mfc_factura_m.forma_pago,  1-> CONTADO
      mfc_nota_tot.total_cargos,
      0, -- mfc_factura_tot.total_descuentos,
      mfc_nota_tot.baseconimpu,
      mfc_nota_tot.baseimponible,
      mfc_nota_tot.totalnota,
      mfc_nota_tot.importebruto,
      mfc_nota_tot.trm, 
      NULL,     --trm_altern
      subtotalfac,
      valorEnLetrasSubTotal,
      valorAdicional1,
      valorAdicional2,
      valorAdicional3,
      valorAdicional4,
      valorAdicional5,
      "",       --valorEnLetras1
      "",       --valorEnLetras2
      "",       --valorEnLetras3
      "",       --valorEnLetras4
      "",       --valorEnLetras5
      redondeoTotalFactura
      )    
      CALL Enlace_Doc_bbl.f_MedioPago_Agrega("1")
   -- LLAMADOS PARA AGREGAR CAMPOS ADICIONALES EN EL DISEÑO DE LA NOTA.
     LET mvalche = mfc_nota_tot.totalnota
     CALL letras()
     LET lineaMonto1 = mletras1[1,69]
     LET lineaMonto2 = mletras2[1,70]
    IF mfc_nota_m.tipoope = "20" OR  mfc_nota_m.tipoope = "30" THEN
      CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"FechaFacturaModif",1,1,mfc_factura_m.fecha_factura,"")
      CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"CufeFacModif",1,1,mfc_factura_m.cufe,"")
    END IF 
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"DescripcionTipoNota",1,1,DesTipoNota CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Regimen",1,1,mfc_empresa.regimen CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"DirFacturador",1,1,mfc_prefijos.direccion CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"CiudadFacturador",1,1,ciudadFacturador CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"TelefonoFacturador",1,1,telefonoFacturador CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"LeyendaEncab1",1,1,mfc_empresa.leyenda_enc CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"nota1",1,1,lineaNota1 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"nota2",1,1,lineaNota2 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"nota3",1,1,lineaNota3 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"nota4",1,1,lineaNota4 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"ValorLetras1",1,1,lineaMonto1 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"ValorLetras2",1,1,lineaMonto2 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"ValorLetras3",1,1,lineaMonto3 CLIPPED,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta1",1,1,"Subtotal                  :","")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta2",1,1,"Subsidio                   :","")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta3",1,1,"Otros Beneficios     :","")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta4",1,1,"Anticipos                   :","")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta5",1,1,"Total IVA                   :" ,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta6",1,1,"Total Imp/Consumo  :","")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Etiqueta7",1,1,"Total a pagar            :","")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Subtotal",1,1,Subtotal,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Totalsub",1,1,TotalSub,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Totalben",1,1,TotalBen,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"Totaliva",1,1,TotalIva,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"TotalImpoc",1,1,TotalImpc,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"PiePagina2",1,1,mfc_empresa.piepag_2,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"PiePagina3",1,1,mfc_empresa.piepag_3,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"NombreElaboro",1,1,NombreElaboro,"")
     CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(NULL,"NombreAprobo",1,1,NombreAprobo,"")
END FUNCTION

FUNCTION consulta_estado_documento_2(tipodoc, prefijo, numfac)
  DEFINE tipodoc, tipodocumento CHAR(1)
  DEFINE prefijo, prefijo_factu CHAR(4)
  DEFINE numfac,numfactura  INTEGER
  DEFINE mfecha_eje DATE
  DEFINE mhora_eje  CHAR(10)
  EXECUTE IMMEDIATE "set encryption password ""Confaoriente2020"""
   select fc_dispapeles_acceso.idEmpresa
       ,""
       ,fc_dispapeles_acceso.usuario
       ,decrypt_char(fc_dispapeles_acceso.contrasena) as contrasena
       ,decrypt_char(fc_dispapeles_acceso.token) as token
       ,fc_dispapeles_acceso.version
   INTO idEmpresa,idErp,usuario,contrasena,token,version
   from fc_dispapeles_acceso
  LET tipodocumento = tipodoc
  LET prefijo_factu = prefijo
  LET numfactura= numfac
  LET ls_salida ="" 
   DISPLAY "\n----------------------------Consultar Estado Documento -----------------------------------------"
   CALL Enlace_DocEstado_bbl.f_ConsultarEstado_Agrega(
                  numfactura      --consecutivo
                , contrasena      --contrasena
                , idEmpresa       --idEmpresa
                , prefijo_factu CLIPPED   --prefijo
                , tipodocumento   --tipoDocumento
                , token           --token
                , usuario         --usuario
                , version         --version
            )
  --Recupera el resultado de la consulta del Estado de la factura
    CALL Enlace_DocEstado_bbl.f_RespuestaConsultarEstado_Recupera()
      RETURNING  codigoQr 
                , codigoUltimoEstadoAdquirente 
                , codigoUltimoEstadoDian 
                , codigoUltimoEstadoDispapeles 
                , codigoUltimoEstadoEmail 
                , numfactura 
                , cufe 
                , descripcionUltimoEstadoAdquirente 
                , descripcionUltimoEstadoDian 
                , descripcionUltimoEstadoDispapeles 
                , descripcionUltimoEstadoEmail 
                , estadoProceso 
                , fechaFactura 
                , fechaRespuesta 
                , fechaRespuestaUltimoEstadoAdquirente 
                , fechaRespuestaUltimoEstadoDian 
                , fechaRespuestaUltimoEstadoDispapeles 
                , fechaRespuestaUltimoEstadoEmail 
                , firmaDelDocumento 
                , idErp 
                , idLote 
                , prefijo_factu 
                , selloDeValidacion 
                , tipodocumento
    DISPLAY "\nMensaje de error: ",sqlca.sqlerrm
    DISPLAY "\ncodigoQR      = ",codigoQr
    DISPLAY "\nDescripcion_Ultimo_Estado_Dian       = ",descripcionUltimoEstadoDian
    DISPLAY "\ndescripcion_Ultimo_Estado_Adquirente = ",descripcionUltimoEstadoAdquirente
    LET mfecha_eje = TODAY
    IF fechaRespuesta IS NOT NULL AND numfactura IS NOT NULL THEN
      LET cnt = 0 
      SELECT COUNT(*) INTO cnt 
       FROM fc_estados_fac
       WHERE fc_estados_fac.prefijo = prefijo
       AND fc_estados_fac.numfac = numfac
       AND fc_estados_fac.tpdocumento = tipodoc
      IF cnt IS NULL THEN LET cnt= 0 END IF
      IF cnt = 0 THEN 
        INSERT INTO fc_estados_fac
       (tpdocumento, prefijo, numfac, fecfactura, cufe, codult_estdisp, des_ult_estdisp,
        fecres_ultestdisp, cod_ult_estdian, des_ult_estdian, fecres_ultestdian, cod_ult_estmail,
        des_ult_estmail, fecres_ultestmail, cod_ult_estadq, des_ult_estadq, fecres_ultestadq, 
        codest,fecest, fecrep)
        VALUES (tipodoc, prefijo, numfac, fechaFactura, cufe, codigoUltimoEstadoDispapeles,
         descripcionUltimoEstadoDispapeles, fechaRespuestaUltimoEstadoDispapeles, 
         codigoUltimoEstadoDian, descripcionUltimoEstadoDian, fechaRespuestaUltimoEstadoDian, 
         codigoUltimoEstadoEmail, descripcionUltimoEstadoEmail,fechaRespuestaUltimoEstadoEmail,                     
         codigoUltimoEstadoAdquirente, descripcionUltimoEstadoAdquirente, fechaRespuestaUltimoEstadoAdquirente,  
         estadoProceso, fechaRespuesta, fechaFactura)
      ELSE    
        UPDATE fc_estados_fac
        SET ( cufe, codult_estdisp, des_ult_estdisp, fecres_ultestdisp, cod_ult_estdian, des_ult_estdian, fecres_ultestdian, 
        cod_ult_estmail, des_ult_estmail, fecres_ultestmail, cod_ult_estadq, des_ult_estadq, fecres_ultestadq, 
         codest, fecest, fecrep  )
         = ( cufe, codigoUltimoEstadoDispapeles,
          descripcionUltimoEstadoDispapeles, fechaRespuestaUltimoEstadoDispapeles, 
          codigoUltimoEstadoDian, descripcionUltimoEstadoDian, fechaRespuestaUltimoEstadoDian, 
          codigoUltimoEstadoEmail, descripcionUltimoEstadoEmail,fechaRespuestaUltimoEstadoEmail,                     
          codigoUltimoEstadoAdquirente, descripcionUltimoEstadoAdquirente, fechaRespuestaUltimoEstadoAdquirente,  
          estadoProceso, fechaRespuesta, fechaFactura)
         WHERE fc_estados_fac.tpdocumento = tipodoc
          AND  fc_estados_fac.prefijo = prefijo
          AND  fc_estados_fac.numfac = numfac
       END if  
      -- Se consultan todos los mensajes asociados a la respuesta al consumo del método "consultarEstado"
      FOR indice = 1 TO Enlace_DocEstado_bbl.f_RespuestaTamanoConsultarEstado_listaMensajes_Recupera()
        LET mhora_eje = TIME 
         CALL f_RespuestaMensajesProceso_Recupera(indice)
          RETURNING  codigoMensaje
          , descripcionMensaje
          , rechazoNotificacion
           DISPLAY "\nMensaje = ",descripcionMensaje
        END FOR
      IF estadoProceso= "1" AND codigoUltimoEstadoAdquirente <> "3" 
       AND cufe IS NOT null THEN   -- EXITOSO
         CASE 
          WHEN tipodoc = "7"   
           UPDATE fc_factura_m
           SET  estado ="P", fecest = fechaRespuesta,  codest = estadoProceso    
           WHERE fc_factura_m.prefijo = prefijo
           AND fc_factura_m.numfac = numfac
           AND fc_factura_m.estado NOT IN ("X", "R", "N", "D")  -- NO SE PUEDE ALTERAR 
          WHEN tipodoc = "2" OR tipodoc ="3"   
           UPDATE fc_nota_m
            SET estado ="P", fecest = fechaRespuesta, codest = estadoProceso    
            WHERE fc_nota_m.tipo = prefijo
           AND fc_nota_m.numnota = numfac
           AND fc_nota_m.estado NOT IN ("X", "R", "D")  -- NO SE PUEDE ALTERAR 
        END CASE
      END IF
      IF codigoUltimoEstadoAdquirente = "3"  THEN     -- RECHAZADA CLIENTE
         CASE 
          WHEN tipodoc = "7"   
           UPDATE fc_factura_m
           SET  estado ="R", fecest = DATE(fechaRespuestaUltimoEstadoAdquirente) , codest = codigoUltimoEstadoAdquirente    
           WHERE fc_factura_m.prefijo = prefijo
           AND fc_factura_m.numfac = numfac
          WHEN tipodoc = "2" OR tipodoc ="3"   
           UPDATE fc_nota_m
            SET estado ="R", fecest = DATE(fechaRespuestaUltimoEstadoAdquirente) ,  codest = codigoUltimoEstadoAdquirente  
            WHERE fc_nota_m.tipo = prefijo
           AND fc_nota_m.numnota = numfac
        END CASE
      END IF
     IF codigoUltimoEstadoDispapeles = "19" THEN      -- RECHAZADA X DISPAPELES
        CASE 
          WHEN tipodoc = "7"   
           UPDATE fc_factura_m
           SET  estado ="X", fecest = DATE(fechaRespuestaUltimoEstadoDispapeles) ,  codest = codigoUltimoEstadoDispapeles    
           WHERE fc_factura_m.prefijo = prefijo
           AND fc_factura_m.numfac = numfac
          WHEN tipodoc = "2" OR tipodoc ="3"   
           UPDATE fc_nota_m
            SET estado ="X", fecest = DATE(fechaRespuestaUltimoEstadoDispapeles), codest = codigoUltimoEstadoDispapeles
            WHERE fc_nota_m.tipo = prefijo
           AND fc_nota_m.numnota = numfac
         END CASE
      END IF  
      IF  codigoUltimoEstadoDian = "4" THEN      -- RECHAZADA X LA DIAN
        CASE 
          WHEN tipodoc = "7"   
           UPDATE fc_factura_m
           SET  estado ="D", fecest = DATE(fechaRespuestaUltimoEstadoDian),  codest = codigoUltimoEstadoDian    
           WHERE fc_factura_m.prefijo = prefijo
           AND fc_factura_m.numfac = numfac
          WHEN tipodoc = "2" OR tipodoc ="3"   
           UPDATE fc_nota_m
            SET estado ="D", fecest = DATE(fechaRespuestaUltimoEstadoDian) , codest =  codigoUltimoEstadoDian
            WHERE fc_nota_m.tipo = prefijo
           AND fc_nota_m.numnota = numfac
         END CASE
      END IF  
    END IF  
 END FUNCTION

FUNCTION envio_documento_2(tipodoc, prefijo,numfactu)
  DEFINE tipodoc, mtipdoc   LIKE    fc_factura_m.tipodocumento
  DEFINE prefijo            LIKE    fc_factura_m.prefijo
  DEFINE numfactu           LIKE    fc_factura_m.numfac      
   EXECUTE IMMEDIATE "set encryption password ""Confaoriente2020"""
   select fc_dispapeles_acceso.idEmpresa 
       ,""                          -- iderp
       ,fc_dispapeles_acceso.usuario
       ,decrypt_char(fc_dispapeles_acceso.contrasena) as contrasena
       ,decrypt_char(fc_dispapeles_acceso.token) as token
       ,fc_dispapeles_acceso.version
   INTO idEmpresa,idErp,usuario,contrasena,token,version
   from fc_dispapeles_acceso
   CASE
    WHEN tipodoc = "7"
      CALL envio_documento_fact(tipodoc, prefijo, numfactu)
    WHEN tipodoc = "2" OR tipodoc ="3"
      CALL envio_documento_nota(tipodoc, prefijo, numfactu)
   END CASE
   CALL Enlace_Doc_bbl.f_RespuestaEnvio_Recupera()
     RETURNING codigoQr,consecutivo_r,cufe,descripcionProceso,estadoProceso,
      fechaExpedicion,fechaFactura,fechaRespuesta,firmaDelDocumento,idErp_r,prefijo_r,
      selloDeValidacion,tipoDocumento_r
    IF cufe IS NOT NULL THEN
      LET cnt =0
      SELECT COUNT(*) INTO cnt
        FROM fc_respenvio
        WHERE tpdocumento = tipodoc
        AND prefijo = prefijo
        AND numfac = numfactu
       IF cnt IS NULL THEN LET cnt = 0 END IF
     IF cnt = 0 THEN  
       INSERT INTO fc_respenvio
       (tpdocumento,prefijo,numfac, cufe, fecfactura, fecresp, fecexped, codest)
       VALUES 
        (tipoDocumento_r, prefijo_r, consecutivo_r,cufe, fechaFactura,fechaRespuesta,
        fechaExpedicion,estadoProceso)
      END IF 
    END if 
      FOR contadorMensajes = 1 TO Enlace_Doc_bbl.f_MensajesProceso_Conteo()
           CALL Enlace_Doc_bbl.f_MensajesProceso_Recupera(contadorMensajes)
            RETURNING codigoMensaje,descripcionMensaje,rechazoNotificacion
      END FOR
   --ACTUALIZAR LA FACTURA O NOTA DE ACUERDO A LOS DATOS DE LA RESPUESTA.
   IF tipodoc = "7" OR tipodoc = "4" THEN
   LET mtime=TIME
    CASE 
     WHEN estadoProceso= "1" AND cufe IS NOT NULL 
       UPDATE fc_factura_m
        SET cufe = cufe, fecha_factura = fechaFactura, estado ="S", fecest = fechaRespuesta,
         codest = estadoProceso, hora = mtime    
        WHERE fc_factura_m.prefijo = prefijo
       AND fc_factura_m.numfac = numfactu
      WHEN estadoProceso= "24"  
       UPDATE fc_factura_m
        SET fecha_factura = fechaFactura, estado ="G", fecest = fechaRespuesta,
         codest = estadoProceso, hora = mtime     
        WHERE fc_factura_m.prefijo = prefijo
       AND fc_factura_m.numfac = numfactu
    END CASE
  ELSE
    if estadoProceso= "1" AND cufe IS NOT NULL THEN 
       UPDATE fc_nota_m
        SET cude = cufe, fecha_nota = fechaFactura, estado ="S", fecest = fechaRespuesta,
         codest = estadoProceso, hora = mtime     
        WHERE fc_nota_m.tipo = prefijo
       AND fc_nota_m.numnota = numfactu
    END IF    
  END if 
END FUNCTION

   