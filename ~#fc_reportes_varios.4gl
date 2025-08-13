DATABASE empresa
GLOBALS "fc_globales.4gl"
DEFINE i INTEGER 


--MAIN
--END MAIN

FUNCTION obtener_datos_doc_x_pref(elprex, fechai,fechaf)
DEFINE elprex CHAR(5)
DEFINE arreglo documentos_prex
DEFINE fechai,fechaf DATE 
DEFINE rec_documentos RECORD LIKE fc_factura_m.*

LET i=1
INITIALIZE rec_documentos.* TO NULL 
DECLARE cursor_documentos CURSOR FOR
SELECT * FROM fc_factura_m
WHERE prefijo = elprex 
AND fecha_factura BETWEEN fechai AND fechaf
FOREACH cursor_documentos INTO rec_documentos.*
    LET arreglo[i].fecha=rec_documentos.fecha_factura
    LET arreglo[i].document=rec_documentos.documento
    LET arreglo[i].nit=rec_documentos.nit
    SELECT FIRST 1 total_factura INTO arreglo[i].total FROM fc_factura_tot
    WHERE prefijo=elprex AND documento = arreglo[i].document
    LET i=i+1
END FOREACH 
RETURN arreglo
END FUNCTION 

FUNCTION RW_Inicializa_prueba1(Nombre_reporte,formato,archivo_4rp)
DEFINE 
 Nombre_reporte STRING
,formato STRING
,archivo_4rp STRING
--Manejador. El cual contiene todas las configuraciones 
--para la generación del reporte
,lsxd_manejador OM.SAXDOCUMENTHANDLER   
,ruta_completa STRING
      LET ruta_completa = "/desarrollo/Proyectos_G_3_10/Proy_Factu_compra/Pruebas_Reportes/", Nombre_reporte
      INITIALIZE lsxd_manejador TO NULL
      IF fgl_report_loadCurrentSettings(archivo_4rp) THEN
         CALL fgl_report_setOutputFileName(ruta_completa) 
         CALL fgl_report_selectDevice(formato)
         CALL fgl_report_selectPreview(true)
         CASE formato
            WHEN "PDF"
               CALL fgl_report_configurePDFDevice (null, false, false, false,1, null)
            WHEN "XLSX"
               CALL fgl_report_configureXLSDevice(1, NULL,FALSE,TRUE,NULL,NULL, TRUE)
            WHEN "RTF"
               CALL fgl_report_configureRTFDevice (1, null, null, null)
            WHEN "SVG"
               CALL fgl_report_configureImageDevice (false, false, false, 1, null, "jpg", null, null, null)
            WHEN "HML"
               CALL fgl_report_configureHTMLDevice (1, null, null, null, null, null, null, null, NULL )
            WHEN "Printer"
               CALL fgl_report_configurePDFDevice (null, false, false, false,1, null)
         END CASE
         LET lsxd_manejador = fgl_report_commitCurrentSettings()
      END IF
      RETURN lsxd_manejador
END FUNCTION

FUNCTION f_genera_reporte_x_prefijo(arr_usuarios,pre,fechai,fechaf,tipo_de_salida)
DEFINE arr_usuarios documentos_prex 
,lsxd_manejador OM.SAXDOCUMENTHANDLER,
tipo_de_salida STRING,
contador INTEGER,
pre CHAR (5),
nombre STRING 
DEFINE fechai,fechaf DATE 

LET nombre = pre,"0000"

    LET lsxd_manejador = RW_Inicializa_prueba1(nombre,tipo_de_salida CLIPPED,"documetos_x_prefijo.4rp")
    IF lsxd_manejador IS NULL THEN
    DISPLAY "Error. El manejador no tiene información................."  
    RETURN
    END IF
    
    START REPORT r_imprimeDocuPref TO XML HANDLER lsxd_manejador
        FOR contador = 1 TO arr_usuarios.getLength()
        
            OUTPUT TO REPORT r_imprimeDocuPref( arr_usuarios[contador].*,pre,fechai,fechaf )
        
        END FOR
    FINISH REPORT r_imprimeDocuPref
    
END FUNCTION

REPORT r_imprimeDocuPref( r_usuario,pre,fechai,fechaf )
DEFINE pre CHAR(5)
DEFINE fechai,fechaf DATE 
DEFINE r_usuario tipo_doc_por_prex
ORDER EXTERNAL BY r_usuario.fecha
    
    FORMAT
    
    FIRST PAGE HEADER
        SKIP TO TOP OF PAGE
        
        PRINTX pre
        PRINTX fechai
        PRINTX fechaf
               
    PAGE HEADER

        PRINTX pre
        PRINTX fechai
        PRINTX fechaf
    
    ON EVERY ROW

        PRINTX r_usuario.fecha
        PRINTX r_usuario.document
        PRINTX r_usuario.nit
        PRINTX r_usuario.total

    ON LAST ROW
       LET i = i-1
       PRINTX i
END REPORT 

FUNCTION opcion_salida()
 OPEN WINDOW w_opcsal AT 04,5 WITH FORM "opcion_salida"
 let int_flag = false
 INPUT opc_sal from radiogroup1

 CLOSE WINDOW w_opcsal

  DISPLAY "Este es", opc_sal
 RETURN opc_sal
END FUNCTION 
