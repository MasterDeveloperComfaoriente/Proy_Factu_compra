
-- Ejemplo simplificado para observar la secuencia de ejecución de las funciones

FUNCTION Ejemplo_Enlace_Con_BD()

    

    SELECT [,,, ...]
    INTO [,,, ...]
    FROM Tabla_Facturas
    WHERE ID_factura = Id_fac_a_enviar

    CALL Enlace_Doc_bbl.f_CabezaDocumento_Agrega([,,, ...])

    SELECT [,,, ...]
    INTO [,,, ...]
    FROM Tabla_Pagos
    WHERE ID_factura = Id_fac_a_enviar

    CALL Enlace_Doc_bbl.f_Pagos_Agrega([,,, ...])

    DECLARE Adquirente CURSOR FOR
        SELECT [,,, ...]
        FROM Tabla_Adquirente
        WHERE ID_factura = Id_fac_a_enviar
    FOREACH Adquirente INTO [,,, ...]
        CALL Enlace_Doc_bbl.f_Adquirente_Agrega([,,, ...])
    END FOREACH

    DECLARE Anticipo CURSOR FOR
        SELECT [,,, ...]
        FROM Tabla_Anticipo
        WHERE ID_factura = Id_fac_a_enviar
    FOREACH Anticipo INTO [,,, ...]
        CALL Enlace_Doc_bbl.f_Anticipo_Agrega([,,, ...])
    END FOREACH

    DECLARE CampoAdicional CURSOR FOR
        SELECT [,,, ...]
        FROM Tabla_CampoAdicional
        WHERE ID_factura = Id_fac_a_enviar
    FOREACH CampoAdicional INTO [,,, ...]
        CALL Enlace_Doc_bbl.f_CampoAdicional_Agrega([,,, ...])
    END FOREACH

    DECLARE Cargo CURSOR FOR
        SELECT [,,, ...]
        FROM Tabla_Cargo
        WHERE ID_factura = Id_fac_a_enviar
    FOREACH Cargo INTO [,,, ...]
        CALL Enlace_Doc_bbl.f_Cargo_Agrega([,,, ...])
    END FOREACH

    DECLARE CodigoBarra CURSOR FOR
        SELECT [,,, ...]
        FROM Tabla_CodigoBarra
        WHERE ID_factura = Id_fac_a_enviar
    FOREACH CodigoBarra INTO [,,, ...]
        CALL Enlace_Doc_bbl.f_CodigoBarra_Agrega([,,, ...])
    END FOREACH

    DECLARE DatoEntrega CURSOR FOR
        SELECT [,,, ...]
        FROM Tabla_DatoEntrega
        WHERE ID_factura = Id_fac_a_enviar
    FOREACH c1 INTO [,,, ...]
        CALL Enlace_Doc_bbl.f_DatoEntrega_Agrega[,,, ...])
    END FOREACH

    DECLARE Descuento CURSOR FOR
        SELECT [,,, ...]
        FROM Tabla_Descuento
        WHERE ID_factura = Id_fac_a_enviar
    FOREACH Descuento INTO [,,, ...]
        CALL Enlace_Doc_bbl.f_Descuento_Agrega([,,, ...])
    END FOREACH

    DECLARE DocumentoAdjunto CURSOR FOR
        SELECT [,,, ...]
        FROM Tabla_DocumentoAdjunto
        WHERE ID_factura = Id_fac_a_enviar
    FOREACH DocumentoAdjunto INTO [,,, ...]
        CALL Enlace_Doc_bbl.f_DocumentoAdjunto_Agrega([,,, ...])
    END FOREACH

    DECLARE FacturaModificada CURSOR FOR
        SELECT [,,, ...]
        FROM Tabla_FacturaModificada
        WHERE ID_factura = Id_fac_a_enviar
    FOREACH FacturaModificada INTO [,,, ...]
        CALL Enlace_Doc_bbl.f_FacturaModificada_Agrega([,,, ...])

    DECLARE Impuesto CURSOR FOR
        SELECT [,,, ...]
        FROM Tabla_Impuesto
        WHERE ID_factura = Id_fac_a_enviar
    FOREACH Impuesto INTO [,,, ...]
        CALL Enlace_Doc_bbl.f_Impuesto_Agrega([,,, ...])
    END FOREACH

    DECLARE MedioPago CURSOR FOR
        SELECT [,,, ...]
        FROM Tabla_MedioPago
        WHERE ID_factura = Id_fac_a_enviar
    FOREACH MedioPagoINTO [,,, ...]
        CALL Enlace_Doc_bbl.f_MedioPago_Agrega([,,, ...])
    END FOREACH

    DECLARE OrdenCompra CURSOR FOR
        SELECT [,,, ...]
        FROM Tabla_OrdenCompra
        WHERE ID_factura = Id_fac_a_enviar
    FOREACH OrdenCompra INTO [,,, ...]
        CALL Enlace_Doc_bbl.f_OrdenCompra_Agrega([,,, ...])
    END FOREACH

    --  Sección Detalle  --------------------------------------------
    DECLARE DetalleDocumento CURSOR FOR
        SELECT [,,, ...]
        FROM Tabla_
        WHERE ID_factura = Id_fac_a_enviar
    FOREACH DetalleDocumento INTO [,,, ...]

        CALL Enlace_Doc_bbl.f_DetalleDocumento_Agrega([,,, ...])

        DECLARE Cargo_Detalle CURSOR FOR
            SELECT [,,, ...]
            FROM Tabla_Cargo_Detalle
            WHERE ID_factura = Id_fac_a_enviar
                AND id_articulo = Id_art_a_enviar
        FOREACH Cargo_Detalle INTO [,,, ...]
            CALL Enlace_Doc_bbl.f_Cargo_Detalle_Agrega([,,, ...])
        END FOREACH

        DECLARE CodigoBarra_Detalle CURSOR FOR
            SELECT [,,, ...]
            FROM Tabla_CodigoBarra_Detalle
            WHERE ID_factura = Id_fac_a_enviar
                AND id_articulo = Id_art_a_enviar
        FOREACH CodigoBarra_Detalle INTO [,,, ...]
            CALL Enlace_Doc_bbl.f_CodigoBarra_Detalle_Agrega([,,, ...])
        END FOREACH

        DECLARE Descuento_Detalle CURSOR FOR
            SELECT [,,, ...]
            FROM Tabla_Descuento_Detalle
            WHERE ID_factura = Id_fac_a_enviar
                AND id_articulo = Id_art_a_enviar
        FOREACH Descuento_Detalle INTO [,,, ...]
            CALL Enlace_Doc_bbl.f_Descuento_Detalle_Agrega([,,, ...])
        END FOREACH

        DECLARE Impuesto_Detalle CURSOR FOR
            SELECT [,,, ...]
            FROM Tabla_Impuesto_Detalle
            WHERE ID_factura = Id_fac_a_enviar
                AND id_articulo = Id_art_a_enviar
        FOREACH Impuesto_Detalle INTO [,,, ...]
            CALL Enlace_Doc_bbl.f_Impuesto_Detalle_Agrega([,,, ...])
        END FOREACH

        DECLARE Mandante_Detalle CURSOR FOR
            SELECT [,,, ...]
            FROM Tabla_Mandante_Detalle
            WHERE ID_factura = Id_fac_a_enviar
                AND id_articulo = Id_art_a_enviar
        FOREACH Mandante_Detalle INTO [,,, ...]
            CALL Enlace_Doc_bbl.f_Mandante_Detalle_Agrega([,,, ...])
        END FOREACH

        DECLARE CampoAdicional_Detalle CURSOR FOR
            SELECT [,,, ...]
            FROM Tabla_CampoAdicional_Detalle
            WHERE ID_factura = Id_fac_a_enviar
                AND id_articulo = Id_art_a_enviar
        FOREACH CampoAdicional_Detalle INTO [,,, ...]
            CALL Enlace_Doc_bbl.f_CampoAdicional_Detalle_Agrega([,,,..])
        END FOREACH
    END FOREACH
    -- Termina sección detalle -----------------------------------------

    CALL Enlace_Doc_bbl
    .f_RespuestaEnvio_Recupera() RETURNING
    DISPLAY "Respuesta Proceso: ", descripcionProceso

    FOR contadorMensajes = 1 TO Enlace_Doc_bbl.f_MensajesProceso_Conteo()
        CALL Enlace_Doc_bbl.f_MensajesProceso_Recupera(contadorMensajes)
            RETURNING
        DISPLAY "Mensaje: ", descripcionMensaje
    END FOR


END FUNCTION
