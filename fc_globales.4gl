DATABASE empresa 

GLOBALS DEFINE 

  glastline, gerrflag, gmaxarray, gmaxdply SMALLINT, 
  y, l, t, i, j, k, z, cnt, cntt integer,
  a, mx char(1)
  DEFINE mest_servicios RECORD LIKE est_servicios.*
  DEFINE mesini, mesfin integer
  DEFINE mnit  char(20)
  DEFINE lr_usuario_pc RECORD LIKE usuario_pc.* 
  define mdeftit char(45)
  define mdefpro char(35)
  DEFINE mselect char(800)
  define mwhere char(300)
  DEFINE mdate1,mdate2 CHAR(10)
  DEFINE mnombre, mnombre2  char(40)
  DEFINE mcodapl  LIKE subsi01.codapl
  DEFINE musuario INTEGER 
  define mclave,mclaenc like gener02.clave
  DEFINE mcodmen  LIKE gener03.codmen
  DEFINE mfecha,mfecha1,mfecha2 DATE
  define mdefano,mdefmes integer
  DEFINE mhora,mho_con,mtime CHAR(8)
  DEFINE ayu char(1) 
  DEFINE mventana ui.Window
  DEFINE continuar integer
  DEFINE mforma ui.Form
  DEFINE mnota char(40)
  DEFINE mpriape, msegape, mprinom, msegnom char(30)
  DEFINE mensa CHAR(150)
-- VARIABLES PARA EL MANIMP DEFINE mraya  char(17) 
 DEFINE mp1 integer
 DEFINE op char(1)
 DEFINE mtipo,mtipesp   char(1)
 DEFINE mpos    integer 
 DEFINE mdefcop,mdefpag,mdeftam,mdefini,mdeffin INTEGER
 DEFINE mdefimp,mdeflet CHAR(15)
 DEFINE mdefnom CHAR(25)
 DEFINE mdeflin INTEGER 
 DEFINE mhoja CHAR(7)
 DEFINE w, v integer
 DEFINE mcodzon char(9)
 DEFINE b,c,d,e,f,g,h,mdigver CHAR(1)
 DEFINE mdo char(7)
 DEFINE mgener01 record like gener01.*
 DEFINE mgener02,mgener02p,mgen02 record like gener02.*
 DEFINE mgener04 record like gener04.*
 DEFINE mgener08 record like gener08.*
 DEFINE mdia, mmes, mano integer
 DEFINE mper integer
 DEFINE factor decimal(10,2)
 DEFINE mfecini, mfecfin, mdeffec1, mdeffec2, mdeffec date
 DEFINE localiza1, localiza2, localiza3 char(80)
 DEFINE mejecuta  char(200)
 DEFINE mtotgen decimal(12,0)
-- VARIABLES PARA TODAS LAS TABLAS
 DEFINE mcre_forpago record like cre_forpago.*
 DEFINE mcre_tipviv record like cre_tipviv.*
 DEFINE mcre_tiposcre record like cre_tiposcre.*
 DEFINE mcre_cat_riesgo record like cre_cat_riesgo.*
 DEFINE mcre_cat_afil record like cre_cat_afil.*
 DEFINE mcre_scorp record like cre_scorp.*
 DEFINE mcre_scor2 record like cre_scor2.*
 DEFINE mcre_tipgar RECORD LIKE cre_tipgar.*
 DEFINE mcodcar like cre_conceptos.codcar
 DEFINE mcodlin like cre_lineas.codlin
 DEFINE mplanp like cre_creditos.planp
 DEFINE mnumcuo integer
 DEFINE tasan, tasan2  decimal(8,6)
 DEFINE tasasub like cre_tasasi.tasae
 DEFINE m_tml like cre_tasaso.tml_e
 DEFINE mvalcon ARRAY[7] OF decimal(12,0)
 define mcontit ARRAY[7] OF CHAR(2)
 DEFINE mvalcuo, mvalint, mintsub, mvalcap, mvalsal, mvalsub decimal(12,0)
 DEFINE mvalcuota LIKE cre_planp_m.salbasliq
 DEFINE mtotint decimal(12,0)
 DEFINE mfecpag, mfeccie  date
 DEFINE mrazon char(35)
 DEFINE mrazon2 char(50)
 DEFINE mestnue like cre_histest.estnue
 DEFINE mgener07 record like gener07.*
 DEFINE mgener09 record like gener09.*
 DEFINE mgener15 record like gener15.*
 DEFINE msubsi02 record like subsi02.*
 DEFINE msubsi10 record like subsi10.*
 DEFINE msubsi11 record like subsi11.*
 DEFINE msubsi12 record like subsi12.*
 DEFINE msubsi13 record like subsi13.*
 DEFINE msubsi15 record like subsi15.*
 DEFINE msubsi20 record like subsi20.*
 DEFINE msubsi22 record like subsi22.*
 DEFINE msubsi04 RECORD LIKE subsi04.*
 DEFINE mfc_empresa RECORD LIKE fc_empresa.*
 DEFINE mfc_moneda RECORD LIKE fc_moneda.*
 DEFINE mfc_prefijos, tpprefijos, gprefijos   RECORD LIKE fc_prefijos.*
 DEFINE mfc_prefijos, tpprefijos, gprefijos   RECORD
    prefijo char(5) ,
    descripcion char(50) ,
    numini integer ,
    numfin integer  ,
    numero integer,
    num_auto char(50)  ,
    fec_auto date  ,
    fec_ven date,
    direccion char(50)  ,
    zona char(9) ,
    dias_cred integer  ,
    telefono char(7),
    conta char(1),
    tarifa_vigente char(4),
    redondeo char(1),
    nota VARCHAR(100,0),
    estado char(1)  ,
    fecsis date  ,
    usuario integer 
  END RECORD  
  
 DEFINE mfc_terceros, tpterceros, gterceros RECORD LIKE fc_terceros.*
 DEFINE mfc_servicios, tpservicios, gservicios RECORD LIKE fc_servicios.*
 DEFINE mfc_sub_servicios, tpsub_servicios, gsub_servicios RECORD LIKE fc_sub_servicios.*
 DEFINE mfc_tarifas, tptarifas, gtarifas RECORD LIKE fc_tarifas.*
 DEFINE mfc_prefijos_usu RECORD LIKE fc_prefijos_usu.*
 DEFINE mfe_pais RECORD LIKE fe_pais.*
 DEFINE mfc_tipid RECORD LIKE fc_tipid.*
 DEFINE mfc_facturador RECORD LIKE fc_facturador.*
 DEFINE mfc_factura_m RECORD LIKE fc_factura_m.*
 DEFINE mfc_factura_d RECORD LIKE fc_factura_d.*
 DEFINE mfc_factura_anti RECORD LIKE fc_factura_anti.*
 DEFINE mfc_factura_imp  RECORD LIKE fc_factura_imp.*
 DEFINE mfc_factura_tot  RECORD LIKE fc_factura_tot.*
 DEFINE mfc_conta1,gfc_conta1, tpfc_conta1 RECORD LIKE fc_conta1.*
 DEFINE mfc_conta3,gfc_conta3, tpfc_conta3 RECORD LIKE fc_conta3.*
 DEFINE mfc_conta2,gfc_conta2, tpfc_conta2 RECORD LIKE fc_conta2.*
 DEFINE gfc_proveedores,tpfe_proveedores,tpcom_proveedores RECORD LIKE fc_terceros.*
 DEFINE mfc_categorias RECORD LIKE fc_categorias.* 
 DEFINE mconta328 RECORD LIKE conta328.*
 DEFINE rec_subsi04 RECORD LIKE subsi04.*
 DEFINE mfc_beneficios,tpbeneficios,gbeneficios RECORD 
    codigo               char(2),
    descripcion          char(30),   
    auxiliardb           char(12),  
    auxiliarcr           char(12),
    codcop               char(4),
    codcop2              char(4),
    estado               char(1),
    fecsis               date,
    usuario              integer
 END RECORD
 define mdocumento char(7)
 DEFINE mdocini, mdocfin like cre_creditos.doccre
 DEFINE mind integer
 define mconta01 record like conta01.*
 define mconta04 record like conta04.*
 define mconta09n record like conta09n.*
 define mconta13n record like conta13n.*
 DEFINE mniif13 RECORD LIKE niif13.*
 define mconta332 record like conta332.*
 define mconta141n record like conta141n.*
 define mconta142n record like conta142n.*
 define mconta143n record like conta143n.*
 define mconta144n record like conta144n.*
 define mconta202n record like conta202n.*
 define mniif141 record like niif141.*
 define mniif142 record like niif142.*
 define mniif142_eps record like niif142_eps.*
 define mniif143 record like niif143.*
 define mniif144 record like niif144.*
 define mniif148 record like niif148.*
 define mcre_enlaces record like cre_enlaces.*
 define mcre_enlaces_niif record like cre_enlaces_niif.*
 define mcodconta char(2)
 define mcodcop char(4)
 define mtipcru char(2)
 define mnivel char(1)
 define mdato char(27)
 define mdebi, mcredi, mdi decimal(14,2)
 define mcodcen char(4)
 define mvalor decimal(12,2)
 define mpunto like cre_histpag_m.codpun
 define salir integer
 define mrecibo_pago like cre_histpag_m.numrec
 define x, lerr integer 
 define  mcon233, mconta233n, gcon2331, tpcon2331, mconta233   RECORD
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
 DEFINE mconni233, tpcon2331_niif, tpcon_ni2331 RECORD
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
  auxiliar     LIKE conta233n.auxiliar
 END RECORD
 --DEFINE mniif233 RECORD LIKE niif233.*
 DEFINE mauxini,mauxinii,mauxfin,mauxfinn,mauxiliar,mauxiliarr,mauxiliardian,
    mauxiniret,mauxfinret, mauxiniiva,mauxfiniva  LIKE conta02.auxiliar
 DEFINE maux4 char(4)
 DEFINE mnumdig  LIKE conta01.numdig
 DEFINE mcla     LIKE conta01.clase
 DEFINE mgru     LIKE conta01.grupo
 DEFINE mcta     LIKE conta01.cta
 DEFINE msct     LIKE conta01.subcta
 DEFINE maux1    LIKE conta01.auxuno
 DEFINE maux2    LIKE conta01.auxdos
 DEFINE maux3    LIKE conta01.auxtre
 DEFINE mtotajus   DECIMAL(12,0)
 DEFINE tpdifpag ARRAY[500] OF RECORD
  nit           LIKE cre_difpagos.nit,
  mnomter       char(30),
  valor         LIKE cre_difpagos.valor,
  tipo          LIKE cre_difpagos.tipo
 END RECORD
 define  mefecto ARRAY[100] OF RECORD  
  tipcru       LIKE conta145n.tipcru,
  nocts        LIKE conta145n.nocts,
  doccru       LIKE conta142n.doccru,
  codcen       LIKE conta145n.codcen,
  fecven       LIKE conta145n.fecven,
  valor        LIKE conta145n.saldo
END RECORD
DEFINE mefeval ARRAY[100] OF RECORD  
  codcen        LIKE conta145n.codcen,
  nocts        LIKE conta145n.nocts,
  doccru       LIKE conta142n.doccru,
  fecven       LIKE conta145n.fecven,
  saldo        LIKE conta145n.saldo,
  mx           CHAR(1)
END RECORD
DEFINE gfc_factura_m,tpfc_factura_m, mmfc_factura_m RECORD
  prefijo             LIKE fc_factura_m.prefijo,--si va
  documento           LIKE fc_factura_m.documento,--si va
  numfac              LIKE fc_factura_m.numfac,--si va
  cufe                LIKE fc_factura_m.cufe,--si va
  fecha_elaboracion   LIKE fc_factura_m.fecha_elaboracion,--si va
  fecha_factura       LIKE fc_factura_m.fecha_factura,--si va
  hora                LIKE fc_factura_m.hora,--si va
  nit                 LIKE fc_factura_m.nit,--si va
  cedtra              LIKE fc_factura_m.cedtra,--si va
  forma_pago          LIKE fc_factura_m.forma_pago,--si va
  medio_pago          LIKE fc_factura_m.medio_pago,--si va
  fecha_vencimiento   LIKE fc_factura_m.fecha_vencimiento,--si va
  nota1               LIKE fc_factura_m.nota1,
  estado              LIKE fc_factura_m.estado,--si va
  codest              LIKE fc_factura_m.codest,--si va
  fecest              LIKE fc_factura_m.fecest,--si va 
  horaest             LIKE fc_factura_m.horaest,--si va
  codcop              LIKE fc_factura_m.codcop,--si va
  docu                LIKE fc_factura_m.docu--si va
END RECORD

DEFINE gfc_nota_m,tpfc_nota_m RECORD
  tipo                LIKE fc_nota_m.tipo,
  documento           LIKE fc_nota_m.documento,
  numnota             LIKE fc_nota_m.numnota,
  fecha_elaboracion   LIKE fc_nota_m.fecha_elaboracion,
  fecha_nota          LIKE fc_nota_m.fecha_nota,
  hora                LIKE fc_nota_m.hora,
  tipo_nota           LIKE fc_nota_m.tipo_nota,
  tipo_nota_c         LIKE fc_nota_m.tipo_nota_c,
  prefijo             LIKE fc_nota_m.prefijo,
  numfac              LIKE fc_nota_m.numfac,
  cude                LIKE fc_nota_m.cude,
  nota1               LIKE fc_nota_m.nota1,
  estado              LIKE fc_nota_m.estado,
  codest              LIKE fc_nota_m.codest,
  fecest              LIKE fc_nota_m.fecest,
  horaest             LIKE fc_nota_m.horaest,
  codcop              LIKE fc_nota_m.codcop,
  docu                LIKE fc_nota_m.docu  
END RECORD

DEFINE gafc_nota_m, tafc_nota_m ARRAY[50] OF RECORD 
  codigo      LIKE fc_nota_d.codigo,
  descripcion LIKE fc_servicios.descripcion,
  subcodigo   LIKE fc_nota_d.subcodigo,
  descri      LIKE fc_sub_servicios.descripcion,
  descrii     LIKE fc_beneficios.descripcion,
  cantidad    LIKE fc_nota_d.cantidad,
  valoruni    LIKE fc_nota_d.valoruni,
  iva         LIKE fc_nota_d.iva,
  impc        LIKE fc_nota_d.impc,
  valor       LIKE fc_nota_d.valor
END RECORD
 define mniif233,mcon233iva,mcon233ing,mcon233impc,mcon233car, mcon233sub, mcon233ant, mcon233subsi, mcon233ant RECORD LIKE niif233.*
 define mniif147,mcon147iva,mcon147ing,mcon147impc,mcon147car, mcon147sub, mcon147ant, mcon147subsi, mcon147ant RECORD LIKE niif147.*
 define mcon233caja, mcon233banco, mcon233cars RECORD LIKE niif233.*
 define mcon147caja, mcon147banco, mcon147cars RECORD LIKE niif147.*
 
 define mcon233ef,mcon233tc,mcon233td,mcon233co,mcon233ch,mcon233tr RECORD LIKE niif233.*
 define mcon147ef,mcon147tc,mcon147td,mcon147co, mcon147ch, mcon147tr RECORD LIKE niif147.*
 define mgener10 RECORD LIKE gener10.*
 define mgener11 RECORD LIKE gener11.*
 define mgener12 RECORD LIKE gener12.*
 define mvalche DECIMAL(14,2)
 define mletras1,mletras2,mdato0,mdato1,mdato2 char(70)
 DEFINE mcansal decimal(10,2)
 DEFINE mcodcat char(1)
 DEFINE mpersal char(6)
 DEFINE msalario LIKE subsi15.salario
 DEFINE msubsi17 RECORD LIKE subsi17.*
 DEFINE msubsi30 RECORD LIKE subsi30.*
 DEFINE mfc_nota_m RECORD LIKE fc_nota_m.*
 DEFINE mfc_nota_d RECORD LIKE fe_nota_d.*
 DEFINE mfc_factura_ter RECORD LIKE fc_factura_ter.*
 DEFINE mcodser LIKE fc_servicios.codigo
 DEFINE mtipcru  char(2)
 DEFINE mconta24n RECORD LIKE conta24n.*
 DEFINE mmarca2 char(4)
 DEFINE mentra char(1)
 DEFINE mprefijo    LIKE fc_factura_m.prefijo
 DEFINE tpmnota char(2)
 DEFINE mnumfac     LIKE fc_factura_m.numfac  
 define ubicacion, ubicacion2 char(150)
----globales add Danny
 DEFINE gfactura_m,tpfactura_m RECORD LIKE fc_factura_m.*
 DEFINE gfc_compras,tpfc_compras RECORD LIKE fc_compras.*
 DEFINE gfe_mediosc,tpfe_mediosc,mfe_mediosc RECORD LIKE fc_medios_c.*
 DEFINE mfc_compras RECORD LIKE fc_compras.*
 DEFINE mrazsoc  char(50)
 DEFINE fcfact_m RECORD LIKE fc_factura_m.*
 DEFINE fcfact_medioc RECORD LIKE fc_medios_c.*
 DEFINE tpfc_estados,gfc_estados,mfc_estados,mfe_estemail,mfe_estdisp RECORD LIKE fc_estados.*
 DEFINE tpfc_estados_fac,gfc_estados_fac RECORD LIKE fc_estados_fac.*
 DEFINE mfe_unidades RECORD LIKE fe_unidades.* 
 DEFINE mteroblig,mterobligp,mterobl record like fe_tipobligacion.*
 DEFINE mfc_nota_imp RECORD LIKE fc_nota_imp.*
 DEFINE mfc_nota_tot RECORD LIKE fc_nota_tot.*
 DEFINE mfc_estados_fac RECORD LIKE fc_estados_fac.* 
 DEFINE mfc_terobligacion RECORD LIKE fc_terobligacion.*
TYPE dato RECORD
        codigo CHAR(5),
        descripcion CHAR (50),
        cantidad DECIMAL (12,2),
        valor_unitario DECIMAL (12,2),
        valor_total DECIMAL (12,2)
    END RECORD

TYPE datos DYNAMIC ARRAY OF dato
 ------
DEFINE handler om.SaxDocumentHandler
  ,lb_preview        BOOLEAN
    ,salida_reporte    VARCHAR(20)
   ,tipo_grafico       VARCHAR(100) 
   ,lv_nombre_reporte  VARCHAR(100)
   ,nombre_plantilla   VARCHAR(100)

 ------
 TYPE tipo_doc_por_prex RECORD
    fecha DATE,
    document CHAR(7),
    nit CHAR(20),
    total DECIMAL (12,2)
END RECORD 

TYPE documentos_prex DYNAMIC ARRAY OF tipo_doc_por_prex
DEFINE opc_sal CHAR (4)
DEFINE rec_fc_nota_ajuste RECORD LIKE fc_nota_ajuste.*
DEFINE valida SMALLINT
DEFINE  mclave_seguridad VARCHAR (120)
DEFINE ip_adress STRING 

END GLOBALS 












