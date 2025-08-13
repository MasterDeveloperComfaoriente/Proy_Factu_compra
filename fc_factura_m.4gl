GLOBALS "fe_globales.4gl"

DEFINE gfactura_m,tpfe_factura_m RECORD
  prefijo             LIKE fe_factura_m.prefijo,
  documento           LIKE fe_factura_m.documento,
  numfac              LIKE fe_factura_m.numfac,
  fecha_factura       LIKE fe_factura_m.fecha_factura,
  estado              LIKE fe_factura_m.estado
END RECORD
DEFINE gtfe_factura_ter, tfe_factura_ter ARRAY[100] OF RECORD 
  cedula             LIKE fe_factura_ter.cedula,
  nombre             LIKE fe_factura_ter.nombre,
  edad               LIKE fe_factura_ter.edad,
  sexo               LIKE fe_factura_ter.sexo,
  cat                LIKE fe_factura_ter.cat,
  valor              LIKE fe_factura_ter.valor
END RECORD

DEFINE medad DECIMAL(14,6)
DEFINE msubsi21 RECORD LIKE subsi21.*
DEFINE msubsi23 RECORD LIKE subsi23.*
DEFINE mcat char(1)
DEFINE msubsi20 RECORD LIKE subsi20.*
DEFINE msubsi22 RECORD LIKE subsi22.*
DEFINE mced char(1)

FUNCTION factura_reng_termain()
DEFINE exist,ttlrow SMALLINT
DEFINE combestado ui.ComboBox
DEFINE combsexo ui.ComboBox
DEFINE combcat ui.ComboBox
OPEN WINDOW w_mfactura_m_reng AT 1,1 WITH FORM "fe_factura_m"
 LET glastline = 23
 LET exist = FALSE
 LET gmaxdply = 9
 LET gmaxarray = 100
 INITIALIZE gfactura_m.* TO NULL
 INITIALIZE tpfe_factura_m.* TO NULL
   LET combestado = ui.ComboBox.forName("fe_factura_m.estado")
   CALL combestado.clear()
   CALL combestado.addItem("B","BORRADOR")
   CALL combestado.addItem("P","PROCESADO CON EXITO")
   CALL combestado.addItem("A","APROBADA")
   CALL combestado.addItem("R","RECHAZADA CLIENTE")
   CALL combestado.addItem("N","ANULADA POR NOTAC")
   CALL combestado.addItem("D","RECHAZADA DIAN")
   CALL combestado.addItem("X","ANULADA MANUAL")
   CALL factura_reng_terinitga()
   LET combsexo  = ui.ComboBox.forName("fe_factura_ter.sexo")
   CALL combsexo.clear()
   CALL combsexo.addItem("F", "F")
   CALL combsexo.addItem("M", "M")
   LET combcat  = ui.ComboBox.forName("fe_factura_ter.cat")
   CALL combcat.clear()
   CALL combcat.addItem("A", "A")
   CALL combcat.addItem("B", "B")
   CALL combcat.addItem("C", "C")
   CALL combcat.addItem("D", "D")
 
 MENU "FACTURA"
  COMMAND "Consulta" "Consulta las facturas adicionadas"
    CALL fact_reng_ter_mquery( exist ) RETURNING exist
    IF int_flag THEN
     LET int_flag = FALSE
    ELSE
     CLEAR FORM
    END IF

  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 10
   EXIT MENU
 END MENU
 CLOSE WINDOW w_mfactura_m_reng
END FUNCTION

FUNCTION factura_reng_terinitga()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE gtfe_factura_ter[x].* TO NULL
 END FOR
END FUNCTION

FUNCTION fact_reng_ter_mdetail()
 DEFINE x SMALLINT
 DISPLAY BY NAME gfactura_m.prefijo THRU gfactura_m.estado
 FOR x = 1 TO gmaxdply
  DISPLAY gtfe_factura_ter[x].* TO tb_factura_ter[x].*
 END FOR
END FUNCTION

FUNCTION factura_mgetdetail()
 DEFINE x SMALLINT
CALL factura_reng_terinitga()
 DECLARE c_gfactura_m CURSOR FOR
  SELECT cedula,nombre,edad,sexo,cat,valor
   FROM fe_factura_ter
   WHERE  prefijo = gfactura_m.prefijo
     AND  documento = gfactura_m.documento
   ORDER BY fe_factura_ter.cedula ASC
 LET x = 1
 FOREACH c_gfactura_m INTO gtfe_factura_ter[x].*
  LET x = x + 1
  IF x > gmaxarray THEN
   EXIT FOREACH
  END IF
 END FOREACH
END FUNCTION

FUNCTION factura_mgetcurr( tpprefijo, tpdocumento )
 DEFINE tpprefijo LIKE fe_factura_m.prefijo
 DEFINE tpdocumento LIKE fe_factura_m.documento
 INITIALIZE gfactura_m.* TO NULL
 SELECT fe_factura_m.prefijo, fe_factura_m.documento, fe_factura_m.numfac,
        fe_factura_m.fecha_factura,fe_factura_m.estado
 INTO gfactura_m.* FROM fe_factura_m
  WHERE fe_factura_m.prefijo = tpprefijo AND
        fe_factura_m.documento = tpdocumento
 INITIALIZE mfe_factura_m.* TO NULL
 SELECT * INTO mfe_factura_m.* FROM fe_factura_m
  WHERE fe_factura_m.prefijo = tpprefijo AND
        fe_factura_m.documento = tpdocumento
 INITIALIZE mfe_terceros.* TO NULL
 SELECT * INTO mfe_terceros.* FROM fe_terceros
  WHERE nit = mfe_factura_m.nit 
 CALL factura_mgetdetail()
END FUNCTION

FUNCTION factura_mshowcurr( rownum, maxnum )
 DEFINE rownum, maxnum  INTEGER
 DISPLAY "" AT glastline,1
 IF gfactura_m.prefijo IS NULL AND gfactura_m.documento IS NULL THEN
  MESSAGE  "Localizacion : ( Actual ", rownum, "/ Existen ", maxnum,") Borrado" --AT glastline,33
 ELSE
  MESSAGE  "Localizacion : ( Actual ", rownum,"/ Existen ", maxnum, ")" --AT glastline,1
 END IF
 CALL fact_reng_ter_mdetail()
END FUNCTION

FUNCTION fact_reng_ter_mquery( exist )
 DEFINE exist, curr, cnt       integer, 
  tpprefijo              LIKE fe_factura_m.prefijo,
  tpdocumento            LIKE fe_factura_m.documento,
  where_info, query_text CHAR(400)

 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 DISPLAY "" AT 1,1
 MESSAGE  "Estado : CONSULTA DE FACTURAS" --ATTRIBUTE(BLUE) 
 CLEAR FORM
 CONSTRUCT where_info
  ON  prefijo, documento, numfac,fecha_factura,estado
  FROM  prefijo, documento, numfac,fecha_factura,estado
 IF int_flag THEN
  MENU "Información"  ATTRIBUTE( style= "dialog", 
                             comment= " La consulta fue cancelada",
                             image= "information")
       COMMAND "Aceptar"
         EXIT MENU
     END MENU
  RETURN exist
 END IF
 DISPLAY "Buscando la factura(s), por favor espere ..." AT 2,1
 LET query_text = " SELECT fe_factura_m.prefijo,fe_factura_m.documento",
                  " FROM fe_factura_m WHERE ", where_info CLIPPED,
                  " ORDER BY fe_factura_m.prefijo,fe_factura_m.documento ASC"
 DISPLAY "consulta ", query_text ," ",WHERE_info 
 PREPARE s_sfactura_reng_ter FROM query_text
 DECLARE c_sfactura_reng_ter SCROLL CURSOR FOR s_sfactura_reng_ter
 LET cnt = 0
 FOREACH c_sfactura_reng_ter INTO tpprefijo,tpdocumento
  LET cnt = cnt + 1
 END FOREACH
 IF ( cnt > 0 ) THEN
  OPEN c_sfactura_reng_ter
  FETCH FIRST c_sfactura_reng_ter INTO tpprefijo,tpdocumento
  LET curr = 1
  CALL factura_mgetcurr( tpprefijo,tpdocumento )
  CALL factura_mshowcurr( curr, cnt )
 ELSE
   MENU "Mensaje de Error" ATTRIBUTE( style= "dialog", 
   comment= " LA FACTURA NO EXISTE", image= "exclamation")
      COMMAND "Aceptar"
        EXIT MENU
  END MENU
  LET int_flag = TRUE
  RETURN exist
 END IF
 MESSAGE "" 
 LET gerrflag = FALSE 
 MENU ":"
  COMMAND "Primero" "Desplaza al primer factura en consulta"
   HELP 5
   FETCH FIRST c_sfactura_reng_ter INTO tpprefijo,tpdocumento
   LET curr = 1
   CALL factura_mgetcurr( tpprefijo,tpdocumento )
   CALL factura_mshowcurr( curr, cnt )
  COMMAND "Ultimo" "Desplaza al ultimo factura en consulta"
   HELP 6
   FETCH LAST c_sfactura_reng_ter INTO tpprefijo,tpdocumento
   LET curr = cnt
   CALL factura_mgetcurr( tpprefijo,tpdocumento )
   CALL factura_mshowcurr( curr, cnt )
  COMMAND "Inmediato" "Se desplaza al sigiente factura en consulta"
   HELP 7
   IF ( curr = cnt ) THEN
    FETCH FIRST c_sfactura_reng_ter INTO tpprefijo,tpdocumento
    LET curr = 1
   ELSE
    FETCH NEXT c_sfactura_reng_ter INTO tpprefijo,tpdocumento
    LET curr = curr + 1
   END IF
   CALL factura_mgetcurr( tpprefijo,tpdocumento )
   CALL factura_mshowcurr( curr, cnt )
  COMMAND "Anterior" "Se desplaza al factura anterior"
   HELP 8
   IF ( curr = 1 ) THEN
    FETCH LAST c_sfactura_reng_ter INTO tpprefijo,tpdocumento
    LET curr = cnt
   ELSE
    FETCH PREVIOUS c_sfactura_reng_ter INTO tpprefijo,tpdocumento
    LET curr = curr - 1
   END IF
   CALL factura_mgetcurr( tpprefijo,tpdocumento )
   CALL factura_mshowcurr( curr, cnt )
   COMMAND "Modifica" "Modifica la Factura"
    IF gfactura_m.documento IS NULL THEN
     CONTINUE MENU
    ELSE
     CLOSE c_sfactura_reng_ter
     CALL factura_mupdate()
     IF int_flag THEN
      LET int_flag = FALSE
     END IF
    CALL factura_mgetcurr( tpprefijo,tpdocumento )
    CALL factura_mshowcurr( curr, cnt )
     OPEN c_sfactura_reng_ter
   END IF

  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 10
   IF  gfactura_m.prefijo IS NULL AND gfactura_m.documento IS NULL THEN
    LET exist = FALSE
   ELSE
    LET exist = TRUE
   END IF
   EXIT MENU
 END MENU
 CLOSE c_sfactura_reng_ter
 RETURN exist
END FUNCTION

FUNCTION factura_minitta()
 DEFINE x SMALLINT
 FOR x = 1 TO gmaxarray
  INITIALIZE tfe_factura_ter[x].* TO NULL
 END FOR
END FUNCTION

FUNCTION factura_mdetail()
 DEFINE x SMALLINT
 DISPLAY BY NAME gfactura_m.prefijo THRU gfactura_m.estado
 FOR x = 1 TO gmaxdply
  DISPLAY gtfe_factura_ter[x].* TO tb_factura_ter[x].*
 END FOR
END FUNCTION

FUNCTION factura_mrownull( x )
 DEFINE x, rownull SMALLINT
 LET rownull = TRUE
 IF tfe_factura_ter[x].cedula IS NOT NULL AND
    tfe_factura_ter[x].nombre  IS NOT NULL AND
    tfe_factura_ter[x].edad IS NOT NULL AND
    tfe_factura_ter[x].sexo  IS NOT NULL AND
    tfe_factura_ter[x].cat  IS NOT NULL AND
    tfe_factura_ter[x].valor  IS NOT NULL THEN
    LET rownull = FALSE
 END IF
 RETURN rownull
END FUNCTION

FUNCTION factura_mupdate()
 DEFINE  cnt, x, rownull,toggle, ttlrow SMALLINT
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 MESSAGE "Estado : MODIFICACIÓN DE COBERTURA DE FACTURAS" 
 INITIALIZE tpfe_factura_m.* TO NULL
 CALL factura_minitta()
 LET tpfe_factura_m.* = gfactura_m.*
 LET ttlrow = 1
 FOR x = 1 TO gmaxarray
  LET tfe_factura_ter[x].* = gtfe_factura_ter[x].*
  CALL factura_mrownull( x ) RETURNING rownull
  IF NOT rownull THEN
   INITIALIZE tfe_factura_ter[x].* TO NULL
   LET tfe_factura_ter[ttlrow].* = gtfe_factura_ter[x].*
   LET ttlrow = ttlrow + 1
  ELSE
   EXIT FOR
  END IF
 END FOR
 LET ttlrow = ttlrow - 1
 LABEL fe_factura_mtog1:
 LET toggle = FALSE
 IF int_flag THEN 
    LET int_flag = FALSE
 END IF
 LET cnt=0
 SELECT count(*) INTO cnt FROM fe_prefijos_usu
  WHERE prefijo=tpfe_factura_m.prefijo AND usu_elabora=musuario
 --IF cnt IS NULL THEN LET cnt=0 END IF
 --IF cnt=0 THEN
 -- CALL FGL_WINMESSAGE( "Administrador", " EL USUARIO NO ESTA AUTORIZADO PARA MODIFICAR FACTURAS DE ESTE PREFIJO","information") 
 -- RETURN
 --END if 
INPUT BY NAME tpfe_factura_m.numfac THRU tpfe_factura_m.estado WITHOUT DEFAULTS
  AFTER FIELD estado
   IF tpfe_factura_m.estado IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL ESTADO DE LA FACTURA NO FUE DIGITADO  ", "stop")
    NEXT FIELD estado
   ELSE
    if tpfe_factura_m.estado<>"B" THEN
     CALL FGL_WINMESSAGE( "Administrador", " EL ESTADO DE LA FACTURA DEBE SER BORRADOR  ", "stop")
     NEXT FIELD estado
    END IF 
   END IF
  ON ACTION bt_detalle
   IF tpfe_factura_m.prefijo IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL PREFIJO NO FUE DIGITADO   ", "stop")
    NEXT FIELD prefijo
   END IF
   IF tpfe_factura_m.documento IS NULL THEN
    CALL FGL_WINMESSAGE( "Administrador", " EL NUMERO INTERNO NO FUE DIGITADO   ", "stop")
    NEXT FIELD documento
   END IF
   LET toggle = TRUE
  EXIT INPUT

  AFTER INPUT
   IF int_flag THEN
     EXIT INPUT
   END IF
 END INPUT
 IF int_flag THEN
  CLEAR FORM
  DISPLAY "" AT 1,10
  CALL FGL_WINMESSAGE( "Administrador", "LA MODIFICACION FUE CANCELADA", "exclamation")
  INITIALIZE tpfe_factura_m.* TO NULL
  CALL factura_minitta()
  RETURN
 END IF
 IF toggle THEN
  LET toggle = FALSE
  for l=gmaxarray to 1 step -1
   if tfe_factura_ter[l].cedula  is not null then
    let ttlrow=l
    exit for
   end IF
  END FOR
CALL SET_COUNT( ttlrow )
INPUT ARRAY tfe_factura_ter WITHOUT DEFAULTS FROM tb_factura_ter.*

AFTER FIELD cedula
  LET mced = NULL  
  LET y = ARR_CURR()
  LET z = SCR_LINE()   
  IF tfe_factura_ter[y].cedula IS null then
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
        comment= " No se ingresado el numero de documento", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
        END MENU
       --NEXT FIELD cedula
  ELSE
    LET cnt=0
    SELECT count(*) INTO cnt FROM subsi15
     WHERE cedtra=mfe_factura_m.nit
     AND estado ="A"
     IF cnt IS NULL THEN LET cnt=0 END IF
     IF cnt=0 THEN
        LET cnt=0
        SELECT count(*) INTO cnt FROM subsi20, subsi21, subsi15
         WHERE subsi21.cedcon=mfe_factura_m.nit 
         AND subsi21.cedtra = subsi15.cedtra
         AND subsi20.cedcon = subsi21.cedcon
         AND subsi15.estado = "A"
         AND subsi20.estado="A"
        IF cnt IS NULL THEN LET cnt=0 END IF
        IF cnt>0 THEN
          LET mced="C"
        ELSE
          LET cnt=0
          SELECT count(*) INTO cnt FROM subsi22
          WHERE documento=mfe_factura_m.nit AND estado="A"
          IF cnt IS NULL THEN LET cnt=0 END IF
          IF cnt<>0 THEN
            LET mced="B" 
          END IF
        END IF
     ELSE
       LET mced = "N"
     END IF
   IF mfe_terceros.tipo_persona="2" THEN
     CASE 
       WHEN mced ="N"
         INITIALIZE msubsi15.* TO NULL
         SELECT * INTO msubsi15.* FROM subsi15
         where cedtra = tfe_factura_ter[y].cedula
          AND estado = "A"
         IF msubsi15.cedtra IS NOT NULL THEN
           LET tfe_factura_ter[y].cat = mcodcat
           DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat
           lET tfe_factura_ter[y].nombre = msubsi15.priape clipped, " ", msubsi15.segape clipped , " ",msubsi15.nombre CLIPPED
           DISPLAY tfe_factura_ter[y].nombre to tb_factura_ter[z].nombre
           LET tfe_factura_ter[y].sexo = msubsi15.sexo
           DISPLAY tfe_factura_ter[y].sexo to tb_factura_ter[z].sexo
           let medad=0
           let medad=today-msubsi15.fecnac
           let medad=medad/(365.25)
           LET tfe_factura_ter[y].edad = medad
           DISPLAY tfe_factura_ter[y].edad to tb_factura_ter[z].edad
        ELSE 
         INITIALIZE msubsi20.* TO NULL
         SELECT * INTO msubsi20.* FROM subsi20
          where cedcon = tfe_factura_ter[y].cedula
         IF msubsi20.cedcon IS NOT NULL THEN
            LET tfe_factura_ter[y].cat = mcodcat
            DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat   
            INITIALIZE msubsi21.* TO NULL
            SELECT * INTO msubsi21.* FROM subsi21
             WHERE cedtra=mfe_factura_m.nit
             and cedcon = tfe_factura_ter[y].cedula 
          IF msubsi21.cedcon IS NULL THEN
            INITIALIZE msubsi22.* TO NULL
            SELECT * INTO msubsi22.* FROM subsi22
            where documento = tfe_factura_ter[y].cedula
            IF msubsi22.documento IS NOT NULL THEN
              LET tfe_factura_ter[y].cat = mcodcat
              DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat     
              INITIALIZE msubsi23.* TO NULL
              SELECT * INTO msubsi23.* FROM subsi23
               WHERE cedtra=mfe_factura_m.nit
                and codben = msubsi22.codben 
              IF msubsi23.codben IS NULL THEN
                 MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
                 comment= " La Cedula del Conyuge No corresponde al Trabajador", image= "exclamation")
                 COMMAND "Aceptar"
                   EXIT MENU
                  END MENU
                  NEXT FIELD cedula
              ELSE
                LET tfe_factura_ter[y].nombre = msubsi22.priape clipped, " ", msubsi22.segape clipped , " ",msubsi22.nombre CLIPPED
                DISPLAY tfe_factura_ter[y].nombre to tb_factura_ter[z].nombre
                LET tfe_factura_ter[y].sexo = msubsi22.sexo
                DISPLAY tfe_factura_ter[y].sexo to tb_factura_ter[z].sexo
                let medad=0
                let medad=today-msubsi22.fecnac
                let medad=medad/(365.25)
                LET tfe_factura_ter[y].edad = medad
                DISPLAY tfe_factura_ter[y].edad to tb_factura_ter[z].edad
                IF msubsi22.parent ="1" AND medad >= 19 THEN
                   LET tfe_factura_ter[y].cat = "D"
                   DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat
                END IF    
              END IF 
            END IF
          ELSE 
             LET tfe_factura_ter[y].nombre = msubsi20.priape clipped, " ", msubsi20.segape clipped , " ",msubsi20.nombre CLIPPED
             DISPLAY tfe_factura_ter[y].nombre to tb_factura_ter[z].nombre
             LET tfe_factura_ter[y].sexo = msubsi20.sexo
             DISPLAY tfe_factura_ter[y].sexo to tb_factura_ter[z].sexo
             let medad=0
             let medad=today-msubsi20.fecnac
             let medad=medad/(365.25)
             LET tfe_factura_ter[y].edad = medad
             DISPLAY tfe_factura_ter[y].edad to tb_factura_ter[z].edad
          END IF
        ELSE
         INITIALIZE msubsi22.* TO NULL
         SELECT * INTO msubsi22.* FROM subsi22
         where documento = tfe_factura_ter[y].cedula
         IF msubsi22.documento IS NOT NULL THEN
            LET tfe_factura_ter[y].cat = mcodcat
            DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat
            let medad=0
            let medad=today-msubsi22.fecnac
            let medad=medad/(365.25)
            LET tfe_factura_ter[y].edad = medad
            IF msubsi22.parent ="1" AND medad >= 19 THEN
              LET tfe_factura_ter[y].cat = "D"
              DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat
            END IF    
            INITIALIZE msubsi23.* TO NULL
            SELECT * INTO msubsi23.* FROM subsi23
             WHERE cedtra=mfe_factura_m.nit
             and codben = msubsi22.codben 
            IF msubsi23.codben IS NULL THEN
              LET tfe_factura_ter[y].cat = "D"
              DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat
               {MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
               comment= " El Documento de la Persona a Cargo No corresponde al Trabajador", image= "exclamation")
               COMMAND "Aceptar"
                  EXIT MENU
               END MENU
               NEXT FIELD cedula}
             END IF    
             LET tfe_factura_ter[y].nombre = msubsi22.priape clipped, " ", msubsi22.segape clipped , " ",msubsi22.nombre CLIPPED
             DISPLAY tfe_factura_ter[y].nombre to tb_factura_ter[z].nombre
             LET tfe_factura_ter[y].sexo = msubsi22.sexo
             DISPLAY tfe_factura_ter[y].sexo to tb_factura_ter[z].sexo
             let medad=0
             let medad=today-msubsi22.fecnac
             let medad=medad/(365.25)
             LET tfe_factura_ter[y].edad = medad
             DISPLAY tfe_factura_ter[y].edad to tb_factura_ter[z].edad
             IF msubsi22.parent ="1" AND medad >= 19 THEN
                LET tfe_factura_ter[y].cat = "D"
                DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat
             END IF
          ELSE
            LET tfe_factura_ter[y].cat = "D"
            DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat
          END IF
        END IF 
      END IF
    WHEN mced ="C"
      INITIALIZE msubsi20.* TO NULL
      SELECT * INTO msubsi20.* FROM subsi20
       where cedcon = tfe_factura_ter[y].cedula
       IF msubsi20.cedcon IS NOT NULL THEN
         LET tfe_factura_ter[y].cat = mcodcat
         DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat   
         INITIALIZE msubsi21.* TO NULL
         SELECT * INTO msubsi21.* FROM subsi21
          WHERE cedtra=mfe_factura_m.cedtra
           and cedcon = tfe_factura_ter[y].cedula 
         IF msubsi21.cedcon IS NULL THEN
           MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
            comment= " La Cedula del Conyuge No corresponde al Trabajador", image= "exclamation")
             COMMAND "Aceptar"
               EXIT MENU
             END MENU
            NEXT FIELD cedula
          ELSE
           LET tfe_factura_ter[y].nombre = msubsi20.priape clipped, " ", msubsi20.segape clipped , " ",msubsi20.nombre CLIPPED
           DISPLAY tfe_factura_ter[y].nombre to tb_factura_ter[z].nombre
           LET tfe_factura_ter[y].sexo = msubsi20.sexo
           DISPLAY tfe_factura_ter[y].sexo to tb_factura_ter[z].sexo
           let medad=0
           let medad=today-msubsi20.fecnac
           let medad=medad/(365.25)
           LET tfe_factura_ter[y].edad = medad
           DISPLAY tfe_factura_ter[y].edad to tb_factura_ter[z].edad
          END IF
        ELSE
          LET tfe_factura_ter[y].cat = "D"
          DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat
        END IF
    WHEN mced ="B"
      INITIALIZE msubsi22.* TO NULL
      SELECT * INTO msubsi22.* FROM subsi22
      where documento = tfe_factura_ter[y].cedula
      IF msubsi22.documento IS NOT NULL THEN
        LET tfe_factura_ter[y].cat = mcodcat
        DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat     
        INITIALIZE msubsi23.* TO NULL
        SELECT * INTO msubsi23.* FROM subsi23
        WHERE cedtra=mfe_factura_m.cedtra
        and codben = msubsi22.codben 
        IF msubsi23.codben IS NULL THEN
          MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
          comment= " El beneficiario no corresponde al Trabajador", image= "exclamation")
           COMMAND "Aceptar"
             EXIT MENU
           END MENU
          NEXT FIELD cedula
        ELSE
         LET tfe_factura_ter[y].nombre = msubsi22.priape clipped, " ", msubsi22.segape clipped , " ",msubsi22.nombre CLIPPED
         DISPLAY tfe_factura_ter[y].nombre to tb_factura_ter[z].nombre
         LET tfe_factura_ter[y].sexo = msubsi22.sexo
         DISPLAY tfe_factura_ter[y].sexo to tb_factura_ter[z].sexo
         let medad=0
         let medad=today-msubsi22.fecnac
         let medad=medad/(365.25)
         LET tfe_factura_ter[y].edad = medad
         DISPLAY tfe_factura_ter[y].edad to tb_factura_ter[z].edad
         IF msubsi22.parent ="1" then 
          LET cnt=0
          --SELECT count(*) INTO cnt FROM fe_servicios_excentos
          -- WHERE codigo=tafe_factura_m[y].codigo
          IF cnt IS NULL THEN LET cnt=0 END IF
          IF cnt=0 THEN
           IF medad >= 19 THEN
            LET tfe_factura_ter[y].cat = "D"
            DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat
           END IF
          ELSE
           IF medad >= 24 THEN
            LET tfe_factura_ter[y].cat = "D"
            DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat
           END IF
          END if 
         END IF
        END IF     
      ELSE 
        LET tfe_factura_ter[y].cat = "D"
        DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat
      END IF
    OTHERWISE
      LET tfe_factura_ter[y].cat = "D"
      DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat
  END CASE
 ELSE
    LET cnt=0
     SELECT count(*) INTO cnt FROM subsi15
      WHERE cedtra=tfe_factura_ter[y].cedula
     IF cnt IS NULL THEN LET cnt=0 END IF
     IF cnt=0 THEN
      LET tfe_factura_ter[y].cat = "D"
      DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat     
     ELSE 
      INITIALIZE msubsi15.* TO NULL
      SELECT * INTO msubsi15.* FROM subsi15
       where cedtra = tfe_factura_ter[y].cedula
      initialize msubsi12.* to NULL
     select * into msubsi12.* from subsi12
       where today between fecini and fecfin
      let mpersal=NULL
      select max(periodo) into mpersal from subsi10
      where cedtra=tfe_factura_ter[y].cedula and suebas>0
      AND hortra >= 96  -- incluido para no tomar fracciones de salario
      if mpersal is not null THEN
        let msalario=NULL
        select sum(suebas) into msalario from subsi10
         where cedtra=tfe_factura_ter[y].cedula and periodo=mpersal
        if msalario is null then let msalario=0 end IF
        let mcansal=msalario/msubsi12.salmin
       ELSE
        initialize msubsi17.* to NULL
        DECLARE ns17 CURSOR FOR
        SELECT * FROM subsi17
         where cedtra=tfe_factura_ter[y].cedula ORDER BY fecha DESC
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
       LET tfe_factura_ter[y].cat = mcat
       DISPLAY tfe_factura_ter[y].cat to tb_factura_ter[z].cat
       LET tfe_factura_ter[y].nombre = msubsi15.priape clipped, " ", msubsi15.segape clipped , " ",msubsi15.nombre CLIPPED
       DISPLAY tfe_factura_ter[y].nombre to tb_factura_ter[z].nombre
       LET tfe_factura_ter[y].sexo = msubsi15.sexo
       DISPLAY tfe_factura_ter[y].sexo to tb_factura_ter[z].sexo
       let medad=0
       let medad=today-msubsi15.fecnac
       let medad=medad/(365.25)
       LET tfe_factura_ter[y].edad = medad
       DISPLAY tfe_factura_ter[y].edad to tb_factura_ter[z].edad
      END IF  
  END IF
END IF
  AFTER FIELD nombre
    LET y = ARR_CURR()
    LET z = SCR_LINE()    
    IF tfe_factura_ter[y].nombre IS NULL AND tfe_factura_ter[y].cedula is not null then
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
    IF tfe_factura_ter[y].edad IS NULL AND tfe_factura_ter[y].cedula is not null then
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
    IF tfe_factura_ter[y].sexo IS NULL AND tfe_factura_ter[y].cedula is not null then
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
    IF tfe_factura_ter[y].valor IS NULL AND tfe_factura_ter[y].cedula is not null then
     MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
        comment= " EL Valor del Beneficio no ha sido digitado", image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
        END MENU
       NEXT FIELD valor
   END IF
   ON ACTION bt_detalle
      LET ttlrow = ARR_COUNT()
      LET int_flag = FALSE
      LET toggle = TRUE
      EXIT INPUT
END INPUT
 IF toggle THEN
   GOTO fe_factura_mtog1
 END IF
 IF int_flag THEN
   CLEAR FORM
   CALL FGL_WINMESSAGE( "Administrador", "LA MODIFICACION FUE CANCELADA", "information")
   INITIALIZE tpfe_factura_m.* TO NULL
   CALL factura_minitta() 
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
  DELETE FROM fe_factura_ter  
   WHERE prefijo = gfactura_m.prefijo 
     AND documento =  gfactura_m.documento
  IF status < 0 THEN
   LET gerrflag = TRUE
  END IF
 END IF
  IF status < 0 THEN
   LET gerrflag = TRUE
  ELSE
   FOR x = 1 TO gmaxarray
    CALL factura_mrownull( x ) RETURNING rownull
    IF NOT rownull THEN
     INSERT INTO fe_factura_ter (  cedula, nombre, edad, sexo, cat, valor, prefijo, documento  )
      VALUES ( tfe_factura_ter[x].cedula, 
             tfe_factura_ter[x].nombre, 
             tfe_factura_ter[x].edad, 
             tfe_factura_ter[x].sexo, 
             tfe_factura_ter[x].cat,
             tfe_factura_ter[x].valor,
             tpfe_factura_m.prefijo ,tpfe_factura_m.documento )
     IF status < 0 THEN
      LET gerrflag = TRUE
      EXIT FOR
     END IF
    END IF
   END FOR
 END IF
 message "                                                        "
 INITIALIZE tpfe_factura_m.* TO NULL
 LET gfactura_m.* = tpfe_factura_m.*
 IF NOT gerrflag THEN
  COMMIT WORK
  LET cnt = 1
  FOR x = 1 TO gmaxarray
   INITIALIZE gtfe_factura_ter[x].* TO NULL
   CALL factura_mrownull( x ) RETURNING rownull
   IF NOT rownull THEN
    LET gtfe_factura_ter[cnt].* = tfe_factura_ter[x].*
    LET cnt = cnt + 1
   END IF
  END FOR
  CALL fact_reng_ter_mdetail()         
  CALL FGL_WINMESSAGE( "Administrador", "EL DETALLE DE LA FACTURA FUE ACTUALIZADO", "information")
 ELSE
  ROLLBACK WORK
  CALL FGL_WINMESSAGE( "Administrador", "LA MODIFICACION FUE CANCELADA", "information") 
 END IF
 SLEEP 1
   
END function 
  


