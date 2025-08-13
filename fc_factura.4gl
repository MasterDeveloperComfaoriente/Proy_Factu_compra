IMPORT util
IMPORT security
GLOBALS "fc_globales.4gl"


DEFINE mtimpbruto, mtbasimp, mttotimp, mttotdesc, mtotant, mttotpag FLOAT
DEFINE gmaxarray2,dias INTEGER
DEFINE mced char(1)
DEFINE mtiprep char(1)
DEFINE rec_servi RECORD LIKE fc_servicios.*
DEFINE prex CHAR (5)


DEFINE opcrep,opcrep2 char(1)

DEFINE medad DECIMAL(14,6)

DEFINE mvaltot decimal(12,2)

DEFINE msubsi21 RECORD LIKE subsi21.*

DEFINE msubsi23 RECORD LIKE subsi23.*

DEFINE gafc_factura_d, tafc_factura_d ARRAY [100] OF RECORD 
  codigo      LIKE fc_factura_d.codigo,
  descripcion LIKE fc_servicios.descripcion,
  subcodigo   LIKE fc_factura_d.subcodigo,
  descri      LIKE fc_sub_servicios.descripcion,
  cantidad    LIKE fc_factura_d.cantidad,
  valoruni    LIKE fc_factura_d.valoruni,
  valor       LIKE fc_factura_d.valor
END RECORD

DEFINE rec_factura_m, recg_factura_m,tapfc_factura_ma RECORD
    prefijo LIKE fc_factura_m.prefijo,
    documento LIKE fc_factura_m.documento,
    numfac LIKE fc_factura_m.numfac,
    cufe LIKE fc_factura_m.cufe,
    fecha_elaboracion LIKE fc_factura_m.fecha_elaboracion,
    fecha_factura LIKE fc_factura_m.fecha_factura,
    hora LIKE fc_factura_m.hora,
    nit LIKE fc_factura_m.nit,
    forma_pago LIKE fc_factura_m.forma_pago,
    medio_pago LIKE fc_factura_m.medio_pago,
    fecha_vencimiento LIKE fc_factura_m.fecha_vencimiento,
    nota1 LIKE fc_factura_m.nota1,
    estado LIKE fc_factura_m.estado,
    codest LIKE fc_factura_m.codest,
    fecest LIKE fc_factura_m.fecest,
    horaest LIKE fc_factura_m.horaest,
    codcop  LIKE fc_factura_m.codcop,
    docu LIKE fc_factura_m.docu
END RECORD 

DEFINE tpfacter ARRAY[100] OF RECORD
  cedula        char(20),
  nombre        char(35),
  edad          integer,
  sexo          char(1),
  cat           char(1),
  valor         decimal(12,2)
END RECORD

DEFINE mcon char(2)
DEFINE mcop,mcopp char(4)
DEFINE total_doc DECIMAL (12,2)
DEFINE tipo_reporte VARCHAR(20)

 DEFINE combestado,cb_estd ui.ComboBox
 DEFINE combforma_pago ui.ComboBox

FUNCTION fc_factura_mmain()
 
 DEFINE exist SMALLINT

 OPEN WINDOW w_mfc_documento_m AT 1,1 WITH FORM "fc_factura"
 LET gmaxarray2 = 100
 LET gmaxarray = 100
 LET gmaxdply = 9
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE rec_factura_m.* TO NULL 
 
 INITIALIZE tapfc_factura_ma.* TO NULL 
    LET combestado = ui.ComboBox.forName("fc_factura_m.estado")
   CALL combestado.clear()
   CALL combestado.addItem("B","BORRADOR")
   CALL combestado.addItem("A","ENVIADA CON ERRORES")
   CALL combestado.addItem("S","TRASMITIDA")
   CALL combestado.addItem("P","PROCESADA EXITOSA")
   CALL combestado.addItem("G","CONTIGENCIA")
   CALL combestado.addItem("R","RECHAZADA CLIENTE")
   CALL combestado.addItem("D","RECHAZADA DIAN")
   CALL combestado.addItem("X","RECHAZADA DISPAPELES")
   CALL combestado.addItem("N","ANULADA POR NOTAC")

  
   
   LET combforma_pago = ui.ComboBox.forName("fc_factura_m.forma_pago")
   CALL combforma_pago.clear()
   CALL combforma_pago.addItem("1","CONTADO")
   CALL combforma_pago.addItem("2","CREDITO")
          
  
   LET cb_estd = ui.ComboBox.forName("fc_factura_m.codest")
   CALL cb_estd.clear()
   CALL cb_estd.addItem("0","CON ERROR")
   CALL cb_estd.addItem("1","EXITOSO")
   CALL cb_estd.addItem("2","CON NOTIFICACIONES")
   CALL cb_estd.addItem("3","ENVIADO DOBLE")
   CALL cb_estd.addItem("4","NO ACEPTADA DIAN")
   CALL cb_estd.addItem("19","FALLO ENVIO DISPAPELES")
   CALL cb_estd.addItem("24","CONTINGENCIA DIAN")

   
 CALL fc_factura_minitga()
 CALL fc_factura_minitta()

 

 MENU "DOCUMENTO SOPORTE"
  COMMAND "Adiciona" "Adiciona Documento Soporte"
   LET mcodmen="FC31"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL fc_factura_madd()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
    CALL fc_factura_mdetail()
   END if 
  COMMAND "Consulta" "Consulta los documentos soportes adicionados"
   LET mcodmen="FC32"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL fc_factura_mquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL fc_factura_mdetail()
   END if 
  COMMAND "Listar" "Lista los servicios de el documento soporte en consulta"
   LET mcodmen="FC33"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF NOT exist THEN
     CALL FGL_WINMESSAGE( "Administrador", " No hay Documento(s) soporte en consulta", "stop")
    ELSE
     CALL fc_factura_mview()
     CALL fc_factura_mdetail()
    END IF
   END IF 
  --COMMAND "Imprimir Factura" "Imprime La FACTURA en estado Aprobada"
  --CALL imprime_factu_r()
  {COMMAND "Imprimir Orden Pago" "Imprime La orden de Pago (Documento en Borrador)"
  -- CALL imprime_ordenp(lb_preview, salida_reporte)
     CALL ui.Interface.loadActionDefaults("acciones") 
      LET tipo_reporte = "Reporte_simple"
      CALL f_salida_reporte(tipo_reporte)}
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 10
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfc_documento_m
END FUNCTION

FUNCTION fc_factura_minitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE gafc_factura_d[x].* TO NULL
 END FOR
END FUNCTION

FUNCTION fc_factura_minitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE tafc_factura_d[x].* TO NULL
 END FOR
END FUNCTION

FUNCTION fc_factura_mdetail()
 DEFINE mnombre,mnombret char(50)
 DEFINE nombre CHAR(80)
 DEFINE x SMALLINT
 DISPLAY BY NAME rec_factura_m.prefijo THRU rec_factura_m.docu
 INITIALIZE mfc_prefijos.* TO NULL
  SELECT * into mfc_prefijos.* FROM fc_prefijos
  WHERE prefijo = rec_factura_m.prefijo
  DISPLAY mfc_prefijos.descripcion TO mprefijo
  INITIALIZE tpcom_proveedores.* TO NULL
  SELECT * into tpcom_proveedores.* FROM fc_terceros
  WHERE nit = rec_factura_m.nit
  IF tpcom_proveedores.razsoc IS NOT NULL  THEN 
   DISPLAY tpcom_proveedores.razsoc TO mrazsoc
  ELSE 
    LET nombre = tpcom_proveedores.primer_nombre CLIPPED," ",tpcom_proveedores.segundo_nombre CLIPPED," ",tpcom_proveedores.primer_apellido CLIPPED," ",tpcom_proveedores.segundo_apellido CLIPPED
    DISPLAY  nombre TO mrazsoc
  END IF 
   {CASE 
        WHEN rec_factura_m.medio_pago = "10"
            DISPLAY "EFECTIVO" TO medio_pago
        WHEN rec_factura_m.medio_pago = "20"
            DISPLAY "CHEQUE" TO medio_pago
        WHEN rec_factura_m.medio_pago = "42" 
            DISPLAY "CONSIGNACION" TO medio_pago
        WHEN rec_factura_m.medio_pago = "45" 
            DISPLAY "TRANSFERENCIA" TO medio_pago   
        WHEN rec_factura_m.medio_pago = "48"
            DISPLAY "TARJETA CREDITO" TO medio_pago
        WHEN rec_factura_m.medio_pago = "49"
            DISPLAY "TARJETA DEBITO" TO medio_pago
   END CASE }
  
 FOR x = 1 TO gmaxdply
  DISPLAY gafc_factura_d[x].* TO ofe[x].*
 END FOR
END FUNCTION
{
FUNCTION fc_factura_mtatoga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET gafc_factura_d[x].* = tafc_factura_d[x].*
 END FOR
END FUNCTION 
FUNCTION fc_factura_mgatota()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET tafc_factura_d[x].* = gafc_factura_d[x].*
 END FOR
END FUNCTION
}
FUNCTION fc_factura_mrownull( x )
 DEFINE x, rownull SMALLINT
 LET rownull = TRUE
 IF tafc_factura_d[x].codigo IS NOT NULL AND
    tafc_factura_d[x].descripcion IS NOT NULL AND
    tafc_factura_d[x].cantidad IS NOT NULL AND
    tafc_factura_d[x].valoruni IS NOT NULL AND 
    tafc_factura_d[x].valor IS NOT NULL THEN 
    LET rownull = FALSE
 END IF
 RETURN rownull
END FUNCTION

FUNCTION fc_factura_mgetdetail()
 DEFINE x SMALLINT
 CALL fc_factura_minitga()
 DECLARE c_rec_factura_m CURSOR FOR
  SELECT fc_factura_d.codigo, fc_servicios.descripcion,
         fc_factura_d.subcodigo, fc_sub_servicios.descripcion,
         fc_factura_d.cantidad,
         fc_factura_d.valoruni, fc_factura_d.valor
   FROM fc_factura_d, fc_servicios, OUTER fc_sub_servicios
   WHERE  fc_factura_d.prefijo = rec_factura_m.prefijo
     AND fc_factura_d.documento = rec_factura_m.documento
     AND fc_factura_d.codigo = fc_servicios.codigo
     AND fc_factura_d.subcodigo = fc_sub_servicios.codigo
    
   ORDER BY fc_factura_d.valor ASC
 LET x = 1
 FOREACH c_rec_factura_m INTO gafc_factura_d[x].*
  LET x = x + 1
  IF x > gmaxarray THEN
   EXIT FOREACH
  END IF
 END FOREACH
END FUNCTION

FUNCTION fc_factura_mupdate()
DEFINE mnombre char(50)
 DEFINE mnumcod integer
 define mdetalle like villa_tip_conv.detalle 
 DEFINE z, cnt, x, v, y, t, rownull, currow,
        scrrow, toggle, ttlrow, lin, lin2 SMALLINT
 DEFINE valor_total LIKE fc_factura_tot.total_factura
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION DE FACTURAS" 
 INITIALIZE tapfc_factura_ma.* TO NULL
 CALL fc_factura_minitta()
 LET tapfc_factura_ma.* = rec_factura_m.*
 LET ttlrow = 1
 FOR x = 1 TO gmaxarray
  LET tafc_factura_d[x].* = gafc_factura_d[x].*
  CALL fc_factura_mrownull( x ) RETURNING rownull
  IF NOT rownull THEN
   INITIALIZE tafc_factura_d[x].* TO NULL
   LET tafc_factura_d[ttlrow].* = gafc_factura_d[x].*
   LET ttlrow = ttlrow + 1
  ELSE
   EXIT FOR
  END IF
 END FOR
 LET ttlrow = ttlrow - 1
 LABEL fc_factura_mtog1:
 LET toggle = FALSE
 IF int_flag THEN 
    LET int_flag = FALSE
 END IF
 IF tapfc_factura_ma.estado<>"B" THEN
  CALL FGL_WINMESSAGE( "Administrador", " LA FACTURA NO SE PUEDE MODIFICAR POR QUE NO ESTA EN ESTADO BORRADOR","information") 
  RETURN
 END IF
 LET cnt=0
 SELECT count(*) INTO cnt FROM fc_prefijos_usu
  WHERE prefijo=tapfc_factura_ma.prefijo AND usu_elabora=musuario
 IF cnt IS NULL THEN LET cnt=0 END IF
 IF cnt=0 THEN
  CALL FGL_WINMESSAGE( "Administrador", " EL USUARIO NO ESTA AUTORIZADO PARA MODIFICAR FACTURAS DE ESTE PREFIJO","information") 
  RETURN
 END IF  
LABEL entrada_factu:
INPUT BY NAME tapfc_factura_ma.nit THRU tapfc_factura_ma.estado WITHOUT DEFAULTS
 BEFORE FIELD nit
  LET mced = null
   --IF tapfc_factura_ma.nit IS NULL THEN
   --  CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE DOCUMENTO DEL ADQUIRIENTE NO FUE DIGITADO ", "stop")
   --  next field nit
   --ELSE
     initialize mfc_terceros.* to NULL
     select * into mfc_terceros.* from fc_terceros where nit=tapfc_factura_ma.nit
     IF mfc_terceros.nit is null THEN
        CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE DOCUMENTO DEL ADQUIRIENTE NO EXISTE ", "stop")
        --next field nit
        LET int_flag = TRUE
        EXIT INPUT
      END IF
      
 AFTER FIELD nit
   LET mced = null
   IF tapfc_factura_ma.nit IS NULL THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE DOCUMENTO DEL ADQUIRIENTE NO FUE DIGITADO ", "stop")
     next field nit
   ELSE
     initialize mfc_terceros.* to NULL
     select * into mfc_terceros.* from fc_terceros where nit=tapfc_factura_ma.nit
     IF mfc_terceros.nit is null THEN
        CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE DOCUMENTO DEL ADQUIRIENTE NO EXISTE ", "stop")
        next field nit
     ELSE
       IF mfc_terceros.tipo_persona="1" THEN
         DISPLAY mfc_terceros.razsoc TO mrazsoc
       ELSE
         LET mnombre=NULL
         LET mnombre=mfc_terceros.primer_nombre clipped," ",mfc_terceros.segundo_nombre clipped," ",
            mfc_terceros.primer_apellido clipped," ",mfc_terceros.segundo_apellido clipped," "
         DISPLAY mnombre TO mrazsoc            
       END IF 
     END IF
   END IF  
   LET mced="N" 
  
 AFTER FIELD forma_pago
   IF tapfc_factura_ma.forma_pago IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA FORMA DE PAGO NO FUE DIGITADO  ", "stop") 
    NEXT FIELD forma_pago
   END IF
   IF tapfc_factura_ma.forma_pago="2" THEN
     LET tapfc_factura_ma.medio_pago = "1"
     let tapfc_factura_ma.fecha_vencimiento=today+mfc_prefijos.dias_cred
     DISPLAY BY NAME tapfc_factura_ma.fecha_vencimiento
   ELSE
     DISPLAY BY NAME tapfc_factura_ma.medio_pago
   END IF 
   
 AFTER FIELD medio_pago
  IF tapfc_factura_ma.forma_pago="10" THEN 
   IF tapfc_factura_ma.medio_pago IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL MEDIO DE PAGO NO FUE DIGITADO  ", "stop") 
    NEXT FIELD medio_pago
   END IF
  END IF 
  CASE
    
   WHEN tapfc_factura_ma.medio_pago="48"
    NEXT FIELD franquicia
   WHEN tapfc_factura_ma.medio_pago="49"
    NEXT FIELD franquicia 
   WHEN tapfc_factura_ma.medio_pago="20"
    NEXT FIELD numche
   OTHERWISE
    NEXT FIELD fecha_vencimiento 
  END case 

 
 AFTER FIELD fecha_vencimiento
  IF tapfc_factura_ma.forma_pago="2" THEN
   IF tapfc_factura_ma.fecha_vencimiento IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA FECHA DE VENCIMIENTO DE LA FACTURA NO FUE DIGITADA ", "stop") 
    NEXT FIELD fecha_vencimiento
   END IF
  END IF
 
 
  AFTER FIELD estado
   IF tapfc_factura_ma.estado IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL ESTADO DE LA FACTURA NO FUE DIGITADO  ", "stop")
    NEXT FIELD estado
   ELSE
    if tapfc_factura_ma.estado<>"B" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL ESTADO DE LA FACTURA DEBE SER BORRADOR  ", "stop")
     NEXT FIELD estado
    END IF 
   END IF
  ON ACTION bt_detalle
   IF tapfc_factura_ma.prefijo IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL PREFIJO NO FUE DIGITADO   ", "stop")
    NEXT FIELD prefijo
   END IF
   IF tapfc_factura_ma.documento IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO INTERNO NO FUE DIGITADO   ", "stop")
    NEXT FIELD documento
   END IF
   IF tapfc_factura_ma.nit IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL DOCUMENTO DEL ADQUIRIENTE NO FUE DIGITADA    ", "stop")
    next field nit
   END IF
   IF tapfc_factura_ma.fecha_elaboracion IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA FECHA DE ELABORACION DE LA FACTURA NO FUE DIGITADA  ", "stop")
    NEXT FIELD fecha
   END IF
   IF tapfc_factura_ma.forma_pago="2" THEN
    IF tapfc_factura_ma.fecha_vencimiento IS NULL THEN
     CALL FGL_WINMESSAGE( "Administrador", " LA FECHA DE VENCIMIENTO NO FUE DIGITADA  ", "stop")
     NEXT FIELD fecha_vencimiento
    END if 
   END IF
  IF tapfc_factura_ma.forma_pago IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA FORMA DE PAGO NO FUE DIGITADA  ", "stop")
    NEXT FIELD forma_pago
   END IF
   IF tapfc_factura_ma.estado IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL ESTADO NO FUE DIGITADA  ", "stop")
    NEXT FIELD estado
   END IF 
   LET toggle = TRUE
   EXIT INPUT
  AFTER INPUT
   IF int_flag THEN
    EXIT INPUT
   END IF
   IF tapfc_factura_ma.prefijo IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL PREFIJO NO FUE DIGITADO   ", "stop")
    GOTO entrada_factu
   END IF
   IF tapfc_factura_ma.documento IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO INTERNO NO FUE DIGITADO   ", "stop")
    GOTO entrada_factu
   END IF
   IF tapfc_factura_ma.nit IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL DOCUMENTO DEL ADQUIRIENTE NO FUE DIGITADA    ", "stop")
    GOTO entrada_factu
   END IF
   IF tapfc_factura_ma.fecha_elaboracion IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA FECHA DE ELABORACION DE LA FACTURA NO FUE DIGITADA  ", "stop")
    GOTO entrada_factu
   END IF
   IF tapfc_factura_ma.forma_pago IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA FORMA DE PAGO NO FUE DIGITADA  ", "stop")
    GOTO entrada_factu
   END IF

   IF tapfc_factura_ma.medio_pago IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL MEDIO DE PAGO NO FUE DIGITADA  ", "stop")
    GOTO entrada_factu
   END IF
  
   IF tapfc_factura_ma.estado IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL ESTADO NO FUE DIGITADA  ", "stop")
    GOTO entrada_factu
   END IF
 END INPUT
 IF int_flag THEN
  CLEAR FORM
  DISPLAY "" AT 1,10
  CALL FGL_WINMESSAGE( "Administrador", "LA MODIFICACION FUE CANCELADA", "exclamation")
  INITIALIZE tapfc_factura_ma.* TO NULL
  CALL fc_factura_minitta()
  RETURN
 END IF
 IF toggle THEN
  LET toggle = FALSE
  for l=gmaxarray to 1 step -1
   if tafc_factura_d[l].codigo is not null then
    let ttlrow=l
    exit for
   end IF
  END for 
  CALL SET_COUNT( ttlrow )
  INPUT ARRAY tafc_factura_d WITHOUT DEFAULTS FROM ofe.*
  AFTER FIELD codigo
   DISPLAY "..Si es este 4gl.."
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_factura_d[y].codigo="?" then
    CALL fc_serviciosval2(tapfc_factura_ma.prefijo) RETURNING tafc_factura_d[y].codigo
    DISPLAY tafc_factura_d[y].codigo to ofe[z].codigo
    INITIALIZE mfc_servicios.* TO NULL
    select * into mfc_servicios.* from fc_servicios 
     where codigo=tafc_factura_d[y].codigo
    IF mfc_servicios.codigo is null THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO NO EXISTE ", "stop")
     INITIALIZE mfc_servicios.* TO NULL
     initialize tafc_factura_d[y].codigo to null
     next field codigo
    END IF
    IF mfc_servicios.estado<>"A" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO ESTA INACTIVO ", "stop")
     INITIALIZE mfc_servicios.* TO NULL
     initialize tafc_factura_d[y].codigo to null
     next field codigo
    END IF
   ELSE 
   
     INITIALIZE mfc_servicios.* TO NULL
     select * into mfc_servicios.* from fc_servicios 
      where codigo=tafc_factura_d[y].codigo
     IF mfc_servicios.codigo is null THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO NO EXISTE ", "stop")
      INITIALIZE mfc_servicios.* TO NULL
      initialize tafc_factura_d[y].codigo to null
      next field codigo
     END IF
     IF mfc_servicios.estado<>"A" THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO ESTA INACTIVO ", "stop")

      INITIALIZE mfc_servicios.* TO NULL
      initialize tafc_factura_d[y].codigo to null
      next field codigo
     END IF
    END IF

   IF tafc_factura_d[y].codigo is not null THEN
   
    LET mcodser=NULL
    LET mcodser=tafc_factura_d[y].codigo  
    LET tafc_factura_d[y].descripcion=mfc_servicios.descripcion
    DISPLAY tafc_factura_d[y].descripcion to ofe[z].descripcion
       
   END IF

  AFTER FIELD subcodigo
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_factura_d[y].subcodigo="?" then
    CALL fc_sub_serviciosval() RETURNING tafc_factura_d[y].subcodigo
    DISPLAY tafc_factura_d[y].subcodigo to ofe[z].subcodigo
    INITIALIZE mfc_sub_servicios.* TO NULL
    select * into mfc_sub_servicios.* from fc_sub_servicios 
     where codigo=tafc_factura_d[y].subcodigo
     AND codser = tafc_factura_d[y].codigo
    IF mfc_sub_servicios.codigo is null THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SUB SERVICIO NO EXISTE ", "stop")
     INITIALIZE mfc_sub_servicios.* TO NULL
     initialize tafc_factura_d[y].subcodigo to null
     next field subcodigo
    END IF
    IF mfc_sub_servicios.estado<>"A" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SUB SERVICIO ESTA INACTIVO ", "stop")
     INITIALIZE mfc_sub_servicios.* TO NULL
     initialize tafc_factura_d[y].subcodigo to null
     next field subcodigo
    END IF
   ELSE 
    IF tafc_factura_d[y].subcodigo is not null then
     INITIALIZE mfc_sub_servicios.* TO NULL
     select * into mfc_sub_servicios.* from fc_sub_servicios 
      where codigo=tafc_factura_d[y].subcodigo
     IF mfc_sub_servicios.codigo is null THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SUB SERVICIO NO EXISTE ", "stop")
      INITIALIZE mfc_sub_servicios.* TO NULL
      initialize tafc_factura_d[y].subcodigo to null
      next field subcodigo
     END IF
     IF mfc_sub_servicios.estado<>"A" THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO ESTA INACTIVO ", "stop")
      INITIALIZE mfc_sub_servicios.* TO NULL
      initialize tafc_factura_d[y].subcodigo to null
      next field subcodigo
     END IF
    END IF
   END IF
   IF tafc_factura_d[y].subcodigo is not null then
    LET tafc_factura_d[y].descri=mfc_sub_servicios.descripcion
    DISPLAY tafc_factura_d[y].descri to ofe[z].descri
   END IF

 
  AFTER FIELD cantidad
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_factura_d[y].cantidad is null or 
      tafc_factura_d[y].cantidad<=0 THEN
      CALL FGL_WINMESSAGE( "Administrador", " LA CANTIDAD NO FUE DIGITADA ", "stop")  
    next field cantidad
   end IF
  
  AFTER FIELD valoruni
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_factura_d[y].valoruni is null THEN
     CALL FGL_WINMESSAGE( "Administrador", " NO HA DIGITADO LA TARIFA PARA ESTE SERVICIO ", "stop")
     NEXT FIELD valoruni
    {CALL FGL_WINMESSAGE( "Administrador", " NO HA DIGITADO LA TARIFA PARA ESTE SERVICIO ", "stop")
    INITIALIZE tafc_factura_d[y].* TO NULL
    DISPLAY tafc_factura_d[y].* TO ofe[z].*
    next field codigo}
   ELSE 
     LET tafc_factura_d[y].valor=tafc_factura_d[y].valoruni*tafc_factura_d[y].cantidad
     DISPLAY tafc_factura_d[y].valor to ofe[z].valor
   END IF 
   

   AFTER FIELD valor 
    LET y = arr_curr()
    LET z = scr_line()
    IF tafc_factura_d[y].valor IS NULL THEN 
        CALL FGL_WINMESSAGE( "Administrador", " NO SE HA CALCULADO EL VALOR TOTAL DE ESTE REGISTRO ", "stop")
        NEXT FIELD valoruni
    END IF 
 
  
   
 
   --DISPLAY tafc_factura_d[y].valor to ofe[z].valor

  ON ACTION bt_detalle
   LET ttlrow = ARR_COUNT()
   LET int_flag = FALSE
   LET toggle = TRUE
   EXIT INPUT

 END INPUT
 IF toggle THEN
  GOTO fc_factura_mtog1
 END IF
 IF int_flag THEN
   CLEAR FORM
   CALL FGL_WINMESSAGE( "Administrador", "LA MODIFICACION FUE CANCELADA", "information")
   INITIALIZE tapfc_factura_ma.* TO NULL
   CALL fc_factura_minitta() 
   message "                                                        " 
   RETURN
  END IF
END IF
LET gerrflag = FALSE
MESSAGE "MODIFICANDO LA FACTURA DE VENTA" 
BEGIN WORK
WHENEVER ERROR CONTINUE
SET LOCK MODE TO WAIT

 IF NOT gerrflag THEN
  DELETE FROM fc_factura_d
   WHERE prefijo = gfc_factura_m.prefijo
     AND documento =  gfc_factura_m.documento
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF
  LET mtimpbruto = 0
  LET mtbasimp = 0
  let mttotimp = 0
  let mttotdesc = 0
  let mtotant = 0
  LET mttotpag = 0
  DELETE FROM fc_factura_imp 
    WHERE fc_factura_imp.prefijo= tapfc_factura_ma.prefijo
      AND fc_factura_imp.documento = tapfc_factura_ma.documento
  IF NOT gerrflag THEN
  update fc_factura_m SET ( nit,  fecha_vencimiento, medio_pago, forma_pago, 
   nota1, estado )
  = ( tapfc_factura_ma.nit, 
   tapfc_factura_ma.fecha_vencimiento,
   tapfc_factura_ma.medio_pago, tapfc_factura_ma.forma_pago,
   tapfc_factura_ma.nota1, tapfc_factura_ma.estado )
  WHERE prefijo = tapfc_factura_ma.prefijo
    AND documento =  tapfc_factura_ma.documento
  IF status < 0 THEN
   LET gerrflag = TRUE
  ELSE
    DELETE FROM fc_factura_d
    WHERE prefijo = tapfc_factura_ma.prefijo
    AND documento =  tapfc_factura_ma.documento
    LET valor_total=0
   FOR x = 1 TO gmaxarray
    CALL fc_factura_mrownull( x ) RETURNING rownull
    IF NOT rownull THEN
     INSERT INTO fc_factura_d ( codigo, subcodigo, cantidad, valoruni, 
       valor, prefijo, documento, total_pagar,base_imponible)
      VALUES ( tafc_factura_d[x].codigo, 
               tafc_factura_d[x].subcodigo, 
               tafc_factura_d[x].cantidad,
               tafc_factura_d[x].valoruni, 
               tafc_factura_d[x].valor,
               tapfc_factura_ma.prefijo ,tapfc_factura_ma.documento,
               tafc_factura_d[x].valor,tafc_factura_d[x].valor)
       LET valor_total=valor_total+ tafc_factura_d[x].valor
     IF status < 0 THEN
      LET gerrflag = TRUE
      EXIT FOR
     END IF
     UPDATE fc_factura_tot SET importebruto=valor_total, total_factura=valor_total,
     baseconimpu=valor_total, baseimponible=valor_total
     WHERE prefijo = tapfc_factura_ma.prefijo
     AND documento =  tapfc_factura_ma.documento 
    END IF
    
   END FOR
  END IF 
 END IF 
 message "                                                        "
 INITIALIZE tapfc_factura_ma.* TO NULL
 LET rec_factura_m.* = tapfc_factura_ma.*
 IF NOT gerrflag THEN
  COMMIT WORK
  LET cnt = 1
  FOR x = 1 TO gmaxarray
   INITIALIZE gafc_factura_d[x].* TO NULL
   CALL fc_factura_mrownull( x ) RETURNING rownull
   IF NOT rownull THEN
    LET gafc_factura_d[cnt].* = tafc_factura_d[x].*
    LET cnt = cnt + 1
   END IF
  END FOR
  for i=1 to gmaxarray
   INITIALIZE mefecto[i].* TO NULL
  end for
  CALL fc_factura_mdetail()
  CALL FGL_WINMESSAGE( "Administrador", "LA FACTURA FUE ADICIONADA Y ACTUALIZADA", "information")
 ELSE
  ROLLBACK WORK
  CALL FGL_WINMESSAGE( "Administrador", "LA MODIFICACION FUE CANCELADA", "information") 
 END IF
 SLEEP 2
END function 

FUNCTION fc_factura_madd()
    DEFINE cnt INTEGER 
    DEFINE mnumcod INTEGER
    DEFINE toggle,ttlrow,rownull SMALLINT 
    DEFINE plata decimal(12,2)
    DEFINE i INTEGER 
    DEFINE acumulado DECIMAL (12,2)
    DEFINE total_renglones SMALLINT 
    DEFINE nombre CHAR (80)
    DEFINE combmedio_pago ui.ComboBox
    DEFINE prefijos_desc RECORD LIKE fc_prefijos.*
    DEFINE combo_prefijo ui.ComboBox
    DEFINE prex CHAR (5) 

    MESSAGE "Estado : ADICIONANDO DOCUMENTO SOPORTE   " 
    IF int_flag THEN
      LET int_flag = FALSE
    END IF
    DISPLAY "" AT 1,1
    MESSAGE ""
    MESSAGE "Estado : ADICIONANDO UN DOCUMENTO SOPORTE" 
    CLEAR FORM 
    INITIALIZE rec_factura_m.* TO NULL
    CALL fc_factura_minitta()
   
        
    LABEL adi_documento:
        INPUT BY NAME rec_factura_m.prefijo THRU rec_factura_m.codest

    BEFORE FIELD prefijo
   LET cnt=0
   SELECT count(*) INTO cnt FROM fc_prefijos_usu
    WHERE usu_elabora=musuario
   IF cnt IS NULL THEN LET cnt=0 END IF
   IF cnt>1 THEN
    CALL fc_prefijosval() RETURNING rec_factura_m.prefijo
    IF rec_factura_m.prefijo is NULL THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     comment= " Debe escoger un Prefijo ",
      image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
     NEXT FIELD prefijo
    ELSE
      INITIALIZE mfc_prefijos.* TO NULL
      SELECT * INTO mfc_prefijos.*
       FROM fc_prefijos
       WHERE fc_prefijos.prefijo = rec_factura_m.prefijo
      DISPLAY mfc_prefijos.descripcion TO mprefijo 
    END IF
   ELSE
    IF cnt<=1 THEN 
     INITIALIZE mfc_prefijos_usu.* TO NULL
     SELECT * INTO mfc_prefijos_usu.* FROM fc_prefijos_usu
      WHERE usu_elabora=musuario
     LET rec_factura_m.prefijo = mfc_prefijos_usu.prefijo 
     DISPLAY BY NAME rec_factura_m.prefijo
    END if 
   END if 
   let rec_factura_m.fecha_elaboracion=today
   let rec_factura_m.estado="B"
   DISPLAY BY NAME rec_factura_m.fecha_elaboracion
   DISPLAY BY NAME rec_factura_m.estado
  
   AFTER FIELD prefijo
    IF rec_factura_m.prefijo is null then
      CALL fc_prefijosval() RETURNING rec_factura_m.prefijo
      IF rec_factura_m.prefijo is NULL THEN 
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " Debe escoger un Prefijo ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD prefijo
      ELSE
        INITIALIZE mfc_prefijos.* TO NULL
        SELECT * INTO mfc_prefijos.*
         FROM fc_prefijos
         WHERE fc_prefijos.prefijo = rec_factura_m.prefijo
        DISPLAY mfc_prefijos.descripcion TO mprefijo 
      END IF 
    ELSE
     INITIALIZE mfc_prefijos.* TO NULL
     SELECT * INTO mfc_prefijos.*
      FROM fc_prefijos
      WHERE fc_prefijos.prefijo = rec_factura_m.prefijo
      DISPLAY mfc_prefijos.descripcion TO mprefijo     
    END IF  
    LET cnt=0
    SELECT count(*) INTO cnt FROM fc_prefijos_usu
     WHERE prefijo=rec_factura_m.prefijo AND usu_elabora=musuario
    IF cnt IS NULL THEN LET cnt=0 END IF
    IF cnt=0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El usuario No puede Crear Documentos Para este Prefijo ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD prefijo
    END IF           
    
    BEFORE FIELD documento
        
       { select max(documento) into mnumcod from fc_factura_m
        WHERE prefijo=rec_factura_m.prefijo}
        SELECT documento INTO mnumcod FROM fc_numeros_internos
        WHERE prefijo= rec_factura_m.prefijo
        if mnumcod is null then let mnumcod=1 end IF
        LET cnt = 1
        LET x = mnumcod + 1
        LET rec_factura_m.documento = x USING "&&&&&&&"
        WHILE cnt <> 0
            SELECT COUNT(*) INTO cnt FROM fc_factura_m
            WHERE documento = rec_factura_m.documento
            AND  prefijo=rec_factura_m.prefijo
            IF cnt <> 0 THEN
                LET x = x + 1
                LET rec_factura_m.documento = x USING "&&&&&&&"
                DISPLAY BY NAME rec_factura_m.documento
                
            ELSE
                EXIT WHILE
            END IF
        END WHILE
   DISPLAY BY NAME rec_factura_m.documento
   UPDATE fc_numeros_internos SET fc_numeros_internos.documento = rec_factura_m.documento
   WHERE fc_numeros_internos.prefijo = rec_factura_m.prefijo
   
   NEXT FIELD nit

    AFTER FIELD nit
        
        LET mced = NULL
        IF rec_factura_m.nit IS NULL THEN
            CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE DOCUMENTO DEL PROVEEDOR NO FUE DIGITADO ", "stop")
            next field nit
        ELSE
            initialize gterceros.* to NULL
            select * into gterceros.* from fc_terceros where nit=rec_factura_m.nit
            IF gterceros.nit is null THEN
                CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE DOCUMENTO DEL PROVEEDOR NO EXISTE ", "stop")
                next field nit
            ELSE
                 
                IF gterceros.razsoc IS NULL THEN
                    LET nombre= gterceros.primer_nombre CLIPPED, " ",  gterceros.segundo_nombre CLIPPED," ",gterceros.primer_apellido CLIPPED, " ",gterceros.segundo_apellido CLIPPED 
                    DISPLAY nombre TO mrazsoc
                ELSE 
                    DISPLAY gterceros.razsoc TO mrazsoc
                END IF 
        END IF 
     END IF
     
    AFTER FIELD forma_pago
        IF rec_factura_m.forma_pago IS NULL THEN
            CALL FGL_WINMESSAGE( "Administrador", " LA FORMA DE PAGO NO FUE SELECCIONADA  ", "stop") 
            NEXT FIELD forma_pago
        ELSE
            IF rec_factura_m.forma_pago = "2" THEN 
                LET combmedio_pago = ui.ComboBox.forName("fc_factura_m.medio_pago")
                CALL combmedio_pago.clear()
                CALL combmedio_pago.addItem("1","NO APLICA")
                CALL combmedio_pago.addItem("10","EFECTIVO")
                CALL combmedio_pago.addItem("20","CHEQUE")
                CALL combmedio_pago.addItem("42","CONSIGNACION")
                CALL combmedio_pago.addItem("45","TRANSFERENCIA")
                CALL combmedio_pago.addItem("48","TARJETA CREDITO")
                CALL combmedio_pago.addItem("49","TARJETA DEBITO")
            ELSE 
                LET combmedio_pago = ui.ComboBox.forName("fc_factura_m.medio_pago")
                CALL combmedio_pago.clear()
                CALL combmedio_pago.addItem("10","EFECTIVO")
                CALL combmedio_pago.addItem("20","CHEQUE")
                CALL combmedio_pago.addItem("42","CONSIGNACION")
                CALL combmedio_pago.addItem("45","TRANSFERENCIA")
                CALL combmedio_pago.addItem("48","TARJETA CREDITO")
                CALL combmedio_pago.addItem("49","TARJETA DEBITO")
            END IF 
        END IF
        IF rec_factura_m.forma_pago="2" THEN
            let rec_factura_m.fecha_vencimiento=today+mfc_prefijos.dias_cred
            DISPLAY BY NAME rec_factura_m.fecha_vencimiento
        END IF 
        
    AFTER FIELD medio_pago
        IF rec_factura_m.medio_pago IS NULL THEN
            CALL FGL_WINMESSAGE( "Administrador", " EL MEDIO DE PAGO NO FUE SELECCIONADO  ", "stop") 
            NEXT FIELD medio_pago
        END IF 
    AFTER FIELD nota1
        IF rec_factura_m.nota1 IS NULL THEN
            CALL FGL_WINMESSAGE( "Administrador", " LA NOTA NO PUEDE ESTAR VACIA  ", "stop") 
            NEXT FIELD nota1
        ELSE 
            NEXT FIELD codest
        END IF 

   --DISPLAY rec_factura_m.estado

    ON ACTION bt_detalle
        LET ttlrow = ARR_COUNT()
        LET total_doc=0
        LET int_flag = FALSE
        LET toggle = TRUE
        IF rec_factura_m.prefijo IS NULL THEN
            CALL FGL_WINMESSAGE( "Administrador", " EL PREFIJO NO FUE DIGITADO   ", "stop")
            NEXT FIELD prefijo
        END IF

        IF rec_factura_m.documento IS NULL THEN
            CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE DOCUMENTO NO FUE DIGITADO   ", "stop")
            NEXT FIELD documento
        END IF

        IF rec_factura_m.nit IS NULL THEN
            CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE DOCUMENTO DEL PROVEEDOR NO FUE DIGITADO   ", "stop")
            NEXT FIELD nit
        END IF

        IF rec_factura_m.forma_pago IS NULL THEN
            CALL FGL_WINMESSAGE( "Administrador", " LA FORMA DE PAGO NO FUE SELECCIONADA   ", "stop")
            NEXT FIELD forma_pago
        END IF

        IF rec_factura_m.medio_pago IS NULL THEN
            CALL FGL_WINMESSAGE( "Administrador", " EL MEDIO DE PAGO NO FUE SELECCIONADO   ", "stop")
            NEXT FIELD medio_pago
        END IF

        IF rec_factura_m.nota1 IS NULL THEN 
            CALL FGL_WINMESSAGE( "Administrador", "La nota no puede estar vacia\n
            recuerde una vez tabulador y despues click en detalle", "stop")
            NEXT FIELD nota1
        END IF
       
        LET toggle = TRUE
        EXIT INPUT 

        AFTER INPUT
            IF int_flag THEN
                EXIT INPUT
            END IF

            IF rec_factura_m.prefijo IS NULL THEN
                CALL FGL_WINMESSAGE( "Administrador", " EL PREFIJO NO FUE DIGITADO   ", "stop")
                GOTO adi_documento
            END IF

            IF rec_factura_m.documento IS NULL THEN
                CALL FGL_WINMESSAGE( "Administrador", " EL DOCUMENTO INTERNO NO FUE DIGITADO   ", "stop")
                GOTO adi_documento
            END IF

            IF rec_factura_m.nit IS NULL THEN
                CALL FGL_WINMESSAGE( "Administrador", " EL NIT DEL PROVEEDOR NO FUE DIGITADO   ", "stop")
                GOTO adi_documento
            END IF

            IF rec_factura_m.forma_pago IS NULL THEN
                CALL FGL_WINMESSAGE( "Administrador", " LA FORMA DE PAGO NO FUE SELECCIONADA   ", "stop")
                GOTO adi_documento
            END IF

            IF rec_factura_m.medio_pago IS NULL THEN
                CALL FGL_WINMESSAGE( "Administrador", " EL MEDIO DE PAGO NO FUE SELECCIONADO   ", "stop")
                GOTO adi_documento
            END IF

            IF rec_factura_m.nota1 IS NULL THEN 
                CALL FGL_WINMESSAGE( "Administrador", " LA NOTA NO FUE DIGITADA   ", "stop")
                NEXT FIELD nota1
            END IF 
            
END INPUT 

IF int_flag THEN
  CLEAR FORM
  DISPLAY "" AT 1,10
  CALL FGL_WINMESSAGE( "Administrador", "LA MODIFICACION FUE CANCELADA", "exclamation")
  INITIALIZE rec_factura_m.* TO NULL
  CALL fc_factura_minitta()
  RETURN
 END IF
 

 IF toggle THEN 
    LET toggle= FALSE
    CALL set_count (ttlrow)
    INPUT ARRAY tafc_factura_d WITHOUT DEFAULTS FROM ofe.*
    AFTER FIELD codigo
    DISPLAY "entra1"
    
    LET y=arr_curr()
    LET z=scr_line()
    

    IF tafc_factura_d[y].codigo="?" THEN
        CALL fc_serviciosval2(rec_factura_m.prefijo) RETURNING tafc_factura_d[y].codigo
        DISPLAY tafc_factura_d[y].codigo to ofe[z].codigo
        INITIALIZE rec_servi.* TO NULL
        select * into rec_servi.* from fc_servicios
        WHERE codigo = tafc_factura_d[y].codigo
        IF rec_servi.codigo is null THEN
            CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO NO EXISTE ", "stop")
            INITIALIZE rec_servi.* TO NULL
            INITIALIZE tafc_factura_d[y].codigo TO NULL 
            NEXT FIELD codigo
        END IF 
       
        IF rec_servi.estado<>"A" THEN 
            CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO ESTA INACTIVO ", "stop")
            INITIALIZE rec_servi.* TO NULL
            INITIALIZE tafc_factura_d[y].codigo to NULL
            next field codigo
        END IF
        IF tafc_factura_d[y].codigo IS NOT NULL THEN 
            INITIALIZE rec_servi.* TO NULL 
            SELECT * INTO rec_servi.* FROM fc_servicios
            WHERE codigo = tafc_factura_d[y].codigo
        
            IF tafc_factura_d[y].codigo IS NULL THEN
                CALL FGL_WINMESSAGE( "Administrador", "EL SERVICIO NO ESTA ASOCIADO AL PREFIJO ", "stop")
                INITIALIZE rec_servi.* TO NULL
                initialize tafc_factura_d[y].codigo to NULL
                next field codigo
            END IF
        END IF 
        ELSE 
            IF tafc_factura_d[y].codigo is not null THEN
                
                INITIALIZE rec_servi.* TO NULL 
                select * into rec_servi.* from fc_servicios
                where codigo=tafc_factura_d[y].codigo
                AND prefijo = rec_factura_m.prefijo
                IF rec_servi.codigo IS NULL THEN
                    CALL FGL_WINMESSAGE( "Administrador", "EL SERVICIO NO ESTA ASOCIADO AL PREFIJO ", "stop")
                    INITIALIZE rec_servi.* TO NULL
                    initialize tafc_factura_d[y].codigo to NULL
                    next field codigo
    
                END IF 
                INITIALIZE rec_servi.* TO NULL
                select * into rec_servi.* from fc_servicios 
                where codigo=tafc_factura_d[y].codigo
                IF rec_servi.codigo is null THEN
                    CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO NO EXISTE ", "stop")
                    INITIALIZE rec_servi.* TO NULL
                    initialize tafc_factura_d[y].codigo to NULL
                    next field codigo
                END IF
                IF rec_servi.estado<>"A" THEN
                    CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO ESTA INACTIVO ", "stop")
                    INITIALIZE rec_servi.* TO NULL
                    initialize tafc_factura_d[y].codigo to NULL
                    next field codigo
                END IF
            END IF 
        END IF 
        IF tafc_factura_d[y].codigo IS NOT NULL THEN 
            FOR x = 1 TO gmaxarray
                INITIALIZE rec_servi.* TO NULL 
                DECLARE crf3 CURSOR FOR 
                SELECT * FROM fc_servicios WHERE codigo = tafc_factura_d[y].codigo
                FOREACH crf3 INTO rec_servi.*
                    CASE 
                        WHEN tapfc_factura_ma.medio_pago="20"
                            let mcopp=mfc_conta3.codcop_ef
                        WHEN tapfc_factura_ma.medio_pago="45"
                            let mcopp=mfc_conta3.codcop_ba
                    END CASE 
                    IF mcon IS NULL THEN 
                        LET mcon = mfc_conta3.codconta
                    END IF
                    IF mcop IS NULL THEN 
                        CASE 
                            WHEN tapfc_factura_ma.medio_pago="20"
                                let mcop=mfc_conta3.codcop_ef
                            WHEN tapfc_factura_ma.medio_pago="45"
                                let mcop=mfc_conta3.codcop_ba
                        END CASE 
                    END IF
                IF mcon <> mfc_conta3.codconta THEN 
                    CALL FGL_WINMESSAGE( "Administrador", " LOS SERVICIOS DIGITADOS POSEEN DIFERENTES CONTABILIDADES ", "stop") 
                    INITIALIZE tafc_factura_d[y].* TO NULL
                    DISPLAY tafc_factura_d[y].* TO ofe[z].*
                    NEXT FIELD codigo
                    EXIT FOREACH
                END IF 
                IF mcop<>mcopp THEN
                    CALL FGL_WINMESSAGE( "Administrador", " LOS SERVICIOS DIGITADOS POSEEN DIFERENTES TIPOS DE COMPROBANTES ", "stop") 
                    INITIALIZE tafc_factura_d[y].* TO NULL
                    DISPLAY tafc_factura_d[y].* TO ofe[z].*
                    NEXT FIELD codigo
                    EXIT FOREACH
                END IF  
            END FOREACH
        END FOR
    LET mcodser = NULL
    LET mcodser=tafc_factura_d[y].codigo  
    LET tafc_factura_d[y].descripcion=rec_servi.descripcion
    DISPLAY tafc_factura_d[y].descripcion to ofe[z].descripcion
   END IF 

  AFTER FIELD subcodigo
    LET y = arr_curr()
    LET z = scr_line()
    IF tafc_factura_d[y].subcodigo="?" then
    CALL fc_sub_serviciosval() RETURNING tafc_factura_d[y].subcodigo
    DISPLAY tafc_factura_d[y].subcodigo to ofe[z].subcodigo
    INITIALIZE mfc_sub_servicios.* TO NULL
    select * into mfc_sub_servicios.* from fc_sub_servicios 
    where codigo=tafc_factura_d[y].subcodigo
    AND codser = tafc_factura_d[y].codigo
    IF mfc_sub_servicios.codigo is null THEN
        CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SUB SERVICIO NO EXISTE ", "stop")
        INITIALIZE mfc_sub_servicios.* TO NULL
        initialize tafc_factura_d[y].subcodigo to NULL
        next field subcodigo
    END IF
    IF mfc_sub_servicios.estado<>"A" THEN
        CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SUB SERVICIO ESTA INACTIVO ", "stop")
        INITIALIZE mfc_sub_servicios.* TO NULL
        initialize tafc_factura_d[y].subcodigo to NULL
        next field subcodigo
    END IF
    ELSE 
    IF tafc_factura_d[y].subcodigo is not null THEN
        INITIALIZE mfc_sub_servicios.* TO NULL
        select * into mfc_sub_servicios.* from fc_sub_servicios 
        where codigo=tafc_factura_d[y].subcodigo
        IF mfc_sub_servicios.codigo is null THEN
            CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SUB SERVICIO NO EXISTE ", "stop")
            INITIALIZE mfc_sub_servicios.* TO NULL
            initialize tafc_factura_d[y].subcodigo to NULL
            next field subcodigo
        END IF
        IF mfc_sub_servicios.estado<>"A" THEN
            CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO ESTA INACTIVO ", "stop")
            INITIALIZE mfc_sub_servicios.* TO NULL
            initialize tafc_factura_d[y].subcodigo to NULL
            next field subcodigo
        END IF
    END IF
END IF
   IF tafc_factura_d[y].subcodigo is not null THEN
        LET tafc_factura_d[y].descri=mfc_sub_servicios.descripcion
        DISPLAY tafc_factura_d[y].descri to ofe[z].descri
   END IF

AFTER FIELD cantidad
    LET y = arr_curr()
    LET z = scr_line()
    IF tafc_factura_d[y].cantidad is null THEN
        CALL FGL_WINMESSAGE( "Administrador", " NO HA DIGITADO LA CANTIDAD.. ", "stop")
        INITIALIZE tafc_factura_d[y].* TO NULL
        DISPLAY tafc_factura_d[y].* TO ofe[z].*
        next field cantidad
   END IF 

AFTER FIELD valoruni
   LET y = arr_curr()
   LET z = scr_line()
   
   IF tafc_factura_d[y].valoruni is null THEN
        CALL FGL_WINMESSAGE( "Administrador", " NO HA DIGITADO LA TARIFA PARA ESTE SERVICIO ", "stop")
        INITIALIZE tafc_factura_d[y].* TO NULL
        DISPLAY tafc_factura_d[y].* TO ofe[z].*
        next field valoruni
    ELSE
            LET tafc_factura_d[y].valor=tafc_factura_d[y].cantidad * tafc_factura_d[y].valoruni
            DISPLAY tafc_factura_d[y].valor TO ofe[z].valor
            
   END IF 


         
END INPUT 
END IF 
BEGIN WORK
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT 
 CALL fc_factura_mrownull( 1 ) RETURNING rownull
 DISPLAY "Esta es la nota: ",rec_factura_m.nota1
IF NOT rownull THEN--1
 if rec_factura_m.prefijo is not null then --2
 INSERT INTO fc_factura_m (prefijo, documento,fecha_elaboracion,nit, medio_pago,
 forma_pago, nota1, estado,usuario_add, tipodocumento, tipoope)
   VALUES (rec_factura_m.prefijo, rec_factura_m.documento, rec_factura_m.fecha_elaboracion,
   rec_factura_m.nit, rec_factura_m.medio_pago, rec_factura_m.forma_pago, 
   rec_factura_m.nota1, rec_factura_m.estado,musuario,"1","10")
   if sqlca.sqlcode <> 0 then   --3 
     MENU "Mensaje de Error"  ATTRIBUTE(style= "dialog", 
                               comment= " NO SE ADICIONO.. REGISTRO REFERENCIADO     "  ,
                               image= "stop")
        COMMAND "Aceptar"
          EXIT MENU
     END MENU
     LET gerrflag = TRUE
    ELSE
        
         LET acumulado=0
         LET total_renglones =0
        FOR x = 1 TO gmaxarray
           
            CALL fc_factura_mrownull( x ) RETURNING rownull
            IF NOT rownull THEN
                INSERT INTO fc_factura_d ( codigo, subcodigo, cantidad, valoruni, 
                              valor, prefijo, documento,base_imponible,total_pagar)
                VALUES ( tafc_factura_d[x].codigo, 
                    tafc_factura_d[x].subcodigo, 
                    tafc_factura_d[x].cantidad,
                    tafc_factura_d[x].valoruni, 
                    tafc_factura_d[x].valor,
                    rec_factura_m.prefijo ,rec_factura_m.documento,
                    tafc_factura_d[x].valor,
                   tafc_factura_d[x].valor)
                    LET acumulado = acumulado + tafc_factura_d[x].valor
                    LET total_renglones=total_renglones+1
                    DISPLAY acumulado
                    DISPLAY total_renglones
            IF status < 0 THEN --4
                LET gerrflag = TRUE
                DISPLAY "El error: " , STATUS, " " , SQLERRMESSAGE
                EXIT FOR 
            END IF --4
        END IF --3
    END FOR
    INSERT INTO fc_factura_tot (prefijo, documento, totreg, importebruto,         
                                    baseimponible, baseconimpu, total_descuentos,
                                    total_cargos, total_anticipos, total_factura,
                                    moneda, trm,fecha_trm)
        VALUES (rec_factura_m.prefijo, rec_factura_m.documento, total_renglones,
                acumulado,acumulado,acumulado,0,0,0,acumulado,"COP", 0, TODAY )
                IF status < 0 THEN--5
                    LET gerrflag = TRUE
                    DISPLAY "El error: " , STATUS, " " , SQLERRMESSAGE
                END IF --5
 
   END IF  --2
 else
  LET gerrflag = TRUE
 end IF --1
 IF NOT gerrflag THEN --1
  COMMIT WORK
  LET recg_factura_m.* = rec_factura_m.*
  INITIALIZE rec_factura_m.* TO NULL
 MENU "Información"  ATTRIBUTE( style= "dialog", 
                   comment= " La información de documento fue Adicionada...  "  ,
                   image= "information")
       COMMAND "Aceptar"
       CLEAR FORM
         EXIT MENU
     END MENU
 ELSE
  ROLLBACK WORK
  DISPLAY "El error: " , STATUS, " " , SQLERRMESSAGE
  MENU "Información"  ATTRIBUTE( style= "dialog", 
                            comment= " La adición fue cancelada      "  ,
                            image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
     GOTO adi_documento   
 END IF--1
 ELSE
    ROLLBACK WORK
    
    MENU "Información"  ATTRIBUTE( style= "dialog", 
                            comment= " No hay items que agregar al detalle del documento soporte      "  ,
                            image= "information")
       COMMAND "Aceptar"
         EXIT MENU
         
     END MENU
     GOTO adi_documento   
END IF 
MESSAGE "" 
        
END FUNCTION 

FUNCTION fc_factura_mgetcurr( tpprefijo, tpdocumento )
 DEFINE tpdocumento LIKE fc_factura_m.documento
 DEFINE tpprefijo LIKE fc_factura_m.prefijo
 INITIALIZE rec_factura_m.* TO NULL
 SELECT fc_factura_m.prefijo, fc_factura_m.documento, fc_factura_m.numfac, fc_factura_m.cufe, 
        fc_factura_m.fecha_elaboracion, fc_factura_m.fecha_factura, fc_factura_m.hora,
        fc_factura_m.nit, fc_factura_m.forma_pago,
        fc_factura_m.medio_pago,  
        fc_factura_m.fecha_vencimiento,
        fc_factura_m.nota1, fc_factura_m.estado,
        fc_factura_m.codest, fc_factura_m.fecest, fc_factura_m.horaest, fc_factura_m.codcop,
        fc_factura_m.docu
   INTO rec_factura_m.*
  FROM fc_factura_m
  WHERE fc_factura_m.prefijo = tpprefijo
    AND fc_factura_m.documento = tpdocumento
   ORDER BY  fc_factura_m.prefijo,  fc_factura_m.numfac 
 CALL fc_factura_mgetdetail()
END FUNCTION

FUNCTION fc_factura_mshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum  INTEGER
 DISPLAY "" AT glastline,1
 IF rec_factura_m.documento IS NULL THEN
  MESSAGE  "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum,") Borrado" --AT glastline,33
 ELSE
  MESSAGE  "Localizacion : ( Actual ", rownum,"/ Existen ", maxnum, ")" --AT glastline,1
 END IF
 CALL fc_factura_mdetail()
END FUNCTION

FUNCTION fc_factura_mquery( exist )
 DEFINE answer CHAR(1),
  exist, curr, cnt SMALLINT,
  tpprefijo           LIKE fc_factura_m.prefijo,
  tpdocumento         LIKE fc_factura_m.documento,
  where_info,
  query_text         CHAR(400)
  DEFINE arr_usuarios    datos
  
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 DISPLAY "" AT 1,1
 MESSAGE  "Estado : CONSULTA DE FACTURAS" 
 CLEAR FORM
 CONSTRUCT where_info
  ON  documento, prefijo, numfac, cufe, fecha_elaboracion, fecha_factura, hora, nit, fecha_vencimiento,
    medio_pago, forma_pago, nota1, estado, codest, fecest, horaest  
  FROM  documento, prefijo, numfac, cufe, fecha_elaboracion, fecha_factura, hora, nit, fecha_vencimiento,
    medio_pago, forma_pago, nota1, estado, codest, fecest, horaest
 IF int_flag THEN
   CALL FGL_WINMESSAGE( "Administrador", " CONSULTA CANCELADA", "stop")
   RETURN exist
 END IF
 MESSAGE  "Buscando la factura(s), porfavor espere ..." --AT 2,1
 LET query_text = " SELECT fc_factura_m.prefijo,fc_factura_m.documento",
                  " FROM fc_factura_m WHERE ", where_info CLIPPED,
                  " AND prefijo in ( select unique prefijo from fc_prefijos_usu",
                  " WHERE usu_elabora = \"",musuario,"\" )",
                  " ORDER BY fc_factura_m.prefijo,fc_factura_m.documento ASC"
 PREPARE s_sfc_factura_m FROM query_text
 DECLARE c_sfc_factura_m SCROLL CURSOR FOR s_sfc_factura_m
 LET cnt = 0
 FOREACH c_sfc_factura_m INTO tpprefijo,tpdocumento
  LET cnt = cnt + 1
 END FOREACH
 IF ( cnt > 0 ) THEN
  OPEN c_sfc_factura_m
  FETCH FIRST c_sfc_factura_m INTO tpprefijo,tpdocumento
  LET curr = 1
  CALL fc_factura_mgetcurr( tpprefijo,tpdocumento )
  CALL fc_factura_mshowcurr( curr, cnt )
 ELSE
  --DISPLAY "" AT 1,10
  --DISPLAY "" AT 2,1
  CALL FGL_WINMESSAGE( "Administrador", " LA FACTURA NO EXISTE  ", "stop")
  --DISPLAY "LA FACTURA NO EXISTE" AT 1,10 ATTRIBUTE(REVERSE) 
  --sleep 2
  RETURN exist
 END IF
 DISPLAY "" AT 2,1
 MENU ":"
  COMMAND "Primero" "Desplaza al primer Documento en consulta"
   HELP 5
   FETCH FIRST c_sfc_factura_m INTO tpprefijo,tpdocumento
   LET curr = 1
   CALL fc_factura_mgetcurr( tpprefijo,tpdocumento )
   CALL fc_factura_mshowcurr( curr, cnt )
  COMMAND "Ultimo" "Desplaza al ultimo Documento en consulta"
   HELP 6
   FETCH LAST c_sfc_factura_m INTO tpprefijo,tpdocumento
   LET curr = cnt
   CALL fc_factura_mgetcurr( tpprefijo,tpdocumento )
   CALL fc_factura_mshowcurr( curr, cnt )
  COMMAND "Inmediato" "Se desplaza al sigiente Documento en consulta"
   HELP 7
   IF ( curr = cnt ) THEN
    FETCH FIRST c_sfc_factura_m INTO tpprefijo,tpdocumento
    LET curr = 1
   ELSE
    FETCH NEXT c_sfc_factura_m INTO tpprefijo,tpdocumento
    LET curr = curr + 1
   END IF
   CALL fc_factura_mgetcurr( tpprefijo,tpdocumento )
   CALL fc_factura_mshowcurr( curr, cnt )
  COMMAND "Anterior" "Se desplaza al factura anterior"
   HELP 8
   IF ( curr = 1 ) THEN
    FETCH LAST c_sfc_factura_m INTO tpprefijo,tpdocumento
    LET curr = cnt
   ELSE
    FETCH PREVIOUS c_sfc_factura_m INTO tpprefijo,tpdocumento
    LET curr = curr - 1
   END IF
   CALL fc_factura_mgetcurr( tpprefijo,tpdocumento )
   CALL fc_factura_mshowcurr( curr, cnt )
  COMMAND "Listar" "Lista los servicios del factura en consulta"
   LET mcodmen="FC33"
   CALL opcion() RETURNING op
   if op="S" THEN 
    IF rec_factura_m.documento IS NULL THEN
     CONTINUE MENU
    ELSE
     CALL fc_factura_mview()
     CALL fc_factura_mdetail()
    END IF
   END IF 
  COMMAND "Modifica" "Modifica la Factura Para El Envio a La DIAN."
   LET mcodmen="FC31"
   CALL opcion() RETURNING op
   if op="S" THEN 
    IF rec_factura_m.documento IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_factura_m
     CALL fc_factura_mupdate()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL fc_factura_mgetcurr( tpprefijo, tpdocumento )
     CALL fc_factura_mshowcurr( curr, cnt )
     OPEN c_sfc_factura_m
    end if 
   end IF
  COMMAND "Borra" "Elimina la Factura en consulta."
   LET mcodmen="FC31"
   CALL opcion() RETURNING op
   if op="S" THEN 
    IF rec_factura_m.documento IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_factura_m
     CALL fc_factura_mremove()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CALL fc_factura_mshowcurr( curr, cnt )
     END if 
     OPEN c_sfc_factura_m
    end if 
   end if 
  COMMAND "Aprobar" "Aprobar El Documento Soporte como definitivo para enumerarlo"
   LET mcodmen="FC34"
   CALL opcion() RETURNING op
   if op="S" THEN 
    IF rec_factura_m.documento IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_factura_m
     --LET mentra="N"
     IF rec_factura_m.estado="B" THEN
        CALL aprueba_factu("7")
     ELSE
      CALL FGL_WINMESSAGE( "Administrador", "EL ESTADO DE EL DOCUMENTO SOPORTE NO ES BORRADOR", "stop")
     END if  
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL fc_factura_mshowcurr( curr, cnt )
     OPEN c_sfc_factura_m
    END IF
   end IF

   COMMAND "Imprimir" "Imprimir el Documento Soporte aprobado"
    IF rec_factura_m.documento IS NULL THEN
     CONTINUE MENU
    ELSE
     CALL descarga_documento("7", rec_factura_m.prefijo, rec_factura_m.numfac)
     END IF 
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 10
   IF rec_factura_m.documento IS NULL THEN
    LET exist = FALSE
   ELSE
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sfc_factura_m
 DISPLAY "" AT glastline,1
 RETURN exist
END FUNCTION

FUNCTION fc_factura_mview()
 DEFINE tp   RECORD
   codigo    LIKE fc_factura_d.codigo,
   descripcion LIKE fc_servicios.descripcion,
   subcodigo    LIKE fc_factura_d.subcodigo,
   descri    LIKE fc_sub_servicios.descripcion,
   descrii    LIKE fc_beneficios.descripcion,
   cantidad  LIKE fc_factura_d.cantidad,
   valoruni  LIKE fc_factura_d.valoruni,
   valor     LIKE fc_factura_d.valor
  END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 23
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fc_factura_d
  WHERE  fc_factura_d.prefijo = rec_factura_m.prefijo
    AND  fc_factura_d.documento = rec_factura_m.documento
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", " NO HAY REGISTROS PARA VISUALIZAR ", "stop")
  RETURN
 END IF
 --DISPLAY "" AT 1,10
 --DISPLAY "" AT 2,1
 MESSAGE  "Trabajando por favor espere ... " --AT 2,1
 DECLARE c_bafc_factura_m SCROLL CURSOR FOR
  SELECT fc_factura_d.codigo, fc_servicios.descripcion, fc_factura_d.subcodigo, fc_sub_servicios.descripcion,
   fc_factura_d.cod_bene, fc_beneficios.descripcion,
   fc_factura_d.codcat, fc_factura_d.cantidad, fc_factura_d.valoruni, 
   fc_factura_d.iva, fc_factura_d.impc, fc_factura_d.subsi, fc_factura_d.valorbene, fc_factura_d.valor
   FROM fc_factura_d, fc_servicios, OUTER fc_sub_servicios, OUTER fc_beneficios
   WHERE  fc_factura_d.prefijo = rec_factura_m.prefijo
     AND  fc_factura_d.documento = rec_factura_m.documento
     AND fc_factura_d.codigo = fc_servicios.codigo
     AND fc_factura_d.subcodigo = fc_sub_servicios.codigo
   ORDER BY fc_factura_d.codigo ASC
 OPEN c_bafc_factura_m
 --DISPLAY "" AT lastline,1
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fc_factura_mshowview( currrow, prevrow, pagenum ) RETURNING pagenum, prevrow 
 --DISPLAY "" AT lastline,1
 MESSAGE  "Localizacion : ( Actual ", currrow,"/ Existen ", maxnum, ")" --AT lastline,1
 MENU "VISUALIZA"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   HELP 5
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL fc_factura_mshowview( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   --DISPLAY "" AT lastline,1
   MESSAGE  "Localizacion : ( Actual ", currrow,"/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL fc_factura_mshowview( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   --DISPLAY "" AT lastline,1
   MESSAGE  "Localizacion : ( Actual ", currrow,"/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND key ("R") "aRriba" "Se desplaza una pagina arriba"
   HELP 7
   IF (currrow - 11) <= 0 THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow - 11
   END IF
   CALL fc_factura_mshowview( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   --DISPLAY "" AT lastline,1
   MESSAGE  "Localizacion : ( Actual ", currrow,"/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND key("B") "aBajo" "Se desplaza una pagina abajo"
   HELP 8
   IF (currrow + 11) > maxnum THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow + 11
   END IF
   CALL fc_factura_mshowview( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
   DISPLAY "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" AT lastline,1
  COMMAND "Vaya" "Se desplaza al registro No.()."
   HELP 9
   LET status = -1
   WHILE ( status < 0 )
    LET status = 1
    PROMPT "Entre el numero de la posicion (1 - ", maxnum, "): " FOR gotorow
    HELP 4
   END WHILE
   IF gotorow IS NULL OR int_flag THEN
    LET int_flag = FALSE
    LET gotorow = currrow
   END IF
   IF gotorow > maxnum THEN
    LET gotorow = maxnum
   END IF
   IF gotorow < 1 THEN
    LET gotorow = 1
   END IF
   LET currrow = gotorow
   CALL fc_factura_mshowview( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
   DISPLAY "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" AT lastline,1
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   EXIT MENU
 END MENU
 CLOSE c_bafc_factura_m
 DISPLAY "" AT lastline,1
END FUNCTION

FUNCTION fc_factura_mshowview( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   codigo    LIKE fc_factura_d.codigo,
   descripcion LIKE fc_servicios.descripcion,
   subcodigo    LIKE fc_factura_d.subcodigo,
   descri    LIKE fc_sub_servicios.descripcion,
   --cod_bene  LIKE fc_factura_d.cod_bene,
   descrii    LIKE fc_beneficios.descripcion,
   --codcat    LIKE fc_factura_d.codcat,
   cantidad  LIKE fc_factura_d.cantidad,
   valoruni  LIKE fc_factura_d.valoruni,
   --iva       LIKE fc_factura_d.iva,
   --impc      LIKE fc_factura_d.impc,
   --subsi     LIKE fc_factura_d.subsi,
   --valorbene  LIKE fc_factura_d.valorbene,
   valor     LIKE fc_factura_d.valor
  END RECORD,
  scrmax,scrcurr,scrprev,currrow,prevrow,pagenum,newpagenum,x,y,scrfrst INTEGER
 LET scrmax = 11
 LET newpagenum = 1
 LET scrcurr = currrow MOD scrmax
 IF scrcurr > 0 THEN
  LET newpagenum = ( currrow/scrmax ) + 1
 ELSE
  LET scrcurr = scrmax
  LET newpagenum = ( currrow/scrmax )
 END IF
 IF newpagenum <> pagenum THEN
  LET pagenum = newpagenum
  LET scrfrst = currrow - scrcurr + 1
  FETCH ABSOLUTE scrfrst c_bafc_factura_m INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO ofe[x].* ATTRIBUTE(REVERSE)
   ELSE
    DISPLAY tp.* TO ofe[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_bafc_factura_m INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO ofe[y].*
     END FOR
     EXIT FOR
    END IF
   END IF
  END FOR
 ELSE
  LET scrprev = prevrow MOD scrmax
  IF scrprev = 0 THEN
   LET scrprev = scrmax
  END IF
  FETCH ABSOLUTE prevrow c_bafc_factura_m INTO tp.*
  DISPLAY tp.* TO ofe[scrprev].*
  FETCH ABSOLUTE currrow c_bafc_factura_m INTO tp.*
  DISPLAY tp.* TO ofe[scrcurr].* ATTRIBUTE(REVERSE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION

FUNCTION mvalorfac(y)
 define y INTEGER
  IF mfc_prefijos.redondeo ="S"  THEN
   LET tafc_factura_d[y].valor=tafc_factura_d[y].cantidad*tafc_factura_d[y].valoruni
  
 ELSE
   LET tafc_factura_d[y].valor=tafc_factura_d[y].cantidad*tafc_factura_d[y].valoruni
  
  END IF 
END FUNCTION
{
function imprime_factu()
DEFINE handler om.SaxDocumentHandler
 DEFINE mprefijo char(5)
 define ubicacion char(80)
 define mdoo,cnt integer
 define mtotfacc like fc_factura_d.valoruni
 define mtotivaa like fc_factura_d.iva
 DEFINE op char(1)
 let mprefijo=null
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null then 
  return
 end if
 let mdo=null
 let mdoo=null
 prompt "No. de Factura =====>> : " for mdoo
 if mdoo is null then 
  return
 end if
 let mdo=mdoo using "&&&&&&&"
 if mdo is null then 
  return
 end IF
 let op=null
 prompt "Digite 1>Forma Preimpresa - 2>Hoja Blanca =====>> : " for op
 if op is null OR (op<>"1" AND op<>"2") then 
  return
 end if
 if mdo is not null then 
  MESSAGE  "Trabajando por favor espere ... " --AT 2,1
  let cnt=0
  select count(*) into cnt from fc_factura_m 
   where prefijo=mprefijo AND numfac=mdoo
  if cnt is null then let cnt=0 end if
  if cnt=0 THEN
   CALL FGL_WINMESSAGE( "Administrador", " LA FACTURA DIGITADA NO EXISTE ", "stop")
   return
  else
   initialize mfc_factura_m.* to null
   select * into mfc_factura_m.* from fc_factura_m 
    where prefijo=mprefijo AND numfac=mdoo
   if mfc_factura_m.estado<>"A" THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA FACTURA DIGITADA NO ESTA APROBADA ", "stop")
    return
   end if
  end if
 end if
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
let ubicacion=fgl_getenv("HOME"),"/reportes/factura_",mdo
let ubicacion=ubicacion CLIPPED
IF op="1" THEN
 start report rfactu to ubicacion
ELSE
-- start report hrfactu to ubicacion
 start report hrfactu_r  TO XML HANDLER HANDLER
END if 
initialize mfc_factura_m.* to null
select * into mfc_factura_m.* from fc_factura_m 
where prefijo=mprefijo AND numfac=mdoo
initialize mfc_prefijos.* to null
select * into mfc_prefijos.* from fc_prefijos 
where prefijo=mprefijo
let mtotfacc=0
let mtotivaa=0
select sum(fc_factura_d.iva*fc_factura_d.cantidad) into mtotivaa
 from fc_factura_d
where prefijo=mprefijo AND numfac=mdoo
LET mtotivaa=nomredondea(mtotivaa)
select sum(fc_factura_d.valor) into mtotfacc
 from fc_factura_d
where prefijo=mprefijo AND documento=mfc_factura_m.documento
initialize mfc_terceros.* to null
select * into mfc_terceros.* from fc_terceros 
 where nit=mfc_factura_m.nit
initialize mgener09.* to null 
SELECT * into mgener09.* FROM gener09
  WHERE codzon = mfc_terceros.zona
initialize mfc_factura_d.* to null
declare prfactu cursor for
select * from fc_factura_d
 where prefijo=mfc_factura_m.prefijo AND documento=mfc_factura_m.documento
  order by codigo,subcodigo
foreach prfactu into mfc_factura_d.*
 IF op="1" THEN
  output to report rfactu(mtotfacc,mtotivaa)
 ELSE
 --output to report hrfactu(mtotfacc,mtotivaa)
  output to report hrfactu_r(mtotfacc,mtotivaa)
 END if 
end FOREACH
IF op="1" THEN
 finish report rfactu
ELSE
 --finish report hrfactu
 finish report hrfactu_r
END if 
call impsn(ubicacion)
END FUNCTION
REPORT rfactu(mtotfacc,mtotivaa)
define mx1,mx2 char(1)
define mvaloruni,mtotfac,mtotfacc like fc_factura_d.valoruni
define mvaloriva,mtotiva,mtotivaa like fc_factura_d.iva
define mvalorsub,mtotsub,mtotsubb,mvalant,mvalorsubben,mtotsubben like fc_factura_d.subsi
DEFINE mrazsoc char(50)
DEFINE mnot1,mnot2,mnot3,mnot4,mnot5 char(80)
output
 top margin 0
 bottom margin 0
 left margin 0
 right margin 80
 page length 38
format
 page header
 if pageno="1" then
  let mtotfac=0
  let mtotiva=0
  let mtotsub=0
  let mtotsubb=0
 end if
 let mx1=null
 let mx2=null
 if mfc_factura_m.forma_pago="1" then
  let mx1="X"
 end if
 if mfc_factura_m.forma_pago="2" then
  let mx2="X"
 end IF
 let mrazsoc=NULL
 IF mfc_terceros.tipo_persona="1" THEN
  let mrazsoc=mfc_terceros.razsoc
 ELSE
  let mrazsoc=mfc_terceros.primer_apellido clipped," ",mfc_terceros.segundo_apellido clipped," ",
              mfc_terceros.primer_nombre clipped," ",mfc_terceros.segundo_nombre clipped
 END if
 skip 9 lines
 print column 10,mrazsoc,
       column 70,mfc_factura_m.nit
 print column 100,day(mfc_factura_m.fecha_elaboracion),
       column 107,month(mfc_factura_m.fecha_elaboracion),
       column 119,year(mfc_factura_m.fecha_elaboracion)
 skip 1 lines      
 print column 15,mfc_terceros.direccion,
       column 75,mx1,
       column 95,mx2
 skip 1 lines
 print column 15,mgener09.detzon[1,50],
       column 75,mfc_terceros.telefono,
       column 100,day(mfc_factura_m.fecha_vencimiento),
       column 107,month(mfc_factura_m.fecha_vencimiento),
       column 119,year(mfc_factura_m.fecha_vencimiento)
 skip 3 LINES
 LET mnot1=NULL
 LET mnot1=mfc_factura_m.nota1[1,80]
 LET mnot2=NULL
 LET mnot2=mfc_factura_m.nota1[81,160]
 LET mnot3=NULL
 LET mnot3=mfc_factura_m.nota1[161,240]
 LET mnot4=NULL
 LET mnot4=mfc_factura_m.nota1[241,320]
 LET mnot5=NULL
 LET mnot5=mfc_factura_m.nota1[321,400]
 --print  column 05,mfc_factura_m.nota1
 print  column 05,mnot1
 print  column 05,mnot2
 print  column 05,mnot3
 print  column 05,mnot4
 print  column 05,mnot5
 skip 1 lines
on every row
 let mvaloruni=0
 let mvaloruni=mfc_factura_d.valoruni
 let mtotfac=mtotfac+(mvaloruni*mfc_factura_d.cantidad)
 let mtotiva=mtotiva+(mfc_factura_d.iva*mfc_factura_d.cantidad)
 let mtotsub=mtotsub+(mfc_factura_d.subsi*mfc_factura_d.cantidad)
 let mtotsubben=mtotsubben+(mfc_factura_d.valorbene*mfc_factura_d.cantidad)
 
 initialize rec_servi.* to null
 select * into rec_servi.* from fc_servicios
 where codigo=mfc_factura_d.codigo
 initialize mfc_sub_servicios.* to null
 select * into mfc_sub_servicios.* from fc_sub_servicios
 where codigo=mfc_factura_d.subcodigo
 print  column 05,mfc_factura_d.codigo,
        column 17,mfc_factura_d.cantidad using "&&&&",
        column 30,rec_servi.descripcion[1,30] clipped,"-",mfc_sub_servicios.descripcion[1,30] clipped,
        column 90,mvaloruni using "##,###,##&.&&",
        column 110,mvaloruni*mfc_factura_d.cantidad using "###,###,##&.&&"

  --on last ROW
   
 page TRAILER
 LET mtotiva=nomredondea(mtotiva)
 LET mtotsub=nomredondea(mtotsub)
 LET mtotfac=nomredondea(mtotfac)
 LET mvalant = 0
 SELECT sum(valor) INTO mvalant
  FROM fc_factura_anti
 WHERE prefijo = mfc_factura_m.prefijo
 AND documento = mfc_factura_m.documento
 IF mvalant IS NULL THEN
  LET mvalant = 0
 END IF
 let mvalche=(mtotfac+mtotiva)-(mtotsub+mvalant+mtotsubben)
 PRINT  COLUMN 30,"ANTICIPOS RECIBIDOS",
        column 110,mvalant*-1 using "---,---,--&.&&"
 PRINT  COLUMN 30,"VALOR SUBSIDIO TARIFA",
        column 110,mtotsub*-1 using "---,---,--&.&&"
 PRINT  COLUMN 30,"VALOR SUBSIDIO BENEFICIO",
        column 110,mtotsubben*-1 using "---,---,--&.&&"       
 skip 1 lines       
 call letras()
 print  column 110,mtotfac-(mtotsub+mtotsubben) using "###,###,##&.&&"
 print  column 05,mletras1 clipped," ",mletras2 clipped,
        column 110,mtotiva using "###,###,##&.&&"
 print  column 110,(mtotfac+mtotiva)-(mtotsub+mvalant+mtotsubben) using "###,###,##&.&&"

 --skip to top of page
end REPORT

REPORT hrfactu(mtotfacc,mtotivaa)
define mx1,mx2 char(1)
define mvaloruni,mtotfac,mtotfacc like fc_factura_d.valoruni
define mvaloriva,mtotiva,mtotivaa like fc_factura_d.iva
define mvalorsub,mtotsub,mtotsubb, mvalant like fc_factura_d.subsi
DEFINE mrazsoc char(50)
DEFINE mdetalle char(100)
DEFINE mdet char(10)
output
 top margin 4
 bottom margin 4
 left margin 0
 right margin 132
 page length 66
format
 page header
 if pageno="1" then
  let mtotfac=0
  let mtotiva=0
  let mtotsub=0
 end IF
 let mtime=time
 print column 104, "FACTURA DE VENTA : ",mfc_factura_m.prefijo clipped," ",mfc_factura_m.numfac USING "#######"
 skip 1 LINES
 let mp1 = (132-length(mfc_empresa.razsoc clipped))/2
 print column mp1,mfc_empresa.razsoc
 let mp1 = (132-length("EDIFICIO SEDE: Avenida 2 Calle 14 Esquina"))/2
 print column mp1,"EDIFICIO SEDE: Avenida 2 Calle 14 Esquina"
 let mp1 = (132-length("PBX. 5836888"))/2
 print column mp1,"PBX. 5836888"
 let mp1 = (132-length("Cucuta - Norte de Santander"))/2
 print column mp1,"Cucuta - Norte de Santander"
 let mp1 = (132-length("NO SOMOS GRANDES CONTIBUYENTES RESOLUCION DIAN No. 0041 DEL 30/01/2014"))/2
 print column mp1,"NO SOMOS GRANDES CONTIBUYENTES RESOLUCION DIAN No. 0041 DEL 30/01/2014"
 skip 1 LINES
 PRINT COLUMN 115,"Fecha : ",mfc_factura_m.fecha_factura 

 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------"
 PRINT COLUMN 01,"DATOS DEL CLIENTE"
 let mrazsoc=NULL
 IF mfc_terceros.tipo_persona="1" THEN
  let mrazsoc=mfc_terceros.razsoc
 ELSE
  let mrazsoc=mfc_terceros.primer_apellido clipped," ",mfc_terceros.segundo_apellido clipped," ",
              mfc_terceros.primer_nombre clipped," ",mfc_terceros.segundo_nombre clipped
 END if
 skip 1 LINES
 print column 01,"Nombre     : ",mrazsoc,
       column 70,"Nit        : ",mfc_factura_m.nit
 print column 01,"Direccion  : ",mfc_terceros.direccion clipped,
       column 70,"Telefono   : ",mfc_terceros.telefono
 print column 01,"Ciudad     : ",mgener09.detzon
 CASE
  WHEN mfc_factura_m.forma_pago="1"
   LET mdet="CONTADO"
  WHEN mfc_factura_m.forma_pago="2"
   LET mdet="CREDITO"
 END case  
 print column 01,"Forma Pago : ",mdet 
 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------"
 PRINT COLUMN 01,"SERVI",
       COLUMN 07,"DESCRIPCION",
       COLUMN 75,"CANT",
       COLUMN 85,"VALOR UNITARIO",
       COLUMN 105,"VALOR SUBSIDIO",
       COLUMN 125,"VALOR TOTAL"
print "---------------------------------------------------------------",
      "------------------------------------------------------------------------------"
 on every row
 let mvaloruni=0
 let mvaloruni=mfc_factura_d.valoruni
 let mtotfac=mtotfac+(mvaloruni*mfc_factura_d.cantidad)
 let mtotiva=mtotiva+(mfc_factura_d.iva*mfc_factura_d.cantidad)
 let mtotsub=mtotsub+(mfc_factura_d.subsi*mfc_factura_d.cantidad)
 initialize rec_servi.* to null
 select * into rec_servi.* from fc_servicios
 where codigo=mfc_factura_d.codigo
 initialize mfc_sub_servicios.* to null
 select * into mfc_sub_servicios.* from fc_sub_servicios
 where codigo=mfc_factura_d.subcodigo
 print  column 01,mfc_factura_d.codigo,
        column 07,rec_servi.descripcion[1,35] clipped,"-",mfc_sub_servicios.descripcion[1,30] clipped,
        column 75,mfc_factura_d.cantidad using "&&&&",
        column 85,mvaloruni using "##,###,##&.&&",
        column 105,mfc_factura_d.subsi*mfc_factura_d.cantidad using "###,###,##&.&&",
        column 125,(mvaloruni-mfc_factura_d.subsi)*mfc_factura_d.cantidad using "###,###,##&.&&"
 --page TRAILER
 on last ROW
 INITIALIZE mgen02.* TO NULL
 select * into mgen02.* from gener02 where usuario=mfc_factura_m.usuario_add
 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------"
 skip 1 lines
 LET mtotiva=nomredondea(mtotiva)
 LET mtotsub=nomredondea(mtotsub)
 LET mtotfac=nomredondea(mtotfac)
 LET mvalant = 0
 SELECT sum(valor) INTO mvalant
  FROM fc_factura_anti
 WHERE prefijo = mfc_factura_m.prefijo
 AND documento = mfc_factura_m.documento
 IF mvalant IS NULL THEN
  LET mvalant = 0
 END IF  
 let mvalche=(mtotfac+mtotiva)-(mtotsub+mvalant)
 
 call letras()
 print  column 01,mletras1 clipped," ",mletras2 clipped 
 print  column 105,"SUBTOTAL",
        COLUMN 125, mtotfac using "###,###,##&.&&"
 PRINT  COLUMN 105,"SUBSIDIO OTORGADO",
        column 125,mtotsub*-1 using "---,---,--&.&&"
 print  COLUMN 105,"ANTICIPOS",
        column 125, mvalant*-1 using "---,---,--&.&&"       
 print  COLUMN 105,"IVA",
        column 125,mtotiva using "###,###,##&.&&"
 print  COLUMN 105,"TOTAL A PAGAR", 
        column 125,mtotfac+mtotiva-mtotsub-mvalant using "###,###,##&.&&"
 SKIP 4 LINES
 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------"
 print column 01,"Nota       : ",mfc_factura_m.nota1[1,100]
 PRINT column 01,mfc_factura_m.nota1[101,200]
 PRINT column 01,mfc_factura_m.nota1[201,300]
 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------"
 SKIP 3 LINES      
 PRINT COLUMN 1, "________________________________________________________"
 PRINT column 1, "      Elaboró : ", mgen02.nombre 
 SKIP 3 LINES
 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------"
 PRINT COLUMN 01,"FACTURA POR COMPUTADOR"
 PRINT COLUMN 01,"Autorizacion de Facturacion DIAN No. ",mfc_prefijos.num_auto clipped," Fecha. ",mfc_prefijos.fec_auto USING "yyyy/mm/dd" clipped
 PRINT COLUMN 01,"Numeracion Habilitada del ",mfc_prefijos.numini clipped," hasta el ",mfc_prefijos.numfin CLIPPED
 PRINT COLUMN 01,"Fecha Vencimiento ",mfc_prefijos.fec_ven USING "yyyy/mm/dd"
  --on last row
 --skip to top of page
end report
}
function imprime_ordenp(lb_preview, salida_reporte)
 DEFINE handler om.SaxDocumentHandler
  ,lb_preview        BOOLEAN
    ,salida_reporte    VARCHAR(20)
   ,tipo_grafico       VARCHAR(100) 
   ,lv_nombre_reporte  VARCHAR(100)
   ,nombre_plantilla   VARCHAR(100)
--   ,lsxd_manejador     OM.SaxDocumentHandler
 DEFINE mfc_factura_m RECORD LIKE fc_factura_m.*
 DEFINE mfc_factura_d RECORD LIKE fc_factura_d.*
 DEFINE mprefijo char(5)
 define ubicacion char(80)
 define mdoo,cnt,mdoo1 INTEGER
 DEFINE mdo1 CHAR(7)
 define mtotfacc like fc_factura_d.valoruni
 --define mtotivaa like fc_factura_d.iva
 let mprefijo=null
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null then 
  return
 end if
 let mdo=null
 let mdoo=null
 prompt "No. Interno Inicial =====>> : " for mdoo
 if mdoo is null then 
  return
 end if
 let mdo=mdoo using "&&&&&&&"
 if mdo is null then 
  return
 end IF
 let mdo1=null
 let mdoo1=null
 prompt "No. Interno Final =====>> : " for mdoo1
 if mdoo1 is null then 
  return
 end if
 let mdo1=mdoo1 using "&&&&&&&"
 if mdo1 is null then 
  return
 end if

 if mdo<=mdo1 then 
  MESSAGE  "Trabajando por favor espere ... " --AT 2,1
  let cnt=0
  select count(*) into cnt from fc_factura_m 
   where prefijo=mprefijo AND documento>=mdo AND documento<=mdo1
  if cnt is null then let cnt=0 end if
  if cnt=0 THEN
   CALL FGL_WINMESSAGE( "Administrador", " LA FACTURA DIGITADA NO EXISTE ", "stop")
   return
  else
   --initialize mfc_factura_m.* to null
   --select * into mfc_factura_m.* from fc_factura_m 
    --where prefijo=mprefijo AND documento=mdo
   --if mfc_factura_m.estado<>"B" THEN
    --CALL FGL_WINMESSAGE( "Administrador", " LA FACTURA DIGITADA NO ES BORRADOR ", "stop")
    --return
   --end IF
  
  end if
 end if
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
let ubicacion=fgl_getenv("HOME"),"/reportes/factura_b_",mdo
let ubicacion=ubicacion CLIPPED
--IF mprefijo="IPSC" THEN 
-- LET handler = configureOutputt("SVG",100,100,120,500) 
--LET HANDLER =RW_Inicializa("certificado","PDF","ordenes_pago.4rp")
-------
-------- 
  DISPLAY  "....",lv_nombre_reporte,salida_reporte, lb_preview
  LET handler = RW_Inicializa(lv_nombre_reporte,salida_reporte,"ordenes_pago.4rp", lb_preview)
    IF HANDLER IS NULL THEN
      DISPLAY "Error. El manejador no tiene información................."  
    RETURN
    END IF
     START REPORT brfactu_PDF TO XML HANDLER HANDLER
--ELSE  
-- start report brfactu to ubicacion
--END IF  
initialize mfc_prefijos.* to null
 select * into mfc_prefijos.* from fc_prefijos 
 where prefijo=mprefijo
initialize mfc_factura_m.* to NULL
DECLARE crordenmas CURSOR for
select * from fc_factura_m 
where prefijo=mprefijo AND documento>=mdo AND documento<=mdo1
--AND estado="B"
 ORDER BY documento
FOREACH crordenmas INTO mfc_factura_m.*
 --let mtotfac=0
 --let mtotiva=0
 --let mtotsub=0
 --let mtotsubben=0 
 let mtotfacc=0
 {let mtotivaa=0
 select sum(fc_factura_d.iva*fc_factura_d.cantidad) into mtotivaa
  from fc_factura_d
 where prefijo=mprefijo AND documento=mfc_factura_m.documento
 LET mtotivaa=nomredondea(mtotivaa)}
 select sum(fc_factura_d.valor) into mtotfacc
  from fc_factura_d
 where prefijo=mprefijo AND documento=mfc_factura_m.documento
 initialize mfc_terceros.* to NULL
 select * into mfc_terceros.* from fc_terceros 
  where nit=mfc_factura_m.nit
 initialize mgener09.* to NULL 
 SELECT * into mgener09.* FROM gener09
  WHERE codzon = mfc_terceros.zona
 --initialize mgener02.* to NULL 
 --SELECT * into mgener02.* FROM gener02
  --WHERE usuario = mfc_factura_m.usuario_add  
 initialize mfc_factura_d.* to NULL
 declare bprfactu cursor FOR
 select * from fc_factura_d
  where prefijo=mfc_factura_m.prefijo AND documento=mfc_factura_m.documento
  ORDER BY documento
 -- order by codigo,subcodigo
 foreach bprfactu into mfc_factura_d.*
  {IF mfc_factura_d.valorbene  > 0  THEN
    INITIALIZE mfc_beneficios.*  TO NULL
     SELECT * INTO mfc_beneficios.*
      FROM fc_beneficios
      WHERE codigo = mfc_factura_d.cod_bene
  END if }
   output to report brfactu_PDF(mfc_factura_m.*,mfc_factura_d.*,mtotfacc)
   --output to report brfactu(mfc_factura_m.*,mfc_factura_d.*,mtotfacc,mtotivaa)
 -- END IF 
 end FOREACH
END foreach
--IF mprefijo="IPSC" THEN 
--finish report brfactu2
finish report brfactu_PDF
--ELSE 
--finish report brfactu
--END if

END FUNCTION
{
REPORT brfactu(mfc_factura_m,mfc_factura_d,mtotfacc,mtotivaa)
DEFINE mfc_factura_m RECORD LIKE fc_factura_m.*
DEFINE mfc_factura_d RECORD LIKE fc_factura_d.*
define mx1,mx2 char(1)
define mvaloruni,mtotfacc like fc_factura_d.valoruni
define mvaloriva,mtotivaa like fc_factura_d.iva
define mvalorsub,mvalorsubben,mtotsubb,mvalant,mivasub like fc_factura_d.subsi
DEFINE mrazsoc char(50)
DEFINE mdetben CHAR(20)
output
 top margin 1
 bottom margin 3
 left margin 0
 right margin 132
 page length 66
format
 page header
 --if pageno="1" then
  
 --end IF
 let mtime=time
 print column 1,"Fecha : ",today," + ",mtime,
       column 121,"Pag No. ",pageno using "####"
 skip 1 LINES

 let mp1 = (132-length(mfc_empresa.razsoc clipped))/2
 print column mp1,mfc_empresa.razsoc
 let mp1 = (132-length("ORDEN DE PAGO"))/2
 print column mp1,"ORDEN DE PAGO"
 skip 1 LINES

 before group of mfc_factura_m.documento
 let mtotfac=0
 let mtotiva=0
 let mtotsub=0
 let mtotsubben=0 
 
 print column 01, "Prefijo   :  ",mfc_factura_m.prefijo,"    Numero Interno : ",mfc_factura_m.documento,
       COLUMN 110,"Fecha    : ",mfc_factura_m.fecha_elaboracion 
 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------"
 let mrazsoc=NULL
 IF mfc_terceros.tipo_persona="1" THEN
  let mrazsoc=mfc_terceros.razsoc
 ELSE
  let mrazsoc=mfc_terceros.primer_apellido clipped," ",mfc_terceros.segundo_apellido clipped," ",
              mfc_terceros.primer_nombre clipped," ",mfc_terceros.segundo_nombre clipped
 END if
 --skip 1 lines
 print column 01,"Cliente   : ",mrazsoc,
       column 70,"Nit       : ",mfc_factura_m.nit
 print column 01,"Direccion : ",mfc_terceros.direccion clipped,
             column 70,"Telefono  : ",mfc_terceros.telefono
 print column 01,"Ciudad    : ",mgener09.detzon 
 print column 01,"Nota      : ",mfc_factura_m.nota1 CLIPPED 
 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------"
 PRINT COLUMN 01,"SERVI",
       COLUMN 07,"CANT",
       COLUMN 20,"DESCRIPCION",
       COLUMN 80,"VALOR UNITARIO",
       COLUMN 100,"VALOR SUBSIDIO",
       COLUMN 120,"VALOR TOTAL"
print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------"

after group of mfc_factura_m.documento
 LET mdetben = "BENEFICIO OTORGADO"
 INITIALIZE mgen02.* TO NULL
 select * into mgen02.* from gener02 where usuario=mfc_factura_m.usuario_add
 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------"
 --skip 1 LINES
 IF mfc_prefijos.redondeo ="S" THEN
   LET mtotiva=nomredondea(mtotiva)
   LET mtotsub=nomredondea(mtotsub)
   LET mtotfac=nomredondea(mtotfac)
 END IF
  LET mvalant = 0
 SELECT sum(valor) INTO mvalant
  FROM fc_factura_anti
 WHERE prefijo = mfc_factura_m.prefijo
 AND documento = mfc_factura_m.documento
 IF mvalant IS NULL THEN
  LET mvalant = 0
 END IF 
 IF mtotsubben <> 0 THEN
  LET mdetben = mfc_beneficios.descripcion
 END IF
 DISPLAY "valorsubsiido...", mtotsub  
 let mvalche=nomredondea((mtotfac+mtotiva)-(mtotsub+mvalant+mtotsubben))
 call letras()
 print  column 01,mletras1 clipped," ",mletras2 clipped 
 print  column 100,"SUBTOTAL",
        COLUMN 120, mtotfac using "###,###,##&.&&"
 PRINT  COLUMN 100,"SUBSIDIO OTORGADO",
        column 120,mtotsub*-1 using "---,---,--&.&&"
 PRINT  COLUMN 100,mdetben,
        column 120,mtotsubben*-1 using "---,---,--&.&&"       
 print  COLUMN 100,"ANTICIPOS",
        column 120, mvalant*-1 using "---,---,--&.&&"       
 print  COLUMN 100,"IVA",
        column 120,mtotiva using "###,###,##&.&&"

      
 IF mfc_prefijos.redondeo ="S" THEN       
   print  COLUMN 100,"TOTAL A PAGAR", 
         column 120,nomredondea((mtotfac+mtotiva)-(mtotsub+mvalant+mtotsubben)) using "###,###,##&.&&"
 ELSE        
   print  COLUMN 100,"TOTAL A PAGAR", 
         column 120,nomredondea((mtotfac+mtotiva)-(mtotsub+mvalant+mtotsubben)) using "###,###,##&.&&"
 END IF
 SKIP 2 LINES
 PRINT COLUMN 1,"OBSERVACION: ",mfc_prefijos.nota[1,50]
 PRINT COLUMN 14,mfc_prefijos.nota[51,100] 
 SKIP 2 LINES
 PRINT COLUMN 1, "________________________________________________________"
 PRINT column 1, "      Elaboró : ", mgen02.nombre
 skip to top of page

       
 on every ROW
 initialize rec_servi.* to null
 select * into rec_servi.* from fc_servicios
 where codigo=mfc_factura_d.codigo
 
 let mvaloruni=0
 let mvaloruni=mfc_factura_d.valoruni
 let mtotfac=mtotfac+(mvaloruni*mfc_factura_d.cantidad)
 let mtotiva=mtotiva+(mfc_factura_d.iva*mfc_factura_d.cantidad)
 let mtotsub=mtotsub+(mfc_factura_d.subsi*mfc_factura_d.cantidad)
 let mtotsubben=mtotsubben+(mfc_factura_d.valorbene*mfc_factura_d.cantidad)
 initialize mfc_sub_servicios.* to null
 select * into mfc_sub_servicios.* from fc_sub_servicios
 where codigo=mfc_factura_d.subcodigo
 print  column 01,mfc_factura_d.codigo,
        column 7,mfc_factura_d.cantidad using "&&&&",
        column 20,rec_servi.descripcion clipped,"-",mfc_sub_servicios.descripcion clipped,
        column 80,mvaloruni using "###,###,##&.&&",
        column 100,mfc_factura_d.subsi*mfc_factura_d.cantidad using "###,###,##&.&&",
        column 120,(mvaloruni-(mfc_factura_d.subsi+mfc_factura_d.valorbene))*mfc_factura_d.cantidad using "###,###,##&.&&"
 --page TRAILER

 on last ROW

end REPORT

REPORT brfactu2(mfc_factura_m,mfc_factura_d,mtotfacc,mtotivaa)
DEFINE mfc_factura_m RECORD LIKE fc_factura_m.*
DEFINE mfc_factura_d RECORD LIKE fc_factura_d.*
define mx1,mx2 char(1)
define mvaloruni,mtotfac,mtotfacc like fc_factura_d.valoruni
define mvaloriva,mtotiva,mtotivaa like fc_factura_d.iva
define mvalorsub,mvalorsubben,mtotsub,mtotsubben,mtotsubb,mvalant,mivasub like fc_factura_d.subsi
DEFINE mrazsoc char(50)
output
 top margin 4
 bottom margin 4
 left margin 0
 right margin 132
 page length 66
format
 page header
 if pageno="1" then
  let mtotfac=0
  let mtotiva=0
  let mtotsub=0
  let mtotsubben=0
 end IF
 let mtime=time
 print column 1,"Fecha : ",today," + ",mtime,
       column 200,"Pag No. ",pageno using "####"
 skip 1 LINES

 let mp1 = (250-length(mfc_empresa.razsoc clipped))/2
 print column mp1,mfc_empresa.razsoc
 let mp1 = (132-length("ORDEN DE PAGO"))/2
 print column mp1,"ORDEN DE PAGO  prueba"
 skip 1 lines
 print column 01, "Prefijo   :  ",mfc_factura_m.prefijo,"    Numero Interno : ",mfc_factura_m.documento,
       COLUMN 200,"Fecha    : ",mfc_factura_m.fecha_elaboracion 
 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------",
       "-------------------------------------------------------------------"
      
 let mrazsoc=NULL
 IF mfc_terceros.tipo_persona="1" THEN
  let mrazsoc=mfc_terceros.razsoc
 ELSE
  let mrazsoc=mfc_terceros.primer_apellido clipped," ",mfc_terceros.segundo_apellido clipped," ",
              mfc_terceros.primer_nombre clipped," ",mfc_terceros.segundo_nombre clipped
 END if
 skip 1 lines
 print column 01,"Cliente   : ",mrazsoc,
       column 200,"Nit       : ",mfc_factura_m.nit
 print column 01,"Direccion : ",mfc_terceros.direccion clipped,
             column 200,"Telefono  : ",mfc_terceros.telefono
 print column 01,"Ciudad    : ",mgener09.detzon 
 print column 01,"Nota      : ",mfc_factura_m.nota1
 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------",
       "-------------------------------------------------------------------"
      
 PRINT COLUMN 01,"SERVI",
       COLUMN 50,"CANT",
       COLUMN 70,"DESCRIPCION",
       COLUMN 180,"VALOR UNITARIO",
       COLUMN 220,"VALOR SUBSIDIO",
       COLUMN 250,"VALOR TOTAL"
print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------",
       "-------------------------------------------------------------------"
     
 on every ROW
 initialize rec_servi.* to null
 select * into rec_servi.* from fc_servicios
 where codigo=mfc_factura_d.codigo
 
 let mvaloruni=0
 let mvaloruni=mfc_factura_d.valoruni
 let mtotfac=mtotfac+(mvaloruni*mfc_factura_d.cantidad)
 let mtotiva=mtotiva+(mfc_factura_d.iva*mfc_factura_d.cantidad)
 let mtotsub=mtotsub+(mfc_factura_d.subsi*mfc_factura_d.cantidad)
 let mtotsubben=mtotsubben+(mfc_factura_d.valorbene*mfc_factura_d.cantidad)
 initialize mfc_sub_servicios.* to null
 select * into mfc_sub_servicios.* from fc_sub_servicios
 where codigo=mfc_factura_d.subcodigo
 print  column 01,mfc_factura_d.codigo,
        column 50,mfc_factura_d.cantidad using "&&&&",
        column 70,rec_servi.descripcion clipped,"-",mfc_sub_servicios.descripcion clipped,
        column 170,mvaloruni using "###,###,##&.&&",
        column 220,mfc_factura_d.subsi*mfc_factura_d.cantidad using "###,###,##&.&&",
        column 250,(mvaloruni-(mfc_factura_d.subsi+mfc_factura_d.valorbene))*mfc_factura_d.cantidad using "###,###,##&.&&"
 --page TRAILER
 on last ROW
 INITIALIZE mgen02.* TO NULL
 select * into mgen02.* from gener02 where usuario=mfc_factura_m.usuario_add
 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------",
       "-------------------------------------------------------------------"
     
 skip 1 LINES
 IF mfc_prefijos.redondeo ="S" THEN
   LET mtotiva=nomredondea(mtotiva)
   LET mtotsub=nomredondea(mtotsub)
   LET mtotfac=nomredondea(mtotfac)
 END IF
  LET mvalant = 0
 SELECT sum(valor) INTO mvalant
  FROM fc_factura_anti
 WHERE prefijo = mfc_factura_m.prefijo
 AND documento = mfc_factura_m.documento
 IF mvalant IS NULL THEN
  LET mvalant = 0
 END IF  
 let mvalche=nomredondea((mtotfac+mtotiva)-(mtotsub+mvalant+mtotsubben))
 call letras()
 print  column 01,mletras1 clipped," ",mletras2 clipped 
 print  column 250,"SUBTOTAL",
        COLUMN 280, mtotfac using "###,###,##&.&&"
 PRINT  COLUMN 250,"SUBSIDIO OTORGADO",
        column 280,mtotsub*-1 using "---,---,--&.&&"
 PRINT  COLUMN 250,"BENEFICIO OTORGADO",
        column 280,mtotsubben*-1 using "---,---,--&.&&"       
 print  COLUMN 250,"ANTICIPOS",
        column 280, mvalant*-1 using "---,---,--&.&&"       
 print  COLUMN 250,"IVA",
        column 280,mtotiva using "###,###,##&.&&"
 IF mfc_prefijos.redondeo ="S" THEN       
   print  COLUMN 250,"TOTAL A PAGAR", 
         column 280,nomredondea((mtotfac+mtotiva)-(mtotsub+mvalant+mtotsubben)) using "###,###,##&.&&"
 ELSE        
   print  COLUMN 250,"TOTAL A PAGAR", 
         column 280,nomredondea((mtotfac+mtotiva)-(mtotsub+mvalant+mtotsubben)) using "###,###,##&.&&"
 END IF        
 SKIP 2 LINES
 PRINT COLUMN 1, "________________________________________________________"
 PRINT column 1, "      Elaboró : ", mgen02.nombre 
 --on last row
 --skip to top of page
end REPORT

-----ORDEN_DE_PAGO_PDF
}
REPORT brfactu_PDF(mfc_factura_m,mfc_factura_d,mtotfacc{,mtotivaa})

DEFINE mfc_factura_m RECORD LIKE fc_factura_m.*
DEFINE mfc_factura_d RECORD LIKE fc_factura_d.*
define mx1,mx2 char(1)
define mvaloruni,mtotfac,mtotfacc like fc_factura_d.valoruni
--define mvaloriva,mtotiva,mtotivaa like fc_factura_d.iva
--define mvalorsub,mvalorsubben,mtotsub,mtotsubben,mtotsubb,mvalant,mivasub like fc_factura_d.subsi
DEFINE mrazsoc char(50)
DEFINE vsubsidio,vtotal,mredondeo,mtotsubp,{mtotsubbenp,}mvalantp,mvalchep DECIMAL(12,2)
DEFINE mfecha DATE
DEFINE mpagina CHAR(2)
output
 top margin 4
 bottom margin 4
 left margin 0
 right margin 132
 page length 66
format
-- page header
--on every ROW
 BEFORE GROUP OF mfc_factura_m.documento

 --if pageno="1" then
  let mtotfac=0
  --let mtotiva=0
  {let mtotsub=0
  let mtotsubben=0}
 --end IF
 let mtime=TIME
 LET mfecha= TODAY
 LET mpagina=pageno
 PRINTX mfecha 
 PRINTX mtime
 PRINTX mpagina using "####"
-- skip 1 LINES
 let mp1 = (250-length(mfc_empresa.razsoc clipped))/2
 PRINTX mp1
 PRINTX mfc_empresa.razsoc
 let mp1 = (132-length("ORDEN DE PAGO"))/2
 --print column mp1,"ORDEN DE PAGO  prueba"

 PRINTX mfc_factura_m.prefijo  
 PRINTX mfc_factura_m.documento
 PRINTX mfc_factura_m.fecha_elaboracion 

 let mrazsoc=NULL
 IF mfc_terceros.tipo_persona="1" THEN
  let mrazsoc=mfc_terceros.razsoc
 ELSE
  let mrazsoc=mfc_terceros.primer_apellido clipped," ",mfc_terceros.segundo_apellido clipped," ",
              mfc_terceros.primer_nombre clipped," ",mfc_terceros.segundo_nombre clipped
 END if

 PRINTX mrazsoc
 PRINTX mfc_factura_m.nit
 PRINTX mfc_terceros.direccion
 PRINTX mfc_terceros.telefono
 PRINTX mgener09.detzon 
 PRINTX mfc_factura_m.nota1
ON  EVERY  ROW
 initialize rec_servi.* to null
 select * into rec_servi.* from fc_servicios
 where codigo=mfc_factura_d.codigo

 let mvaloruni=0
 let mvaloruni=mfc_factura_d.valoruni
 let mtotfac=mtotfac+(mvaloruni*mfc_factura_d.cantidad)
 {let mtotiva=mtotiva+(mfc_factura_d.iva*mfc_factura_d.cantidad)}
 {let mtotsub=mtotsub+(mfc_factura_d.subsi*mfc_factura_d.cantidad)
 let mtotsubben=mtotsubben+(mfc_factura_d.valorbene*mfc_factura_d.cantidad)}
 initialize mfc_sub_servicios.* to null
 select * into mfc_sub_servicios.* from fc_sub_servicios
 where codigo=mfc_factura_d.subcodigo
 
{ LET vsubsidio=mfc_factura_d.subsi*mfc_factura_d.cantidad}
 LET vtotal=(mvaloruni)*mfc_factura_d.cantidad
 PRINTX mfc_factura_d.codigo
 PRINTX mfc_factura_d.cantidad using "&&&&"
 PRINTX rec_servi.descripcion,"-",mfc_sub_servicios.descripcion 
 PRINTX mvaloruni using "###,###,##&.&&"
 PRINTX vsubsidio  using "###,###,##&.&&"
 PRINTX vtotal using "###,###,##&.&&"
 --page TRAILER
-- on last ROW
 AFTER GROUP OF mfc_factura_m.documento
 INITIALIZE mgen02.* TO NULL
 select * into mgen02.* from gener02 where usuario=mfc_factura_m.usuario_add
 IF mfc_prefijos.redondeo ="S" THEN
  { LET mtotiva=nomredondea(mtotiva)}
   {LET mtotsub=nomredondea(mtotsub)}
   LET mtotfac=nomredondea(mtotfac)
 END IF
 { LET mvalant = 0
 SELECT sum(valor) INTO mvalant
  FROM fc_factura_anti
 WHERE prefijo = mfc_factura_m.prefijo
 AND documento = mfc_factura_m.documento
 IF mvalant IS NULL THEN
  LET mvalant = 0
 END IF  }
 let mvalche=nomredondea((mtotfac))
 call letras()
{ LET mtotsubp=mtotsub*-1}
 
 --LET mtotsubbenp=mtotsubben*-1
 {LET mvalantp=mvalant*-1}
 PRINTX mletras1," ",mletras2
 PRINTX mtotfac using "###,###,##&.&&"
 PRINTX mtotsubp using "---,---,--&.&&"
 --PRINTX mtotsubbenp using "---,---,--&.&&"       
 PRINTX mvalantp using "---,---,--&.&&"       
 {PRINTX mtotiva using "###,###,##&.&&"}
 
 IF mfc_prefijos.redondeo ="S" THEN       
   LET mvalchep=mvalche -- using "###,###,##&.&&" --nomredondea((mtotfac+mtotiva)-(mtotsub+mvalant+mtotsubben)) using "###,###,##&.&&"
 ELSE        
   LET  mvalchep=mvalche-- using "###,###,##&.&&"--nomredondea((mtotfac+mtotiva)-(mtotsub+mvalant+mtotsubben)) using "###,###,##&.&&"
 END IF 
 PRINTX mvalchep  using "###,###,##&.&&"
 PRINTX mgen02.nombre 
 
 --on last row
 --skip to top of page
end report

-----------------------



function letras()
define dato2 DECIMAL(20,0) --integer
define dato2jp integer
define mcnt decimal(12,2)
define datoprueba decimal(12,2)
define mf char(140)
define mcent,j,a,b integer
define ms,ms0,ms1,ms2,ms3,ms4,ms5,ms6,ms7,ms8,ms9,ms10,ms11,ms12,ms13 char(15)
define n1,n2,n3,n4 char(1)
define ma array[16] of char(15)
for j=1 to 15
 let ma[j]=null
end for
let datoprueba=null
let mf=null
let a=null
let ms=null
let ms0=null
let ms1=null
let ms2=null
let ms3=null
let ms4=null
let ms5=null
let ms6=null
let ms7=null
let ms8=null
let ms9=null
let ms10=null
let ms11=NULL
LET ms12=NULL
LET ms13=null
let n1=null
let n2=null
let n3=null
let n4=null
let dato2=mvalche
let mcnt=mvalche-dato2
if mcnt<>0 then
 let mcent=(mcnt*100)
end IF
if dato2>1000000000 and dato2<10000000000 then
 let a=dato2/1000000000
 select * into mgener10.* from gener10 where gener10.numero=a
 let ms12=mgener10.valor 
 let dato2=dato2-(a*1000000000)
 let datoprueba=mvalche-dato2
 DISPLAY "..dP.",datoprueba," ",dato2," ",mvalche
 LET ms13="MIL"
 if datoprueba=1000000000 and dato2<10000000 then
  --let ms="MILLONES" 
  let ms12=""
 end if
 if a=1 THEN 
  let ms12=""
 end IF
end IF
if dato2>100000000 and dato2<1000000000 then
 let a=dato2/100000000
 select * into mgener12.* from gener12 where gener12.numero=a
 let ms11=mgener12.valor 
 let dato2=dato2-(a*100000000)
 let datoprueba=mvalche-dato2
 if datoprueba=100000000 and dato2<1000000 then
  let ms="MILLONES" 
  let ms11="CIEN"
 end if
 if dato2=0 then let ms="MILLONES" 
 end if
end if
if dato2>30000000 and dato2<=100000000 then
  let a=dato2/10000000
  select * into mgener11.* from gener11 where gener11.numero=a
  let ms1=mgener11.valor 
  let ms="MILLONES" 
  let dato2=dato2-(a*10000000)
  let dato2jp=dato2/1000000
  if dato2jp<>0 then
   let n1="Y"
  end if
 end if
 if dato2>=2000000 and dato2<=30000000 then
  let a=dato2/1000000
  select * into mgener10.* from gener10 where gener10.numero=a
  let ms2=mgener10.valor 
  let ms="MILLONES" 
  let dato2=dato2-(a*1000000)
 end if
##### cambie ms2 por ms3 ######
 if dato2=0 then
  let ms3="CERO "
 end if
 if dato2>=1000000 and dato2<2000000 then
  let a=dato2/1000000
  select * into mgener10.* from gener10 where gener10.numero=a
  let ms2="UN" 
  let ms="MILLON" 
  let dato2=dato2-(a*1000000)
 end if
 if dato2>100000 and dato2<1000000 then
  let b=dato2
  let a=dato2/100000
  select * into mgener12.* from gener12 where gener12.numero=a
  let ms3=mgener12.valor 
  let ms0="MIL" 
  let dato2=dato2-(a*100000)
  let a=b/1000
  if a=100 then
   let ms3="CIEN" 
   let ms0="MIL" 
   let dato2=b-(100000)
  end if
 end if
 if dato2=100000 then
  let ms3="CIEN" 
  let ms0="MIL" 
  let dato2=dato2-(100000)
 end if
 if dato2>=30000 and dato2<100000 then
  let a=dato2/10000
  select * into mgener11.* from gener11 where gener11.numero=a
  let ms4=mgener11.valor 
  let ms0="MIL" 
  let dato2=dato2-(a*10000)
  let dato2jp=dato2/1000
  if dato2jp<>0 then
   let n2="Y"
  end if
 end if
 if dato2>=2000 and dato2<30000 then
  let a=dato2/1000
  select * into mgener10.* from gener10 where gener10.numero=a
  let ms5=mgener10.valor 
  let ms0="MIL" 
  let dato2=dato2-(a*1000)
 end if
 if dato2>=1000 and dato2<2000 then
  let a=dato2/1000
  let ms5="UN"
  let ms0="MIL"
  let dato2=dato2-(a*1000)
 end if
 if dato2>100 and dato2<1000 then
  let a=dato2/100
  select * into mgener12.* from gener12 where gener12.numero=a
  let ms6=mgener12.valor
  let dato2=dato2-(a*100)
 end if
if dato2=100 then 
  let ms6="CIEN"
 end if
 if dato2>=30 and dato2<100 then
  let a=dato2/10
  select * into mgener11.* from gener11 where gener11.numero=a
  let ms7=mgener11.valor
  let dato2=dato2-(a*10)
  if dato2<>0 then
   let n3="Y"
  end if
 end if
 if dato2<30 and dato2>=2 then
  let a=dato2
  select * into mgener10.* from gener10 where gener10.numero=a
  let ms8=mgener10.valor
 end if
 if dato2=1 then
  let ms8="UN"
 end IF
 let ma[1]=ms12 clipped
 let ma[2]=ms13 clipped
 let ma[3]=ms11 clipped
 let ma[4]=ms1 clipped
 let ma[5]=n1 clipped
 let ma[6]=ms2 clipped
 let ma[7]=ms clipped
 let ma[8]=ms3 clipped
 let ma[9]=ms4 clipped
 let ma[10]=n2 clipped
 let ma[11]=ms5 clipped
 let ma[12]=ms0 clipped
 let ma[13]=ms6 clipped
 let ma[14]=ms7 clipped
 let ma[15]=n3 clipped
 let ma[16]=ms8 clipped
 let mf=mf clipped
 let j=0
 while j<16
  let j=j+1
  if ma[j] is not null then              
   let mf=mf clipped," ",ma[j] clipped
  end if
 end while 
 if mcent>0 then
  if mcent>=30 and mcent<100 then
   let a=mcent/10
   select * into mgener11.* from gener11 where gener11.numero=a
   let ms9=mgener11.valor
   let mcent=mcent-(a*10)
   if mcent<>0 then
    let n4="Y"
   end if
  end if
  if mcent<30 and mcent>=2 then
   let a=mcent
   select * into mgener10.* from gener10 where gener10.numero=a
   let ms10=mgener10.valor
  end if
  if mcent=1 then
   let ms10="UN"
  end if
  let mf=mf clipped," PESOS CON ",ms9 clipped," ",n4 clipped," ",ms10 clipped,
                    " CENTAVOS M/CTE"
 else
  let mf=mf clipped ," PESOS M/CTE"
 end if
 for l=1 to 70
  if mf[(70-l),(70-l)]=" " then
   let mletras1=mf[1,(70-l)]
   let mletras2=mf[(70-l),140]
   exit for
  end if
 end for
end FUNCTION
{
FUNCTION fc_categoriasval()
 DEFINE tp   RECORD
   codigo         LIKE fc_categorias.codigo,
   detalle     LIKE fc_categorias.detalle
 END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fc_categorias
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.codigo = NULL
  RETURN tp.codigo
 END IF
 OPEN WINDOW w_vfc_categorias1 AT 8,32 WITH FORM "fc_categoriasv"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 DECLARE c_vfc_categorias1 SCROLL CURSOR FOR
  SELECT fc_categorias.codigo, fc_categorias.detalle FROM fc_categorias
   ORDER BY fc_categorias.codigo
 OPEN c_vfc_categorias1
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fc_categoriasrow( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
 DISPLAY "" AT lastline,1
 MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
 MENU ":"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   HELP 5
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL fc_categoriasrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL fc_categoriasrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Vaya" "Se desplaza al registro No.()."
   HELP 9
   LET status = -1
   WHILE ( status < 0 )
    LET status = 1
    PROMPT "Entre el numero de la posicion (1 - ", maxnum, "): " FOR gotorow
    HELP 4
   END WHILE
   IF gotorow IS NULL OR int_flag THEN
    LET int_flag = FALSE
    LET gotorow = currrow
   END IF
   IF gotorow > maxnum THEN
    LET gotorow = maxnum
   END IF
   IF gotorow < 1 THEN
    LET gotorow = 1
   END IF
   LET currrow = gotorow
   CALL fc_categoriasrow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vfc_categorias1 INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.codigo = NULL
   EXIT MENU
 END MENU
 CLOSE c_vfc_categorias1
 CLOSE WINDOW w_vfc_categorias1
 RETURN tp.codigo
END FUNCTION  
FUNCTION fc_categoriasrow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   codigo         LIKE fc_categorias.codigo,
   detalle     LIKE fc_categorias.detalle
  END RECORD,
  scrmax,scrcurr,scrprev,currrow,prevrow,pagenum,newpagenum,x,y,scrfrst INTEGER
 LET scrmax = 5
 LET newpagenum = 1
 LET scrcurr = currrow MOD scrmax
 IF scrcurr > 0 THEN
  LET newpagenum = ( currrow/scrmax ) + 1
 ELSE
  LET scrcurr = scrmax
  LET newpagenum = ( currrow/scrmax )
 END IF
 IF newpagenum <> pagenum THEN
  LET pagenum = newpagenum
  LET scrfrst = currrow - scrcurr + 1
  FETCH ABSOLUTE scrfrst c_vfc_categorias1 INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cenv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO cenv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vfc_categorias1 INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO cenv[y].*
     END FOR
     EXIT FOR
    END IF
   END IF
  END FOR
 ELSE
  LET scrprev = prevrow MOD scrmax
  IF scrprev = 0 THEN
   LET scrprev = scrmax
  END IF
  FETCH ABSOLUTE prevrow c_vfc_categorias1 INTO tp.*
  DISPLAY tp.* TO cenv[scrprev].*
  FETCH ABSOLUTE currrow c_vfc_categorias1 INTO tp.*
  DISPLAY tp.* TO cenv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION
}
function impsn(ubicacion)
define ubicacion char(100)
define nombre char(80)
define sn char(1)
define impresora char(15)
define comando char(200)
define i,mnumcopias integer
let nombre=ubicacion[20,100]
#ERROR "     NOMBRE DEL REPORTE : ",nombre
#PROMPT "" for char a
#ERROR ""
--let comando ="less -S ",ubicacion clipped
--run comando
CALL showfile(ubicacion) 
initialize sn to null
prompt "Desea imprimir (S/N) : " for sn
let sn = upshift(sn)
if sn = "S" then
 initialize impresora to null
 let impresora=fgl_getenv("LPDEST")
 initialize comando to null 
 let comando="lp -d",impresora clipped," ",ubicacion clipped
 let mnumcopias=null
 prompt "Numero de copias : " for mnumcopias
 if mnumcopias is null then
  let mnumcopias=1
 end if 
 if mnumcopias=0 then
  let mnumcopias=1
 end if 
 #display comando
 #prompt "Prepare la impresora. <ENTER> para continuar..." for sn
 for i=1 to mnumcopias
  run comando
 end for
end if
end FUNCTION

FUNCTION nomredondea(valdec)
 DEFINE valdec DECIMAL(12,2)
 DEFINE valent INTEGER
 DEFINE decima DECIMAL(14,2)
 LET valent = valdec
 LET decima = valdec - valent
 IF decima > 0.50 THEN
  LET valent = valent + 1
 END IF
RETURN valent
END FUNCTION

FUNCTION showfile(fn)
  DEFINE fn STRING
  DEFINE txt STRING
  OPEN WINDOW w WITH FORM "TBText"
     ATTRIBUTE(TEXT="File: ["||fn||"]",STYLE="dialog")
  LET txt = readfile(fn)
  INPUT BY NAME txt WITHOUT DEFAULTS
  CLOSE WINDOW w
END FUNCTION

FUNCTION readfile(fn)
  DEFINE fn STRING
  DEFINE txt STRING
  DEFINE ln STRING
  DEFINE ch base.Channel
  LET ch=base.channel.create()
  CALL ch.openfile(fn,"r")
  WHILE ch.read(ln)
    IF txt IS NULL THEN
      IF ln IS NULL THEN
        LET txt = "\n"
      else
        LET txt = ln
      END IF
    ELSE
      IF ln IS NULL THEN
        LET txt = txt || "\n"
      ELSE
        LET txt = txt || "\n" || ln
      END IF
    END IF
  END WHILE
  CALL ch.close()
  RETURN txt
END FUNCTION
{
function aprueba_factu(mmtp)
DEFINE mmtp char(1)
define ubicacion char(80)
DEFINE mtime char(8)
DEFINE numerofac,x INTEGER
DEFINE mdepar char(2)
DEFINE mtot_reg INTEGER
DEFINE op char(1)
IF mmtp="1" THEN
 LET cnt=0
 SELECT count(*) INTO cnt FROM fc_factura_m
 WHERE fc_factura_m.prefijo = rec_factura_m.prefijo
  AND fc_factura_m.documento = rec_factura_m.documento
  AND fc_factura_m.estado="B"
 IF cnt IS NULL THEN LET cnt=0 END IF
 IF cnt=0 THEN
  MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     comment= " La Factura No existe o Ya fue Aprobada ",
      image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
     LET mentra="N"
   return  
 END IF 
 LET cnt=0
 SELECT count(*) INTO cnt FROM fc_prefijos_usuu
  WHERE prefijo=rec_factura_m.prefijo AND usu_autoriza=musuario
 IF cnt IS NULL THEN LET cnt=0 END IF
 IF cnt=0 THEN
  MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
    comment= " El usuario no puede aprobar facturas para este Prefijo ",
     image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
    LET mentra="N"
    return
 END IF
END if 
 LET numerofac=0
 DISPLAY "prefijo", rec_factura_m.prefijo
 select numero into numerofac from fc_prefijos WHERE prefijo=rec_factura_m.prefijo
 IF numerofac IS NULL THEN LET numerofac=1 END if
 LET cnt = 1
 LET x = numerofac
 WHILE cnt <> 0 
  SELECT  COUNT(*) INTO cnt FROM fc_factura_m
   WHERE fc_factura_m.prefijo = rec_factura_m.prefijo
     AND fc_factura_m.numfac = numerofac
  IF cnt IS NULL THEN LET cnt = 0 END if   
  IF cnt <> 0 THEN
   LET x = x + 1
   UPDATE fc_prefijos SET numero=numero+1 WHERE prefijo=rec_factura_m.prefijo
   LET numerofac = x
  ELSE
   UPDATE fc_prefijos SET numero=numero+1 WHERE prefijo=rec_factura_m.prefijo
   EXIT WHILE
  END IF
 END WHILE
 --LET mtime=TIME
 UPDATE fc_factura_m SET numfac=numerofac,fecha_factura=today,estado="A",usuario_apru=musuario
 WHERE fc_factura_m.prefijo = rec_factura_m.prefijo
  AND fc_factura_m.documento = rec_factura_m.documento
  AND fc_factura_m.estado="B"
 --DISPLAY "" AT 2,1
 IF numerofac IS NOT NULL AND numerofac > 0 THEN
   {CALL act_totales_factura( rec_factura_m.prefijo, rec_factura_m.documento)}
   {IF mmtp = "1" then
    CALL envio_documento("1",rec_factura_m.prefijo,numerofac)
   ELSE
    CALL envio_documento_2("1",rec_factura_m.prefijo,numerofac)
   END IF
 END if  
END FUNCTION}

{REPORT archifactu(mtot_reg)
DEFINE op char(1)
define mtotfac like fc_factura_d.valoruni
define mtotiva like fc_factura_d.iva
define mtotimpc like fc_factura_d.impc
DEFINE mediopag,mediorecep char(2)
DEFINE menvio char(25)
DEFINE m_email char(50)
DEFINE mnitfactu char(20)
DEFINE mg02,mg022 RECORD LIKE gener02.*
DEFINE mg09 RECORD LIKE gener09.*
DEFINE mcodimp char(2)
DEFINE mporcen decimal(5,2)
DEFINE msec INTEGER
DEFINE mtot_reg INTEGER 
DEFINE mtpimp char(1)

output
 top margin 0
 bottom margin 0
 left margin 0
 right margin 500
 page length 2
format
 first page HEADER
  LET msec=0
  initialize mg02.* to NULL
  select * into mg02.* from gener02 
   WHERE usuario = mfc_factura_m.usuario_add
  initialize mg022.* to NULL
  select * into mg022.* from gener02 
   WHERE usuario = mfc_factura_m.usuario_apru
  initialize mg09.* to NULL 
  SELECT * into mg09.* FROM gener09
   WHERE codzon = mfc_prefijos.zona
  let mvalche=mtotfacc
  call letras()
   
  
  LET mediopag=null
  CASE
   WHEN mfc_factura_m.medio_pago="1"
    LET mediopag="10"
   WHEN mfc_factura_m.medio_pago="2"
    LET mediopag="48"
   WHEN mfc_factura_m.medio_pago="3"
    LET mediopag="49"
   WHEN mfc_factura_m.medio_pago="4"
    LET mediopag="42"
   WHEN mfc_factura_m.medio_pago="5"
    LET mediopag="20"
   WHEN mfc_factura_m.medio_pago="6"
    LET mediopag="45"
  END CASE  
  LET mediorecep=NULL
  LET menvio=NULL
  LET m_email=NULL
  LET mnitfactu=NULL
  CASE
   WHEN mfc_terceros.medio_recep="1"
    LET mediorecep="SI"
    LET menvio="EMAIL"
    LET m_email=mfc_terceros.email
   WHEN mfc_terceros.medio_recep="2"
    LET mediorecep="SI"
    LET menvio="PLATAFORMA TECNOLOGICA"
   WHEN mfc_terceros.medio_recep="3"
    LET mediorecep="SI"
    LET mnitfactu=mfc_terceros.nit_facturador
   WHEN mfc_terceros.medio_recep="4"
    LET mediorecep="SI"
  END CASE  
  IF mfc_factura_m.forma_pago="1" then
   LET mfc_prefijos.dias_cred=NULL
  END if 
 ##felCabezaDocumento  
 print column 01,"488" clipped,"|",
                 "EmpCOMFAORIENTE" clipped,"|",
                 "Pwc0mf40r1ent3" clipped,"|",
                 "eaab450239c82b4efb6a0a894583d7aa5ffe886c" CLIPPED,"|",
                 "7" clipped,"|",
                 "1" clipped,"|",
                 mfc_factura_m.prefijo clipped,"|",
                 mfc_factura_m.numfac clipped,"|",
                 mfc_factura_m.fecha_factura USING "YYYY-MM-DD" clipped," ",mfc_factura_m.hora clipped,"|",
                 mfc_prefijos.num_plantilla clipped,"|",
                 "|",
                 mtot_reg USING "&&&" clipped,"|",  
                 "|",
                 "|",
                 "SI" clipped,"|", 
                 "|",
                 "|",
                 "|",
                 "|",
                 "|",
##felPagos
                 mfc_empresa.moneda clipped,"|",
                 (mtotfacc-(mtsub+mtben)) clipped,"|",
                 (mtotfacc-(mtsub+mtben)) clipped,"|",
                 ((mtotfacc-(mtsub+mtben))+mtotivaa+mtotimpcc) clipped,"|",
                 mtotfacc+mtsub+mtben+mtotivaa+mtotimpcc clipped,"|", 
                 "0.00","|",
                 mfc_factura_m.forma_pago clipped,"|",
                 (mfc_factura_m.fecha_vencimiento-mfc_factura_m.fecha_vencimiento)+1 USING "YYYY-MM-DD" clipped,"|",
                 mfc_factura_m.fecha_vencimiento USING "YYYY-MM-DD" clipped,"|",
                 "|",
                 "|",
                 "|",
                 "|",
                 mtsub+mtben clipped,"|",
                 "0.00","|"
 on every ROW
  LET msec=msec+1
  INITIALIZE rec_servi.* TO NULL
  SELECT * INTO rec_servi.* FROM fc_servicios
  where prefijo=mfc_factura_m.prefijo AND codigo=mfc_factura_d.codigo

  LET mtpimp="3"
  LET mcodimp=NULL
  LET mcodimp=null
  CASE
   when mfc_factura_d.iva<>0
    LET mtpimp="1"
   when mfc_factura_d.impc<>0
    LET mtpimp="1" 
  END case 
  
   
  IF op="2" THEN
##listadetalle  
   print column 01,mfc_factura_d.codigo clipped,"|",
                 "999" clipped,"|", 
                 rec_servi.descripcion clipped,"|",
                 mfc_factura_d.codcat clipped,"|",
                 "|",
                 "|",
                 "|",
                 "|",                 
                 "|",  
                 mfc_factura_d.cantidad clipped,"|",
                 "94","|",
                 mfc_factura_d.valoruni clipped,"|",
                 ((mfc_factura_d.valoruni*mfc_factura_d.cantidad)-((mfc_factura_d.subsi+mfc_factura_d.valorbene)*mfc_factura_d.cantidad))+((mfc_factura_d.iva+mfc_factura_d.impc)*mfc_factura_d.cantidad) clipped,"|",
                 "|",
                 "|",
                 "|",
                 "|",
                 "|",        
                 "|",
                 mtpimp,"|", 
##felimpuestos
             (mfc_factura_d.valoruni-((mfc_factura_d.iva+mfc_factura_d.impc)*mfc_factura_d.cantidad)) clipped,"|",
                 "|",
                 (mfc_factura_d.valor-((mfc_factura_d.iva+mfc_factura_d.impc)*mfc_factura_d.cantidad)) clipped,"|",
                 mfc_factura_d.valor clipped,"|",
                 "|",
                 msec clipped,"|",
                 "|",
                 "|",
                 "|",
                 "|",
                 "|",
                 "|",
                 "|",  
                 "|",
                 "|",
                 "|",
                 "|"
                 
  END IF
  LET mcodimp=NULL
  LET mporcen=NULL
  LET mtotiva=0
  LET mtotivaa=0
  IF mfc_factura_d.iva<>"0" THEN
   LET mcodimp="01"
   LET mporcen=rec_servi.iva
   let mtotiva=(mfc_factura_d.iva*mfc_factura_d.cantidad)
   LET mtotivaa=(mfc_factura_d.valor-(mfc_factura_d.iva*mfc_factura_d.cantidad))
  ELSE 
   IF mfc_factura_d.impc<>"0" THEN
    LET mcodimp="03"
    LET mporcen=rec_servi.impc
    let mtotiva=(mfc_factura_d.impc*mfc_factura_d.cantidad)
    LET mtotivaa=(mfc_factura_d.valor-(mfc_factura_d.impc*mfc_factura_d.cantidad))
   END if 
  END if 
  IF op="3" THEN
   print column 01,"3" clipped,"|",
                 mfc_factura_d.codigo clipped,"|",
                 mcodimp,"|",
                 mporcen,"|",
                 mtotiva,"|",
                 mtotivaa,"|" 
  END IF
     
 
end REPORT
}
function valida_factu()
{
define mauxiliar,mauxiliarr like fc_conta1.auxiliariva
define mcodcen,mcodcenn   like fc_conta1.cencosiva
define mnit,mnitt like niif141.nit
define mdetdep like niif141.descripcion
define mcosto,mvalorr like niif141.valor
define cnt,cntp integer}
define mc, md, mdif, mvaltot, mvalts decimal(12,2)
{
define mcodcopp like niif141.codcop
define mdocumentoo like niif141.documento
define mfechaa like niif141.fecha
define mtp char(2)
DEFINE mfe_medio_pago_aux RECORD LIKE fe_medio_pago_aux.*
DEFINE mnumero,xx INTEGER

initialize mfc_factura_m.* to null
declare valvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = rec_factura_m.prefijo
  AND fc_factura_m.documento = rec_factura_m.documento
foreach valvil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare valvil255 cursor for
 select * from fc_factura_d where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  order by codigo
 foreach valvil255 into mfc_factura_d.*
  initialize mfc_conta3.* to null
  select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo
  let mcodconta=NULL
  let mcodconta=mfc_conta3.codconta
  let mcodcop=NULL
  if mfc_factura_m.forma_pago="1" then
   CASE
     WHEN mfc_factura_m.medio_pago="10"
      let mcodcop=mfc_conta3.codcop_ef
     WHEN mfc_factura_m.medio_pago="48"
      let mcodcop=mfc_conta3.codcop_ba
     WHEN mfc_factura_m.medio_pago="49"
      let mcodcop=mfc_conta3.codcop_ba
     WHEN mfc_factura_m.medio_pago="42"
      let mcodcop=mfc_conta3.codcop_ba
     WHEN mfc_factura_m.medio_pago="20"
      let mcodcop=mfc_conta3.codcop_ef
     WHEN mfc_factura_m.medio_pago="45"
      let mcodcop=mfc_conta3.codcop_ba
   END CASE
  END IF
  if mfc_factura_m.forma_pago="2" THEN
   let mcodcop=mfc_conta3.codcop_cr
  END IF
  initialize mfc_conta1.* to null
  select * into mfc_conta1.* from fc_conta1 
   where codigo=mfc_factura_d.codigo
  IF mfc_factura_d.iva<>0 THEN
   IF mfc_conta1.auxiliariva IS NULL THEN
    LET mentra="X"
   END if 
  END IF
  IF mfc_factura_d.impc<>0 THEN
   IF mfc_conta1.auxiliarimpc IS NULL THEN
    LET mentra="X"
   END if 
  END IF
  IF mfc_factura_d.subsi<>0 THEN
   IF mfc_conta1.auxiliarsubsi IS NULL THEN
    LET mentra="X"
   END IF 
   IF mfc_conta1.auxiliarcars IS NULL THEN
    LET mentra="X"
   END IF
   --let mcodcop=mfc_conta3.codcop_su
  END if
 END FOREACH
END FOREACH
IF mentra="N" THEN 
 IF mcodconta IS NOT NULL AND mcodcop IS NOT NULL THEN
  LET mentra="S"
 END IF
END IF 
}
END FUNCTION


FUNCTION factu_terceros()
 DEFINE mcat char(1)
 DEFINE msubsi20 RECORD LIKE subsi20.*
 DEFINE msubsi21 RECORD LIKE subsi21.*
 DEFINE msubsi22 RECORD LIKE subsi22.*
 DEFINE msubsi23 RECORD LIKE subsi23.*
 
 LET mcat=null
  IF int_flag THEN
    LET int_flag = FALSE
  END IF
  OPEN WINDOW w_mdifp AT 1,1 WITH FORM "fc_factura_ter"
  CLEAR FORM
  FOR i = 1 TO 100
   INITIALIZE tpfacter[i].* TO NULL
  END FOR
  LET i = 1
  DECLARE cur_buster CURSOR FOR
   SELECT cedula, nombre, edad, sexo, cat, valor FROM fc_factura_ter
   WHERE prefijo = tapfc_factura_ma.prefijo
    AND documento = tapfc_factura_ma.documento
  FOREACH cur_buster INTO tpfacter[i].*  
   LET i = i + 1  
  END FOREACH
  CALL SET_COUNT(100)
 LABEL ing_terceros: 
  INPUT ARRAY tpfacter WITHOUT DEFAULTS FROM tb_difp.* ATTRIBUTE ( APPEND ROW = FALSE, DELETE ROW= FALSE, INSERT ROW = FALSE)
   AFTER FIELD cedula
    LET y = ARR_CURR()
    LET z = SCR_LINE()   
  IF tpfacter[y].cedula IS null then
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
        comment= " No se ingresado el numero de documento", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
        END MENU
       --NEXT FIELD cedula
   ELSE
    let tpfacter[y].valor=0
    DISPLAY tpfacter[y].valor to tb_difp[z].valor
    IF mfc_terceros.tipo_persona="2" THEN
     CASE 
     WHEN mced ="N"
       INITIALIZE msubsi15.* TO NULL
       SELECT * INTO msubsi15.* FROM subsi15
        where cedtra = tpfacter[y].cedula
         AND estado = "A"
       IF msubsi15.cedtra IS NOT NULL THEN
         LET tpfacter[y].cat = mcodcat
         DISPLAY tpfacter[y].cat to tb_difp[z].cat
         lET tpfacter[y].nombre = msubsi15.priape clipped, " ", msubsi15.segape clipped , " ",msubsi15.nombre CLIPPED
         DISPLAY tpfacter[y].nombre to tb_difp[z].nombre
         LET tpfacter[y].sexo = msubsi15.sexo
         DISPLAY tpfacter[y].sexo to tb_difp[z].sexo
         let medad=0
         let medad=today-msubsi15.fecnac
         let medad=medad/(365.25)
         LET tpfacter[y].edad = medad
         DISPLAY tpfacter[y].edad to tb_difp[z].edad
       ELSE 
         INITIALIZE msubsi20.* TO NULL
         SELECT * INTO msubsi20.* FROM subsi20
          where cedcon = tpfacter[y].cedula
         IF msubsi20.cedcon IS NOT NULL THEN
           LET tpfacter[y].cat = mcodcat
           DISPLAY tpfacter[y].cat to tb_difp[z].cat   
           INITIALIZE msubsi21.* TO NULL
           SELECT * INTO msubsi21.* FROM subsi21
            WHERE cedtra=tapfc_factura_ma.nit
            and cedcon = tpfacter[y].cedula 
         IF msubsi21.cedcon IS NULL THEN
           INITIALIZE msubsi22.* TO NULL
           SELECT * INTO msubsi22.* FROM subsi22
           where documento = tpfacter[y].cedula
           IF msubsi22.documento IS NOT NULL THEN
           LET tpfacter[y].cat = mcodcat
           DISPLAY tpfacter[y].cat to tb_difp[z].cat     
           INITIALIZE msubsi23.* TO NULL
           SELECT * INTO msubsi23.* FROM subsi23
            WHERE cedtra=tapfc_factura_ma.nit
              and codben = msubsi22.codben 
           IF msubsi23.codben IS NULL THEN
            MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
            comment= " La Cedula del Conyuge No corresponde al Trabajador", image= "exclamation")
             COMMAND "Aceptar"
               EXIT MENU
             END MENU
            NEXT FIELD cedula
           ELSE
            LET tpfacter[y].nombre = msubsi22.priape clipped, " ", msubsi22.segape clipped , " ",msubsi22.nombre CLIPPED
            DISPLAY tpfacter[y].nombre to tb_difp[z].nombre
            LET tpfacter[y].sexo = msubsi22.sexo
            DISPLAY tpfacter[y].sexo to tb_difp[z].sexo
            let medad=0
            let medad=today-msubsi22.fecnac
            let medad=medad/(365.25)
            LET tpfacter[y].edad = medad
            DISPLAY tpfacter[y].edad to tb_difp[z].edad
            IF msubsi22.parent ="1" AND medad >= 19 THEN
              LET tpfacter[y].cat = "D"
              DISPLAY tpfacter[y].cat to tb_difp[z].cat
            END IF    
           END IF 
          END IF
         ELSE 
          LET tpfacter[y].nombre = msubsi20.priape clipped, " ", msubsi20.segape clipped , " ",msubsi20.nombre CLIPPED
          DISPLAY tpfacter[y].nombre to tb_difp[z].nombre
          LET tpfacter[y].sexo = msubsi20.sexo
          DISPLAY tpfacter[y].sexo to tb_difp[z].sexo
          let medad=0
          let medad=today-msubsi20.fecnac
          let medad=medad/(365.25)
          LET tpfacter[y].edad = medad
          DISPLAY tpfacter[y].edad to tb_difp[z].edad
         END IF
        ELSE
         INITIALIZE msubsi22.* TO NULL
         SELECT * INTO msubsi22.* FROM subsi22
         where documento = tpfacter[y].cedula
         IF msubsi22.documento IS NOT NULL THEN
            LET tpfacter[y].cat = mcodcat
            DISPLAY tpfacter[y].cat to tb_difp[z].cat
            let medad=0
            let medad=today-msubsi22.fecnac
            let medad=medad/(365.25)
            LET tpfacter[y].edad = medad
            IF msubsi22.parent ="1" AND medad >= 19 THEN
              LET tpfacter[y].cat = "D"
              DISPLAY tpfacter[y].cat to tb_difp[z].cat
            END IF    
            INITIALIZE msubsi23.* TO NULL
            SELECT * INTO msubsi23.* FROM subsi23
             WHERE cedtra=tapfc_factura_ma.nit
             and codben = msubsi22.codben 
            IF msubsi23.codben IS NULL THEN
               MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
               comment= " El Documento de la Persona a Cargo No corresponde al Trabajador", image= "exclamation")
               COMMAND "Aceptar"
                  EXIT MENU
               END MENU
               NEXT FIELD cedula
             END IF    
             LET tpfacter[y].nombre = msubsi22.priape clipped, " ", msubsi22.segape clipped , " ",msubsi22.nombre CLIPPED
             DISPLAY tpfacter[y].nombre to tb_difp[z].nombre
             LET tpfacter[y].sexo = msubsi22.sexo
             DISPLAY tpfacter[y].sexo to tb_difp[z].sexo
             let medad=0
             let medad=today-msubsi22.fecnac
             let medad=medad/(365.25)
             LET tpfacter[y].edad = medad
             DISPLAY tpfacter[y].edad to tb_difp[z].edad
             IF msubsi22.parent ="1" AND medad >= 19 THEN
                LET tpfacter[y].cat = "D"
                DISPLAY tpfacter[y].cat to tb_difp[z].cat
             END IF
          ELSE
            LET tpfacter[y].cat = "D"
            DISPLAY tpfacter[y].cat to tb_difp[z].cat
          END IF
        END IF 
      END IF
   
   
   OTHERWISE
      LET tpfacter[y].cat = "D"
      DISPLAY tpfacter[y].cat to tb_factura_ter[z].cat  
   END CASE
 ELSE
    LET cnt=0
     SELECT count(*) INTO cnt FROM subsi15
      WHERE cedtra=tpfacter[y].cedula
     IF cnt IS NULL THEN LET cnt=0 END IF
     IF cnt=0 THEN
      LET tpfacter[y].cat = "D"
      DISPLAY tpfacter[y].cat to tb_difp[z].cat     
     ELSE 
      INITIALIZE msubsi15.* TO NULL
      SELECT * INTO msubsi15.* FROM subsi15
       where cedtra = tpfacter[y].cedula
      initialize msubsi12.* to NULL
     select * into msubsi12.* from subsi12
       where today between fecini and fecfin
      let mpersal=NULL
      select max(periodo) into mpersal from subsi10
      where cedtra=tpfacter[y].cedula and suebas>0
       AND hortra >= 96  -- incluido para no tomar fracciones de salario
      if mpersal is not null THEN
        let msalario=NULL
        select sum(suebas) into msalario from subsi10
         where cedtra=tpfacter[y].cedula and periodo=mpersal
        if msalario is null then let msalario=0 end IF
        let mcansal=msalario/msubsi12.salmin
       ELSE
        initialize msubsi17.* to NULL
        DECLARE ns17 CURSOR FOR
        SELECT * FROM subsi17
         where cedtra=tpfacter[y].cedula ORDER BY fecha DESC
        FOREACH ns17 INTO msubsi17.*
         EXIT FOREACH
        END FOREACH
        let mcansal=msubsi17.salario/msubsi12.salmin
       end IF
       DECLARE ns30 CURSOR FOR
       SELECT * FROM subsi30 ORDER BY codcat ASC
       FOREACH ns30 INTO msubsi30.*
        if mcansal<msubsi30.cansal THEN
         EXIT FOREACH
        end IF
       END FOREACH
       IF msubsi30.codcat="1" THEN
        LET mcat="A"
       END IF
       IF msubsi30.codcat="2" THEN
        LET mcat="B"
       END IF
       IF msubsi30.codcat="3" THEN
        LET mcat="C"
       END IF
       LET tpfacter[y].cat = mcat
       DISPLAY tpfacter[y].cat to tb_difp[z].cat
       LET tpfacter[y].nombre = msubsi15.priape clipped, " ", msubsi15.segape clipped , " ",msubsi15.nombre CLIPPED
       DISPLAY tpfacter[y].nombre to tb_difp[z].nombre
       LET tpfacter[y].sexo = msubsi15.sexo
       DISPLAY tpfacter[y].sexo to tb_difp[z].sexo
       let medad=0
       let medad=today-msubsi15.fecnac
       let medad=medad/(365.25)
       LET tpfacter[y].edad = medad
       DISPLAY tpfacter[y].edad to tb_difp[z].edad
      END IF  
  END IF
END IF
  AFTER FIELD nombre
    LET y = ARR_CURR()
    LET z = SCR_LINE()    
    IF tpfacter[y].nombre IS NULL AND tpfacter[y].cedula is not null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
        comment= " EL nombre no ha sido digitado", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
        END MENU
       NEXT FIELD nombre
   END IF
   AFTER FIELD edad
    LET y = ARR_CURR()
    LET z = SCR_LINE()    
    IF tpfacter[y].edad IS NULL AND tpfacter[y].cedula is not null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
        comment= " La edad no ha sido digitada", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
        END MENU
       NEXT FIELD edad
   END IF
  AFTER FIELD sexo
    LET y = ARR_CURR()
    LET z = SCR_LINE()    
    IF tpfacter[y].sexo IS NULL AND tpfacter[y].cedula is not null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
        comment= " EL sexo no ha sido digitado", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
        END MENU
       NEXT FIELD sexo
   END IF
 AFTER FIELD valor
    LET y = ARR_CURR()
    LET z = SCR_LINE()    
    IF tpfacter[y].valor IS NULL AND tpfacter[y].cedula is not null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
        comment= " EL Valor del Beneficio no ha sido digitado", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
        END MENU
       NEXT FIELD valor
   END IF
   ON ACTION bt_familia
    LET y = ARR_CURR()
    LET z = SCR_LINE()
    CALL nucleo(tapfc_factura_ma.nit) RETURNING tpfacter[y].cedula
    DISPLAY tpfacter[y].cedula TO cedula[z]
   AFTER INPUT
    IF int_flag THEN 
      EXIT INPUT
    END IF    
  END INPUT   
  IF int_flag THEN
   FOR i = 1 to gmaxarray
    INITIALIZE tpfacter[i].* TO NULL 
   END FOR
  ELSE
   DELETE FROM fc_factura_ter 
   WHERE prefijo = tapfc_factura_ma.prefijo
    and documento = tapfc_factura_ma.documento
   FOR i = 1 to gmaxarray 
     IF tpfacter[i].cedula IS NOT null THEN
       INSERT INTO fc_factura_ter (prefijo, documento, cedula, nombre, edad, sexo, cat, valor )
       VALUES (tapfc_factura_ma.prefijo, tapfc_factura_ma.documento, tpfacter[i].cedula, tpfacter[i].nombre, 
       tpfacter[i].edad, tpfacter[i].sexo, tpfacter[i].cat, tpfacter[i].valor )
       IF status <> 0 THEN 
        LET gerrflag = TRUE
       END IF
     ELSE 
       EXIT FOR    
     END IF
   END FOR
   LET cnt= i -1
   --IF cnt<>tapfc_factura_ma.parti THEN
   -- CALL FGL_WINMESSAGE( "Administrador", " LA COBERTURA DIGITADA NO CORRESPONDE AL NUMERO PARTICIPANTES ", "information")
   -- GO TO ing_terceros
   --END IF     
  END IF  
  CLOSE WINDOW w_mdifp
  let int_flag = FALSE
END FUNCTION

FUNCTION rep_facturas()
DEFINE prex CHAR(5)
DEFINE fechai, fechaf DATE 
DEFINE arreglo documentos_prex

PROMPT "Prefijo =====>> :" FOR prex 
LET prex = upshift(prex)
let mdeftit="    RELACION DE DOCUMENTOS X PREFIJO   "
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL confccr() RETURNING fechai, fechaf
 IF fechai IS null or fechaf is null then
   return
 end IF

CALL obtener_datos_doc_x_pref(prex, fechai,fechaf) RETURNING arreglo
CALL opcion_salida () RETURNING opc_sal
CALL f_genera_reporte_x_prefijo(arreglo,prex,fechai,fechaf,opc_sal)
END FUNCTION

REPORT rprec_xls()
 OUTPUT
   top margin 3
   bottom  margin 8
   left  margin 0
   right margin 240
   page length 66
 format
  PAGE HEADER
  let mtime=TIME
  print column 1,"Fecha : ",today," + ",mtime,
        column 121,"Pag No. ",pageno using "####"
 skip 1 LINES
 let mp1 = (132-length(mfc_empresa.razsoc clipped))/2
 print column mp1,mfc_empresa.razsoc
 let mp1 = (132-length("LISTADO GENERAL DE FACTURAS APROBADAS "))/2
 print column mp1,"LISTADO GENERAL DE FACTURAS APLICADAS EXISTOSAS "

 skip 1 LINES
 PRINT COLUMN 01, "FACTURAS DEL PREFIJO  : ", mprefijo 
 print "--------------------------------------------------------------------",
       "--------------------------------------------------------------------",
       "-----------------"
  print column 01,"NUM FAC",
        column 12,"# INTERNO",
        column 24,"FE.ELABORA",
        column 38,"FE.FACTURA",
        COLUMN 55,"VR.FACTURA",
        COLUMN 70,"VR.SUBSIDIO",
        COLUMN 85,"VR.IVA",
        Column 105,"TERCERO"
  print "--------------------------------------------------------------------",
        "--------------------------------------------------------------------",
        "-----------------"
  on every ROW
   print column 01,mfc_factura_m.numfac USING "-------",
         column 13,mfc_factura_m.documento,
         COLUMN 24,mfc_factura_m.fecha_elaboracion,
         column 38,mfc_factura_m.fecha_factura,
         COLUMN 56,mvaltot USING "###,###,##&",
         COLUMN 69,mvalsub USING "###,###,##&",
         {COLUMN 84,mvaliva USING "###,###,##&",}
         column 101,mfc_factura_m.nit CLIPPED,"-",mnombre[1,30]
 ON LAST ROW      
    print "--------------------------------------------------------------------",
          "--------------------------------------------------------------------",
          "-----------------" 
    PRINT COLUMN 1,  "TOTAL FACTURADO .....", 
       COLUMN 56, sum(mvaltot) USING "###,###,##&",
       COLUMN 69, sum(mvalsub) USING "###,###,##&"
      { COLUMN 84, sum(mvaliva) USING "###,###,##&"}
    skip to top of page
end REPORT


FUNCTION rep_facturas_nit()
DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
DEFINE mcodpun CHAR(2)
DEFINE cnt INTEGER
DEFINE opp CHAR(1)
 LET mfecini = NULL
 LET mfecfin = NULL
 let mdeftit="    RELACION DE FACTURAS "
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL confccr() RETURNING mfecini,mfecfin
 if mfecini is null or mfecfin is null then
   return
 end IF
 let mnit=null
 let mdeftit="  FACTURAS TERCERO " #32
 let mdefpro="Nit Tercero" #23
 CALL fe_nit() RETURNING mnit
 if mnit is null then
  return
 end if
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
{ LET handler = configureOutput_excel(90,"5.0cm","3.0cm","0.5cm","0.5cm","XLSX")}
 START REPORT nrprec_xls TO XML HANDLER HANDLER
  DECLARE ncurrec CURSOR FOR
  SELECT * FROM fc_factura_m
   WHERE fecha_elaboracion between mfecini and mfecfin AND nit=mnit
   ORDER BY prefijo,documento
  FOREACH ncurrec INTO mfc_factura_m.*
        OUTPUT TO REPORT nrprec_xls()
  END FOREACH
 finish report nrprec_xls
 --let mdefnom="RELACION DE RECIBOS"
 --let mdeflet="condensed"
 --let mdeftam=66
 --let mhoja="9.5x11"
 --call impsn(nomrep,"S")
END FUNCTION


REPORT nrprec_xls()
 DEFINE mvaltot decimal(12,2)
 define mnombre char(35)
 DEFINE mestado char(10)
 --output
  --top margin 3
  --bottom  margin 8
  --left  margin 0
  --right margin 240
  --page length 66
 format
  FIRST page HEADER
    
  print column 01,"PREFIJO",
        column 10,"DOCUMENTO",
        column 20,"FE.ELABORA",
        column 35,"TERCERO",
        column 60,"NOMBRE TERCERO",
        column 100,"ESTADO",
        COLUMN 110,"VALOR FACTURA"
  on every ROW
  LET mvaltot=0
  select sum(valor-(subsi*cantidad)) INTO mvaltot from fc_factura_d
   WHERE prefijo=mfc_factura_m.prefijo AND documento=mfc_factura_m.documento
  IF mvaltot IS NULL then LET mvaltot=0 END if 
   initialize mfc_terceros.* to null
   select * into mfc_terceros.* from fc_terceros 
    where nit=mfc_factura_m.nit
   IF mfc_terceros.tipo_persona="2" THEN 
    LET mnombre=NULL
    Let mnombre=mfc_terceros.primer_apellido CLIPPED," ",
                mfc_terceros.segundo_apellido CLIPPED," ",
                mfc_terceros.primer_nombre CLIPPED," ",
                mfc_terceros.segundo_nombre CLIPPED," "
   ELSE
    LET mnombre=NULL
    Let mnombre=mfc_terceros.razsoc CLIPPED
   END IF
   CASE
   when mfc_factura_m.estado="A"
     LET mestado="ENVIADA CON ERRORES"  
   when mfc_factura_m.estado="S"
     LET mestado="TRANSMITIDA"  
    when mfc_factura_m.estado="N"
     LET mestado="ANULADA POR NC"   
    when mfc_factura_m.estado="X"
     LET mestado="RECHAZADA DISPAPELES"
    when mfc_factura_m.estado="R"
     LET mestado="RECHAZADA CLIENTE"          
    when mfc_factura_m.estado="D"
     LET mestado="RECHAZADA DIAN"     
    when mfc_factura_m.estado="P"
     LET mestado="PROCESADA EXITOSA"
    when mfc_factura_m.estado="G"
     LET mestado="FACTURA CONTINGENCIA"
    when mfc_factura_m.estado="B"
     LET mestado="BORRADOR"     
   END case
     print column 01, mfc_factura_m.prefijo,
         column 10, mfc_factura_m.documento,
         column 20, mfc_factura_m.fecha_elaboracion,
         column 35, mfc_factura_m.nit,
         column 60, mnombre,
         column 100, mestado,
         COLUMN 110, mvaltot USING "###,###,##&.&&"
    
  --skip to top of page
end REPORT

--agregado por Danny

FUNCTION rep_facturas_estados()
DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
DEFINE mcodpun CHAR(2)
DEFINE cnt INTEGER
DEFINE opp CHAR(1)
 let ubicacion=fgl_getenv("HOME"),"/reportes/rel_facturas_estados"
 let ubicacion=ubicacion CLIPPED
 let mprefijo=NULL
 prompt "Digite el prefijo : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null THEN 
  RETURN
 end if
 LET mfecini = NULL
 LET mfecfin = NULL
 let mdeftit="    RELACION DE FACTURAS "
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL confccr() RETURNING mfecini,mfecfin
 if mfecini is null or mfecfin is null then
   return
 end IF
 LET opcrep = NULL
 PROMPT " OPCIONES:  A.=>ENVIADA CON ERROR   N.=>ANULADA POR NC   R.=>RECHAZADA CLIENTE   D.=>RECHAZADA DIAN   P.=>PROCESADA EXITOSA   B.=> BORRADOR  : " for  opcrep 
 IF opcrep <> "A" AND opcrep <> "N"  AND opcrep <> "X" AND opcrep <> "D" AND opcrep <> "P" AND opcrep <> "B"
 and opcrep <> "S" AND opcrep <> "R" 
 THEN
    RETURN
 END if 
 
 LET opcrep2 = NULL
 PROMPT " Reporte  1. Texto   2. Excel  : " for  opcrep2
 IF opcrep2 <> "1" AND opcrep2 <> "2" THEN
    RETURN
 END if 
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
 --CALL ini_mensaje_espera("Generando Reporte ... Espere por favor...")
 IF opcrep2 = "1" THEN
   START REPORT rprec_xls_est TO ubicacion
 ELSE
   {LET handler = configureOutput_excel(90,"5.0cm","3.0cm","0.5cm","0.5cm","XLSX")}
   START REPORT rprec_xls_est TO XML HANDLER HANDLER
 END IF  
  DECLARE currec_est CURSOR FOR
  SELECT * FROM fc_factura_m
   WHERE fecha_factura between mfecini and mfecfin
    AND prefijo = mprefijo
   and (estado=opcrep )
   ORDER BY prefijo, numfac
  FOREACH currec_est INTO mfc_factura_m.*
   DISPLAY "FACTURA ", mfc_factura_m.numfac
    LET mvaltot =0
   { LET mvaliva = 0}
    LET mvalsub = 0
    select sum((valoruni-subsi+iva) * cantidad), sum(subsi*cantidad), sum(iva*cantidad) 
    INTO mvaltot  from fc_factura_d
    WHERE prefijo=mfc_factura_m.prefijo AND documento=mfc_factura_m.documento
   IF mvaltot IS NULL then LET mvaltot=0 END IF 
   LET mvaltot = nomredondea(mvaltot)
   LET mvalsub = nomredondea(mvalsub)
  { LET mvaliva = nomredondea(mvaliva)}
   initialize mfc_terceros.* to null
   select * into mfc_terceros.* from fc_terceros 
    where nit=mfc_factura_m.nit
   IF mfc_terceros.tipo_persona="2" THEN 
    LET mnombre=NULL
    Let mnombre=mfc_terceros.primer_apellido CLIPPED," ",
                mfc_terceros.segundo_apellido CLIPPED," ",
                mfc_terceros.primer_nombre CLIPPED," ",
                mfc_terceros.segundo_nombre clipped
   ELSE
    LET mnombre=NULL
    Let mnombre=mfc_terceros.razsoc clipped
   END IF
   OUTPUT TO REPORT rprec_xls_est()
  END FOREACH
 finish report rprec_xls_est
 IF opcrep2 ="1" THEN
   let mdefnom="RELACION DE RECIBOS"
   let mdeflet="condensed"
   let mdeftam=66
   let mhoja="9.5x11"
   call impsn(ubicacion) 
 END IF
END FUNCTION

REPORT rprec_xls_est()
 DEFINE mestado char(10)
 OUTPUT
   top margin 3
   bottom  margin 8
   left  margin 0
   right margin 240
   page length 66
 format
  PAGE HEADER
  let mtime=TIME
  print column 1,"Fecha : ",today," + ",mtime,
        column 121,"Pag No. ",pageno using "####"
 skip 1 LINES
 let mp1 = (132-length(mfc_empresa.razsoc clipped))/2
 print column mp1,mfc_empresa.razsoc
 let mp1 = (132-length("LISTADO GENERAL DE FACTURAS  "))/2
 print column mp1,"LISTADO GENERAL DE FACTURAS  "
  CASE
   when mfc_factura_m.estado="A"
     LET mestado="ENVIADA CON ERRORES"  
   when mfc_factura_m.estado="S"
     LET mestado="TRANSMITIDA"  
    when mfc_factura_m.estado="N"
     LET mestado="ANULADA POR NC"   
    when mfc_factura_m.estado="X"
     LET mestado="RECHAZADA DISPAPELES"
    when mfc_factura_m.estado="R"
     LET mestado="RECHAZADA CLIENTE"          
    when mfc_factura_m.estado="D"
     LET mestado="RECHAZADA DIAN"     
    when mfc_factura_m.estado="P"
     LET mestado="PROCESADA EXITOSA"
    when mfc_factura_m.estado="G"
     LET mestado="FACTURA CONTINGENCIA"
    when mfc_factura_m.estado="B"
     LET mestado="BORRADOR"     
   END case
 skip 1 LINES
 PRINT COLUMN 01, "FACTURAS DEL PREFIJO  : ", mprefijo,
       COLUMN 115, "ESTADO FACTURA  : ", mestado  
 print "--------------------------------------------------------------------",
       "--------------------------------------------------------------------",
       "-----------------"
  print column 01,"NUM FAC",
        column 12,"# INTERNO",
        column 24,"FE.ELABORA",
        column 38,"FE.FACTURA",
        COLUMN 55,"VR.FACTURA",
        COLUMN 70,"VR.SUBSIDIO",
        COLUMN 85,"VR.IVA",
        Column 105,"TERCERO"
  print "--------------------------------------------------------------------",
        "--------------------------------------------------------------------",
        "-----------------"
  on every ROW
  
   print column 01,mfc_factura_m.numfac USING "-------",
         column 13,mfc_factura_m.documento,
         COLUMN 24,mfc_factura_m.fecha_elaboracion,
         column 38,mfc_factura_m.fecha_factura,
         COLUMN 56,mvaltot USING "###,###,##&",
         COLUMN 69,mvalsub USING "###,###,##&",
         {COLUMN 84,mvaliva USING "###,###,##&",}
         column 105,mfc_factura_m.nit CLIPPED,"-",mnombre[1,30]
 ON LAST ROW      
    print "--------------------------------------------------------------------",
          "--------------------------------------------------------------------",
          "-----------------" 
    PRINT COLUMN 1,  "TOTAL FACTURADO .....", 
       COLUMN 56, sum(mvaltot) USING "###,###,##&",
       COLUMN 69, sum(mvalsub) USING "###,###,##&"
       {COLUMN 84, sum(mvaliva) USING "###,###,##&"}
    skip to top of page
end REPORT

--agregado por Danny
FUNCTION rep_facturas_pago()
DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
DEFINE mcodpun CHAR(2)
DEFINE cnt INTEGER
DEFINE opp,ox CHAR(1)
DEFINE mprefijo char(5)
 let mprefijo=null
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null then 
  return
 end if
 LET mfecini = NULL
 LET mfecfin = NULL
 let mdeftit="    RELACION DE FACTURAS "
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL confccr() RETURNING mfecini,mfecfin
 if mfecini is null or mfecfin is null then
   return
 end IF
 LET ox=NULL
 PROMPT "Digite 1=Contado - 2=Credito : " FOR ox
 IF ox IS NULL OR (ox<>"1" AND ox<>"2") THEN
  RETURN
 end if 
 
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
 -- LET handler = configureOutputt("XLS","22cm","28cm",17,"1.5cm")
{ LET handler = configureOutput_excel(90,"5.0cm","3.0cm","0.5cm","0.5cm","XLSX")}
  --CALL ini_mensaje_espera("Generando Reporte ... Espere por favor...")
  START REPORT rprec_xlsp TO XML HANDLER HANDLER
 
  DECLARE pcurrec CURSOR FOR
  SELECT * FROM fc_factura_m
   WHERE fecha_elaboracion between mfecini and mfecfin
     AND forma_pago=ox
     AND prefijo=mprefijo 
   ORDER BY prefijo,documento
  FOREACH pcurrec INTO mfc_factura_m.*
    OUTPUT TO REPORT rprec_xlsp()
  END FOREACH
 finish report rprec_xlsp
 --let mdefnom="RELACION DE RECIBOS"
 --let mdeflet="condensed"
 --let mdeftam=66
 --let mhoja="9.5x11"
 --call impsn(nomrep,"S")
END FUNCTION


REPORT rprec_xlsp()
 DEFINE mvaltot decimal(12,2)
 define mnombre char(60)
 DEFINE mformap char(10)
 DEFINE mestado char(10)
 --output
  --top margin 3
  --bottom  margin 8
  --left  margin 0
  --right margin 240
  --page length 66
 format
  FIRST page HEADER
    
  print column 01,"PREFIJO",
        --column 10,"DOCUMENTO",
        COLUMN 10, "NRO FACTURA",
        column 20,"FE.ELABORA",
        column 40,"ESTADO",
        COLUMN 50,"FOR.PAGO",
        COLUMN 60,"VALOR FACTURA",
        column 80,"TERCERO",
        column 100,"NOMBRE TERCERO"

  on every ROW

  LET mvaltot=0
  select sum(valor-(subsi*cantidad)) INTO mvaltot from fc_factura_d
   WHERE prefijo=mfc_factura_m.prefijo AND documento=mfc_factura_m.documento
  IF mvaltot IS NULL then LET mvaltot=0 END if 

  
   initialize mfc_terceros.* to null
   select * into mfc_terceros.* from fc_terceros 
    where nit=mfc_factura_m.nit
   IF mfc_terceros.tipo_persona="2" THEN 
    LET mnombre=NULL
    Let mnombre=mfc_terceros.primer_apellido CLIPPED," ",
                mfc_terceros.segundo_apellido CLIPPED," ",
                mfc_terceros.primer_nombre CLIPPED," ",
                mfc_terceros.segundo_nombre CLIPPED," "
   ELSE
    LET mnombre=NULL
    Let mnombre=mfc_terceros.razsoc CLIPPED
   END IF    
   CASE
    when mfc_factura_m.forma_pago="1"
     LET mformap="CONTADO"
    when mfc_factura_m.forma_pago="2"
     LET mformap="CREDITO" 
   END CASE

  CASE
   when mfc_factura_m.estado="A"
     LET mestado="ENVIADA CON ERRORES"  
   when mfc_factura_m.estado="S"
     LET mestado="TRANSMITIDA"  
    when mfc_factura_m.estado="N"
     LET mestado="ANULADA POR NC"   
    when mfc_factura_m.estado="X"
     LET mestado="RECHAZADA DISPAPELES"
    when mfc_factura_m.estado="R"
     LET mestado="RECHAZADA CLIENTE"          
    when mfc_factura_m.estado="D"
     LET mestado="RECHAZADA DIAN"     
    when mfc_factura_m.estado="P"
     LET mestado="PROCESADA EXITOSA"
    when mfc_factura_m.estado="G"
     LET mestado="FACTURA CONTINGENCIA"
    when mfc_factura_m.estado="B"
     LET mestado="BORRADOR"     
   END case
   
   print column 01, mfc_factura_m.prefijo,
         --column 10, mfc_factura_m.documento,
         COLUMN 10, mfc_factura_m.numfac,
         column 20, mfc_factura_m.fecha_elaboracion,
         column 40, mestado,
         column 50, mformap,
         COLUMN 60, mvaltot USING "###,###,##&.&&",
         column 80, mfc_factura_m.nit,
         column 100, mnombre
  --skip to top of page
end REPORT
{
FUNCTION conefvalniif141()
 DEFINE fil, nctas integer
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 let t= 0
 LET mvalor = 0
 OPEN WINDOW w_vcontaef1 AT 5,20 WITH FORM "coneva"
 MESSAGE "Trabajando por favor espere ... ",mtipcru," ",mauxiliar," ",mnit 
 DECLARE c_vconef1niif141 CURSOR FOR
 SELECT niif145.codcen, niif145.nocts, niif145.doccru, niif145.fecven,niif145.saldo,"O"
  FROM niif145
  WHERE niif145.tipcru=mtipcru 
      AND niif145.nit=mnit AND
        niif145.auxiliar=mauxiliar AND 
        niif145.saldo>0 AND 
        niif145.estado="A"
      and niif145.codconta=mfc_conta3.codconta
  UNION 
  select niif141.codcen, niif142.nocts, niif142.doccru,niif142.fecven,niif141.valor,"O"
  from niif141,niif142 
  WHERE niif142.tipcru=mtipcru AND niif141.nit=mnit
    AND niif141.auxiliar=mauxiliar 
    and niif141.codcop=niif142.codcop
    and niif141.documento=niif142.documento
    and niif141.sec=niif142.sec
    --and niif141.nat<>mnat
           and niif142.codconta=mfc_conta3.codconta
       and niif141.codconta=mfc_conta3.codconta
  ORDER BY 3 ASC, 4 ASC
 let x=1
 for i = 1 to gmaxarray
  initialize mefeval[i].*  to null
 end for
LET nctas = 0
 FOREACH c_vconef1niif141 INTO mefeval[x].*
  SELECT * INTO mfc_factura_anti.* FROM fc_factura_anti 
    WHERE prefijo = tapfc_factura_ma.prefijo 
     AND documento = tapfc_factura_ma.documento
  IF mefeval[x].doccru = mfc_factura_anti.doccru
      AND mefeval[x].saldo = mfc_factura_anti.valor
      AND mefeval[x].fecven = mfc_factura_anti.fecven THEN
      LET mefeval[x].mx ="X"
  END if    
  let x=x+1
  let nctas = nctas + 1
 END FOREACH
 let mvalor=0
 MESSAGE "Marque con una X los que quiere seleccionar " 
 CALL SET_COUNT( x )
 INPUT ARRAY mefeval WITHOUT DEFAULTS FROM efe.*
 --BEFORE FIELD mx
 -- LET fil = arr_curr()
 -- if fil >nctas then
 --  CALL FGL_WINMESSAGE( "Administrador", "NO HAY MAS REGISTROS PARA SELECCIONAR", "stop") 
 -- end IF
 -- DISPLAY " 1  fil ",fil
 --ON CHANGE mx
 AFTER FIELD mx
  LET fil = arr_curr()
  LET t = scr_line()
  --DISPLAY " 2  fil ",fil
  IF mefeval[fil].mx IS NULL THEN
   CALL FGL_WINMESSAGE( "Administrador", "EL ESTADO DEL REGISTRO PARA ADICIONAR ES X/O", "stop") 
   let mefeval[fil].mx="O"
   DISPLAY mefeval[fil].mx to efe[t].mx
   NEXT FIELD mx
  END IF
  DISPLAY mefeval[fil].mx to efe[t].mx
  --DISPLAY ":",mefeval[fil].saldo," fil ",fil  
   if mefeval[fil].mx="X" then
    if mefeval[fil].saldo is not null then
     let mvalor=mvalor+mefeval[fil].saldo
    end if
   end if
  #call efeacuniif141()
  display mvalor to mac
 AFTER INPUT
  IF int_flag THEN
   EXIT INPUT
  END IF
 END INPUT
 IF int_flag THEN
  MESSAGE "ENTRA Y CAMBIA A O........... "
  for i=1 to x
   let mefeval[i].mx="O"
  end for
  LET int_flag = FALSE
 END IF
 CLOSE WINDOW w_vcontaef1
END FUNCTION}

function doccopcon141_niif()
define i integer
define j1 char(1)
define j2 char(2)
define j3 char(3)
define j4 char(4)
define j5 char(5)
define j6 char(6)
define j7 char(7)
BEGIN WORK
set lock mode to wait
DECLARE docn148lock CURSOR FOR
select ultnum from niif148
 WHERE codcop=mmarca2 
 FOR UPDATE
 OPEN docn148lock
 FETCH docn148lock
INITIALIZE mniif148.* TO NULL
select * into mniif148.* from niif148 where codcop=mmarca2
let i=mniif148.ultnum+1
if i<10 then
 let j1=i
 let mdo="000000",j1
end if    
if i>9 and i<100 then
 let j2=i
 let mdo="00000",j2
end if 
if i>99 and i<1000 then
 let j3=i
 let mdo="0000",j3
end if 
if i>999 and i<10000 then
 let j4=i
 let mdo="000",j4
end if 
if i>9999 and i<100000 then
 let j5=i
 let mdo="00",j5
end if 
if i>99999 and i<1000000 then
 let j6=i
 let mdo="0",j6
end if 
if i>999999 then
 let j7=i
 let mdo=j7
end if 
CLOSE docn148lock
IF status < 0 THEN
 ROLLBACK WORK
ELSE
 COMMIT WORK
END IF
end FUNCTION 

FUNCTION rep_facturas_contab()--facturas contabilizadas
DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
DEFINE mcodpun CHAR(2)
DEFINE cnt INTEGER
DEFINE opp CHAR(1)
 let ubicacion=fgl_getenv("HOME"),"/reportes/facturas_contab"
 let ubicacion=ubicacion CLIPPED
 let mprefijo=NULL
 prompt "Digite el prefijo : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null THEN 
  RETURN
 end if
 LET mfecini = NULL
 LET mfecfin = NULL
 let mdeftit="    RELACION DE FACTURAS "
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL confccr() RETURNING mfecini,mfecfin
 if mfecini is null or mfecfin is null then
   return
 end IF
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
 START REPORT rprec_xls_cont TO "rep"
  DECLARE currec_cont CURSOR FOR
  SELECT * FROM fc_factura_m
   WHERE fecha_factura between mfecini and mfecfin
    AND prefijo = mprefijo
   ORDER BY prefijo, numfac
  FOREACH currec_cont INTO mfc_factura_m.*
   DISPLAY "FACTURA " , mfc_factura_m.numfac
    LET mvaltot =0
    {LET mvaliva = 0}
    LET mvalsub = 0
   initialize mfc_terceros.* to null
   select * into mfc_terceros.* from fc_terceros 
    where nit=mfc_factura_m.nit
   IF mfc_terceros.tipo_persona="2" THEN 
    LET mnombre=NULL
    Let mnombre=mfc_terceros.primer_apellido CLIPPED," ",
                mfc_terceros.segundo_apellido CLIPPED," ",
                mfc_terceros.primer_nombre CLIPPED," ",
                mfc_terceros.segundo_nombre clipped
   ELSE
    LET mnombre=NULL
    Let mnombre=mfc_terceros.razsoc clipped
   END IF
   OUTPUT TO REPORT rprec_xls_cont()
  END FOREACH
 finish report rprec_xls_cont

   let mdefnom="FACTURAS CONTABILIZADAS"
   let mdeflet="condensed"
   let mdeftam=66
   let mhoja="9.5x11"
  CALL manimp()
END FUNCTION

REPORT rprec_xls_cont()
 DEFINE mestado char(20)
 OUTPUT
   top margin 3
   bottom  margin 8
   left  margin 0
   right margin 240
   page length 66
 format
  PAGE HEADER
  let mtime=TIME
  print column 1,"Fecha : ",today," + ",mtime,
        column 141,"Pag No. ",pageno using "####"
 skip 1 LINES
 let mp1 = (150-length(mfc_empresa.razsoc clipped))/2
 print column mp1,mfc_empresa.razsoc
 let mp1 = (150-length("DATOS CONTABILIZACION FACTURAS"))/2
 print column mp1,"DATOS CONTABILIZACION FACTURAS"
   
  skip 1 LINES
 PRINT COLUMN 01, "FACTURAS DEL PREFIJO  : ", mprefijo
 print "--------------------------------------------------------------------",
       "--------------------------------------------------------------------",
       "-----------------"
  print column 01,"NUM FAC",
        column 12,"# INTERNO",
        column 23,"FE.FACTURA",
        Column 51,"DATOS DEL ADQUIRIENTE",
        COLUMN 90," ESTADO ",
        Column 108,"COMPROBANTE",
        Column 128,"REVERSADA"
  print "--------------------------------------------------------------------",
        "--------------------------------------------------------------------",
        "-----------------"
  on every ROW
  CASE 
    when mfc_factura_m.estado="B"
      LET mestado="BORRADOR"
    when mfc_factura_m.estado="A"
     LET mestado="ENVIADA CON ERRORES" 
    when mfc_factura_m.estado="S"
      LET mestado="TRASMITIDA"
    when mfc_factura_m.estado="P"
     LET mestado="PROCESADA EXITOSA" 
    when mfc_factura_m.estado="G"
      LET mestado="CONTIGENCIA"
    when mfc_factura_m.estado="R"
     LET mestado="RECHAZADA CLIENTE"
    when mfc_factura_m.estado="D"
     LET mestado="RECHAZADA DIAN"
    when mfc_factura_m.estado="X"
      LET mestado="RECHAZADA DISPAPELES"
    when mfc_factura_m.estado="N"
     LET mestado="ANULADA POR NOTAC"
   END CASE  
   print column 01,mfc_factura_m.numfac USING "-------",
         column 13,mfc_factura_m.documento,
         column 23,mfc_factura_m.fecha_factura,
         column 37,mfc_factura_m.nit CLIPPED,"-",mnombre[1,30],
         COLUMN 82,mestado,
         column 112,mfc_factura_m.codcop clipped, "-",mfc_factura_m.docu,
         COLUMN 132, mfc_factura_m.reversada
 ON LAST ROW      
    print "--------------------------------------------------------------------",
          "--------------------------------------------------------------------",
          "-----------------" 
    skip to top of page
end REPORT

--agregado por Danny

FUNCTION rep_facturas_pagoo()
DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
DEFINE mcodpun CHAR(2)
DEFINE cnt INTEGER
DEFINE opp,oxx CHAR(1)
DEFINE mprefijo char(5)
DEFINE ox char(2)
let mprefijo=null
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null then 
  return
 end if
 LET mfecini = NULL
 LET mfecfin = NULL
 let mdeftit="    RELACION DE FACTURAS "
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL confccr() RETURNING mfecini,mfecfin
 if mfecini is null or mfecfin is null then
   return
 end IF
 LET ox=NULL
 PROMPT "Digite 10=EFE - 48=T.Cre - 49=T.Deb - 42=Consig - 20=Cheque - 45=Transf : " FOR ox
 IF ox IS NULL OR (ox<>"10" AND ox<>"48" AND ox<>"49" AND ox<>"42" AND ox<>"20" AND ox<>"45") THEN
  RETURN
 end IF
 IF ox="48" OR ox="49" THEN
  LET oxx=NULL
  PROMPT "Digite 1=Visa - 2=Mastercard - 3=Diners - 4=American Express : " FOR oxx
  IF oxx IS NULL OR (oxx<>"1" AND oxx<>"2" AND oxx<>"3" AND oxx<>"4") THEN
   RETURN
  end IF
 END if 
 
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
 -- LET handler = configureOutputt("XLS","22cm","28cm",17,"1.5cm")
{ LET handler = configureOutput_excel(90,"5.0cm","3.0cm","0.5cm","0.5cm","XLSX")}
  --CALL ini_mensaje_espera("Generando Reporte ... Espere por favor...")
  START REPORT rprec_xlspp TO XML HANDLER HANDLER
  IF ox="2" OR ox="3" THEN 
   DECLARE ppcurrec CURSOR FOR
   SELECT * FROM fc_factura_m
    WHERE fecha_elaboracion between mfecini and mfecfin
      AND medio_pago=ox AND franquicia=oxx
      AND prefijo=mprefijo 
    ORDER BY prefijo,documento
   FOREACH ppcurrec INTO mfc_factura_m.*
     OUTPUT TO REPORT rprec_xlspp()
   END FOREACH
  ELSE
   DECLARE pppcurrec CURSOR FOR
   SELECT * FROM fc_factura_m
    WHERE fecha_elaboracion between mfecini and mfecfin
      AND medio_pago=ox 
      AND prefijo=mprefijo
    ORDER BY prefijo,documento
   FOREACH pppcurrec INTO mfc_factura_m.*
     OUTPUT TO REPORT rprec_xlspp()
   END FOREACH
  END if 
 finish report rprec_xlspp
 --let mdefnom="RELACION DE RECIBOS"
 --let mdeflet="condensed"
 --let mdeftam=66
 --let mhoja="9.5x11"
 --call impsn(nomrep,"S")
END FUNCTION


REPORT rprec_xlspp()
 DEFINE mvaltot decimal(12,2)
 define mnombre char(35)
 DEFINE mformap char(10)
 DEFINE mformapp,mformappp char(20)
 DEFINE mestado char(10)
 --output
  --top margin 3
  --bottom  margin 8
  --left  margin 0
  --right margin 240
  --page length 66
 format
  FIRST page HEADER
    
  print column 01,"PREFIJO",
        column 10,"DOCUMENTO",
        column 20,"FE.ELABORA",
        --column 35,"TERCERO",
        --column 60,"NOMBRE TERCERO",
        column 100,"ESTADO",
        COLUMN 110,"VALOR FACTURA",
        COLUMN 140,"FORMA PAGO",
        COLUMN 150,"MEDIO PAGO",
        COLUMN 160,"FRANQUICIA",
        column 190,"TERCERO",
        column 220,"NOMBRE TERCERO"
        

  on every ROW

  LET mvaltot=0
  select sum(valor-(subsi*cantidad)) INTO mvaltot from fc_factura_d
   WHERE prefijo=mfc_factura_m.prefijo AND documento=mfc_factura_m.documento
  IF mvaltot IS NULL then LET mvaltot=0 END if 
  
   initialize mfc_terceros.* to null
   select * into mfc_terceros.* from fc_terceros 
    where nit=mfc_factura_m.nit
   IF mfc_terceros.tipo_persona="2" THEN 
    LET mnombre=NULL
    Let mnombre=mfc_terceros.primer_apellido CLIPPED," ",
                mfc_terceros.segundo_apellido CLIPPED," ",
                mfc_terceros.primer_nombre CLIPPED," ",
                mfc_terceros.segundo_nombre CLIPPED," "
   ELSE
    LET mnombre=NULL
    Let mnombre=mfc_terceros.razsoc CLIPPED
   END IF
   LET mformap=NULL
   LET mformapp=NULL
   LET mformappp=null   
   CASE
    when mfc_factura_m.forma_pago="1"
     LET mformap="CONTADO"
    when mfc_factura_m.forma_pago="2"
     LET mformap="CREDITO" 
   END CASE
   CASE
    when mfc_factura_m.medio_pago="10"
     LET mformapp="EFECTIVO"
    when mfc_factura_m.medio_pago="48"
     LET mformapp="TARJETA CREDITO"
    when mfc_factura_m.medio_pago="49"
     LET mformapp="TARJETA DEBITO"
    when mfc_factura_m.medio_pago="42"
     LET mformapp="CONSIGNACION"
    when mfc_factura_m.medio_pago="20"
     LET mformapp="CHEQUE"
    when mfc_factura_m.medio_pago="45"
     LET mformapp="TRANSFERENCIA"
    when mfc_factura_m.medio_pago="7"
     LET mformapp="LIBRANZA"
   END CASE
   

   CASE  
    when mfc_factura_m.estado="B"
     LET mestado="BORRADOR"
    when mfc_factura_m.estado="A"
     LET mestado="APROBADA" 
   END case
   
   print column 01, mfc_factura_m.prefijo,
         column 10, mfc_factura_m.documento,
         column 20, mfc_factura_m.fecha_elaboracion,
         --column 35, mfc_factura_m.nit,
         --column 60, mnombre,
         column 100, mestado,
         COLUMN 110, mvaltot USING "###,###,##&.&&",
         column 140, mformap,
         column 150, mformapp,
         column 160, mformappp,
         column 190, mfc_factura_m.nit,
         column 220, mnombre

         
  --skip to top of page
end REPORT
{

FUNCTION facterdplyg()
DEFINE x integer
 FOR x = 1 TO gmaxdply
   DISPLAY tpfacter[x].* TO tb_difp[x].*
 END FOR
END FUNCTION
}
FUNCTION nucleo(mcedtra)
 DEFINE tp   RECORD
  documento          LIKE subsi22.documento,
  priape             LIKE subsi22.priape,
  segape             LIKE subsi22.segape,
  nombre             LIKE subsi22.nombre,
  parent             char(4)
 END RECORD,
 mcedtra LIKE fc_factura_m.nit,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM subsi23 WHERE cedtra=mcedtra
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
  LET tp.documento = NULL
  RETURN tp.documento
 END IF
 OPEN WINDOW w_vfc_prefijos1xn AT 8,32 WITH FORM "nucleov"
 MESSAGE "Trabajando por favor espere ... "
 DECLARE c_vfe_nucleo SCROLL CURSOR FOR
 SELECT subsi22.documento, subsi22.priape, subsi22.segape, subsi22.nombre, subsi22.parent
 FROM subsi22,subsi23
    WHERE subsi22.codben=subsi23.codben
     AND subsi23.cedtra=mcedtra
     AND subsi22.estado="A"
 UNION
  SELECT subsi20.cedcon, subsi20.priape, subsi20.segape, subsi20.nombre, "CONY"
   FROM subsi20,subsi21
    WHERE subsi20.cedcon=subsi21.cedcon
     AND subsi21.cedtra=mcedtra
     AND subsi20.estado="A"
  OPEN c_vfe_nucleo
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL nucleorow( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
 DISPLAY "" AT lastline,1
 MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
 MENU ":"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   HELP 5
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL nucleorow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL nucleorow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Vaya" "Se desplaza al registro No.()."
   HELP 9
   LET status = -1
   WHILE ( status < 0 )
    LET status = 1
    PROMPT "Entre el numero de la posicion (1 - ", maxnum, "): " FOR gotorow
    HELP 4
   END WHILE
   IF gotorow IS NULL OR int_flag THEN
    LET int_flag = FALSE
    LET gotorow = currrow
   END IF
   IF gotorow > maxnum THEN
    LET gotorow = maxnum
   END IF
   IF gotorow < 1 THEN
    LET gotorow = 1
   END IF
   LET currrow = gotorow
   CALL nucleorow( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,
         "/ Existen ", maxnum, ")" --AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vfe_nucleo INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.documento = NULL
   EXIT MENU
 END MENU
 CLOSE c_vfe_nucleo
 CLOSE WINDOW w_vfc_prefijos1xn
 RETURN tp.documento
END FUNCTION  

FUNCTION nucleorow( currrow, prevrow, pagenum )
 DEFINE tp RECORD
  documento          LIKE subsi22.documento,
  priape             LIKE subsi22.priape,
  segape             LIKE subsi22.segape,
  nombre             LIKE subsi22.nombre,
  parent             CHAR(4)
  END RECORD,
  scrmax,scrcurr,scrprev,currrow,prevrow,pagenum,newpagenum,x,y,scrfrst INTEGER
 LET scrmax = 8
 LET newpagenum = 1
 LET scrcurr = currrow MOD scrmax
 IF scrcurr > 0 THEN
  LET newpagenum = ( currrow/scrmax ) + 1
 ELSE
  LET scrcurr = scrmax
  LET newpagenum = ( currrow/scrmax )
 END IF
 IF newpagenum <> pagenum THEN
  LET pagenum = newpagenum
  LET scrfrst = currrow - scrcurr + 1
  FETCH ABSOLUTE scrfrst c_vfe_nucleo INTO tp.*
   CASE tp.parent
   WHEN 1
    LET tp.parent ="HIJO"
   WHEN 2
    LET tp.parent ="HERM"
   WHEN 3
    LET tp.parent ="PADR" 
   END CASE
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cenv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO cenv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vfe_nucleo INTO tp.*
   CASE tp.parent
   WHEN 1
    LET tp.parent ="HIJO"
   WHEN 2
    LET tp.parent ="HERM"
   WHEN 3
    LET tp.parent ="PADR"
   END CASE  
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO cenv[y].*
     END FOR
     EXIT FOR
    END IF
   END IF
  END FOR
 ELSE
  LET scrprev = prevrow MOD scrmax
  IF scrprev = 0 THEN
   LET scrprev = scrmax
  END IF
  FETCH ABSOLUTE prevrow c_vfe_nucleo INTO tp.*
   CASE tp.parent
   WHEN 1
    LET tp.parent ="HIJO"
   WHEN 2
    LET tp.parent ="HERM"
   WHEN 3
    LET tp.parent ="PADR" 
  END CASE  
  DISPLAY tp.* TO cenv[scrprev].*
  FETCH ABSOLUTE currrow c_vfe_nucleo INTO tp.*
   CASE tp.parent
   WHEN 1
    LET tp.parent ="HIJO"
   WHEN 2
    LET tp.parent ="HERM"
   WHEN 3
    LET tp.parent ="PADR"
   END CASE 
  DISPLAY tp.* TO cenv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION

FUNCTION aprueba_masivo()
 DEFINE mprefijo,m_prefijo char(5)
 DEFINE mdoo1,mdoo2,mfac INTEGER
 DEFINE mdo1,mdo2,m_documento char(7)
 let mprefijo=NULL
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null THEN 
  RETURN
 end IF
 let mdo1=null
 let mdoo1=null
 prompt "No. Interno Inicial =====>> : " for mdoo1
 if mdoo1 is null then 
  return
 end if
 let mdo2=null
 let mdoo2=null
 prompt "No. Interno Final =====>> : " for mdoo2
 if mdoo2 is null then 
  return
 end if
 LET m_documento=NULL
 FOR mfac = mdoo1 TO mdoo2
  let m_documento=mfac using "&&&&&&&"
  LET cnt=0
  SELECT count(*) INTO cnt FROM fc_factura_m 
   WHERE prefijo = mprefijo
   AND documento=m_documento
   AND estado = "B"
  IF cnt IS NULL THEN LET cnt=0 END IF
  IF cnt<>0 THEN
   INITIALIZE rec_factura_m.* TO NULL
   LET rec_factura_m.prefijo=mprefijo
   LET rec_factura_m.documento=m_documento
   DISPLAY " Aprobando la factura.......... :  ", mprefijo, "-", m_documento 
   CALL aprueba_factu("2")
  END if  
 END for
END FUNCTION
   
FUNCTION habilita_genera_comprobante()
DEFINE mprefijo,m_prefijo char(5)
 DEFINE mdoo1,mdoo2,mfac INTEGER
 DEFINE mmensaje VARCHAR(200)
 let mprefijo=NULL
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null THEN 
  RETURN
 end IF
 let mdoo1=null
 prompt "No. Factura =====>> : " for mdoo1
 if mdoo1 is null then 
  return
 end IF
 LET cnt=0
 SELECT count(*) INTO cnt FROM fc_factura_m 
  WHERE prefijo = mprefijo
  AND numfac = mdoo1
  AND estado = "P"
 IF cnt IS NULL THEN LET cnt=0 END IF
 IF cnt<>0 THEN
  INITIALIZE mfc_factura_m.* TO NULL
  SELECT * INTO mfc_factura_m.* FROM fc_factura_m
   WHERE prefijo = mprefijo AND numfac = mdoo1
  IF mfc_factura_m.codcop IS NOT NULL AND mfc_factura_m.docu IS NOT null THEN
   LET cnt=0
   SELECT COUNT(*) INTO cnt FROM niif141
   WHERE niif141.codcop = mfc_factura_m.codcop AND
         niif141.documento = mfc_factura_m.docu
   IF cnt <> 0 THEN
    CALL FGL_WINMESSAGE( "Administrador", "LA FACTURA YA TIENE COMPROBANTE GENERADO-DESCARGADO, DEBE ELIMINARSE", "stop")
    return
   END IF
   LET cnt=0
   SELECT COUNT(*) INTO cnt FROM niif146
   WHERE niif146.codcop = mfc_factura_m.codcop AND
         niif146.documento = mfc_factura_m.docu
   IF cnt <> 0 THEN
    CALL FGL_WINMESSAGE( "Administrador", "LA FACTURA YA TIENE COMPROBANTE GENERADO-ACTUALIZADO, DEBE ELIMINARSE", "stop")
    return
   END IF
   UPDATE fc_factura_m SET codcop=NULL,docu=NULL
       WHERE prefijo = mprefijo AND numfac = mdoo1
  END IF
 ELSE
     LET mmensaje ="LA FACTURA ", mprefijo CLIPPED, "-", mdoo1 USING "&&&&&&&",
    " NO HA SIDO TRASMITIDA EXITOSA"
    CALL FGL_WINMESSAGE( "Administrador", mmensaje, "information") 
 END if 
END FUNCTION

FUNCTION genera_comprobante()
 DEFINE mprefijo,m_prefijo char(5)
 DEFINE mdoo1,mdoo2,mfac INTEGER
 DEFINE mmensaje VARCHAR(200)
 let mprefijo=NULL
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null THEN 
  RETURN
 end IF
 let mdoo1=null
 prompt "No. Factura Inicial =====>> : " for mdoo1
 if mdoo1 is null then 
  return
 end if
 let mdoo2=null
 prompt "No. Factura Final =====>> : " for mdoo2
 if mdoo2 is null then 
  return
 end IF
 FOR mfac = mdoo1 TO mdoo2
   --CALL consulta_estado_documento_2("1",mprefijo, mfac)
   LET cnt=0
  SELECT count(*) INTO cnt FROM fc_factura_m 
   WHERE prefijo = mprefijo
   AND numfac = mfac
   AND estado = "P"
  IF cnt IS NULL THEN LET cnt=0 END IF
  IF cnt>0 THEN
   INITIALIZE rec_factura_m.* TO NULL
   INITIALIZE mfc_factura_m.* TO NULL
   SELECT * INTO mfc_factura_m.* 
     FROM fc_factura_m
      WHERE prefijo = mprefijo
      AND numfac = mfac
    LET rec_factura_m.prefijo = mfc_factura_m.prefijo
    LET rec_factura_m.documento = mfc_factura_m.documento
    LET rec_factura_m.numfac= mfc_factura_m.numfac
   IF mfc_factura_m.codcop IS NULL OR mfc_factura_m.codcop ="" THEN   
     INITIALIZE mfc_prefijos.* TO NULL
     SELECT * INTO mfc_prefijos.* FROM fc_prefijos
     WHERE fc_prefijos.prefijo = mprefijo
    IF mfc_prefijos.conta="S" THEN 
      {CALL gen_comp_factura("2")}
      let mdocini= mdocumento
      let mdocfin= mdocumento
      let mind=0
      DISPLAY "COMPROBANTE VENTA : ", mcodcop , " Documento : ", mdocumento
      CALL ini_mensaje_espera("Act comprobante Venta (ingreso) .....")
     { CALL niif141act()}
      CALL fin_mensaje_espera()
      {CALL gen_comp_factura_s("2")}
      let mdocini= mdocumento
      let mdocfin= mdocumento
      let mind=0
      DISPLAY "COMPROBANTE SUBSIDIO TARIFA : ", mcodcop , " Documento : ", mdocumento
      CALL ini_mensaje_espera("Act comprobante Subsidio Tarifa.....")
      {CALL niif141act()}
      CALL fin_mensaje_espera()
     { CALL gen_comp_factura_a("2")}
      let mdocini= mdocumento
      let mdocfin= mdocumento
      let mind=0
      DISPLAY "COMPROBANTE ANTICIPO : ", mcodcop , " Documento : ", mdocumento
      CALL ini_mensaje_espera("Act comprobante Anticipos.....")
     { CALL niif141act()}
      CALL fin_mensaje_espera()
      {CALL gen_comp_factura_b("2")}
      let mdocini= mdocumento
      let mdocfin= mdocumento
      let mind=0
      DISPLAY "COMPROBANTE  BENEFICIO : ", mcodcop , " Documento : ", mdocumento
      CALL ini_mensaje_espera("Act comprobante Otros Beneficios.....")
     { CALL niif141act()}
      CALL fin_mensaje_espera()
     END IF
   ELSE
     CALL FGL_WINMESSAGE( "Administrador", "FACTURA YA CONTABILIZADA", "information")
   END IF  
  ELSE
    LET mmensaje ="LA FACTURA ", mprefijo CLIPPED, "-", mfac USING "&&&&&&&",
    " NO HA SIDO TRASMITIDA EXITOSA"
    CALL FGL_WINMESSAGE( "Administrador", mmensaje, "information")
  END if  
 END for
END FUNCTION

FUNCTION reversa_comp_rechazo()
 DEFINE mprefijo char(5)
 DEFINE mdo1 integer
 let mprefijo=NULL
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null THEN 
  RETURN
 end IF
 let mdo1=null
 prompt "No. Factura =====>> : " for mdo1
 if mdo1 is null then 
  return
 end if
  LET cnt=0
  SELECT count(*) INTO cnt FROM fc_factura_m 
   WHERE prefijo = mprefijo
   AND numfac=mdo1
   AND estado = "R"
  IF cnt IS NULL THEN LET cnt=0 END IF
  IF cnt=0 THEN
   CALL FGL_WINMESSAGE( "Administrador", "EL DOCUMENTO SOPORTE NO ESTA EN ESTADO RECHAZADO", "stop")
   return
  END IF
  LET cnt=0
  SELECT count(*) INTO cnt FROM fc_factura_m 
   WHERE prefijo = mprefijo
   AND numfac=mdo1
   AND estado = "R" AND reversada="S"
  IF cnt IS NULL THEN LET cnt=0 END IF
  IF cnt<>0 THEN
   CALL FGL_WINMESSAGE( "Administrador", "EL COMPROBANTE DE EL DOCUMENTO SOPORTE RECHAZADO YA FUE PROCESADO", "stop")
   return
  END IF
  LET cnt=0
  SELECT count(*) INTO cnt FROM fc_factura_m 
   WHERE prefijo = mprefijo
   AND numfac=mdo1
   AND estado = "R" AND codcop IS NOT null
  IF cnt IS NULL THEN LET cnt=0 END IF
  IF cnt<>0 THEN
   CALL FGL_WINMESSAGE( "Administrador", "EL DOCUMENTO SOPORTE NO FUE CONTABILIZADO NO ES NECESARIO REVERSARLO", "stop")
   return
  END IF
  UPDATE fc_factura_m SET reversada="S",fecrever=TODAY  
  WHERE prefijo = mprefijo
  AND numfac=mdo1
  AND estado = "R"
  {CALL gen_comp_factura_n_rever(mprefijo,mdo1)
  CALL gen_comp_factura_s_n_rever(mprefijo,mdo1)}
END FUNCTION

FUNCTION fc_factura_mremove()
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : RETIRO DE DOCUMENTO SOPORTE " ATTRIBUTE(BLUE)
 PROMPT "Esta seguro de borrar el registro (s/n)? " FOR CHAR answer
 IF answer MATCHES "[Ss]" THEN
  IF rec_factura_m.estado<>"B" THEN
   CALL FGL_WINMESSAGE( "Administrador", "EL DOCUMENTO NO ESTA EN ESTADO BORRADOR", "stop")
   LET answer="N"
  END if
 END IF
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO EL REGISTRO " ATTRIBUTE(BLUE)
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  DELETE FROM fc_factura_m
     WHERE prefijo = rec_factura_m.prefijo
    AND documento =  rec_factura_m.documento
    AND estado ="B"
  IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
  DELETE FROM fc_factura_d
     WHERE prefijo = rec_factura_m.prefijo
    AND documento =  rec_factura_m.documento
  IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
  DELETE FROM fc_factura_anti
     WHERE prefijo = rec_factura_m.prefijo
    AND documento =  rec_factura_m.documento
  IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
  DELETE FROM fc_factura_tot
     WHERE prefijo = rec_factura_m.prefijo
    AND documento =  rec_factura_m.documento
  IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
  
  DELETE FROM fc_factura_ter
     WHERE prefijo = rec_factura_m.prefijo
    AND documento =  rec_factura_m.documento
  IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro referenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF

  
  
   
  IF NOT gerrflag THEN 
   INITIALIZE gterceros.* TO NULL
   MENU "Información"  ATTRIBUTE( style= "dialog", 
        comment= " El Registro  fue retirado", image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   COMMIT WORK
  ELSE
   MENU "Información"  ATTRIBUTE( style= "dialog", 
     comment= " El retiro del registro fue cancelado",  image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   ROLLBACK WORK
  END IF
 ELSE
  MENU "Información"  ATTRIBUTE( style= "dialog", 
    comment= " El retiro del registro fue cancelado",image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  LET int_flag = TRUE
 END IF
END FUNCTION 

FUNCTION RW_Inicializa(Nombre_reporte,formato,archivo_4rp, lb_preview)
DEFINE 
 Nombre_reporte STRING
,formato STRING
,archivo_4rp STRING
--Manejador. El cual contiene todas las configuraciones 
--para la generación del reporte
,lb_preview     BOOLEAN 
,lsxd_manejador OM.SAXDOCUMENTHANDLER   
,ruta_completa STRING
,uuid           STRING

      LET ruta_completa = "C:\\Puerto\\", Nombre_reporte
      
      INITIALIZE lsxd_manejador TO NULL
      
      {IF fgl_report_loadCurrentSettings(archivo_4rp) THEN
       IF formato=="Genero Report Viewer" THEN
            IF isGDC() THEN
               LET formato="SVG"
            ELSE
               LET formato="Browser"
            END IF
         END IF
         CALL fgl_report_setOutputFileName(ruta_completa) 
         CALL fgl_report_selectDevice(formato)
         CALL fgl_report_selectPreview(lb_preview)--se coloca en true para ver en vista previa
                 CASE formato
            WHEN "PDF"
               CALL fgl_report_configurePDFDevice (null, false, false, false,1, null)
            WHEN "XLS"--  SI LOS DEJO ASI COMENTARIADO MUESTRA UNA PAGINA DIFERENTE EN EXCEL PERO SI LOS HABILITO LOS  MUESTRA TODOS EN UNA SOLA HOJA
               CALL fgl_report_configureXLSDevice(1, NULL,FALSE,TRUE,NULL,TRUE, TRUE)  --ESTA LINEA TAMBIEN HAY QUE COMENTARIARLA PARA QUE MUESTRE VARIAS HOJAS EN EXCEL 
            --WHEN "XLSX"
               --CALL fgl_report_configureXLSXDevice(1, NULL,FALSE,TRUE,NULL,NULL,TRUE)
            WHEN "RTF"
               CALL fgl_report_configureRTFDevice (1, null, null, NULL)
            WHEN "Image"


    CALL fgl_report_configureImageDevice (false, false, false, 1, null, "jpg", "C:\\Puerto\\", "RPT_" , NULL)
            WHEN "HTML"
               CALL fgl_report_configureHTMLDevice (1, null, null, null, null, null, null, null, NULL )
            WHEN "SVG"
               CALL fgl_report_configureImageDevice (false, false, false, 1, null, "jpg", null, null, NULL)
            WHEN "Printer"
               CALL fgl_report_setPageMargins("0.05cm", "0.05cm", "0.05cm", "0.05cm")
               CALL fgl_report_setPrinterPrintQuality("high")
               CALL fgl_report_setPrinterSides("one-sided")
               --Para obtener más información de las impresoras disponibles
               --se debe ejecutar la herramienta 
               --$GDCDIR/bin/printerinfo.exe
               --Depués de esa ejecución, ya es posible configurar los siguientes parámetros
               --CALL fgl_report_setSVGPrinterName("Nombre_impresora")
               --CALL fgl_report_setSVGPaperSource("A4")
               --CALL fgl_report_configureSVGPreview("PrintOnNamedPrinter")
            WHEN "Browser"
               LET uuid=security.RandomGenerator.CreateUUIDString()
               IF fgl_getenv("GRE_PRIVATE_DIR") IS NOT NULL THEN
                  CALL fgl_report_setBrowserDocumentDirectory(fgl_getenv("GRE_PRIVATE_DIR")||"/"||uuid)
                  CALL fgl_report_setBrowserFontDirectory(fgl_getenv("GRE_PUBLIC_DIR")||"/fonts")
                  CALL fgl_report_setBrowserDocumentDirectoryURL(fgl_getenv("GRE_PRIVATE_URL_PREFIX")||"/"||uuid)
                  CALL fgl_report_setBrowserFontDirectoryURL(fgl_getenv("GRE_PUBLIC_URL_PREFIX")||"/fonts")            
                  IF lb_preview THEN
                     CALL ui.Interface.frontCall( "standard", "launchurl", [fgl_getenv("GRE_REPORT_VIEWER_URL_PREFIX")||"/viewer.html?reportId="||uuid||"&privateUrlPrefix="||fgl_getenv("GRE_PRIVATE_URL_PREFIX")], [] )
                  END IF
               END IF
               CALL fgl_report_setOutputFileName(Nombre_reporte)  
         END CASE
         LET lsxd_manejador = fgl_report_commitCurrentSettings()
      END IF}
      RETURN lsxd_manejador
END FUNCTION

FUNCTION f_salida_reporte(tipo_reporte)
DEFINE
   -- arr_empleados      datos
   tipo_reporte       VARCHAR(50)
   ,salida_reporte     VARCHAR(20)
   ,lb_preview         BOOLEAN
   ,lb_genera_reporte  BOOLEAN

   --Inicialización de variables
   LET salida_reporte    = NULL
   LET lb_preview        = FALSE
   LET lb_genera_reporte = FALSE

   OPEN WINDOW w_salida_reporte WITH FORM "OpcionesSalidaFrm"

      DIALOG
      ATTRIBUTES(UNBUFFERED)

         INPUT salida_reporte
          FROM rgp_salida_reporte
          ATTRIBUTES (WITHOUT DEFAULTS)

            ON CHANGE rgp_salida_reporte
   --habilita boton 
                CALL dialog.setActionActive("btn_preview",salida_reporte!="Image")-- esta linea e sla que permite habilitar el boton si es diferente a imagen sino lo deshabilita
               CALL dialog.setActionActive("btn_guardar_disco",salida_reporte!="Genero Report Viewer" OR isGDC())-- esta linea e sla que permite habilitar el boton si es diferente a imagen sino lo deshabilita
               IF ( salida_reporte ==  "Printer") THEN
                  CALL dialog.setActionActive("btn_guardar_disco",FALSE)
               END IF   
         END INPUT

         ON ACTION btn_preview
      IF ( salida_reporte IS NULL ) THEN
                  DISPLAY "Favor de seleccionar una salida de reporte.............."
                  CALL fgl_winmessage("Advertencia","Favor de seleccionar una salida de reporte","exclamation")
               CONTINUE DIALOG
            END IF   
            --Se muestra la vista preliminar
            LET lb_preview        = TRUE
            LET lb_genera_reporte = TRUE
            EXIT DIALOG 

         ON ACTION btn_guardar_disco
            IF ( salida_reporte IS NULL ) THEN
               DISPLAY "Favor de seleccionar una salida de reporte.............."
               CALL fgl_winmessage("Advertencia","Favor de seleccionar una salida de reporte","exclamation")
               CONTINUE DIALOG
            END IF
            --Se guarda el reporte en disco
            LET lb_preview        = FALSE
            LET lb_genera_reporte = TRUE
            EXIT DIALOG

         ON ACTION btn_salir
            LET lb_genera_reporte = FALSE
            EXIT DIALOG
      END DIALOG

      IF ( lb_genera_reporte == TRUE ) THEN
         IF ( tipo_reporte == "Reporte_simple" ) THEN
            CALL imprime_ordenp(lb_preview, salida_reporte)
         END IF    
      END IF      

   CLOSE WINDOW w_salida_reporte
END FUNCTION

FUNCTION isGDC()
DEFINE cliente STRING
   LET cliente = ui.Interface.getFrontEndName()
   IF ( cliente == "GDC" ) THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF  
END FUNCTION

FUNCTION llenar_combo_prefijo (cb)
DEFINE cb ui.ComboBox
DEFINE prefijos_usuario RECORD LIKE fc_prefijos_usu.*


CALL cb.CLEAR()
DECLARE crf4 CURSOR FOR 
    SELECT * FROM fc_prefijos_usu WHERE usu_elabora = musuario
    FOREACH crf4 INTO prefijos_usuario.*     
        CALL cb.addItem(prefijos_usuario.prefijo, prefijos_usuario.prefijo)
    END FOREACH
END FUNCTION 

function aprueba_factu(mmtp)
DEFINE mmtp char(1)
define ubicacion char(80)
DEFINE mtime char(8)
DEFINE mnumfac,x INTEGER
DEFINE mdepar char(2)
DEFINE mtot_reg integer
DEFINE op char(1)
DEFINE numerofac, mnumcod INTEGER
IF mmtp="7" THEN
 LET cnt=0
 SELECT count(*) INTO cnt FROM fc_factura_m
 WHERE fc_factura_m.prefijo = rec_factura_m.prefijo
  AND fc_factura_m.documento = rec_factura_m.documento
  AND fc_factura_m.estado="B"
 IF cnt IS NULL THEN LET cnt=0 END IF
 IF cnt=0 THEN
  MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     comment= " El Documento soporte No existe o Ya fue Aprobado ",
      image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
     LET mentra="N"
   RETURN  
    
 END IF 
 LET cnt=0
 SELECT count(*) INTO cnt FROM fc_prefijos_usuu
  WHERE prefijo=rec_factura_m.prefijo AND usu_autoriza=musuario
 IF cnt IS NULL THEN LET cnt=0 END IF
 IF cnt=0 THEN
  MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
    comment= " El usuario no puede aprobar Documentos Soporte para este Prefijo ",
     image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
    LET mentra="N"
    return
 END IF
END if 
 LET mnumfac=null 
 select numero into mnumfac from fc_prefijos WHERE prefijo=rec_factura_m.prefijo
 IF mnumfac IS NULL THEN LET mnumfac=1 END IF
 LET cnt = 1
 LET x = mnumfac
 WHILE cnt <> 0
  SELECT COUNT(*) INTO cnt FROM fc_factura_m
   WHERE fc_factura_m.prefijo = rec_factura_m.prefijo
     AND fc_factura_m.numfac = mnumfac
  IF cnt <> 0 THEN
   LET x = x + 1
   UPDATE fc_prefijos SET numero=numero+1 WHERE prefijo=rec_factura_m.prefijo
   LET mnumfac = x
  ELSE
   UPDATE fc_prefijos SET numero=numero+1 WHERE prefijo=rec_factura_m.prefijo
   EXIT WHILE
  END IF
 END WHILE
 LET mtime=TIME
 UPDATE fc_factura_m SET numfac=mnumfac,fecha_factura=today,hora=mtime,estado="A",usuario_apru=musuario
 WHERE fc_factura_m.prefijo = rec_factura_m.prefijo
  AND fc_factura_m.documento = rec_factura_m.documento
  AND fc_factura_m.estado="B"

  IF mnumfac IS NOT NULL AND mnumfac > 0 THEN   
   IF mmtp = "7" then
    CALL enviar_documento_soporte_prueba(rec_factura_m.prefijo,mmtp,rec_factura_m.documento,mnumfac) --AQUI VA EL ENVIO
   END IF
 END if  
END FUNCTION

