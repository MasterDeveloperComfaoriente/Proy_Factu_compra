GLOBALS "fc_globales.4gl"
SCHEMA empresa
DEFINE mregs,dias INTEGER
DEFINE medad DECIMAL(14,6)
DEFINE xx,mced char(1)
DEFINE mcon char(2)
DEFINE mseredu integer
DEFINE mcop,mcopp char(4)
DEFINE rec_servic RECORD LIKE fc_servicios.*
DEFINE msubsi21 RECORD LIKE subsi21.*
DEFINE msubsi23 RECORD LIKE subsi23.*
DEFINE mtiprep char(1)
DEFINE mvaltot, mvalsub, mvaliva decimal(12,2)
FUNCTION fc_nota_mmain()
 DEFINE combestadon ui.ComboBox
 DEFINE combtipon ui.ComboBox
 DEFINE combtiponn ui.ComboBox
 DEFINE combtiponnn ui.ComboBox
 DEFINE exist SMALLINT
 OPEN WINDOW w_mfc_nota_m AT 1,1 WITH FORM "fc_nota"
 LET gmaxarray = 50
 LET gmaxdply = 9
 LET glastline = 23
 LET exist = FALSE
 INITIALIZE gfc_nota_m.* TO NULL
 INITIALIZE tpfc_nota_m.* TO NULL
  LET combestadon = ui.ComboBox.forName("fc_nota_m.estado")
  CALL combestadon.clear()
  CALL combestadon.addItem("B","BORRADOR")
   CALL combestadon.addItem("A","ENVIADA CON ERRORES")
   CALL combestadon.addItem("S","TRASMITIDA")
   CALL combestadon.addItem("P","PROCESADA EXITOSA")
   CALL combestadon.addItem("G","CONTIGENCIA")
   CALL combestadon.addItem("R","RECHAZADA CLIENTE")
   CALL combestadon.addItem("D","RECHAZADA DIAN")
   CALL combestadon.addItem("X","RECHAZADA DISPAPELES")
  LET combtipon = ui.ComboBox.forName("fc_nota_m.tipo")
  CALL combtipon.clear()
  CALL combtipon.addItem("ND","NOTA DEBITO")
  CALL combtipon.addItem("NC","NOTA CREDITO")

  LET combtiponn = ui.ComboBox.forName("fc_nota_m.tipo_nota")
  CALL combtiponn.clear()
  CALL combtiponn.addItem("1","NC-DEVOLUCION DE PARTE DE LOS BIENES")
  CALL combtiponn.addItem("2","NC-ANULACION DE FACTURA")
  CALL combtiponn.addItem("3","NC-REBAJA TOTAL APLICADA")
  CALL combtiponn.addItem("4","NC-DESCUENTO TOTAL APLICADO")
  CALL combtiponn.addItem("5","NC-RESCISION: NULIDAD POR FALTA DE REQUISITOS")
  CALL combtiponn.addItem("6","NC-OTROS")
  CALL combtiponn.addItem("7","ND-INTERESES")
  CALL combtiponn.addItem("8","ND-GASTOS POR COBRAR")
  CALL combtiponn.addItem("9","ND-CAMBIO DEL VALOR")
  CALL combtiponn.addItem("10","ND-OTROS")

  LET combtiponnn = ui.ComboBox.forName("fc_nota_m.tipo_nota_c")
  CALL combtiponnn.clear()
  CALL combtiponnn.addItem("1","CAMBIO CATEGORIA")
  CALL combtiponnn.addItem("2","CAMBIO DE SERVICIO")
  
  CALL fc_nota_minitga()
  CALL fc_nota_minitta()
 MENU "NOTA"
  COMMAND "Adiciona" "Adiciona un documento de NOTA"
   LET mcodmen="fc31"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL fc_nota_madd()
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
     LET exist = TRUE
    END IF
    CALL fc_nota_mdetail()
   END if 
  COMMAND "Consulta" "Consulta los documentos de NOTA adicionadas"
   LET mcodmen="fc32"
   CALL opcion() RETURNING op
   if op="S" THEN
    CALL fc_nota_mquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF
    CALL fc_nota_mdetail()
   END if 
  COMMAND "Listar" "Lista los servicios del NOTA en consulta"
   LET mcodmen="fc33"
   CALL opcion() RETURNING op
   if op="S" THEN
    IF NOT exist THEN
     CALL FGL_WINMESSAGE( "Administrador", " NO HAY NOTA(S) EN CONSULTA ", "stop")
    ELSE
     CALL fc_nota_mview()
     CALL fc_nota_mdetail()
    END IF
   END IF 
  --COMMAND "Imprimir Nota" "Imprime La Nota DB - CR"
  --CALL imprime_ordenn()
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 10
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfc_nota_m
END FUNCTION
FUNCTION fc_nota_minitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE gafc_nota_m[x].* TO NULL
 END FOR
END FUNCTION
FUNCTION fc_nota_minitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE tafc_nota_m[x].* TO NULL
 END FOR
END FUNCTION
FUNCTION fc_nota_mdetail()
 DEFINE mnombre char(50)
 DEFINE x SMALLINT
 DISPLAY BY NAME gfc_nota_m.tipo THRU gfc_nota_m.docu
 INITIALIZE mfc_factura_m.* TO NULL
 SELECT * into mfc_factura_m.* FROM fc_factura_m
  WHERE prefijo = gfc_nota_m.prefijo
    AND numfac = gfc_nota_m.numfac
 DISPLAY mfc_factura_m.fecha_factura TO mfccfactu
 INITIALIZE mfc_prefijos.* TO NULL
 SELECT * into mfc_prefijos.* FROM fc_prefijos
  WHERE prefijo = gfc_nota_m.prefijo
  DISPLAY mfc_prefijos.descripcion TO mprefijo
  INITIALIZE mfc_terceros.* TO NULL
  SELECT * into mfc_terceros.* FROM fc_terceros
  WHERE nit = mfc_factura_m.nit
  DISPLAY mfc_terceros.nit TO mnit
  IF mfc_terceros.tipo_persona="1" THEN
   DISPLAY mfc_terceros.razsoc TO mrazsoc
  ELSE
   LET mnombre=NULL
   LET mnombre=mfc_terceros.primer_nombre clipped," ",mfc_terceros.segundo_nombre clipped," ",
               mfc_terceros.primer_apellido clipped," ",mfc_terceros.segundo_apellido clipped," "
   DISPLAY mnombre TO mrazsoc
  END if  
 FOR x = 1 TO gmaxdply
  DISPLAY gafc_nota_m[x].* TO ofc[x].*
 END FOR
END FUNCTION
FUNCTION fc_nota_mtatoga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET gafc_nota_m[x].* = tafc_nota_m[x].*
 END FOR
END FUNCTION 
FUNCTION fc_nota_mgatota()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  LET tafc_nota_m[x].* = gafc_nota_m[x].*
 END FOR
END FUNCTION
FUNCTION fc_nota_mrownull( x )
 DEFINE x, rownull SMALLINT
 LET rownull = TRUE
 IF tafc_nota_m[x].codigo IS NOT NULL AND
    --tafc_nota_m[x].descripcion IS NOT NULL AND
    --tafc_nota_m[x].codcat IS NOT NULL AND
    tafc_nota_m[x].cantidad IS NOT NULL AND
    tafc_nota_m[x].valoruni IS NOT NULL AND
    tafc_nota_m[x].iva IS NOT NULL AND
    tafc_nota_m[x].impc IS NOT NULL AND
    tafc_nota_m[x].valor IS NOT NULL THEN
    LET rownull = FALSE
 END IF
 RETURN rownull
END FUNCTION
FUNCTION fc_nota_mgetdetail()
 DEFINE x SMALLINT
 CALL fc_nota_minitga()
 DECLARE c_gfc_nota_m CURSOR FOR
  SELECT fc_nota_d.codigo, fc_servicios.descripcion,
         {fc_nota_d.subcodigo,} fc_sub_servicios.descripcion,
         fc_beneficios.descripcion,
         fc_nota_d.cantidad,
         fc_nota_d.valoruni,
         fc_nota_d.iva,
         fc_nota_d.impc,
         fc_nota_d.valorbene,
         fc_nota_d.valor
   FROM fc_nota_d, fc_servicios, OUTER fc_sub_servicios, OUTER fc_beneficios
   WHERE  fc_nota_d.tipo = gfc_nota_m.tipo
     AND fc_nota_d.documento = gfc_nota_m.documento
     AND fc_nota_d.codigo = fc_servicios.codigo
     {AND fc_nota_d.subcodigo = fc_sub_servicios.codigo}
   ORDER BY fc_nota_d.valor ASC
 LET x = 1
 FOREACH c_gfc_nota_m INTO gafc_nota_m[x].*
  LET x = x + 1
  IF x > gmaxarray THEN
   EXIT FOREACH
  END IF
 END FOREACH
END FUNCTION
FUNCTION fc_nota_mgetdetaill()
 DEFINE x SMALLINT
 CALL fc_nota_minitga()
 DECLARE tc_gfc_nota_m CURSOR FOR
  SELECT fc_factura_d.codigo, fc_servicios.descripcion,
         {fc_factura_d.subcodigo,} fc_sub_servicios.descripcion,
         fc_beneficios.descripcion,
         fc_factura_d.cantidad,
         fc_factura_d.valoruni,
         fc_factura_d.iva,
         fc_factura_d.impc,
         fc_factura_d.valorbene,
         fc_factura_d.valor
   FROM fc_factura_d, fc_servicios, OUTER fc_sub_servicios, OUTER fc_beneficios
   WHERE  fc_factura_d.prefijo = mfc_factura_m.prefijo
     AND fc_factura_d.documento = mfc_factura_m.documento
     AND fc_factura_d.codigo = fc_servicios.codigo
     {AND fc_factura_d.subcodigo = fc_sub_servicios.codigo}
  ORDER BY fc_factura_d.valor ASC
 LET x = 1
 FOREACH tc_gfc_nota_m INTO gafc_nota_m[x].*
  LET tafc_nota_m[x].* = gafc_nota_m[x].*
  LET x = x + 1
  IF x > gmaxarray THEN
   EXIT FOREACH
  END IF
 END FOREACH
 LET mregs = x
END FUNCTION
FUNCTION fc_nota_mdetaill()
 FOR x = 1 TO gmaxdply
  DISPLAY gafc_nota_m[x].* TO ofc[x].*
 END FOR
END FUNCTION

FUNCTION fc_nota_madd()
 DEFINE mnombre char(50)
 DEFINE mnumcod integer
 define mdetalle like villa_tip_conv.detalle 
 DEFINE z, cnt,cnt2, x, v, y, t, rownull, currow,
        scrrow, toggle, ttlrow SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 DISPLAY "" AT 1,1
 DISPLAY "" AT 2,1
 MESSAGE "Estado : ADICIONANDO UNA NOTA DEBITO O CREDITO " 
 CLEAR FORM
 INITIALIZE tpfc_nota_m.* TO NULL
 CALL fc_nota_minitta()
 LET ttlrow = 0
 LABEL fc_nota_mtog1:
 LET toggle = FALSE
 let v=0
 LET xx="1"
 INPUT BY NAME tpfc_nota_m.tipo THRU tpfc_nota_m.estado WITHOUT DEFAULTS
  AFTER FIELD tipo
   IF tpfc_nota_m.tipo IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL TIPO DE NOTA NO FUE DIGITADO  ", "stop") 
    NEXT FIELD tipo
   END IF
  BEFORE FIELD documento
   select max(documento) into mnumcod from fc_nota_m
     WHERE tipo=tpfc_nota_m.tipo
   if mnumcod is null then let mnumcod=1 end if
   LET cnt = 1
   LET x = mnumcod
   LET tpfc_nota_m.documento = x USING "&&&&&&&"
   WHILE cnt <> 0
    SELECT COUNT(*) INTO cnt FROM fc_nota_m
     WHERE documento = tpfc_nota_m.documento
      AND  tipo=tpfc_nota_m.tipo
    IF cnt <> 0 THEN
     LET x = x + 1
     LET tpfc_nota_m.documento = x USING "&&&&&&&"
     DISPLAY BY NAME tpfc_nota_m.documento
    ELSE
     EXIT WHILE
    END IF
   END WHILE
   DISPLAY BY NAME tpfc_nota_m.documento
   let tpfc_nota_m.fecha_elaboracion=today
   let tpfc_nota_m.estado="B"
   DISPLAY BY NAME tpfc_nota_m.fecha_elaboracion
   DISPLAY BY NAME tpfc_nota_m.estado
   NEXT FIELD fecha_elaboracion

  AFTER FIELD documento
   IF tpfc_nota_m.documento IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " NUMERO INTERNO NO FUE DIGITADO ", "stop")
    NEXT FIELD documento
   END IF

  AFTER FIELD fecha_elaboracion
   IF tpfc_nota_m.fecha_elaboracion IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA fecha DE ELABORACION NO FUE DIGITADO ", "stop")
    NEXT FIELD fecha_elaboracion
   ELSE 
    IF tpfc_nota_m.fecha_elaboracion<TODAY THEN
     CALL FGL_WINMESSAGE( "Administrador", " LA fecha DE ELABORACION NO PUEDE SER DIfcRENTE A HOY ", "stop")
     NEXT FIELD fecha_elaboracion
    END IF
    IF tpfc_nota_m.fecha_elaboracion>TODAY THEN
     CALL FGL_WINMESSAGE( "Administrador", " LA fecha DE ELABORACION NO PUEDE SER DIfcRENTE A HOY ", "stop")
     NEXT FIELD fecha_elaboracion
    END IF 
   END IF
   NEXT FIELD tipo_nota

  AFTER FIELD tipo_nota
   IF tpfc_nota_m.tipo_nota IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO FUE DIGITADO  ", "stop") 
    NEXT FIELD tipo_nota
   END IF 
   IF tpfc_nota_m.tipo="NC" THEN
    IF tpfc_nota_m.tipo_nota="7" OR tpfc_nota_m.tipo_nota="8" OR tpfc_nota_m.tipo_nota="9" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO CORRESPONDE CON EL TIPO NOTA CREDITO  ", "stop") 
     NEXT FIELD tipo_nota
    END if
   END IF
   IF tpfc_nota_m.tipo="ND" THEN
    IF tpfc_nota_m.tipo_nota="1" OR tpfc_nota_m.tipo_nota="2" OR tpfc_nota_m.tipo_nota="3" OR
       tpfc_nota_m.tipo_nota="4" OR tpfc_nota_m.tipo_nota="5" OR tpfc_nota_m.tipo_nota="6" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO CORRESPONDE CON EL TIPO NOTA DEBITO  ", "stop") 
     NEXT FIELD tipo_nota
    END if
   END IF 
 
  AFTER FIELD tipo_nota_c
   IF tpfc_nota_m.tipo_nota="6" THEN
    IF tpfc_nota_m.tipo_nota_c IS NULL THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA DE LA CAJA NO FUE DIGITADO  ", "stop") 
      NEXT FIELD tipo_nota_c
    END IF
   ELSE
     NEXT FIELD prefijo
   END if 
   
 BEFORE FIELD prefijo
   LET cnt=0
   SELECT count(*) INTO cnt FROM fc_prefijos_usu
    WHERE usu_elabora=musuario
   IF cnt IS NULL THEN LET cnt=0 END IF
   IF cnt>1 THEN
    CALL fc_prefijosval() RETURNING tpfc_nota_m.prefijo
    IF tpfc_nota_m.prefijo is NULL THEN
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
       WHERE fc_prefijos.prefijo = tpfc_nota_m.prefijo
      DISPLAY mfc_prefijos.descripcion TO mprefijo 
    END IF
   ELSE
    IF cnt<=1 THEN 
     INITIALIZE mfc_prefijos_usu.* TO NULL
     SELECT * INTO mfc_prefijos_usu.* FROM fc_prefijos_usu
      WHERE usu_elabora=musuario
     LET tpfc_nota_m.prefijo = mfc_prefijos_usu.prefijo 
     DISPLAY BY NAME tpfc_nota_m.prefijo
    END if 
   END if 
  AFTER FIELD prefijo
    IF tpfc_nota_m.prefijo is null then
      CALL fc_prefijosval() RETURNING tpfc_nota_m.prefijo
      IF tpfc_nota_m.prefijo is NULL THEN 
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
         WHERE fc_prefijos.prefijo = tpfc_nota_m.prefijo
        DISPLAY mfc_prefijos.descripcion TO mprefijo 
      END IF 
    ELSE
     INITIALIZE mfc_prefijos.* TO NULL
     SELECT * INTO mfc_prefijos.*
      FROM fc_prefijos
      WHERE fc_prefijos.prefijo = tpfc_nota_m.prefijo
      DISPLAY mfc_prefijos.descripcion TO mprefijo     
    END IF  
    LET cnt=0
    SELECT count(*) INTO cnt FROM fc_prefijos_usu
     WHERE prefijo=tpfc_nota_m.prefijo AND usu_elabora=musuario
    IF cnt IS NULL THEN LET cnt=0 END IF
    IF cnt=0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El usuario No puede Crear Notas Para este Prefijo ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD prefijo
    END IF  

  AFTER FIELD numfac
   IF tpfc_nota_m.numfac IS NULL THEN
     LET mprefijo = tpfc_nota_m.prefijo
     CALL fc_factura_mval2() RETURNING tpfc_nota_m.prefijo, tpfc_nota_m.numfac  
     IF mnumfac IS NULL THEN  
       CALL FGL_WINMESSAGE( "Administrador", " Debe digitar o seleccionar una factura ", "stop")
       NEXT FIELD numfac
     END IF
   END IF 
   DISPLAY tpfc_nota_m.numfac TO numfac
--  IF mfc_factura_m.estado="P" THEN --agregada esta linea para que deje agregar una nota con un mismo numero de factura si esta en estado R,x,D
   INITIALIZE mfc_factura_m.* TO NULL
    SELECT * into mfc_factura_m.* FROM fc_factura_m
    WHERE prefijo = tpfc_nota_m.prefijo
      AND numfac = tpfc_nota_m.numfac
      AND estado = "P"
    IF mfc_factura_m.numfac IS NULL THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE LA FACTURA NO EXISTE O NO ESTA PROCESADA EXITOSAMENTE ", "stop")
     NEXT FIELD numfac
    END IF
    IF mfc_factura_m.codcop IS NULL THEN
     CALL FGL_WINMESSAGE( "Administrador", "LA FACTURA QUE DESEA ANULAR DEBE ESTAR CONTABILIZADA  ", "stop")
     NEXT FIELD numfac
    END IF
    LET cnt=0
    SELECT COUNT(*) INTO cnt FROM fc_nota_m
    WHERE prefijo = tpfc_nota_m.prefijo
      AND numfac = tpfc_nota_m.numfac AND estado="P"
    IF cnt IS NULL THEN LET cnt=0 END if  
    IF cnt<>0 THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE LA FACTURA YA FUE DIGITADA ", "stop")
     NEXT FIELD numfac
    END IF
    ----inicio para dejar registrar nota que esta en estado R,X,D
      LET cnt2=0
    SELECT COUNT(*) INTO cnt2 FROM fc_nota_m
    WHERE prefijo = tpfc_nota_m.prefijo
      AND numfac = tpfc_nota_m.numfac AND (estado="R" OR estado="X" OR estado="D")
    IF cnt2 IS NULL THEN LET cnt2=0 END if  
    IF cnt2<>0 THEN
--fin para dejar registrar nota que esta en estado R,X,D

  
   DISPLAY mfc_factura_m.fecha_factura TO mfccfactu
   LET tpfc_nota_m.nota1=mfc_factura_m.nota1
   DISPLAY BY NAME tpfc_nota_m.nota1 
   INITIALIZE mfc_terceros.* TO NULL
   SELECT * into mfc_terceros.* FROM fc_terceros
   WHERE nit = mfc_factura_m.nit
   DISPLAY mfc_terceros.nit TO mnit
  
  IF mfc_terceros.tipo_persona="1" THEN
   DISPLAY mfc_terceros.razsoc TO mrazsoc
  ELSE
   LET mnombre=NULL
   LET mnombre=mfc_terceros.primer_nombre clipped," ",mfc_terceros.segundo_nombre clipped," ",
               mfc_terceros.primer_apellido clipped," ",mfc_terceros.segundo_apellido clipped," "
   DISPLAY mnombre TO mrazsoc
  END IF
  
  LET mced = NULL
  LET mced="N" 
  IF mfc_terceros.tipo_persona="2" THEN
   LET cnt=0
   SELECT count(*) INTO cnt FROM subsi15
    WHERE cedtra=tpfc_factura_m.nit
    AND estado ="A"
   IF cnt IS NULL THEN LET cnt=0 END IF
   IF cnt=0 THEN
    LET cnt=0
    SELECT count(*) INTO cnt FROM subsi20, subsi21, subsi15
     WHERE subsi21.cedcon=tpfc_factura_m.nit 
     AND subsi21.cedtra = subsi15.cedtra
     AND subsi20.cedcon = subsi21.cedcon
     AND subsi15.estado = "A"
     AND subsi20.estado="A"
    IF cnt IS NULL THEN LET cnt=0 END IF
    IF cnt<>0 THEN
     LET mced="C"
    ELSE
     LET cnt=0
     SELECT count(*) INTO cnt FROM subsi22
     WHERE documento=tpfc_factura_m.nit AND estado="A"
     IF cnt IS NULL THEN LET cnt=0 END IF
     IF cnt<>0 THEN
      LET mced="B" 
     END IF
    END IF
   END IF
  END IF
END IF   
  AFTER FIELD estado
   IF tpfc_nota_m.estado IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL ESTADO DE LA NOTA NO FUE DIGITADO  ", "stop")
    NEXT FIELD estado
   ELSE
    if tpfc_nota_m.estado<>"B" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL ESTADO DE LA NOTA DEBE SER BORRADOR  ", "stop")
     NEXT FIELD estado
    END IF 
   END IF
   
  ON ACTION DETALLE
   IF tpfc_nota_m.tipo IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL TIPO NO FUE DIGITADO   ", "stop")
    NEXT FIELD tipo
   END IF
   IF tpfc_nota_m.documento IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO INTERNO NO FUE DIGITADO   ", "stop")
    NEXT FIELD documento
   END IF
   IF tpfc_nota_m.fecha_elaboracion IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA fecha DE ELABORACION DE LA NOTA NO FUE DIGITADA  ", "stop")
    NEXT FIELD fecha
   END IF
   IF tpfc_nota_m.tipo_nota IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL TIPO DE LA NOTA NO FUE DIGITADO   ", "stop")
    NEXT FIELD tipo_nota
   END IF
   IF tpfc_nota_m.tipo="NC" THEN
    IF tpfc_nota_m.tipo_nota="7" OR tpfc_nota_m.tipo_nota="8" OR tpfc_nota_m.tipo_nota="9" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO CORRESPONDE CON EL TIPO NOTA CREDITO  ", "stop") 
     NEXT FIELD tipo_nota
    END if
   END IF
   IF tpfc_nota_m.tipo="ND" THEN
    IF tpfc_nota_m.tipo_nota="1" OR tpfc_nota_m.tipo_nota="2" OR tpfc_nota_m.tipo_nota="3" OR
       tpfc_nota_m.tipo_nota="4" OR tpfc_nota_m.tipo_nota="5" OR tpfc_nota_m.tipo_nota="6" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO CORRESPONDE CON EL TIPO NOTA DEBITO  ", "stop") 
     NEXT FIELD tipo_nota
    END if
   END IF 
   IF tpfc_nota_m.prefijo IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL PREFIJO NO FUE DIGITADO   ", "stop")
    NEXT FIELD prefijo
   END IF
   IF tpfc_nota_m.numfac IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE FACTURA NO FUE DIGITADO   ", "stop")
    NEXT FIELD numfac
   END IF
   IF tpfc_nota_m.estado IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL ESTADO DE LA NOTA ESTA NULA  ", "stop")
    NEXT FIELD estado
   END IF
   IF tpfc_nota_m.tipo_nota<>"2" AND
      tpfc_nota_m.tipo_nota<>"3" AND
      tpfc_nota_m.tipo_nota<>"4" AND
      tpfc_nota_m.tipo_nota<>"5" THEN
    LET toggle = TRUE
    EXIT INPUT  
   ELSE
    call fc_nota_mgetdetaill()
    call fc_nota_mdetaill()   
    NEXT FIELD estado  
   END if 

  AFTER INPUT
   IF int_flag THEN
    EXIT INPUT
   END IF
   IF tpfc_nota_m.tipo IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL TIPO NO FUE DIGITADO   ", "stop")
    NEXT FIELD tipo
   END IF
   IF tpfc_nota_m.documento IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO INTERNO NO FUE DIGITADO   ", "stop")
    NEXT FIELD documento
   END IF
   IF tpfc_nota_m.fecha_elaboracion IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA fecha DE ELABORACION DE LA FACTURA NO FUE DIGITADA  ", "stop")
    NEXT FIELD fecha
   END IF
   IF tpfc_nota_m.tipo_nota IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL TIPO DE LA NOTA NO FUE DIGITADO   ", "stop")
    NEXT FIELD tipo_nota
   END IF

   IF tpfc_nota_m.tipo="NC" THEN
    IF tpfc_nota_m.tipo_nota="7" OR tpfc_nota_m.tipo_nota="8" OR tpfc_nota_m.tipo_nota="9" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO CORRESPONDE CON EL TIPO NOTA CREDITO  ", "stop") 
     NEXT FIELD tipo_nota
    END if
   END IF
   IF tpfc_nota_m.tipo="ND" THEN
    IF tpfc_nota_m.tipo_nota="1" OR tpfc_nota_m.tipo_nota="2" OR tpfc_nota_m.tipo_nota="3" OR
       tpfc_nota_m.tipo_nota="4" OR tpfc_nota_m.tipo_nota="5" OR tpfc_nota_m.tipo_nota="6" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO CORRESPONDE CON EL TIPO NOTA DEBITO  ", "stop") 
     NEXT FIELD tipo_nota
    END if
   END IF 
   --IF tpfc_nota_m.tipo_nota_c IS NULL THEN
   -- CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA DE LA CAJA NO FUE DIGITADO  ", "stop")
   -- NEXT FIELD tipo_nota_c
   --END IF
   IF tpfc_nota_m.prefijo IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL PREFIJO NO FUE DIGITADO   ", "stop")
    NEXT FIELD prefijo
   END IF
   IF tpfc_nota_m.numfac IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE FACTURA NO FUE DIGITADO   ", "stop")
    NEXT FIELD numfac
   END IF
 END INPUT
 IF int_flag THEN
  CLEAR FORM
  CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "exclamation")
  DISPLAY "" AT 1,10
  INITIALIZE tpfc_nota_m.* TO NULL
  CALL fc_nota_minitta()
  RETURN
 END IF
 call fc_nota_mgetdetaill()
 call fc_nota_mdetaill()
 IF toggle THEN
  LET toggle = FALSE
  CALL SET_COUNT( mregs )
  INPUT ARRAY tafc_nota_m WITHOUT DEFAULTS FROM ofc.*  
  AFTER FIELD codigo
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_nota_m[y].codigo="?" then
    CALL fc_serviciosval2(mfc_factura_m.prefijo) RETURNING tafc_nota_m[y].codigo
    DISPLAY tafc_nota_m[y].codigo to ofc[z].codigo
    INITIALIZE rec_servic.* TO NULL
    select * into rec_servic.* from fc_servicios 
     where codigo=tafc_nota_m[y].codigo
    IF rec_servic.codigo is null THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO NO EXISTE ", "stop")
     INITIALIZE rec_servic.* TO NULL
     initialize tafc_nota_m[y].codigo to null
     next field codigo
    END IF
    IF rec_servic.estado<>"A" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO ESTA INACTIVO ", "stop")
     INITIALIZE rec_servic.* TO NULL
     initialize tafc_nota_m[y].codigo to null
     next field codigo
    END IF
   ELSE 
    IF tafc_nota_m[y].codigo is not null THEN
     INITIALIZE mfc_conta3.* TO NULL 
     select * into mfc_conta3.* from fc_conta3 
      where codigo=tafc_nota_m[y].codigo
      AND prefijo = mfc_factura_m.prefijo
     IF mfc_conta3.codigo IS NULL THEN
       CALL FGL_WINMESSAGE( "Administrador", "EL SERVICIO NO ESTA ASOCIADO DL PREFIJO ", "stop")
       INITIALIZE rec_servic.* TO NULL
       initialize tafc_nota_m[y].codigo to NULL
       next field codigo
     END if 
     INITIALIZE rec_servic.* TO NULL
     select * into rec_servic.* from fc_servicios 
      where codigo=tafc_nota_m[y].codigo
     IF rec_servic.codigo is null THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO NO EXISTE ", "stop")
      INITIALIZE rec_servic.* TO NULL
      initialize tafc_nota_m[y].codigo to null
      next field codigo
     END IF
     IF rec_servic.estado<>"A" THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO ESTA INACTIVO ", "stop")
      INITIALIZE rec_servic.* TO NULL
      initialize tafc_nota_m[y].codigo to null
      next field codigo
     END IF
    END IF
   END IF
   IF tafc_nota_m[y].codigo is not null THEN
    FOR x = 1 TO gmaxarray
     INITIALIZE mfc_conta3.* TO NULL
     DECLARE crf3 CURSOR FOR
     SELECT * FROM fc_conta3 WHERE codigo=tafc_nota_m[y].codigo
     FOREACH crf3 INTO mfc_conta3.*
      CASE
        WHEN mfc_factura_m.medio_pago="10"
         let mcopp=mfc_conta3.codcop_ef
        WHEN mfc_factura_m.medio_pago="48"
         let mcopp=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="49"
         let mcopp=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="42"
         let mcopp=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="20"
         let mcopp=mfc_conta3.codcop_ef
        WHEN mfc_factura_m.medio_pago="45"
         let mcopp=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="7"
         let mcopp=mfc_conta3.codcop_cr
      END CASE
      IF mcon IS NULL THEN
       LET mcon=mfc_conta3.codconta
      END IF
      IF mcop IS NULL THEN
       CASE
        WHEN mfc_factura_m.medio_pago="10"
         let mcop=mfc_conta3.codcop_ef
        WHEN mfc_factura_m.medio_pago="48"
         let mcop=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="49"
         let mcop=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="42"
         let mcop=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="20"
         let mcop=mfc_conta3.codcop_ef
        WHEN mfc_factura_m.medio_pago="45"
         let mcop=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="7"
         let mcop=mfc_conta3.codcop_cr
       END CASE
      END if 
      IF mcon<>mfc_conta3.codconta THEN
       CALL FGL_WINMESSAGE( "Administrador", " LOS SERVICIOS DIGITADOS SON DE DIfcRENTES CONTABILIDADES ", "stop") 
       INITIALIZE tafc_nota_m[y].* TO NULL
       DISPLAY tafc_nota_m[y].* TO ofc[z].*
       NEXT FIELD codigo
       EXIT foreach
      END IF
      IF mcop<>mcopp THEN
       CALL FGL_WINMESSAGE( "Administrador", " LOS SERVICIOS DIGITADOS PERTENECEN A DIfcRENTES TIPOS DE COMPROBANTES", "stop") 
       INITIALIZE tafc_nota_m[y].* TO NULL
       DISPLAY tafc_nota_m[y].* TO ofc[z].*
       NEXT FIELD codigo
       EXIT foreach
      END if  
     END FOREACH
    END FOR
    LET mcodser=NULL
    LET mcodser=tafc_nota_m[y].codigo  
    LET tafc_nota_m[y].descripcion=rec_servic.descripcion
    DISPLAY tafc_nota_m[y].descripcion to ofc[z].descripcion
    {IF rec_servic.maneja_cat="S" THEN 
      IF mfc_terceros.tipo_persona="2" THEN
       IF mced="N" then 
        LET cnt=0
        SELECT count(*) INTO cnt FROM subsi15
         WHERE cedtra=tpfc_factura_m.nit
        IF cnt IS NULL THEN LET cnt=0 END IF
        IF cnt=0 THEN 
           LET tafc_nota_m[y].codcat="D"
        ELSE
         LET cnt=0
         SELECT count(*) INTO cnt FROM subsi15
          WHERE cedtra=mfc_factura_m.nit AND estado="I"
         IF cnt IS NULL THEN LET cnt=0 END IF
         IF cnt<>0 THEN 
          initialize msubsi15.* to NULL
          select * into msubsi15.* from subsi15 where cedtra=mfc_factura_m.nit
          IF msubsi15.carnet="F" THEN
           LET dias=0 
           let dias=mfc_factura_m.fecha_elaboracion-msubsi15.fccest
           if dias>365 THEN
            LET tafc_nota_m[y].codcat="D"
           ELSE
            initialize msubsi12.* to NULL
            select * into msubsi12.* from subsi12
             where today between fccini and fccfin
            let mpersal=NULL
            select max(periodo) into mpersal from subsi10
             where cedtra=mfc_factura_m.nit and suebas>0
            if mpersal is not null THEN
             let msalario=NULL
             select sum(suebas) into msalario from subsi10
             where cedtra=mfc_factura_m.nit and periodo=mpersal
             if msalario is null then let msalario=0 end IF
             let mcansal=msalario/msubsi12.salmin
            ELSE
             initialize msubsi17.* to NULL
             DECLARE dggxs17 CURSOR FOR
             SELECT * FROM subsi17
              where cedtra=msubsi15.cedtra ORDER BY fecha DESC
             FOREACH dggxs17 INTO msubsi17.*
               EXIT FOREACH
             END FOREACH
             let mcansal=msubsi17.salario/msubsi12.salmin
            end IF
            DECLARE drdrxs30 CURSOR FOR
             SELECT * FROM subsi30 ORDER BY codcat ASC
            FOREACH drdrxs30 INTO msubsi30.*
             if mcansal<msubsi30.cansal THEN
              EXIT FOREACH
             end IF
            END FOREACH
            IF msubsi30.codcat="1" THEN
              LET tafc_nota_m[y].codcat="A"
            END IF
            IF msubsi30.codcat="2" THEN
             LET tafc_nota_m[y].codcat="B"
            END IF
            IF msubsi30.codcat="3" THEN
             LET tafc_nota_m[y].codcat="C"
            END IF  
           END if 
          else 
           LET tafc_nota_m[y].codcat="D"
          END if   
         ELSE 
          initialize msubsi15.* to NULL
          select * into msubsi15.* from subsi15 where cedtra=mfc_factura_m.nit
          IF msubsi15.carnet="I" THEN
           LET tafc_nota_m[y].codcat="B"
          ELSE 
           initialize msubsi12.* to NULL
           select * into msubsi12.* from subsi12
            where today between fccini and fccfin
           let mpersal=NULL
           select max(periodo) into mpersal from subsi10
            where cedtra=mfc_factura_m.nit and suebas>0
           if mpersal is not null THEN
            let msalario=NULL
            select sum(suebas) into msalario from subsi10
            where cedtra=mfc_factura_m.nit and periodo=mpersal
            if msalario is null then let msalario=0 end IF
            let mcansal=msalario/msubsi12.salmin
           ELSE
            initialize msubsi17.* to NULL
            DECLARE llggxs17 CURSOR FOR
            SELECT * FROM subsi17
             where cedtra=msubsi15.cedtra ORDER BY fecha DESC
            FOREACH llggxs17 INTO msubsi17.*
              EXIT FOREACH
            END FOREACH
            let mcansal=msubsi17.salario/msubsi12.salmin
           end IF
           DECLARE llnnxs30 CURSOR FOR
           SELECT * FROM subsi30 ORDER BY codcat ASC
           FOREACH llnnxs30 INTO msubsi30.*
            if mcansal<msubsi30.cansal THEN
             EXIT FOREACH
            end IF
           END FOREACH
           IF msubsi30.codcat="1" THEN
            LET tafc_nota_m[y].codcat="A"
           END IF
           IF msubsi30.codcat="2" THEN
            LET tafc_nota_m[y].codcat="B"
           END IF
           IF msubsi30.codcat="3" THEN
            LET tafc_nota_m[y].codcat="C"
           END IF
          END if 
         END IF   
        END IF
       ELSE
        IF mced="B" THEN
         INITIALIZE msubsi22.* TO NULL
         SELECT * INTO msubsi22.* FROM subsi22
         where documento = mfc_factura_m.nit
         let medad=0
         let medad=today-msubsi22.fccnac
         let medad=medad/(365.25)
         LET cnt=0
         SELECT count(*) INTO cnt FROM fc_servicios_excentos
          WHERE codigo=tafc_nota_m[y].codigo
         IF cnt IS NULL THEN LET cnt=0 END IF
         IF cnt=0 THEN
          IF medad>="19" THEN
           CALL FGL_WINMESSAGE( "Administrador", " LA EDAD DE LA PERSONA A CARGO ES MAYOR O IGUAL A 19", "stop") 
           LET tafc_nota_m[y].codcat="D"
          END IF
         ELSE
          IF medad>="24" THEN
           CALL FGL_WINMESSAGE( "Administrador", " LA EDAD DE LA PERSONA A CARGO ES MAYOR O IGUAL A 24", "stop")
           LET tafc_nota_m[y].codcat="D"
          END if 
         END IF
        ELSE   
         initialize msubsi15.* to NULL
         select * into msubsi15.* from subsi15 where cedtra=mfc_factura_m.cedtra
         initialize msubsi12.* to NULL
         select * into msubsi12.* from subsi12
          where today between fccini and fccfin
         let mpersal=NULL
         select max(periodo) into mpersal from subsi10
          where cedtra=mfc_factura_m.cedtra and suebas>0
         if mpersal is not null THEN
           let msalario=NULL
           select sum(suebas) into msalario from subsi10
           where cedtra=mfc_factura_m.cedtra and periodo=mpersal
           if msalario is null then let msalario=0 end IF
             let mcansal=msalario/msubsi12.salmin
           ELSE
             initialize msubsi17.* to NULL
             DECLARE wecedxs17 CURSOR FOR
             SELECT * FROM subsi17
              where cedtra=msubsi15.cedtra ORDER BY fecha DESC
             FOREACH wecedxs17 INTO msubsi17.*
               EXIT FOREACH
             END FOREACH
             let mcansal=msubsi17.salario/msubsi12.salmin
           end IF
           DECLARE rtcedxs30 CURSOR FOR
            SELECT * FROM subsi30 ORDER BY codcat ASC
            FOREACH rtcedxs30 INTO msubsi30.*
            if mcansal<msubsi30.cansal THEN
             EXIT FOREACH
            end IF
           END FOREACH
           IF msubsi30.codcat="1" THEN
             LET tafc_nota_m[y].codcat="A"
           END IF
           IF msubsi30.codcat="2" THEN
            LET tafc_nota_m[y].codcat="B"
           END IF
           IF msubsi30.codcat="3" THEN
            LET tafc_nota_m[y].codcat="C"
           END IF
        END if    
       END if 
     ELSE
        LET cnt=0
        SELECT count(*) INTO cnt FROM subsi02
         WHERE nit=tpfc_factura_m.nit AND estado="A"
        IF cnt IS NULL THEN LET cnt=0 END IF
        IF cnt<>0 THEN 
         LET tafc_nota_m[y].codcat="E"
        ELSE
         LET tafc_nota_m[y].codcat="E"
         --LET tafc_factura_m[y].codcat="D"
        END IF 
     END IF 
     DISPLAY tafc_nota_m[y].codcat to ofc[z].codcat
     LET mcodcat=tafc_nota_m[y].codcat
   END IF
   }
   {IF mfc_factura_m.cuotas>rec_servic.cuotas THEN
     CALL FGL_WINMESSAGE( "Administrador", " LAS CUOTAS A CREDITO SUPERAN EL TOPE ESTABLECIDO EN EL SERVICIO ", "stop")
     INITIALIZE rec_servic.* TO NULL
     initialize tafc_nota_m[y].codigo to null
     next field codigo
    END if}
   END IF
  AFTER FIELD subcodigo
   LET y = arr_curr()
   LET z = scr_line()
   {IF tafc_nota_m[y].subcodigo="?" then
    CALL fc_sub_serviciosval() RETURNING tafc_nota_m[y].subcodigo
    DISPLAY tafc_nota_m[y].subcodigo to ofc[z].subcodigo
    INITIALIZE mfc_sub_servicios.* TO NULL
    select * into mfc_sub_servicios.* from fc_sub_servicios 
     where codigo=tafc_nota_m[y].subcodigo
    IF mfc_sub_servicios.codigo is null THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SUBSERVICIO NO EXISTE ", "stop")
     INITIALIZE mfc_sub_servicios.* TO NULL
     initialize tafc_nota_m[y].subcodigo to null
     next field subcodigo
    END IF
    IF mfc_sub_servicios.estado<>"A" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SUBSERVICIO ESTA INACTIVO ", "stop")
     INITIALIZE mfc_sub_servicios.* TO NULL
     initialize tafc_nota_m[y].subcodigo to null
     next field subcodigo
    END IF
   ELSE 
    IF tafc_nota_m[y].subcodigo is not null then
     INITIALIZE mfc_sub_servicios.* TO NULL
     select * into mfc_sub_servicios.* from fc_sub_servicios 
      where codigo=tafc_nota_m[y].subcodigo
      AND codser= tafc_nota_m[y].codigo
     IF mfc_sub_servicios.codigo is null THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SUBSERVICIO NO EXISTE ", "stop")
      INITIALIZE mfc_sub_servicios.* TO NULL
      initialize tafc_nota_m[y].subcodigo to null
      next field subcodigo
     END IF
     IF mfc_sub_servicios.estado<>"A" THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO ESTA INACTIVO ", "stop")
      INITIALIZE mfc_sub_servicios.* TO NULL
      initialize tafc_nota_m[y].subcodigo to null
      next field subcodigo
     END IF
    END IF
   END IF
   IF tafc_nota_m[y].subcodigo is not null then
    LET tafc_nota_m[y].descri=mfc_sub_servicios.descripcion
    DISPLAY tafc_nota_m[y].descri to ofc[z].descri
   END IF}
   {
  AFTER FIELD cod_bene
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_nota_m[y].cod_bene="?" then
    CALL fc_beneficiosval() RETURNING tafc_nota_m[y].cod_bene
    DISPLAY tafc_nota_m[y].cod_bene to ofc[z].cod_bene
    INITIALIZE mfc_beneficios.* TO NULL
    select * into mfc_beneficios.* from fc_beneficios 
     where codigo=tafc_nota_m[y].cod_bene
    IF mfc_beneficios.codigo is null THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL BENEFICIO NO EXISTE ", "stop")
     INITIALIZE mfc_beneficios.* TO NULL
     initialize tafc_nota_m[y].cod_bene to null
     next field cod_bene
    END IF
    IF mfc_beneficios.estado<>"A" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL BENEFICIO ESTA INACTIVO ", "stop")
     INITIALIZE mfc_beneficios.* TO NULL
     initialize tafc_nota_m[y].cod_bene to null
     next field cod_bene
    END IF
   ELSE 
    IF tafc_nota_m[y].cod_bene is not null THEN
     INITIALIZE mfc_beneficios.* TO NULL
     select * into mfc_beneficios.* from fc_beneficios 
      where codigo=tafc_nota_m[y].cod_bene
     IF mfc_beneficios.codigo is null THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL BENEFICIO NO EXISTE ", "stop")
      INITIALIZE mfc_beneficios.* TO NULL
      initialize tafc_nota_m[y].cod_bene to null
      next field cod_bene
     END IF
     IF mfc_beneficios.estado<>"A" THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL BENEFICIO ESTA INACTIVO ", "stop")
      INITIALIZE mfc_beneficios.* TO NULL
      initialize tafc_nota_m[y].cod_bene to null
      next field cod_bene
     END IF
    END IF
   END IF
   IF tafc_nota_m[y].cod_bene is not null then
    LET tafc_nota_m[y].descrii=mfc_beneficios.descripcion
    DISPLAY tafc_nota_m[y].descrii to ofc[z].descrii
   END IF
   }
   {
  AFTER FIELD codcat
   LET y = arr_curr()
   LET z = scr_line()
   IF rec_servic.maneja_cat="S" THEN
    IF mfc_terceros.tipo_persona="2" THEN
      IF tafc_nota_m[y].codcat="?" THEN
         CALL fc_categoriasval() RETURNING tafc_nota_m[y].codcat
         DISPLAY tafc_nota_m[y].codcat to ofc[z].codcat
         INITIALIZE mfc_categorias.* TO NULL
         select * into mfc_categorias.* from fc_categorias 
          where codigo=tafc_nota_m[y].codcat
         IF mfc_categorias.codigo is null THEN
           CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DE LA CATEGORIA NO EXISTE ", "stop")
           INITIALIZE mfc_categorias.* TO NULL
           initialize tafc_nota_m[y].codcat to NULL
           next field codcat
         END IF
      ELSE 
        IF tafc_nota_m[y].codcat is not null THEN
          INITIALIZE mfc_categorias.* TO NULL
          select * into mfc_categorias.* from fc_categorias 
           where codigo=tafc_nota_m[y].codcat
          IF mfc_categorias.codigo is null THEN
           CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DE LA CATEGORIA NO EXISTE ", "stop")
           INITIALIZE mfc_categorias.* TO NULL
           initialize tafc_nota_m[y].codcat to NULL
           next field codcat
          END IF
        END IF
      END IF
      IF tafc_nota_m[y].codcat<>"D" THEN
        IF mcodcat<>tafc_nota_m[y].codcat THEN
          LET tafc_nota_m[y].codcat=mcodcat
          DISPLAY tafc_nota_m[y].codcat to ofc[z].codcat
        END IF
      END IF 
    END IF
   END IF 
   }
  AFTER FIELD cantidad
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_nota_m[y].cantidad is null or 
      tafc_nota_m[y].cantidad<=0 THEN
      CALL FGL_WINMESSAGE( "Administrador", " LA CANTIDAD NO FUE DIGITADA ", "stop")  
    next field cantidad
   end IF
   
  AFTER FIELD valoruni
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_nota_m[y].valoruni is null THEN
    CALL FGL_WINMESSAGE( "Administrador", " NO HA DIGITADO LA TARIFA PARA ESTE SERVICIO ", "stop")
    INITIALIZE tafc_nota_m[y].* TO NULL
    DISPLAY tafc_nota_m[y].* TO ofc[z].*
    next field valoruni
   END IF 
  AFTER FIELD subsi
   LET y = arr_curr()
   LET z = scr_line()

   
{
  AFTER FIELD valorbene
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_nota_m[y].cod_bene is NOT null THEN
    IF tafc_nota_m[y].valorbene is null THEN
     CALL FGL_WINMESSAGE( "Administrador", " NO HA DIGITADO EL VALOR DEL SUBSIDIO EN ESPECIE ", "stop")
     INITIALIZE tafc_nota_m[y].* TO NULL
     DISPLAY tafc_nota_m[y].* TO ofc[z].*
     next field valorbene
    END IF
   ELSE
    let tafc_nota_m[y].valorbene=0
    DISPLAY tafc_nota_m[y].valorbene to ofc[z].valorbene 
   END if 
   }
   call mvalornota(y)
   DISPLAY tafc_nota_m[y].iva to ofc[z].iva
   DISPLAY tafc_nota_m[y].impc to ofc[z].impc
   DISPLAY tafc_nota_m[y].valor to ofc[z].valor

  ON ACTION DETALLE
   LET ttlrow = ARR_COUNT()
   LET int_flag = FALSE
   LET toggle = TRUE
   EXIT INPUT

 END INPUT
 IF toggle THEN
  GOTO fc_nota_mtog1
 END IF
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 IF int_flag THEN
  CLEAR FORM
  CALL FGL_WINMESSAGE( "Administrador", " LA ADICION FUE CANCELADA", "information")
  INITIALIZE tpfc_nota_m.* TO NULL
  CALL fc_nota_minitta()
  RETURN
 END IF
END IF
MESSAGE  "ADICIONANDO LA NOTA" --AT 1,10 ATTRIBUTE(REVERSE)
BEGIN WORK
LET gerrflag = FALSE
INSERT INTO fc_nota_m ( tipo, documento, fecha_elaboracion, tipo_nota, tipo_nota_c, prefijo, numfac, nota1, estado, usuario_add )
 VALUES ( tpfc_nota_m.tipo, tpfc_nota_m.documento, tpfc_nota_m.fecha_elaboracion, tpfc_nota_m.tipo_nota, tpfc_nota_m.tipo_nota_c, 
  tpfc_nota_m.prefijo,
  tpfc_nota_m.numfac, 
  tpfc_nota_m.nota1, tpfc_nota_m.estado, musuario )
IF status < 0 THEN
 LET gerrflag = TRUE
ELSE
 FOR x = 1 TO gmaxarray
  CALL fc_nota_mrownull( x ) RETURNING rownull
  IF NOT rownull THEN
   INSERT INTO fc_nota_d ( codigo, subcodigo, cantidad, valoruni, iva, impc, subsi, valor, cod_bene, valorbene, tipo, documento, prefijo )
    VALUES ( tafc_nota_m[x].codigo,
             {tafc_nota_m[x].subcodigo, }
             tafc_nota_m[x].cantidad,
             tafc_nota_m[x].valoruni, 
             tafc_nota_m[x].iva, tafc_nota_m[x].impc,  
             tafc_nota_m[x].valor,
             tpfc_nota_m.tipo ,tpfc_nota_m.documento, tpfc_nota_m.prefijo )
   IF status < 0 THEN
    LET gerrflag = TRUE
    EXIT FOR
   END IF
  END IF
 END FOR
END IF
DISPLAY "" AT 1,10
IF NOT gerrflag THEN
 COMMIT WORK
 LET gfc_nota_m.* = tpfc_nota_m.*
 LET cnt = 1
 FOR x = 1 TO gmaxarray
  INITIALIZE gafc_nota_m[x].* TO NULL
  CALL fc_nota_mrownull( x ) RETURNING rownull
  IF NOT rownull THEN
   LET gafc_nota_m[cnt].* = tafc_nota_m[x].*
   LET cnt = cnt + 1
  END IF
 END FOR
 CALL FGL_WINMESSAGE( "Administrador", " LA NOTA DE AJUSTE FUE ADICIONADA", "information")
ELSE
 ROLLBACK WORK
 CALL FGL_WINMESSAGE( "Administrador", " LA ADICION FUE CANCELADA", "information")
END IF
SLEEP 2
END FUNCTION 
FUNCTION fc_nota_mgetcurr( tptipo, tpdocumento )
 DEFINE tpdocumento LIKE fc_nota_m.documento
 DEFINE tptipo LIKE fc_nota_m.tipo
 INITIALIZE gfc_nota_m.* TO NULL
 SELECT fc_nota_m.tipo, fc_nota_m.documento, fc_nota_m.numnota,
        fc_nota_m.fecha_elaboracion, fc_nota_m.fecha_nota, fc_nota_m.hora,
        fc_nota_m.tipo_nota, fc_nota_m.tipo_nota_c, fc_nota_m.prefijo,
        fc_nota_m.numfac, fc_nota_m.cude, fc_nota_m.nota1, fc_nota_m.estado, fc_nota_m.codest,
        fc_nota_m.fccest, fc_nota_m.horaest, fc_nota_m.codcop, fc_nota_m.docu
   INTO gfc_nota_m.*
  FROM fc_nota_m
  WHERE fc_nota_m.tipo = tptipo
    AND fc_nota_m.documento = tpdocumento
  ORDER BY  fc_nota_m.tipo, fc_nota_m.numnota
 CALL fc_nota_mgetdetail()
END FUNCTION
FUNCTION fc_nota_mshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum  INTEGER
 DISPLAY "" AT glastline,1
 IF gfc_nota_m.documento IS NULL THEN
  MESSAGE  "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum,") Borrado" --AT glastline,33
 ELSE
  MESSAGE  "Localizacion : ( Actual ", rownum,"/ Existen ", maxnum, ")" --AT glastline,1
 END IF
 CALL fc_nota_mdetail()
END FUNCTION
FUNCTION fc_nota_mquery( exist )
 DEFINE answer CHAR(1),
  exist, curr, cnt SMALLINT,
  tptipo           LIKE fc_nota_m.tipo,
  tpdocumento      LIKE fc_nota_m.documento,
  where_info,
  query_text         CHAR(400)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 DISPLAY "" AT 1,1
 DISPLAY "" AT 2,1
 MESSAGE  "Estado :  CONSULTA DE NOTAS" --AT 1,10 ATTRIBUTE(REVERSE)
 CLEAR FORM
 CONSTRUCT where_info
  ON tipo, documento, numnota, fecha_elaboracion, fecha_nota, hora, tipo_nota, tipo_nota_c, prefijo, numfac,
    nota1, estado, codest, fccest, horaest  
  FROM tipo, documento, numnota, fecha_elaboracion, fecha_nota, hora,  tipo_nota, tipo_nota_c, prefijo, numfac,
    nota1, estado, codest, fccest, horaest  
 IF int_flag THEN
  --DISPLAY "" AT 1,10
  CALL FGL_WINMESSAGE( "Administrador", " CONSULTA CANCELADA", "stop")
  --DISPLAY "CONSULTA CANCELADA" AT 1,10 ATTRIBUTE(REVERSE)
  SLEEP 2
  DISPLAY "" AT 1,10
  RETURN exist
 END IF
 MESSAGE  "Buscando la nota(s), porfavor espere ..." --AT 2,1
 LET query_text = " SELECT fc_nota_m.tipo,fc_nota_m.documento",
                  " FROM fc_nota_m WHERE ", where_info CLIPPED,
                  " ORDER BY fc_nota_m.tipo,fc_nota_m.documento ASC"
 PREPARE s_sfc_nota_m FROM query_text
 DECLARE c_sfc_nota_m SCROLL CURSOR FOR s_sfc_nota_m
 LET cnt = 0
 FOREACH c_sfc_nota_m INTO tptipo,tpdocumento
  LET cnt = cnt + 1
 END FOREACH
 IF ( cnt > 0 ) THEN
  OPEN c_sfc_nota_m
  FETCH FIRST c_sfc_nota_m INTO tptipo,tpdocumento
  LET curr = 1
  CALL fc_nota_mgetcurr( tptipo,tpdocumento )
  CALL fc_nota_mshowcurr( curr, cnt )
 ELSE
  --DISPLAY "" AT 1,10
  --DISPLAY "" AT 2,1
  CALL FGL_WINMESSAGE( "Administrador", " LA NOTA NO EXISTE", "stop")
  --DISPLAY "LA FACTURA NO EXISTE" AT 1,10 ATTRIBUTE(REVERSE) 
  --sleep 2
  RETURN exist
 END IF
 DISPLAY "" AT 2,1
 MENU ":"
  COMMAND "Primero" "Desplaza al primer nota en consulta"
   HELP 5
   FETCH FIRST c_sfc_nota_m INTO tptipo,tpdocumento
   LET curr = 1
   CALL fc_nota_mgetcurr( tptipo,tpdocumento )
   CALL fc_nota_mshowcurr( curr, cnt )
  COMMAND "Ultimo" "Desplaza al ultimo nota en consulta"
   HELP 6
   FETCH LAST c_sfc_nota_m INTO tptipo,tpdocumento
   LET curr = cnt
   CALL fc_nota_mgetcurr( tptipo,tpdocumento )
   CALL fc_nota_mshowcurr( curr, cnt )
  COMMAND "Inmediato" "Se desplaza al sigiente nota en consulta"
   HELP 7
   IF ( curr = cnt ) THEN
    FETCH FIRST c_sfc_nota_m INTO tptipo,tpdocumento
    LET curr = 1
   ELSE
    FETCH NEXT c_sfc_nota_m INTO tptipo,tpdocumento
    LET curr = curr + 1
   END IF
   CALL fc_nota_mgetcurr( tptipo,tpdocumento )
   CALL fc_nota_mshowcurr( curr, cnt )
  COMMAND "Anterior" "Se desplaza al nota anterior"
   HELP 8
   IF ( curr = 1 ) THEN
    FETCH LAST c_sfc_nota_m INTO tptipo,tpdocumento
    LET curr = cnt
   ELSE
    FETCH PREVIOUS c_sfc_nota_m INTO tptipo,tpdocumento
    LET curr = curr - 1
   END IF
   CALL fc_nota_mgetcurr( tptipo,tpdocumento )
   CALL fc_nota_mshowcurr( curr, cnt )
  COMMAND "Listar" "Lista los servicios de la nota en consulta"
   LET mcodmen="fc33"
   CALL opcion() RETURNING op
   if op="S" THEN 
    IF gfc_nota_m.documento IS NULL THEN
     CONTINUE MENU
    ELSE
     CALL fc_nota_mview()
     CALL fc_nota_mdetail()
    END IF
   END IF 

  COMMAND "Modifica" "Modifica la Nota Para El Envio a La DIAN."
   LET mcodmen="fc31"
   CALL opcion() RETURNING op
   if op="S" THEN 
    IF gfc_nota_m.documento IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_nota_m
     CALL fc_nota_mupdate()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL fc_nota_mgetcurr( tptipo, tpdocumento )
     CALL fc_nota_mshowcurr( curr, cnt )
     OPEN c_sfc_nota_m
    end if 
   end IF

  COMMAND "Borra" "Elimina la Nota en consulta."
   LET mcodmen="fc31"
   CALL opcion() RETURNING op
   if op="S" THEN 
    IF gfc_nota_m.documento IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_nota_m
     CALL fc_nota_mremove()
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     ELSE
      CALL fc_nota_mshowcurr( curr, cnt )
     END if 
     OPEN c_sfc_nota_m
    end if 
   end if 
  
  COMMAND "Aprueba" "Aprueba la Nota Para El Envio a La DIAN."
   LET mcodmen="fc36"
   CALL opcion() RETURNING op
   if op="S" THEN 
    IF gfc_nota_m.documento IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfc_nota_m
     IF gfc_nota_m.estado="B" THEN
      CALL aprueba_nota_2()
     ELSE
      CALL FGL_WINMESSAGE( "Administrador", "EL ESTADO DE LA NOTA NO ES BORRADOR", "stop")
     END if  
     IF gerrflag THEN
      EXIT MENU
     END IF
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
     CALL fc_nota_mshowcurr( curr, cnt )
     OPEN c_sfc_nota_m
    END IF
   end if

  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 10
   IF gfc_nota_m.documento IS NULL THEN
    LET exist = FALSE
   ELSE
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sfc_nota_m
 DISPLAY "" AT glastline,1
 RETURN exist
END FUNCTION
FUNCTION fc_nota_mview()
 DEFINE tp   RECORD
   codigo    LIKE fc_nota_d.codigo,
   descripcion LIKE fc_servicios.descripcion,
   subcodigo    LIKE fc_nota_d.subcodigo,
   descri    LIKE fc_sub_servicios.descripcion,
   descrii    LIKE fc_beneficios.descripcion,
   cantidad  LIKE fc_nota_d.cantidad,
   valoruni  LIKE fc_nota_d.valoruni,
   iva       LIKE fc_nota_d.iva,
   impc      LIKE fc_nota_d.impc,
   valor     LIKE fc_nota_d.valor
  END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 23
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fc_nota_d
  WHERE  fc_nota_d.tipo = gfc_nota_m.tipo
    AND  fc_nota_d.documento = gfc_nota_m.documento
 IF NOT maxnum THEN
  CALL FGL_WINMESSAGE( "Administrador", " NO HAY REGISTROS PARA VISUALIZAR ", "stop")
  RETURN
 END IF
 --DISPLAY "" AT 1,10
 --DISPLAY "" AT 2,1
 MESSAGE  "Trabajando por favor espere ... " --AT 2,1
 DECLARE c_bafc_nota_m SCROLL CURSOR FOR
  SELECT fc_nota_d.codigo, fc_servicios.descripcion, fc_nota_d.subcodigo, fc_sub_servicios.descripcion,
  fc_sub_servicios.descripcion,
   fc_nota_d.cantidad, fc_nota_d.valoruni, 
   fc_nota_d.iva, fc_nota_d.impc, fc_nota_d.subsi, fc_nota_d.valorbene, fc_nota_d.valor
   FROM fc_nota_d, fc_servicios, outer fc_sub_servicios, OUTER fc_beneficios
   WHERE  fc_nota_d.tipo = gfc_nota_m.tipo
     AND  fc_nota_d.documento = gfc_nota_m.documento
     AND fc_nota_d.codigo = fc_servicios.codigo
     AND fc_nota_d.subcodigo = fc_sub_servicios.codigo
   ORDER BY fc_nota_d.codigo ASC
 OPEN c_bafc_nota_m
 --DISPLAY "" AT lastline,1
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fc_nota_mshowview( currrow, prevrow, pagenum ) RETURNING pagenum, prevrow 
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
   CALL fc_nota_mshowview( currrow, prevrow, pagenum )
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
   CALL fc_nota_mshowview( currrow, prevrow, pagenum )
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
   CALL fc_nota_mshowview( currrow, prevrow, pagenum )
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
   CALL fc_nota_mshowview( currrow, prevrow, pagenum )
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
   CALL fc_nota_mshowview( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
   DISPLAY "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" AT lastline,1
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   EXIT MENU
 END MENU
 CLOSE c_bafc_nota_m
 DISPLAY "" AT lastline,1
END FUNCTION
FUNCTION fc_nota_mshowview( currrow, prevrow, pagenum )
 DEFINE tp RECORD
   codigo       LIKE fc_nota_d.codigo,
   descripcion  LIKE fc_servicios.descripcion,
   subcodigo    LIKE fc_nota_d.subcodigo,
   descri       LIKE fc_sub_servicios.descripcion,
   descrii      LIKE fc_beneficios.descripcion,
   cantidad     LIKE fc_nota_d.cantidad,
   valoruni     LIKE fc_nota_d.valoruni,
   iva          LIKE fc_nota_d.iva,
   impc         LIKE fc_nota_d.impc,
   valor        LIKE fc_nota_d.valor
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
  FETCH ABSOLUTE scrfrst c_bafc_nota_m INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO ofc[x].* ATTRIBUTE(REVERSE)
   ELSE
    DISPLAY tp.* TO ofc[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_bafc_nota_m INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO ofc[y].*
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
  FETCH ABSOLUTE prevrow c_bafc_nota_m INTO tp.*
  DISPLAY tp.* TO ofc[scrprev].*
  FETCH ABSOLUTE currrow c_bafc_nota_m INTO tp.*
  DISPLAY tp.* TO ofc[scrcurr].* ATTRIBUTE(REVERSE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION
FUNCTION mvalornota(y)
 define y integer
 LET tafc_nota_m[y].valor=tafc_nota_m[y].cantidad*tafc_nota_m[y].valoruni
END FUNCTION

function aprueba_nota()
define ubicacion char(80)
DEFINE mtime char(8)
DEFINE mnumnota,x INTEGER
define mtotfacc like fc_nota_d.valoruni
define mtotivaa like fc_nota_d.iva
define mtotimpcc like fc_nota_d.impc
DEFINE mdepar char(2)
DEFINE op char(1)
LET cnt=0
SELECT count(*) INTO cnt FROM fc_nota_m
 WHERE fc_nota_m.tipo = gfc_nota_m.tipo
  AND fc_nota_m.documento = gfc_nota_m.documento
  AND fc_nota_m.estado="B"
 IF cnt IS NULL THEN LET cnt=0 END IF
 IF cnt=0 THEN
  MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     comment= " La NOTA No existe o Ya fue Aprobada ",
      image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   return  
 END IF 
 LET cnt=0
 SELECT count(*) INTO cnt FROM fc_prefijos_usuu
  WHERE prefijo=gfc_nota_m.prefijo AND usu_autoriza=musuario
 IF cnt IS NULL THEN LET cnt=0 END IF
 IF cnt=0 THEN
  MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
    comment= " El usuario No puede Aprobar NOTAS Para este Prefijo ",
     image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
    return
 END IF
 LET mnumnota=NULL
 IF gfc_nota_m.tipo="ND" then
  select numnota_d into mnumnota from fc_empresa
 ELSE
  select numnota_c into mnumnota from fc_empresa
 END if 
 IF mnumnota IS NULL THEN LET mnumnota=1 END if
 LET cnt = 1
 LET x = mnumnota
 WHILE cnt <> 0
  SELECT COUNT(*) INTO cnt FROM fc_nota_m
   WHERE fc_nota_m.tipo = gfc_nota_m.tipo
     AND fc_nota_m.numnota = mnumnota
  IF cnt <> 0 THEN
   LET x = x + 1
   IF gfc_nota_m.tipo="ND" THEN
    UPDATE fc_empresa SET numnota_d=numnota_d+1
    LET mnumnota = x
   ELSE
    UPDATE fc_empresa SET numnota_c=numnota_c+1
    LET mnumnota = x
   END if 
  ELSE
   IF gfc_nota_m.tipo="ND" THEN
    UPDATE fc_empresa SET numnota_d=numnota_d+1
   ELSE
    UPDATE fc_empresa SET numnota_c=numnota_c+1
   END if  
   EXIT WHILE
  END IF
 END WHILE
 LET mtime=TIME
 UPDATE fc_nota_m SET numnota=mnumnota,fecha_nota=today,hora=mtime,estado="A",usuario_apru=musuario
 WHERE fc_nota_m.tipo = gfc_nota_m.tipo
  AND fc_nota_m.documento = gfc_nota_m.documento
  AND fc_nota_m.estado="B"
{
  DISPLAY "" AT 2,1
let ubicacion=fgl_getenv("HOME"),"/reportes/",gfc_nota_m.tipo clipped,"-",mnumnota USING "&&&&&" clipped,".txt"
let ubicacion=ubicacion CLIPPED

start report archinota to ubicacion
initialize mfc_nota_m.* to null
select * into mfc_nota_m.* from fc_nota_m 
 WHERE fc_nota_m.tipo = gfc_nota_m.tipo
  AND fc_nota_m.documento = gfc_nota_m.documento
  AND fc_nota_m.numnota = mnumnota
initialize mfc_factura_m.* to null
select * into mfc_factura_m.* from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_nota_m.prefijo
  AND fc_factura_m.numfac = gfc_nota_m.numfac
initialize mfc_prefijos.* to null
select * into mfc_prefijos.* from fc_prefijos 
 WHERE fc_prefijos.prefijo = gfc_nota_m.prefijo
let mtotfacc=0
let mtotivaa=0
let mtotimpcc=0
select sum(fc_nota_d.iva*fc_nota_d.cantidad) into mtotivaa
 from fc_nota_d
 WHERE fc_nota_d.tipo = gfc_nota_m.tipo
  AND fc_nota_d.documento = gfc_nota_m.documento
LET mtotivaa=nomredondea(mtotivaa)
select sum(fc_nota_d.impc*fc_nota_d.cantidad) into mtotimpcc
 from fc_nota_d
 WHERE fc_nota_d.tipo = gfc_nota_m.tipo
  AND fc_nota_d.documento = gfc_nota_m.documento
LET mtotimpcc=nomredondea(mtotimpcc)
select sum(fc_nota_d.valor) into mtotfacc
 from fc_nota_d
WHERE fc_nota_d.tipo = gfc_nota_m.tipo
  AND fc_nota_d.documento = gfc_nota_m.documento
initialize mfc_terceros.* to null
select * into mfc_terceros.* from fc_terceros 
 where nit=mfc_factura_m.nit
initialize mgener09.* to null 
SELECT * into mgener09.* FROM gener09
  WHERE codzon = mfc_terceros.zona
LET mdepar=mfc_terceros.zona[1,2]  
initialize mgener07.* to null 
SELECT * into mgener07.* FROM gener07
  WHERE coddep = mdepar
  
initialize mfc_nota_d.* to null
declare prnotaa cursor for
select * from fc_nota_d
 where tipo=mfc_nota_m.tipo AND documento=mfc_nota_m.documento
  order by codigo
foreach prnotaa into mfc_nota_d.*
 LET op="2"
 output to report archinota(mtotfacc,mtotivaa,mtotimpcc,op)
end FOREACH

--if mtotivaa<>0 OR mtotimpcc<>0 THEN
 initialize mfc_nota_d.* to NULL
 declare pprnotaa cursor FOR
 select * from fc_nota_d
  where tipo=mfc_nota_m.tipo AND documento=mfc_nota_m.documento
   order by codigo
 foreach pprnotaa into mfc_nota_d.*
  LET op="3"
  output to report archinota(mtotfacc,mtotivaa,mtotimpcc,op)
 end FOREACH
--END if
finish report archinota
}
END FUNCTION

REPORT archinota(mtotfacc,mtotivaa,mtotimpcc,op)
DEFINE op char(1)
define mtotfac,mtotfacc like fc_nota_d.valoruni
define mtotiva,mtotivaa like fc_nota_d.iva
define mtotimpc,mtotimpcc like fc_nota_d.impc
DEFINE mediopag,mediorecep char(2)
DEFINE menvio char(25)
DEFINE m_email char(50)
DEFINE mnitfactu char(20)
DEFINE mg02,mg022 RECORD LIKE gener02.*
DEFINE mg09 RECORD LIKE gener09.*
DEFINE mcodimp char(2)
DEFINE mporcen decimal(5,2)
DEFINE msec integer
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
   WHERE usuario = mfc_nota_m.usuario_add
  initialize mg022.* to NULL
  select * into mg022.* from gener02 
   WHERE usuario = mfc_nota_m.usuario_apru
  initialize mg09.* to NULL 
  SELECT * into mg09.* FROM gener09
   WHERE codzon = mfc_prefijos.zona
  let mvalche=mtotfacc
  call letras()
   
  let mtotfac=0
  let mtotiva=0
  let mtotimpc=0
  LET mediopag=null
  CASE
   WHEN mfc_factura_m.medio_pago="10"
    LET mediopag="10"
   WHEN mfc_factura_m.medio_pago="48"
    LET mediopag="48"
   WHEN mfc_factura_m.medio_pago="49"
    LET mediopag="49"
   WHEN mfc_factura_m.medio_pago="42"
    LET mediopag="42"
   WHEN mfc_factura_m.medio_pago="20"
    LET mediopag="20"
   WHEN mfc_factura_m.medio_pago="45"
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
   
   WHEN mfc_terceros.medio_recep="4"
    LET mediorecep="SI"
  END CASE  
  IF mfc_factura_m.forma_pago="1" then
   LET mfc_prefijos.dias_cred=NULL
  END if 
  
 print column 01,"1" clipped,"|",
                 
                 "|",
                 "1" clipped,"|",
                 mfc_nota_m.prefijo clipped,"|",
                 mfc_nota_m.numnota clipped,"|",
                 mfc_nota_m.fecha_nota USING "YYYY-MM-DD" clipped," ",mfc_nota_m.hora clipped,"|",
                 "|",
                 "|",
                 "|",
                 mfc_empresa.moneda clipped,"|",
                 (mtotfacc-(mtotivaa+mtotimpcc)) clipped,"|",
                 (mtotfacc-(mtotivaa+mtotimpcc)) clipped,"|",
                 "0.00","|",
                 "0.00","|", 
                 mtotfacc clipped,"|",
                 mediopag clipped,"|",
                 "|", 
                 "|",
                 mfc_terceros.tipo_persona clipped,"|",
                 mfc_terceros.razsoc clipped,"|",
                 mfc_terceros.primer_nombre clipped,"|",
                 mfc_terceros.segundo_nombre clipped,"|",
                 mfc_terceros.primer_apellido clipped,"|",
                 mfc_terceros.segundo_apellido clipped,"|",
                 mfc_terceros.tipid clipped,"|",
                 mfc_terceros.nit clipped,"|",
                 mfc_terceros.regimen clipped,"|",
                 mediorecep clipped,"|",
                 menvio clipped,"|",
                 m_email clipped,"|",
                 mnitfactu clipped,"|",
                 "|",
                 "|",
                 "|",
                 "|",
                 "|",
                 "|",
                 mfc_terceros.pais clipped,"|",
                 mgener07.detdep CLIPPED,"|",
                 mgener09.detzon CLIPPED,"|",
                 "|",
                 mfc_terceros.direccion clipped,"|",
                 mfc_terceros.telefono clipped,"|", 
                 "|",
                 "|",
                 mfc_factura_m.forma_pago clipped,"|",
                 mfc_prefijos.dias_cred clipped,"|",
                 mfc_factura_m.fecha_vencimiento USING "YYYY-MM-DD" clipped,"|",
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
                 "|",
                 "|",
                 "|",
                 "|",  
                 mg02.nombre clipped,"|",
                 mg022.nombre clipped,"|",
                 mfc_prefijos.num_auto clipped,"|",
                 "No somos Grandes contribuyentes segurm Resol.","|",
                 "Somos autoretenedores de retefuente","|",
                 mfc_prefijos.direccion clipped,"|",
                 mg09.detzon CLIPPED,"|",
                 mfc_prefijos.telefono clipped,"|", 
                 mfc_nota_m.nota1 clipped,"|",
                 mletras1 clipped," ",mletras2 clipped,"|",
                 mtotivaa+mtotimpcc clipped,"|",
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
                 "|",
                 "|",
                 "|",
                 "|",
                 "|", 
                 "|"

 on every ROW
  LET msec=msec+1
  INITIALIZE rec_servic.* TO NULL
  SELECT * INTO rec_servic.* FROM fc_servicios
  where codigo=mfc_nota_d.codigo

  IF op="2" THEN
   print column 01,"2" clipped,"|",
                 mfc_nota_d.codigo clipped,"|",
                 rec_servic.descripcion clipped,"|",
                 "|",  
                 mfc_nota_d.cantidad clipped,"|",
                 "|",  
                 (mfc_nota_d.valoruni-((mfc_nota_d.iva+mfc_nota_d.impc)*mfc_nota_d.cantidad)) clipped,"|",
                 "|",
                 (mfc_nota_d.valor-((mfc_nota_d.iva+mfc_nota_d.impc)*mfc_nota_d.cantidad)) clipped,"|",
                 mfc_nota_d.valor clipped,"|",
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
  IF mfc_nota_d.iva<>"0" THEN
   LET mcodimp="01"
   
   let mtotiva=(mfc_nota_d.iva*mfc_nota_d.cantidad)
   LET mtotivaa=(mfc_nota_d.valor-(mfc_nota_d.iva*mfc_nota_d.cantidad))
  ELSE 
   IF mfc_nota_d.impc<>"0" THEN
    LET mcodimp="03"
    
    let mtotiva=(mfc_nota_d.impc*mfc_nota_d.cantidad)
    LET mtotivaa=(mfc_nota_d.valor-(mfc_nota_d.impc*mfc_nota_d.cantidad))
   END if 
  END if 
  IF op="3" THEN
   print column 01,"3" clipped,"|",
                 mfc_nota_d.codigo clipped,"|",
                 mcodimp,"|",
                 mporcen,"|",
                 mtotiva,"|",
                 mtotivaa,"|" 
  END IF
end REPORT

function gen_comp_factura_n()
define mauxiliar,mauxiliarr like fc_conta1.auxiliariva
define mcodcen,mcodcenn   like fc_conta1.cencosiva
define mnit,mnitt like niif141.nit
define mdetdep like niif141.descripcion
define mdetdepp char(50)
define mcosto,mvalorr,mvalors,mvalorsb like niif141.valor
define cnt,cntp integer
define mc, md, mdif, mvaltot, mvalanti, mivasub decimal(12,0)
define mcodcopp like niif141.codcop
define mdocumentoo like niif141.documento
define mfechaa like niif141.fecha
define mtp char(2)
DEFINE mfc_medio_pago_aux RECORD LIKE fc_medio_pago_aux.*
DEFINE mfc_factura_anti RECORD LIKE fc_factura_anti.*
DEFINE mcon141 RECORD LIKE niif141.*
DEFINE mnumero,xx INTEGER
DEFINE mfccven DATE
DEFINE mdoccru CHAR(15)
DEFINE m_nomnota char(15)
initialize mfc_factura_m.* to null
declare vil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_nota_m.prefijo
  AND fc_factura_m.numfac = gfc_nota_m.numfac
  AND fc_factura_m.estado = "P"
foreach vil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare vil255 cursor for
 select * from fc_factura_d where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  order by codigo
 foreach vil255 into mfc_factura_d.*
  initialize mfc_conta3.* to null
  select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo
  let mcodconta=NULL
  let mcodconta=mfc_conta3.codconta
  let mcodcop=NULL
  LET m_nomnota=NULL
  CASE
   WHEN mcodconta="08"
    CASE
     WHEN gfc_nota_m.tipo="ND"
      let mcodcop=mfc_empresa.codcop_notad_eps
      let m_nomnota="NOTA DEBITO"
     WHEN gfc_nota_m.tipo="NC"
      let mcodcop=mfc_empresa.codcop_notac_eps
      let m_nomnota="NOTA CREDITO"
    END CASE
   WHEN mcodconta="07"
    CASE
     WHEN gfc_nota_m.tipo="ND"
      let mcodcop=mfc_empresa.codcop_notad_epsc
      let m_nomnota="NOTA DEBITO"
     WHEN gfc_nota_m.tipo="NC"
      let mcodcop=mfc_empresa.codcop_notac_epsc
      let m_nomnota="NOTA CREDITO"
    END CASE
   WHEN mcodconta="05"
    CASE
     WHEN gfc_nota_m.tipo="ND"
      let mcodcop=mfc_empresa.codcop_notad_cre
      let m_nomnota="NOTA DEBITO"
     WHEN gfc_nota_m.tipo="NC"
      let mcodcop=mfc_empresa.codcop_notac_cre
      let m_nomnota="NOTA CREDITO"
    END CASE 
   WHEN mcodconta="03"
    CASE
     WHEN gfc_nota_m.tipo="ND"
      let mcodcop=mfc_empresa.codcop_notad_ips
      let m_nomnota="NOTA DEBITO"
     WHEN gfc_nota_m.tipo="NC"
      let mcodcop=mfc_empresa.codcop_notac_ips
      let m_nomnota="NOTA CREDITO"
    END CASE
   OTHERWISE
    CASE
     WHEN gfc_nota_m.tipo="ND"
      let mcodcop=mfc_empresa.codcop_notad
      let m_nomnota="NOTA DEBITO"
     WHEN gfc_nota_m.tipo="NC"
      let mcodcop=mfc_empresa.codcop_notac
      let m_nomnota="NOTA CREDITO"
    END CASE
  END case 
 END FOREACH
END FOREACH 
LET mmarca2=mcodcop
CALL doccopcon141_niif()
let mdocumento=null
LET mdocumento=mdo
let mc=0
let md=0
let l=0
LET mvaltot=0
LET mvalanti=0
LET cnt=1
LET xx=mdocumento
WHILE cnt <> 0
 SELECT COUNT(*) INTO cnt FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
 IF cnt <> 0 THEN
  LET xx = xx + 1
  LET mdocumento = xx USING "&&&&&&&"        
 ELSE
  SELECT COUNT(*) INTO cnt FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
  IF cnt <> 0 THEN
   LET xx = xx + 1
   LET mdocumento = xx USING "&&&&&&&"        
  ELSE
   EXIT WHILE
  END IF
 END IF
END WHILE 
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET gerrflag = FALSE
BEGIN WORK
create temp table con14 
   (
     codconta char(2),
     codcop char(4),
     documento char(7),
     fecha date,
     auxiliar char(12),
     codcen char(4),
     codbod char(2),
     nit char(12),
     descripcion char(30),
     nat char(1),
     valor money(12,2),
     sec SMALLINT
   )

 --Actualiza tipo comprobante y numero
UPDATE fc_nota_m SET codcop=mcodcop,docu=mdocumento
 WHERE fc_nota_m.prefijo = gfc_nota_m.prefijo
  AND fc_nota_m.numfac = gfc_nota_m.numfac
  
LET mvaltot=0
initialize mfc_factura_m.* to null
declare nvvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_nota_m.prefijo
  AND fc_factura_m.numfac = gfc_nota_m.numfac
  AND fc_factura_m.estado = "P"
foreach nvvil244 into mfc_factura_m.*
 LET gfc_nota_m.fecha_nota=NULL
 SELECT fecha_nota INTO gfc_nota_m.fecha_nota FROM fc_nota_m
  WHERE fc_nota_m.prefijo = gfc_nota_m.prefijo
  AND fc_nota_m.numfac = gfc_nota_m.numfac
  AND fc_nota_m.estado ="P" 
 initialize mfc_factura_d.* to null
 declare nvvil255 cursor for
 select prefijo,documento,codigo,subcodigo,"A",
 cantidad,sum(valoruni),sum(iva),sum(impc),sum(subsi),sum(valor),sum(valorbene) 
 from fc_factura_d 
  where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  GROUP BY 1,2,3,4,5,6,12 
  order by codigo
 foreach nvvil255 into mfc_factura_d.*
  initialize rec_servic.* to null
  select * into rec_servic.* from fc_servicios 
   where codigo=mfc_factura_d.codigo 
  {LET mfc_factura_d.iva=nomredondea(mfc_factura_d.iva)
  LET mfc_factura_d.impc=nomredondea(mfc_factura_d.impc)}
  LET mivasub=0
  --LET mivasub=(mfc_factura_d.subsi*mfc_factura_d.cantidad)*(rec_servic.iva/100)
  --LET mfc_factura_d.iva=mfc_factura_d.iva-mivasub
  {LET mfc_factura_d.iva=mfc_factura_d.iva}
  LET mvalanti=0
  SELECT sum(valor) INTO mvalanti FROM fc_factura_anti
   where prefijo=mfc_factura_m.prefijo 
     and documento=mfc_factura_m.documento
     and codigo=mfc_factura_d.codigo
  IF mvalanti IS NULL THEN LET mvalanti=0 END if   
  
  initialize mfc_conta3.* to null
  select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo
  initialize mfc_conta1.* to null
  select * into mfc_conta1.* from fc_conta1 
   where codigo=rec_servic.codigo
  LET mvalors=0
 
  LET mvalorsb=0
   
  if mfc_conta1.auxiliaring is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliaring
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep=rec_servic.descripcion
  -- VALIDACION SI EL SERVICIO ES DE EDUCACION EL BENEF DE PANDEMIA NO SE DESCUENTA 
   -- DEL INGRESO NI DE LA CARTERA
   LET mseredu = 0
   SELECT COUNT(*) INTO mseredu 
    FROM fc_servicios_prefijos
    WHERE codservicio  = 4
    AND prefijo = mfc_factura_m.prefijo
   IF mseredu IS NULL THEN LET mseredu = 0 END IF
   IF mseredu > 0 THEN
     let mvalor=mfc_factura_d.valor- mvalors
   ELSE 
     let mvalor=mfc_factura_d.valor-(mvalors+mvalorsb)
   END IF
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencosing
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    IF mfc_factura_m.prefijo="AGEC" THEN
     IF mvalors>0 THEN
      if mniif233.tercero="S" THEN
       let mnit=mfc_empresa.nit
      ELSE
       let mnit=NULL
      end IF 
      let l=l+1
      INSERT INTO niif141
        ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
           nit, descripcion, nat, valor, sec )
       VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
           mnit, mdetdep, a, mvalors, l )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF
     END IF 
    END IF
   END if 
  end if
  if mfc_conta1.auxiliariva is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliariva
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep="IVA GENERADO"
  { let mfc_factura_d.iva=mfc_factura_d.iva*mfc_factura_d.cantidad
   let mvalor=mfc_factura_d.iva}
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencosiva
   else
    let mcodcen=null
   end IF
   IF mvalor>0 then
   let l=l+1
   INSERT INTO niif141
     ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
        nit, descripcion, nat, valor, sec )
    VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
        mnit, mdetdep, a, mvalor, l )
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
   END if
  end IF
  if mfc_conta1.auxiliarimpc is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarimpc
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep="IMPUESTO CONSUMO"
  { let mfc_factura_d.impc=mfc_factura_d.impc*mfc_factura_d.cantidad
   let mvalor=mfc_factura_d.impc}
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencosimpc
   else
    let mcodcen=null
   end IF
   IF mvalor>0 then
   let l=l+1
   INSERT INTO niif141
     ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
        nit, descripcion, nat, valor, sec )
    VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
        mnit, mdetdep, a, mvalor, l )
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
   END if
  end IF
   
  if mfc_conta1.auxiliarcar is not null THEN
   IF mfc_factura_m.prefijo="AGEC" THEN
   {IF mfc_factura_d.subsi<>0 THEN
    initialize mniif233.* to NULL
    select * into mniif233.* from niif233 
     where auxiliar=mfc_conta1.auxiliarcar
    let mauxiliar=mniif233.auxiliar
    let a="C"
    let mdetdep="SUB TARIFA ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac CLIPPED
    --let mfc_factura_d.subsi=mfc_factura_d.subsi*mfc_factura_d.cantidad
    let mvalor=mfc_factura_d.subsi
    let md=md+mvalor}
    if mniif233.tercero="S" THEN
     let mnit=mfc_empresa.nit
    ELSE
     let mnit=NULL
    end IF
    if mniif233.centros="S" THEN
     let mcodcen=mfc_conta1.cencoscar
    ELSE
     let mcodcen=NULL
    end IF
    IF mvalor>0 THEN
     let l=l+1
     INSERT INTO niif141
     ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
        nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
        mnit, mdetdep, a, mvalor, l )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF
     if mniif233.detalla="C" or mniif233.detalla="P" THEN
      LET mfccven=null
      LET mfccven=mfc_factura_m.fecha_vencimiento+30
      LET mdoccru=NULL
      LET mdoccru=mfc_factura_m.prefijo CLIPPED,"-",mfc_factura_m.numfac
      IF mcodconta="08" THEN
       INSERT INTO niif142
        ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fccven )
       VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, x, mdoccru, mfccven )
       IF status < 0 THEN
        LET gerrflag = TRUE
       END IF
      ELSE
       INSERT INTO niif142
        ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fccven )
       VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, x, mfc_factura_m.numfac, mfccven )
       IF status < 0 THEN
        LET gerrflag = TRUE
       END IF
      END if 
     END IF
    END if
   END IF
   END if
  
  if mfc_factura_m.forma_pago="2" THEN
   --if mfc_factura_m.medio_pago="10" OR mfc_factura_m.medio_pago="20" THEN 
    if mfc_conta1.auxiliarcar is not null THEN
     initialize mniif233.* to NULL
     select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarcar
     let mauxiliar=mniif233.auxiliar
     let a="C"
     let mdetdep="FACTURA A CREDITO ",mfc_factura_m.numfac
     {if mfc_factura_m.cuotas<=0 THEN
      LET mfc_factura_m.cuotas=1
     END IF}
      {IF mseredu > 0 THEN
          let mvalor=(((mfc_factura_d.valor+mfc_factura_d.iva+mfc_factura_d.impc))/mfc_factura_m.cuotas)
       ELSE
          let mvalor=(((mfc_factura_d.valor+mfc_factura_d.iva+mfc_factura_d.impc)/mfc_factura_m.cuotas))
       END IF}
     let md=md+mvalor
     if mniif233.tercero="S" THEN
      let mnit=mfc_factura_m.nit
     ELSE
      let mnit=NULL
     end IF
     if mniif233.centros="S" THEN
      let mcodcen=mfc_conta1.cencoscar
     ELSE
      let mcodcen=NULL
     end IF
     IF mvalor>0 THEN
     { FOR x = 1 TO mfc_factura_m.cuotas
       let l=l+1
       INSERT INTO niif141
       ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
          nit, descripcion, nat, valor, sec )
       VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
          mnit, mdetdep, a, mvalor, l )
       IF status < 0 THEN
        LET gerrflag = TRUE
       END IF
       if mniif233.detalla="C" or mniif233.detalla="P" THEN
        IF x<>1 THEN
         LET mfc_factura_m.fecha_vencimiento=mfc_factura_m.fecha_vencimiento+30
        END IF
        LET mdoccru=NULL
        LET mdoccru=mfc_factura_m.prefijo CLIPPED,"-",mfc_factura_m.numfac
        IF mcodconta="08" THEN
         INSERT INTO niif142
          ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fccven )
         VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, x, mdoccru, mfccven )
         IF status < 0 THEN
          LET gerrflag = TRUE
         END IF
        ELSE
         INSERT INTO niif142
         ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fccven )
         VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, x, mfc_factura_m.numfac, mfc_factura_m.fecha_vencimiento )
         IF status < 0 THEN
          LET gerrflag = TRUE
         END IF
        END if 
       END IF
      END for }
     END if
    end IF
   --END IF
  END IF
  if mfc_factura_m.forma_pago="1" THEN
   if mfc_factura_m.medio_pago="10" OR mfc_factura_m.medio_pago="20" THEN 
    if mfc_conta1.auxiliarcaja is not null THEN
     initialize mniif233.* to NULL
     select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarcaja
     let mauxiliar=mniif233.auxiliar
     let a="C"
     let mdetdep="INGRESO DE CAJA ",mfc_factura_m.numfac
     let mvalor=((mfc_factura_d.valor)-(mvalanti))
     let md=md+mvalor
     if mniif233.tercero="S" THEN
      let mnit=mfc_factura_m.nit
     ELSE
      let mnit=NULL
     end IF
     if mniif233.centros="S" THEN
      let mcodcen=mfc_conta1.cencoscaja
     ELSE
      let mcodcen=NULL
     end IF
     IF mvalor>0 THEN
      --let l=l+1
      INSERT INTO con14
        ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
           nit, descripcion, nat, valor, sec )
       VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
           mnit, mdetdep, a, mvalor, 1 )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF
     END IF
    end IF
   END IF
   if mfc_factura_m.medio_pago="48" OR mfc_factura_m.medio_pago="49" OR mfc_factura_m.medio_pago="42" OR mfc_factura_m.medio_pago="45" THEN 
    if mfc_conta1.auxiliarbanco is not null THEN
     initialize mniif233.* to NULL
     select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarbanco
     let mauxiliar=mniif233.auxiliar
     let a="C"
     let mdetdep="INGRESO BANCO ",mfc_factura_m.numfac
     let mvalor=((mfc_factura_d.valor)-(mvalanti))
     let md=md+mvalor
     if mniif233.tercero="S" THEN
      let mnit=mfc_factura_m.nit
     ELSE
      let mnit=NULL
     end IF
     if mniif233.centros="S" THEN
      let mcodcen=mfc_conta1.cencoscaja
     ELSE
      let mcodcen=NULL
     end IF
     IF mvalor>0 THEN
      --let l=l+1
      INSERT INTO con14
       ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
          nit, descripcion, nat, valor, sec )
      VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
          mnit, mdetdep, a, mvalor, 1 )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF
     END IF
    end IF
   END if
  END IF
 end foreach
end FOREACH
initialize mcon141.* to null
 declare nprt55 cursor for
 select codconta,codcop,documento,fecha,auxiliar,codcen,codbod,nit,descripcion,
  nat,sum(valor),1 from con14
  group by codconta,codcop,documento,fecha,auxiliar,codcen,codbod,nit,descripcion,nat
  order by auxiliar
 foreach nprt55 into mcon141.*
  let l=l+1
  INSERT INTO niif141
   ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
     nit, descripcion, nat, valor, sec )
   VALUES ( mcon141.codconta, mcon141.codcop, mcon141.documento, mcon141.fecha,
     mcon141.auxiliar, mcon141.codcen, mcon141.codbod,  
     mcon141.nit, mcon141.descripcion, mcon141.nat, mcon141.valor, l )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END foreach 

{
IF NOT gerrflag THEN
 if mc<>md then
  if mc<md then
   let mdif=md-mc
   let x=0
   select max(niif141.sec) into x from niif141 where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.nat="C"
   update niif141 set niif141.valor=(niif141.valor+mdif) 
    where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.sec=x
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   let mdif=mc-md
   let x=0
   select max(niif141.sec) into x from niif141 where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.nat="D"
   update niif141 set niif141.valor=(niif141.valor+mdif) 
    where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.sec=x
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
 end if
END IF
}
IF NOT gerrflag THEN
 let mhora=time
  INSERT INTO niif339  -- NUEVA AUDITORIA ADICIONA
  ( codconta, codcop, documento, fecha, hora, tipope, usuario )
  VALUES 
  ( mcodconta, mcodcop, mdocumento, gfc_nota_m.fecha_nota, mhora, "A", musuario)
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 INSERT INTO niif149 ( codconta, codcop, documento, fecha, usuadd, usuact, estado )
      VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, musuario, musuario,"A")
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 LET mdetdepp=null
 let mdetdepp=m_nomnota,"A LA FACTURA - ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac CLIPPED
 INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "1", mdetdepp )
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[1,50]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[51,100]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 


 
IF NOT gerrflag THEN
  set lock mode to wait
  DECLARE ncon11lock CURSOR FOR
  select ultnum from niif148
   WHERE niif148.codcop=mcodcop
   FOR UPDATE
  OPEN ncon11lock
  FETCH ncon11lock
  UPDATE niif148 SET ultnum=ultnum+1 WHERE niif148.codcop=mcodcop
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  CLOSE ncon11lock 
END IF

IF NOT gerrflag THEN
 COMMIT WORK
 --CALL FGL_WINMESSAGE( "Administrador", "EL COMPROBANTE FUE ADICIONADO", "information")
ELSE
 ROLLBACK WORK
 CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "information") 
END if
DROP TABLE con14
END IF 
END FUNCTION

function gen_comp_factura_s_n()
define mauxiliar,mauxiliarr like fc_conta1.auxiliariva
define mcodcen,mcodcenn   like fc_conta1.cencosiva
define mnit,mnitt like niif141.nit
define mdetdep like niif141.descripcion
define mdetdepp char(50)
define mcosto,mvalorr,mvalors,mvalorsb like niif141.valor
define cnt,cntp integer
define mc, md, mdif, mvaltot, mvalanti decimal(12,2)
define mcodcopp like niif141.codcop
define mdocumentoo like niif141.documento
define mfechaa,mfccven like niif141.fecha
define mtp char(2)
DEFINE mfc_medio_pago_aux RECORD LIKE fc_medio_pago_aux.*
DEFINE mfc_factura_anti RECORD LIKE fc_factura_anti.*
DEFINE mcon141 RECORD LIKE niif141.*
DEFINE mnumero,xx INTEGER
DEFINE mvals decimal(12,2)
DEFINE m_nomnota char(15)
LET m_nomnota=null
IF gfc_nota_m.tipo="ND" then
 let m_nomnota="NOTA DEBITO"
ELSE 
 let m_nomnota="NOTA CREDITO"
END if 
LET mcodconta=NULL
LET mcodcop=NULL
LET mvals=0
initialize mfc_factura_m.* to null
declare nsuvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_nota_m.prefijo
  AND fc_factura_m.numfac = gfc_nota_m.numfac
  --AND fc_factura_m.estado = "A"
foreach nsuvil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare nsuvil255 cursor for
 select * from fc_factura_d where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  order by codigo

END FOREACH
IF mvals IS NULL OR mvals = 0 THEN
  RETURN
END IF  
IF mcodconta IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO LA CONTABILIDAD PARA COMPROBANTE DEL SUBSIDIO A LA DEMANDA", "stop")
 return
END IF
IF mcodcop IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO EL TIPO DE COMPROBANTE DEL SUBSIDIO A LA DEMANDA", "stop")
 return
END IF
LET mmarca2=mcodcop
CALL doccopcon141_niif()
let mdocumento=null
LET mdocumento=mdo
let mc=0
let md=0
let l=0
LET mvaltot=0
LET mvalanti=0
LET cnt=1
LET xx=mdocumento
WHILE cnt <> 0
 SELECT COUNT(*) INTO cnt FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
 IF cnt <> 0 THEN
  LET xx = xx + 1
  LET mdocumento = xx USING "&&&&&&&"        
 ELSE
  SELECT COUNT(*) INTO cnt FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
  IF cnt <> 0 THEN
   LET xx = xx + 1
   LET mdocumento = xx USING "&&&&&&&"        
  ELSE
   EXIT WHILE
  END IF
 END IF
END WHILE 
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET gerrflag = FALSE
BEGIN WORK
create temp table con14 
   (
     codconta char(2),
     codcop char(4),
     documento char(7),
     fecha date,
     auxiliar char(12),
     codcen char(4),
     codbod char(2),
     nit char(12),
     descripcion char(30),
     nat char(1),
     valor money(12,2),
     sec smallint
   )
LET mvaltot=0
initialize mfc_factura_m.* to null
declare nsuvvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_nota_m.prefijo
  AND fc_factura_m.numfac = gfc_nota_m.numfac
 -- AND fc_factura_m.estado = "A"
foreach nsuvvil244 into mfc_factura_m.*
 LET gfc_nota_m.fecha_nota=NULL
 SELECT fecha_nota INTO gfc_nota_m.fecha_nota FROM fc_nota_m
  WHERE fc_nota_m.prefijo = gfc_nota_m.prefijo
  AND fc_nota_m.numfac = gfc_nota_m.numfac

 initialize mfc_factura_d.* to null
 declare nsuvvil255 cursor for
 select prefijo,documento,codigo,subcodigo,"A",cantidad,sum(valoruni),sum(iva),sum(impc),sum(subsi),sum(valor),sum(valorbene) from fc_factura_d 
  where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  GROUP BY 1,2,3,4,5,6,12 
  order by codigo
 foreach nsuvvil255 into mfc_factura_d.*
  initialize rec_servic.* to null
  select * into rec_servic.* from fc_servicios 
   where codigo=mfc_factura_d.codigo 
  initialize mfc_conta1.* to null
  select * into mfc_conta1.* from fc_conta1 
   where codigo=rec_servic.codigo
  initialize mfc_conta3.* to NULL
   select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo 
  if mfc_conta1.auxiliarsubsi is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarsubsi
   let mauxiliar=mniif233.auxiliar
   let a="C"
   let mdetdep="REVERSION SUB TARIFA ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "-------"
   LET mdetdep = mdetdep CLIPPED
   let md=md+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencossubsi
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     LET mfccven=null
     LET mfccven=mfc_factura_m.fecha_vencimiento+30
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fccven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, 1, mfc_factura_m.numfac, mfccven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END if 
   END IF
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarcars
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep="REVERSION SUB TARIFA ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac CLIPPED
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencoscars
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     LET mfccven=null
     LET mfccven=mfc_factura_m.fecha_vencimiento+30
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fccven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, 1, mfc_factura_m.numfac, mfccven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END if
   END if
  end IF
 end foreach
end FOREACH

IF NOT gerrflag THEN
 let mhora=time
  INSERT INTO niif339  -- NUEVA AUDITORIA ADICIONA
  ( codconta, codcop, documento, fecha, hora, tipope, usuario )
  VALUES 
  ( mcodconta, mcodcop, mdocumento, gfc_nota_m.fecha_nota, mhora, "A", musuario)
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 INSERT INTO niif149 ( codconta, codcop, documento, fecha, usuadd, usuact, estado )
      VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, musuario, musuario,"A")
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 LET mdetdepp=null
 let mdetdepp=m_nomnota," A LA FACTURA - ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "-------" CLIPPED
 INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "1", mdetdepp )
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[1,50]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[51,100]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "3", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 

IF NOT gerrflag THEN
  set lock mode to wait
  DECLARE nscon11lock CURSOR FOR
  select ultnum from niif148
   WHERE niif148.codcop=mcodcop
   FOR UPDATE
  OPEN nscon11lock
  FETCH nscon11lock
  UPDATE niif148 SET ultnum=ultnum+1 WHERE niif148.codcop=mcodcop
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  CLOSE nscon11lock 
END IF
IF NOT gerrflag THEN
 COMMIT WORK
 CALL FGL_WINMESSAGE( "Administrador", "EL COMPROBANTE DE SUBSIDIO FUE ADICIONADO", "information")
ELSE
 ROLLBACK WORK
 CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "information") 
END if
DROP TABLE con14
END IF 
END FUNCTION


function gen_comp_factura_a_n()
define mauxiliar,mauxiliarr like fc_conta1.auxiliariva
define mcodcen,mcodcenn   like fc_conta1.cencosiva
define mnit,mnitt like niif141.nit
define mdetdep like niif141.descripcion
define mdetdepp char(50)
define mcosto,mvalorr,mvalors like niif141.valor
define cnt,cntp integer
define mc, md, mdif, mvaltot, mvalanti decimal(12,2)
define mcodcopp like niif141.codcop
define mdocumentoo like niif141.documento
define mfechaa like niif141.fecha
define mtp char(2)
DEFINE mfc_medio_pago_aux RECORD LIKE fc_medio_pago_aux.*
DEFINE mfc_factura_anti RECORD LIKE fc_factura_anti.*
DEFINE mcon141 RECORD LIKE niif141.*
DEFINE mnumero,xx INTEGER
DEFINE mvals decimal(12,2)
DEFINE m_nomnota char(15)
LET m_nomnota=null
IF gfc_nota_m.tipo="ND" then
 let m_nomnota="NOTA DEBITO"
ELSE 
 let m_nomnota="NOTA CREDITO"
END if 

LET mcodconta=NULL
LET mcodcop=NULL
LET mvals=0
initialize mfc_factura_m.* to null
declare nasuvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_nota_m.prefijo
  AND fc_factura_m.numfac = gfc_nota_m.numfac
 -- AND fc_factura_m.estado = "A"
foreach nasuvil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare nasuvil255 cursor for
 select * from fc_factura_d where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  order by codigo
 foreach nasuvil255 into mfc_factura_d.*
  LET mvalanti=0
  SELECT sum(valor) INTO mvalanti FROM fc_factura_anti
   where prefijo=mfc_factura_m.prefijo 
     and documento=mfc_factura_m.documento
     and codigo=mfc_factura_d.codigo
  IF mvalanti<>0 THEN
   LET mvals=mvals+mvalanti  
   initialize mfc_conta3.* to NULL
   select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo
   let mcodconta=NULL
   let mcodconta=mfc_conta3.codconta
   let mcodcop=NULL
   let mcodcop=mfc_conta3.codcop_an
  END IF   
 END FOREACH
END FOREACH
IF mvals IS NULL OR mvals = 0 THEN
  RETURN
END IF  
IF mcodconta IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO LA CONTABILIDAD PARA COMPROBANTE DEL ANTICIPO", "stop")
 return
END IF
IF mcodcop IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO EL TIPO DE COMPROBANTE DEL ANTICIPO", "stop")
 return
END IF
LET mmarca2=mcodcop
CALL doccopcon141_niif()
let mdocumento=null
LET mdocumento=mdo
let mc=0
let md=0
let l=0
LET mvaltot=0
LET mvalanti=0
LET cnt=1
LET xx=mdocumento
WHILE cnt <> 0
 SELECT COUNT(*) INTO cnt FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
 IF cnt <> 0 THEN
  LET xx = xx + 1
  LET mdocumento = xx USING "&&&&&&&"        
 ELSE
  SELECT COUNT(*) INTO cnt FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
  IF cnt <> 0 THEN
   LET xx = xx + 1
   LET mdocumento = xx USING "&&&&&&&"        
  ELSE
   EXIT WHILE
  END IF
 END IF
END WHILE 
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF

LET gerrflag = FALSE
BEGIN WORK
create temp table con14 
   (
     codconta char(2),
     codcop char(4),
     documento char(7),
     fecha date,
     auxiliar char(12),
     codcen char(4),
     codbod char(2),
     nit char(12),
     descripcion char(30),
     nat char(1),
     valor money(12,2),
     sec smallint
   )
LET mvaltot=0
initialize mfc_factura_m.* to null
declare nasuvvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_nota_m.prefijo
  AND fc_factura_m.numfac = gfc_nota_m.numfac
 -- AND fc_factura_m.estado = "A"
foreach nasuvvil244 into mfc_factura_m.*
  LET gfc_nota_m.fecha_nota=NULL
 SELECT fecha_nota INTO gfc_nota_m.fecha_nota FROM fc_nota_m
  WHERE fc_nota_m.prefijo = gfc_nota_m.prefijo
  AND fc_nota_m.numfac = gfc_nota_m.numfac

 initialize mfc_factura_d.* to null
 declare nasuvvil255 cursor for
 select prefijo,documento,codigo,subcodigo,"A",cantidad,sum(valoruni),sum(iva),sum(impc),sum(subsi),sum(valor) from fc_factura_d 
  where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  GROUP BY 1,2,3,4,5,6 
  order by codigo
 foreach nasuvvil255 into mfc_factura_d.*
  initialize rec_servic.* to null
  select * into rec_servic.* from fc_servicios 
   where codigo=mfc_factura_d.codigo 
  LET mvalanti=0
  SELECT sum(valor) INTO mvalanti FROM fc_factura_anti
   where prefijo=mfc_factura_m.prefijo 
     and documento=mfc_factura_m.documento
     and codigo=mfc_factura_d.codigo

  initialize mfc_conta1.* to null
  select * into mfc_conta1.* from fc_conta1 
   where codigo=rec_servic.codigo
  

  if mfc_conta1.auxiliarant is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarant
   let mauxiliar=mniif233.auxiliar
   let a="C"
   let mdetdep="REVERSION ANTICIPOS"
   initialize mfc_factura_anti.* to NULL
   declare naanvvil255 cursor FOR
   select * from fc_factura_anti 
    where prefijo=mfc_factura_m.prefijo 
     and documento=mfc_factura_m.documento
     AND codigo=mfc_factura_d.codigo 
    order by codigo
   foreach naanvvil255 into mfc_factura_anti.*
    let mvalor=mfc_factura_anti.valor
    let md=md+mvalor
    if mniif233.tercero="S" THEN
     let mnit=mfc_factura_m.nit
    ELSE
     let mnit=NULL
    end IF
    if mniif233.centros="S" THEN
     let mcodcen=mfc_conta1.cencosant
    ELSE
     let mcodcen=NULL
    end IF
    IF mvalor>0 THEN
     let l=l+1
     INSERT INTO niif141
       ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
          nit, descripcion, nat, valor, sec )
      VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
          mnit, mdetdep, a, mvalor, l )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fccven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_factura_anti.tipcru, mfc_factura_anti.nocts, mfc_factura_anti.doccru)
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END IF
   END foreach 
  end IF 
  if mfc_conta1.auxiliaring is not null THEN
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliaring
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep="REVERSION ANTICIPOS"
   let mvalor=mvalanti
   let mc=mc+mvalor
   if mniif233.tercero="S" THEN
    let mnit=mfc_factura_m.nit
   ELSE
    let mnit=NULL
   end IF
   if mniif233.centros="S" THEN
    let mcodcen=mfc_conta1.cencosing
   ELSE
    let mcodcen=NULL
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
   END IF
  END if
 end foreach
end FOREACH

{
IF NOT gerrflag THEN
 if mc<>md then
  if mc<md then
   let mdif=md-mc
   let x=0
   select max(niif141.sec) into x from niif141 where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.nat="C"
   update niif141 set niif141.valor=(niif141.valor+mdif) 
    where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.sec=x
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  else
   let mdif=mc-md
   let x=0
   select max(niif141.sec) into x from niif141 where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.nat="D"
   update niif141 set niif141.valor=(niif141.valor+mdif) 
    where niif141.codcop=mcodcop
      and niif141.documento=mdocumento and niif141.sec=x
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
  end if
 end if
END IF
}
IF NOT gerrflag THEN
 let mhora=time
  INSERT INTO niif339  -- NUEVA AUDITORIA ADICIONA
  ( codconta, codcop, documento, fecha, hora, tipope, usuario )
  VALUES 
  ( mcodconta, mcodcop, mdocumento, gfc_nota_m.fecha_nota, mhora, "A", musuario)
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 INSERT INTO niif149 ( codconta, codcop, documento, fecha, usuadd, usuact, estado )
      VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, musuario, musuario,"A")
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF

IF NOT gerrflag THEN
 LET mdetdepp=null
 let mdetdepp=m_nomnota," A LA FACTURA - ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac CLIPPED
 INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "1", mdetdepp )
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[1,50]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[51,100]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "3", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 
IF NOT gerrflag THEN
  set lock mode to wait
  DECLARE nascon11lock CURSOR FOR
  select ultnum from niif148
   WHERE niif148.codcop=mcodcop
   FOR UPDATE
  OPEN nascon11lock
  FETCH nascon11lock
  UPDATE niif148 SET ultnum=ultnum+1 WHERE niif148.codcop=mcodcop
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  CLOSE nascon11lock 
END IF
IF NOT gerrflag THEN
 COMMIT WORK
 CALL FGL_WINMESSAGE( "Administrador", "EL COMPROBANTE DE SUBSIDIO FUE ADICIONADO", "information")
ELSE
 ROLLBACK WORK
 CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "information") 
END if
DROP TABLE con14
END IF 
END FUNCTION


function gen_comp_factura_b_n()
DEFINE mmtp char(1)
define mauxiliar,mauxiliarr like fc_conta1.auxiliariva
define mcodcen,mcodcenn   like fc_conta1.cencosiva
define mnit,mnitt like niif141.nit
define mdetdep like niif141.descripcion
define mdetdepp char(50)
define mcosto,mvalorr,mvalors,mvalorsb like niif141.valor
define cnt,cntp integer
define mc, md, mdif, mvaltot, mvalanti decimal(12,2)
define mcodcopp like niif141.codcop
define mdocumentoo like niif141.documento
define mfechaa,mfccven like niif141.fecha
define mtp char(2)
DEFINE mfc_medio_pago_aux RECORD LIKE fc_medio_pago_aux.*
DEFINE mfc_factura_anti RECORD LIKE fc_factura_anti.*
DEFINE mcon141 RECORD LIKE niif141.*
DEFINE mnumero,xx INTEGER
DEFINE mpreedu smallint
DEFINE mvals decimal(12,2)
DEFINE m_nomnota char(15)
LET m_nomnota=null
IF gfc_nota_m.tipo="ND" then
 let m_nomnota="NOTA DEBITO"
ELSE 
 let m_nomnota="NOTA CREDITO"
END if 
LET mcodconta=NULL
LET mcodcop=NULL
LET mvals=0
initialize mfc_factura_m.* to null
declare nbsuvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_nota_m.prefijo
  AND fc_factura_m.documento = gfc_nota_m.documento
  --AND fc_factura_m.estado = "A"
foreach nbsuvil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare nbsuvil255 cursor for
 select * from fc_factura_d where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  order by codigo
 foreach nbsuvil255 into mfc_factura_d.*
  --IF mfc_factura_d.valorbene<>0 THEN
   --LET mvals=mvals+mfc_factura_d.valorbene  
   {initialize mfc_beneficios.* to NULL
   select * into mfc_beneficios.* from fc_beneficios 
    where codigo=mfc_factura_d.cod_bene}
   {initialize mfc_conta3.* to NULL
   select * into mfc_conta3.* from fc_conta3 
    where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo
   let mcodconta=NULL
   let mcodconta=mfc_conta3.codconta
   let mcodcop=NULL
   let mcodcop=mfc_beneficios.codcop2
  END if  }
 END FOREACH
END FOREACH
IF mvals IS NULL OR mvals = 0 THEN
  RETURN
END IF  
IF mcodconta IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO LA CONTABILIDAD PARA COMPROBANTE DEL BENEFICIO", "stop")
 return
END IF
IF mcodcop IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO EL TIPO DE COMPROBANTE DEL BENEFICIO", "stop")
 return
END IF
LET mmarca2=mcodcop
CALL doccopcon141_niif()
let mdocumento=null
LET mdocumento=mdo
let mc=0
let md=0
let l=0
LET mvaltot=0
LET mvalanti=0
LET cnt=1
LET xx=mdocumento
WHILE cnt <> 0
 SELECT COUNT(*) INTO cnt FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
 IF cnt <> 0 THEN
  LET xx = xx + 1
  LET mdocumento = xx USING "&&&&&&&"        
 ELSE
  SELECT COUNT(*) INTO cnt FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
  IF cnt <> 0 THEN
   LET xx = xx + 1
   LET mdocumento = xx USING "&&&&&&&"        
  ELSE
   EXIT WHILE
  END IF
 END IF
END WHILE 
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET gerrflag = FALSE
BEGIN WORK
create temp table con14 
   (
     codconta char(2),
     codcop char(4),
     documento char(7),
     fecha date,
     auxiliar char(12),
     codcen char(4),
     codbod char(2),
     nit char(12),
     descripcion char(30),
     nat char(1),
     valor money(12,2),
     sec smallint
   )
LET mvaltot=0
initialize mfc_factura_m.* to null
declare nbsuvvil244 cursor for
select * from fc_factura_m 
 WHERE fc_factura_m.prefijo = gfc_nota_m.prefijo
  AND fc_factura_m.numfac = gfc_nota_m.numfac
 -- AND fc_factura_m.estado = "A"
foreach nbsuvvil244 into mfc_factura_m.*
 LET gfc_nota_m.fecha_nota=NULL
 SELECT fecha_nota INTO gfc_nota_m.fecha_nota FROM fc_nota_m
  WHERE fc_nota_m.prefijo = gfc_nota_m.prefijo
  AND fc_nota_m.numfac = gfc_nota_m.numfac

 initialize mfc_factura_d.* to null
 declare nbsuvvil255 cursor for
 select prefijo,documento,codigo,subcodigo,"A",cantidad,
 sum(valoruni),sum(iva),sum(impc),sum(subsi),sum(valor),sum(valorbene) 
 from fc_factura_d 
  where prefijo=mfc_factura_m.prefijo 
   and documento=mfc_factura_m.documento
  GROUP BY 1,2,3,4,5,6,12 
  order by codigo
 foreach nbsuvvil255 into mfc_factura_d.*
  initialize rec_servic.* to null
  select * into rec_servic.* from fc_servicios 
   where codigo=mfc_factura_d.codigo
  initialize mfc_conta1.* to null
  select * into mfc_conta1.* from fc_conta1 
   where codigo=rec_servic.codigo
  initialize mfc_conta3.* to NULL
   select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo 
  {initialize mfc_beneficios.* to NULL
   select * into mfc_beneficios.* from fc_beneficios 
   where codigo=mfc_factura_d.cod_bene}
  if mfc_beneficios.auxiliardb is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_beneficios.auxiliardb
   let mauxiliar=mniif233.auxiliar
   let a="C"
   let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,"-SUB BENEFICIOS"
   LET mdetdep = mdetdep CLIPPED
  
   let md=md+mvalor
   if mniif233.tercero="S" THEN
    IF mfc_factura_d.prefijo ="AGEC" THEN
        let mnit="890500675"
     ELSE
        LET mnit= mfc_factura_m.nit
     END if   
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencossubsi
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     IF mfc_factura_m.fecha_vencimiento IS NULL THEN
      LET mfc_factura_m.fecha_vencimiento=gfc_nota_m.fecha_nota
     END if
     LET mfccven=null
     LET mfccven=mfc_factura_m.fecha_vencimiento+30
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fccven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, 1, mfc_factura_m.numfac, mfccven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END if 
   END IF
   -- VALIDAR SI ES UN PREFIJO DE EDUCACION 
   LET mpreedu = 0
    SELECT COUNT(*) INTO mpreedu
      FROM fc_servicios_prefijos
       WHERE prefijo = mfc_factura_m.prefijo 
       AND codservicio = 4   
   IF mpreedu IS NULL THEN LET mpreedu = 0 END IF
   initialize mniif233.* to null
   IF mpreedu > 0 THEN
    select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarcar
     let mauxiliar=mniif233.auxiliar
   ELSE   
     select * into mniif233.* from niif233 
      where auxiliar=mfc_beneficios.auxiliarcr
     let mauxiliar=mniif233.auxiliar
   END IF   
   let a="D"
   let mdetdep=mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&" clipped,"-SUB BENEFICIOS"
  
   let mc=mc+mvalor
   if mniif233.tercero="S" THEN
     IF mpreedu > 0 THEN
       let mnit=mfc_factura_m.nit
     else
       let mnit="890500675" 
     END if  
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencoscars
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     IF mfc_factura_m.fecha_vencimiento IS NULL THEN
      LET mfc_factura_m.fecha_vencimiento=gfc_nota_m.fecha_nota
     END if  
     LET mfccven=null
     LET mfccven=mfc_factura_m.fecha_vencimiento+30
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fccven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, 1, mfc_factura_m.numfac, mfccven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END if
   END if
  end IF
 end foreach
end FOREACH

IF NOT gerrflag THEN
 let mhora=time
  INSERT INTO niif339  -- NUEVA AUDITORIA ADICIONA
  ( codconta, codcop, documento, fecha, hora, tipope, usuario )
  VALUES 
  ( mcodconta, mcodcop, mdocumento, gfc_nota_m.fecha_nota, mhora, "A", musuario)
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 INSERT INTO niif149 ( codconta, codcop, documento, fecha, usuadd, usuact, estado )
      VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, musuario, musuario,"A")
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 LET mdetdepp=null
 let mdetdepp=m_nomnota," A LA FACTURA - ",mfc_factura_m.prefijo clipped,"-",mfc_factura_m.numfac USING "&&&&&&&" CLIPPED
 INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "1", mdetdepp )
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[1,50]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[51,100]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "3", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 
IF NOT gerrflag THEN
  set lock mode to wait
  DECLARE nbscon11lock CURSOR FOR
  select ultnum from niif148
   WHERE niif148.codcop=mcodcop
   FOR UPDATE
  OPEN nbscon11lock
  FETCH nbscon11lock
  UPDATE niif148 SET ultnum=ultnum+1 WHERE niif148.codcop=mcodcop
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  CLOSE nbscon11lock 
END IF
IF NOT gerrflag THEN
 COMMIT WORK
 CALL FGL_WINMESSAGE( "Administrador", "EL COMPROBANTE DE SUBSIDIO FUE ADICIONADO", "information")
ELSE
 ROLLBACK WORK
 CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "information")
END if
DROP TABLE con14
END IF 
END FUNCTION


function imprime_ordenn()
 DEFINE handler om.SaxDocumentHandler
 DEFINE mtipo char(2)
 define ubicacion char(80)
 define mdoo,cnt integer
 define mtotfacc like fc_factura_d.valoruni
 --define mtotivaa like fc_factura_d.iva
 let mtipo=null
 prompt "Digite ND-Nota Debito - NC-Nota Credito =====>> : " for mtipo
 LET mtipo= upshift(mtipo)
 if mtipo is null then 
  return
 end if
 let mdo=null
 let mdoo=null
 prompt "No. Interno =====>> : " for mdoo
 if mdoo is null then 
  return
 end if
 let mdo=mdoo using "&&&&&&&"
 if mdo is null then 
  return
 end if
 if mdo is not null then 
  MESSAGE  "Trabajando por favor espere ... " --AT 2,1
  let cnt=0
  select count(*) into cnt from fc_nota_m 
   where tipo=mtipo AND documento=mdo
  if cnt is null then let cnt=0 end if
  if cnt=0 THEN
   CALL FGL_WINMESSAGE( "Administrador", " LA NOTA DIGITADA NO EXISTE ", "stop")
   return
  end if
 end if
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
let ubicacion=fgl_getenv("HOME"),"/reportes/nota_",mdo
let ubicacion=ubicacion clipped
start report brnota to ubicacion
--LET handler = configureOutputt("PDF","28cm","22cm",17,"1.5cm")
--START REPORT brfactu TO XML HANDLER HANDLER
initialize mfc_nota_m.* to null
select * into mfc_nota_m.* from fc_nota_m 
where tipo=mtipo AND documento=mdo
initialize mfc_factura_m.* to null
select * into mfc_factura_m.* from fc_factura_m 
where prefijo=mfc_nota_m.prefijo AND numfac=mfc_nota_m.numfac
let mtotfacc=0
--let mtotivaa=0
{select sum(fc_nota_d.iva*fc_nota_d.cantidad) into mtotivaa
 from fc_nota_d
where tipo=mtipo AND documento=mdo}
--LET mtotivaa=nomredondea(mtotivaa)
select sum(fc_nota_d.valor) into mtotfacc
 from fc_nota_d
where tipo=mtipo AND documento=mdo
initialize mfc_terceros.* to null
select * into mfc_terceros.* from fc_terceros 
 where nit=mfc_factura_m.nit
initialize mgener09.* to null 
SELECT * into mgener09.* FROM gener09
  WHERE codzon = mfc_terceros.zona
initialize mgener02.* to null 
SELECT * into mgener02.* FROM gener02
  WHERE usuario = mfc_nota_m.usuario_add  
initialize mfc_nota_d.* to null
declare bprfactu cursor for
select * from fc_nota_d
 where tipo=mfc_nota_m.tipo AND documento=mfc_nota_m.documento
  order by codigo,subcodigo
foreach bprfactu into mfc_nota_d.*
 output to report brnota(mtotfacc)
end foreach
finish report brnota
call impsn(ubicacion)
END FUNCTION
REPORT brnota(mtotfacc)
define mx1,mx2 char(1)
define mvaloruni,mtotfac,mtotfacc like fc_factura_d.valoruni
--define mvaloriva,mtotiva,mtotivaa like fc_factura_d.iva
DEFINE mrazsoc char(50)
DEFINE m_nomnota char(15)
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
  --let mtotiva=0
  
 
 end IF
 let mtime=time
 print column 1,"fecha : ",today," + ",mtime,
       column 121,"Pag No. ",pageno using "####"
 skip 1 LINES

 let mp1 = (132-length(mfc_empresa.razsoc clipped))/2
 print column mp1,mfc_empresa.razsoc
 skip 1 LINES
 let m_nomnota=NULL
 IF mfc_nota_m.tipo="NC" THEN
  let m_nomnota="NOTA CREDITO : "
 ELSE
  let m_nomnota="NOTA DEBITO : "
 END IF
 PRINT COLUMN 110,m_nomnota," ",mfc_nota_m.numnota USING "&&&&&&&"
 skip 1 LINES
 
 --print column 01,"Tipo Nota      : ",mfc_nota_m.tipo
 print COLUMN 01,"Numero Interno : ",mfc_nota_m.documento
 --print COLUMN 01,"Numero Nota    : ",mfc_nota_m.numnota USING "&&&&&&&"
 print COLUMN 01,"fecha          : ",mfc_nota_m.fecha_elaboracion 
 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------"      
 --print column 01,"Prefijo        : ",mfc_factura_m.prefijo
 --print COLUMN 01,"Numero Factura : ",mfc_factura_m.numfac
 --print COLUMN 01,"fecha          : ",mfc_factura_m.fecha_elaboracion 
 --print "---------------------------------------------------------------",
 --      "------------------------------------------------------------------------------"
 let mrazsoc=NULL
 IF mfc_terceros.tipo_persona="1" THEN
  let mrazsoc=mfc_terceros.razsoc
 ELSE
  let mrazsoc=mfc_terceros.primer_apellido clipped," ",mfc_terceros.segundo_apellido clipped," ",
              mfc_terceros.primer_nombre clipped," ",mfc_terceros.segundo_nombre clipped
 END if
 skip 1 LINES
 PRINT COLUMN 01,"FACTURA AJUSTADA : ",mfc_factura_m.prefijo,"-",mfc_factura_m.numfac USING "&&&&&&&",
       COLUMN 70,"fecha FACTURA    : ",mfc_factura_m.fecha_factura
 print column 01,"Cliente          : ",mrazsoc,
       column 70,"Nit              : ",mfc_factura_m.nit
 print column 01,"Direccion        : ",mfc_terceros.direccion clipped,
       column 70,"Telefono         : ",mfc_terceros.telefono
 print column 01,"Ciudad           : ",mgener09.detzon 
 print column 01,"Observaciones    : ",mfc_nota_m.nota1
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
 on every ROW
 initialize rec_servic.* to null
 select * into rec_servic.* from fc_servicios
 where codigo=mfc_nota_d.codigo
 
 let mvaloruni=0
 let mvaloruni=mfc_nota_d.valoruni
 let mtotfac=mtotfac+(mvaloruni*mfc_nota_d.cantidad)
 --let mtotiva=mtotiva+(mfc_nota_d.iva*mfc_nota_d.cantidad)
 initialize mfc_sub_servicios.* to null
 select * into mfc_sub_servicios.* from fc_sub_servicios
 where codigo=mfc_nota_d.subcodigo
 print  column 01,mfc_nota_d.codigo,
        column 7,mfc_nota_d.cantidad using "&&&&",
        column 20,rec_servic.descripcion clipped,"-",mfc_sub_servicios.descripcion clipped,
        column 80,mvaloruni using "###,###,##&.&&",
        column 100,mfc_nota_d.subsi*mfc_nota_d.cantidad using "###,###,##&.&&",
        column 120,(mvaloruni-(mfc_nota_d.subsi+mfc_nota_d.valorbene))*mfc_nota_d.cantidad using "###,###,##&.&&"
 --page TRAILER
 on last ROW
 INITIALIZE mgen02.* TO NULL
 select * into mgen02.* from gener02 where usuario=mfc_nota_m.usuario_add
 print "---------------------------------------------------------------",
       "------------------------------------------------------------------------------"
 skip 1 lines
 --LET mtotiva=nomredondea(mtotiva)
 LET mtotfac=nomredondea(mtotfac)
 {SELECT sum(valor) INTO mvalant
  FROM fc_factura_anti
 WHERE prefijo = mfc_factura_m.prefijo
 AND documento = mfc_factura_m.documento
 IF mvalant IS NULL THEN
  LET mvalant = 0
 END IF  }
 let mvalche=nomredondea((mtotfac))
 call letras()
 print  column 01,mletras1 clipped," ",mletras2 clipped 
 print  column 100,"SUBTOTAL",
        COLUMN 120, mtotfac using "###,###,##&.&&"
 PRINT  COLUMN 100,"SUBSIDIO OTORGADO",
        column 120
 PRINT  COLUMN 100,"BENEFICIO OTORGADO",
        column 120   
 print  COLUMN 100,"ANTICIPOS"
            
 print  COLUMN 100,"IVA",
        column 120,"" using "###,###,##&.&&"
 print  COLUMN 100,"TOTAL A PAGAR", 
        column 120,nomredondea((mtotfac)) using "###,###,##&.&&"
 SKIP 2 LINES
 PRINT COLUMN 1, "________________________________________________________",
       COLUMN 80, "________________________________________________________"
 PRINT column 1, "      Elaboró : ", mgen02.nombre, 
       column 80, "                   Recibido" 

 --on last row
 --skip to top of page
end report

FUNCTION fc_nota_mupdate()
 DEFINE mnombre char(50)
 DEFINE mnumcod integer
 define mdetalle like villa_tip_conv.detalle 
 DEFINE z, cnt, x, v, y, t, rownull, currow,
        scrrow, toggle, ttlrow, lin, lin2 SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACION DE NOTAS" 
 INITIALIZE tpfc_nota_m.* TO NULL
 CALL fc_nota_minitta()
 LET tpfc_nota_m.* = gfc_nota_m.*
 LET ttlrow = 1
 FOR x = 1 TO gmaxarray
  LET tafc_nota_m[x].* = gafc_nota_m[x].*
  CALL fc_nota_mrownull( x ) RETURNING rownull
  IF NOT rownull THEN
   INITIALIZE tafc_nota_m[x].* TO NULL
   LET tafc_nota_m[ttlrow].* = gafc_nota_m[x].*
   LET ttlrow = ttlrow + 1
  ELSE
   EXIT FOR
  END IF
 END FOR
 LET ttlrow = ttlrow - 1
 LABEL fc_nota_mtog1:
 LET toggle = FALSE
 IF int_flag THEN 
    LET int_flag = FALSE
 END IF
 IF tpfc_nota_m.estado<>"B" THEN
  CALL FGL_WINMESSAGE( "Administrador", " LA NOTA NO SE PUEDE MODIFICAR POR QUE NO ESTA EN ESTADO BORRADOR","information") 
  RETURN
 END IF
 LET cnt=0
 SELECT count(*) INTO cnt FROM fc_prefijos_usu
  WHERE prefijo=tpfc_nota_m.prefijo AND usu_elabora=musuario
 IF cnt IS NULL THEN LET cnt=0 END IF
 IF cnt=0 THEN
  CALL FGL_WINMESSAGE( "Administrador", " EL USUARIO NO ESTA AUTORIZADO PARA MODIFICAR NOTAS DE ESTE PREFIJO","information") 
  RETURN
 END IF  
LABEL entrada_nota:
INPUT BY NAME tpfc_nota_m.fecha_elaboracion THRU tpfc_nota_m.estado WITHOUT DEFAULTS

  AFTER FIELD fecha_elaboracion
   IF tpfc_nota_m.fecha_elaboracion IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA FECHA DE ELABORACION NO FUE DIGITADO ", "stop")
    NEXT FIELD fecha_elaboracion
   ELSE 
    IF tpfc_nota_m.fecha_elaboracion<TODAY THEN
     CALL FGL_WINMESSAGE( "Administrador", " LA fecha DE ELABORACION NO PUEDE SER DIfcRENTE A HOY ", "stop")
     NEXT FIELD fecha_elaboracion
    END IF
    IF tpfc_nota_m.fecha_elaboracion>TODAY THEN
     CALL FGL_WINMESSAGE( "Administrador", " LA fecha DE ELABORACION NO PUEDE SER DIfcRENTE A HOY ", "stop")
     NEXT FIELD fecha_elaboracion
    END IF 
   END IF
   NEXT FIELD tipo_nota

  AFTER FIELD tipo_nota
   IF tpfc_nota_m.tipo_nota IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO FUE DIGITADO  ", "stop") 
    NEXT FIELD tipo_nota
   END IF 
   IF tpfc_nota_m.tipo="NC" THEN
    IF tpfc_nota_m.tipo_nota="7" OR tpfc_nota_m.tipo_nota="8" OR tpfc_nota_m.tipo_nota="9" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO CORRESPONDE CON EL TIPO NOTA CREDITO  ", "stop") 
     NEXT FIELD tipo_nota
    END if
   END IF
   IF tpfc_nota_m.tipo="ND" THEN
    IF tpfc_nota_m.tipo_nota="1" OR tpfc_nota_m.tipo_nota="2" OR tpfc_nota_m.tipo_nota="3" OR
       tpfc_nota_m.tipo_nota="4" OR tpfc_nota_m.tipo_nota="5" OR tpfc_nota_m.tipo_nota="6" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO CORRESPONDE CON EL TIPO NOTA DEBITO  ", "stop") 
     NEXT FIELD tipo_nota
    END if
   END IF 
 
  AFTER FIELD tipo_nota_c
   IF tpfc_nota_m.tipo_nota="6" THEN
    IF tpfc_nota_m.tipo_nota_c IS NULL THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA DE LA CAJA NO FUE DIGITADO  ", "stop") 
      NEXT FIELD tipo_nota_c
    END IF
   ELSE
     NEXT FIELD prefijo
   END if 
   
 BEFORE FIELD prefijo
   LET cnt=0
   SELECT count(*) INTO cnt FROM fc_prefijos_usu
    WHERE usu_elabora=musuario
   IF cnt IS NULL THEN LET cnt=0 END IF
   IF cnt>1 THEN
    CALL fc_prefijosval() RETURNING tpfc_nota_m.prefijo
    IF tpfc_nota_m.prefijo is NULL THEN
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
       WHERE fc_prefijos.prefijo = tpfc_nota_m.prefijo
      DISPLAY mfc_prefijos.descripcion TO mprefijo 
    END IF
   ELSE
    IF cnt<=1 THEN 
     INITIALIZE mfc_prefijos_usu.* TO NULL
     SELECT * INTO mfc_prefijos_usu.* FROM fc_prefijos_usu
      WHERE usu_elabora=musuario
     LET tpfc_nota_m.prefijo = mfc_prefijos_usu.prefijo 
     DISPLAY BY NAME tpfc_nota_m.prefijo
    END if 
   END if 
  AFTER FIELD prefijo
    IF tpfc_nota_m.prefijo is null then
      CALL fc_prefijosval() RETURNING tpfc_nota_m.prefijo
      IF tpfc_nota_m.prefijo is NULL THEN 
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
         WHERE fc_prefijos.prefijo = tpfc_nota_m.prefijo
        DISPLAY mfc_prefijos.descripcion TO mprefijo 
      END IF 
    ELSE
     INITIALIZE mfc_prefijos.* TO NULL
     SELECT * INTO mfc_prefijos.*
      FROM fc_prefijos
      WHERE fc_prefijos.prefijo = tpfc_nota_m.prefijo
      DISPLAY mfc_prefijos.descripcion TO mprefijo     
    END IF  
    LET cnt=0
    SELECT count(*) INTO cnt FROM fc_prefijos_usu
     WHERE prefijo=tpfc_nota_m.prefijo AND usu_elabora=musuario
    IF cnt IS NULL THEN LET cnt=0 END IF
    IF cnt=0 THEN
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
       comment= " El usuario No puede Crear Notas Para este Prefijo ",
        image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
       END MENU
       NEXT FIELD prefijo
    END IF  

  AFTER FIELD numfac
   IF tpfc_nota_m.numfac IS NULL THEN
     LET mprefijo = tpfc_nota_m.prefijo
     CALL fc_factura_mval2() RETURNING tpfc_nota_m.prefijo, tpfc_nota_m.numfac  
     IF mnumfac IS NULL THEN  
       CALL FGL_WINMESSAGE( "Administrador", " Debe digitar o seleccionar una factura ", "stop")
       NEXT FIELD numfac
     END IF
   END IF 
   DISPLAY tpfc_nota_m.numfac TO numfac 
   INITIALIZE mfc_factura_m.* TO NULL
    SELECT * into mfc_factura_m.* FROM fc_factura_m
    WHERE prefijo = tpfc_nota_m.prefijo
      AND numfac = tpfc_nota_m.numfac
      AND estado ="P"
    IF mfc_factura_m.numfac IS NULL THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE LA FACTURA NO EXISTE O NO ESTA APROBADA ", "stop")
     NEXT FIELD numfac
    END IF
    IF mfc_factura_m.codcop IS NULL THEN
     CALL FGL_WINMESSAGE( "Administrador", "LA FACTURA QUE DESEA ANULAR DEBE ESTAR CONTABILIZADA  ", "stop")
     NEXT FIELD numfac
    END IF
    LET cnt=0
    SELECT COUNT(*) INTO cnt FROM fc_nota_m
    WHERE prefijo = tpfc_nota_m.prefijo
      AND numfac = tpfc_nota_m.numfac
    IF cnt IS NULL THEN LET cnt=0 END if  
    IF cnt<>0 THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE LA FACTURA YA FUE DIGITADA ", "stop")
     NEXT FIELD numfac
    END IF
   DISPLAY mfc_factura_m.fecha_factura TO mfccfactu
   LET tpfc_nota_m.nota1=mfc_factura_m.nota1
   DISPLAY BY NAME tpfc_nota_m.nota1 
   INITIALIZE mfc_terceros.* TO NULL
   SELECT * into mfc_terceros.* FROM fc_terceros
   WHERE nit = mfc_factura_m.nit
   DISPLAY mfc_terceros.nit TO mnit
  
  IF mfc_terceros.tipo_persona="1" THEN
   DISPLAY mfc_terceros.razsoc TO mrazsoc
  ELSE
   LET mnombre=NULL
   LET mnombre=mfc_terceros.primer_nombre clipped," ",mfc_terceros.segundo_nombre clipped," ",
               mfc_terceros.primer_apellido clipped," ",mfc_terceros.segundo_apellido clipped," "
   DISPLAY mnombre TO mrazsoc
  END IF
  
  LET mced = NULL
  LET mced="N" 
  IF mfc_terceros.tipo_persona="2" THEN
   LET cnt=0
   SELECT count(*) INTO cnt FROM subsi15
    WHERE cedtra=tpfc_factura_m.nit
    AND estado ="A"
   IF cnt IS NULL THEN LET cnt=0 END IF
   IF cnt=0 THEN
    LET cnt=0
    SELECT count(*) INTO cnt FROM subsi20, subsi21, subsi15
     WHERE subsi21.cedcon=tpfc_factura_m.nit 
     AND subsi21.cedtra = subsi15.cedtra
     AND subsi20.cedcon = subsi21.cedcon
     AND subsi15.estado = "A"
     AND subsi20.estado="A"
    IF cnt IS NULL THEN LET cnt=0 END IF
    IF cnt<>0 THEN
     LET mced="C"
    ELSE
     LET cnt=0
     SELECT count(*) INTO cnt FROM subsi22
     WHERE documento=tpfc_factura_m.nit AND estado="A"
     IF cnt IS NULL THEN LET cnt=0 END IF
     IF cnt<>0 THEN
      LET mced="B" 
     END IF
    END IF
   END IF
  END IF  
  AFTER FIELD estado
   IF tpfc_nota_m.estado IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL ESTADO DE LA NOTA NO FUE DIGITADO  ", "stop")
    NEXT FIELD estado
   ELSE
    if tpfc_nota_m.estado<>"B" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL ESTADO DE LA NOTA DEBE SER BORRADOR  ", "stop")
     NEXT FIELD estado
    END IF 
   END IF
   
  ON ACTION DETALLE
   IF tpfc_nota_m.tipo IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL TIPO NO FUE DIGITADO   ", "stop")
    NEXT FIELD tipo
   END IF
   IF tpfc_nota_m.documento IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO INTERNO NO FUE DIGITADO   ", "stop")
    NEXT FIELD documento
   END IF
   IF tpfc_nota_m.fecha_elaboracion IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA fecha DE ELABORACION DE LA NOTA NO FUE DIGITADA  ", "stop")
    NEXT FIELD fecha
   END IF
   IF tpfc_nota_m.tipo_nota IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL TIPO DE LA NOTA NO FUE DIGITADO   ", "stop")
    NEXT FIELD tipo_nota
   END IF
   IF tpfc_nota_m.tipo="NC" THEN
    IF tpfc_nota_m.tipo_nota="7" OR tpfc_nota_m.tipo_nota="8" OR tpfc_nota_m.tipo_nota="9" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO CORRESPONDE CON EL TIPO NOTA CREDITO  ", "stop") 
     NEXT FIELD tipo_nota
    END if
   END IF
   IF tpfc_nota_m.tipo="ND" THEN
    IF tpfc_nota_m.tipo_nota="1" OR tpfc_nota_m.tipo_nota="2" OR tpfc_nota_m.tipo_nota="3" OR
       tpfc_nota_m.tipo_nota="4" OR tpfc_nota_m.tipo_nota="5" OR tpfc_nota_m.tipo_nota="6" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO CORRESPONDE CON EL TIPO NOTA DEBITO  ", "stop") 
     NEXT FIELD tipo_nota
    END if
   END IF 
   IF tpfc_nota_m.prefijo IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL PREFIJO NO FUE DIGITADO   ", "stop")
    NEXT FIELD prefijo
   END IF
   IF tpfc_nota_m.numfac IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE FACTURA NO FUE DIGITADO   ", "stop")
    NEXT FIELD numfac
   END IF
   IF tpfc_nota_m.estado IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL ESTADO DE LA NOTA ESTA NULA  ", "stop")
    NEXT FIELD estado
   END IF
   IF tpfc_nota_m.tipo_nota<>"2" AND
      tpfc_nota_m.tipo_nota<>"3" AND
      tpfc_nota_m.tipo_nota<>"4" AND
      tpfc_nota_m.tipo_nota<>"5" THEN
    LET toggle = TRUE
    EXIT INPUT  
   ELSE
    call fc_nota_mgetdetaill()
    call fc_nota_mdetaill()   
    NEXT FIELD estado  
   END if 

  AFTER INPUT
   IF int_flag THEN
    EXIT INPUT
   END IF
   IF tpfc_nota_m.tipo IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL TIPO NO FUE DIGITADO   ", "stop")
    NEXT FIELD tipo
   END IF
   IF tpfc_nota_m.documento IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO INTERNO NO FUE DIGITADO   ", "stop")
    NEXT FIELD documento
   END IF
   IF tpfc_nota_m.fecha_elaboracion IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " LA fecha DE ELABORACION DE LA FACTURA NO FUE DIGITADA  ", "stop")
    NEXT FIELD fecha
   END IF
   IF tpfc_nota_m.tipo_nota IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL TIPO DE LA NOTA NO FUE DIGITADO   ", "stop")
    NEXT FIELD tipo_nota
   END IF

   IF tpfc_nota_m.tipo="NC" THEN
    IF tpfc_nota_m.tipo_nota="7" OR tpfc_nota_m.tipo_nota="8" OR tpfc_nota_m.tipo_nota="9" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO CORRESPONDE CON EL TIPO NOTA CREDITO  ", "stop") 
     NEXT FIELD tipo_nota
    END if
   END IF
   IF tpfc_nota_m.tipo="ND" THEN
    IF tpfc_nota_m.tipo_nota="1" OR tpfc_nota_m.tipo_nota="2" OR tpfc_nota_m.tipo_nota="3" OR
       tpfc_nota_m.tipo_nota="4" OR tpfc_nota_m.tipo_nota="5" OR tpfc_nota_m.tipo_nota="6" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA NO CORRESPONDE CON EL TIPO NOTA DEBITO  ", "stop") 
     NEXT FIELD tipo_nota
    END if
   END IF 
   --IF tpfc_nota_m.tipo_nota_c IS NULL THEN
   -- CALL FGL_WINMESSAGE( "Administrador", " EL MOTIVO DE LA NOTA DE LA CAJA NO FUE DIGITADO  ", "stop")
   -- NEXT FIELD tipo_nota_c
   --END IF
   IF tpfc_nota_m.prefijo IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL PREFIJO NO FUE DIGITADO   ", "stop")
    NEXT FIELD prefijo
   END IF
   IF tpfc_nota_m.numfac IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO DE FACTURA NO FUE DIGITADO   ", "stop")
    NEXT FIELD numfac
   END IF
 END INPUT
 IF int_flag THEN
  CLEAR FORM
  CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "exclamation")
  DISPLAY "" AT 1,10
  INITIALIZE tpfc_nota_m.* TO NULL
  CALL fc_nota_minitta()
  RETURN
 END IF
 call fc_nota_mgetdetaill()
 call fc_nota_mdetaill()
 IF toggle THEN
  LET toggle = FALSE
  CALL SET_COUNT( mregs )
  INPUT ARRAY tafc_nota_m WITHOUT DEFAULTS FROM ofc.*  
  AFTER FIELD codigo
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_nota_m[y].codigo="?" then
    CALL fc_serviciosval2(mfc_factura_m.prefijo) RETURNING tafc_nota_m[y].codigo
    DISPLAY tafc_nota_m[y].codigo to ofc[z].codigo
    INITIALIZE rec_servic.* TO NULL
    select * into rec_servic.* from fc_servicios 
     where codigo=tafc_nota_m[y].codigo
    IF rec_servic.codigo is null THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO NO EXISTE ", "stop")
     INITIALIZE rec_servic.* TO NULL
     initialize tafc_nota_m[y].codigo to null
     next field codigo
    END IF
    IF rec_servic.estado<>"A" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO ESTA INACTIVO ", "stop")
     INITIALIZE rec_servic.* TO NULL
     initialize tafc_nota_m[y].codigo to null
     next field codigo
    END IF
   ELSE 
    IF tafc_nota_m[y].codigo is not null THEN
     INITIALIZE mfc_conta3.* TO NULL 
     select * into mfc_conta3.* from fc_conta3 
      where codigo=tafc_nota_m[y].codigo
      AND prefijo = mfc_factura_m.prefijo
     IF mfc_conta3.codigo IS NULL THEN
       CALL FGL_WINMESSAGE( "Administrador", "EL SERVICIO NO ESTA ASOCIADO DL PREFIJO ", "stop")
       INITIALIZE rec_servic.* TO NULL
       initialize tafc_nota_m[y].codigo to NULL
       next field codigo
     END if 
     INITIALIZE rec_servic.* TO NULL
     select * into rec_servic.* from fc_servicios 
      where codigo=tafc_nota_m[y].codigo
     IF rec_servic.codigo is null THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO NO EXISTE ", "stop")
      INITIALIZE rec_servic.* TO NULL
      initialize tafc_nota_m[y].codigo to null
      next field codigo
     END IF
     IF rec_servic.estado<>"A" THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO ESTA INACTIVO ", "stop")
      INITIALIZE rec_servic.* TO NULL
      initialize tafc_nota_m[y].codigo to null
      next field codigo
     END IF
    END IF
   END IF
   IF tafc_nota_m[y].codigo is not null THEN
    FOR x = 1 TO gmaxarray
     INITIALIZE mfc_conta3.* TO NULL
     DECLARE upcrf3 CURSOR FOR
     SELECT * FROM fc_conta3 WHERE codigo=tafc_nota_m[y].codigo
     FOREACH upcrf3 INTO mfc_conta3.*
      CASE
        WHEN mfc_factura_m.medio_pago="10"
         let mcopp=mfc_conta3.codcop_ef
        WHEN mfc_factura_m.medio_pago="48"
         let mcopp=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="49"
         let mcopp=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="42"
         let mcopp=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="20"
         let mcopp=mfc_conta3.codcop_ef
        WHEN mfc_factura_m.medio_pago="45"
         let mcopp=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="7"
         let mcopp=mfc_conta3.codcop_cr
      END CASE
      IF mcon IS NULL THEN
       LET mcon=mfc_conta3.codconta
      END IF
      IF mcop IS NULL THEN
       CASE
        WHEN mfc_factura_m.medio_pago="10"
         let mcop=mfc_conta3.codcop_ef
        WHEN mfc_factura_m.medio_pago="48"
         let mcop=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="49"
         let mcop=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="42"
         let mcop=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="20"
         let mcop=mfc_conta3.codcop_ef
        WHEN mfc_factura_m.medio_pago="45"
         let mcop=mfc_conta3.codcop_ba
        WHEN mfc_factura_m.medio_pago="7"
         let mcop=mfc_conta3.codcop_cr
       END CASE
      END if 
      IF mcon<>mfc_conta3.codconta THEN
       CALL FGL_WINMESSAGE( "Administrador", " LOS SERVICIOS DIGITADOS SON DE DIfcRENTES CONTABILIDADES ", "stop") 
       INITIALIZE tafc_nota_m[y].* TO NULL
       DISPLAY tafc_nota_m[y].* TO ofc[z].*
       NEXT FIELD codigo
       EXIT foreach
      END IF
      IF mcop<>mcopp THEN
       CALL FGL_WINMESSAGE( "Administrador", " LOS SERVICIOS DIGITADOS PERTENECEN A DIfcRENTES TIPOS DE COMPROBANTES", "stop") 
       INITIALIZE tafc_nota_m[y].* TO NULL
       DISPLAY tafc_nota_m[y].* TO ofc[z].*
       NEXT FIELD codigo
       EXIT foreach
      END if  
     END FOREACH
    END FOR
    LET mcodser=NULL
    LET mcodser=tafc_nota_m[y].codigo  
    LET tafc_nota_m[y].descripcion=rec_servic.descripcion
    DISPLAY tafc_nota_m[y].descripcion to ofc[z].descripcion
    --ok
    {
    IF rec_servic.maneja_cat="S" THEN 
      IF mfc_terceros.tipo_persona="2" THEN
       IF mced="N" then 
        LET cnt=0
        SELECT count(*) INTO cnt FROM subsi15
         WHERE cedtra=tpfc_factura_m.nit
        IF cnt IS NULL THEN LET cnt=0 END IF
        IF cnt=0 THEN 
           LET tafc_nota_m[y].codcat="D"
        ELSE
         LET cnt=0
         SELECT count(*) INTO cnt FROM subsi15
          WHERE cedtra=mfc_factura_m.nit AND estado="I"
         IF cnt IS NULL THEN LET cnt=0 END IF
         IF cnt<>0 THEN 
          initialize msubsi15.* to NULL
          select * into msubsi15.* from subsi15 where cedtra=mfc_factura_m.nit
          IF msubsi15.carnet="F" THEN
           LET dias=0 
           let dias=mfc_factura_m.fecha_elaboracion-msubsi15.fccest
           if dias>365 THEN
            LET tafc_nota_m[y].codcat="D"
           ELSE
            initialize msubsi12.* to NULL
            select * into msubsi12.* from subsi12
             where today between fccini and fccfin
            let mpersal=NULL
            select max(periodo) into mpersal from subsi10
             where cedtra=mfc_factura_m.nit and suebas>0
            if mpersal is not null THEN
             let msalario=NULL
             select sum(suebas) into msalario from subsi10
             where cedtra=mfc_factura_m.nit and periodo=mpersal
             if msalario is null then let msalario=0 end IF
             let mcansal=msalario/msubsi12.salmin
            ELSE
             initialize msubsi17.* to NULL
             DECLARE updggxs17 CURSOR FOR
             SELECT * FROM subsi17
              where cedtra=msubsi15.cedtra ORDER BY fecha DESC
             FOREACH updggxs17 INTO msubsi17.*
               EXIT FOREACH
             END FOREACH
             let mcansal=msubsi17.salario/msubsi12.salmin
            end IF
            DECLARE updrdrxs30 CURSOR FOR
             SELECT * FROM subsi30 ORDER BY codcat ASC
            FOREACH updrdrxs30 INTO msubsi30.*
             if mcansal<msubsi30.cansal THEN
              EXIT FOREACH
             end IF
            END FOREACH
            IF msubsi30.codcat="1" THEN
              LET tafc_nota_m[y].codcat="A"
            END IF
            IF msubsi30.codcat="2" THEN
             LET tafc_nota_m[y].codcat="B"
            END IF
            IF msubsi30.codcat="3" THEN
             LET tafc_nota_m[y].codcat="C"
            END IF  
           END if 
          else 
           LET tafc_nota_m[y].codcat="D"
          END if   
         ELSE 
          initialize msubsi15.* to NULL
          select * into msubsi15.* from subsi15 where cedtra=mfc_factura_m.nit
          IF msubsi15.carnet="I" THEN
           LET tafc_nota_m[y].codcat="B"
          ELSE 
           initialize msubsi12.* to NULL
           select * into msubsi12.* from subsi12
            where today between fccini and fccfin
           let mpersal=NULL
           select max(periodo) into mpersal from subsi10
            where cedtra=mfc_factura_m.nit and suebas>0
           if mpersal is not null THEN
            let msalario=NULL
            select sum(suebas) into msalario from subsi10
            where cedtra=mfc_factura_m.nit and periodo=mpersal
            if msalario is null then let msalario=0 end IF
            let mcansal=msalario/msubsi12.salmin
           ELSE
            initialize msubsi17.* to NULL
            DECLARE upllggxs17 CURSOR FOR
            SELECT * FROM subsi17
             where cedtra=msubsi15.cedtra ORDER BY fecha DESC
            FOREACH upllggxs17 INTO msubsi17.*
              EXIT FOREACH
            END FOREACH
            let mcansal=msubsi17.salario/msubsi12.salmin
           end IF
           DECLARE upllnnxs30 CURSOR FOR
           SELECT * FROM subsi30 ORDER BY codcat ASC
           FOREACH upllnnxs30 INTO msubsi30.*
            if mcansal<msubsi30.cansal THEN
             EXIT FOREACH
            end IF
           END FOREACH
           IF msubsi30.codcat="1" THEN
            LET tafc_nota_m[y].codcat="A"
           END IF
           IF msubsi30.codcat="2" THEN
            LET tafc_nota_m[y].codcat="B"
           END IF
           IF msubsi30.codcat="3" THEN
            LET tafc_nota_m[y].codcat="C"
           END IF
          END if 
         END IF   
        END IF
       ELSE
        IF mced="B" THEN
         INITIALIZE msubsi22.* TO NULL
         SELECT * INTO msubsi22.* FROM subsi22
         where documento = mfc_factura_m.nit
         let medad=0
         let medad=today-msubsi22.fccnac
         let medad=medad/(365.25)
         LET cnt=0
         SELECT count(*) INTO cnt FROM fc_servicios_excentos
          WHERE codigo=tafc_nota_m[y].codigo
         IF cnt IS NULL THEN LET cnt=0 END IF
         IF cnt=0 THEN
          IF medad>="19" THEN
           CALL FGL_WINMESSAGE( "Administrador", " LA EDAD DE LA PERSONA A CARGO ES MAYOR O IGUAL A 19", "stop") 
           LET tafc_nota_m[y].codcat="D"
          END IF
         ELSE
          IF medad>="24" THEN
           CALL FGL_WINMESSAGE( "Administrador", " LA EDAD DE LA PERSONA A CARGO ES MAYOR O IGUAL A 24", "stop")
           LET tafc_nota_m[y].codcat="D"
          END if 
         END IF
        ELSE   
         initialize msubsi15.* to NULL
         select * into msubsi15.* from subsi15 where cedtra=mfc_factura_m.cedtra
         initialize msubsi12.* to NULL
         select * into msubsi12.* from subsi12
          where today between fccini and fccfin
         let mpersal=NULL
         select max(periodo) into mpersal from subsi10
          where cedtra=mfc_factura_m.cedtra and suebas>0
         if mpersal is not null THEN
           let msalario=NULL
           select sum(suebas) into msalario from subsi10
           where cedtra=mfc_factura_m.cedtra and periodo=mpersal
           if msalario is null then let msalario=0 end IF
             let mcansal=msalario/msubsi12.salmin
           ELSE
             initialize msubsi17.* to NULL
             DECLARE upwecedxs17 CURSOR FOR
             SELECT * FROM subsi17
              where cedtra=msubsi15.cedtra ORDER BY fecha DESC
             FOREACH wecedxs17 INTO msubsi17.*
               EXIT FOREACH
             END FOREACH
             let mcansal=msubsi17.salario/msubsi12.salmin
           end IF
           DECLARE uprtcedxs30 CURSOR FOR
            SELECT * FROM subsi30 ORDER BY codcat ASC
            FOREACH rtcedxs30 INTO msubsi30.*
            if mcansal<msubsi30.cansal THEN
             EXIT FOREACH
            end IF
           END FOREACH
           IF msubsi30.codcat="1" THEN
             LET tafc_nota_m[y].codcat="A"
           END IF
           IF msubsi30.codcat="2" THEN
            LET tafc_nota_m[y].codcat="B"
           END IF
           IF msubsi30.codcat="3" THEN
            LET tafc_nota_m[y].codcat="C"
           END IF
        END if    
       END if 
     ELSE
        LET cnt=0
        SELECT count(*) INTO cnt FROM subsi02
         WHERE nit=tpfc_factura_m.nit AND estado="A"
        IF cnt IS NULL THEN LET cnt=0 END IF
        IF cnt<>0 THEN 
         LET tafc_nota_m[y].codcat="E"
        ELSE
         LET tafc_nota_m[y].codcat="E"
         --LET tafc_factura_m[y].codcat="D"
        END IF 
     END IF 
     DISPLAY tafc_nota_m[y].codcat to ofc[z].codcat
     LET mcodcat=tafc_nota_m[y].codcat
   END IF
   }
   {IF mfc_factura_m.cuotas>rec_servic.cuotas THEN
     CALL FGL_WINMESSAGE( "Administrador", " LAS CUOTAS A CREDITO SUPERAN EL TOPE ESTABLECIDO EN EL SERVICIO ", "stop")
     INITIALIZE rec_servic.* TO NULL
     initialize tafc_nota_m[y].codigo to null
     next field codigo
    END if}
   END IF
  AFTER FIELD subcodigo
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_nota_m[y].subcodigo="?" then
    CALL fc_sub_serviciosval() RETURNING tafc_nota_m[y].subcodigo
    DISPLAY tafc_nota_m[y].subcodigo to ofc[z].subcodigo
    INITIALIZE mfc_sub_servicios.* TO NULL
    select * into mfc_sub_servicios.* from fc_sub_servicios 
     where codigo=tafc_nota_m[y].subcodigo
    IF mfc_sub_servicios.codigo is null THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SUBSERVICIO NO EXISTE ", "stop")
     INITIALIZE mfc_sub_servicios.* TO NULL
     initialize tafc_nota_m[y].subcodigo to null
     next field subcodigo
    END IF
    IF mfc_sub_servicios.estado<>"A" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SUBSERVICIO ESTA INACTIVO ", "stop")
     INITIALIZE mfc_sub_servicios.* TO NULL
     initialize tafc_nota_m[y].subcodigo to null
     next field subcodigo
    END IF
   ELSE 
    IF tafc_nota_m[y].subcodigo is not null then
     INITIALIZE mfc_sub_servicios.* TO NULL
     select * into mfc_sub_servicios.* from fc_sub_servicios 
      where codigo=tafc_nota_m[y].subcodigo
      AND codser= tafc_nota_m[y].codigo
     IF mfc_sub_servicios.codigo is null THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SUBSERVICIO NO EXISTE ", "stop")
      INITIALIZE mfc_sub_servicios.* TO NULL
      initialize tafc_nota_m[y].subcodigo to null
      next field subcodigo
     END IF
     IF mfc_sub_servicios.estado<>"A" THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL SERVICIO ESTA INACTIVO ", "stop")
      INITIALIZE mfc_sub_servicios.* TO NULL
      initialize tafc_nota_m[y].subcodigo to null
      next field subcodigo
     END IF
    END IF
   END IF
   IF tafc_nota_m[y].subcodigo is not null then
    LET tafc_nota_m[y].descri=mfc_sub_servicios.descripcion
    DISPLAY tafc_nota_m[y].descri to ofc[z].descri
   END IF
   {
  AFTER FIELD cod_bene
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_nota_m[y].cod_bene="?" then
    CALL fc_beneficiosval() RETURNING tafc_nota_m[y].cod_bene
    DISPLAY tafc_nota_m[y].cod_bene to ofc[z].cod_bene
    INITIALIZE mfc_beneficios.* TO NULL
    select * into mfc_beneficios.* from fc_beneficios 
     where codigo=tafc_nota_m[y].cod_bene
    IF mfc_beneficios.codigo is null THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL BENEFICIO NO EXISTE ", "stop")
     INITIALIZE mfc_beneficios.* TO NULL
     initialize tafc_nota_m[y].cod_bene to null
     next field cod_bene
    END IF
    IF mfc_beneficios.estado<>"A" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL BENEFICIO ESTA INACTIVO ", "stop")
     INITIALIZE mfc_beneficios.* TO NULL
     initialize tafc_nota_m[y].cod_bene to null
     next field cod_bene
    END IF
   ELSE 
    IF tafc_nota_m[y].cod_bene is not null THEN
     INITIALIZE mfc_beneficios.* TO NULL
     select * into mfc_beneficios.* from fc_beneficios 
      where codigo=tafc_nota_m[y].cod_bene
     IF mfc_beneficios.codigo is null THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL BENEFICIO NO EXISTE ", "stop")
      INITIALIZE mfc_beneficios.* TO NULL
      initialize tafc_nota_m[y].cod_bene to null
      next field cod_bene
     END IF
     IF mfc_beneficios.estado<>"A" THEN
      CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DEL BENEFICIO ESTA INACTIVO ", "stop")
      INITIALIZE mfc_beneficios.* TO NULL
      initialize tafc_nota_m[y].cod_bene to null
      next field cod_bene
     END IF
    END IF
   END IF
   IF tafc_nota_m[y].cod_bene is not null then
    LET tafc_nota_m[y].descrii=mfc_beneficios.descripcion
    DISPLAY tafc_nota_m[y].descrii to ofc[z].descrii
   END IF
   }
   {
  AFTER FIELD codcat
   LET y = arr_curr()
   LET z = scr_line()
   IF rec_servic.maneja_cat="S" THEN
    IF mfc_terceros.tipo_persona="2" THEN
      IF tafc_nota_m[y].codcat="?" THEN
         CALL fc_categoriasval() RETURNING tafc_nota_m[y].codcat
         DISPLAY tafc_nota_m[y].codcat to ofc[z].codcat
         INITIALIZE mfc_categorias.* TO NULL
         select * into mfc_categorias.* from fc_categorias 
          where codigo=tafc_nota_m[y].codcat
         IF mfc_categorias.codigo is null THEN
           CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DE LA CATEGORIA NO EXISTE ", "stop")
           INITIALIZE mfc_categorias.* TO NULL
           initialize tafc_nota_m[y].codcat to NULL
           next field codcat
         END IF
      ELSE 
        IF tafc_nota_m[y].codcat is not null THEN
          INITIALIZE mfc_categorias.* TO NULL
          select * into mfc_categorias.* from fc_categorias 
           where codigo=tafc_nota_m[y].codcat
          IF mfc_categorias.codigo is null THEN
           CALL FGL_WINMESSAGE( "Administrador", " EL CODIGO DE LA CATEGORIA NO EXISTE ", "stop")
           INITIALIZE mfc_categorias.* TO NULL
           initialize tafc_nota_m[y].codcat to NULL
           next field codcat
          END IF
        END IF
      END IF
      IF tafc_nota_m[y].codcat<>"D" THEN
        IF mcodcat<>tafc_nota_m[y].codcat THEN
          LET tafc_nota_m[y].codcat=mcodcat
          DISPLAY tafc_nota_m[y].codcat to ofc[z].codcat
        END IF
      END IF 
    END IF
   END IF 
  AFTER FIELD cantidad
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_nota_m[y].cantidad is null or 
      tafc_nota_m[y].cantidad<=0 THEN
      CALL FGL_WINMESSAGE( "Administrador", " LA CANTIDAD NO FUE DIGITADA ", "stop")  
    next field cantidad
   end IF
   IF rec_servic.maneja_cat="S" THEN
     INITIALIZE mfc_tarifas.* TO NULL
     select * into mfc_tarifas.* from fc_tarifas 
      where codigo=tafc_nota_m[y].codigo
        and prefijo=mfc_factura_m.prefijo
        and codcat=tafc_nota_m[y].codcat
        and vigencia=year(mfc_factura_m.fecha_elaboracion)
     IF mfc_tarifas.valor is null THEN
        CALL FGL_WINMESSAGE( "Administrador", " NO SE HA ESTABLECIDO LA TARIFA PARA ESTE SERVICIO ", "stop")
        INITIALIZE tafc_nota_m[y].* TO NULL
        DISPLAY tafc_nota_m[y].* TO ofc[z].*
        next field codigo
      ELSE
        LET tafc_nota_m[y].subsi=mfc_tarifas.valorsub
        DISPLAY tafc_nota_m[y].subsi to ofc[z].subsi
        LET tafc_nota_m[y].valoruni=mfc_tarifas.valor
        DISPLAY tafc_nota_m[y].valoruni to ofc[z].valoruni    
        IF rec_servic.tar_fija="S" THEN
          NEXT FIELD subsi
        END IF
      END IF
   END IF   
  AFTER FIELD valoruni
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_nota_m[y].valoruni is null THEN
    CALL FGL_WINMESSAGE( "Administrador", " NO HA DIGITADO LA TARIFA PARA ESTE SERVICIO ", "stop")
    INITIALIZE tafc_nota_m[y].* TO NULL
    DISPLAY tafc_nota_m[y].* TO ofc[z].*
    next field valoruni
   END IF 
  AFTER FIELD subsi
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_nota_m[y].subsi is null THEN
    CALL FGL_WINMESSAGE( "Administrador", " NO HA DIGITADO EL VALOR DEL SUBSIDIO PARA ESTE SERVICIO ", "stop")
    INITIALIZE tafc_nota_m[y].* TO NULL
    DISPLAY tafc_nota_m[y].* TO ofc[z].*
    next field subsi
   END IF 
}
    {
  AFTER FIELD valorbene
   LET y = arr_curr()
   LET z = scr_line()
   IF tafc_nota_m[y].cod_bene is NOT null THEN
    IF tafc_nota_m[y].valorbene is null THEN
     CALL FGL_WINMESSAGE( "Administrador", " NO HA DIGITADO EL VALOR DEL SUBSIDIO EN ESPECIE ", "stop")
     INITIALIZE tafc_nota_m[y].* TO NULL
     DISPLAY tafc_nota_m[y].* TO ofc[z].*
     next field valorbene
    END IF
   ELSE
    let tafc_nota_m[y].valorbene=0
    DISPLAY tafc_nota_m[y].valorbene to ofc[z].valorbene 
   END if 
   }
   call mvalornota(y)
   DISPLAY tafc_nota_m[y].iva to ofc[z].iva
   DISPLAY tafc_nota_m[y].impc to ofc[z].impc
   DISPLAY tafc_nota_m[y].valor to ofc[z].valor

  ON ACTION DETALLE
   LET ttlrow = ARR_COUNT()
   LET int_flag = FALSE
   LET toggle = TRUE
   EXIT INPUT

 END INPUT
 IF toggle THEN
  GOTO fc_nota_mtog1
 END IF
 IF int_flag THEN
   CLEAR FORM
   CALL FGL_WINMESSAGE( "Administrador", "LA MODIFICACION FUE CANCELADA", "information")
   INITIALIZE tpfc_nota_m.* TO NULL
   CALL fc_nota_minitta() 
   message "                                                        " 
   RETURN
  END IF
 END IF
LET gerrflag = FALSE
MESSAGE "MODIFICANDO LA NOTA" 
BEGIN WORK
WHENEVER ERROR CONTINUE
SET LOCK MODE TO WAIT

 IF NOT gerrflag THEN
  DELETE FROM fc_nota_d
   WHERE tipo = gfc_nota_m.tipo
     AND documento =  gfc_nota_m.documento
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF
 IF NOT gerrflag THEN
  UPDATE fc_nota_m SET( fecha_elaboracion, tipo_nota, tipo_nota_c, prefijo, numfac, nota1, estado )
   = ( tpfc_nota_m.fecha_elaboracion, tpfc_nota_m.tipo_nota, tpfc_nota_m.tipo_nota_c, 
    tpfc_nota_m.prefijo,
    tpfc_nota_m.numfac, 
    tpfc_nota_m.nota1, tpfc_nota_m.estado )
  WHERE tipo = gfc_nota_m.tipo
    AND documento =  gfc_nota_m.documento  
  IF status < 0 THEN
   LET gerrflag = TRUE
  ELSE
   FOR x = 1 TO gmaxarray
    CALL fc_nota_mrownull( x ) RETURNING rownull
    IF NOT rownull THEN
     INSERT INTO fc_nota_d ( codigo, {subcodigo,} cantidad, valoruni, iva, impc, subsi, valor, valorbene, tipo, documento, prefijo )
      VALUES ( tafc_nota_m[x].codigo,
             {tafc_nota_m[x].subcodigo, }
             tafc_nota_m[x].cantidad,
             tafc_nota_m[x].valoruni, 
             tafc_nota_m[x].iva, tafc_nota_m[x].impc,  
             tafc_nota_m[x].valor,
             tpfc_nota_m.tipo ,tpfc_nota_m.documento, tpfc_nota_m.prefijo )
     IF status < 0 THEN
      LET gerrflag = TRUE
      EXIT FOR
     END IF
    END IF
   END FOR
  END IF
 END IF
 message "                                                        "
 INITIALIZE tpfc_nota_m.* TO NULL
 LET gfc_nota_m.* = tpfc_nota_m.*
 IF NOT gerrflag THEN
  COMMIT WORK
  LET cnt = 1
  FOR x = 1 TO gmaxarray
   INITIALIZE gafc_nota_m[x].* TO NULL
   CALL fc_nota_mrownull( x ) RETURNING rownull
   IF NOT rownull THEN
    LET gafc_nota_m[cnt].* = tafc_nota_m[x].*
    LET cnt = cnt + 1
   END IF
  END FOR
  CALL fc_nota_mdetail()
  CALL FGL_WINMESSAGE( "Administrador", "LA NOTA FUE ADICIONADA Y ACTUALIZADA", "information")
 ELSE
  ROLLBACK WORK
  CALL FGL_WINMESSAGE( "Administrador", "LA MODIFICACION FUE CANCELADA", "information") 
 END IF
 SLEEP 2
END function

#### COMPROBANTE NOTA DEBITO
function gen_comp_nota()
define mauxiliar,mauxiliarr like fc_conta1.auxiliariva
define mcodcen,mcodcenn   like fc_conta1.cencosiva
define mnit,mnitt like niif141.nit
define mdetdep like niif141.descripcion
define mdetdepp char(50)
define mcosto,mvalorr,mvalors,mvalorsb like niif141.valor
define cnt,cntp integer
define mc, md, mdif, mvaltot, mvalanti, mivasub decimal(12,0)
define mcodcopp like niif141.codcop
define mdocumentoo like niif141.documento
define mfechaa like niif141.fecha
define mtp char(2)
DEFINE mfc_medio_pago_aux RECORD LIKE fc_medio_pago_aux.*
DEFINE mfc_factura_anti RECORD LIKE fc_factura_anti.*
DEFINE mcon141 RECORD LIKE niif141.*
DEFINE mnumero,xx INTEGER
DEFINE mfccven DATE
DEFINE m_nomnota char(15)
initialize mfc_factura_m.* to null
declare not244 cursor for
select * from fc_nota_m 
 WHERE fc_nota_m.tipo = gfc_nota_m.tipo
  AND fc_nota_m.numnota = gfc_nota_m.numnota
  --AND fc_nota_m.estado = "A"
foreach not244 into mfc_nota_m.*
 initialize mfc_nota_d.* to null
 declare not255 cursor for
 select * from fc_nota_d where tipo=mfc_nota_m.tipo 
   and documento=mfc_nota_m.documento
  order by codigo
 foreach not255 into mfc_nota_d.*
  initialize mfc_conta3.* to null
  select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_factura_d.codigo
     AND prefijo=mfc_factura_m.prefijo
  let mcodconta=NULL
  let mcodconta=mfc_conta3.codconta
  let mcodcop=NULL
  LET m_nomnota=null
  CASE
   WHEN gfc_nota_m.tipo="ND"
    let mcodcop=mfc_empresa.codcop_notad
    let m_nomnota="NOTA DEBITO"
   WHEN gfc_nota_m.tipo="NC"
    let mcodcop=mfc_empresa.codcop_notac
    let m_nomnota="NOTA CREDITO"
  END case 
 END FOREACH
END FOREACH 
LET mmarca2=mcodcop
CALL doccopcon141_niif()
let mdocumento=null
LET mdocumento=mdo
let mc=0
let md=0
let l=0
LET mvaltot=0
LET mvalanti=0
LET cnt=1
LET xx=mdocumento
WHILE cnt <> 0
 SELECT COUNT(*) INTO cnt FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
 IF cnt <> 0 THEN
  LET xx = xx + 1
  LET mdocumento = xx USING "&&&&&&&"        
 ELSE
  SELECT COUNT(*) INTO cnt FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
  IF cnt <> 0 THEN
   LET xx = xx + 1
   LET mdocumento = xx USING "&&&&&&&"        
  ELSE
   EXIT WHILE
  END IF
 END IF
END WHILE 
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET gerrflag = FALSE
BEGIN WORK
create temp table con14 
   (
     codconta char(2),
     codcop char(4),
     documento char(7),
     fecha date,
     auxiliar char(12),
     codcen char(4),
     codbod char(2),
     nit char(12),
     descripcion char(30),
     nat char(1),
     valor money(12,2),
     sec SMALLINT
   )
   --Actualiza tipo comprobante y numero
UPDATE fc_nota_m SET codcop=mcodcop,docu=mdocumento
 WHERE fc_nota_m.tipo = gfc_nota_m.tipo
  AND fc_nota_m.numnota = gfc_nota_m.numnota

LET mvaltot=0
initialize mfc_factura_m.* to null
declare nvnota244 cursor FOR
select * from fc_nota_m 
 WHERE fc_nota_m.tipo = gfc_nota_m.tipo
  AND fc_nota_m.numnota = gfc_nota_m.numnota
 -- AND fc_nota_m.estado = "A"
foreach nvnota244 into mfc_nota_m.*
 initialize mfc_nota_d.* to null
 declare nvnota255 cursor for
 select prefijo,documento,codigo,{subcodigo,}"A",
 cantidad,sum(valoruni),sum(iva),sum(impc),sum(subsi),sum(valor),sum(valorbene) 
 from fc_nota_d 
  where fc_nota_m.tipo = gfc_nota_m.tipo
  AND fc_nota_m.documento = gfc_nota_m.documento
  GROUP BY 1,2,3,4,5,6,12 
  order by codigo
 foreach nvnota255 into mfc_nota_d.*
  INITIALIZE mfc_factura_d.* TO NULL
  SELECT * INTO mfc_factura_m.* FROM fc_factura_m
    WHERE fc_factura_m.prefijo = gfc_nota_m.prefijo
      AND fc_factura_m.numfac = gfc_nota_m.numfac
  initialize rec_servic.* to null
  select * into rec_servic.* from fc_servicios 
   where codigo=mfc_nota_d.codigo 
  LET mfc_nota_d.iva=nomredondea(mfc_nota_d.iva)
  LET mfc_nota_d.impc=nomredondea(mfc_nota_d.impc)
  LET mivasub=0
  --LET mivasub=(mfc_factura_d.subsi*mfc_factura_d.cantidad)*(rec_servic.iva/100)
  --LET mfc_factura_d.iva=mfc_factura_d.iva-mivasub
  LET mfc_nota_d.iva=mfc_nota_d.iva
  
  initialize mfc_conta3.* to null
  select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_nota_d.codigo
     AND tipo=mfc_nota_m.tipo
  initialize mfc_conta1.* to null
  select * into mfc_conta1.* from fc_conta1 
   where codigo=mfc_nota.codigo
   
  LET mvalors=0
  let mvalors=mfc_nota_d.subsi*mfc_nota_d.cantidad
  LET mvalorsb=0
  let mvalorsb=mfc_nota_d.valorbene*mfc_nota_d.cantidad
  let mfc_nota_d.subsi=mfc_nota_d.subsi*mfc_nota_d.cantidad
  let mfc_nota_d.valorbene=mfc_nota_d.valorbene*mfc_nota_d.cantidad

  if mfc_conta1.auxiliaring is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliaring
   let mauxiliar=mniif233.auxiliar
   let a="C"
   let mdetdep=rec_servic.descripcion
   let mvalor=mfc_nota_d.valor-(mvalanti+mvalors+mvalorsb)
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencosing
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, mfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
  END if 
  end if
  if mfc_conta1.auxiliariva is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliariva
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep="IVA GENERADO"
   let mfc_nota_d.iva=mfc_nota_d.iva*mfc_nota_d.cantidad
   let mvalor=mfc_nota_d.iva
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencosiva
   else
    let mcodcen=null
   end IF
   IF mvalor>0 then
   let l=l+1
   INSERT INTO niif141
     ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
        nit, descripcion, nat, valor, sec )
    VALUES ( mcodconta, mcodcop , mdocumento, mfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
        mnit, mdetdep, a, mvalor, l )
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
   END if
  end IF
  if mfc_conta1.auxiliarimpc is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarimpc
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep="IMPUESTO CONSUMO"
   let mfc_nota_d.impc=mfc_nota_d.impc*mfc_nota_d.cantidad
   let mvalor=mfc_nota_d.impc
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencosimpc
   else
    let mcodcen=null
   end IF
   IF mvalor>0 then
   let l=l+1
   INSERT INTO niif141
     ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
        nit, descripcion, nat, valor, sec )
    VALUES ( mcodconta, mcodcop , mdocumento, mfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
        mnit, mdetdep, a, mvalor, l )
   IF status < 0 THEN
    LET gerrflag = TRUE
   END IF
   END if
  end IF
  if mfc_factura_m.forma_pago="2" THEN
    if mfc_conta1.auxiliarcar is not null THEN
     initialize mniif233.* to NULL
     select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarcar
     let mauxiliar=mniif233.auxiliar
     let a="D"
     let mdetdep="ND-FACT/CREDITO ",mfc_nota_m.numfac
     {if mfc_factura_m.cuotas<=0 THEN
      LET mfc_factura_m.cuotas=1
     END if}
     let mvalor=(((mfc_nota_d.valor+mfc_nota_d.iva+mfc_nota_d.impc))/1)
     let md=md+mvalor
     if mniif233.tercero="S" THEN
      let mnit=mfc_factura_m.nit
     ELSE
      let mnit=NULL
     end IF
     if mniif233.centros="S" THEN
      let mcodcen=mfc_conta1.cencoscar
     ELSE
      let mcodcen=NULL
     end IF
     IF mvalor>0 THEN
      {FOR x = 1 TO mfc_factura_m.cuotas
       let l=l+1
       INSERT INTO niif141
       ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
          nit, descripcion, nat, valor, sec )
       VALUES ( mcodconta, mcodcop , mdocumento, mfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
          mnit, mdetdep, a, mvalor, l )
       IF status < 0 THEN
        LET gerrflag = TRUE
       END IF
       if mniif233.detalla="C" or mniif233.detalla="P" THEN
        IF x<>1 THEN
         LET mfc_factura_m.fecha_vencimiento=mfc_factura_m.fecha_vencimiento+30
        END if
        INSERT INTO niif142
         ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fccven )
        VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, x, mfc_factura_m.numfac, mfc_factura_m.fecha_vencimiento )
        IF status < 0 THEN
         LET gerrflag = TRUE
        END IF 
       END IF
      END for }
     END if
    end IF
  END IF
  if mfc_factura_m.forma_pago="1" THEN
   if mfc_factura_m.medio_pago="10" OR mfc_factura_m.medio_pago="20" THEN 
    if mfc_conta1.auxiliarcaja is not null THEN
     initialize mniif233.* to NULL
     select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarcaja
     let mauxiliar=mniif233.auxiliar
     let a="D"
     let mdetdep="ND.INGRESO DE CAJA ",mfc_nota_m.numfac
     let mvalor=((mfc_nota_d.valor+mfc_nota_d.iva+mfc_nota_d.impc)-(mfc_nota_d.subsi))
     let md=md+mvalor
     if mniif233.tercero="S" THEN
      let mnit=mfc_factura_m.nit
     ELSE
      let mnit=NULL
     end IF
     if mniif233.centros="S" THEN
      let mcodcen=mfc_conta1.cencoscaja
     ELSE
      let mcodcen=NULL
     end IF
     IF mvalor>0 THEN
      --let l=l+1
      INSERT INTO con14
        ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
           nit, descripcion, nat, valor, sec )
       VALUES ( mcodconta, mcodcop , mdocumento, mfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
           mnit, mdetdep, a, mvalor, 1 )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF
     END IF
    end IF
   END IF
   if mfc_factura_m.medio_pago="48" OR mfc_factura_m.medio_pago="49" OR mfc_factura_m.medio_pago="42" OR mfc_factura_m.medio_pago="45" THEN 
    if mfc_conta1.auxiliarbanco is not null THEN
     initialize mniif233.* to NULL
     select * into mniif233.* from niif233 
      where auxiliar=mfc_conta1.auxiliarbanco
     let mauxiliar=mniif233.auxiliar
     let a="D"
     let mdetdep="ND.INGRESO BANCO ",mfc_nota_m.numfac
     let mvalor=((mfc_nota_d.valor+mfc_nota_d.iva+mfc_nota_d.impc)-(mfc_nota_d.subsi+mfc_nota_d.valorbene))
     let md=md+mvalor
     if mniif233.tercero="S" THEN
      let mnit=mfc_factura_m.nit
     ELSE
      let mnit=NULL
     end IF
     if mniif233.centros="S" THEN
      let mcodcen=mfc_conta1.cencoscaja
     ELSE
      let mcodcen=NULL
     end IF
     IF mvalor>0 THEN
      --let l=l+1
      INSERT INTO con14
       ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
          nit, descripcion, nat, valor, sec )
      VALUES ( mcodconta, mcodcop , mdocumento, mfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
          mnit, mdetdep, a, mvalor, 1 )
      IF status < 0 THEN
       LET gerrflag = TRUE
      END IF
     END IF
    end IF
   END if
  END IF
 end foreach
end FOREACH
initialize mcon141.* to null
 declare notat55 cursor for
 select codconta,codcop,documento,fecha,auxiliar,codcen,codbod,nit,descripcion,
  nat,sum(valor),1 from con14
  group by codconta,codcop,documento,fecha,auxiliar,codcen,codbod,nit,descripcion,nat
  order by auxiliar
 foreach notat55 into mcon141.*
  let l=l+1
  INSERT INTO niif141
   ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
     nit, descripcion, nat, valor, sec )
   VALUES ( mcon141.codconta, mcon141.codcop, mcon141.documento, mcon141.fecha,
     mcon141.auxiliar, mcon141.codcen, mcon141.codbod,  
     mcon141.nit, mcon141.descripcion, mcon141.nat, mcon141.valor, l )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END foreach 

IF NOT gerrflag THEN
 let mhora=time
  INSERT INTO niif339  -- NUEVA AUDITORIA ADICIONA
  ( codconta, codcop, documento, fecha, hora, tipope, usuario )
  VALUES 
  ( mcodconta, mcodcop, mdocumento, gfc_nota_m.fecha_nota, mhora, "A", musuario)
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 INSERT INTO niif149 ( codconta, codcop, documento, fecha, usuadd, usuact, estado )
      VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, musuario, musuario,"A")
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 LET mdetdepp=null
 let mdetdepp=m_nomnota,"N.D FACTURA-",mfc_nota_m.prefijo clipped,"-",mfc_nota_m.numfac CLIPPED
 INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "1", mdetdepp )
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[1,50]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[51,100]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 

IF NOT gerrflag THEN
  set lock mode to wait
  DECLARE notacon11lock CURSOR FOR
  select ultnum from niif148
   WHERE niif148.codcop=mcodcop
   FOR UPDATE
  OPEN notacon11lock
  FETCH notacon11lock
  UPDATE niif148 SET ultnum=ultnum+1 WHERE niif148.codcop=mcodcop
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  CLOSE notacon11lock 
END IF

IF NOT gerrflag THEN
 COMMIT WORK
 --CALL FGL_WINMESSAGE( "Administrador", "EL COMPROBANTE FUE ADICIONADO", "information")
ELSE
 ROLLBACK WORK
 CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "information") 
END if
DROP TABLE con14
END IF 
END FUNCTION

function gen_comp_nota_s()
define mauxiliar,mauxiliarr like fc_conta1.auxiliariva
define mcodcen,mcodcenn   like fc_conta1.cencosiva
define mnit,mnitt like niif141.nit
define mdetdep like niif141.descripcion
define mdetdepp char(50)
define mcosto,mvalorr,mvalors,mvalorsb like niif141.valor
define cnt,cntp integer
define mc, md, mdif, mvaltot, mvalanti decimal(12,2)
define mcodcopp like niif141.codcop
define mdocumentoo like niif141.documento
define mfechaa,mfccven like niif141.fecha
define mtp char(2)
DEFINE mfc_medio_pago_aux RECORD LIKE fc_medio_pago_aux.*
DEFINE mfc_factura_anti RECORD LIKE fc_factura_anti.*
DEFINE mcon141 RECORD LIKE niif141.*
DEFINE mnumero,xx INTEGER
DEFINE mvals decimal(12,2)
DEFINE m_nomnota char(15)
LET m_nomnota=null
IF gfc_nota_m.tipo="ND" then
 let m_nomnota="NOTA DEBITO"
ELSE 
 let m_nomnota="NOTA CREDITO"
END if 
LET mcodconta=NULL
LET mcodcop=NULL
LET mvals=0
initialize mfc_factura_m.* to null
declare notasuvil244 cursor for
select * from fc_nota_m 
 WHERE fc_nota_m.tipo = gfc_nota_m.tipo
  AND fc_nota_m.nota = gfc_nota_m.numnota
  AND fc_nota_m.estado = "P"
foreach notasuvil244 into mfc_nota_m.*
 initialize mfc_nota_d.* to null
 declare notasuvil255 cursor for
 select * from fc_nota_d where tipo= mfc_nota_m.tipo 
   and documento=mfc_nota_m.documento
  order by codigo

END FOREACH
IF mvals IS NULL OR mvals = 0 THEN
  RETURN
END IF  
IF mcodconta IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO LA CONTABILIDAD PARA COMPROBANTE DEL SUBSIDIO A LA DEMANDA", "stop")
 return
END IF
IF mcodcop IS null THEN
 CALL FGL_WINMESSAGE( "Administrador", "NO SE DEFINIO EL TIPO DE COMPROBANTE DEL SUBSIDIO A LA DEMANDA", "stop")
 return
END IF
LET mmarca2=mcodcop
CALL doccopcon141_niif()
let mdocumento=null
LET mdocumento=mdo
let mc=0
let md=0
let l=0
LET mvaltot=0
LET mvalanti=0
LET cnt=1
LET xx=mdocumento
WHILE cnt <> 0
 SELECT COUNT(*) INTO cnt FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
 IF cnt <> 0 THEN
  LET xx = xx + 1
  LET mdocumento = xx USING "&&&&&&&"        
 ELSE
  SELECT COUNT(*) INTO cnt FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
  IF cnt <> 0 THEN
   LET xx = xx + 1
   LET mdocumento = xx USING "&&&&&&&"        
  ELSE
   EXIT WHILE
  END IF
 END IF
END WHILE 
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif141
  WHERE  niif141.codcop = mcodcop AND
         niif141.documento = mdocumento
         and niif141.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET cnt = 0
SELECT COUNT(*) INTO cnt
  FROM niif146
  WHERE  niif146.codcop = mcodcop AND
         niif146.documento = mdocumento
         and niif146.codconta=mcodconta
IF cnt <> 0 THEN
 CALL FGL_WINMESSAGE( "Administrador", "EL NUMERO DEL COMPROBANTE YA EXISTE", "stop")
 return
END IF
LET gerrflag = FALSE
BEGIN WORK
create temp table con14 
   (
     codconta char(2),
     codcop char(4),
     documento char(7),
     fecha date,
     auxiliar char(12),
     codcen char(4),
     codbod char(2),
     nit char(12),
     descripcion char(30),
     nat char(1),
     valor money(12,2),
     sec smallint
   )
LET mvaltot=0
initialize mfc_factura_m.* to null
declare notasuvvil244 cursor FOR
select * from fc_nota_m 
 WHERE fc_nota_m.tipo = gfc_nota_m.tipo
  AND fc_nota_m.nota = gfc_nota_m.numnota
  AND fc_nota_m.estado = "P"
foreach notasuvvil244 into mfc_factura_m.*
 initialize mfc_factura_d.* to null
 declare notasuvvil255 cursor for
 select prefijo,documento,codigo,{subcodigo,}"A",cantidad,sum(valoruni),sum(iva),sum(impc),sum(subsi),sum(valor),sum(valorbene)
  from fc_nota_d 
  where tipo=mfc_nota_m.tipo 
   and documento=mfc_nota_m.documento
  GROUP BY 1,2,3,4,5,6,12 
  order by codigo
 foreach notasuvvil255 into mfc_nota_d.*
 initialize mfc_factura_m.* TO NULL
 SELECT * INTO mfc_factura_m.* FROM fc_factura_m
  WHERE prefijo = mfc_nota_m.prefijo
   AND numfac = mfc_nota_m.numfac
 initialize rec_servic.* to null
  select * into rec_servic.* from fc_servicios 
   where codigo=mfc_nota_d.codigo 
  initialize mfc_conta1.* to null
  select * into mfc_conta1.* from fc_conta1 
   where codigo=rec_servic.codigo
  initialize mfc_conta3.* to NULL
   select * into mfc_conta3.* from fc_conta3 
   where codigo=mfc_nota_d.codigo
     AND prefijo=mfc_nota_m.prefijo 
  if mfc_conta1.auxiliarsubsi is not null then
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarsubsi
   let mauxiliar=mniif233.auxiliar
   let a="D"
   let mdetdep="ND SUB TARIFA ",mfc_nota_m.prefijo clipped,"-",mfc_nota_m.numfac USING "-------"
   LET mdetdep = mdetdep CLIPPED
   let mvalor=mfc_nota_d.subsi*mfc_nota_d.cantidad
   let md=md+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencossubsi
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, mfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     LET mfccven=null
     LET mfccven=mfc_factura_m.fecha_vencimiento+30
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fccven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, 1, mfc_nota_m.numfac, mfccven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END if 
   END IF
   initialize mniif233.* to null
   select * into mniif233.* from niif233 
    where auxiliar=mfc_conta1.auxiliarcars
   let mauxiliar=mniif233.auxiliar
   let a="C"
   let mdetdep="ND SUB TARIFA ",mfc_nota_m.prefijo clipped,"-",mfc_nota_m.numfac CLIPPED
   let mvalor=mfc_nota_d.subsi*mfc_nota_d.cantidad
   let mc=mc+mvalor
   if mniif233.tercero="S" then
    let mnit=mfc_factura_m.nit
   else
    let mnit=null
   end if
   if mniif233.centros="S" then
    let mcodcen=mfc_conta1.cencoscars
   else
    let mcodcen=null
   end IF
   IF mvalor>0 THEN
    let l=l+1
    INSERT INTO niif141
      ( codconta, codcop, documento, fecha, auxiliar, codcen, codbod,
         nit, descripcion, nat, valor, sec )
     VALUES ( mcodconta, mcodcop , mdocumento, mfc_nota_m.fecha_nota, mauxiliar, mcodcen, null, 
         mnit, mdetdep, a, mvalor, l )
    IF status < 0 THEN
     LET gerrflag = TRUE
    END IF
    if mniif233.detalla="C" or mniif233.detalla="P" THEN
     LET mfccven=null
     LET mfccven=mfc_factura_m.fecha_vencimiento+30
     INSERT INTO niif142
      ( codconta, codcop, documento, sec, tipcru, nocts, doccru, fccven )
     VALUES ( mcodconta, mcodcop, mdocumento, l, mfc_conta3.tipcruu, 1, mfc_nota_m.numfac, mfccven )
     IF status < 0 THEN
      LET gerrflag = TRUE
     END IF 
    END if
   END if
  end IF
 end foreach
end FOREACH

IF NOT gerrflag THEN
 let mhora=time
  INSERT INTO niif339  -- NUEVA AUDITORIA ADICIONA
  ( codconta, codcop, documento, fecha, hora, tipope, usuario )
  VALUES 
  ( mcodconta, mcodcop, mdocumento, gfc_nota_m.fecha_nota, mhora, "A", musuario)
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 INSERT INTO niif149 ( codconta, codcop, documento, fecha, usuadd, usuact, estado )
      VALUES ( mcodconta, mcodcop , mdocumento, gfc_nota_m.fecha_nota, musuario, musuario,"A")
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
END IF
IF NOT gerrflag THEN
 LET mdetdepp=null
 let mdetdepp=m_nomnota," DE LA FACTURA - ",mfc_nota_m.prefijo clipped,"-",mfc_nota_m.numfac USING "-------" CLIPPED
 INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "1", mdetdepp )
 IF status < 0 THEN
  LET gerrflag = TRUE
 END IF
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[1,50]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "2", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
 LET mdetdepp=null
 let mdetdepp=gfc_nota_m.nota1[51,100]
 IF mdetdepp IS NOT NULL THEN
  INSERT INTO niif187 ( codconta, codcop, documento, marca, numero, dato )
      VALUES ( mcodconta, mcodcop , mdocumento, "D", "3", mdetdepp )
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF 
IF NOT gerrflag THEN
  set lock mode to wait
  DECLARE notascon11lock CURSOR FOR
  select ultnum from niif148
   WHERE niif148.codcop=mcodcop
   FOR UPDATE
  OPEN notascon11lock
  FETCH notascon11lock
  UPDATE niif148 SET ultnum=ultnum+1 WHERE niif148.codcop=mcodcop
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
  CLOSE notascon11lock 
END IF
IF NOT gerrflag THEN
 COMMIT WORK
 CALL FGL_WINMESSAGE( "Administrador", "EL COMPROBANTE DE SUBSIDIO FUE ADICIONADO", "information")
ELSE
 ROLLBACK WORK
 CALL FGL_WINMESSAGE( "Administrador", "LA ADICION FUE CANCELADA", "information") 
END if
DROP TABLE con14
END IF 
END FUNCTION


FUNCTION rep_notas()
DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
DEFINE mcodpun CHAR(2)
DEFINE cnt INTEGER
DEFINE opp CHAR(1)
 let ubicacion=fgl_getenv("HOME"),"/reportes/rel_notas"
 let ubicacion=ubicacion CLIPPED
 let tpmnota=NULL
 prompt "Digite ND - NC : " for tpmnota
 LET tpmnota= upshift(tpmnota)
 if tpmnota is null THEN 
  RETURN
 end IF
 let mprefijo=null
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null then 
  return
 end if
 LET mfecini = NULL
 LET mfecfin = NULL
 let mdeftit="    RELACION DE NOTAS "
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL confccr() RETURNING mfecini,mfecfin
 if mfecini is null or mfecfin is null then
   return
 end IF
 LET mtiprep = NULL
 PROMPT " Reporte  1. Texto   2. Excel  : " for  mtiprep
 IF mtiprep <> "1" AND mtiprep <> "2" THEN
    RETURN
 END if 
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
 --CALL ini_mensaje_espera("Generando Reporte ... Espere por favor...")
 IF mtiprep = "1" THEN
   START REPORT norprec_xls TO ubicacion
 ELSE
  { LET handler = configureOutput_excel(90,"5.0cm","3.0cm","0.5cm","0.5cm","XLSX")}
   START REPORT norprec_xls TO XML HANDLER HANDLER
 END IF  
  DECLARE nocurrec CURSOR FOR
  SELECT * FROM fc_nota_m
   WHERE fecha_nota between mfecini and mfecfin
    AND tipo = tpmnota
    AND prefijo = mprefijo
    AND estado <> "B" 
   ORDER BY tipo, documento
  FOREACH nocurrec INTO mfc_nota_m.*
    LET mvaltot =0
    LET mvaliva = 0
    LET mvalsub = 0
    select sum((valoruni) * cantidad) 
    INTO mvaltot  from fc_nota_d
    WHERE tipo=mfc_nota_m.tipo AND documento=mfc_nota_m.documento
   IF mvaltot IS NULL then LET mvaltot=0 END IF 
   LET mvaltot = nomredondea(mvaltot)
   LET mvalsub = nomredondea(mvalsub)
   LET mvaliva = nomredondea(mvaliva)
   initialize mfc_factura_m.* to null
   select * into mfc_factura_m.* from fc_factura_m 
    where prefijo=mfc_nota_m.prefijo and numfac=mfc_nota_m.numfac 
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
   OUTPUT TO REPORT norprec_xls()
  END FOREACH
 finish report norprec_xls
 IF mtiprep ="1" THEN
   let mdefnom="RELACION DE NOTAS"
   let mdeflet="condensed"
   let mdeftam=66
   let mhoja="9.5x11"
   call impsn(ubicacion) 
 END IF
END FUNCTION

REPORT norprec_xls_ant()
 DEFINE mestado char(10)
 OUTPUT
   top margin 3
   bottom  margin 8
   left  margin 0
   right margin 240
   page length 66
 format
  FIRST page HEADER
  print column 01,"PREFIJO",
        column 10,"DOCUMENTO",
        column 20,"fc.ELABORA",
        COLUMN 40,"VR.FACTURA",
        column 60,"ESTADO",   
        column 80,"TERCERO",
        column 98,"NOMBRE TERCERO"
   PRINT COLUMN 01, "-----------------------------------------------------------"
   
  on every ROW
   CASE
    when mfc_nota_m.estado="B"
     LET mestado="BORRADOR"
    when mfc_nota_m.estado="A"
     LET mestado="ENVIADA CON ERRORES"
    when mfc_nota_m.estado="S"
     LET mestado="TRASMITIDA"
    when mfc_nota_m.estado="P"
     LET mestado="APROBADA EXITOSA" 
   END case   
   print column 01,mfc_factura_m.prefijo,
         column 10,mfc_factura_m.documento,
         column 20,mfc_factura_m.fecha_elaboracion,
         COLUMN 40,mvaltot USING "###,###,##&.&&",
         column 60,mestado,  
         column 80,mfc_factura_m.nit,
         column 110,mnombre
  --skip to top of page
end REPORT

REPORT norprec_xls()
 OUTPUT
   top margin 3
   bottom  margin 8
   left  margin 0
   right margin 240
   page length 66
 format
  PAGE HEADER
  let mtime=TIME
  print column 1,"fecha : ",today," + ",mtime,
        column 121,"Pag No. ",pageno using "####"
 skip 1 LINES
 let mp1 = (132-length(mfc_empresa.razsoc clipped))/2
 print column mp1,mfc_empresa.razsoc
 let mp1 = (132-length("LISTADO GENERAL DE FACTURAS APROBADAS "))/2
 print column mp1,"LISTADO GENERAL DE NOTAS APROBADAS "

 skip 1 LINES
 PRINT COLUMN 01, "TIPO DE NOTA  : ", tpmnota 
 PRINT COLUMN 01, "PREFIJO       : ", mprefijo 
 print "--------------------------------------------------------------------",
       "--------------------------------------------------------------------",
       "---------------------------"
  PRINT column 01,"NUM NOT",
        column 10,"N.INTER",
        column 20,"PREFI",
        column 26,"NUM FAC",
        column 36,"F.ELA.NOTA",
        column 50,"fecha.NOTA",
        COLUMN 65,"VR.NOTA",
        COLUMN 80,"VR.SUBSIDIO",
        COLUMN 95,"VR.IVA",
        Column 115,"TERCERO"
  print "--------------------------------------------------------------------",
        "--------------------------------------------------------------------",
        "---------------------------"
  on every ROW
   print COLUMN 01,mfc_nota_m.numnota USING "-------",
         COLUMN 10,mfc_nota_m.documento,
         column 20,mfc_nota_m.prefijo,
         column 26,mfc_nota_m.numfac USING "-------",
         COLUMN 36,mfc_nota_m.fecha_elaboracion,
         column 50,mfc_nota_m.fecha_nota,
         COLUMN 66,mvaltot USING "###,###,##&",
         COLUMN 79,mvalsub USING "###,###,##&",
         COLUMN 94,mvaliva USING "###,###,##&",
         column 111,mfc_factura_m.nit CLIPPED,"-",mnombre[1,30]
 ON LAST ROW      
    print "--------------------------------------------------------------------",
          "--------------------------------------------------------------------",
          "---------------------------" 
    PRINT COLUMN 1,  "TOTAL NOTA .....", 
       COLUMN 66, sum(mvaltot) USING "###,###,##&",
       COLUMN 99, sum(mvalsub) USING "###,###,##&",
       COLUMN 94, sum(mvaliva) USING "###,###,##&"
    skip to top of page
end REPORT


function detalladonota()
 define mfc_nota_m record like fc_nota_m.*
 define mfc_factura_d record like fc_factura_d.*
 define ubicacion char(100)
 define op char(1)
 define mcaja char(2)
 define cnt,musuario integer
 define mcosto,mcostoo decimal(12,2)
 DEFINE mprefijo char(5)
 define tp record
  codser char(5),
  costo decimal(12,2),
  subsidio decimal(12,2),
  cantidad integer,
  iva decimal(12,2),
  total decimal(12,2)
 end RECORD

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
 let mprefijo=null
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null then 
  return
 end if
 MESSAGE "" --AT 2,1
 MESSAGE "Trabajando por favor espere ... " --AT 2,1
 
 create temp table mvilla2
 (
  numfac integer,
  documento integer,
  codser char(5),
  costo decimal(12,2),
  subsidio decimal(12,2), 
  cantidad integer,
  iva decimal(12,2),
  total decimal(12,2)
 )
 let ubicacion=fgl_getenv("HOME"),"/reportes/detalladonota"
 let ubicacion=ubicacion clipped
 start report norarqgennnfac to ubicacion
  INITIALIZE mfc_nota_m.* TO NULL
  declare nofacrrtes44444 cursor for
  SELECT * FROM fc_nota_m
    WHERE fc_nota_m.prefijo=mprefijo 
      AND fc_nota_m.fecha_nota>=mfecini and fc_nota_m.fecha_nota<=mfecfin
       AND estado="P"
   ORDER BY documento
  FOREACH nofacrrtes44444 INTO mfc_nota_m.*
   INITIALIZE mfc_factura_m.* TO NULL
   SELECT * into mfc_factura_m.* FROM fc_factura_m
    WHERE prefijo = mfc_nota_m.prefijo
      AND numfac = mfc_nota_m.numfac 
   INITIALIZE mfc_nota_d.* TO NULL
   declare nofacrrtes444444 cursor for
   SELECT fc_nota_d.* FROM fc_nota_d, fc_servicios
     WHERE  fc_nota_d.codigo = fc_servicios.codigo
       AND fc_servicios.cobertura <> "0"
       AND fc_nota_d.documento=mfc_nota_m.documento
       AND fc_nota_d.prefijo=mfc_nota_m.prefijo
    ORDER BY fc_nota_d.codigo
   FOREACH nofacrrtes444444 INTO mfc_nota_d.*
    insert into mvilla2 ( numfac, documento, codser, costo, subsidio, cantidad, 
     iva, total )
    values ( mfc_nota_m.numfac, mfc_nota_m.documento, mfc_nota_d.codigo, 
     mfc_nota_d.valoruni, 
     mfc_nota_d.subsi, mfc_nota_d.cantidad,
     mfc_nota_d.iva, mfc_nota_d.valor )
   END FOREACH
  END FOREACH
 INITIALIZE tp.* TO NULL
 declare facrtestp cursor for
 #SELECT codusu,codser,codcat,codtipusu,costo,sum(cantidad),sum(iva),sum(total)
 SELECT codser,costo,subsidio,sum(cantidad),sum(iva*cantidad),sum(total-subsidio*cantidad)
   FROM mvilla2
  GROUP BY codser,costo,subsidio --,iva
  ORDER BY codser,costo--,iva
 FOREACH facrtestp INTO tp.*
  --LET tp.iva= nomredondea(tp.iva)
  --LET tp.total=nomredondea(tp.total)
  output to report norarqgennnfac(tp.*,mprefijo)
 end foreach
 finish report norarqgennnfac
 call impsn(ubicacion)
 drop table mvilla2
END FUNCTION  
REPORT norarqgennnfac(tp,mprefijo)
define op char(1)
define mcaja char(2)
define cnt,musuario integer
define mtitulo char(100)
DEFINE mprefijo char(5)
define tp record
-- documento integer,
 codser char(5),
 costo decimal(12,2),
 subsidio decimal(12,2),
 cantidad integer,
 iva decimal(12,2),
 total decimal(12,2)
end record
output
 top margin 1
 bottom margin 1
 left margin 0
 right margin 132
 page length 66
format
 page header
 print column 1,"fecha : ",today," + ",mtime,
       column 121,"Pag No. ",pageno using "####"
 skip 1 lines
 let mp1 = (132-length(mfc_empresa.razsoc clipped))/2
 print column mp1,mfc_empresa.razsoc
 print column 56,"MOVIMIENTO DE LOS SERVICIOS POR NOTAS DE ",mfecini," AL ",mfecfin
 skip 1 lines
 let mtitulo="MOVIMIENTO GENERAL PREFIJO ",mprefijo
 print column 01,mtitulo
 print "----------------------------------------------------------------------------",
       "----------------------------------------------------------------------------"
 print  column 01,"SERVICIO",
        column 60,"CAT",
        column 65,"CANTID",
        column 75,"  VAL TARIFA   ",
        COLUMN 95, "VAL SUBSIDIO ",  
        column 115,"  TOTAL IVA    ",
        column 135,"  VALOR TOTAL  "
       -- column 135,"# FACTURA"
 print "----------------------------------------------------------------------------",
       "----------------------------------------------------------------------------"

on every row
 initialize rec_servic.* to null
 select * into rec_servic.* from fc_servicios
  where codigo=tp.codser
 --LET tp.costo=nomredondea(tp.costo-(tp.iva/tp.cantidad)) 
 print  column 01,tp.codser,
        column 08,rec_servic.descripcion,
        column 65,tp.cantidad using "&&&&&&",
        column 75,tp.costo using "###,###,##&.&&",
        COLUMN 95,(tp.subsidio* tp.cantidad) using "###,###,##&.&&",
        column 115,tp.iva using "###,###,##&.&&",
        column 135,tp.total using "###,###,##&.&&"
        --column 135,tp.documento
 on last row
 skip 3 lines
 print  column 01,"TOTALES GENERAL ==> ",
        column 65,"______",
        column 95,"__________________",
        column 115,"__________________",
        column 135,"__________________"
 print  column 65,sum(tp.cantidad) using "&&&&&&",
        COLUMN 95,sum(tp.subsidio* tp.cantidad) using "###,###,##&.&&",
        column 115,sum(tp.iva) using "###,###,###,##&.&&",
        column 135,sum(tp.total) using "###,###,###,##&.&&"
 skip to top of page
end report

FUNCTION contabiliza_nota()
  INITIALIZE mfc_prefijos.* TO NULL
   SELECT * INTO mfc_prefijos.* FROM fc_prefijos
    WHERE fc_prefijos.prefijo = gfc_nota_m.prefijo
    CASE 
     WHEN gfc_nota_m.tipo_nota="2" OR gfc_nota_m.tipo_nota="3"
      OR gfc_nota_m.tipo_nota="4" OR gfc_nota_m.tipo_nota="5"
       CALL gen_comp_factura_n()
       CALL gen_comp_factura_s_n()
       CALL gen_comp_factura_b_n()
       UPDATE fc_factura_m SET estado ="N", fccest = TODAY
        WHERE prefijo = gfc_nota_m.prefijo 
         AND numfac = gfc_nota_m.numfac
      WHEN gfc_nota_m.tipo_nota="9"
        --CALL gen_comp_notad()
        --CALL gen_comp_notad_s()
         --CALL gen_comp_notad_b()
      END CASE
END FUNCTION

function aprueba_nota_2()
define ubicacion char(80)
DEFINE mtime char(8)
DEFINE mnumnota,x INTEGER
define mtotfacc like fc_nota_d.valoruni
define mtotivaa like fc_nota_d.iva
define mtotimpcc like fc_nota_d.impc
DEFINE mdepar char(2)
DEFINE op char(1)
LET cnt=0
SELECT count(*) INTO cnt FROM fc_nota_m
 WHERE fc_nota_m.tipo = gfc_nota_m.tipo
  AND fc_nota_m.documento = gfc_nota_m.documento
  AND fc_nota_m.estado="B"
 IF cnt IS NULL THEN LET cnt=0 END IF
 IF cnt=0 THEN
  MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
     comment= " La Nota no existe o ya fue Aprobada ",
      image= "exclamation")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
   return  
 END IF 
 LET cnt=0
 SELECT count(*) INTO cnt FROM fc_prefijos_usuu
  WHERE prefijo=gfc_nota_m.prefijo AND usu_autoriza=musuario
 IF cnt IS NULL THEN LET cnt=0 END IF
 IF cnt=0 THEN
  MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
    comment= " El usuario no puede Aprobar notas para este Prefijo ",
     image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
    END MENU
    return
 END IF
 LET mnumnota=NULL
 IF gfc_nota_m.tipo="ND" then
  select numnota_d into mnumnota from fc_empresa
 ELSE
  select numnota_c into mnumnota from fc_empresa
 END if 
 IF mnumnota IS NULL THEN LET mnumnota=1 END if
 LET cnt = 1
 LET x = mnumnota
 WHILE cnt <> 0
  SELECT COUNT(*) INTO cnt FROM fc_nota_m
   WHERE fc_nota_m.tipo = gfc_nota_m.tipo
     AND fc_nota_m.numnota = mnumnota
  IF cnt <> 0 THEN
   LET x = x + 1
   IF gfc_nota_m.tipo="ND" THEN
    UPDATE fc_empresa SET numnota_d=numnota_d+1
    LET mnumnota = x
   ELSE
    UPDATE fc_empresa SET numnota_c=numnota_c+1
    LET mnumnota = x
   END if 
  ELSE
   IF gfc_nota_m.tipo="ND" THEN
    UPDATE fc_empresa SET numnota_d=numnota_d+1
   ELSE
    UPDATE fc_empresa SET numnota_c=numnota_c+1
   END if  
   EXIT WHILE
  END IF
 END WHILE
 LET mtime=TIME
 UPDATE fc_nota_m SET numnota=mnumnota,fecha_nota=today,hora=mtime,estado="A",usuario_apru=musuario
 WHERE fc_nota_m.tipo = gfc_nota_m.tipo
  AND fc_nota_m.documento = gfc_nota_m.documento
  AND fc_nota_m.estado="B"
{ CALL act_totales_nota( gfc_nota_m.tipo, gfc_nota_m.documento) }
 IF gfc_nota_m.tipo = "NC" THEN
   CALL envio_documento("2",gfc_nota_m.tipo,mnumnota)
 ELSE 
   CALL envio_documento("3",gfc_nota_m.tipo,mnumnota)
 END IF 
END FUNCTION

FUNCTION genera_comprobante_notas()
 DEFINE mprefijo,m_prefijo char(5)
 DEFINE mtpnota char(2)
 DEFINE mdoo1,mdoo2,mfac INTEGER
-- DEFINE mdo1,mdo2,m_documento char(7)
 let mtpnota=NULL
 prompt "Tipo de Nota : ND - NC =====>> : " for mtpnota
 LET mtpnota= upshift(mtpnota)
 if mtpnota is null OR (mtpnota<>"ND" AND mtpnota<>"NC") THEN 
  RETURN
 end IF
 let mdoo1=null
 prompt "Número Nota Inicial =====>> : " for mdoo1
 if mdoo1 is null then 
  return
 end if
 let mdoo2=null
 prompt "Número Nota Final =====>> : " for mdoo2
 if mdoo2 is null then 
  return
 end if
 FOR mfac = mdoo1 TO mdoo2
 IF mtpnota ="NC" THEN
   CALL consulta_estado_documento_2("2",mtpnota, mfac)
 ELSE
   CALL consulta_estado_documento_2("3",mtpnota, mfac)
 END IF 
 LET cnt=0
  SELECT count(*) INTO cnt FROM fc_nota_m 
   WHERE fc_nota_m.tipo = mtpnota
   AND fc_nota_m.numnota=mfac
   AND fc_nota_m.estado = "P"
  IF cnt IS NULL THEN LET cnt=0 END IF
  IF cnt<>0 THEN
   INITIALIZE gfc_nota_m.* TO NULL
   INITIALIZE mfc_nota_m.* TO NULL
   SELECT * INTO mfc_nota_m.* 
     FROM fc_nota_m
      WHERE fc_nota_m .tipo = mtpnota
      AND fc_nota_m.numnota = mfac
    IF mfc_nota_m.codcop IS NULL OR mfc_nota_m.codcop ="" THEN   
     SELECT * INTO gfc_nota_m.* FROM fc_nota_m
      WHERE fc_nota_m.tipo = mtpnota AND fc_nota_m.numnota =  mfac 
     INITIALIZE mfc_prefijos.* TO NULL
     SELECT * INTO mfc_prefijos.* FROM fc_prefijos
      WHERE fc_prefijos.prefijo = gfc_nota_m.prefijo 
       DISPLAY "NOTA  ACONTABILIZAR ", gfc_nota_m.numnota
      CASE 
        WHEN gfc_nota_m.tipo_nota="2" OR gfc_nota_m.tipo_nota="3"
         OR gfc_nota_m.tipo_nota="4" OR gfc_nota_m.tipo_nota="5"
          CALL gen_comp_factura_n()
           let mdocini= mdocumento
           let mdocfin= mdocumento
           let mind=0
           DISPLAY "COMPROBANTE NOTA : ", mcodcop , " Documento : ", mdocumento
           CALL ini_mensaje_espera("Act comprobante Nota.....")
          { CALL niif141act()}
           CALL fin_mensaje_espera()
          CALL gen_comp_factura_s_n()
           let mdocini= mdocumento
           let mdocfin= mdocumento
           let mind=0
           DISPLAY "COMPROBANTE REVERSION SUBSIDIO : ", mcodcop , " Documento : ", mdocumento
           CALL ini_mensaje_espera("Act comprobante Reversion subsidio.....")
          { CALL niif141act()}
           CALL fin_mensaje_espera()
          CALL gen_comp_factura_b_n()
           let mdocini= mdocumento
           let mdocfin= mdocumento
           let mind=0
           DISPLAY "COMPROBANTE REVERSION BENEFICIO : ", mcodcop , " Documento : ", mdocumento
           CALL ini_mensaje_espera("Act comprobante Reversion beneficio.....")
          { CALL niif141act()}
           CALL fin_mensaje_espera()
        UPDATE fc_factura_m SET estado ="N", fccest = TODAY
          WHERE prefijo = gfc_nota_m.prefijo 
          AND numfac = gfc_nota_m.numfac
       WHEN gfc_nota_m.tipo_nota="9"
         --CALL gen_comp_notad()
         --CALL gen_comp_notad_s()
         --CALL gen_comp_notad_b()
    END CASE
    ELSE
      DISPLAY "LA NOTA ", mtpnota, "-", mfac, " YA ESTA CONTABILIZADA"  
  END IF  
    ELSE
     DISPLAY "LA NOTA ", mtpnota, "-", mfac, " NO EXISTE O NO HA SIDO TRAMSMITIDA EXITOSA"
  END if  
 END for
END function   

FUNCTION rep_notas_cont()
DEFINE handler om.SaxDocumentHandler
DEFINE nomrep char(100)
DEFINE mcodpun CHAR(2)
DEFINE cnt INTEGER
DEFINE opp CHAR(1)
 let ubicacion=fgl_getenv("HOME"),"/reportes/notas_cont"
 let ubicacion=ubicacion CLIPPED
 let tpmnota=NULL
 prompt "Digite ND - NC : " for tpmnota
 LET tpmnota= upshift(tpmnota)
 if tpmnota is null THEN 
  RETURN
 end IF
 let mprefijo=null
 prompt "Prefijo =====>> : " for mprefijo
 LET mprefijo= upshift(mprefijo)
 if mprefijo is null then 
  return
 end if
 LET mfecini = NULL
 LET mfecfin = NULL
 let mdeftit="    RELACION DE NOTAS "
 let mdefpro="Digite Rango de fechas" #23
 let mdeffec1=today
 let mdeffec2=today
 CALL confccr() RETURNING mfecini,mfecfin
 if mfecini is null or mfecfin is null then
   return
 end IF
 DISPLAY "" at 2,1
 DISPLAY "Trabajando ........................." at 2,1
   START REPORT norprec_cont TO "rep"
  DECLARE nocurrec_cont CURSOR FOR
  SELECT * FROM fc_nota_m
   WHERE fecha_nota between mfecini and mfecfin
    AND tipo = tpmnota
    AND prefijo = mprefijo
   ORDER BY tipo, documento
  FOREACH nocurrec_cont INTO mfc_nota_m.*
   initialize mfc_factura_m.* to null
   select * into mfc_factura_m.* from fc_factura_m 
    where prefijo=mfc_nota_m.prefijo and numfac=mfc_nota_m.numfac 
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
   OUTPUT TO REPORT norprec_cont()
  END FOREACH
 finish report norprec_cont
   let mdefnom="RELACION DE RECIBOS"
   let mdeflet="condensed"
   let mdeftam=66
   let mhoja="9.5x11"
   CALL manimp()
END FUNCTION

REPORT norprec_cont()
 OUTPUT
   top margin 3
   bottom  margin 8
   left  margin 0
   right margin 240
   page length 66
 format
  PAGE HEADER
  let mtime=TIME
  print column 1,"fecha : ",today," + ",mtime,
        column 121,"Pag No. ",pageno using "####"
 skip 1 LINES
 let mp1 = (132-length(mfc_empresa.razsoc clipped))/2
 print column mp1,mfc_empresa.razsoc
 let mp1 = (132-length("LISTADO GENERAL DE NOTAS TRANSMITIDAS"))/2
 print column mp1,"LISTADO GENERAL DE NOTAS TRANSMITIDAS"

 skip 1 LINES
 PRINT COLUMN 01, "TIPO DE NOTA  : ", tpmnota 
 PRINT COLUMN 01, "PREFIJO       : ", mprefijo 
 print "--------------------------------------------------------------------",
       "--------------------------------------------------------------------",
       "---------------------------"
  PRINT column 01,"NUM NOT",
        column 10,"N.INTER",
        column 20,"PREFI",
        column 26,"NUM FAC",
        column 36,"fecha.NOTA",
        Column 56,"TERCERO",
        Column 108,"COMPROBANTE",
        Column 128,"REVERSADA"
  print "--------------------------------------------------------------------",
        "--------------------------------------------------------------------",
        "---------------------------"
  on every ROW
   print COLUMN 01,mfc_nota_m.numnota USING "-------",
         COLUMN 10,mfc_nota_m.documento,
         column 20,mfc_nota_m.prefijo,
         column 26,mfc_nota_m.numfac USING "-------",
         column 36,mfc_nota_m.fecha_nota,
         column 56,mfc_factura_m.nit CLIPPED,"-",mnombre[1,30],
         Column 108,mfc_nota_m.codcop,"-",mfc_nota_m.docu,
         COLUMN 132,mfc_nota_m.reversada 
 ON LAST ROW      
    print "--------------------------------------------------------------------",
          "--------------------------------------------------------------------",
          "---------------------------" 
    skip to top of page
end REPORT
FUNCTION fc_nota_mremove()
 DEFINE answer CHAR(1)
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "ESTADO : RETIRO DE NOTAS " ATTRIBUTE(BLUE)
 PROMPT "Esta seguro de borrar el registro (s/n)? " FOR CHAR answer
 IF answer MATCHES "[Ss]" THEN
  IF gfc_nota_m.estado<>"B" THEN
   CALL FGL_WINMESSAGE( "Administrador", "LA NOTA NO ESTA EN ESTADO BORRADOR", "stop")
   LET answer="N"
  END if
 END IF
 IF answer MATCHES "[Ss]" THEN
  MESSAGE "RETIRANDO EL REGISTRO " ATTRIBUTE(BLUE)
  LET gerrflag = FALSE
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT 
  DELETE FROM fc_nota_m
    WHERE tipo = gfc_nota_m.tipo
      AND documento =  gfc_nota_m.documento
   IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro refcrenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
  DELETE FROM fc_nota_d
       WHERE tipo = gfc_nota_m.tipo
      AND documento =  gfc_nota_m.documento
  IF status <> 0 THEN
   MENU "Mensaje de Error"  ATTRIBUTE( style= "dialog", 
     comment= " No se elimino .. Registro refcrenciado    "  ,  image= "stop")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
    LET gerrflag = TRUE
  END IF
  
  IF NOT gerrflag THEN 
   INITIALIZE gfc_nota_m.* TO NULL
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


