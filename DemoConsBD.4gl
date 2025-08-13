MAIN

DEFINE  ls_script VARCHAR(100)
DEFINE arr_a  RECORD
    clave CHAR(20),
    nombre CHAR (20)
END RECORD  
DATABASE empresa
    LET ls_script = "select * from fe_ciudades WHERE clave IN (05001,05004,050021)"
    PREPARE s1 FROM ls_script
    DECLARE c1 CURSOR FOR s1
    FOREACH c1  INTO arr_a.*
      DISPLAY arr_a.nombre
    END FOREACH
END MAIN
