IMPORT security
DATABASE empresa
GLOBALS "fc_globales.4gl"
DEFINE lr_tipfun LIKE gener02.tipfun
FUNCTION reestablecer_contraseña ()
DEFINE cedtra CHAR (20)
DEFINE cont INTEGER 
DEFINE usuario,clave1,clave2, clave_encriptada VARCHAR (120)
DEFINE fechafin,ld_fecha_fin DATE 
DEFINE clave_antigua LIKE gener02.clave

OPEN WINDOW w_rescla AT 1,1 WITH FORM "fc_reestablecer_clave"
IF int_flag  THEN
    LET int_flag = FALSE
END IF 
CLEAR FORM 
INPUT BY NAME cedtra,usuario,clave1,clave2 ---ATTRIBUTES (ACCEPT = FALSE)
AFTER FIELD cedtra 
    IF cedtra IS NULL THEN
        CALL fgl_winmessage ("Administrador","Debe Ingresar la cédula del usuario","stop")
        NEXT FIELD cedtra
    ELSE
        LET cont = 0
        LET cedtra = cedtra CLIPPED 
        SELECT COUNT(*),tipfun INTO cont,lr_tipfun  FROM gener02
        WHERE gener02.cedtra = cedtra
        GROUP BY 2
        SELECT MAX(acceso_esp_usuarios.fec_fin) INTO ld_fecha_fin FROM acceso_esp_usuarios
        WHERE acceso_esp_usuarios.usuario = usuario
        
        IF ld_fecha_fin <= TODAY THEN
            IF lr_tipfun <>"REVI" THEN 
                IF cont = 0 THEN
                    CALL fgl_winmessage ("Administrador","El usuario de cedula "||cedtra CLIPPED||" no existe","stop")
                    NEXT FIELD cedtra
                ELSE
                    LET cont = 0
                    SELECT COUNT(*) INTO cont FROM nomin02
                    WHERE nomin02.docemp = cedtra
                    AND nomin02.estado = "A"
                    IF cont > 0 THEN
                        SELECT nomin02.fecter INTO fechafin FROM nomin02
                        WHERE nomin02.docemp = cedtra 
                        IF fechafin <= TODAY THEN
                            CALL fgl_winmessage("Administrador","Ya su contrato expiró, por favor comuniquese con Talento Humano para actualizar su información Laboral","stop")
                            NEXT FIELD cedtra
                        END IF 
                    ELSE
                        LET cont = 0
                        SELECT COUNT(*) INTO cont from ct_proveedores
                        where ct_proveedores.estado = "A"
                        AND (ct_proveedores.nit = cedtra OR ct_proveedores.cedrep = cedtra)

                        IF cont > 0 THEN
                            SELECT COUNT(*) INTO cont from ct_proveedores, ct_contrato
                            where ct_proveedores.nit = ct_contrato.nit_contratista
                            and ct_proveedores.estado = "A"
                            and ct_contrato.fecha_fin >= TODAY
                            AND (ct_proveedores.nit = cedtra OR ct_proveedores.cedrep = cedtra)
                            IF cont < 1 THEN
                                CALL fgl_winmessage("Administrador","Señor contratista su contrato ya no esta vigente, por favor comuniquese con Talento Humano para actualizar su información contractual","stop")
                                NEXT FIELD cedtra
                            END IF 
                        ELSE
                            LET cont = 0
                            SELECT COUNT(*) INTO cont FROM nom_mision
                            WHERE nom_mision.documento = cedtra  
                            IF cont > 0 THEN
                                SELECT fecterm INTO fechafin FROM nom_mision
                                WHERE nom_mision.documento = cedtra
                                IF fechafin <= TODAY THEN
                                    CALL fgl_winmessage("Administrador","Estimado funcionario su contrato ya no esta vigente, por favor comuniquese con la temporal para actualizar su situación contractual","stop")
                                    NEXT FIELD cedtra
                                END IF 
                            ELSE
                                LET cont = 0
                                    SELECT COUNT (*) INTO cont FROM nomin100
                                    WHERE nomin100.documento = cedtra
                                    IF cont > 0 THEN 
                                        LET cont = 0
                                        SELECT COUNT (*) INTO cont FROM nomin100
                                        WHERE nomin100.documento = cedtra
                                        AND nomin100.fecfin_etapa02 > TODAY 

                                        IF cont < 1 THEN
                                            CALL fgl_winmessage("Administrador","Estimado aprendiz SENA su contrato ya no esta vigente, por favor comuniquese con Talento Humano para actualizar su situación contractual","stop")
                                            NEXT FIELD cedtra
                                        END IF 
                                    ELSE
                                        CALL fgl_winmessage("Administrador","Su Número de documento "||cedtra|| " no se encuentra registrado en nuestro sistema ","stop")
                                        NEXT FIELD cedtra
                                    END IF
                            END IF 
                        END IF 
                    END IF 
                END IF
            END IF 
        END IF     
    END IF 
AFTER FIELD usuario 
IF usuario IS NULL THEN
    CALL fgl_winmessage ("Administrador","Debe Ingresar la clave antigua","stop")
    NEXT FIELD usuario
ELSE
    
   
    LET cont = 0
    SELECT gener02.cantidad_cambios
    iNTO cont FROM gener02
    WHERE gener02.cedtra = cedtra
    IF cont = 0 THEN 
        CALL encripta_(usuario)
        LET usuario=mclaenc
        DISPLAY "La clave es: ", usuario
        LET cont = 0
        SELECT COUNT(*) INTO cont FROM gener02
        WHERE gener02.clave = usuario
        AND gener02.cedtra = cedtra
        IF cont = 0 THEN
            CALL fgl_winmessage ("Administrador","La clave es Invalida","stop")
            NEXT FIELD usuario
        END IF 
    ELSE
        EXECUTE IMMEDIATE "set encryption password ""0r13nt3"""
        select decrypt_char(gener02.clave) as contrasena 
        INTO clave_antigua
        FROM gener02
        WHERE gener02.cedtra = cedtra

        IF clave_antigua <> usuario THEN
            CALL fgl_winmessage ("Administrador","La clave antigua no es válida","stop")
            NEXT FIELD usuario
        END IF 
    END IF 
END IF 
AFTER FIELD clave1
IF clave1 IS NULL THEN
    CALL fgl_winmessage ("Administrador","No digitó ninguna clave","stop")
    NEXT FIELD clave1
ELSE
    IF valida_clave (clave1) = FALSE THEN 
        CALL fgl_winmessage ("Administrador","La clave debe tener 8 caracteres ó más, contener un caracter especial, un número y una letra Mayúscula","stop")
        NEXT FIELD clave1
    END IF 
END IF 
AFTER FIELD clave2
IF clave2 IS NULL THEN
    CALL fgl_winmessage ("Administrador","No colocó ningun valor en el campo","stop")
    NEXT FIELD clave2
ELSE
    IF clave2 <> clave1 THEN
        CALL fgl_winmessage ("Administrador","Las contraseñas no coinciden","stop")
        NEXT FIELD clave2
    ELSE
        --CALL fgl_winmessage ("Administrador","Perfecto","information")
        --NEXT FIELD clave2
    END IF 
END IF 
AFTER INPUT 
IF int_flag THEN
    EXIT INPUT
ELSE
    IF cedtra IS NULL OR usuario IS NULL OR clave1 IS NULL OR clave2 IS NULL THEN
        CALL fgl_winmessage ("Administrador","Dejo campos de datos obligatorios en bancos","stop")
    END IF
END IF  
END INPUT 

IF int_flag THEN
    CLOSE WINDOW w_rescla
ELSE
    IF cedtra IS NULL OR usuario IS NULL OR clave1 IS NULL OR clave2 IS NULL THEN
        CALL fgl_winmessage ("Administrador","Dejo campos de datos obligatorios en bancos","stop")
    END IF
END IF 
 
 IF int_flag THEN
  CLEAR FORM
  CALL FGL_winmessage("INFORMACION","La Actualizacion fue cancelada","information")
    INITIALIZE cedtra,usuario,clave1,clave2 TO NULL
    EXIT PROGRAM 
 END IF
--MENU
--ON ACTION Reestablecer
    IF cedtra IS NULL OR usuario IS NULL OR clave1 IS NULL OR clave2 IS NULL THEN
        CALL fgl_winmessage ("Administrador","Dejo campos de datos obligatorios en bancos","stop")
    else
        IF clave2 = clave1 THEN
            PREPARE sp FROM "set encryption password (""0r13nt3"")"
            EXECUTE sp
            update gener02 
            set gener02.clave = encrypt_tdes (clave1) 
            where gener02.cedtra = cedtra
            IF status <> 0 THEN
                CALL fgl_winmessage ("Administrador","Ocurrio el error: ","stop")
                RETURN 
            ELSE
                CALL fgl_winmessage ("Administrador","Clave actualizada con éxito","information")
                UPDATE gener02 SET gener02.cantidad_cambios  = gener02.cantidad_cambios + 1
                WHERE gener02.cedtra = cedtra
                RETURN 
            END IF 
        END IF 
    END IF 
--ON ACTION salir 
    --CLOSE WINDOW w_rescla
--END MENU  
END FUNCTION 

FUNCTION valida_clave (clave)
DEFINE clave LIKE gener02.clave
DEFINE caracteres_especiales, mayusculas,numeros,i,longitud,minusculas INTEGER
DEFINE clave_aux STRING

LET clave_aux = clave

LET caracteres_especiales = 0
LET mayusculas = 0
LET numeros = 0
LET longitud = 0
LET longitud = clave_aux.getLength()

IF longitud > 7 THEN  

    FOR i=1 TO clave_aux.getLength()
        IF clave_aux.getCharAt(i).equals("!") OR clave_aux.getCharAt(i).equals("#") 
        OR clave_aux.getCharAt(i).equals("$") OR clave_aux.getCharAt(i).equals("%") 
        OR clave_aux.getCharAt(i).equals("&") OR clave_aux.getCharAt(i).equals("'")
        OR clave_aux.getCharAt(i).equals("(") OR clave_aux.getCharAt(i).equals(")")
        OR clave_aux.getCharAt(i).equals("*") OR clave_aux.getCharAt(i).equals("+")
        OR clave_aux.getCharAt(i).equals(",") OR clave_aux.getCharAt(i).equals("-")
        OR clave_aux.getCharAt(i).equals(".") OR clave_aux.getCharAt(i).equals("/") 
        OR clave_aux.getCharAt(i).equals(":") OR clave_aux.getCharAt(i).equals("<")
        OR clave_aux.getCharAt(i).equals(">") OR clave_aux.getCharAt(i).equals("?") 
        OR clave_aux.getCharAt(i).equals("=") OR clave_aux.getCharAt(i).equals("@")
        OR clave_aux.getCharAt(i).equals("[") OR clave_aux.getCharAt(i).equals("]")
        OR clave_aux.getCharAt(i).equals("{") OR clave_aux.getCharAt(i).equals("}")
        OR clave_aux.getCharAt(i).equals("_") THEN
            LET caracteres_especiales = caracteres_especiales + 1 
        END IF
        
        IF clave_aux.getCharAt(i).equals("0") OR clave_aux.getCharAt(i).equals("1")
        OR clave_aux.getCharAt(i).equals("2") OR clave_aux.getCharAt(i).equals("3") 
        OR clave_aux.getCharAt(i).equals("4") OR clave_aux.getCharAt(i).equals("5") 
        OR clave_aux.getCharAt(i).equals("6") OR clave_aux.getCharAt(i).equals("7") 
        OR clave_aux.getCharAt(i).equals("8") OR clave_aux.getCharAt(i).equals("9")THEN 
            LET numeros = numeros + 1
        END IF 
        
        IF clave_aux.getCharAt(i).equals("A") OR clave_aux.getCharAt(i).equals("B")
        OR clave_aux.getCharAt(i).equals("C") OR clave_aux.getCharAt(i).equals("D")
        OR clave_aux.getCharAt(i).equals("E") OR clave_aux.getCharAt(i).equals("F")
        OR clave_aux.getCharAt(i).equals("G") OR clave_aux.getCharAt(i).equals("H")
        OR clave_aux.getCharAt(i).equals("I") OR clave_aux.getCharAt(i).equals("J")
        OR clave_aux.getCharAt(i).equals("K") OR clave_aux.getCharAt(i).equals("L")
        OR clave_aux.getCharAt(i).equals("M") OR clave_aux.getCharAt(i).equals("N")
        OR clave_aux.getCharAt(i).equals("O") OR clave_aux.getCharAt(i).equals("P") 
        OR clave_aux.getCharAt(i).equals("Q") OR clave_aux.getCharAt(i).equals("R")
        OR clave_aux.getCharAt(i).equals("Ñ") OR clave_aux.getCharAt(i).equals("S")
        OR clave_aux.getCharAt(i).equals("T") OR clave_aux.getCharAt(i).equals("U")
        OR clave_aux.getCharAt(i).equals("V") OR clave_aux.getCharAt(i).equals("W")
        OR clave_aux.getCharAt(i).equals("X") OR clave_aux.getCharAt(i).equals("Y")
        OR clave_aux.getCharAt(i).equals("Z") THEN
            LET mayusculas = mayusculas + 1
        END IF 
        IF clave_aux.getCharAt(i).equals("a") OR clave_aux.getCharAt(i).equals("b")
        OR clave_aux.getCharAt(i).equals("c") OR clave_aux.getCharAt(i).equals("d")
        OR clave_aux.getCharAt(i).equals("e") OR clave_aux.getCharAt(i).equals("f")
        OR clave_aux.getCharAt(i).equals("g") OR clave_aux.getCharAt(i).equals("h")
        OR clave_aux.getCharAt(i).equals("i") OR clave_aux.getCharAt(i).equals("j")
        OR clave_aux.getCharAt(i).equals("k") OR clave_aux.getCharAt(i).equals("l")
        OR clave_aux.getCharAt(i).equals("m") OR clave_aux.getCharAt(i).equals("n")
        OR clave_aux.getCharAt(i).equals("o") OR clave_aux.getCharAt(i).equals("p") 
        OR clave_aux.getCharAt(i).equals("q") OR clave_aux.getCharAt(i).equals("r")
        OR clave_aux.getCharAt(i).equals("ñ") OR clave_aux.getCharAt(i).equals("s")
        OR clave_aux.getCharAt(i).equals("t") OR clave_aux.getCharAt(i).equals("u")
        OR clave_aux.getCharAt(i).equals("v") OR clave_aux.getCharAt(i).equals("w")
        OR clave_aux.getCharAt(i).equals("x") OR clave_aux.getCharAt(i).equals("y")
        OR clave_aux.getCharAt(i).equals("x") THEN
            LET minusculas = minusculas + 1
        END IF 
    END FOR 
ELSE
    RETURN FALSE 
END IF 

IF mayusculas > 0 AND numeros > 0 AND caracteres_especiales > 0 AND minusculas > 0 THEN
    RETURN TRUE
ELSE
    RETURN FALSE 
END IF 
END FUNCTION 

FUNCTION olvido_clave()
DEFINE cedula LIKE gener02.cedtra
DEFINE cont,i,cont2,t INTEGER 
DEFINE codigo BIGINT 
DEFINE cli RECORD LIKE cliente.* 
DEFINE hora_actual DATETIME HOUR TO SECOND
DEFINE minuto,hora,segundo CHAR (2)
DEFINE aux CHAR (8)
DEFINE aux2 CHAR(6)
DEFINE instruccion STRING 
DEFINE mensaje STRING 


PROMPT "Por favor digite el número de documento: " FOR cedula

LET cedula = cedula CLIPPED 
INITIALIZE cli.* TO NULL 

SELECT * INTO cli.* FROM cliente
WHERE cliente.doc_cliente = cedula

IF cli.doc_cliente IS null THEN
    CALL fgl_winmessage ("Administrador","El usuario no existe","stop")
    RETURN 
END IF 

LET codigo = security.RandomGenerator.CreateRandomNumber()
LET cont = codigo / 19000000000000
IF cont < 0 THEN
    LET cont = cont * (-1)
END IF 

IF cont < 99999 THEN
    LET cont = cont * 10
END IF 

DISPLAY cont 

LET hora_actual = TIME (CURRENT)
LET aux = hora_actual
LET minuto = aux [4,5]
LET minuto = minuto + 10
LET hora = aux [1,2]
LET segundo = aux[7,8]

IF minuto > 59 THEN
    LET minuto = minuto - 60 USING "&&"
    LET hora = hora + 1
END IF 

LET aux = hora clipped,":",minuto clipped,":",segundo clipped

DISPLAY hora_actual
DISPLAY aux

LET i=0

SELECT COUNT(*) INTO i FROM gener02_olvido
WHERE gener02_olvido.numero_documento = cedula

IF i = 0 THEN 
    INSERT INTO gener02_olvido VALUES (cedula,cont,TODAY,hora_actual,aux)
ELSE
    UPDATE gener02_olvido SET gener02_olvido.codigo = cont,
    gener02_olvido.fecha = TODAY,
    gener02_olvido.hora_finalizacion = aux,
    gener02_olvido.hora_generacion = hora_actual
    WHERE gener02_olvido.numero_documento = cedula
END IF 

IF status <> 0 THEN
    CALL fgl_winmessage ("Administrador","Ocurrió un error al conectar a la Base de Datos " || STATUS ||"\n" || SQLERRMESSAGE,"stop")
    RETURN 
ELSE
    LET mensaje = "El código para reestablecer la contraseña es : ",cont," estará activo por 10 minutos."

    CALL enviar_correo_sin_adjuntos(cli.email, "CODIGO PARA CAMBIO DE CONTRASEÑA",mensaje)
    --LET instruccion ="echo ",mensaje," | mail -v -s ""CODIGO PARA CAMBIO DE CONTRASEÑA""  ", cli.email
    --RUN instruccion 
END IF 
LET t=0
WHILE t<3
    LET t = t + 1
    CALL fgl_winprompt(10,10,"DIGITE EL CODIGO QUE RECIBIO EN SU CORREO: "||cli.email,"000000",6,2)  RETURNING aux2
    LET cont2 = aux2
    LET i = 0
    LET hora_actual = TIME
    SELECT COUNT(*) INTO i FROM gener02_olvido
    WHERE gener02_olvido.numero_documento = cedula
    AND gener02_olvido.codigo = cont2
    AND gener02_olvido.hora_finalizacion > hora_actual
    and fecha = TODAY
    
    IF i < 1 THEN
        SELECT hora_finalizacion INTO aux FROM gener02_olvido
        WHERE gener02_olvido.numero_documento = cedula
        AND gener02_olvido.codigo = cont2
        and fecha = TODAY

        IF aux < TIME THEN
            CALL fgl_winmessage ("Administrador","El código ya expiró","stop")
            LET i = 0
            EXIT while
        ELSE
            CALL fgl_winmessage ("Administrador","El código es incorrecto","stop")
            LET i = 0
        END IF 
    ELSE
        LET i = 1
        EXIT WHILE 
    END IF 
END WHILE

IF i = 1 THEN
    CALL olvido_contrasena(cedula)
ELSE 
    CALL fgl_winmessage ("Administrador","Por favor vuelve a intentarlo","stop")
    RETURN 
END IF 
END FUNCTION 

function clave(imagen)
  
  DEFINE mclaver VARCHAR (120)
  DEFINE m_mensaje char(55)
  DEFINE usuarioin,cont INTEGER
  DEFINE documentoin CHAR (20)
  DEFINE nombre LIKE gener02.nombre
  DEFINE fechafin,ld_fecha_fin DATE 
  DEFINE li_cnt INTEGER
  DEFINE imagen STRING 
OPEN WINDOW w_clave  WITH FORM "fc_clave"
 DISPLAY imagen TO logo
 let j=0
 let mclave=null 
 let musuario = null
 let mnombre = null
 let valida = FALSE
label ciclo_clave:
INPUT BY NAME usuarioin,documentoin,mclave_seguridad --ATTRIBUTES( ACCEPT=FALSE )
BEFORE INPUT 
 CALL oculta_campo("olvido")
 CALL oculta_campo("olvido_clave")
AFTER FIELD usuarioin
    --IF usuarioin IS NULL THEN
             --CALL ayudusu() RETURNING usuarioin
             IF usuarioin IS NULL THEN
                  CALL fgl_winmessage ("Administrador","Debe Digitar el número de usuario","stop")
                  NEXT FIELD usuarioin
             ELSE
                  LET li_cnt = 0
                  SELECT gener02.cantidad_cambios
                  INTO li_cnt FROM gener02
                  WHERE gener02.usuario = usuarioin
                    
                      IF li_cnt<>0 then 
                             CALL muestra_campo("olvido")
                             CALL muestra_campo("olvido_clave")
                      END IF 
                  
                  LET cont = 0
                  SELECT COUNT(*) INTO cont FROM gener02
                  WHERE gener02.usuario = usuarioin
                    IF cont = 0 THEN
                        CALL fgl_winmessage ("Administrador","El usuario "||usuarioin clipped||" no existe!","stop")
                        NEXT FIELD usuarioin
                    END IF  
            END IF
   -- ELSE 
        --LET cont = 0
        --SELECT COUNT(*) INTO cont FROM gener02
        --WHERE gener02.usuario = usuarioin
        --IF cont = 0 THEN
            --CALL fgl_winmessage ("Administrador","El usuario "||usuarioin clipped||" no existe!","stop")
            --NEXT FIELD usuarioin
        --END IF 
    --END IF 

AFTER FIELD documentoin 
    IF documentoin IS NULL THEN
        CALL fgl_winmessage ("Administrador","Debe Digitar el número de identificación","stop")
        NEXT FIELD documentoin
    ELSE
        LET cont = 0
        SELECT COUNT(*) INTO cont FROM gener02
        WHERE gener02.usuario = usuarioin
        AND gener02.cedtra = documentoin
        IF cont = 0 THEN
            CALL fgl_winmessage ("Administrador","El documento "||documentoin clipped||" no corresponde al usuario "||usuarioin clipped,"stop")
            NEXT FIELD documentoin
        ELSE
            LET cont = 0
            SELECT gener02.nombre,gener02.cantidad_cambios
            INTO nombre,cont FROM gener02
            WHERE gener02.usuario = usuarioin
            AND gener02.cedtra = documentoin
            DISPLAY "El nombre del paciente es: ",nombre
            IF cont = 0 THEN
                CALL reestablecer_contraseña ()
            END IF 
            LET cont = 0
            LET documentoin = documentoin CLIPPED 
            SELECT COUNT(*),tipfun INTO cont, lr_tipfun FROM gener02
            WHERE gener02.usuario = usuarioin AND 
            gener02.cedtra = documentoin
            GROUP BY 2
            SELECT MAX(acceso_esp_usuarios.fec_fin) INTO ld_fecha_fin FROM acceso_esp_usuarios
            WHERE acceso_esp_usuarios.usuario = usuario
      
            IF ld_fecha_fin <= TODAY THEN
                IF lr_tipfun <>"REVI" THEN
                    IF cont = 0 THEN
                        CALL fgl_winmessage ("Administrador","El usuario de cedula "||documentoin CLIPPED||" no existe","stop")
                        NEXT FIELD documentoin
                    ELSE
                        LET cont = 0
                        SELECT COUNT(*) INTO cont FROM nomin02
                        WHERE nomin02.docemp = documentoin
                        AND nomin02.estado = "A"
                        IF cont > 0 THEN
                            SELECT nomin02.fecter INTO fechafin FROM nomin02
                            WHERE nomin02.docemp = documentoin
                            IF fechafin < TODAY THEN
                                CALL fgl_winmessage("Administrador","Ya su contrato expiró, por favor comuniquese con Talento Humano para actualizar su información Laboral","stop")
                                NEXT FIELD cedtra
                            END IF 
                        ELSE
                            LET cont = 0
                            SELECT COUNT(*) INTO cont from ct_proveedores
                            where ct_proveedores.estado = "A"
                            AND (ct_proveedores.nit = documentoin OR ct_proveedores.cedrep = documentoin)

                            IF cont > 0 THEN
                                SELECT COUNT(*) INTO cont from ct_proveedores, ct_contrato
                                where ct_proveedores.nit = ct_contrato.nit_contratista
                                and ct_proveedores.estado = "A"
                                and ct_contrato.fecha_fin > TODAY
                                AND (ct_proveedores.nit = documentoin OR ct_proveedores.cedrep = documentoin)
                                IF cont < 1 THEN
                                    CALL fgl_winmessage("Administrador","Señor contratista su contrato ya no esta vigente, por favor comuniquese con Talento Humano para actualizar su información contractual","stop")
                                    NEXT FIELD documentoin
                                END IF 
                            ELSE
                                LET cont = 0
                                SELECT COUNT(*) INTO cont FROM nom_mision
                                WHERE nom_mision.documento = documentoin
                                IF cont > 0 THEN
                                    SELECT fecterm INTO fechafin FROM nom_mision
                                    WHERE nom_mision.documento = documentoin
                                    IF fechafin < TODAY THEN
                                        CALL fgl_winmessage("Administrador","Estimado funcionario su contrato ya no esta vigente, por favor comuniquese con la temporal para actualizar su situación contractual","stop")
                                        NEXT FIELD documentoin
                                    END IF 
                                ELSE
                                    LET cont = 0
                                    SELECT COUNT (*) INTO cont FROM nomin100
                                    WHERE nomin100.documento = documentoin
                                    IF cont > 0 THEN 
                                        LET cont = 0
                                        SELECT COUNT (*) INTO cont FROM nomin100
                                        WHERE nomin100.documento = documentoin
                                        AND nomin100.fecfin_etapa02 > TODAY 

                                        IF cont < 1 THEN
                                            CALL fgl_winmessage("Administrador","Estimado aprendiz SENA su contrato ya no esta vigente, por favor comuniquese con Talento Humano para actualizar su situación contractual","stop")
                                            NEXT FIELD documentoin
                                        END IF 
                                    ELSE
                                        CALL fgl_winmessage("Administrador","Su Número de documento "||documentoin|| " no se encuentra registrado en nuestro sistema ","stop")
                                        NEXT FIELD documentoin
                                    END IF  
                                END IF 
                            END IF 
                        END IF 
                    END IF 
                END IF 
            END IF     
        END IF 
    END IF   
AFTER FIELD mclave_seguridad
 IF mclave_seguridad IS NULL  THEN
        SELECT gener02.cantidad_cambios
        INTO li_cnt FROM gener02
        WHERE gener02.usuario = usuarioin
        NEXT FIELD documentoin               
 END IF 
 IF mclave_seguridad is not null THEN
    LET cont = 0
    SELECT gener02.cantidad_cambios INTO cont FROM gener02
    WHERE gener02.usuario = usuarioin
    IF cont = 0 THEN
        CALL reestablecer_contraseña ()    
    END IF 
 --LET mclave=mclaenc
 DISPLAY "La clave es: ", mclave_seguridad
 --INITIALIZE mgener02.* TO NULL
 EXECUTE IMMEDIATE "set encryption password ""0r13nt3"""
 select gener02.usuario, gener02.nombre,decrypt_char(gener02.clave) as contrasena 
 into musuario, mnombre, mclaver
 from gener02 
 where gener02.usuario = usuarioin

 --DISPLAY "Es esta: ",mclaver
 IF mclaver IS NULL then
      MESSAGE "LA CLAVE DIGITADA NO EXISTE " ATTRIBUTE(BLUE)
      DISPLAY "" to mclave_seguridad
 ELSE  
    IF mclaver = mclave_seguridad THEN 
      LET valida = TRUE
      let l=1
      --let musuario = mgener02.usuario
      --let mnombre = mgener02.nombre
      
      --CALL formamain()
      ----CALL fgl_winmessage ("Administrador","Ingreso con exito","information")
      EXIT INPUT
    ELSE
        MESSAGE "Clave Inválida"
        let musuario = null
        let mnombre  = null
        DISPLAY "" TO mclave_seguridad 
        NEXT FIELD mclave_seguridad
    END IF 
 end if
else 
   MESSAGE "NO HA DIGITADO LA CLAVE" 
end IF
ON ACTION olvido
    CALL reestablecer_contraseña ()

ON ACTION olvido_clave
    CALL olvido_clave()

--GOTO ciclo_clave
AFTER INPUT 
    IF int_flag THEN 
        EXIT INPUT
    ELSE
        IF usuarioin IS NULL OR documentoin IS NULL OR mclave IS NULL THEN
            CALL fgl_winmessage("Admiistrador","No se pueden dejar campos obligatorios vacios","stop")
            RETURN 
        END IF 
    END IF 
END INPUT

{MENU
--ON ACTION ingresar
    --CALL fgl_winmessage("Admiistrador","Ingresaste con éxito","informacion")
  ON ACTION olvido
    CALL reestablecer_contraseña ()


    
  ON ACTION salir
    EXIT PROGRAM
END MENU}
    
CLOSE WINDOW w_clave
--END MENU 

 IF not VALIDA then
   EXIT PROGRAM 
 end if
end FUNCTION

FUNCTION encripta()
 DEFINE mkeyval,i,b,x SMALLINT 
 define d decimal(10,2)
 IF mclave IS NULL THEN
  MESSAGE "  LA CLAVE NO FUE DIGITADA POR FAVOR VERIFIQUELA"
             
  RETURN
 END IF
 FOR i = 1 TO 5
  let d=i/2  
  let b=d
  if b=d then
   let x=6
  else
   let x=-4
  end if
  LET mkeyval = FGL_KEYVAL(mclave[i,i])
  LET mclaenc[i,i] = ASCII (mkeyval+x+5)
 END FOR 
END FUNCTION

FUNCTION encripta_(clave_)
 DEFINE mkeyval,i,b,x SMALLINT 
 define d decimal(10,2)
 DEFINE clave_ LIKE gener02.clave
 IF clave_ IS NULL THEN
  MESSAGE "  LA CLAVE NO FUE DIGITADA POR FAVOR VERIFIQUELA"
             
  RETURN
 END IF
 FOR i = 1 TO 5
  let d=i/2  
  let b=d
  if b=d then
   let x=6
  else
   let x=-4
  end if
  LET mkeyval = FGL_KEYVAL(clave_[i,i])
  LET mclaenc[i,i] = ASCII (mkeyval+x+5)
 END FOR 
END FUNCTION

FUNCTION olvido_contrasena(cedula)
DEFINE cedula LIKE cliente.doc_cliente
DEFINE rec_olvido RECORD
	contrasena VARCHAR (120),
	contrasena2 VARCHAR (120)
END RECORD


OPEN WINDOW w_olvido WITH FORM "fc_olvido_clave"
IF int_flag  THEN
    LET int_flag = FALSE
END IF 

INITIALIZE rec_olvido.* TO NULL 

INPUT BY NAME rec_olvido.contrasena THRU rec_olvido.contrasena2 --ATTRIBUTES (ACCEPT = FALSE)
AFTER FIELD contrasena
IF rec_olvido.contrasena IS NULL THEN
    CALL fgl_winmessage ("Administrador","No digitó ninguna clave","stop")
    NEXT FIELD contrasena
ELSE
    IF valida_clave (rec_olvido.contrasena) = FALSE THEN 
        CALL fgl_winmessage ("Administrador","La clave debe tener 8 caracteres ó más, contener un caracter especial, un número y una letra Mayúscula","stop")
        NEXT FIELD contrasena
    END IF 
END IF 
AFTER FIELD contrasena2
IF rec_olvido.contrasena2 IS NULL THEN
    CALL fgl_winmessage ("Administrador","No colocó ningun valor en el campo","stop")
    NEXT FIELD contrasena2
ELSE
    IF rec_olvido.contrasena2 <> rec_olvido.contrasena THEN
        CALL fgl_winmessage ("Administrador","Las contraseñas no coinciden","stop")
        NEXT FIELD contrasena2
    ELSE
        --CALL fgl_winmessage ("Administrador","Perfecto","information")
        --NEXT FIELD clave2
    END IF 
END IF 
AFTER INPUT 
IF int_flag THEN
    EXIT INPUT
ELSE
    IF rec_olvido.contrasena2 IS NULL OR rec_olvido.contrasena IS null THEN
        CALL fgl_winmessage ("Administrador","Dejo campos de datos obligatorios en bancos","stop")
    END IF
END IF  
END INPUT 
MENU
ON ACTION Reestablecer_Contrasena
    IF rec_olvido.contrasena2 IS NULL OR rec_olvido.contrasena IS NULL THEN
        CALL fgl_winmessage ("Administrador","Dejo campos de datos obligatorios en bancos","stop")
    else
        IF rec_olvido.contrasena2 = rec_olvido.contrasena THEN
            PREPARE sp FROM "set encryption password (""0r13nt3"")"
            EXECUTE sp
            update gener02 
            set gener02.clave = encrypt_tdes (rec_olvido.contrasena) 
            where gener02.cedtra = cedula
            IF status <> 0 THEN
                CALL fgl_winmessage ("Administrador","Ocurrio el error: ","stop")
                RETURN 
            ELSE
                CALL fgl_winmessage ("Administrador","Clave actualizada con éxito","information")
                UPDATE gener02 SET gener02.cantidad_cambios  = gener02.cantidad_cambios + 1
                WHERE gener02.cedtra = cedula
                --RETURN 
            END IF 
        END IF 
    END IF 


ON ACTION salir
   ---  EXIT PROGRAM
    RETURN 
  END MENU 
  CLOSE WINDOW w_olvido
END FUNCTION 

function ingreso(imagen)
 DEFINE musr char(35)
 DEFINE imagen STRING 
 INITIALIZE mgener01.* TO NULL
 select * into mgener01.* from gener01
 let mdate1=mgener01.fecha
 let mcodapl="CR"
 let mdate2=today
 call clave(imagen)
 RETURN valida
end function
FUNCTION oculta_campo(campo)
DEFINE campo  STRING
    ,w ui.WINDOW
    ,f ui.FORM
    
    LET w = ui.Window.getCurrent()
    LET f = w.getForm()
    CALL f.setElementHidden(campo,1)
    CALL f.setFieldHidden(campo,1)

END FUNCTION
FUNCTION muestra_campo(campo)
DEFINE campo  STRING
    ,w ui.WINDOW
    ,f ui.FORM
    
    LET w = ui.Window.getCurrent()
    LET f = w.getForm()
    CALL f.setElementHidden(campo,0)
    CALL f.setFieldHidden(campo,0)

END FUNCTION