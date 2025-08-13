#+ Consulta de archivos.
#+
#+ Enlace con servicio web de Dispapeles para
#+ la consulta de documentos de facturas electrónicas.

IMPORT FGL DispapelesArchivo
IMPORT security

GLOBALS "consultarArchivos.inc"
GLOBALS
DEFINE indice_errores INTEGER
END GLOBALS

#+ Genera el filtro para consultar la factura a eliminar.
#+
#+ Genera la información que será utilizada para filtrar la factura a eliminar.
#+
#+ @code
#+ CALL f_borrarRegistrosIA_Agrega(
#+         123--consecutivo
#+    ,"Texto"--contrasenia
#+    ,    123--idEmpresa
#+    ,"Texto"--prefijo
#+    ,    123--tipoArchivo
#+    ,"Texto"--tipoDocumento
#+    ,"Texto"--token
#+    ,"Texto"--usuario
#+    ,"Texto"--version
#+ )
#+
#+ @param consecutivo  NÚMERO DE CONSECUTIVO DE LA FACTURA.
#+ @param contrasenia  CONTRASEÑA. CAMPOS PARA VALIDAR LA SEGURIDAD. ESTOS VALORES SON ENTREGADOS POR DISPAPELES A CADA EMPRESA FACTURADORA.
#+ @param idEmpresa ID. DE EMPRESA. CAMPOS PARA VALIDAR LA SEGURIDAD. ESTOS VALORES SON ENTREGADOS POR DISPAPELES A CADA EMPRESA FACTURADORA.
#+ @param prefijo PREFIJO DEL DOCUMENTO.
#+ @param tipoArchivo INDICA QUE TIPO DE ARCHIVO SE DEBE DESCARGAR. 0 = PDF Y XML; 1 = PDF; 2 = XML
#+ @param tipoDocumento TIPO DE DOCUMENTO ELECTRÓNICO.
#+ @param token TOKEN. CAMPOS PARA VALIDAR LA SEGURIDAD. ESTOS VALORES SON ENTREGADOS POR DISPAPELES A CADA EMPRESA FACTURADORA.   
#+ @param usuario USUARIO. CAMPOS PARA VALIDAR LA SEGURIDAD. ESTOS VALORES SON ENTREGADOS POR DISPAPELES A CADA EMPRESA FACTURADORA.
#+ @param version VERSIÓN DEL MANUAL CON LA QUE EL CLIENTE TRABAJÓ LA INTEGRACIÓN.
#+
#+ @return Sin_regreso
#+
FUNCTION f_borrarRegistrosIA_Agrega(
     consecutivo  
   , contrasenia  
   , idEmpresa  
   , prefijo  
   , tipoArchivo  
   , tipoDocumento  
   , token  
   , usuario  
   , version 
)
DEFINE
    consecutivo   BIGINT 
  , contrasenia   VARCHAR(40) 
  , idEmpresa     BIGINT 
  , prefijo       VARCHAR(5) 
  , tipoArchivo   INTEGER 
  , tipoDocumento VARCHAR(1) 
  , token         VARCHAR(40) 
  , usuario       VARCHAR(40) 
  , version       VARCHAR(40)

  --Inicialización de variables
  LET borrarRegistrosIA.Fel_ConsultaFacturaArchivo.consecutivo   = consecutivo
  LET borrarRegistrosIA.Fel_ConsultaFacturaArchivo.contrasenia   = contrasenia
  LET borrarRegistrosIA.Fel_ConsultaFacturaArchivo.idEmpresa     = idEmpresa
  LET borrarRegistrosIA.Fel_ConsultaFacturaArchivo.prefijo       = prefijo
  LET borrarRegistrosIA.Fel_ConsultaFacturaArchivo.tipoArchivo   = tipoArchivo
  LET borrarRegistrosIA.Fel_ConsultaFacturaArchivo.tipoDocumento = tipoDocumento
  LET borrarRegistrosIA.Fel_ConsultaFacturaArchivo.token         = token
  LET borrarRegistrosIA.Fel_ConsultaFacturaArchivo.usuario       = usuario
  LET borrarRegistrosIA.Fel_ConsultaFacturaArchivo.version       = version

    LET indice_errores = 0

END FUNCTION

#+ Recupera registro BorrarRegistrosIA.
#+
#+ Recupera la respuesta derivada de la eliminación de registros IA. En la cual se recibe un número de archivo y un número de mensaje a consultar.
#+
#+ @code
#+ CALL f_RespuestaBorrarRegistrosIA_Recupera()
#+ RETURNING 
#+     codigoRespuesta
#+    ,consecutivo
#+    ,descripcionRespuesta
#+    ,estadoProceso
#+    ,idErp
#+    ,prefijo
#+    ,tipoDocumento
#+
#+ @return codigoRespuesta CÓDIGO INTERNO CON EL RESULTADO DE LA OPERACIÓN.
#+ @return consecutivo NÚMERO DE CONSECUTIVO DE LA FACTURA.
#+ @return descripcionRespuesta TEXTO QUE DEVUELVE UN CÓDIGO SEGUIDO DEL MENSAJE QUE DESCRIBE ESE CÓDIGO. EJEMPLO: OK, SE HAN RECIBIDO 100 FACTURAS. 
#+ @return estadoProceso PREFIJO DE FACTURACIÓN.
#+ @return idErp CÓDIGO INTERNO QUE IDENTIFICA LA FACTURA EN EL ERP.
#+ @return prefijo PREFIJO DE DOCUMENTO, SOLO SI LA EMPRESA LO MANEJA.
#+ @return tipoDocumento TIPO DE DOCUMENTO --1. FACTURA DE VENTA, 2. NOTA CRÉDITO, 3. NOTA DÉBITO 4.FACTURA DE EXPORTACIÓN, 5.FACTURA DE CONTINGENCIA, 6.FACTURA DE IMPORTACIÓN
#+
FUNCTION f_RespuestaBorrarRegistrosIA_Recupera()
DEFINE
     wsstatus             INTEGER
    ,codigoRespuesta      INTEGER
   , consecutivo          BIGINT
   , descripcionRespuesta VARCHAR(240)
   , estadoProceso        INTEGER
   , idErp                VARCHAR(240)
   , prefijo              VARCHAR(5) 
   , tipoDocumento        VARCHAR(1)

   ,lb_hay_error BOOLEAN

    LET lb_hay_error = FALSE
    
    CALL Val_obligaIAb("Es obligatorio el consecutivo",borrarRegistrosIA.Fel_ConsultaFacturaArchivo.consecutivo,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obligaIAb("Es obligatoria la contraseña",borrarRegistrosIA.Fel_ConsultaFacturaArchivo.contrasenia,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obligaIAb("Es obligatorio el id de la empresa ",borrarRegistrosIA.Fel_ConsultaFacturaArchivo.idEmpresa,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obligaIAb("Es obligatorio el tipo de documento",borrarRegistrosIA.Fel_ConsultaFacturaArchivo.tipodocumento,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obligaIAb("Es obligatorio el token",borrarRegistrosIA.Fel_ConsultaFacturaArchivo.token,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obligaIAb("Es obligatorio el usuario",borrarRegistrosIA.Fel_ConsultaFacturaArchivo.usuario,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obligaIAb("Es obligatoria la versión",borrarRegistrosIA.Fel_ConsultaFacturaArchivo.version,lb_hay_error) RETURNING lb_hay_error

    IF lb_hay_error THEN
        LET descripcionRespuesta = "Hay errores en validación de campos obligatorios."
       RETURN   codigoRespuesta
              , consecutivo         
              , descripcionRespuesta 
              , estadoProceso        
              , idErp                
              , prefijo              
              , tipoDocumento

    END IF
   
   --Consume el WS
   CALL  DispapelesArchivo.borrarRegistrosIA_g() RETURNING wsstatus

   --Inicialización de variables
   LET codigoRespuesta      = borrarRegistrosIAResponse.return.codigoRespuesta
   LET consecutivo          = borrarRegistrosIAResponse.return.consecutivo
   LET descripcionRespuesta = borrarRegistrosIAResponse.return.descripcionRespuesta
   LET estadoProceso        = borrarRegistrosIAResponse.return.estadoProceso
   LET idErp                = borrarRegistrosIAResponse.return.idErp
   LET prefijo              = borrarRegistrosIAResponse.return.prefijo
   LET tipoDocumento        = borrarRegistrosIAResponse.return.tipoDocumento

   RETURN   codigoRespuesta
          , consecutivo         
          , descripcionRespuesta 
          , estadoProceso        
          , idErp                
          , prefijo              
          , tipoDocumento

END FUNCTION

#+ Recuperar mensaje BorrarRegistrosIA.
#+
#+ Recupera un mensaje, del listado de mensajes restantes, después de la eliminación de registros IA.
#+
#+ @code
#+ CALL f_RespuestaBorrarRegistrosIAMensajes_Recupera(indice)
#+ RETURNING 
#+     codigoMensaje
#+    ,descripcionMensaje
#+    ,rechazoNotificacion
#+
#+ @param indice Número de mensaje a recuperar.
#+
#+ @return codigoMensaje IDENTIFICADOR DEL MENSAJE.
#+ @return descripcionMensaje CAMPO QUE DESCRIBE LOS MENSAJES DE ERROR ASOCIADOS AL DOCUMENTO.
#+ @return rechazoNotificacion CAMPO QUE DESCRIBE SI LA VALIDACIÓN ES DE TIPO RECHAZO (R) O NOTIFICACIÓN (N)
#+
FUNCTION f_RespuestaBorrarRegistrosIAMensajes_Recupera(indice)
DEFINE
     indice               INTEGER
   , codigoMensaje        VARCHAR(50)
   , descripcionMensaje   VARCHAR(240)
   , rechazoNotificacion  VARCHAR(2)

   --Inicialización de variables
   INITIALIZE  codigoMensaje 
             , descripcionMensaje 
             , rechazoNotificacion TO NULL
             
   IF ( indice > 0 AND borrarRegistrosIAResponse.return.listaMensajesProceso.getLength() > 0 ) THEN
      LET codigoMensaje       = borrarRegistrosIAResponse.return.listaMensajesProceso[indice].codigoMensaje
      LET descripcionMensaje  = borrarRegistrosIAResponse.return.listaMensajesProceso[indice].descripcionMensaje
      LET rechazoNotificacion = borrarRegistrosIAResponse.return.listaMensajesProceso[indice].rechazoNotificacion
   END IF

   RETURN   codigoMensaje 
          , descripcionMensaje 
          , rechazoNotificacion

END FUNCTION

#+ Recuperar archivo BorrarRegistrosIA.
#+
#+ Recupera un archivo, de los restantes, después de la eliminación de registros IA.
#+
#+ @code
#+ CALL f_RespuestaBorrarRegistrosIAArchivos_Recupera(indice)
#+ RETURNING 
#+    ,formato
#+    ,mimeType
#+    ,nameFile
#+    ,streamFile
#+
#+ @param indice Número de archivo a recuperar.
#+
#+ @return formato  EXTENSIÓN PARA EL ARCHIVO (.XML O .PDF)
#+ @return mimeType MIMETYPE, FORMATO ESTÁNDAR DE HTML PARA IDENTIFICAR EL TIPO DE ARCHIVO.
#+ @return nameFile NOMBRE DEL ARCHIVO, TAL COMO SE ENCUENTRA EN EL SERVIDOR.
#+ @return streamFile FLUJO DE BYTES QUE CONTIENE EL ARCHIVO COMO UN ARREGLO DE BYTES.
#+
FUNCTION f_RespuestaBorrarRegistrosIAArchivos_Recupera(indice)
DEFINE
     indice               INTEGER
   , formato              VARCHAR(4)
   , mimeType             VARCHAR(240)
   , nameFile             VARCHAR(240)
   , streamFile           STRING

   --Inicialización de variables
   INITIALIZE  formato 
             , mimeType
             , nameFile
             , streamFile TO NULL
   IF ( indice > 0 AND borrarRegistrosIAResponse.return.listaArchivos.getLength() > 0 ) THEN
      LET formato    = borrarRegistrosIAResponse.return.listaArchivos[indice].formato
      LET mimeType   = borrarRegistrosIAResponse.return.listaArchivos[indice].mimeType
      LET nameFile   = borrarRegistrosIAResponse.return.listaArchivos[indice].nameFile
      LET streamFile = borrarRegistrosIAResponse.return.listaArchivos[indice].streamFile
   END IF   

   RETURN   formato 
          , mimeType
          , nameFile
          , streamFile
          
END FUNCTION

#+ Guardar archivos de borrarRegistrosIA.
#+
#+ Guarda todos los archivos que traiga de respuesta de borrarRegistrosIA en el directorio especificado.
#+
#+ @code
#+ CALL f_BorrarRegistrosIA_Guardar("c:\\Puerto\\")
#+
#+ @param Ruta Directorio en el que se guardaran los archivos.
#+
#+ @return sin retorno

FUNCTION f_BorrarRegistrosIA_Guardar(Ruta)
DEFINE Ruta STRING
   , indice      INTEGER
   , formato     VARCHAR(4)
   , mimeType    VARCHAR(240)
   , nameFile    VARCHAR(240)
   , streamFile  STRING 
DEFINE ch_out base.Channel

   FOR indice = 1 TO f_RespuestaTamanoBorrarRegistrosIA_listaArchivos_Recupera()
      CALL f_RespuestaBorrarRegistrosIAArchivos_Recupera(indice)
           RETURNING  formato, mimeType, nameFile, streamFile

      LET ch_out = base.Channel.create()
      CALL ch_out.setDelimiter(NULL)
      CALL ch_out.openFile(Ruta||nameFile,"w")
      CALL ch_out.write(streamFile)
      CALL ch_out.close()
      
   END FOR

END FUNCTION

#+ Recuperar registro DescargaDocumentos.
#+
#+ Recupera un registro correspondiente a la respuesta derivada de la descarga de un documento.
#+
#+ @code
#+ CALL f_RespuestaDescargaDocumentos_Recupera()
#+ RETURNING 
#+     codigoRespuesta
#+    ,consecutivo
#+    ,descripcionRespuesta
#+    ,estadoProceso
#+    ,idErp
#+    ,prefijo
#+    ,tipoDocumento
#+
#+ @return codigoRespuesta CÓDIGO INTERNO CON EL RESULTADO DE LA OPERACIÓN.
#+ @return consecutivo NÚMERO DE CONSECUTIVO DE LA FACTURA.
#+ @return descripcionRespuesta TEXTO QUE DEVUELVE UN CÓDIGO SEGUIDO DEL MENSAJE QUE DESCRIBE ESE CÓDIGO. EJEMPLO: OK, SE HAN RECIBIDO 100 FACTURAS. 
#+ @return estadoProceso PREFIJO DE FACTURACIÓN.
#+ @return idErp CÓDIGO INTERNO QUE IDENTIFICA LA FACTURA EN EL ERP.
#+ @return prefijo PREFIJO DE DOCUMENTO, SOLO SI LA EMPRESA LO MANEJA.
#+ @return tipoDocumento TIPO DE DOCUMENTO --1. FACTURA DE VENTA, 2. NOTA CRÉDITO, 3. NOTA DÉBITO 4.FACTURA DE EXPORTACIÓN, 5.FACTURA DE CONTINGENCIA, 6.FACTURA DE IMPORTACIÓN
#+
FUNCTION f_RespuestaDescargaDocumentos_Recupera()
DEFINE
     wsstatus             INTEGER
   , codigoRespuesta      INTEGER
   , consecutivo          BIGINT
   , descripcionRespuesta VARCHAR(240)
   , estadoProceso        INTEGER
   , idErp                VARCHAR(240)
   , prefijo              VARCHAR(5) 
   , tipoDocumento        VARCHAR(1)

   ,lb_hay_error BOOLEAN

    LET lb_hay_error = FALSE
    
    CALL Val_obliga("Es obligatorio el consecutivo",consultarArchivos.Fel_ConsultaFacturaArchivo.consecutivo,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obliga("Es obligatoria la contraseña",consultarArchivos.Fel_ConsultaFacturaArchivo.contrasenia,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obliga("Es obligatorio el id de la empresa ",consultarArchivos.Fel_ConsultaFacturaArchivo.idEmpresa,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obliga("Es obligatorio el tipo de documento",consultarArchivos.Fel_ConsultaFacturaArchivo.tipodocumento,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obliga("Es obligatorio el token",consultarArchivos.Fel_ConsultaFacturaArchivo.token,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obliga("Es obligatorio el usuario",consultarArchivos.Fel_ConsultaFacturaArchivo.usuario,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obliga("Es obligatoria la versión",consultarArchivos.Fel_ConsultaFacturaArchivo.version,lb_hay_error) RETURNING lb_hay_error

    IF lb_hay_error THEN
        LET descripcionRespuesta = "Hay errores en validación de campos obligatorios."
       RETURN   codigoRespuesta
              , consecutivo         
              , descripcionRespuesta 
              , estadoProceso        
              , idErp                
              , prefijo              
              , tipoDocumento

    END IF

   --Consume el WS
   CALL DispapelesArchivo.consultarArchivos_g() RETURNING wsstatus

   --Inicialización de variables
   LET codigoRespuesta      = consultarArchivosResponse.return.codigoRespuesta
   LET consecutivo          = consultarArchivosResponse.return.consecutivo
   LET descripcionRespuesta = consultarArchivosResponse.return.descripcionRespuesta
   LET estadoProceso        = consultarArchivosResponse.return.estadoProceso
   LET idErp                = consultarArchivosResponse.return.idErp
   LET prefijo              = consultarArchivosResponse.return.prefijo
   LET tipoDocumento        = consultarArchivosResponse.return.tipoDocumento

   RETURN   codigoRespuesta
          , consecutivo         
          , descripcionRespuesta 
          , estadoProceso        
          , idErp                
          , prefijo              
          , tipoDocumento

END FUNCTION

#+ Genera el filtro para consultar la factura.
#+
#+ Genera la información que será utilizada para filtrar la factura.
#+
#+ @code
#+ CALL f_consultarFacturaArchivo_Agrega(
#+         123--consecutivo
#+    ,"Texto"--contrasenia
#+    ,    123--idEmpresa
#+    ,"Texto"--prefijo
#+    ,    123--tipoArchivo
#+    ,"Texto"--tipoDocumento
#+    ,"Texto"--token
#+    ,"Texto"--usuario
#+    ,"Texto"--version
#+ )
#+
#+ @param consecutivo  NÚMERO DE CONSECUTIVO DE LA FACTURA.
#+ @param contrasenia  CONTRASEÑA. CAMPOS PARA VALIDAR LA SEGURIDAD. ESTOS VALORES SON ENTREGADOS POR DISPAPELES A CADA EMPRESA FACTURADORA.
#+ @param idEmpresa ID. DE EMPRESA. CAMPOS PARA VALIDAR LA SEGURIDAD. ESTOS VALORES SON ENTREGADOS POR DISPAPELES A CADA EMPRESA FACTURADORA.
#+ @param prefijo PREFIJO DEL DOCUMENTO.
#+ @param tipoArchivo INDICA QUE TIPO DE ARCHIVO SE DEBE DESCARGAR. 0 = PDF Y XML; 1 = PDF; 2 = XML
#+ @param tipoDocumento TIPO DE DOCUMENTO ELECTRÓNICO.
#+ @param token TOKEN. CAMPOS PARA VALIDAR LA SEGURIDAD. ESTOS VALORES SON ENTREGADOS POR DISPAPELES A CADA EMPRESA FACTURADORA.   
#+ @param usuario USUARIO. CAMPOS PARA VALIDAR LA SEGURIDAD. ESTOS VALORES SON ENTREGADOS POR DISPAPELES A CADA EMPRESA FACTURADORA.
#+ @param version VERSIÓN DEL MANUAL CON LA QUE EL CLIENTE TRABAJÓ LA INTEGRACIÓN.
#+
#+ @return Sin_regreso
#+
FUNCTION f_consultarFacturaArchivo_Agrega(
     consecutivo  
   , contrasenia  
   , idEmpresa  
   , prefijo  
   , tipoArchivo  
   , tipoDocumento  
   , token  
   , usuario  
   , version 
)
DEFINE
    consecutivo   BIGINT 
  , contrasenia   VARCHAR(40) 
  , idEmpresa     BIGINT 
  , prefijo       VARCHAR(5) 
  , tipoArchivo   INTEGER 
  , tipoDocumento VARCHAR(1) 
  , token         VARCHAR(40) 
  , usuario       VARCHAR(40) 
  , version       VARCHAR(40)

  --Inicialización de variables
  LET consultarArchivos.Fel_ConsultaFacturaArchivo.consecutivo   = consecutivo
  LET consultarArchivos.Fel_ConsultaFacturaArchivo.contrasenia   = contrasenia
  LET consultarArchivos.Fel_ConsultaFacturaArchivo.idEmpresa     = idEmpresa
  LET consultarArchivos.Fel_ConsultaFacturaArchivo.prefijo       = prefijo
  LET consultarArchivos.Fel_ConsultaFacturaArchivo.tipoArchivo   = tipoArchivo
  LET consultarArchivos.Fel_ConsultaFacturaArchivo.tipoDocumento = tipoDocumento
  LET consultarArchivos.Fel_ConsultaFacturaArchivo.token         = token
  LET consultarArchivos.Fel_ConsultaFacturaArchivo.usuario       = usuario
  LET consultarArchivos.Fel_ConsultaFacturaArchivo.version       = version

   LET indice_errores = 0

END FUNCTION

#+ Recuperar archivo DescargaDocumentos.
#+
#+ Recupera un archivo, recibiendo como parámetro un número de archivo.
#+
#+ @code
#+ CALL f_RespuestaArchivos_Recupera(indice)
#+ RETURNING  
#+          formato
#+        , mimeType
#+        , nameFile
#+        , streamFile
#+
#+ @param indice Número de archivo a recuperar.
#+
#+ @return formato  EXTENSIÓN PARA EL ARCHIVO (.XML O .PDF)
#+ @return mimeType MIMETYPE, FORMATO ESTÁNDAR DE HTML PARA IDENTIFICAR EL TIPO DE ARCHIVO.
#+ @return nameFile NOMBRE DEL ARCHIVO, TAL COMO SE ENCUENTRA EN EL SERVIDOR.
#+ @return streamFile FLUJO DE BYTES QUE CONTIENE EL ARCHIVO COMO UN ARREGLO DE BYTES.
#+
FUNCTION f_RespuestaArchivos_Recupera(indice)
DEFINE
     formato     VARCHAR(4)
   , mimeType    VARCHAR(240)
   , nameFile    VARCHAR(240)
   , streamFile  STRING 
   , indice      INTEGER 

  --Inicialización de variables
  INITIALIZE   formato
             , mimeType
             , nameFile
             , streamFile TO NULL
             
  IF ( indice > 0 AND consultarArchivosResponse.return.listaArchivos.getLength() > 0 ) THEN  
     LET formato     = consultarArchivosResponse.return.listaArchivos[indice].formato
     LET mimeType    = consultarArchivosResponse.return.listaArchivos[indice].mimeType
     LET nameFile    = consultarArchivosResponse.return.listaArchivos[indice].nameFile
     LET streamFile  = consultarArchivosResponse.return.listaArchivos[indice].streamFile
  END IF   

  RETURN   formato
         , mimeType
         , nameFile
         , streamFile
  
END FUNCTION

#+ Guardar archivos DescargaDocumentos.
#+
#+ Guarda todos los archivos que traiga de respuesta en el directorio especificado.
#+
#+ @code
#+ CALL f_RespuestaArchivos_Guardar("c:\\Puerto\\")
#+
#+ @param Ruta Directorio en el que se guardaran los archivos.
#+
#+ @return sin retorno

FUNCTION f_ConsultarArchivos_Guardar(Ruta)
DEFINE Ruta STRING
   , indice      INTEGER
   , formato     VARCHAR(4)
   , mimeType    VARCHAR(240)
   , nameFile    VARCHAR(240)
   , streamFile  STRING 
--DEFINE ch_out base.Channel

   FOR indice = 1 TO f_RespuestaTamanoConsultarArchivos_listaArchivos_Recupera()
      CALL f_RespuestaArchivos_Recupera(indice)
           RETURNING  formato, mimeType, nameFile, streamFile


      CALL security.Base64.SaveBinary(Ruta||nameFile,streamFile)

      {LET ch_out = base.Channel.create()
      CALL ch_out.setDelimiter(NULL)
      CALL ch_out.openFile(Ruta||nameFile,"w")
      CALL ch_out.write(streamFile)
      CALL ch_out.close()}
      
   END FOR

END FUNCTION

#+ Recuperar mensaje DescargaDocumentos.
#+
#+ Recupera un mensaje correspondiente a los existentes en la respuesta a la consulta de archivos.
#+
#+ @code
#+ CALL f_RespuestaMensajesProcesoArchivo_Recupera(indice)
#+ RETURNING 
#+     codigoMensaje
#+    ,descripcionMensaje
#+    ,rechazoNotificacion
#+
#+ @param indice Número de mensaje a recuperar.
#+
#+ @return codigoMensaje IDENTIFICADOR DEL MENSAJE
#+ @return descripcionMensaje CAMPO QUE DESCRIBE LOS MENSAJES DE ERROR ASOCIADOS AL DOCUMENTO.
#+ @return rechazoNotificacion CAMPO QUE DESCRIBE SI LA VALIDACIÓN ES DE TIPO RECHAZO (R) O NOTIFICACIÓN (N)
#+
FUNCTION f_RespuestaMensajesProcesoArchivo_Recupera(indice)
DEFINE
     codigoMensaje        VARCHAR(50)
   , descripcionMensaje   VARCHAR(240)
   , rechazoNotificacion  VARCHAR(2)
   , indice               INTEGER

   --Inicialización de variables
   INITIALIZE  codigoMensaje      
             , descripcionMensaje   
             , rechazoNotificacion TO NULL
             
   IF ( indice > 0 AND consultarArchivosResponse.return.listaMensajesProceso.getLength() > 0 ) THEN
      LET codigoMensaje       = consultarArchivosResponse.return.listaMensajesProceso[indice].codigoMensaje
      LET descripcionMensaje  = consultarArchivosResponse.return.listaMensajesProceso[indice].descripcionMensaje
      LET rechazoNotificacion = consultarArchivosResponse.return.listaMensajesProceso[indice].rechazoNotificacion
   END IF

   RETURN   codigoMensaje      
          , descripcionMensaje   
          , rechazoNotificacion

END FUNCTION

#+ Genera el filtro para consultar los registros IA.
#+
#+ Genera la información que será utilizada para filtrar los registros IA.
#+
#+ @code
#+ CALL f_consultarRegistrosIA_Agrega(
#+         123--consecutivo
#+    ,"Texto"--contrasenia
#+    ,    123--idEmpresa
#+    ,"Texto"--prefijo
#+    ,    123--tipoArchivo
#+    ,"Texto"--tipoDocumento
#+    ,"Texto"--token
#+    ,"Texto"--usuario
#+    ,"Texto"--version
#+ )
#+
#+ @param consecutivo  NÚMERO DE CONSECUTIVO DE LA FACTURA.
#+ @param contrasenia  CONTRASEÑA. CAMPOS PARA VALIDAR LA SEGURIDAD. ESTOS VALORES SON ENTREGADOS POR DISPAPELES A CADA EMPRESA FACTURADORA.
#+ @param idEmpresa ID. DE EMPRESA. CAMPOS PARA VALIDAR LA SEGURIDAD. ESTOS VALORES SON ENTREGADOS POR DISPAPELES A CADA EMPRESA FACTURADORA.
#+ @param prefijo PREFIJO DEL DOCUMENTO.
#+ @param tipoArchivo INDICA QUE TIPO DE ARCHIVO SE DEBE DESCARGAR. 0 = PDF Y XML; 1 = PDF; 2 = XML
#+ @param tipoDocumento TIPO DE DOCUMENTO ELECTRÓNICO.
#+ @param token TOKEN. CAMPOS PARA VALIDAR LA SEGURIDAD. ESTOS VALORES SON ENTREGADOS POR DISPAPELES A CADA EMPRESA FACTURADORA.   
#+ @param usuario USUARIO. CAMPOS PARA VALIDAR LA SEGURIDAD. ESTOS VALORES SON ENTREGADOS POR DISPAPELES A CADA EMPRESA FACTURADORA.
#+ @param version VERSIÓN DEL MANUAL CON LA QUE EL CLIENTE TRABAJÓ LA INTEGRACIÓN.
#+
#+ @return Sin_regreso
#+
FUNCTION f_consultarRegistrosIA_Agrega(
     consecutivo  
   , contrasenia  
   , idEmpresa  
   , prefijo  
   , tipoArchivo  
   , tipoDocumento  
   , token  
   , usuario  
   , version 
)
DEFINE
    consecutivo   BIGINT 
  , contrasenia   VARCHAR(40) 
  , idEmpresa     BIGINT 
  , prefijo       VARCHAR(5) 
  , tipoArchivo   INTEGER 
  , tipoDocumento VARCHAR(1) 
  , token         VARCHAR(40) 
  , usuario       VARCHAR(40) 
  , version       VARCHAR(40)

  --Inicialización de variables
  LET consultarRegistrosIA.Fel_ConsultaFacturaArchivo.consecutivo   = consecutivo
  LET consultarRegistrosIA.Fel_ConsultaFacturaArchivo.contrasenia   = contrasenia
  LET consultarRegistrosIA.Fel_ConsultaFacturaArchivo.idEmpresa     = idEmpresa
  LET consultarRegistrosIA.Fel_ConsultaFacturaArchivo.prefijo       = prefijo
  LET consultarRegistrosIA.Fel_ConsultaFacturaArchivo.tipoArchivo   = tipoArchivo
  LET consultarRegistrosIA.Fel_ConsultaFacturaArchivo.tipoDocumento = tipoDocumento
  LET consultarRegistrosIA.Fel_ConsultaFacturaArchivo.token         = token
  LET consultarRegistrosIA.Fel_ConsultaFacturaArchivo.usuario       = usuario
  LET consultarRegistrosIA.Fel_ConsultaFacturaArchivo.version       = version

   LET indice_errores = 0
  
END FUNCTION
#+ Envia consultar registro IA.
#+
#+ Envia la ejecución al servicio web de archivo metodo Consulta de registro IA.
#+
#+ @code
#+ CALL f_RegistrosIA_Recupera() RETURNING wsstatus
#+
#+ @return wsstatus CÓDIGO DE ESTADO DE LA COMUNICACIÓN
#+
FUNCTION f_RegistrosIA_Recupera()
DEFINE wsstatus INTEGER

   ,lb_hay_error BOOLEAN

    LET lb_hay_error = FALSE
    
    CALL Val_obligaIAc("Es obligatorio el consecutivo",consultarRegistrosIA.Fel_ConsultaFacturaArchivo.consecutivo,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obligaIAc("Es obligatoria la contraseña",consultarRegistrosIA.Fel_ConsultaFacturaArchivo.contrasenia,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obligaIAc("Es obligatorio el id de la empresa ",consultarRegistrosIA.Fel_ConsultaFacturaArchivo.idEmpresa,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obligaIAc("Es obligatorio el tipo de documento",consultarRegistrosIA.Fel_ConsultaFacturaArchivo.tipodocumento,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obligaIAc("Es obligatorio el token",consultarRegistrosIA.Fel_ConsultaFacturaArchivo.token,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obligaIAc("Es obligatorio el usuario",consultarRegistrosIA.Fel_ConsultaFacturaArchivo.usuario,lb_hay_error) RETURNING lb_hay_error
    CALL Val_obligaIAc("Es obligatoria la versión",consultarRegistrosIA.Fel_ConsultaFacturaArchivo.version,lb_hay_error) RETURNING lb_hay_error

    IF lb_hay_error THEN
        RETURN wsstatus
    END IF
    --Consume el WS
   CALL  DispapelesArchivo.consultarRegistrosIA_g() RETURNING wsstatus

   RETURN wsstatus

END FUNCTION


#+ Recupera registro IA.
#+
#+ Recupera un nuevo registro al resultado de la consulta de registros IA. Acorde al indice indicado.
#+
#+ @code
#+ CALL f_RespuestaConsultarRegistrosIA_Agrega(
#+     1--indice
#+ )
#+ RETURNING cadena
#+
#+ @param indice  NÚMERO DE CADENA A RECUPERAR.
#+
#+ @return cadena  CADENA CON EL RESULTADO DE LA CONSULTA DE REGISTROS IA.
#+
FUNCTION f_RespuestaConsultarRegistrosIA_Recupera(
      indice
)
DEFINE
     indice     INTEGER
   , cadena     VARCHAR(255)    

   --Inicialización de variables
   LET cadena = consultarRegistrosIAResponse.return[indice]

   RETURN cadena
   
END FUNCTION

#+ Genera el filtro para consultar un rango de registros IA.
#+
#+ Genera la información que será utilizada para filtrar un rango de registros IA.
#+
#+ @code
#+ CALL f_ConsultarRegistrosIAManual_Agrega(
#+         999           --consecutivoFinal
#+    ,    123           --consecutivoInicial
#+    ,"1993-01-01 00:00"--fechaFinal
#+    ,"1990-01-01 00:00"--fechaIncial
#+    ,    123           --idEmpresa
#+    ,"Texto"           --numeroIdentificacion
#+    ,"Texto"           --prefijo
#+ )
#+
#+ @param consecutivoFinal  NÚMERO DE CONSECUTIVO FINAL DE LAS FACTURAS.
#+ @param consecutivoInicial  NÚMERO DE CONSECUTIVO INICIAL DE LAS FACTURAS.
#+ @param fechaFinal  FECHA FINAL DE LAS FACTURAS
#+ @param fechaIncial FECHA INICIAL DE LAS FACTURAS 
#+ @param idEmpresa IDENTIFICADOR DE EMPRESA.
#+ @param numeroIdentificacion NÚMERO DEL DOCUMENTO DE IDENTIFICACIÓN.
#+ @param prefijo PREFIJO DE LOS DOCUMENTOS.
#+
#+ @return Sin_regreso
#+
FUNCTION f_ConsultarRegistrosIAManual_Agrega(
     consecutivoFinal 
   , consecutivoInicial 
   , fechaFinal 
   , fechaIncial 
   , idEmpresa 
   , numeroIdentificacion 
   , prefijo
)
DEFINE
    consecutivoFinal     BIGINT
  , consecutivoInicial   BIGINT
  , fechaFinal           DATETIME YEAR TO FRACTION(5)
  , fechaIncial          DATETIME YEAR TO FRACTION(5)
  , idEmpresa            BIGINT
  , numeroIdentificacion VARCHAR(30)
  , prefijo              VARCHAR(5)

   --Inicialización de variables
   LET ConsultarRegistrosIAManual.Fel_ConsultaFacturaArchivoIA.consecutivoFinal     = consecutivoFinal
   LET ConsultarRegistrosIAManual.Fel_ConsultaFacturaArchivoIA.consecutivoInicial   = consecutivoInicial
   LET ConsultarRegistrosIAManual.Fel_ConsultaFacturaArchivoIA.fechaFinal           = fechaFinal
   LET ConsultarRegistrosIAManual.Fel_ConsultaFacturaArchivoIA.fechaIncial          = fechaIncial
   LET ConsultarRegistrosIAManual.Fel_ConsultaFacturaArchivoIA.idEmpresa            = idEmpresa
   LET ConsultarRegistrosIAManual.Fel_ConsultaFacturaArchivoIA.numeroIdentificacion = numeroIdentificacion
   LET ConsultarRegistrosIAManual.Fel_ConsultaFacturaArchivoIA.prefijo              = prefijo

    LET indice_errores = 0

END FUNCTION

#+ Envia consultar registro IA Manual.
#+
#+ Envia la ejecución al servicio web de archivo metodo Consulta de registro IA manual.
#+
#+ @code
#+ CALL f_RegistrosIAManual_Recupera() RETURNING wsstatus
#+
#+ @return wsstatus CÓDIGO DE ESTADO DE LA COMUNICACIÓN
#+
FUNCTION f_RegistrosIAManual_Recupera()
DEFINE wsstatus INTEGER

   ,lb_hay_error BOOLEAN

    LET lb_hay_error = FALSE
    
    CALL Val_obligaIAm("Es obligatorio el id de la empresa ",ConsultarRegistrosIAManual.Fel_ConsultaFacturaArchivoIA.idEmpresa,lb_hay_error) RETURNING lb_hay_error

    IF lb_hay_error THEN

        RETURN wsstatus

    END IF
    --Consume el WS
    CALL  DispapelesArchivo.ConsultarRegistrosIAManual_g() RETURNING wsstatus

   RETURN wsstatus

END FUNCTION

#+ Recupera cadena IA manual.
#+
#+ Recupera una cadena del listado manual de resultados correspondientes a la consulta un rango de registros IA. Acorde al indice indicado.
#+
#+ @code
#+ CALL f_RespuestaConsultarRegistrosIAManual_Recupera(indice) 
#+    RETURNING cadena
#+
#+ @param indice NÚMERO DE MENSAJE A CONSULTAR.
#+
#+ @return cadena CADENA CON EL RESULTADO DE UNA CONSULTA A UN RANGO REGISTROS IA.
#+
FUNCTION f_RespuestaConsultarRegistrosIAManual_Recupera(indice)
DEFINE
     indice      INTEGER
   , cadena      VARCHAR(255)

   --Inicialización de variables
   LET cadena = ConsultarRegistrosIAManualResponse.return[indice]

   RETURN cadena

END FUNCTION

#+ Recupera el número de archivos.
#+
#+ Recupera el número de archivos asociados a la respuesta del consumo del método consultar archivos.
#+
#+ @code
#+ CALL f_RespuestaTamanoConsultarArchivos_listaArchivos_Recupera() 
#+     RETURNING tamano
#+
#+ @return tamano  NÚMERO DE ARCHIVOS CONTENIDOS EN LA CONSULTA DE ARCHIVOS. 
#+
FUNCTION f_RespuestaTamanoConsultarArchivos_listaArchivos_Recupera()
DEFINE
     tamano      INTEGER
   
   --Inicialización de variables
   LET tamano = consultarArchivosResponse.return.listaArchivos.getLength()

   RETURN tamano

END FUNCTION


#+ Recupera número de mensajes.
#+
#+ Regresa el número de mensajes asociados a la consulta de archivos.
#+
#+ @code
#+ CALL f_RespuestaTamanoConsultarArchivos_listaMensajes_Recupera() 
#+     RETURNING tamano
#+
#+ @return tamano  NÚMERO DE MENSAJES ASOCIADOS A LA CONSULTA DE ARCHIVOS. 
#+
FUNCTION f_RespuestaTamanoConsultarArchivos_listaMensajes_Recupera()
DEFINE
     tamano      INTEGER
   
   --Inicialización de variables
   LET tamano = consultarArchivosResponse.return.listaMensajesProceso.getLength()

   RETURN tamano

END FUNCTION

#+ Regresa el número de archivos IA.
#+
#+ Regresa el número de archivos después de la eliminación de registros IA.
#+
#+ @code
#+ CALL f_RespuestaTamanoBorrarRegistrosIA_listaArchivos_Recupera() 
#+     RETURNING tamano
#+
#+ @return tamano  NÚMERO DE ARCHIVOS DESPUÉS DE LA ELIMINACIÓN DE REGISTROS IA. 
#+
FUNCTION f_RespuestaTamanoBorrarRegistrosIA_listaArchivos_Recupera()
DEFINE
     tamano      INTEGER
   
   --Inicialización de variables
   LET tamano = borrarRegistrosIAResponse.return.listaArchivos.getLength()

   RETURN tamano

END FUNCTION

#+ Regresa el número de mensajes IA.
#+
#+ Regresa el número de mensajes después de la eliminación de registros IA.
#+
#+ @code
#+ CALL f_RespuestaTamanoBorrarRegistrosIA_listaMensajes_Recupera() 
#+     RETURNING tamano
#+
#+ @return tamano  NÚMERO DE MENSAJES DESPUÉS DE LA ELIMINACIÓN DE REGISTROS IA. 
#+
FUNCTION f_RespuestaTamanoBorrarRegistrosIA_listaMensajes_Recupera()
DEFINE
     tamano      INTEGER
   
   --Inicialización de variables
   LET tamano = borrarRegistrosIAResponse.return.listaMensajesProceso.getLength()

   RETURN tamano

END FUNCTION

#+ Regresa el número cadenas IA manual.
#+
#+ Regresa el número de cadenas existentes para la consulta de un rango de registros IA manual.
#+
#+ @code
#+ CALL f_RespuestaTamanoConsultarRegistrosIAManual_Recupera() 
#+     RETURNING tamano
#+
#+ @return tamano NÚMERO DE CADENAS EXISTENTES PARA LA CONSULTA DE UN RANGO DE REGISTROS IA.
#+
FUNCTION f_RespuestaTamanoConsultarRegistrosIAManual_Recupera()
DEFINE
     tamano      INTEGER

   --Inicialización de variables
   LET tamano = ConsultarRegistrosIAManualResponse.return.getLength()

   RETURN tamano

END FUNCTION

#+ Regresa el número de cadenas IA.
#+
#+ Regresa el número de cadenas existentes para una consulta de registros IA.
#+
#+ @code
#+ CALL f_RespuestaTamanoConsultarRegistrosIA_Recupera() 
#+     RETURNING  tamano
#+
#+ @return tamano NÚMERO DE CADENAS EXISTENTES PARA UNA CONSULTA DE REGISTROS IA.
#+
FUNCTION f_RespuestaTamanoConsultarRegistrosIA_Recupera()
DEFINE
     tamano      INTEGER

   --Inicialización de variables
   LET tamano = consultarRegistrosIAResponse.return.getLength()

   RETURN tamano

END FUNCTION

PRIVATE FUNCTION Val_obliga(ls_texto,ls_dato,lb_hay_error_t)
DEFINE ls_dato,ls_texto STRING
DEFINE lb_hay_error_t BOOLEAN

    IF ls_dato IS NULL THEN
        LET indice_errores = indice_errores + 1
        LET consultarArchivosResponse.return.listaMensajesProceso[indice_errores].descripcionMensaje = ls_texto
        LET consultarArchivosResponse.return.listaMensajesProceso[indice_errores].rechazoNotificacion = "R"
        LET consultarArchivosResponse.return.listaMensajesProceso[indice_errores].codigoMensaje = "PRE"
        RETURN TRUE
    ELSE 
        RETURN lb_hay_error_t
    END IF

END FUNCTION

PRIVATE FUNCTION Val_obligaIAb(ls_texto,ls_dato,lb_hay_error_t)
DEFINE ls_dato,ls_texto STRING
DEFINE lb_hay_error_t BOOLEAN

    IF ls_dato IS NULL THEN
        LET indice_errores = indice_errores + 1
        LET borrarRegistrosIAResponse.return.listaMensajesProceso[indice_errores].descripcionMensaje = ls_texto
        LET borrarRegistrosIAResponse.return.listaMensajesProceso[indice_errores].rechazoNotificacion = "R"
        LET borrarRegistrosIAResponse.return.listaMensajesProceso[indice_errores].codigoMensaje = "PRE"
        RETURN TRUE
    ELSE 
        RETURN lb_hay_error_t
    END IF

END FUNCTION

PRIVATE FUNCTION Val_obligaIAc(ls_texto,ls_dato,lb_hay_error_t)
DEFINE ls_dato,ls_texto STRING
DEFINE lb_hay_error_t BOOLEAN

    IF ls_dato IS NULL THEN
        LET indice_errores = indice_errores + 1
        LET consultarRegistrosIAResponse.return[indice_errores] = ls_texto
        RETURN TRUE
    ELSE 
        RETURN lb_hay_error_t
    END IF

END FUNCTION

PRIVATE FUNCTION Val_obligaIAm(ls_texto,ls_dato,lb_hay_error_t)
DEFINE ls_dato,ls_texto STRING
DEFINE lb_hay_error_t BOOLEAN

    IF ls_dato IS NULL THEN
        LET indice_errores = indice_errores + 1
        LET ConsultarRegistrosIAManualResponse.return[indice_errores] = ls_texto
        RETURN TRUE
    ELSE 
        RETURN lb_hay_error_t
    END IF

END FUNCTION

