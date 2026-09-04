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
**# Variables Instrumentales
*     ▄    ▄ ▄▄▄▄▄ 
*     ▀▄  ▄▀   █   
*      █  █    █   
*      ▀▄▄▀    █   
*       ██   ▄▄█▄▄ 
*******************************************************


*******************************************************
**# Variables Instrumentales
*    ┏━╸┏━┓┏━┓┏━╸┏━┓┏━┓   ╻┏┓╻┏━╸┏━┓   ┏━╸╻ ╻╻  ╺┳╸╻╻ ╻┏━┓┏━┓
*    ┃  ┣━┫┣┳┛┃╺┓┣━┫┣┳┛   ┃┃┗┫┣╸ ┃ ┃   ┃  ┃ ┃┃   ┃ ┃┃┏┛┃ ┃┗━┓
*    ┗━╸╹ ╹╹┗╸┗━┛╹ ╹╹┗╸   ╹╹ ╹╹  ┗━┛   ┗━╸┗━┛┗━╸ ╹ ╹┗┛ ┗━┛┗━┛
