-- Ejemplo ampliado con variables para observar la secuencia de ejecución de las funciones
IMPORT FGL Enlace_Doc_bbl
IMPORT FGL Enlace_Archivo_bbl

MAIN
    DISPLAY "+++++++++++++++++++++Inicia proceso+++++++++++++++++++++"
    CLOSE WINDOW SCREEN
    CONNECT TO "empresa"
    --CALL ui.Interface.loadActionDefaults("acciones_inv")
   -- OPTIONS INPUT WRAP
    
    CALL Ejemplo_Enlace_Con_BD()
    

    DISCONNECT CURRENT
    DISPLAY "+++++++++++++++++++++Termina proceso+++++++++++++++++++++"
END MAIN

FUNCTION Ejemplo_Enlace_Con_BD()
DEFINE 
     Envio_prefijo VARCHAR(5)
    ,Envio_consecutivo VARCHAR(16)
    --variables del encabezado
    ,aplicafel VARCHAR(2)
    ,cantidadLineas INTEGER
    ,centroCostos VARCHAR(100)
    ,codigoPlantillaPdf INTEGER
    ,codigovendedor VARCHAR(50)
    ,consecutivo BIGINT
    ,contrasenia VARCHAR(40)
    ,descripcionCentroCostos VARCHAR(240)
    ,fechafacturacion DATETIME YEAR TO FRACTION(5)
    ,idEmpresa BIGINT
    ,idErp VARCHAR(40)
    ,incoterm VARCHAR(3)
    ,nombrevendedor VARCHAR(50)
    ,prefijo VARCHAR(5)
    ,sucursal VARCHAR(50)
    ,tipoOperacion VARCHAR(2)
    ,tipodocumento VARCHAR(1)
    ,tiponota VARCHAR(2)
    ,token VARCHAR(40)
    ,usuario VARCHAR(40)
    ,version VARCHAR(40)
    -- variables del pago
    ,codigoMonedaCambio VARCHAR(3)
    ,fechaTasaCambio DATETIME YEAR TO FRACTION(5)
    ,fechavencimiento DATETIME YEAR TO FRACTION(5)
    ,moneda VARCHAR(3)
    ,pagoanticipado FLOAT
    ,periododepagoa INTEGER
    ,tipocompra INTEGER
    ,totalCargos FLOAT
    ,totalDescuento FLOAT
    ,totalbaseconimpuestos FLOAT
    ,totalbaseimponible FLOAT
    ,totalfactura FLOAT
    ,totalimportebruto FLOAT
    ,trm FLOAT
    ,trm_alterna FLOAT
    -- variables Adquirente
    ,barioLocalidad VARCHAR(50)
    ,ciudad VARCHAR(50)
    ,codigoCIUU VARCHAR(30)
    ,codigoPostal VARCHAR(6)
    ,departamento VARCHAR(50)
    ,descripcionCiudad VARCHAR(100)
    ,digitoverificacion VARCHAR(2)
    ,direccion VARCHAR(100)
    ,email VARCHAR(200)
    ,envioPorEmailPlataforma VARCHAR(10)
    ,matriculaMercantil VARCHAR(60)
    ,nitProveedorTecnologico VARCHAR(30)
    ,nombreCompleto VARCHAR(240)
    ,nombredepartamento VARCHAR(50)
    ,numeroIdentificacion VARCHAR(30)
    ,pais VARCHAR(2)
    ,paisnombre VARCHAR(30)
    ,regimen VARCHAR(240)
    ,telefono VARCHAR(50)
    ,tipoIdentificacion INTEGER
    ,tipoPersona VARCHAR(1)
    ,tipoobligacion VARCHAR(30)
    -- variables Medio de pago
    ,medioPago VARCHAR(2)
    -- variables del detalle
    ,aplicaMandato VARCHAR(2)
    ,campoAdicional1 STRING
    ,campoAdicional2 STRING
    ,campoAdicional3 STRING
    ,campoAdicional4 STRING
    ,campoAdicional5 STRING
    ,cantidad FLOAT
    ,codigoproducto VARCHAR(30)
    ,descripcion VARCHAR(240)
    ,familia VARCHAR(240)
    ,fechaSuscripcionContrato DATETIME YEAR TO FRACTION(5)
    ,gramaje VARCHAR(800)
    ,grupo VARCHAR(240)
    ,marca VARCHAR(240)
    ,modelo VARCHAR(240)
    ,muestracomercial INTEGER
    ,muestracomercialcodigo INTEGER
    ,nombreProducto VARCHAR(240)
    ,posicion INTEGER
    ,preciosinimpuestos FLOAT
    ,preciototal FLOAT
    ,referencia VARCHAR(100)
    ,seriales VARCHAR(800)
    ,tamanio FLOAT
    ,tipoImpuesto INTEGER
    ,tipocodigoproducto VARCHAR(30)
    ,unidadmedida VARCHAR(5)
    ,valorunitario FLOAT
    -- variables impuesto detalle
    ,baseimponible FLOAT
    ,codigoImpuestoRetencion VARCHAR(2)
    ,isAutoRetenido BOOLEAN
    ,porcentaje FLOAT
    ,valorImpuestoRetencion FLOAT
    -- variables descuento detalle
    ,codigoDescuento VARCHAR(2)
    ,descuento_descripcion VARCHAR(240)
    ,descuento FLOAT
    ,porcentajeDescuento FLOAT
    -- variables descuento detalle subsidio
    ,subsi_codigoDescuento VARCHAR(2)
    ,subsi_descuento_descripcion VARCHAR(240)
    ,subsi_descuento FLOAT
    ,subsi_porcentajeDescuento FLOAT
    -- variables respuesta de envio
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
    --, consecutivo          BIGINT
    , descripcionRespuesta VARCHAR(240)
    --, estadoProceso        INTEGER
    --, idErp                VARCHAR(240)
    --, prefijo              VARCHAR(5) 
    --, tipoDocumento        VARCHAR(1)

    -- variables de procedimiento
    ,contadorMensajes INTEGER
    ,consecutivo_de_prueba STRING
    ,Prefijo_de_prueba  STRING
    ,rel_documento STRING
    ,rel_NIT_completo STRING
    ,Suma_Cargos FLOAT
    ,Suma_Descuento FLOAT
    ,Suma_baseconimpuestos FLOAT
    ,Suma_baseimponible FLOAT
    ,Suma_factura FLOAT
    ,Suma_importebruto FLOAT
    ,Suma_valorImpuestoRetencion FLOAT
    ,codigoCiudad             VARCHAR(30)
    ,porcentajeParticipacion  FLOAT
    ,subtotal                 FLOAT
    ,valorEnLetrasSubTotal    VARCHAR(240)
    ,valorAdicional1          VARCHAR(240)
    ,valorAdicional2          VARCHAR(240)
    ,valorAdicional3          VARCHAR(240)
    ,valorAdicional4          VARCHAR(240)
    ,valorAdicional5          VARCHAR(240)
    ,valorEnLetras1           VARCHAR(240)
    ,valorEnLetras2           VARCHAR(240)
    ,valorEnLetras3           VARCHAR(240)
    ,valorEnLetras4           VARCHAR(240)
    ,valorEnLetras5           VARCHAR(240)
    ,redondeoTotalFactura     FLOAT
    ,nombreSector             VARCHAR(240)   --Nombre del sector de la empresa
    ,nombreImpresora          VARCHAR(240)
    ,valorUnitarioPorCantidad FLOAT

    DISPLAY "+++++++++++++++++++++Inicia obtencion de datos+++++++++++++++++++++"

    LET Suma_Cargos = 0
    LET Suma_Descuento = 0
    LET Suma_baseconimpuestos = 0
    LET Suma_baseimponible = 0
    LET Suma_factura = 0
    LET Suma_importebruto = 0
    LET Suma_valorImpuestoRetencion = 0

    
    
    --LET Envio_prefijo = 'AGE  '
    --LET Envio_consecutivo = '0000045'

    --LET Envio_prefijo = 'EDUC '
    --LET Envio_consecutivo = '0000703'

    LET Envio_prefijo = 'RECU '
    LET Envio_consecutivo = '3573'

    LET consecutivo_de_prueba = '52'--52
    LET Prefijo_de_prueba = 'SETT'


    LET contrasenia = "i98u7y6t"--Colocar la contraseña correcta
    LET idEmpresa = 488
    LET idErp = ""
    LET token = "eaab450239c82b4efb6a0a894583d7aa5ffe886c"
    LET usuario = "EmpCOMFAORIENTE"
    LET version = "11"

    LET prefijo = Envio_prefijo
    LET consecutivo = Envio_consecutivo
   
    SELECT
         fe_factura_m.documento --rel_documento
        ,fe_factura_m.NIT --rel_NIT_completo
        ,"SI" --aplicafel
        ,"" --centroCostos
        ,fe_prefijos.num_plantilla --codigoPlantillaPdf
        ,"" --codigovendedor
        ,"" --descripcionCentroCostos
        ,fe_factura_m.fecha_factura --fechafacturacion
        ,"DAP" --incoterm
        ,"" --nombrevendedor
        ,"" --sucursal
        ,"01" --tipoOperacion
        ,"1" --tipodocumento
        ,"0" --tiponota
    into rel_documento,rel_NIT_completo,aplicafel,centroCostos,codigoPlantillaPdf,codigovendedor,descripcionCentroCostos,fechafacturacion,incoterm,nombrevendedor,sucursal,tipoOperacion,tipodocumento,tiponota
    from fe_factura_m INNER JOIN
         fe_prefijos ON fe_factura_m.prefijo = fe_prefijos.prefijo
    where fe_factura_m.prefijo = Envio_prefijo
        and fe_factura_m.numfac = Envio_consecutivo

    SELECT COUNT(*)
    INTO cantidadLineas
    FROM fe_factura_d
    WHERE fe_factura_d.prefijo = Envio_prefijo
        AND fe_factura_d.documento = rel_documento

    LET fechafacturacion = DATE( CURRENT ) -- solo para las pruebas si viene el dato en tabla
    LET prefijo = Prefijo_de_prueba -- solo para las pruebas si viene el dato en tabla
    LET consecutivo = consecutivo_de_prueba -- solo para las pruebas si viene el dato en tabla

    CALL Enlace_Doc_bbl.f_CabezaDocumento_Agrega(aplicafel,cantidadLineas,centroCostos,codigoPlantillaPdf,codigovendedor,consecutivo,contrasenia,descripcionCentroCostos,fechafacturacion,idEmpresa,idErp,incoterm,nombrevendedor,prefijo,sucursal,tipoOperacion,tipodocumento,tiponota,token,usuario,version,nombreImpresora,campoAdicional1,campoAdicional2,campoAdicional3,campoAdicional4,campoAdicional5)

    SELECT
         "" --barioLocalidad
        ,trim(fe_terceros.zona) --ciudad
        ,"" --codigoCIUU
        ,"050010" --codigoPostal
        ,LEFT(fe_terceros.zona,2) --departamento
        ,"Medellín" --descripcionCiudad
        ,"" --digitoverificacion
        ,fe_terceros.direccion --direccion
        ,trim(fe_terceros.email) --email
        ,"Email" --envioPorEmailPlataforma
        ,"" --matriculaMercantil
        ,"" --nitProveedorTecnologico
        ,case when tipo_persona = 1 then razsoc else trim(primer_nombre)||' '||trim(segundo_nombre)||' '||trim(primer_apellido)||' '||trim(segundo_apellido) END --nombreCompleto
        ,"Antioquia" --nombredepartamento
        ,trim(nit) --numeroIdentificacion
        ,fe_terceros.pais --pais
        ,"Colombia" --paisnombre
        ,"04" --regimen
        ,fe_terceros.telefono--telefono
        ,fe_terceros.tipid --tipoIdentificacion
        ,fe_terceros.tipo_persona --tipoPersona
        ,"A-04" --tipoobligacion
    INTO   barioLocalidad,ciudad,codigoCIUU,codigoPostal,departamento,descripcionCiudad,digitoverificacion,direccion,email,envioPorEmailPlataforma,matriculaMercantil,nitProveedorTecnologico,nombreCompleto,nombredepartamento,numeroIdentificacion,pais,paisnombre,regimen,telefono,tipoIdentificacion,tipoPersona,tipoobligacion
    FROM fe_terceros
    where nit = rel_NIT_completo

    select nombre
    into descripcionCiudad
    from fe_ciudades
    where clave = ciudad

    select nombre
    into nombredepartamento
    from fe_departamento
    where clave = departamento
    
    LET digitoverificacion = "8" -- solo para las pruebas NO viene el dato en tabla

    LET digitoverificacion = "" -- solo para las pruebas NO viene el dato en tabla
    LET email = "nada@nada.com" -- solo para las pruebas si viene el dato en tabla

    CALL Enlace_Doc_bbl.f_Adquirente_Agrega(barioLocalidad,ciudad,codigoCIUU,codigoCiudad,codigoPostal,departamento,descripcionCiudad,digitoverificacion,direccion,email,envioPorEmailPlataforma,matriculaMercantil,nitProveedorTecnologico,nombreCompleto,nombredepartamento,numeroIdentificacion,pais,paisnombre,porcentajeParticipacion,regimen,telefono,tipoIdentificacion,tipoPersona,tipoobligacion)

    --  Sección Detalle  --------------------------------------------
    DECLARE DetalleDocumento CURSOR FOR
        SELECT        
            "no" --aplicaMandato
           ,"" --campoAdicional1
           ,"" --campoAdicional2
           ,"" --campoAdicional3
           ,"" --campoAdicional4
           ,"" --campoAdicional5
           ,fe_factura_d.cantidad --cantidad
           ,"86101705" --codigoproducto
           ,"" --descripcion
           ,"" --familia
           ,""   --fechaSuscripcionContrato
           ,"" --gramaje
           ,fe_factura_d.codcat --grupo
           ,"" --marca
           ,"" --modelo
           ,0 --muestracomercial
           ,0 --muestracomercialcodigo
           ,fe_servicios.descripcion --nombreProducto
           ,0 --posicion
           ,fe_factura_d.valoruni*fe_factura_d.cantidad - fe_factura_d.valorbene - fe_factura_d.subsi --preciosinimpuestos CANTIDAD X VALOR UNITARIO – DESCUENTO +CARGOS
           ,fe_factura_d.valoruni*fe_factura_d.cantidad - fe_factura_d.valorbene - fe_factura_d.subsi + ((fe_factura_d.valoruni*fe_factura_d.cantidad - fe_factura_d.valorbene - fe_factura_d.subsi)*(fe_servicios.iva/100)) --preciototal (CANTIDAD X VALOR UNITARIO – DESCUENTO +CARGOS) +IMPUESTO
           ,"" --referencia
           ,"" --seriales
           ,0 --tamanio
           ,1 --tipoImpuesto
           ,"001" --tipocodigoproducto
           ,"ATT" --unidadmedida
           ,fe_factura_d.valoruni --valorunitario
           
           ,fe_factura_d.valoruni*fe_factura_d.cantidad - fe_factura_d.valorbene - fe_factura_d.subsi --baseimponible
           ,"01" --codigoImpuestoRetencion
           ,0 --isAutoRetenido
           ,fe_servicios.iva --porcentaje
           ,(fe_factura_d.valoruni*fe_factura_d.cantidad - fe_factura_d.valorbene - fe_factura_d.subsi)*(fe_servicios.iva/100) --valorImpuestoRetencion

           ,"09" --codigoDescuento
           ,"Beneficio" --descripcion
           ,fe_factura_d.valorbene --descuento
           ,100*fe_factura_d.valorbene/(fe_factura_d.valoruni*fe_factura_d.cantidad) --porcentajeDescuento

           ,"09" --codigoDescuento
           ,"Subsidio" --descripcion
           ,fe_factura_d.subsi --descuento
           ,100*fe_factura_d.subsi/(fe_factura_d.valoruni*fe_factura_d.cantidad) --porcentajeDescuento

        from fe_factura_d inner join
             fe_servicios on fe_factura_d.codigo = fe_servicios.codigo
        where fe_factura_d.prefijo = Envio_prefijo
            and fe_factura_d.documento = rel_documento

    FOREACH DetalleDocumento INTO aplicaMandato,campoAdicional1,campoAdicional2,campoAdicional3,campoAdicional4,campoAdicional5,cantidad,codigoproducto,descripcion,familia,fechaSuscripcionContrato,gramaje,grupo,marca,modelo,muestracomercial,muestracomercialcodigo,nombreProducto,posicion,preciosinimpuestos,preciototal,referencia,seriales,tamanio,tipoImpuesto,tipocodigoproducto,unidadmedida,valorunitario
                                    ,baseimponible,codigoImpuestoRetencion,isAutoRetenido,porcentaje,valorImpuestoRetencion
                                    ,codigoDescuento,descuento_descripcion,descuento,porcentajeDescuento
                                    ,subsi_codigoDescuento,subsi_descuento_descripcion,subsi_descuento,subsi_porcentajeDescuento

        CALL Enlace_Doc_bbl.f_DetalleDocumento_Agrega(aplicaMandato,campoAdicional1,campoAdicional2,campoAdicional3,campoAdicional4,campoAdicional5,cantidad,codigoproducto,descripcion,familia,fechaSuscripcionContrato,gramaje,grupo,marca,modelo,muestracomercial,muestracomercialcodigo,nombreProducto,posicion,preciosinimpuestos,preciototal,referencia,seriales,tamanio,tipoImpuesto,tipocodigoproducto,unidadmedida,valorunitario,valorUnitarioPorCantidad)

        CALL Enlace_Doc_bbl.f_Impuesto_Detalle_Agrega(baseimponible,codigoImpuestoRetencion,isAutoRetenido,porcentaje,valorImpuestoRetencion)

        IF descuento>0 THEN
            CALL Enlace_Doc_bbl.f_Descuento_Detalle_Agrega(codigoDescuento,descuento_descripcion,descuento,porcentajeDescuento)
        END IF 

        IF subsi_descuento>0 THEN
            CALL Enlace_Doc_bbl.f_Descuento_Detalle_Agrega(subsi_codigoDescuento,subsi_descuento_descripcion,subsi_descuento,subsi_porcentajeDescuento)
        END IF 
        
        LET Suma_Cargos = Suma_Cargos + 0
        LET Suma_baseimponible = Suma_baseimponible + baseimponible
        LET Suma_valorImpuestoRetencion = Suma_valorImpuestoRetencion + valorImpuestoRetencion
        LET Suma_importebruto = Suma_importebruto + preciosinimpuestos
        --LET Suma_Descuento = Suma_Descuento + descuento-- no se suman los decuentos en el detalle
    END FOREACH
    -- Termina sección detalle -----------------------------------------
    LET Suma_baseconimpuestos = Suma_importebruto+Suma_valorImpuestoRetencion
    LET Suma_factura = Suma_baseconimpuestos+Suma_Cargos - Suma_Descuento


    CALL Enlace_Doc_bbl.f_Impuesto_Agrega(Suma_baseimponible,codigoImpuestoRetencion,isAutoRetenido,porcentaje,Suma_valorImpuestoRetencion)

    SELECT "10" --medioPago

        ,"COP" --codigoMonedaCambio
        ,"" --fechaTasaCambio
        ,fe_factura_m.fecha_vencimiento --fechavencimiento
        ,"COP" --moneda
        ,0 --pagoanticipado
        ,0 --periododepagoa
        ,fe_factura_m.forma_pago --tipocompra
        ,0 --totalCargos
        ,0 --totalDescuento
        ,0 --totalbaseconimpuestos
        ,0 --totalbaseimponible
        ,0 --totalfactura
        ,0 --totalimportebruto
        ,0 --trm
        ,0 --trm_alterna
    INTO   medioPago,codigoMonedaCambio,fechaTasaCambio,fechavencimiento,moneda,pagoanticipado,periododepagoa,tipocompra,totalCargos,totalDescuento,totalbaseconimpuestos,totalbaseimponible,totalfactura,totalimportebruto,trm,trm_alterna
    from fe_factura_m
    where fe_factura_m.prefijo = Envio_prefijo
        and fe_factura_m.numfac = Envio_consecutivo
    
    LET totalCargos = Suma_Cargos
    LET totalDescuento = Suma_Descuento
    LET totalbaseconimpuestos = Suma_baseconimpuestos
    LET totalbaseimponible = Suma_baseimponible
    LET totalfactura = Suma_factura
    LET totalimportebruto = Suma_importebruto

    LET fechavencimiento = DATE( CURRENT )+60 -- solo para las pruebas si viene el dato en tabla

    CALL Enlace_Doc_bbl.f_Pagos_Agrega(codigoMonedaCambio,fechaTasaCambio,fechavencimiento,moneda,pagoanticipado,periododepagoa,tipocompra,totalCargos,totalDescuento,totalbaseconimpuestos,totalbaseimponible,totalfactura,totalimportebruto,trm,trm_alterna,subtotal,valorEnLetrasSubTotal,valorAdicional1,valorAdicional2,valorAdicional3,valorAdicional4,valorAdicional5,valorEnLetras1,valorEnLetras2,valorEnLetras3,valorEnLetras4,valorEnLetras5,redondeoTotalFactura)
    CALL Enlace_Doc_bbl.f_MedioPago_Agrega(medioPago)

    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"Regimen",1,1,"27_B_Reg No Responsable de Iva",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"DirFacturador",1,1,"27_B_Dirf KM 4 VIA BOCONO AL LADO CENTRO REC VILLA ",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"CiudadFacturador",1,1,"27_B_CiudFact 54001",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"TelefonoFacturador",1,1,"27_B_ TelFact 5748880",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"ResolucionDianlinea1",1,1,"1",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"ResolucionDianlinea2",1,1,"10000",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"LeyendaEncab1",1,1,"27_B_LeyendaEncab1 TEXTPRU-LEYENC1",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"DescMedioP",1,1,"27_B_DescMedioP TARJ. CRED",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"nota1",1,1,"27_B_nota1 TEXPRU-NOTA1",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"nota2",1,1,"27_B_nota2 TEXPRU-NOTA2",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"nota3",1,1,"27_B_nota3 TEXPRU-NOTA3",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"nota4",1,1,"27_B_nota4 TEXPRU-NOTA4",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"ValorLetras1",1,1,"27_B_ValorLetras1 TEXTPRU-VALORLETRA1",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"ValorLetras2",1,1,"27_B_ValorLetras2 TEXTPRU-VALORLETRA2",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"Totalsub",1,1,"426792",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"Totalben",1,1,"115200",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"Totaliva",1,1,"0",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"TotalImpoc",1,1,"0",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"Etiqueta1",1,1,"27_B_Etiqueta1 TEXTPRU-ETI1",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"Etiqueta2",1,1,"27_B_Etiqueta2 SUBSIDIO",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"Etiqueta3",1,1,"27_B_Etiqueta3 BENEFICIO",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"Etiqueta4",1,1,"27_B_Etiqueta4 TEXTPRU-ETI4",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"Etiqueta5",1,1,"27_B_Etiqueta5 IVA",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"Etiqueta6",1,1,"27_B_Etiqueta6 IMPC",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"Etiqueta7",1,1,"27_B_Etiqueta7 TEXTPRU-ETI7",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"PiePagina1",1,1,"27_B_PiePagina1 TEXTPRU-PiePag1",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"PiePagina2",1,1,"27_B_PiePagina2 TEXTPRU-PiePag2",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"PiePagina3",1,1,"27_B_PiePagina3 TEXTPRU-PiePag3",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"NombreElaboro",1,1,"27_B_NomElab ROBERTO PALACIOS",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"NombreAprobo",1,1,"27_B_NomApro ERNESTO AYALA",null)

    --Campos para la resolución 084 de 2021
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"CODIGO_PRESTADOR",1,1,"Dato_de_CODIGO_PRESTADOR",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"TIPO_DOCUMENTO_IDENTIFICACION",1,1,"Dato_de_TIPO_DOCUMENTO_IDENTIFICACION",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"NUMERO_DOCUMENTO_IDENTIFICACION",1,1,"Dato_de_NUMERO_DOCUMENTO_IDENTIFICACION",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"PRIMER_APELLIDO",1,1,"Dato_de_PRIMER_APELLIDO",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"SEGUNDO_APELLIDO",1,1,"Dato_de_SEGUNDO_APELLIDO",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"PRIMER_NOMBRE",1,1,"Dato_de_PRIMER_NOMBRE",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"SEGUNDO_NOMBRE",1,1,"Dato_de_SEGUNDO_NOMBRE",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"TIPO_USUARIO",1,1,"Dato_de_TIPO_USUARIO",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"MODALIDAD_CONTRATACION",1,1,"Dato_de_MODALIDAD_CONTRATACION",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"COBERTURA_PLAN_BENEFICIOS",1,1,"Dato_de_COBERTURA_PLAN_BENEFICIOS",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"NUMERO_AUTORIZACION",1,1,"Dato_de_NUMERO_AUTORIZACION",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"NUMERO_MIPRES",1,1,"Dato_de_NUMERO_MIPRES",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"NUMERO_SUMINISTRO_MIPRES",1,1,"Dato_de_NUMERO_SUMINISTRO_MIPRES",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"NUMERO_CONTRATO",1,1,"Dato_de_NUMERO_CONTRATO",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"NUMERO_POLIZA",1,1,"Dato_de_NUMERO_POLIZA",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"FECHA_INICIO",1,1,"Dato_de_FECHA_INICIO",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"FECHA_FINAL",1,1,"Dato_de_FECHA_FINAL",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"COPAGO",1,1,"Dato_de_COPAGO",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"CUOTA_MODERADORA",1,1,"Dato_de_CUOTA_MODERADORA",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"CUOTA_RECUPERACION",1,1,"Dato_de_CUOTA_RECUPERACION",null)
    CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega(null,"PAGOS_COMPARTIDOS",1,1,"Dato_de_PAGOS_COMPARTIDOS",NULL)

    DISPLAY "+++++++++++++++++++++Inicia envio de factura+++++++++++++++++++++"

    CALL Enlace_Doc_bbl.f_RespuestaEnvio_Recupera()
        RETURNING      codigoQr,consecutivo_r,cufe,descripcionProceso,estadoProceso,fechaExpedicion,fechaFactura,fechaRespuesta,firmaDelDocumento,idErp_r,prefijo_r,selloDeValidacion,tipoDocumento_r
    
    DISPLAY "Respuesta Protocolo: ", sqlca.sqlerrm
    DISPLAY "Respuesta Proceso: ", descripcionProceso

    FOR contadorMensajes = 1 TO Enlace_Doc_bbl.f_MensajesProceso_Conteo()

        CALL Enlace_Doc_bbl.f_MensajesProceso_Recupera(contadorMensajes)
            RETURNING codigoMensaje,descripcionMensaje,rechazoNotificacion

        DISPLAY "Mensaje: ", descripcionMensaje
        
    END FOR

    DISPLAY "NIT:",numeroIdentificacion
    
-------------------------------------------------------------------------------
    DISPLAY "+++++++++++++++++++++Inicia consulta de archivos+++++++++++++++++++++"

    --Inicializa la información para llevar a cabo la consulta de archivos
   CALL Enlace_Archivo_bbl.f_consultarFacturaArchivo_Agrega(
     consecutivo --consecutivo  
   , contrasenia --contrasenia  
   , idEmpresa --idEmpresa  
   , prefijo --prefijo  
   , 0 --tipoArchivo  
   , "1" --tipoDocumento  
   , token --token  
   , usuario --usuario  
   , version --version 
   )

   --Recupera la información referente a la consulta de archivos
   CALL Enlace_Archivo_bbl.f_RespuestaDescargaDocumentos_Recupera()
        RETURNING  codigoRespuesta, consecutivo, descripcionRespuesta, estadoProceso, idErp, prefijo, tipoDocumento

   DISPLAY "Código de error       = ", SQLCA.sqlerrm
   DISPLAY "Codigo Respuesta      = ", codigoRespuesta
   DISPLAY "Descripción respuesta = ", descripcionRespuesta

   
   --Recupera todos los mensajes resultantes de la consulta
   FOR indice = 1 TO Enlace_Archivo_bbl.f_RespuestaTamanoConsultarArchivos_listaMensajes_Recupera()
      CALL Enlace_Archivo_bbl.f_RespuestaMensajesProcesoArchivo_Recupera(indice)
           RETURNING codigoMensaje
                   , descripcionMensaje
                   , rechazoNotificacion

      DISPLAY "Mensaje: ",codigoMensaje," - ", descripcionMensaje
   END FOR
   
   --Guarda todos los archivos resultantes de la consulta
   CALL Enlace_Archivo_bbl.f_ConsultarArchivos_Guardar("c:\\Puerto\\")


END FUNCTION
