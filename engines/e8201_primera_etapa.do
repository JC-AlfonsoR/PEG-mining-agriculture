*******************************************************
** Identificación con Variables Instrumentales
** ANALISIS DE PRIMERA ETAPA
** Mineral: Oro
**
** Instrumento: Potencial mineral X precio mineral
** X: Minería ilegal
** Y: Producción agrícola
*******************************************************

*******************************************************

********************************************************
**# Consideraciones
********************************************************

* Indicadores de potencial minero de oro en roca:
* 1.poteMine_oro_area_roca_m2:  area en m^2 con potencial aurifero de roca
* 2.poteMine_oro_distnc_roca_m: distancia del centroide del municipio a una 
*								zona de potencial aurifero de roca
* 3.poteMine_oro_pctMun_roca_pct: porcentaje del area municipal cubierta
* 								por una zona de potencial aurifero de roca
* 
* Elijo la 3 como principal porque es la única que no depende de la extensión
* del municipio, es decir que es la única que no confunde tamaño del municipio
* con potencial.
* Voy a usar 1 y 2 como robustez:
* Al indicador de area (1) le voy a aplicar una transformación logaritmica o
* de seno asintotico para manejar los valores extremos que puede presentar
* Al indicador de distancia lo voy a convertir en un indicador de "proximidad"
* del estilo 1+1/distancia para suavizar valores extremos (distancia=0) y 
* para que la interpretación de los coeficientes sea en sentido positivo (i.e 
* un coeficiente positivo indicaría que a mayor proximidad al potencial mineral
* en roca hay mayor producción legal de oro y viceversa.)


* Indicadores de produccion legal de oro:
* 1: mineLegl_oro_pRegls_prod_gr: gramos reportados para regalías
* 2: mineLegl_oro_pRegls_valr_COP: Valor en COP de la produccion asociada a regalías
* Elijo la 1 como principal y la 2 como prueba de robustez. Las cantidades producidas
* son literalmente el volumen de producción mientras que el valor en COP está
* afectado por el precio.


*******************************************************
**# Cargar panel final y preparar variables del analisis
*******************************************************
* Ejecutar desde e8000_master.do despues de e8001, e8050 y e8051.
* Las rutas se definen en e8001. Esta rutina no reconstruye el panel.
if "$panel_analisis" == "" {
    display as error "Ejecuta e8001_configurar.do antes de esta rutina."
    exit 198
}

use "$panel_analisis", clear
isid codigo_dane_municipio anno


* Conservar las variables de interes
keep codigo_dane_municipio anno ///
    poteMine_oro_distnc_roca_m poteMine_oro_distnc_aluv_m ///
    mineLegl_oro_pRegls_prod_gr mineLegl_oro_pRegls_valr_COP ///
    tituMine_oro_AreaSo_tGrn_m2Fx tituMine_oro_AreaSo_tOtr_m2Fx ///
	tituMine_oro_AreaTi_tGrn_m2Fx tituMine_oro_AreaTi_tOtr_m2Fx ///
    mineIleg_oro_nwPrp_SR21_pct precMine_oro_prmdio_oro_USoz

********************************************************
**# Transformar variables
********************************************************

* Potencial de oro en cualquier recurso: distancia minima en metros.
gen poteMine_oro_distnc = min(poteMine_oro_distnc_roca_m, poteMine_oro_distnc_aluv_m)

* Transformar distancia en proximidad para facilitar la interpretacion.
* Convertir metros a kilometros; la formula es finita si distancia = 0.
gen proximidad_potencial_gnrl = 1 / (1 + poteMine_oro_distnc/1000)
gen proximidad_potencial_roca = 1 / (1 + poteMine_oro_distnc_roca_m/1000)
gen proximidad_potencial_aluvion = 1 / (1 + poteMine_oro_distnc_aluv_m/1000)

* Transformaciones logaritmicas
gen log_mineLegl_oro_prod_gr = log(1+mineLegl_oro_pRegls_prod_gr)
gen log_mineLegl_oro_valr_COP = log(1+mineLegl_oro_pRegls_valr_COP)

* Calcular flujo total de area SOLICITADA para mineria de oro en cada municipio-año
gen tituMine_oro_AreaSo_total_m2Fx  = tituMine_oro_AreaSo_tGrn_m2Fx + tituMine_oro_AreaSo_tOtr_m2Fx
gen log_tituMine_oro_AreaSo_total = log(1+tituMine_oro_AreaSo_total_m2Fx)

* Calcular flujo total de area TITULADA para mineria de oro en cada municipio-año
gen tituMine_oro_AreaTi_total_m2Fx  = tituMine_oro_AreaTi_tGrn_m2Fx + tituMine_oro_AreaTi_tOtr_m2Fx
gen log_tituMine_oro_AreaTi_total = log(1+tituMine_oro_AreaTi_total_m2Fx)

********************************************************
**# Especificacion principal
********************************************************



* Definir las variables del modelo

local potencial_mineral_roca proximidad_potencial_roca 
local potencial_mineral_aluvion proximidad_potencial_aluvion
local potencial_mineral_gnrl proximidad_potencial_gnrl
local mineria_legal log_mineLegl_oro_prod_gr
local intencion_mineria_legal log_tituMine_oro_AreaSo_total

* Minería ilegal:
* mineIleg_oro_area_SR21_km2 mineIleg_oro_nwPrp_SR21_pct mineIleg_oro_prpMun_SR21_pct
local mineria_ilegal mineIleg_oro_nwPrp_SR21_pct
* La definición de la variable en SR2021, está en el dofile 01_Create_Stata_DataSet_forreg.do de su repositorio, en la línea 449:
* label var newpropminedMi_illegal "Share of new mined area mined illegaly"


* La especifciacion principal es con el precio promedio anual
* El precio anual max y min se usarán para revisar hipotesis de auge/declive
local precio_mineral precMine_oro_prmdio_oro_USoz


* Conservar solo las variables de interes
keep codigo_dane_municipio anno `potencial_mineral_roca' `potencial_mineral_aluvion' `potencial_mineral_gnrl' `mineria_legal' `mineria_ilegal' `intencion_mineria_legal' `precio_mineral'



* Definir las variables del modelo



********************************************************
**# Sección transversal
********************************************************
* Voy a probar la primera etapa en cada uno de los años disponibles
* Busco responder a la pregunta ¿Los municipios con mayor potencial aurífero 
* presentan, en promedio, mayor actividad minera legal?


*******************************************************
**## Minería Legal
*    ┏┳┓╻┏┓╻┏━╸┏━┓╻┏━┓   ╻  ┏━╸┏━╸┏━┓╻  
*    ┃┃┃┃┃┗┫┣╸ ┣┳┛┃┣━┫   ┃  ┣╸ ┃╺┓┣━┫┃  
*    ╹ ╹╹╹ ╹┗━╸╹┗╸╹╹ ╹   ┗━╸┗━╸┗━┛╹ ╹┗━╸
*******************************************************
* La especificacion principal es con 
* Potencial: proximidad_potencial_roca 
* Produccion legal: log_mineLegl_oro_prod_gr


*******************************************************
**### Roca
*******************************************************
* Explorar los cortes transversales de cada año
* Minería legal explicada por Potencial de roca
preserve
	
	* Eliminar datos faltantes
	drop if missing(codigo_dane_municipio, `mineria_legal')

	* Estimar una regresión transversal por año
	statsby ///
		b_roca  = _b[`potencial_mineral_roca'] ///
		se_roca    = _se[`potencial_mineral_roca'] ///
		n     = e(N) ///
		f_stat = e(F) ///
		r2    = e(r2) ///
		df_r  = e(df_r), ///
		by(anno) clear: ///
		regress `mineria_legal' ///
			`potencial_mineral_roca', ///
			vce(robust)

	* Valor p de H0: b_roca = 0
	gen pv_roca = 2 * ttail(df_r, abs(b_roca / se_roca))

	* Eliminar variable auxiliar
	drop df_r

	* Formato y presentación
	format b_roca se_roca f_stat r2 pv_roca %9.4f

	display "=========================================="
    display "Sección transversal para cada año"
	display "X: Potencial mineral en roca medido como: `potencial_mineral_roca'"
	display "Y: Minería legal medida como: `mineria_legal'"
    display "=========================================="
	
	* Mostrar valores
	list anno n b_roca se_roca pv_roca f_stat r2, noobs

restore

*******************************************************
**### Aluvion + Roca
*******************************************************
* Explorar los cortes transversales de cada año
* Minería legal explicada por Potencial de roca y potencial de aluvion
preserve
	
	* Eliminar datos faltantes
	drop if missing(codigo_dane_municipio, `mineria_legal')

	* Estimar una regresión transversal por año
	statsby ///
		b_roca  = _b[`potencial_mineral_roca'] ///
		se_roca    = _se[`potencial_mineral_roca'] ///
		b_aluv = _b[`potencial_mineral_aluvion'] ///
		se_aluv = _se[`potencial_mineral_aluvion'] ///
		n     = e(N) ///
		f_stat = e(F) ///
		r2    = e(r2) ///
		df_r  = e(df_r), ///
		by(anno) clear: ///
		regress `mineria_legal' ///
			`potencial_mineral_roca' `potencial_mineral_aluvion', ///
			vce(robust)

	* Valor p de H0: beta = 0
	gen pv_roca = 2 * ttail(df_r, abs(b_roca / se_roca))
	gen pv_aluv = 2 * ttail(df_r, abs(b_aluv / se_aluv))

	* Eliminar variable auxiliar
	drop df_r

	* Formato y presentación
	format b_roca se_roca pv_roca f_stat r2  b_aluv pv_aluv se_aluv %9.4f

	display "=========================================="
    display "Sección transversal para cada año"
	display "X1: Potencial mineral en roca medido como: `potencial_mineral_roca'"
	display "X2: Potencial mineral en aluvion medido como: `potencial_mineral_aluvion'"
	display "Y: Minería legal medida como: `mineria_legal'"
    display "=========================================="
	
	* Mostrar valores
	list anno n b_roca se_roca pv_roca b_aluv se_aluv pv_aluv  f_stat r2, noobs

restore


*******************************************************
**## Intención M. legal
*    ╻┏┓╻╺┳╸┏━╸┏┓╻┏━╸╻┏━┓┏┓╻   ┏┳┓    ╻  ┏━╸┏━╸┏━┓╻  
*    ┃┃┗┫ ┃ ┣╸ ┃┗┫┃  ┃┃ ┃┃┗┫   ┃┃┃    ┃  ┣╸ ┃╺┓┣━┫┃  
*    ╹╹ ╹ ╹ ┗━╸╹ ╹┗━╸╹┗━┛╹ ╹   ╹ ╹╹   ┗━╸┗━╸┗━┛╹ ╹┗━╸
*******************************************************

*******************************************************
**### Aluvion
*******************************************************
* Explorar los cortes transversales de cada año
* Intención de minería legal explicada por Potencial de roca y potencial de aluvion

preserve
	
	* Eliminar datos faltantes
	drop if missing(codigo_dane_municipio, `intencion_mineria_legal')

	* Estimar una regresión transversal por año
	statsby ///
		b_aluv = _b[`potencial_mineral_aluvion'] ///
		se_aluv = _se[`potencial_mineral_aluvion'] ///
		n     = e(N) ///
		f_stat = e(F) ///
		r2    = e(r2) ///
		df_r  = e(df_r), ///
		by(anno) clear: ///
		regress `intencion_mineria_legal' ///
			`potencial_mineral_aluvion', ///
			vce(robust)

	* Valor p de H0: beta = 0
	gen pv_aluv = 2 * ttail(df_r, abs(b_aluv / se_aluv))

	* Eliminar variable auxiliar
	drop df_r

	* Formato y presentación
	format f_stat r2  b_aluv pv_aluv se_aluv %9.4f

	display "=========================================="
    display "Sección transversal para cada año"
	display "X: Potencial mineral en aluvion medido como: `potencial_mineral_aluvion'"
	display "Y: Intención de Minería legal medida como: `intencion_mineria_legal'"
    display "=========================================="
	
	* Mostrar valores
	list anno n b_aluv se_aluv pv_aluv  f_stat r2, noobs

restore


*******************************************************
**### Roca
*******************************************************
* Explorar los cortes transversales de cada año
* Intención de minería legal explicada por Potencial de roca y potencial de aluvion
preserve
	
	* Eliminar datos faltantes
	drop if missing(codigo_dane_municipio, `intencion_mineria_legal')

	* Estimar una regresión transversal por año
	statsby ///
		b_roca  = _b[`potencial_mineral_roca'] ///
		se_roca    = _se[`potencial_mineral_roca'] ///
		n     = e(N) ///
		f_stat = e(F) ///
		r2    = e(r2) ///
		df_r  = e(df_r), ///
		by(anno) clear: ///
		regress `intencion_mineria_legal' ///
			`potencial_mineral_roca', ///
			vce(robust)

	* Valor p de H0: b_roca = 0
	gen pv_roca = 2 * ttail(df_r, abs(b_roca / se_roca))

	* Eliminar variable auxiliar
	drop df_r

	* Formato y presentación
	format b_roca se_roca f_stat r2 pv_roca %9.4f

	display "=========================================="
    display "Sección transversal para cada año"
	display "X: Potencial mineral en roca medido como: `potencial_mineral_roca'"
	display "Y: Intención de Minería legal medida como: `intencion_mineria_legal'"
    display "=========================================="
	
	* Mostrar valores
	list anno n b_roca se_roca pv_roca f_stat r2, noobs

restore


*******************************************************
**### Aluvion + Roca
*******************************************************
* Explorar los cortes transversales de cada año
* Minería legal explicada por Potencial de roca y potencial de aluvion
preserve
	
	* Eliminar datos faltantes
	drop if missing(codigo_dane_municipio, `intencion_mineria_legal')

	* Estimar una regresión transversal por año
	statsby ///
		b_roca  = _b[`potencial_mineral_roca'] ///
		se_roca    = _se[`potencial_mineral_roca'] ///
		b_aluv = _b[`potencial_mineral_aluvion'] ///
		se_aluv = _se[`potencial_mineral_aluvion'] ///
		n     = e(N) ///
		f_stat = e(F) ///
		r2    = e(r2) ///
		df_r  = e(df_r), ///
		by(anno) clear: ///
		regress `intencion_mineria_legal' ///
			`potencial_mineral_roca' `potencial_mineral_aluvion', ///
			vce(robust)

	* Valor p de H0: beta = 0
	gen pv_roca = 2 * ttail(df_r, abs(b_roca / se_roca))
	gen pv_aluv = 2 * ttail(df_r, abs(b_aluv / se_aluv))

	* Eliminar variable auxiliar
	drop df_r

	* Formato y presentación
	format b_roca se_roca pv_roca f_stat r2  b_aluv pv_aluv se_aluv %9.4f

	display "=========================================="
    display "Sección transversal para cada año"
	display "X1: Potencial mineral en roca medido como: `potencial_mineral_roca'"
	display "X2: Potencial mineral en aluvion medido como: `potencial_mineral_aluvion'"
	display "Y: Intención de Minería legal medida como: `intencion_mineria_legal'"
    display "=========================================="
	
	* Mostrar valores
	list anno n b_roca se_roca pv_roca b_aluv se_aluv pv_aluv  f_stat r2, noobs

restore


*******************************************************
**## Minería Ilegal
*    ┏┳┓╻┏┓╻┏━╸┏━┓╻┏━┓   ╻   ╻  ┏━╸┏━╸┏━┓╻  
*    ┃┃┃┃┃┗┫┣╸ ┣┳┛┃┣━┫   ┃╺━╸┃  ┣╸ ┃╺┓┣━┫┃  
*    ╹ ╹╹╹ ╹┗━╸╹┗╸╹╹ ╹   ╹   ┗━╸┗━╸┗━┛╹ ╹┗━╸
*******************************************************

* La especificacion principal es con 
* Potencial: proximidad_potencial_aluvion
* Mineria ilegal: mineIleg_oro_nwPrp_SR21_pct

*******************************************************
**### Aluvion
*******************************************************

* Explorar los cortes transversales de cada año
preserve
	
	* Eliminar datos faltantes
	drop if missing(codigo_dane_municipio, `mineria_ilegal')

	* Estimar una regresión transversal por año
	statsby ///
		b_aluv = _b[`potencial_mineral_aluvion'] ///
		se_aluv = _se[`potencial_mineral_aluvion'] ///
		n     = e(N) ///
		f_stat = e(F) ///
		r2    = e(r2) ///
		df_r  = e(df_r), ///
		by(anno) clear: ///
		regress `mineria_ilegal' ///
			`potencial_mineral_aluvion', ///
			vce(robust)

	* Valor p de H0: beta = 0
	gen pv_aluv = 2 * ttail(df_r, abs(b_aluv / se_aluv))

	* Eliminar variable auxiliar
	drop df_r

	* Formato y presentación
	format f_stat r2  b_aluv pv_aluv se_aluv %9.4f

	display "=========================================="
    display "Sección transversal para cada año"
	display "X: Potencial mineral en aluvion medido como: `potencial_mineral_aluvion'"
	display "Y: Minería ilegal medida como: `mineria_ilegal'"
    display "=========================================="
	
	* Mostrar valores
	list anno n b_aluv se_aluv pv_aluv  f_stat r2, noobs

restore


*******************************************************
**### Aluvion + Roca
*******************************************************

* Explorar los cortes transversales de cada año
* Minería ilegal explicada por Potencial de roca y potencial de aluvion
preserve
	
	* Eliminar datos faltantes
	drop if missing(codigo_dane_municipio, `mineria_ilegal')

	* Estimar una regresión transversal por año
	statsby ///
		b_roca  = _b[`potencial_mineral_roca'] ///
		se_roca    = _se[`potencial_mineral_roca'] ///
		b_aluv = _b[`potencial_mineral_aluvion'] ///
		se_aluv = _se[`potencial_mineral_aluvion'] ///
		n     = e(N) ///
		f_stat = e(F) ///
		r2    = e(r2) ///
		df_r  = e(df_r), ///
		by(anno) clear: ///
		regress `mineria_ilegal' ///
			`potencial_mineral_roca' `potencial_mineral_aluvion', ///
			vce(robust)

	* Valor p de H0: beta = 0
	gen pv_roca = 2 * ttail(df_r, abs(b_roca / se_roca))
	gen pv_aluv = 2 * ttail(df_r, abs(b_aluv / se_aluv))

	* Eliminar variable auxiliar
	drop df_r

	* Formato y presentación
	format b_roca se_roca pv_roca f_stat r2  b_aluv pv_aluv se_aluv %9.4f

	display "=========================================="
    display "Sección transversal para cada año"
	display "X1: Potencial mineral en roca medido como: `potencial_mineral_roca'"
	display "X2: Potencial mineral en aluvion medido como: `potencial_mineral_aluvion'"
	display "Y: Minería ilegal medida como: `mineria_ilegal'"
    display "=========================================="
	
	* Mostrar valores
	list anno n b_roca se_roca pv_roca b_aluv se_aluv pv_aluv  f_stat r2, noobs

restore
