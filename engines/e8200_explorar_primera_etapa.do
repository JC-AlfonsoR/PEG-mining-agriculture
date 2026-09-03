*******************************************************
** Mineral: Oro
** Primera Etapa
*******************************************************

*******************************************************
**# Primera Etapa en oro
*     ▄▄▄      ▄▄          ▄▄▄▄▄▄   ▄                        
*       █     █  █         █      ▄▄█▄▄   ▄▄▄   ▄▄▄▄    ▄▄▄  
*       █      ▀▀          █▄▄▄▄▄   █    ▀   █  █▀ ▀█  ▀   █ 
*       █                  █        █    ▄▀▀▀█  █   █  ▄▀▀▀█ 
*     ▄▄█▄▄                █▄▄▄▄▄   ▀▄▄  ▀▄▄▀█  ██▄█▀  ▀▄▄▀█ 
*                                               █           
*******************************************************

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
**# Preámbulo
*******************************************************

* En este do-file corro las regresiones de variables instrumentales de mi tesis del PEG
cls
clear all
set more off


*******************************************************
* Configuración
*******************************************************
* Raíz del proyecto
local computador=c(username)
if "`computador'"=="jcalf" {
	cd "C:/Users/jcalf/OneDrive - Universidad de los Andes/PEG/PEG-mining-agriculture"
}
if "`computador'"=="javie" {
	cd "C:/Users/javie/OneDrive - Universidad de los andes/PEG/PEG-mining-agriculture"
}

* Verificación
pwd

* Definir la carpeta donde están las bases
*local data_intermediate "data/intermediate"
global data_intermediate "data/intermediate"


*******************************************************
**# Procesamiento de datos de minerales
do "engines/e8100_procesar_datos_minerales"
*******************************************************



*******************************************************
**# Especificacion principal
*    ┏━╸┏━┓┏━┓┏━╸┏━╸    ┏━┓┏━┓╻┏┓╻┏━╸╻┏━┓┏━┓╻  
*    ┣╸ ┗━┓┣━┛┣╸ ┃      ┣━┛┣┳┛┃┃┗┫┃  ┃┣━┛┣━┫┃  
*    ┗━╸┗━┛╹  ┗━╸┗━╸╹   ╹  ╹┗╸╹╹ ╹┗━╸╹╹  ╹ ╹┗━╸
*******************************************************

* Definir las variables del modelo

* Potencial mineral en roca
local potencial_mineral_roca proximidad_potencial_roca 

* Potencial mineral en aluvion
local potencial_mineral_aluvion proximidad_potencial_aluvion

* Potencial mineral en cualquier recurso (roca o aluvion)
local potencial_mineral_gnrl proximidad_potencial_gnrl

* Minería legal
local mineria_legal log_mineLegl_oro_prod_gr

* Inteción de hacer minería legal
local intencion_mineria_legal log_tituMine_oro_AreaSo_total
*local intencion_mineria_legal tituMine_oro_AreaTi_tOtr_m2Fx

* Minería ilegal:
* mineIleg_oro_area_SR21_km2 mineIleg_oro_nwPrp_SR21_pct mineIleg_oro_prpMun_SR21_pct
local mineria_ilegal mineIleg_oro_nwPrp_SR21_pct
* La definición de la variable en SR2021, está en el dofile 01_Create_Stata_DataSet_forreg.do de su repositorio, en la línea 449:
* label var newpropminedMi_illegal "Share of new mined area mined illegaly"


* La especifciacion principal es con el precio promedio anual
* El precio anual max y min se usarán para revisar hipotesis de auge/declive
local precio_mineral precMine_oro_prmdio_oro_USoz


* Conservar solo las variables de interes
keep codigo_dane_municipio anno `potencial_mineral_roca' `potencial_mineral_aluvion' `potencial_mineral_gnrl' `mineria_legal' `mineria_ilegal' `intencion_mineria_legal'

*******************************************************
**# Sección Transversal
*      ▄▄▄▄               ▄▄▄▄▄▄▄                                          
*     █▀   ▀                 █     ▄ ▄▄   ▄▄▄   ▄ ▄▄    ▄▄▄   ▄   ▄        
*     ▀█▄▄▄                  █     █▀  ▀ ▀   █  █▀  █  █   ▀  ▀▄ ▄▀        
*         ▀█                 █     █     ▄▀▀▀█  █   █   ▀▀▀▄   █▄█         
*     ▀▄▄▄█▀   █             █     █     ▀▄▄▀█  █   █  ▀▄▄▄▀    █      █   
*******************************************************
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
	display "X: Potencial mineral en roca medido como: `potencial_mineral_aluvion'"
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
* Produccion ilegal: mineIleg_oro_nwPrp_SR21_pct

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
	display "X: Potencial mineral en roca medido como: `potencial_mineral_aluvion'"
	display "Y: Minería legal medida como: `mineria_ilegal'"
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
	display "Y: Minería legal medida como: `mineria_ilegal'"
    display "=========================================="
	
	* Mostrar valores
	list anno n b_roca se_roca pv_roca b_aluv se_aluv pv_aluv  f_stat r2, noobs

restore




*******************************************************
**# Panel
*     ▄▄▄▄▄                       ▀▀█   
*     █   ▀█  ▄▄▄   ▄ ▄▄    ▄▄▄     █   
*     █▄▄▄█▀ ▀   █  █▀  █  █▀  █    █   
*     █      ▄▀▀▀█  █   █  █▀▀▀▀    █   
*     █      ▀▄▄▀█  █   █  ▀█▄▄▀    ▀▄▄ 
*******************************************************

**## Estructurar datos panel


 * Incluir el precio anual de los minerales
*******************************************************
* El panel que tengo es (municipio, año). Los datos en precios_minerales solo estan identificados por año. Entonces, el merge replica el valor del precio anual para cada municipio
merge m:1 anno using "`data_intermediate'/e3000_precios_minerales.dta"

* Analizar merge
tab _merge
*br if _merge==2
* Las observaciones de _merge==2 son años desde 1960 hasta 2003.
* En esos años hay datos de precios, pero no hay datos
* mineria legal, minerai ilegal. Por eso se desechan esos datos
keep if _merge==3
drop _merge

**### Crear instrumento de interacción Precio X Potencial

* La especifciacion principal es con el precio promedio anual
* El precio anual max y min se usarán para revisar hipotesis de auge/declive
gen instr_potRoca_precio = `potencial_mineral_roca'*`precio_mineral'
gen instr_potAluvion_precio = `potencial_mineral_aluvion'*`precio_mineral'
gen instr_potGnrl_precio = `potencial_mineral_gnrl'*`precio_mineral'



* Conservar solo las variables de interes
keep codigo_dane_municipio anno `potencial_mineral_roca' `potencial_mineral_aluvion' `potencial_mineral_gnrl' `mineria_legal' `mineria_ilegal' `precio_mineral' instr_potRoca_precio instr_potAluvion_precio instr_potGnrl_precio `intencion_mineria_legal' 

*******************************************************
* Declarar el Panel

* Crear identificador numérico del municipio
egen id_municipio = group(codigo_dane_municipio), label

* verificar que (municipio, año) sea único. Si no sale error, significa que los identificadores funcionar
isid id_municipio anno

* Declarar el Panel
xtset id_municipio	anno


*******************************************************
**## Minería Legal
*******************************************************
* La especificacion principal es con 
* Potencial: proximidad_potencial_roca * Precio 
* Produccion legal: log_mineLegl_oro_prod_gr * Precio

reg `mineria_legal' instr_potRoca_precio
reg `mineria_legal' instr_potAluvion_precio
reg `mineria_legal' instr_potGnrl_precio 

*******************************************************
**## Intención M. legal
*******************************************************
reg `intencion_mineria_legal' instr_potRoca_precio
reg `intencion_mineria_legal' instr_potAluvion_precio
reg `intencion_mineria_legal' instr_potGnrl_precio


*******************************************************
**## Minería Ilegal
*******************************************************

* La especificacion principal es con 
* Potencial: proximidad_potencial_aluvion * Precio
* Produccion ilegal: mineIleg_oro_nwPrp_SR21_pct * Precio

reg `mineria_ilegal' instr_potRoca_precio
reg `mineria_ilegal' instr_potAluvion_precio
reg `mineria_ilegal' instr_potGnrl_precio





 *******************************************************                                       
**# Efectos Fijos
* ▄▄▄▄▄▄   ▄▀▀                  ▄                         ▄▄▄▄▄▄   ▀       ▀                
* █      ▄▄█▄▄   ▄▄▄    ▄▄▄   ▄▄█▄▄   ▄▄▄    ▄▄▄          █      ▄▄▄     ▄▄▄    ▄▄▄    ▄▄▄  
* █▄▄▄▄▄   █    █▀  █  █▀  ▀    █    █▀ ▀█  █   ▀         █▄▄▄▄▄   █       █   █▀ ▀█  █   ▀ 
* █        █    █▀▀▀▀  █        █    █   █   ▀▀▀▄         █        █       █   █   █   ▀▀▀▄ 
* █▄▄▄▄▄   █    ▀█▄▄▀  ▀█▄▄▀    ▀▄▄  ▀█▄█▀  ▀▄▄▄▀         █      ▄▄█▄▄     █   ▀█▄█▀  ▀▄▄▄▀ 
*                                                                         █                
*                                                                       ▀▀                 
*******************************************************                                       



 *******************************************************
**## Minería Legal
*******************************************************
* La especificacion principal es con 
* Potencial: proximidad_potencial_roca * Precio 
* Produccion legal: log_mineLegl_oro_prod_gr * Precio

reghdfe `mineria_legal' instr_potRoca_precio, ///
	absorb(id_municipio anno) ///
	vce(cluster id_municipio)

reghdfe `mineria_legal' instr_potAluvion_precio, ///
	absorb(id_municipio anno) ///
	vce(cluster id_municipio)

reghdfe `mineria_legal' instr_potGnrl_precio, ///
	absorb(id_municipio anno) ///
	vce(cluster id_municipio)

*******************************************************
**## Intención M. legal
*******************************************************
reghdfe `intencion_mineria_legal' instr_potRoca_precio, ///
	absorb(id_municipio anno) vce(cluster id_municipio)

reghdfe `intencion_mineria_legal' instr_potAluvion_precio, ///
	absorb(id_municipio anno) vce(cluster id_municipio)
	
reghdfe `intencion_mineria_legal' instr_potGnrl_precio, ///
	absorb(id_municipio anno) vce(cluster id_municipio)

*******************************************************
**## Minería Ilegal
*******************************************************

* La especificacion principal es con 
* Potencial: proximidad_potencial_aluvion * Precio
* Produccion ilegal: mineIleg_oro_nwPrp_SR21_pct * Precio

reghdfe `mineria_ilegal' instr_potRoca_precio, ///
	absorb(id_municipio anno) ///
	vce(cluster id_municipio)

reghdfe `mineria_ilegal' instr_potAluvion_precio, ///
	absorb(id_municipio anno) ///
	vce(cluster id_municipio)

reghdfe `mineria_ilegal' instr_potGnrl_precio, ///
	absorb(id_municipio anno) ///
	vce(cluster id_municipio)
	


*****
* Revisar conteo de observaciones de mineria legal e ilegal por año
*bysort anno: summarize `mineria_ilegal' `mineria_legal'