IMPORT security

DATABASE empresa


#############PRUEBAS#################
--GLOBALS "enviarDocumento.inc"       
--GLOBALS "consultarEstadoPrueba.inc" 
--GLOBALS "consultarArchivos.inc"     

#############PRODUCCIÓN################
GLOBALS "enviarDocumentoProduccion.inc"    
GLOBALS "consultarEstadoProduccion.inc"     
GLOBALS "consultarArchivosPro.inc"  

GLOBALs "fc_globales.4gl"

DEFINE wcantidad integer
DEFINE rec_maestro RECORD LIKE fc_factura_m.*,
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
,version VARCHAR(1),
ls_salida STRING,
cbtipd ui.ComboBox,
mtime CHAR(8),
cufe STRING,
newnameFile VARCHAR(240),
ruta_descarga STRING

FUNCTION enviar_documento_soporte(prefijo,tipodoc, documento)
DEFINE prefijo LIKE fc_factura_m.prefijo
DEFINE tipodoc CHAR(1)
DEFINE documento LIKE fc_factura_m.documento
DEFINE bandera,cont,wsstatus,i INTEGER
DEFINE base_imponible DECIMAL (12,2)
DEFINE fecha CHAR(19)

LET wcantidad=0
LET fecha=""
LET fecha=TODAY USING "yyyy-MM-dd"
LET fecha=fecha clipped,"'T'",CURRENT hour TO SECOND
LET fecha=fecha CLIPPED

INITIALIZE rec_maestro.* TO NULL 
INITIALIZE rec_detalle.* TO NULL 
INITIALIZE rec_total.* TO NULL 
INITIALIZE rec_servicio.* TO null

SELECT fc_factura_m.*, fc_factura_tot.* 
INTO rec_maestro.*, rec_total.* 
FROM fc_factura_m, fc_factura_tot
WHERE fc_factura_m.prefijo = fc_factura_tot.prefijo
AND fc_factura_m.documento= fc_factura_tot.documento
AND fc_factura_m.prefijo=prefijo
AND fc_factura_m.documento=documento



LET wfechafac=CURRENT YEAR TO SECOND 
--LET wfechafac=util.Datetime.format(wfechafac, "%Y-%m-%d'T'%H:%M:%S")

SELECT COUNT(*) INTO wcantidad FROM fc_factura_d
WHERE fc_factura_d.prefijo=prefijo
AND fc_factura_d.documento=documento



DISPLAY rec_maestro.* 
display rec_detalle.*
display rec_total.*

EXECUTE IMMEDIATE "set encryption password ""0r13nt3"""
   select fe_dispapeles_acceso.idEmpresa
       ,""
       ,fe_dispapeles_acceso.usuario
       ,decrypt_char(fe_dispapeles_acceso.contrasena) as contrasena
       ,decrypt_char(fe_dispapeles_acceso.token) as token
       ,fe_dispapeles_acceso.version
   INTO idEmpresa,idErp,usuario,contrasena,token,version
   from fe_dispapeles_acceso

LET enviarDocumento.felCabezaDocumento.idEmpresa         = idEmpresa
LET enviarDocumento.felCabezaDocumento.usuario           = usuario clipped
LET enviarDocumento.felCabezaDocumento.contrasenia       = contrasena clipped
LET enviarDocumento.felCabezaDocumento.token             = token CLIPPED 
LET enviarDocumento.felCabezaDocumento.version           = "14"
LET enviarDocumento.felCabezaDocumento.tipodocumento     = tipodoc CLIPPED
LET enviarDocumento.felCabezaDocumento.prefijo           = prefijo CLIPPED
SELECT numero INTO enviarDocumento.felCabezaDocumento.consecutivo FROM fc_prefijos
LET enviarDocumento.felCabezaDocumento.fechafacturacion  = wfechafac
LET enviarDocumento.felCabezaDocumento.codigoPlantillaPdf= 14
LET enviarDocumento.felCabezaDocumento.cantidadLineas    = wcantidad
LET enviarDocumento.felCabezaDocumento.tiponota          = "0"
LET enviarDocumento.felCabezaDocumento.aplicafel         = "NO"
LET enviarDocumento.felCabezaDocumento.listaMediosPagos[1].medioPago=rec_maestro.medio_pago

DECLARE det CURSOR FOR
SELECT * FROM fc_factura_d
WHERE fc_factura_d.prefijo = prefijo
AND fc_factura_d.documento = documento
INITIALIZE rec_detalle.* TO NULL 
LET i=1

FOREACH det INTO rec_detalle.*
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].codigoproducto=rec_detalle.codigo
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].tipocodigoproducto="999"
    SELECT descripcion, coduni INTO  enviarDocumento.felCabezaDocumento.listaDetalle[i].nombreProducto,enviarDocumento.felCabezaDocumento.listaDetalle[i].unidadmedida
    FROM fc_servicios
    WHERE codigo=rec_detalle.codigo
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].nombreProducto=enviarDocumento.felCabezaDocumento.listaDetalle[i].nombreProducto CLIPPED 
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].nombreProducto= enviarDocumento.felCabezaDocumento.listaDetalle[i].nombreProducto CLIPPED 
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].unidadmedida=enviarDocumento.felCabezaDocumento.listaDetalle[i].unidadmedida CLIPPED 
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].cantidad=rec_detalle.cantidad
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].valorunitario=rec_detalle.valoruni
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].preciosinimpuestos=rec_detalle.cantidad*rec_detalle.valoruni
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].preciototal=rec_detalle.cantidad*rec_detalle.valoruni
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].tipoImpuesto=3
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].muestracomercial=0
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].muestracomercialcodigo=0
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].posicion=i
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].tamanio=1.00
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].valorUnitarioPorCantidad=rec_detalle.valoruni
    LET enviarDocumento.felCabezaDocumento.listaCamposAdicionales[1].nombreCampo="PERIODO_FACTURACION"
    LET enviarDocumento.felCabezaDocumento.listaCamposAdicionales[1].valorCampo=1
    LET enviarDocumento.felCabezaDocumento.listaCamposAdicionales[1].fecha=wfechafac
    LET enviarDocumento.felCabezaDocumento.listaCamposAdicionales[1].orden=1
    LET enviarDocumento.felCabezaDocumento.listaCamposAdicionales[1].seccion=1
END FOREACH 

INITIALIZE rec_tercero.* TO NULL 

SELECT fc_terceros.* INTO rec_tercero.* FROM fc_terceros
WHERE nit=rec_maestro.nit

LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].tipoPersona= rec_tercero.tipo_persona
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].nombreCompleto=rec_tercero.primer_nombre clipped," ",rec_tercero.segundo_nombre CLIPPED," ",rec_tercero.primer_apellido CLIPPED," ",rec_tercero.segundo_apellido CLIPPED
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].tipoIdentificacion="31"--rec_tercero.tipid
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].digitoverificacion=rec_tercero.digver
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].numeroIdentificacion=rec_tercero.nit CLIPPED
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].pais=rec_tercero.pais CLIPPED 
SELECT nombrepais INTO  enviarDocumento.felCabezaDocumento.listaAdquirentes[1].paisnombre FROM fe_paises
WHERE codpais= enviarDocumento.felCabezaDocumento.listaAdquirentes[1].pais 
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].departamento=rec_tercero.zona[1,2]
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].codigoCiudad=rec_tercero.zona CLIPPED
LET enviarDocumento.felCabezaDocumento.listaAdquirentes[1].ciudad =rec_tercero.zona CLIPPED 
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


LET enviarDocumento.felCabezaDocumento.pago.moneda=rec_total.moneda CLIPPED
LET enviarDocumento.felCabezaDocumento.pago.totalimportebruto=rec_total.importebruto
LET enviarDocumento.felCabezaDocumento.pago.totalbaseimponible=rec_total.baseimponible
LET enviarDocumento.felCabezaDocumento.pago.totalbaseconimpuestos=rec_total.baseconimpu
LET enviarDocumento.felCabezaDocumento.pago.totalfactura=rec_total.total_factura
LET enviarDocumento.felCabezaDocumento.pago.tipocompra=rec_maestro.forma_pago
IF enviarDocumento.felCabezaDocumento.pago.tipocompra = "2" THEN
    LET enviarDocumento.felCabezaDocumento.pago.fechavencimiento=rec_maestro.fecha_vencimiento
END IF   
LET enviarDocumento.felCabezaDocumento.pago.codigoMonedaCambio="COP"
LET enviarDocumento.felCabezaDocumento.tipoOperacion=rec_maestro.tipoope

CALL enviarDocumento_g() RETURNING wsstatus

CALL fgl_winmessage ("Administrador",wsstatus,"information")
END FUNCTION

FUNCTION enviar_documento_soporte_prueba(prefijo,tipodoc, documento,consecutivo)
DEFINE prefijo LIKE fc_factura_m.prefijo
DEFINE tipodoc CHAR(1)
DEFINE documento LIKE fc_factura_m.documento
DEFINE wsstatus,i,cnt,contadorMensajes INTEGER
DEFINE consecutivo INTEGER 

LET ls_salida =""
 OPEN WINDOW w_vista WITH FORM "Vista" DIALOG ATTRIBUTES(UNBUFFERED)
    INPUT tipodoc,prefijo,consecutivo,ls_salida
     FROM  txt_tipodoc,txt_prefijo,txt_folio_manual,txt_salida
     ATTRIBUTES( WITHOUT DEFAULTS) 
     END INPUT
  BEFORE  DIALOG
   LET cbtipd = ui.ComboBox.forName("txt_tipodoc")
   CALL cbtipd.clear()
   CALL cbtipd.addItem("7","DOCUMENTO SOPORTE")
   CALL cbtipd.addItem("10","NOTA AJUSTE")
  -- DISPLAY consecutivo TO txt_folio_manual

LET wcantidad=0

INITIALIZE rec_maestro.* TO NULL 
INITIALIZE rec_detalle.* TO NULL 
INITIALIZE rec_total.* TO NULL 
INITIALIZE rec_servicio.* TO null

SELECT fc_factura_m.*, fc_factura_tot.* 
INTO rec_maestro.*, rec_total.* 
FROM fc_factura_m, fc_factura_tot
WHERE fc_factura_m.prefijo = fc_factura_tot.prefijo
AND fc_factura_m.documento= fc_factura_tot.documento
AND fc_factura_m.prefijo=prefijo
AND fc_factura_m.documento=documento

LET wfechafac=CURRENT YEAR TO SECOND 

INITIALIZE enviarDocumento.* TO NULL 

SELECT COUNT(*) INTO wcantidad FROM fc_factura_d
WHERE fc_factura_d.prefijo=prefijo
AND fc_factura_d.documento=documento

EXECUTE IMMEDIATE "set encryption password ""0r13nt3"""
   select fe_dispapeles_acceso.idEmpresa
       ,""
       ,fe_dispapeles_acceso.usuario
       ,decrypt_char(fe_dispapeles_acceso.contrasena) as contrasena
       ,decrypt_char(fe_dispapeles_acceso.token) as token
       ,fe_dispapeles_acceso.version
   INTO idEmpresa,idErp,usuario,contrasena,token,version
   from fe_dispapeles_acceso

LET enviarDocumento.felCabezaDocumento.idEmpresa=idEmpresa--488
LET enviarDocumento.felCabezaDocumento.usuario=usuario--"EmpCOMFAORIENTE"
LET enviarDocumento.felCabezaDocumento.contrasenia=contrasena--"Pwc0mf40r1ent3"
LET enviarDocumento.felCabezaDocumento.token=token--"eaab450239c82b4efb6a0a894583d7aa5ffe886c"
LET enviarDocumento.felCabezaDocumento.version="14"
LET enviarDocumento.felCabezaDocumento.tipodocumento=tipodoc
LET enviarDocumento.felCabezaDocumento.prefijo=prefijo CLIPPED 
LET enviarDocumento.felCabezaDocumento.consecutivo=consecutivo
LET enviarDocumento.felCabezaDocumento.fechafacturacion=wfechafac
LET enviarDocumento.felCabezaDocumento.codigoPlantillaPdf=14
LET enviarDocumento.felCabezaDocumento.cantidadLineas=wcantidad
LET enviarDocumento.felCabezaDocumento.tiponota="0"
LET enviarDocumento.felCabezaDocumento.aplicafel="NO"
LET enviarDocumento.felCabezaDocumento.listaMediosPagos[1].medioPago=rec_maestro.medio_pago

DECLARE det2 CURSOR FOR
SELECT * FROM fc_factura_d
WHERE fc_factura_d.prefijo = prefijo
AND fc_factura_d.documento = documento
INITIALIZE rec_detalle.* TO NULL 
LET i=1

FOREACH det2 INTO rec_detalle.*
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].codigoproducto=rec_detalle.codigo
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].tipocodigoproducto="999"
    SELECT descripcion,coduni,tpimpuesto INTO  enviarDocumento.felCabezaDocumento.listaDetalle[i].nombreProducto,
    enviarDocumento.felCabezaDocumento.listaDetalle[i].unidadmedida,
    enviarDocumento.felCabezaDocumento.listaDetalle[i].tipoImpuesto
    FROM fc_servicios
    WHERE codigo=rec_detalle.codigo
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].nombreProducto=enviarDocumento.felCabezaDocumento.listaDetalle[i].nombreProducto CLIPPED 
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].nombreProducto= enviarDocumento.felCabezaDocumento.listaDetalle[i].nombreProducto CLIPPED 
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].unidadmedida=enviarDocumento.felCabezaDocumento.listaDetalle[i].unidadmedida CLIPPED
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].tipoImpuesto=enviarDocumento.felCabezaDocumento.listaDetalle[i].tipoImpuesto CLIPPED 
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].cantidad=rec_detalle.cantidad
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].valorunitario=rec_detalle.valoruni
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].preciosinimpuestos=rec_detalle.cantidad*rec_detalle.valoruni
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].preciototal=rec_detalle.cantidad*rec_detalle.valoruni
    --LET enviarDocumento.felCabezaDocumento.listaDetalle[i].tipoImpuesto=3
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].muestracomercial=0
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].muestracomercialcodigo=0
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].posicion=i
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].tamanio=1.00
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].valorUnitarioPorCantidad=rec_detalle.valoruni
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].listaCamposAdicionales[1].nombreCampo="PERIODO_FACTURACION"
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].listaCamposAdicionales[1].fecha=wfechafac
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].listaCamposAdicionales[1].valorCampo=1
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].listaCamposAdicionales[1].orden=0
    LET enviarDocumento.felCabezaDocumento.listaDetalle[i].listaCamposAdicionales[1].seccion=0
    LET i=i+1
END FOREACH 

LET enviarDocumento.felCabezaDocumento.listaCamposAdicionales[1].fecha=NULL
LET enviarDocumento.felCabezaDocumento.listaCamposAdicionales[1].nombreCampo="observaciones"
LET enviarDocumento.felCabezaDocumento.listaCamposAdicionales[1].orden=1
LET enviarDocumento.felCabezaDocumento.listaCamposAdicionales[1].seccion=0
LET enviarDocumento.felCabezaDocumento.listaCamposAdicionales[1].valorCampo=rec_maestro.nota1 CLIPPED 


INITIALIZE rec_tercero.* TO NULL 

SELECT fc_terceros.* INTO rec_tercero.* FROM fc_terceros
WHERE nit=rec_maestro.nit

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



LET enviarDocumento.felCabezaDocumento.pago.moneda=rec_total.moneda CLIPPED
LET enviarDocumento.felCabezaDocumento.pago.totalimportebruto=rec_total.importebruto
LET enviarDocumento.felCabezaDocumento.pago.totalbaseimponible=0 --rec_total.baseimponible
LET enviarDocumento.felCabezaDocumento.pago.totalbaseconimpuestos=rec_total.baseconimpu
LET enviarDocumento.felCabezaDocumento.pago.totalfactura=rec_total.total_factura
LET enviarDocumento.felCabezaDocumento.pago.tipocompra=rec_maestro.forma_pago
LET enviarDocumento.felCabezaDocumento.pago.codigoMonedaCambio="COP"
LET enviarDocumento.felCabezaDocumento.tipoOperacion=rec_maestro.tipoope
IF rec_maestro.forma_pago = "2" THEN 
    LET enviarDocumento.felCabezaDocumento.pago.fechavencimiento=rec_maestro.fecha_vencimiento
END IF 

CASE
    WHEN tipodoc = "7" OR tipodoc = "10" 
      CALL enviarDocumento_g() RETURNING wsstatus
END CASE
  LET ls_salida = ls_salida,"\n+++++++++++++++++++++Consulta Método Respuesta Envio +++++++++++++++++++++"
   CALL ui.Interface.refresh()
    LET ls_salida = ls_salida,"\nRespuesta Protocolo: "
    LET ls_salida = ls_salida,sqlca.sqlerrm
    LET ls_salida = ls_salida,"\nRespuesta Proceso: "
    LET ls_salida = ls_salida, enviarDocumentoResponse.return.estadoProceso CLIPPED, "-",  enviarDocumentoResponse.return.descripcionProceso
    IF wsError.description IS NOT NULL then
        LET ls_salida = ls_salida,"\nError de web service: ",wsError.description
    END IF 
    --IF cufe IS NOT NULL THEN
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
     --END if 
     IF tipodoc = "7" THEN--1
        LET mtime=TIME
        IF enviarDocumentoResponse.return.estadoProceso = "1" OR enviarDocumentoResponse.return.estadoProceso = "2" 
        OR enviarDocumentoResponse.return.estadoProceso = "3" THEN --2
            IF enviarDocumentoResponse.return.cufe IS NOT NULL THEN--3
                UPDATE fc_factura_m SET cufe = enviarDocumentoResponse.return.cufe,
                fecha_factura=enviarDocumentoResponse.return.fechaFactura,
                estado="P", fecest=enviarDocumentoResponse.return.fechaRespuesta,
                codest = enviarDocumentoResponse.return.estadoProceso, hora=mtime,
                numfac = enviarDocumentoResponse.return.consecutivo,
                tipodocumento=enviarDocumentoResponse.return.tipoDocumento
                WHERE fc_factura_m.prefijo=rec_maestro.prefijo
                AND fc_factura_m.documento=rec_maestro.documento
                
                IF sqlca.sqlcode = 0 THEN--4
                    display  "OK"
                ELSE
                    display "Ocurrió un error al conectar a la Base de Datos " , STATUS ,
                 "\n" , SQLERRMESSAGE
                END IF--4
            END IF --3
        END IF --2
    
    END IF 
     
      FOR contadorMensajes = 1 TO enviarDocumentoResponse.return.listaMensajesProceso.getLength()
           
                LET ls_salida = ls_salida,"\nMensaje: "
                LET ls_salida = ls_salida,enviarDocumentoResponse.return.listaMensajesProceso[contadorMensajes].descripcionMensaje
                LET ls_salida = ls_salida,"\nNotificacion Rechazo: "
                LET ls_salida = ls_salida,enviarDocumentoResponse.return.listaMensajesProceso[contadorMensajes].rechazoNotificacion
                IF wsError.description IS NOT NULL THEN
                    LET ls_salida = ls_salida,"\nError de web service: "
                    LET ls_salida = ls_salida, wsError.description
                END IF 
                CALL ui.Interface.refresh()
     END FOR
     
        ON ACTION bt_cerrar
            EXIT DIALOG
    END DIALOG
    CLOSE WINDOW w_vista


END FUNCTION

FUNCTION consultar_estado_documento_soporte()
EXECUTE IMMEDIATE "set encryption password ""0r13nt3"""
   select fe_dispapeles_acceso.idEmpresa
       ,""
       ,fe_dispapeles_acceso.usuario
       ,decrypt_char(fe_dispapeles_acceso.contrasena) as contrasena
       ,decrypt_char(fe_dispapeles_acceso.token) as token
       ,fe_dispapeles_acceso.version
   INTO idEmpresa,idErp,usuario,contrasena,token,version
   from fe_dispapeles_acceso


END FUNCTION 

FUNCTION consulta_estados_factu(tipo_doc)
 DEFINE mpref       LIKE   fc_factura_m.prefijo
 DEFINE mnumfactu   LIKE   fc_factura_m.numfac
 DEFINE tipo_doc LIKE fc_factura_m.tipodocumento
 
  LET mpref = NULL 
  LET mnumfactu = 0
  PROMPT "Prefijo  ===> : "    FOR mpref
  LET mpref = upshift(mpref) 
  IF mpref IS NULL THEN 
    RETURN
  END IF
  PROMPT "Numero de factura  :  "   FOR mnumfactu
  IF mnumfactu IS NULL OR mnumfactu = 0 THEN
    RETURN
   END IF
  INITIALIZE mfc_factura_m.* TO NULL
  SELECT * INTO mfc_factura_m.*
    FROM fc_factura_m
  WHERE prefijo = mpref
   AND numfac = mnumfactu
  IF mfc_factura_m.numfac IS NULL THEN
    CALL FGL_WINMESSAGE( "Mensaje de error ", "El numero de factura no fue encontrada","stop")
    RETURN
  END IF
  IF mfc_factura_m.estado = "B"  THEN
    CALL FGL_WINMESSAGE( "Información", "La factura no ha sido trasmitida","information")
    RETURN
  END IF
  CALL consulta_estado_documento(tipo_doc,mfc_factura_m.prefijo, mnumfactu)
END FUNCTION

FUNCTION consulta_estados_nota(tipo_doc)
 DEFINE mpref       LIKE   fc_factura_m.prefijo
 DEFINE mnumfactu   LIKE   fc_factura_m.numfac
 DEFINE tipo_doc CHAR(2)
 
  LET mpref = NULL 
  LET mnumfactu = 0
  LET mpref="DSNC"
  PROMPT "Numero de Nota de Ajuste  :  "   FOR mnumfactu
  IF mnumfactu IS NULL OR mnumfactu = 0 THEN
    RETURN
   END IF
 { INITIALIZE mfc_factura_m.* TO NULL
  SELECT * INTO mfc_factura_m.*
    FROM fc_factura_m
  WHERE prefijo = mpref
   AND numfac = mnumfactu
  IF mfc_factura_m.numfac IS NULL THEN
    CALL FGL_WINMESSAGE( "Mensaje de error ", "El numero de factura no fue encontrada","stop")
    RETURN
  END IF
  IF mfc_factura_m.estado = "B"  THEN
    CALL FGL_WINMESSAGE( "Información", "La factura no ha sido trasmitida","information")
    RETURN
  END IF}
  LET tipo_doc ="10"
  CALL consulta_estado_documento(tipo_doc,mpref, mnumfactu)
END FUNCTION

FUNCTION consulta_estado_documento(tipodoc, prefijo, numfac)
  DEFINE tipodoc, tipodocumento CHAR(2)
  DEFINE prefijo, prefijo_factu CHAR(4)
  DEFINE numfac,numfactura,wsstatus  INTEGER
  DEFINE mfecha_eje DATE
  DEFINE mhora_eje  CHAR(10)
  DEFINE indice INTEGER 
  LET ls_salida ="" 
  EXECUTE IMMEDIATE "set encryption password ""0r13nt3"""
   select fe_dispapeles_acceso.idEmpresa
       ,""
       ,fe_dispapeles_acceso.usuario
       ,decrypt_char(fe_dispapeles_acceso.contrasena) as contrasena
       ,decrypt_char(fe_dispapeles_acceso.token) as token
       ,fe_dispapeles_acceso.version
   INTO idEmpresa,idErp,usuario,contrasena,token,version
   from fe_dispapeles_acceso
  LET tipodocumento = tipodoc
  LET prefijo_factu = prefijo
  LET numfactura= numfac
  LET ls_salida ="" 
  OPEN WINDOW w_vista WITH FORM "Vista"
  DIALOG ATTRIBUTES(UNBUFFERED)
    INPUT ls_salida, tipodoc, prefijo, numfac
     FROM  txt_salida,txt_tipodoc,txt_prefijo, txt_folio_manual
     ATTRIBUTES (WITHOUT DEFAULTS)
     END INPUT 
  BEFORE DIALOG 
   LET cbtipd = ui.ComboBox.forName("txt_tipodoc")
   CALL cbtipd.clear()
   CALL cbtipd.addItem("7","DOCUMENTO SOPORTE")
   CALL cbtipd.addItem("10","NOTA AJUSTE DOCUMENTO SOPORTE")

   
   LET ls_salida = ls_salida,"\n----------------------------Consultar Estado Documento -----------------------------------------"

   LET consultarEstado.felConsultaFactura.consecutivo=numfactura
   LET consultarEstado.felConsultaFactura.contrasenia=contrasena
   LET consultarEstado.felConsultaFactura.idEmpresa=idEmpresa
   LET consultarEstado.felConsultaFactura.prefijo=prefijo_factu CLIPPED
   LET consultarEstado.felConsultaFactura.tipoDocumento=tipodocumento CLIPPED 
   LET consultarEstado.felConsultaFactura.token=token
   LET consultarEstado.felConsultaFactura.version="14"
   LET consultarEstado.felConsultaFactura.usuario=usuario
  
  --Recupera el resultado de la consulta del Estado de la factura
    CALL consultarEstado_g() RETURNING wsstatus
    
    LET ls_salida = ls_salida,"\nMensaje de error: ",sqlca.sqlerrm
    LET ls_salida = ls_salida,"\ncodigoQR      = ", consultarEstadoResponse.return.codigoQr
    LET ls_salida = ls_salida,"\nEstadoProceso       = ",consultarEstadoResponse.return.estadoProceso
    LET ls_salida = ls_salida,"\nDescripcion_Ultimo_Estado_Dian       = ",consultarEstadoResponse.return.descripcionUltimoEstadoDian
    LET ls_salida = ls_salida,"\ndescripcion_Ultimo_Estado_Adquirente = ",consultarEstadoResponse.return.descripcionUltimoEstadoAdquirente
    LET mfecha_eje = TODAY
    -- Se consultan todos los mensajes asociados a la respuesta al consumo del método "consultarEstado"
    {FOR indice = 1 TO consultarEstadoResponse.return.listaMensajesProceso.getLength()
      LET mhora_eje = TIME 
      
         --LET ls_salida = ls_salida,"\nMensaje = ",descripcionMensaje
      END FOR}
    IF consultarEstadoResponse.return.fechaRespuesta IS NOT NULL AND consultarEstadoResponse.return.consecutivo IS NOT NULL THEN
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
        VALUES (consultarEstadoResponse.return.tipoDocumento, consultarEstadoResponse.return.prefijo, 
        consultarEstadoResponse.return.consecutivo, consultarEstadoResponse.return.fechaFactura, 
        consultarEstadoResponse.return.cufe, consultarEstadoResponse.return.codigoUltimoEstadoDispapeles,
        consultarEstadoResponse.return.descripcionUltimoEstadoDispapeles, consultarEstadoResponse.return.fechaRespuestaUltimoEstadoDispapeles, 
        consultarEstadoResponse.return.codigoUltimoEstadoDian, consultarEstadoResponse.return.descripcionUltimoEstadoDian,
        consultarEstadoResponse.return.fechaRespuestaUltimoEstadoDian, consultarEstadoResponse.return.codigoUltimoEstadoEmail, 
        consultarEstadoResponse.return.descripcionUltimoEstadoEmail,consultarEstadoResponse.return.fechaRespuestaUltimoEstadoEmail,                     
        consultarEstadoResponse.return.codigoUltimoEstadoAdquirente, consultarEstadoResponse.return.descripcionUltimoEstadoAdquirente, 
        consultarEstadoResponse.return.fechaRespuestaUltimoEstadoAdquirente,  
        consultarEstadoResponse.return.estadoProceso, consultarEstadoResponse.return.fechaRespuesta, consultarEstadoResponse.return.fechaFactura)
      ELSE    
       UPDATE fc_estados_fac
       SET (cufe, codult_estdisp, des_ult_estdisp,fecres_ultestdisp, cod_ult_estdian, des_ult_estdian, fecres_ultestdian, cod_ult_estmail,
        des_ult_estmail, fecres_ultestmail, cod_ult_estadq, des_ult_estadq, fecres_ultestadq, 
        codest,fecest, fecrep  )
        = ( consultarEstadoResponse.return.cufe, consultarEstadoResponse.return.codigoUltimoEstadoDispapeles,
         consultarEstadoResponse.return.descripcionUltimoEstadoDispapeles, consultarEstadoResponse.return.fechaRespuestaUltimoEstadoDispapeles, 
         consultarEstadoResponse.return.codigoUltimoEstadoDian, consultarEstadoResponse.return.descripcionUltimoEstadoDian, consultarEstadoResponse.return.fechaRespuestaUltimoEstadoDian, 
         consultarEstadoResponse.return.codigoUltimoEstadoEmail, consultarEstadoResponse.return.descripcionUltimoEstadoEmail,consultarEstadoResponse.return.fechaRespuestaUltimoEstadoEmail,                     
         consultarEstadoResponse.return.codigoUltimoEstadoAdquirente, consultarEstadoResponse.return.descripcionUltimoEstadoAdquirente, consultarEstadoResponse.return.fechaRespuestaUltimoEstadoAdquirente,  
         consultarEstadoResponse.return.estadoProceso, consultarEstadoResponse.return.fechaRespuesta, consultarEstadoResponse.return.fechaFactura)
        WHERE fc_estados_fac.tpdocumento = consultarEstadoResponse.return.tipoDocumento
         AND  fc_estados_fac.prefijo = consultarEstadoResponse.return.prefijo
         AND  fc_estados_fac.numfac = consultarEstadoResponse.return.consecutivo
      END if  
      IF consultarEstadoResponse.return.estadoProceso= "1"  AND consultarEstadoResponse.return.cufe IS NOT null THEN   -- EXITOSO
         CASE 
          WHEN tipodoc = "7"   
           UPDATE fc_factura_m
           SET  cufe = consultarEstadoResponse.return.cufe, estado ="P", fecest = consultarEstadoResponse.return.fechaRespuesta,  codest = consultarEstadoResponse.return.estadoProceso    
           WHERE fc_factura_m.prefijo = consultarEstadoResponse.return.prefijo
           AND fc_factura_m.numfac = consultarEstadoResponse.return.consecutivo
           AND fc_factura_m.estado <> "N"
          WHEN tipodoc = "10"  
           UPDATE fc_nota_ajuste
            SET estado ="P", fecest = consultarEstadoResponse.return.fechaRespuesta, codest = consultarEstadoResponse.return.estadoProceso,
                cuds = consultarEstadoResponse.return.cufe
            WHERE fc_nota_ajuste.numerona = consultarEstadoResponse.return.consecutivo
           AND fc_nota_ajuste.estado <> "N"
        END CASE
      END IF
      IF consultarEstadoResponse.return.codigoUltimoEstadoAdquirente = "3"  THEN     -- RECHAZADA CLIENTE
         CASE 
          WHEN tipodoc = "7"   
           UPDATE fc_factura_m
           SET  estado ="R", fecest = DATE(consultarEstadoResponse.return.fechaRespuestaUltimoEstadoAdquirente), codest = consultarEstadoResponse.return.codigoUltimoEstadoAdquirente    
           WHERE fc_factura_m.prefijo = consultarEstadoResponse.return.prefijo
           AND fc_factura_m.numfac = consultarEstadoResponse.return.consecutivo
           WHEN consultarEstadoResponse.return.tipoDocumento = "10"   
           UPDATE fc_nota_ajuste
            SET estado ="R", fecest = DATE(consultarEstadoResponse.return.fechaRespuestaUltimoEstadoAdquirente),  codest = consultarEstadoResponse.return.codigoUltimoEstadoAdquirente  
            WHERE fc_nota_ajuste.numerona = consultarEstadoResponse.return.consecutivo
        END CASE
      END IF
     IF consultarEstadoResponse.return.codigoUltimoEstadoDispapeles = "19" THEN      -- RECHAZADA X DISPAPELES
        CASE 
          WHEN tipodoc = "7"   
           UPDATE fc_factura_m
           SET  estado ="X", fecest = DATE(consultarEstadoResponse.return.fechaRespuestaUltimoEstadoDispapeles),  codest = consultarEstadoResponse.return.codigoUltimoEstadoDispapeles    
           WHERE fc_factura_m.prefijo = consultarEstadoResponse.return.prefijo
           AND fc_factura_m.numfac = consultarEstadoResponse.return.consecutivo
          WHEN tipodoc = "10"  
           UPDATE fc_nota_ajuste
            SET estado ="X", fecest =  DATE(consultarEstadoResponse.return.fechaRespuestaUltimoEstadoDispapeles), codest = consultarEstadoResponse.return.codigoUltimoEstadoDispapeles
            WHERE fc_nota_ajuste.numerona = consultarEstadoResponse.return.consecutivo
         END CASE
      END IF  
      IF  consultarEstadoResponse.return.codigoUltimoEstadoDian = "4" THEN      -- RECHAZADA X LA DIAN
        CASE 
          WHEN tipodoc = "7"   
           UPDATE fc_factura_m
           SET  estado ="D", fecest =  DATE(consultarEstadoResponse.return.fechaRespuestaUltimoEstadoDian),  codest = consultarEstadoResponse.return.codigoUltimoEstadoDian    
           WHERE fc_factura_m.prefijo = consultarEstadoResponse.return.prefijo
           AND fc_factura_m.numfac = consultarEstadoResponse.return.consecutivo
          WHEN consultarEstadoResponse.return.tipoDocumento = "10"
           UPDATE fc_nota_ajuste
            SET estado ="D", fecest =  DATE(consultarEstadoResponse.return.fechaRespuestaUltimoEstadoDian), codest =  consultarEstadoResponse.return.codigoUltimoEstadoDian
            WHERE fc_nota_ajuste.numerona = consultarEstadoResponse.return.consecutivo
         END CASE
      END IF  
    END IF  
    DISPLAY ls_salida
    ON ACTION bt_cerrar
        EXIT DIALOG
    END DIALOG
    CLOSE WINDOW w_vista
END FUNCTION

FUNCTION generar_pdf_factu()
 DEFINE mpref       LIKE   fe_factura_m.prefijo
 DEFINE mnumfactu   LIKE   fe_factura_m.numfac
  LET mpref = NULL 
  LET mnumfactu = 0
  PROMPT "Prefijo  ===> : "    FOR mpref
  LET mpref = upshift(mpref) 
  IF mpref IS NULL THEN 
    RETURN
  END IF
  PROMPT "Numero de factura  :  "   FOR mnumfactu
  IF mnumfactu IS NULL OR mnumfactu = 0 THEN
    RETURN
   END IF
  INITIALIZE mfc_factura_m.* TO NULL
  SELECT * INTO mfc_factura_m.*
    FROM fc_factura_m
  WHERE prefijo = mpref
   AND numfac = mnumfactu
  IF mfc_factura_m.numfac IS NULL THEN
    CALL FGL_WINMESSAGE( "Mensaje de error ", "El numero de documento soporte no fue encontrado","stop")
    RETURN
  END IF
  IF mfc_factura_m.estado = "B"  THEN
    CALL FGL_WINMESSAGE( "Información", "El Documento Soporte no ha sido trasmitida","information")
    RETURN
  END IF
  CALL descarga_documento("7",mfc_factura_m.prefijo, mnumfactu)
END FUNCTION

FUNCTION descarga_documento(tipodoc, prefijo, numfac)
  DEFINE tipodoc CHAR(2)
  DEFINE prefijo CHAR(4)
  DEFINE numfac, wsstatus,indice INTEGER
  DEFINE resope INTEGER
  DEFINE mfecha_eje DATE
  DEFINE mhora_eje  CHAR(10)
  ,codigoMensaje VARCHAR(50)
  ,descripcionMensaje VARCHAR(240)
  ,rechazoNotificacion VARCHAR(2)
 CASE
  WHEN tipodoc = "7"
    LET newnamefile = fgl_getenv("HOME"),"/",mprefijo CLIPPED, "/",
       prefijo CLIPPED, numfac USING "&&&&&&&"
  WHEN tipodoc = "10"  
    LET newnamefile = fgl_getenv("HOME"),"/NOTAC/NC", mnumfac USING "&&&&&&&"
  END CASE
  --LET ruta_descarga = "C:\\FacturasEscenarios\\Archivos\\"
  LET ruta_descarga = "/home/documento_soporte/"
  EXECUTE IMMEDIATE "set encryption password ""0r13nt3"""
   select fe_dispapeles_acceso.idEmpresa
       ,""
       ,fe_dispapeles_acceso.usuario
       ,decrypt_char(fe_dispapeles_acceso.contrasena) as contrasena
       ,decrypt_char(fe_dispapeles_acceso.token) as token
       ,fe_dispapeles_acceso.version
   INTO idEmpresa,idErp,usuario,contrasena,token,version
   from fe_dispapeles_acceso
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
   CALL cbtipd.addItem("10","NOTA DE AJUSTE")
   
  IF tipodoc = "7" THEN
   LET ls_salida = ls_salida,"\n+++++++++++++++++++++Descarga PDF Documento Soporte +++++++++++++++++++++"
  ELSE
   LET ls_salida = ls_salida,"\n+++++++++++++++++++++Descarga PDF Nota  +++++++++++++++++++++"
  END IF 
  CALL ui.Interface.refresh()
  --Inicializa la información para llevar a cabo la consulta de archivos

    LET consultarArchivos.Fel_ConsultaFacturaArchivo.consecutivo= numfac
    LET consultarArchivos.Fel_ConsultaFacturaArchivo.contrasenia=contrasena--"Pwc0mf40r1ent3"
    LET consultarArchivos.Fel_ConsultaFacturaArchivo.idEmpresa=idEmpresa
    LET consultarArchivos.Fel_ConsultaFacturaArchivo.prefijo=prefijo CLIPPED 
    LET consultarArchivos.Fel_ConsultaFacturaArchivo.tipoArchivo=1
    LET consultarArchivos.Fel_ConsultaFacturaArchivo.tipoDocumento=tipodoc clipped
    LET consultarArchivos.Fel_ConsultaFacturaArchivo.token=token--"eaab450239c82b4efb6a0a894583d7aa5ffe886c"
    LET consultarArchivos.Fel_ConsultaFacturaArchivo.usuario=usuario--"EmpCOMFAORIENTE"
    LET consultarArchivos.Fel_ConsultaFacturaArchivo.version="14"

    CALL consultarArchivos_g() RETURNING wsstatus
    LET ls_salida = ls_salida, "\nCódigo de error       = "
    IF NOT SQLCA.sqlerrm IS NULL THEN
        LET ls_salida = ls_salida||SQLCA.sqlerrm
    END IF
    LET ls_salida = ls_salida,"\nCodigo Respuesta      = "
    IF NOT SQLCA.sqlerrm IS NULL THEN
      LET ls_salida = ls_salida||consultarArchivosResponse.return.codigoRespuesta
    END IF
    LET ls_salida = ls_salida,"\nDescripción respuesta = "
    IF NOT SQLCA.sqlerrm IS NULL THEN
       LET ls_salida = ls_salida, consultarArchivosResponse.return.descripcionRespuesta  --descripcionRespuesta
    END IF
    --Recupera todos los mensajes resultantes de la consulta
    FOR indice = 1 TO f_RespuestaTamanoConsultarArchivos_listaMensajes_Recupera()
      CALL f_RespuestaMensajesProcesoArchivo_Recupera(indice)
        RETURNING codigoMensaje
            , descripcionMensaje
            , rechazoNotificacion
        LET ls_salida = ls_salida,"\nMensaje: ",codigoMensaje," - ", descripcionMensaje
     END FOR
     --Guarda todos los archivos resultantes de la consulta
      CALL f_ConsultarArchivos_Guardar(ruta_descarga)
     --Recupera todos los archivos resultantes de la consulta
      FOR indice = 1 TO consultarArchivosResponse.return.listaArchivos.getLength()--Enlace_Archivo_bbl.f_RespuestaTamanoConsultarArchivos_listaArchivos_Recupera()
          LET ls_salida = ls_salida,"\nArchivo = "
          LET ls_salida = ls_salida,consultarArchivosResponse.return.listaArchivos[indice].nameFile
          LET ls_salida = ls_salida,"\nRuta Descarga = ", ruta_descarga CLIPPED, consultarArchivosResponse.return.listaArchivos[indice].nameFile
          CALL ui.Interface.refresh()
          CALL FGL_PUTFILE(ruta_descarga||consultarArchivosResponse.return.listaArchivos[indice].nameFile ,prefijo||"-"||numfac||"."||consultarArchivosResponse.return.listaArchivos[indice].formato)
      END FOR
   ON ACTION bt_cerrar
        EXIT DIALOG
    END DIALOG
    CLOSE WINDOW w_vista
END FUNCTION

FUNCTION f_ConsultarArchivos_Guardar(Ruta)
DEFINE Ruta STRING
   , indice      INTEGER
   
   FOR indice = 1 TO f_RespuestaTamanoConsultarArchivos_listaArchivos_Recupera()
      CALL security.Base64.SaveBinary(Ruta||consultarArchivosResponse.return.listaArchivos[indice].nameFile,
      consultarArchivosResponse.return.listaArchivos[indice].streamFile)
   END FOR
END FUNCTION

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

FUNCTION f_RespuestaTamanoConsultarArchivos_listaArchivos_Recupera()
DEFINE
     tamano      INTEGER
   
   --Inicialización de variables
   LET tamano = consultarArchivosResponse.return.listaArchivos.getLength()

   RETURN tamano

END FUNCTION

FUNCTION f_RespuestaTamanoConsultarArchivos_listaMensajes_Recupera()
DEFINE
     tamano      INTEGER
   
   --Inicialización de variables
   LET tamano = consultarArchivosResponse.return.listaMensajesProceso.getLength()

   RETURN tamano

END FUNCTION

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

FUNCTION enviar_factura_dian()
 DEFINE mpref       LIKE   fe_factura_m.prefijo
 DEFINE mnumfactu  INTEGER
 DEFINE mtipdoc     INTEGER
 DEFINE documento LIKE fc_factura_m.documento
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
    CALL FGL_WINMESSAGE( "Mensaje de error ", "El numero de factura no fue encontrada","stop")
    RETURN
  END IF
  
  SELECT fc_factura_m.documento INTO documento FROM fc_factura_m
  WHERE prefijo=mpref AND numfac=mnumfactu 

  LET mtipdoc = 0
  LET cnt = 0
  IF mfc_factura_m.estado <> "A" AND mfc_factura_m.estado <> "S" AND mfc_factura_m.estado <> "G" THEN
    CALL FGL_WINMESSAGE( "Mensaje de error ", "La factura no esta en un estado valido para ser transmitida","stop")
    RETURN
  END IF
  CALL enviar_documento_soporte_prueba(mpref,"7",documento,mnumfactu) --AQUI VA EL ENVIO
END FUNCTION


