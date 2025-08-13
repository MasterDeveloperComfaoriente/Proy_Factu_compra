DATABASE empresa
GLOBALS
 DEFINE gcurso_empresa,tpcurso_empresa RECORD LIKE curso_empresa.*
 DEFINE gcurso_vendedor,tpcurso_vendedor RECORD LIKE curso_vendedor.*
 DEFINE gcurso_articulos,tpcurso_articulos RECORD LIKE curso_articulos.*
 DEFINE gcurso_cliente,tpcurso_cliente RECORD LIKE curso_cliente.*
 DEFINE gfactura_m,tpfactura_m RECORD LIKE fe_factura_m.*
 DEFINE gfe_compras,tpfe_compras RECORD LIKE fe_compras.*
 DEFINE gfe_mediosc,tpfe_mediosc,mfe_mediosc RECORD LIKE fe_medios_c.*
 DEFINE mfe_prefijos, tpprefijos, gprefijos RECORD LIKE fe_prefijos.*
 DEFINE mfe_terceros, tpterceros, gterceros RECORD LIKE fe_terceros.*
 DEFINE mfe_compras RECORD LIKE fe_compras.*
 DEFINE mfe_factura_ter RECORD LIKE fe_factura_ter.*
 DEFINE mfe_servicios RECORD LIKE fe_servicios.*
 DEFINE mfc_sub_servicios RECORD LIKE fe_sub_servicios.*
 DEFINE mfe_factura_d RECORD LIKE fe_factura_d.*
 DEFINE fefact_m RECORD LIKE fe_factura_m.*
 DEFINE fefact_medioc RECORD LIKE fe_medios_c.*
 DEFINE mfe_prefijos_usu RECORD LIKE fe_prefijos_usu.*
 DEFINE ggen291,tpgen291 RECORD LIKE gener29.*
 DEFINE mgener30 RECORD LIKE gener30.*
 DEFINE mgener29 RECORD LIKE gener29.*
 DEFINE mgener27 RECORD LIKE gener27.* 
 DEFINE mgener28 RECORD LIKE gener28.*
 DEFINE mgener11 RECORD LIKE gener11.*
 DEFINE mgener10 RECORD LIKE gener10.*
 DEFINE mgener12 RECORD LIKE gener12.*
 DEFINE mfecini, mfecfin,mdeffec1,mdeffec2,mfecha,mdeffec DATE 
 DEFINE msubsi15 RECORD LIKE subsi15.*
 DEFINE gjec_alumnos,tpjec_alumnos RECORD LIKE jec_alumnos.*
 DEFINE gjec_institucion,tpjec_institucion RECORD LIKE jec_institucion.*
 DEFINE gjec_docentes,tpjec_docentes RECORD LIKE jec_docentes.*
 DEFINE gjec_periodos,tpjec_periodos RECORD LIKE jec_periodos.*
 DEFINE gjec_doc_encuentro,tpjec_doc_encuentro RECORD LIKE jec_doc_encuentro.*
 DEFINE gjec_listado,tpjec_listado RECORD LIKE jec_listado.*
 DEFINE mensa    STRING
 DEFINE midesub LIKE subsi14.idesub
 DEFINE mprinom,msegnom LIKE subsi15.nombre
 DEFINE mFC1,mfe2 DATE
 DEFINE j,op char(1)
 DEFINE modimp,moptt char(1)
 DEFINE mcodmen,mtipfun char(4)
 DEFINE marchivo char(12)
 DEFINE ubicacion CHAR(80)
 DEFINE mnombre  LIKE gener02.nombre
 define mclave,mclaenc like gener02.clave
 define musuario integer
 DEFINE mdate1,mdate2 CHAR(10)
 DEFINE mcodapl  LIKE subsi01.codapl
 DEFINE mvent CHAR(2)
 DEFINE mvalor3 CHAR(40)
 define mcompag like gener28.consec
 DEFINE 
  mgener01 RECORD LIKE gener01.*,
  mgener02 RECORD LIKE gener02.*,
  mgener04 RECORD LIKE gener04.*,
  mgener07 RECORD LIKE gener07.*,
  mgener09 RECORD LIKE gener09.*,
  mgener25 RECORD LIKE gener25.*, 
  glastline, gerrflag, integer,
  gmaxarray, gmaxdply INTEGER,
  y, l, t SMALLINT
-- VARIABLES PARA EL MANIMP

 DEFINE mraya  char(17) 
 DEFINE mtipo,mtipesp   char(1)
 DEFINE mpos    integer 
 DEFINE mdefcop,mdefpag,mdeftam,mdefini,mdeffin INTEGER
 DEFINE mdefimp,mdeflet CHAR(15)
 DEFINE mdefnom CHAR(25)
 DEFINE mdeflin INTEGER 
 DEFINE mhoja CHAR(7)
 DEFINE mcodproy LIKE v_proyectos.codproy
 DEFINE b,c,d,e,f,g,h CHAR(1)
 DEFINE mtime CHAR(8)
 DEFINE mp1,mp2 INTEGER
 DEFINE mnucleo RECORD LIKE v_nucleo.*
 DEFINE nombre_archivo VARCHAR(40)
 --- DEFINICION DE VARIABLES 
 DEFINE mnomarc CHAR(50)
 #Variables Utilizadas por el Comprobante
DEFINE i,v INTEGER
DEFINE mcodcop LIKE conta11.codcop
DEFINE mdocumento LIKE conta14.documento
define mdeftit char(32)
define mdefpro char(23)
define mdefcp like conta11.codcop
DEFINE   mconta233n RECORD
  clase        LIKE conta233n.clase,
  grupo        LIKE conta233n.grupo,
  cta          LIKE conta233n.cta,
  subcta       LIKE conta233n.subcta,
  auxuno       LIKE conta233n.auxuno,
  auxdos       LIKE conta233n.auxdos,
  auxtre       LIKE conta233n.auxtre,
  nivel        LIKE conta233n.nivel,
  detalle      LIKE conta233n.detalle,
  tercero      LIKE conta233n.tercero,
  centros      LIKE conta233n.centros,
  activos      LIKE conta233n.activos,
  detalla      LIKE conta233n.detalla,
  banco        LIKE conta233n.banco,
  ajuste       LIKE conta233n.ajuste,
  dian         LIKE conta233n.dian,
  corriente    LIKE conta233n.corriente,
  salud        LIKE conta233n.salud,
  facret       LIKE conta233n.facret,
  estado       LIKE conta233n.estado,
  homologa     LIKE conta233n.homologa,
  auxiliarr    LIKE conta233n.auxiliarr,
  auxiliar     LIKE conta233n.auxiliar
END RECORD
DEFINE   mconta148n RECORD
  codcop       LIKE conta148n.codcop,
  detalle      LIKE conta148n.detalle,
  ultnum       LIKE conta148n.ultnum
END RECORD
define mdeffec,mfecha,mFC1,mfe2,mdeffec1,mdeffec2  DATE
define mfecini,mfecfin,mdeffec1,mdeffec2,fecha1,fecha2 DATE
DEFINE mdo     LIKE conta14.documento
DEFINE mcodconta LIKE conta328.codconta  
---Variables Subsidios
DEFINE msubsi02 RECORD LIKE subsi02.*
DEFINE msubsi12 RECORD LIKE subsi12.*
DEFINE msubsi16 RECORD LIKE subsi16.*
DEFINE gsub16, tpsub16  RECORD
  cedtra       LIKE subsi15.cedtra,
  priape       LIKE subsi15.priape,
  segape       LIKE subsi15.segape,
  nombre       LIKE subsi15.nombre
  END RECORD
DEFINE gasub16, tasub16 ARRAY[200] OF RECORD
  nit          LIKE subsi16.nit,
  razsoc       LIKE subsi02.razsoc,
  fecafi       LIKE subsi16.fecafi,
  fecret       LIKE subsi16.fecret
  END RECORD
DEFINE z INTEGER 
DEFINE mnit CHAR(15)
DEFINE mcedtra,mcedcon CHAR(12)
DEFINE mcodben char(7)
DEFINE mwhere,mselect CHAR(300)
DEFINE mdesempleo31 RECORD LIKE desempleo31.*
DEFINE mdesempleo11 RECORD LIKE desempleo11.*
DEFINE mff_asistencia RECORD LIKE ff_asistencia.*
DEFINE mff_curso RECORD LIKE ff_curso.*
DEFINE tpff_bonos_pagos,gff_bonos_pagos,mff_bonos_pagos RECORD LIKE ff_bonos_pagos.*
DEFINE l_cadena INTEGER 
--DEFINE mensa CHAR(60)

END GLOBALS