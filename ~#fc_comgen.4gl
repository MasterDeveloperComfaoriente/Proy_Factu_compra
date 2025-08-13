GLOBALS "fc_globales.4gl"
DEFINE mdeflinc, mdeflinc2 char(200)
	
-- FUNCIONES DE IMPRESION
FUNCTION manimp()
 DEFINE mimprima CHAR(200)
 DEFINE mopcion char(1)
 DEFINE tp      RECORD
  a                CHAR(1),
  nombre           LIKE gener25.nombre,
  clase            LIKE gener25.clase,
  ubicada          LIKE gener25.ubicada
 END RECORD,
 lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER, o CHAR(1)
 CREATE TEMP TABLE gentem
 (
  registro char(200)
 )
 IF int_flag THEN LET int_flag = FALSE END IF
 LET lastline = 23
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM gener25
 IF NOT maxnum THEN
  ERROR "                  NO HAY REGISTROS PARA VISUALIZAR          ",
        "                   "
  SLEEP 2
  ERROR ""
  LET tp.nombre = NULL
  DROP TABLE gentem
  RETURN
 END IF
 OPEN WINDOW w_vgener251 AT 1,1 WITH FORM "genimp"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 RUN "wc -l rep > tem"
 LOAD FROM "tem" INSERT INTO gentem
 RUN "rm tem"
 LET mdeflinc = NULL
 SELECT registro INTO mdeflinc FROM gentem
 LET mdeflinc2 = NULL
 FOR i = 1 TO 200
   DISPLAY mdeflinc[i,i]
   IF mdeflinc[i,i] <> "0" AND mdeflinc[i,i] <> "1" AND mdeflinc[i,i] <> "2"
    AND mdeflinc[i,i] <> "3" AND mdeflinc[i,i] <> "4" AND mdeflinc[i,i] <> "5"
    AND mdeflinc[i,i] <> "6" AND mdeflinc[i,i] <> "7" AND mdeflinc[i,i] <> "8"
    AND mdeflinc[i,i] <> "9" THEN
        EXIT FOR
   ELSE     
      LET mdeflinc2 = mdeflinc2 clipped,  mdeflinc[i,i]
   END IF   
 END FOR  
 LET mdeflin = mdeflinc2
 DECLARE c_vgener251 SCROLL CURSOR FOR
 SELECT "O",gener25.nombre, gener25.clase, gener25.ubicada
  FROM gener25 ORDER BY gener25.nombre
 OPEN c_vgener251
 LET mdefimp=FGL_GETENV("LPDEST")
 LET mdefpag=mdeflin/mdeftam
 LET b = NULL
 LET c = NULL
 LET d = NULL
 LET e = NULL
 LET f = NULL
 LET g = NULL
 LET h = NULL
 CASE
  WHEN mdeflet="bold"      LET b="X"
  WHEN mdeflet="italic"    LET c="X"
  WHEN mdeflet="condensed" LET d="X"
  WHEN mdeflet="elite"     LET e="X"
  WHEN mdeflet="draft"     LET f="X"
  WHEN mdeflet="roman"     LET g="X"
  WHEN mdeflet="sansserif" LET h="X"
 END CASE
 LET mdefcop=1
 LET mdefini=1
 LET mdeffin=mdefpag
 CALL defecto()
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL gener25row( currrow, prevrow, pagenum ) RETURNING pagenum, prevrow 
 label entrada: 
 INPUT mopcion from mopcion ATTRIBUTE (ACCEPT =FALSE, CANCEL=FALSE)
  AFTER FIELD mopcion
   CASE
     WHEN mopcion="I"
      LET mopcion=null
      DISPLAY BY NAME mopcion
      CALL gener25val(maxnum) RETURNING tp.nombre
      LET mdefimp=tp.nombre
      CALL defecto()
     WHEN mopcion="L"
      LET mopcion=null
      DISPLAY BY NAME mopcion
      CALL camlet() RETURNING b,c,d,e,f,g,h
      CALL defecto()
     WHEN mopcion="C"
      LET mopcion=null
      DISPLAY BY NAME mopcion
      CALL camcop(mdefcop) RETURNING mdefcop
      CALL defecto()
     WHEN mopcion="G"
      LET mopcion=null
      DISPLAY BY NAME mopcion
      CALL campag(mdefini,mdeffin) RETURNING mdefini,mdeffin
      CALL defecto()
     WHEN mopcion="P"
      LET mopcion=null
      DISPLAY BY NAME mopcion
      --LET mimprima="awk 'FNR==",((mdefini*mdeftam)-mdeftam)+1 USING "<<<<<<<",
      --                 ",FNR==",mdeffin*mdeftam USING "<<<<<<<",
      --                 " {print $0}'"," rep > rep1"
      --RUN mimprima
      #RUN "show rep1;rm rep1"
      CALL showfile("rep")
      RUN "rm rep1"

     WHEN mopcion="A"
      LET mopcion=null
      DISPLAY BY NAME mopcion
      CALL repfile()
     WHEN mopcion="S"
      LET mopcion=null
      DISPLAY BY NAME mopcion
      IF mdeflin <= 0 THEN
       MENU "Mensaje de Error" ATTRIBUTE(style= "dialog", 
         comment= "  IMPRESION VACIA  ",
           image= "exclamation")
         COMMAND "Aceptar"
           EXIT MENU
         END MENU
         EXIT INPUT
      END IF
     --LET mimprima="awk 'FNR==",((mdefini*mdeftam)-mdeftam)+1 USING "<<<<<<<",
     --                ",FNR==",mdeffin*mdeftam USING "<<<<<<<"," {print $0}'",
      --          " rep|lp -d",mdefimp clipped," -n ",mdefcop using "----"
      let mimprima = "lp rep"
      RUN mimprima
      EXIT INPUT
     WHEN mopcion="N"
      LET mopcion=null
      DISPLAY BY NAME mopcion
      RUN "rm rep"
      EXIT INPUT
    END CASE
 GOTO entrada  
END INPUT
 DROP table gentem
 RUN "rm rep"
 CLOSE c_vgener251
 CLOSE WINDOW w_vgener251
END FUNCTION
FUNCTION repfile()
 DEFINE mfile CHAR(12), x CHAR(1), mcomm CHAR(50)
 LET mfile = NULL
 LET x = NULL
 INPUT BY NAME mfile, x WITHOUT DEFAULTS
  BEFORE INPUT
   LET mfile = "rep"
   DISPLAY BY NAME mfile
  AFTER FIELD mfile
   IF mfile IS NULL THEN NEXT FIELD mfile END IF
  AFTER FIELD x
   IF x <> "S" AND x <> "N" THEN NEXT FIELD x END IF
   IF x = "S" OR x = "N" THEN EXIT INPUT END IF
  AFTER INPUT 
   IF x <> "S" AND x <> "N" THEN NEXT FIELD x END IF
 END INPUT
 LET mcomm = "cp rep ",mfile CLIPPED
 --LET mcomm="awk 'FNR==",((mdefini*mdeftam)-mdeftam)+1 USING "<<<<<<<",
 --              ",FNR==",mdeffin*mdeftam USING "<<<<<<<",
 --              " {print $0}'"," rep > ",mfile CLIPPED
 DISPLAY mcomm                
 RUN mcomm
 IF x = "S" THEN
  PROMPT "INSERTE DISKETTE EN DRIVE A Y PRESIONE <ENTER> ... " FOR CHAR x
  LET mcomm = "doscp ",mfile CLIPPED," a:"
  RUN mcomm
 END IF
 DISPLAY "" TO mfile
 DISPLAY "" TO x
END FUNCTION
FUNCTION defecto()
 DEFINE mfecha DATE
 DEFINE mhora CHAR(5)
 LET mfecha=date(today)
 LET mhora=time
 DISPLAY mdefimp TO dnombre
 CASE
  WHEN b="X" LET mdeflet="bold"
  WHEN c="X" LET mdeflet="italic"
  WHEN d="X" LET mdeflet="condensed"
  WHEN e="X" LET mdeflet="elite"
  WHEN f="X" LET mdeflet="draft"
  WHEN g="X" LET mdeflet="roman"
  WHEN h="X" LET mdeflet="sansserif"
 END CASE
 DISPLAY mdeflet TO dletra
 DISPLAY mdefcop TO dnc
 DISPLAY mdefnom TO mnom
 DISPLAY mfecha TO mf
 DISPLAY mhora TO mh
 DISPLAY mhoja TO mhoja
 DISPLAY mdefpag TO np
 DISPLAY mdefcop TO nc
 DISPLAY mdefini TO pi
 DISPLAY mdeffin TO pf
 DISPLAY b TO b
 DISPLAY c TO c
 DISPLAY d TO d
 DISPLAY e TO e
 DISPLAY f TO f
 DISPLAY g TO g
 DISPLAY h TO h
END FUNCTION
FUNCTION camcop(nc)
 DEFINE nc INTEGER
 INPUT BY NAME nc WITHOUT DEFAULTS
  AFTER FIELD nc
   IF nc IS NULL OR nc <= 0 THEN
    LET nc = 1
   END IF 
   EXIT INPUT
 END INPUT
 RETURN nc
END FUNCTION
FUNCTION campag(pi,pf)
 DEFINE pi,pf INTEGER
 INPUT BY NAME pi,pf WITHOUT DEFAULTS
  AFTER FIELD pi
   IF pi IS NULL OR pi <= 0 OR pi > mdefpag THEN
    LET pi = mdefini
    DISPLAY pi TO pi
   END IF 
  AFTER FIELD pf
   IF pf IS NULL OR pf <= 0 OR pf > mdefpag THEN
    LET pf = mdeffin
    DISPLAY pf TO pf
   END IF
 -- ON KEY (control-I)
 --  EXIT INPUT
 END INPUT
 RETURN pi,pf
END FUNCTION
FUNCTION camlet()
 DEFINE t, u, v, w, x, y, z CHAR(1)
 INPUT BY NAME b,c,d,e,f,g,h WITHOUT DEFAULTS
  --ON KEY (control-I)
  -- EXIT INPUT
  --ON KEY (control-M)
  -- EXIT INPUT
  BEFORE INPUT
   LET t = NULL
   LET u = NULL
   LET v = NULL
   LET w = NULL
   LET x = NULL
   LET y = NULL
   LET z = NULL
   LET t = b
   LET u = c
   LET v = d
   LET w = e
   LET x = f
   LET y = g
   LET z = h
   DISPLAY t TO b
   DISPLAY u TO c
   DISPLAY v TO d
   DISPLAY w TO e
   DISPLAY x TO f
   DISPLAY y TO g
   DISPLAY z TO h
   LET b = NULL
   LET c = NULL
   LET d = NULL
   LET e = NULL
   LET f = NULL
   LET g = NULL
   LET h = NULL
  BEFORE FIELD b
   DISPLAY t TO b
  AFTER FIELD b
   IF b IS NOT NULL THEN
    LET b="X"
    LET c=null
    LET d=null
    LET e=null
    LET f=null
    LET g=null
    LET h=null
    EXIT INPUT
   END IF 
  BEFORE FIELD c
   DISPLAY u TO c
  AFTER FIELD c
   IF c IS NOT NULL THEN
    LET b=null
    LET c="X"
    LET d=null
    LET e=null
    LET f=null
    LET g=null
    LET h=null
    EXIT INPUT
   END IF 
  BEFORE FIELD d
   DISPLAY v TO d
  AFTER FIELD d
   IF d IS NOT NULL THEN
    LET b=null
    LET c=null
    LET d="X"
    LET e=null
    LET f=null
    LET g=null
    LET h=null
    EXIT INPUT
   END IF 
  BEFORE FIELD e
   DISPLAY w TO e
  AFTER FIELD e
   IF e IS NOT NULL THEN
    LET b=null
    LET c=null
    LET d=null
    LET e="X"
    LET f=null
    LET g=null
    LET h=null
    EXIT INPUT
   END IF 
  BEFORE FIELD f
   DISPLAY x TO f
  AFTER FIELD f
   IF f IS NOT NULL THEN
    LET b=null
    LET c=null
    LET d=null
    LET e=null
    LET f="X"
    LET g=null
    LET h=null
    EXIT INPUT
   END IF 
  BEFORE FIELD g
   DISPLAY y TO g
  AFTER FIELD g
   IF g IS NOT NULL THEN
    LET b=null
    LET c=null
    LET d=null
    LET e=null
    LET f=null
    LET g="X"
    LET h=null
    EXIT INPUT
   END IF 
  BEFORE FIELD h
   DISPLAY z TO h
  AFTER FIELD h
   IF h IS NOT NULL THEN
    LET b=null
    LET c=null
    LET d=null
    LET e=null
    LET f=null
    LET g=null
    LET h="X"
    EXIT INPUT
   END IF 
 END INPUT
 IF b IS NULL AND c IS NULL AND d IS NULL AND e IS NULL AND f IS NULL AND
    g IS NULL AND h IS NULL THEN
  LET b = t
  LET c = u
  LET d = v
  LET e = w
  LET f = x
  LET g = y
  LET h = z
 END IF
 DISPLAY BY NAME b
 DISPLAY BY NAME c
 DISPLAY BY NAME d
 DISPLAY BY NAME e
 DISPLAY BY NAME f
 DISPLAY BY NAME g
 DISPLAY BY NAME h
 RETURN b,c,d,e,f,g,h
END FUNCTION
FUNCTION gener25val(maxnum)
 DEFINE tp      RECORD
  a                CHAR(1),
  nombre           LIKE gener25.nombre,
  clase            LIKE gener25.clase,
  ubicada          LIKE gener25.ubicada
 END RECORD,
 lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER,
 p CHAR(1)
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL gener25row( currrow, prevrow, pagenum ) RETURNING pagenum, prevrow 
 LABEL dato:
 INPUT BY NAME p WITHOUT DEFAULTS
    AFTER FIELD p
 --  IF INFIELD(p) THEN
    CASE
     WHEN FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR p = "I"
      LET p=null
      DISPLAY by name p
      IF currrow = maxnum THEN
       LET currrow = 1
      ELSE
       LET currrow = currrow + 1
      END IF
      CALL gener25row( currrow, prevrow, pagenum )
      RETURNING pagenum, prevrow 
     -- GOTO dato
     WHEN FGL_LASTKEY() = FGL_KEYVAL("UP") OR p = "A"
      LET p=null
      DISPLAY by name p
      IF currrow = 1 THEN
       LET currrow = maxnum
      ELSE
       LET currrow = currrow - 1
      END IF
      CALL gener25row( currrow, prevrow, pagenum )
      RETURNING pagenum, prevrow 
     -- GOTO dato
    WHEN FGL_LASTKEY() = FGL_KEYVAL("RETURN") or p ="T"
     LET p=null
     DISPLAY BY NAME p
     FETCH ABSOLUTE currrow c_vgener251 INTO tp.*
     EXIT INPUT
    END CASE
--   END IF 
 -- ON KEY (control-I)
--   LET tp.nombre = NULL
 --  EXIT INPUT
 END INPUT
 RETURN tp.nombre
END FUNCTION 

FUNCTION gener25row( currrow, prevrow, pagenum )
 DEFINE tp RECORD
  a                CHAR(1),
  nombre           LIKE gener25.nombre,
  clase            LIKE gener25.clase,
  ubicada          LIKE gener25.ubicada
 END RECORD,
 scrmax, scrcurr, scrprev, currrow, prevrow, pagenum,
 newpagenum, x, y, scrfrst    INTEGER
 LET scrmax = 4
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
  FETCH ABSOLUTE scrfrst c_vgener251 INTO tp.*
  FOR x = 1 TO scrmax
   if mdefimp=tp.nombre then
    LET tp.a="X"
   end if
   IF x = scrcurr THEN
    DISPLAY tp.* TO impresora[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO impresora[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vgener251 INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO impresora[y].*
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
  FETCH ABSOLUTE prevrow c_vgener251 INTO tp.*
  DISPLAY tp.* TO impresora[scrprev].*
  FETCH ABSOLUTE currrow c_vgener251 INTO tp.*
  DISPLAY tp.* TO impresora[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION 

{FUNCTION showfile(fn)
  DEFINE fn STRING
  DEFINE txt STRING
  OPEN WINDOW ven_mostrar WITH FORM "TBText"
     ATTRIBUTE(TEXT="File: ["||fn||"]",STYLE="dialog")
  LET txt = readfile(fn)
  INPUT BY NAME txt WITHOUT DEFAULTS
   ON ACTION ACCEPT
    EXIT INPUT
   END INPUT  
  CLOSE WINDOW ven_mostrar
END FUNCTION}

{FUNCTION readfile(fn)
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
END FUNCTION}

FUNCTION comfec()
 OPEN WINDOW w_fecha AT 04,5 WITH FORM "fe_comrep"
 let int_flag = false
 display mdeftit to titulo
 display mdefpro to prompt 
 let v=0
 let z=0
 INPUT mfecini,mfecfin from fecha1,fecha2
  BEFORE FIELD fecha1
   if v=0 then
    let v=1
    let mfecini=mdeffec1
    DISPLAY mfecini TO fecha1
   end if
  AFTER FIELD fecha1
   IF mfecini IS NULL THEN
    ERROR "  LA FECHA NO FUE DIGITADA       "
    sleep 2
    error ""
    NEXT FIELD fecha1
   end if
  BEFORE FIELD fecha2
   if z=0 then
    let z=1
    let mfecfin=mdeffec2
    DISPLAY mfecfin TO fecha2
   end if
  AFTER FIELD fecha2
   IF mfecfin IS NULL THEN
    ERROR " LA FECHA NO FUE DIGITADA       "
    sleep 2
    error ""
    NEXT FIELD fecha2
   end if
   IF mfecini>mfecfin THEN
    LET mfecfin=mfecini
    DISPLAY mfecfin TO fecha2
   END IF
 AFTER INPUT
  IF int_flag THEN
   let mfecini = null
   let mfecfin = null
   EXIT INPUT
  END IF
 END INPUT
 CLOSE WINDOW w_fecha
 OPTIONS
  ACCEPT KEY ESCAPE
 RETURN mfecini,mfecfin
END FUNCTION 



FUNCTION conta09val()
 DEFINE tp      RECORD
  codcue             LIKE conta09.codcue,
  numcue             LIKE conta09.numcue,
  detalle            LIKE conta09.detalle
 END RECORD,
 lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER 
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM conta09n
 IF NOT maxnum THEN
  ERROR "                         NO HAY REGISTROS PARA VISUALIZAR   ",
        "                   "
  SLEEP 2
  ERROR ""
  LET tp.codcue = NULL
  RETURN tp.codcue
 END IF
 OPEN WINDOW w_vconta093 AT 8,26 WITH FORM "con09v"
 DISPLAY "" AT 1,10
 DISPLAY "" AT 2,1
 DISPLAY "Trabajando por favor espere ... " AT 2,1
 DECLARE c_vconta093 SCROLL CURSOR FOR
 SELECT conta09n.codcue, conta09n.numcue, conta09n.detalle
  FROM conta09n ORDER BY conta09n.codcue
 OPEN c_vconta093
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL conta09row( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
 DISPLAY "" AT lastline,1
 DISPLAY "Localizacion : ( Actual ", currrow,
          "/ Existen ", maxnum, ")" AT lastline,1
 MENU "VISUALIZA"
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   HELP 5
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL conta09row( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
   DISPLAY "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" AT lastline,1
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   HELP 6
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL conta09row( currrow, prevrow, pagenum )
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
   CALL conta09row( currrow, prevrow, pagenum )
   RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
   DISPLAY "Localizacion : ( Actual ", currrow,
           "/ Existen ", maxnum, ")" AT lastline,1
  COMMAND "Tomar" "Selecciona el registro actual"
   HELP 3 
   FETCH ABSOLUTE currrow c_vconta093 INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   HELP 1
   LET tp.codcue = NULL
   EXIT MENU
 END MENU
 CLOSE c_vconta093
 CLOSE WINDOW w_vconta093
 RETURN tp.codcue
END FUNCTION
FUNCTION conta09row( currrow, prevrow, pagenum )
 DEFINE tp RECORD
  codcue             LIKE conta09.codcue,
  numcue             LIKE conta09.numcue,
  detalle            LIKE conta09.detalle
 END RECORD,
 scrmax, scrcurr, scrprev, currrow, prevrow,
 pagenum, newpagenum, x, y, scrfrst INTEGER
 LET scrmax = 6
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
  FETCH ABSOLUTE scrfrst c_vconta093 INTO tp.*
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO cuen[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO cuen[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vconta093 INTO tp.*
    IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO cuen[y].*
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
  FETCH ABSOLUTE prevrow c_vconta093 INTO tp.*
  DISPLAY tp.* TO cuen[scrprev].*
  FETCH ABSOLUTE currrow c_vconta093 INTO tp.*
  DISPLAY tp.* TO cuen[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION

--Funcion Inicia El Mensaje
FUNCTION ini_mensaje_espera(titulo)
DEFINE titulo      STRING
--CALL ui.Interface.loadStyles("estilo")
OPEN WINDOW w_mensaje_espera WITH FORM "ff_espera"
ATTRIBUTES (STYLE="centrada noborder fondoblanco")
DISPLAY titulo TO message1
CALL ui.interface.refresh()
END FUNCTION

FUNCTION mue_mensaje_espera(mensa,pos)
DEFINE mensa STRING
DEFINE pos SMALLINT
CASE 
  WHEN pos = 1 
    DISPLAY mensa TO message1
  WHEN pos = 2 
    DISPLAY mensa TO message2  
END CASE
CALL ui.interface.refresh()
END FUNCTION
---Funcion Finaliza El Mensaje
FUNCTION fin_mensaje_espera()
CLOSE WINDOW w_mensaje_espera
CALL ui.interface.refresh()
CALL ui.Interface.loadStyles("c_style")
END FUNCTION

FUNCTION fc_factura_mval2()
 DEFINE tp   RECORD
   pref         LIKE fc_factura_m.prefijo,
   numf         LIKE fc_factura_m.numfac,
   nit          LIKE fc_factura_m.nit,
   razsoc       LIKE fc_terceros.razsoc,
   valor        LIKE fe_factura_d.valor
 END RECORD,
  lastline, gotorow, prevrow, currrow, maxnum, pagenum INTEGER
 IF int_flag THEN
  LET int_flag = FALSE
 END IF
 LET lastline = 16
 LET maxnum = 0
 SELECT COUNT(*) INTO maxnum FROM fc_factura_m
  WHERE prefijo =mprefijo
 IF NOT maxnum THEN
   CALL FGL_WINMESSAGE( "Administrador", "NO HAY REGISTROS PARA VISUALIZAR  ", "stop") 
   LET tp.pref = NULL
   RETURN tp.pref
 END IF
 OPEN WINDOW w_vfcfact_m AT 8,32 WITH FORM "fe_facturaw"
 MESSAGE "Trabajando por favor espere ... " 
 DECLARE c_vfcfact_m SCROLL CURSOR FOR
  SELECT fc_factura_m.prefijo,fc_factura_m.numfac, fc_factura_m.nit, conta04.razsoc, 0 
  FROM fc_factura_m, conta04 
  WHERE fc_factura_m.nit = conta04.nit 
  AND fc_factura_m.prefijo=mprefijo 
  AND fc_factura_m.estado='A'
 ORDER BY  fc_factura_m.prefijo,fc_factura_m.numfac desc
 OPEN c_vfcfact_m
 LET currrow = 1
 LET prevrow = 1
 LET pagenum = 0
 CALL fcfact_mrow2( currrow,prevrow,pagenum ) RETURNING pagenum, prevrow 
 MESSAGE  "Localizacion : ( Actual ", currrow, "/ Existen ", maxnum, ")" 
 MENU ""
  COMMAND "Inmediato" "Se desplaza al siguiente registro en pantalla" 
   IF currrow = maxnum THEN
    LET currrow = 1
   ELSE
    LET currrow = currrow + 1
   END IF
   CALL fcfact_mrow2( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,"/ Existen ", maxnum, ")" 
  COMMAND "Anterior" "Se desplaza al anterior registro en pantalla"
   IF currrow = 1 THEN
    LET currrow = maxnum
   ELSE
    LET currrow = currrow - 1
   END IF
   CALL fcfact_mrow2( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,"/ Existen ", maxnum, ")" 
  COMMAND "Vaya" "Se desplaza al registro No.()."
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
   CALL fcfact_mrow2( currrow, prevrow, pagenum )
    RETURNING pagenum, prevrow 
   DISPLAY "" AT lastline,1
  MESSAGE  "Localizacion : ( Actual ", currrow,"/ Existen ", maxnum, ")" 
  COMMAND "Tomar" "Selecciona el registro actual"
   FETCH ABSOLUTE currrow c_vfcfact_m INTO tp.*
   EXIT MENU
  COMMAND KEY ("esc","S") "Salir" "Salir del menu actual" 
   INITIALIZE tp.* TO NULL
   EXIT MENU
 END MENU
 CLOSE c_vfcfact_m
 CLOSE WINDOW w_vfcfact_m
 RETURN tp.pref, tp.numf
END FUNCTION  

FUNCTION fcfact_mrow2( currrow, prevrow, pagenum )
 DEFINE mvalor decimal(12,0)
 DEFINE mdocumento LIKE fc_factura_m.documento
 DEFINE tp RECORD
   pref         LIKE fc_factura_m.prefijo,
   numf         LIKE fc_factura_m.numfac, 
   nit          LIKE fc_factura_m.nit,
   razsoc       LIKE fc_terceros.razsoc,
   valor        LIKE fe_factura_d.valor
  END RECORD,
  scrmax,scrcurr,scrprev,currrow,prevrow,pagenum,newpagenum,x,y,scrfrst INTEGER
 LET scrmax = 8
 LET mvalor = 0
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
  FETCH ABSOLUTE scrfrst c_vfcfact_m INTO tp.*
  LET mdocumento = 0
  SELECT documento INTO mdocumento
   FROM fc_factura_m
  WHERE fc_factura_m.numfac = tp.numf
   AND fc_factura_m.prefijo = tp.pref 
  SELECT sum( fe_factura_d.cantidad * ( fe_factura_d.valoruni + fe_factura_d.iva 
   + fe_factura_d.impc - fe_factura_d.subsi)) INTO mvalor
     FROM fe_factura_d
   WHERE  fe_factura_d.prefijo = tp.pref
    AND fe_factura_d.documento = mdocumento
   LET tp.valor = mvalor 
  FOR x = 1 TO scrmax
   IF x = scrcurr THEN
    DISPLAY tp.* TO prefv[x].* ATTRIBUTE(BLUE)
   ELSE
    DISPLAY tp.* TO prefv[x].*
   END IF
   IF x < scrmax THEN
    FETCH c_vfcfact_m INTO tp.*
     LET mdocumento = 0
     SELECT documento INTO mdocumento
      FROM fc_factura_m
     WHERE fc_factura_m.numfac = tp.numf
      AND fc_factura_m.prefijo = tp.pref 
     SELECT sum( fe_factura_d.cantidad * ( fe_factura_d.valoruni + fe_factura_d.iva 
       + fe_factura_d.impc - fe_factura_d.subsi)) INTO mvalor
       FROM fe_factura_d
      WHERE  fe_factura_d.prefijo = tp.pref
       AND fe_factura_d.documento = mdocumento
      LET tp.valor = mvalor 
     IF status = NOTFOUND THEN
     INITIALIZE tp.* TO NULL
     LET x = x + 1
     FOR y = x TO scrmax
      DISPLAY tp.* TO prefv[y].*
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
  FETCH ABSOLUTE prevrow c_vfcfact_m INTO tp.*
  LET mdocumento = 0
  SELECT documento INTO mdocumento
   FROM fc_factura_m
  WHERE fc_factura_m.numfac = tp.numf
   AND fc_factura_m.prefijo = tp.pref
  SELECT sum( fe_factura_d.cantidad * ( fe_factura_d.valoruni + fe_factura_d.iva 
   + fe_factura_d.impc - fe_factura_d.subsi)) INTO mvalor
     FROM fe_factura_d
   WHERE  fe_factura_d.prefijo = tp.pref
    AND fe_factura_d.documento = mdocumento
   LET tp.valor = mvalor
  DISPLAY tp.* TO prefv[scrprev].*
  FETCH ABSOLUTE currrow c_vfcfact_m INTO tp.*
  LET mdocumento = 0
  SELECT documento INTO mdocumento
   FROM fc_factura_m
  WHERE fc_factura_m.numfac = tp.numf
   AND fc_factura_m.prefijo = tp.pref
  SELECT sum( fe_factura_d.cantidad * ( fe_factura_d.valoruni + fe_factura_d.iva 
   + fe_factura_d.impc - fe_factura_d.subsi)) INTO mvalor
     FROM fe_factura_d
   WHERE  fe_factura_d.prefijo = tp.pref
    AND fe_factura_d.documento = mdocumento
   LET tp.valor = mvalor
  DISPLAY tp.* TO prefv[scrcurr].* ATTRIBUTE(BLUE)
 END IF
 LET prevrow = currrow
 RETURN pagenum, prevrow
END FUNCTION
