*******************************************************
** Identificación con Variables Instrumentales
** Mineral: Oro
**
** Instrumento: Potencial mineral X precio mineral
** X: Minería ilegal
** Y: Producción agrícola
*******************************************************



*******************************************************
**# Preámbulo
*******************************************************

* En este do-file corro las regresiones de variables instrumentales de mi tesis del PEG
cls
clear all
set more off

*******************************************************
* Instalar versiones compatibles de paquetes

* Eliminar versiones anteriores
*cap ado uninstall ivreghdfe
*cap ado uninstall reghdfe
*cap ado uninstall ftools
*cap ado uninstall ivreg2


* Instalar versiones compatibles desde las fuentes oficiales
*net install ftools, ///
*    from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/") ///
*    replace

*net install reghdfe, ///
*    from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/") ///
*    replace

*ssc install ivreg2, replace

*net install ivreghdfe, ///
*    from("https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/") ///
*    replace

*ssc install ranktest, replace
*ssc install estout, replace

*******************************************************
* Configuración

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
**# Panel
*    ┏━┓┏━┓┏┳┓┏━┓┏━┓   ┏━┓┏━┓┏┓╻┏━╸╻  
*    ┣━┫┣┳┛┃┃┃┣━┫┣┳┛   ┣━┛┣━┫┃┗┫┣╸ ┃  
*    ╹ ╹╹┗╸╹ ╹╹ ╹╹┗╸   ╹  ╹ ╹╹ ╹┗━╸┗━╸
*******************************************************

**## Estructurar datos panel


 * Incluir el precio anual de los minerales
*******************************************************
* El panel que tengo es (municipio, año). Los datos en precios_minerales solo estan identificados por año. Entonces, el merge replica el valor del precio anual para cada municipio
merge m:1 anno using "$data_intermediate/e3000_precios_minerales.dta"

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
**# Cargar informaicón agrícola
*    ┏━╸┏━┓┏━┓┏━╸┏━┓┏━┓   ╻┏┓╻┏━╸┏━┓   ┏━╸╻ ╻╻  ╺┳╸╻╻ ╻┏━┓┏━┓
*    ┃  ┣━┫┣┳┛┃╺┓┣━┫┣┳┛   ┃┃┗┫┣╸ ┃ ┃   ┃  ┃ ┃┃   ┃ ┃┃┏┛┃ ┃┗━┓
*    ┗━╸╹ ╹╹┗╸┗━┛╹ ╹╹┗╸   ╹╹ ╹╹  ┗━┛   ┗━╸┗━┛┗━╸ ╹ ╹┗┛ ┗━┛┗━┛
*******************************************************

* Cargar panel de cultivos
merge 1:1 codigo_dane_municipio anno using "$data_intermediate/e1101_panel_informacionAgricola.dta"

*******************************************************
**# Regresión Directa
*     ▄▄▄▄▄                ▄▄▄▄     ▀                           ▄          
*     █   ▀█               █   ▀▄ ▄▄▄     ▄ ▄▄   ▄▄▄    ▄▄▄   ▄▄█▄▄   ▄▄▄  
*     █▄▄▄▄▀               █    █   █     █▀  ▀ █▀  █  █▀  ▀    █    ▀   █ 
*     █   ▀▄               █    █   █     █     █▀▀▀▀  █        █    ▄▀▀▀█ 
*     █    ▀   █           █▄▄▄▀  ▄▄█▄▄   █     ▀█▄▄▀  ▀█▄▄▀    ▀▄▄  ▀▄▄▀█ 
*******************************************************
* Antes de correr la regresión principal, corro la regresión directa entre
* Minería legal vs producción agrícola


**# Regresión simple sin controles
* Minería ilegal explicando producción agrícola
reg prodAgr_total_ACosch_totl_ha `mineria_ilegal'
reg prodAgr_total_ASembr_totl_ha `mineria_ilegal'
reg prodAgr_total_Produc_totl_ton mineIleg_oro_nwPrp_SR21_pct

* F=111.25
* beta=10.69***, t=10.55
* La regresión directa muestra la existencia de una relación entre
* el area total cosechada y la minería ilegal
* Este planteamiento sufre del problema de endogeneidad,
* Por eso instrumento Potencial geológico X precio oro sobre la minería ilegal
* para aislar la variación asociada solo a ese instrumento
* El resultado es análogo con area sembrada y producción total.
* voy a explorar el comportamiento con desagregaciones de producción agrícola

* Calcular logaritmos de las variables
gen log_prodAgr_total_ACosch = log(1+prodAgr_total_ACosch_totl_ha)
gen log_prodAgr_CCPerm_ACosch = log(1+prodAgr_CCPerm_ACosch_cicl_ha)
gen log_prodAgr_CCTrns_ACosch = log(1+prodAgr_CCTrns_ACosch_cicl_ha)

local resultados_agricolas ///
	prodAgr_total_ACosch_totl_ha ///
	prodAgr_CCPerm_ACosch_cicl_ha ///
	prodAgr_CCTrns_ACosch_cicl_ha
	
	*prodAgr_GCCerl_ACosch_grpo_ha prodAgr_GCFrut_ACosch_grpo_ha prodAgr_GCHort_ACosch_grpo_ha prodAgr_GCLegu_ACosch_grpo_ha prodAgr_GCMedc_ACosch_grpo_ha prodAgr_GCOlea_ACosch_grpo_ha prodAgr_GCRaiz_ACosch_grpo_ha prodAgr_GCTrop_ACosch_grpo_ha 

local log_resultados_agricolas /// 
	log_prodAgr_total_ACosch ///
	log_prodAgr_CCPerm_ACosch ///
	log_prodAgr_CCTrns_ACosch
	

*******************************************************
**# VI
*     ▄    ▄ ▄▄▄▄▄ 
*     ▀▄  ▄▀   █   
*      █  █    █   
*      ▀▄▄▀    █   
*       ██   ▄▄█▄▄ 
*******************************************************


foreach y of local resultados_agricolas {
	
	* Generar logaritmo de la variable de interes
	gen log_y = log(1+`y')
	local y_considerada log_y
	*local y_considerada = `y'
	
	display as text _newline ///
        "Estimando modelos para la variable dependiente: `y'"
	eststo clear

	
	** 1. VI simple
	quietly eststo vi_simple: ///
		ivreghdfe `y_considerada' ///
			(`mineria_ilegal' = instr_potRoca_precio), ///
			cluster(codigo_dane_municipio) ///
			first

    quietly estadd scalar KP_F = e(widstat)

	
	** 2. VI con efectos fijos de AÑO
	quietly eststo vi_anno: ///
        ivreghdfe `y_considerada' ///
            (`mineria_ilegal' = instr_potRoca_precio), ///
            absorb(anno) ///
            cluster(codigo_dane_municipio) ///
            first

    quietly estadd scalar KP_F = e(widstat)
	
	** 3. VI con efectos fijos de MUNICIPIO
	quietly eststo vi_municipio: ///
        ivreghdfe `y_considerada' ///
            (`mineria_ilegal' = instr_potRoca_precio), ///
            absorb(codigo_dane_municipio) ///
            cluster(codigo_dane_municipio) ///
            first

    quietly estadd scalar KP_F = e(widstat)
	
	
	** Efecto fijo de MUNICIPIO y AÑO
	quietly eststo vi_municipio_anno: ///
        ivreghdfe `y_considerada' ///
            (`mineria_ilegal' = instr_potRoca_precio), ///
            absorb(codigo_dane_municipio anno) ///
            cluster(codigo_dane_municipio) ///
            first
	
	
	** Mostrar tabla en Stata
    ********************************************************

	display as text _newline ///
        "Estimando modelos para la variable dependiente: `y'"
		
	esttab vi_simple vi_anno vi_municipio vi_municipio_anno, ///
		order(`mineria_ilegal') ///
		mtitles( ///
			"VI simple" ///
			"EF año" ///
			"EF municipio" ///
			"EF municipio & año" ///
		) ///
	

	** Eliminar variable de logaritmo
	drop log_y
}




*******************************************************
**# Vi X=minería legal
*     ▄    ▄ ▄▄▄▄▄ 
*     ▀▄  ▄▀   █   
*      █  █    █   
*      ▀▄▄▀    █   
*       ██   ▄▄█▄▄ 
*******************************************************

foreach y of local resultados_agricolas {
	
	* Generar logaritmo de la variable de interes
	gen log_y = log(1+`y')
	local y_considerada log_y
	*local y_considerada = `y'
	
	display as text _newline ///
        "Estimando modelos para la variable dependiente: `y'"
	eststo clear

	
	** 1. VI simple
	quietly eststo vi_simple: ///
		ivreghdfe `y_considerada' `mineria_legal' ///
			(`mineria_ilegal' = instr_potRoca_precio), ///
			cluster(codigo_dane_municipio) ///
			first

    quietly estadd scalar KP_F = e(widstat)

	
	** 2. VI con efectos fijos de AÑO
	quietly eststo vi_anno: ///
        ivreghdfe `y_considerada' `mineria_legal' ///
            (`mineria_ilegal' = instr_potRoca_precio), ///
            absorb(anno) ///
            cluster(codigo_dane_municipio) ///
            first

    quietly estadd scalar KP_F = e(widstat)
	
	** 3. VI con efectos fijos de MUNICIPIO
	quietly eststo vi_municipio: ///
        ivreghdfe `y_considerada' `mineria_legal' ///
            (`mineria_ilegal' = instr_potRoca_precio), ///
            absorb(codigo_dane_municipio) ///
            cluster(codigo_dane_municipio) ///
            first

    quietly estadd scalar KP_F = e(widstat)
	
	
	** Efecto fijo de MUNICIPIO y AÑO
	quietly eststo vi_municipio_anno: ///
        ivreghdfe `y_considerada' `mineria_legal' ///
            (`mineria_ilegal' = instr_potRoca_precio), ///
            absorb(codigo_dane_municipio anno) ///
            cluster(codigo_dane_municipio) ///
            first
	
	
	** Mostrar tabla en Stata
    ********************************************************

	display as text _newline ///
        "Estimando modelos para la variable dependiente: `y'"
		
	esttab vi_simple vi_anno vi_municipio vi_municipio_anno, ///
		order(`mineria_ilegal') ///
		mtitles( ///
			"VI simple" ///
			"EF año" ///
			"EF municipio" ///
			"EF municipio & año" ///
		) ///
	

	** Eliminar variable de logaritmo
	drop log_y
}