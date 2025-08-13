DATABASE empresa

DEFINE maestro RECORD LIKE fc_factura_m.*
TYPE detalle RECORD LIKE fc_factura_d.*
TYPE detalles DYNAMIC ARRAY OF detalle

MAIN

DEFINE arr_usuarios detalles
INITIALIZE maestro.* TO NULL 
SELECT * INTO maestro.* FROM fc_factura_m
WHERE fc_factura_m.documento = "0000002"

CALL f_obtencion_de_datos() RETURNING arr_usuarios 
CALL f_genera_reporte_simple(arr_usuarios)

END MAIN
 
FUNCTION f_obtencion_de_datos ()
DEFINE arr_usuarios detalles
DEFINE rec_detalle RECORD LIKE fc_factura_d.*
DEFINE i INTEGER 
INITIALIZE rec_detalle.* TO NULL
DECLARE cursor_det CURSOR FOR
   Select *  from fc_factura_d
   WHERE fc_factura_d.documento = "0000002"
LET i = 1
   FOREACH cursor_det into rec_detalle.*
      
      LET arr_usuarios[i].prefijo = rec_detalle.prefijo
      DISPLAY arr_usuarios[i].prefijo
      LET arr_usuarios[i].documento = rec_detalle.documento
      DISPLAY arr_usuarios[i].documento
      LET arr_usuarios[i].codigo = rec_detalle.codigo
      DISPLAY arr_usuarios[i].codigo
      LET arr_usuarios[i].subcodigo = rec_detalle.subcodigo
      DISPLAY arr_usuarios[i].subcodigo
      LET arr_usuarios[i].cantidad = rec_detalle.cantidad
      DISPLAY arr_usuarios[i].cantidad
      LET arr_usuarios[i].valoruni = rec_detalle.valoruni
      DISPLAY arr_usuarios[i].valoruni 
      LET arr_usuarios[i].valor = rec_detalle.valor
      DISPLAY arr_usuarios[i].valor
      LET arr_usuarios[i].base_imponible = rec_detalle.base_imponible
      DISPLAY arr_usuarios[i].base_imponible 
      LET arr_usuarios[i].total_pagar = rec_detalle.total_pagar
      DISPLAY arr_usuarios[i].total_pagar 
      LET i = i + 1
      DISPLAY "Número de lineas: ", i
   END FOREACH 
CALL arr_usuarios.clear()

RETURN arr_usuarios
END FUNCTION 

FUNCTION f_genera_reporte_simple(arr_usuarios)
DEFINE arr_usuarios detalles
,lsxd_manejador OM.SAXDOCUMENTHANDLER
,contador INTEGER
 LET lsxd_manejador = RW_Inicializa_prueba("RPT_prueba5","PDF","Documento_Soporte.4rp")
 IF lsxd_manejador IS NULL THEN
 DISPLAY "Error. El manejador no tiene información................." 
 RETURN
 END IF
 
 START REPORT r_imprimeCatEmpleados TO XML HANDLER lsxd_manejador
 FOR contador = 1 TO arr_usuarios.getLength()
 
 OUTPUT TO REPORT r_imprimeCatEmpleados( arr_usuarios[contador].* )
 
 END FOR
 FINISH REPORT r_imprimeCatEmpleados
 
END FUNCTION

FUNCTION RW_Inicializa_prueba(Nombre_reporte,formato,archivo_4rp)
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
 CALL fgl_report_selectPreview(FALSE)
 CASE formato
 WHEN "PDF"
 CALL fgl_report_configurePDFDevice (null, false, false, false,1, null)
 WHEN "XLSX"
 CALL fgl_report_configureXLSDevice(1, NULL,FALSE,TRUE,NULL,NULL, TRUE)
 WHEN "RTF"
 CALL fgl_report_configureRTFDevice (1, null, null, null)
 WHEN "SVG"
 CALL fgl_report_configureImageDevice (false, false, false, 1, null, "jpg", null, null, 
null)
 WHEN "HMTL"
 CALL fgl_report_configureHTMLDevice (1, null, null, null, null, null, null, null, NULL )
 WHEN "Printer"
 CALL fgl_report_configurePDFDevice (null, false, false, false,1, null)
 END CASE
 LET lsxd_manejador = fgl_report_commitCurrentSettings()
 END IF
 RETURN lsxd_manejador
END FUNCTION



REPORT r_imprimeCatEmpleados( r_usuario )
DEFINE r_usuario detalle
DEFINE rec_terceros RECORD LIKE fc_terceros.*
DEFINE nombre_proveedor STRING 
DEFINE nit CHAR (20)
DEFINE telefono CHAR (15)
DEFINE direccion CHAR (50)
DEFINE ciudad VARCHAR (50)
DEFINE razsoc CHAR (80)
DEFINE nit_empresa CHAR (20)
DEFINE tel_empresa CHAR (12)
DEFINE dir_empresa VARCHAR (50)
DEFINE ciu_empresa VARCHAR (6)
DEFINE descripcion_s CHAR (50)
DEFINE total DECIMAL(12,2) 

 ORDER EXTERNAL BY r_usuario.documento
 FORMAT
 FIRST PAGE HEADER
 SKIP TO TOP OF PAGE
 LET total=0
 INITIALIZE rec_terceros.* TO NULL 
 SELECT * INTO rec_terceros.* FROM fc_terceros
 WHERE fc_terceros.nit = maestro.nit 
 IF rec_terceros.razsoc IS NULL THEN 
    LET nombre_proveedor = rec_terceros.primer_nombre, " ", rec_terceros.primer_apellido, " ", rec_terceros.segundo_apellido
 ELSE
    LET nombre_proveedor = rec_terceros.razsoc
 END IF 
 LET nit = rec_terceros.nit
 LET telefono = rec_terceros.telefono
 LET direccion = rec_terceros.direccion
 SELECT fe_ciudades.nombreciu INTO ciudad FROM fe_unidades 
 WHERE fe_ciudades.codciu = rec_terceros.zona
 LET razsoc="CAJA DE COMPENSACION DEL ORIENTE COLOMBIANO COMFAORIENTE"
 LET nit_empresa="890500675"
 LET tel_empresa="(57)5748880"
 LET dir_empresa ="Avenida 2 No. 13-75 La Playa"
 LET ciu_empresa = "Cúcuta"
   
 PRINTX nombre_proveedor 
 PRINTX nit 
 PRINTX telefono 
 PRINTX direccion 
 PRINTX ciudad 
 PRINTX razsoc
 PRINTX nit_empresa
 PRINTX tel_empresa 
 PRINTX dir_EMPRESA 
 PRINTX ciu_empresa 
 PAGE HEADER
 
 ON EVERY ROW
 SELECT fc_servicios.descripcion INTO descripcion_s FROM fc_servicios
 WHERE fc_servicios.codigo = r_usuario.codigo
 
 PRINTX r_usuario.codigo
 PRINTX descripcion_s
 PRINTX r_usuario.cantidad
 PRINTX r_usuario.valoruni
 PRINTX r_usuario.total_pagar
 LET total=total+r_usuario.total_pagar

 ON LAST ROW
    
    
 PRINTX total
END REPORT