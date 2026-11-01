*******************************************************
** Identificación con Variables Instrumentales
** Mineral: Oro
**
** Instrumento: Potencial mineral X precio mineral
** X: Minería ilegal
** Y: Producción agrícola
*******************************************************




*******************************************************
**# Cargar panel final y preparar variables del analisis
*******************************************************
do "$engines/e8100_preparar_variables_analisis.do"


*******************************************************
**# Especificacion principal
*    ┏━╸┏━┓┏━┓┏━╸┏━╸    ┏━┓┏━┓╻┏┓╻┏━╸╻┏━┓┏━┓╻  
*    ┣╸ ┗━┓┣━┛┣╸ ┃      ┣━┛┣┳┛┃┃┗┫┃  ┃┣━┛┣━┫┃  
*    ┗━╸┗━┛╹  ┗━╸┗━╸╹   ╹  ╹┗╸╹╹ ╹┗━╸╹╹  ╹ ╹┗━╸
*******************************************************

* Definir las variables del modelo

* Potencial mineral en roca, aluvión o a cualquier recurso (roca o aluvion)
local potencial_mineral_roca proximidad_potencial_roca 
local potencial_mineral_aluvion proximidad_potencial_aluvion
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

* Controles exogenos
local controles_clima clima_precpt_anual_tot_mm clima_tmprtr_max_med_gCel clima_tmprtr_min_med_gCel
local controles_invariables_tiempo altura dismdo

*******************************************************
**# Complementar Panel
*******************************************************


**## Crear instrumento de interacción Precio X Potencial

* La especifciacion principal es con el precio promedio anual
* El precio anual max y min se usarán para revisar hipotesis de auge/declive
gen instr_potRoca_precio = `potencial_mineral_roca'*`precio_mineral'
gen instr_potAluvion_precio = `potencial_mineral_aluvion'*`precio_mineral'
gen instr_potGnrl_precio = `potencial_mineral_gnrl'*`precio_mineral'



*******************************************************
**# Declarar el Panel

* Crear identificador numérico del municipio
egen id_municipio = group(codigo_dane_municipio), label

* verificar que (municipio, año) sea único. Si no sale error, significa que los identificadores funcionar
isid id_municipio anno

* Declarar el Panel
xtset id_municipio	anno


**## Rezagos
* Probar rezagos del precio del oro para verificar la hipótesis de que 
* la minería legal necesita más tiempo de precios altos

* Crear instrumentos con el precio rezagado
foreach rezago in 1 3 5 {

    gen double instr_potRoca_precio_L`rezago' = ///
        `potencial_mineral_roca' * L`rezago'.`precio_mineral'

    gen double instr_potAluvion_precio_L`rezago' = ///
        `potencial_mineral_aluvion' * L`rezago'.`precio_mineral'

    gen double instr_potGnrl_precio_L`rezago' = ///
        `potencial_mineral_gnrl' * L`rezago'.`precio_mineral'

}

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


* Conservar solo las variables de interes
keep codigo_dane_municipio anno instr_pot* `mineria_legal' `mineria_ilegal' `intencion_mineria_legal' instr_potRoca_precio instr_potAluvion_precio instr_potGnrl_precio prodAgr_total_* prodAgr_CCPerm_* prodAgr_CCTrns* `controles_clima' `controles_invariables_tiempo' prodAgr_GC* prodAgr_Ccafe* prodAgr_Carroz_* prodAgr_CplmAc* prodAgr_Cmaiz* prodAgr_Ccanna* prodAgr_Cpltno_* prodAgr_Ccacao* prodAgr_Cyuca* prodAgr_Cpapa* prodAgr_Cagcte* prodAgr_Cbnano_* prodAgr_Cfrijl* prodAgr_Csoya* prodAgr_Cnrnja_* prodAgr_Climon* prodAgr_Ctmate* prodAgr_Cahyma_* prodAgr_Cptill*


**# Minería ilegal explicando producción agrícola
* Probar SIN y CON Controles
reg prodAgr_total_ACosch_totl_ha `mineria_ilegal'
reg prodAgr_total_ACosch_totl_ha `mineria_ilegal' `controles_clima' `controles_invariables_tiempo'

reg prodAgr_total_ASembr_totl_ha `mineria_ilegal'
reg prodAgr_total_ASembr_totl_ha `mineria_ilegal' `controles_clima' `controles_invariables_tiempo'

reg prodAgr_total_Produc_totl_ton `mineria_ilegal'
reg prodAgr_total_Produc_totl_ton `mineria_ilegal' `controles_clima' `controles_invariables_tiempo'


**# Minería legal explicando producción agrícola
* Probar SIN y CON Controles
reg prodAgr_total_ACosch_totl_ha `intencion_mineria_legal'
reg prodAgr_total_ACosch_totl_ha `intencion_mineria_legal' `controles_clima' `controles_invariables_tiempo'

reg prodAgr_total_ASembr_totl_ha `intencion_mineria_legal'
reg prodAgr_total_ASembr_totl_ha `intencion_mineria_legal' `controles_clima' `controles_invariables_tiempo'

reg prodAgr_total_Produc_totl_ton `intencion_mineria_legal'
reg prodAgr_total_Produc_totl_ton `intencion_mineria_legal' `controles_clima' `controles_invariables_tiempo'


**# Minería ilegal y minería legal explicando producción agrícola
* Probar SIN y CON Controles
reg prodAgr_total_ACosch_totl_ha `mineria_ilegal' `intencion_mineria_legal'
reg prodAgr_total_ACosch_totl_ha `mineria_ilegal' `intencion_mineria_legal' `controles_clima' `controles_invariables_tiempo'

reg prodAgr_total_ASembr_totl_ha `mineria_ilegal' `intencion_mineria_legal'
reg prodAgr_total_ASembr_totl_ha `mineria_ilegal' `intencion_mineria_legal' `controles_clima' `controles_invariables_tiempo'

reg prodAgr_total_Produc_totl_ton `mineria_ilegal' `intencion_mineria_legal'
reg prodAgr_total_Produc_totl_ton `mineria_ilegal' `intencion_mineria_legal' `controles_clima' `controles_invariables_tiempo'


* F=111.25
* beta=10.69***, t=10.55
* La regresión directa muestra la existencia de una relación entre
* el area total cosechada y la minería ilegal
* Este planteamiento sufre del problema de endogeneidad,
* Por eso instrumento Potencial geológico X precio oro sobre la minería ilegal
* para aislar la variación asociada solo a ese instrumento
* El resultado es análogo con area sembrada y producción total.
* voy a explorar el comportamiento con desagregaciones de producción agrícola



*******************************************************
**# Transformar variables
*    ╺┳╸┏━┓┏━┓┏┓╻┏━┓┏━╸┏━┓┏━┓┏┳┓┏━┓┏━┓   ╻ ╻┏━┓┏━┓╻┏━┓┏┓ ╻  ┏━╸┏━┓
*     ┃ ┣┳┛┣━┫┃┗┫┗━┓┣╸ ┃ ┃┣┳┛┃┃┃┣━┫┣┳┛   ┃┏┛┣━┫┣┳┛┃┣━┫┣┻┓┃  ┣╸ ┗━┓
*     ╹ ╹┗╸╹ ╹╹ ╹┗━┛╹  ┗━┛╹┗╸╹ ╹╹ ╹╹┗╸   ┗┛ ╹ ╹╹┗╸╹╹ ╹┗━┛┗━╸┗━╸┗━┛
*******************************************************

* Calcular logaritmos de las variables
*gen log_prodAgr_total_ACosch = log(1+prodAgr_total_ACosch_totl_ha)
*gen log_prodAgr_CCPerm_ACosch = log(1+prodAgr_CCPerm_ACosch_cicl_ha)
*gen log_prodAgr_CCTrns_ACosch = log(1+prodAgr_CCTrns_ACosch_cicl_ha)

*local resultados_agricolas ///
	prodAgr_total_ACosch_totl_ha ///
	prodAgr_CCPerm_ACosch_cicl_ha ///
	prodAgr_CCTrns_ACosch_cicl_ha	
	*prodAgr_GCCerl_ACosch_grpo_ha prodAgr_GCFrut_ACosch_grpo_ha prodAgr_GCHort_ACosch_grpo_ha prodAgr_GCLegu_ACosch_grpo_ha prodAgr_GCMedc_ACosch_grpo_ha prodAgr_GCOlea_ACosch_grpo_ha prodAgr_GCRaiz_ACosch_grpo_ha prodAgr_GCTrop_ACosch_grpo_ha 
	
*local resultados_agricolas ///
	prodAgr_total_ASembr_totl_ha ///
	prodAgr_CCPerm_ASembr_cicl_ha ///
	prodAgr_CCTrns_ASembr_cicl_ha
	
local resultados_agricolas ///
	prodAgr_total_Produc_totl_ton ///
	prodAgr_CCPerm_Produc_cicl_ton ///
	prodAgr_CCTrns_Produc_cicl_ton ///
	prodAgr_total_ACosch_totl_ha ///
	prodAgr_CCPerm_ACosch_cicl_ha ///
	prodAgr_CCTrns_ACosch_cicl_ha ///
	prodAgr_total_ASembr_totl_ha ///
	prodAgr_CCPerm_ASembr_cicl_ha ///
	prodAgr_CCTrns_ASembr_cicl_ha /// * incluir resultados por agrupaciones de cultivos
	prodAgr_GCCerl_ACosch_grpo_ha ///
	prodAgr_GCCerl_ASembr_grpo_ha ///
	prodAgr_GCCerl_Produc_grpo_ton ///
	prodAgr_GCFrut_ACosch_grpo_ha ///
	prodAgr_GCFrut_ASembr_grpo_ha ///
	prodAgr_GCFrut_Produc_grpo_ton ///
	prodAgr_GCHort_ACosch_grpo_ha ///
	prodAgr_GCHort_ASembr_grpo_ha ///
	prodAgr_GCHort_Produc_grpo_ton ///
	prodAgr_GCOlea_ACosch_grpo_ha ///
	prodAgr_GCOlea_ASembr_grpo_ha ///
	prodAgr_GCOlea_Produc_grpo_ton ///
	prodAgr_GCRaiz_ACosch_grpo_ha ///
	prodAgr_GCRaiz_ASembr_grpo_ha ///
	prodAgr_GCRaiz_Produc_grpo_ton ///
	prodAgr_GCTrop_ACosch_grpo_ha ///
	prodAgr_GCTrop_ASembr_grpo_ha ///
	prodAgr_GCTrop_Produc_grpo_ton /// * incluir resultados de 15 cultivos de mayor area
	prodAgr_Ccafe_ACosch_cltv_ha /// * Tropicales son de interes por efectos estables encontrados
	prodAgr_Ccafe_ASembr_cltv_ha /// * Tropicales son de interes por efectos estables encontrados
	prodAgr_Ccafe_Produc_cltv_ton  /// * Tropicales son de interes por efectos estables encontrados
	prodAgr_Carroz_ACosch_cltv_ha ///
	prodAgr_Carroz_ASembr_cltv_ha ///
	prodAgr_Carroz_Produc_cltv_ton  ///
	prodAgr_CplmAc_ACosch_cltv_ha ///
	prodAgr_CplmAc_ASembr_cltv_ha ///
	prodAgr_CplmAc_Produc_cltv_ton  ///
	prodAgr_Cmaiz_ACosch_cltv_ha ///
	prodAgr_Cmaiz_ASembr_cltv_ha ///
	prodAgr_Cmaiz_Produc_cltv_ton  ///
	prodAgr_Ccanna_ACosch_cltv_ha /// * Tropicales son de interes por efectos estables encontrados
	prodAgr_Ccanna_ASembr_cltv_ha /// * Tropicales son de interes por efectos estables encontrados
	prodAgr_Ccanna_Produc_cltv_ton  /// * Tropicales son de interes por efectos estables encontrados
	prodAgr_Cpltno_ACosch_cltv_ha ///
	prodAgr_Cpltno_ASembr_cltv_ha ///
	prodAgr_Cpltno_Produc_cltv_ton  ///
	prodAgr_Ccacao_ACosch_cltv_ha /// * Tropicales son de interes por efectos estables encontrados
	prodAgr_Ccacao_ASembr_cltv_ha /// * Tropicales son de interes por efectos estables encontrados
	prodAgr_Ccacao_Produc_cltv_ton  /// * Tropicales son de interes por efectos estables encontrados
	prodAgr_Cyuca_ACosch_cltv_ha ///
	prodAgr_Cyuca_ASembr_cltv_ha ///
	prodAgr_Cyuca_Produc_cltv_ton  ///
	prodAgr_Cpapa_ACosch_cltv_ha ///
	prodAgr_Cpapa_ASembr_cltv_ha ///
	prodAgr_Cpapa_Produc_cltv_ton  ///
	prodAgr_Cagcte_ACosch_cltv_ha ///
	prodAgr_Cagcte_ASembr_cltv_ha ///
	prodAgr_Cagcte_Produc_cltv_ton  ///
	prodAgr_Cbnano_ACosch_cltv_ha ///
	prodAgr_Cbnano_ASembr_cltv_ha ///
	prodAgr_Cbnano_Produc_cltv_ton  ///
	prodAgr_Cfrijl_ACosch_cltv_ha ///
	prodAgr_Cfrijl_ASembr_cltv_ha ///
	prodAgr_Cfrijl_Produc_cltv_ton  ///
	prodAgr_Csoya_ACosch_cltv_ha ///
	prodAgr_Csoya_ASembr_cltv_ha ///
	prodAgr_Csoya_Produc_cltv_ton  ///
	prodAgr_Cnrnja_ACosch_cltv_ha ///
	prodAgr_Cnrnja_ASembr_cltv_ha ///
	prodAgr_Cnrnja_Produc_cltv_ton  ///
	prodAgr_Climon_ACosch_cltv_ha ///
	prodAgr_Climon_ASembr_cltv_ha ///
	prodAgr_Climon_Produc_cltv_ton  ///
	prodAgr_Ctmate_ACosch_cltv_ha /// * Hortalizas son de interes por efectos estables encontrados
	prodAgr_Ctmate_ASembr_cltv_ha /// * Hortalizas son de interes por efectos estables encontrados
	prodAgr_Ctmate_Produc_cltv_ton /// * Hortalizas son de interes por efectos estables encontrados
	prodAgr_Cahyma_ACosch_cltv_ha /// * Hortalizas son de interes por efectos estables encontrados
	prodAgr_Cahyma_ASembr_cltv_ha /// * Hortalizas son de interes por efectos estables encontrados
	prodAgr_Cahyma_Produc_cltv_ton /// * Hortalizas son de interes por efectos estables encontrados
	prodAgr_Cptill_ACosch_cltv_ha /// * Hortalizas son de interes por efectos estables encontrados
	prodAgr_Cptill_ASembr_cltv_ha /// * Hortalizas son de interes por efectos estables encontrados
	prodAgr_Cptill_Produc_cltv_ton /// * Hortalizas son de interes por efectos estables encontrados



local resAgro_todos_cultivos ///
	prodAgr_total_Produc_totl_ton ///
	prodAgr_total_ACosch_totl_ha ///
	prodAgr_total_ASembr_totl_ha 
	

	
	
*******************************************************	
* Conteo de variables
preserve

* Conservar observaciones sin valores faltantes en las tres variables
keep if !missing(prodAgr_total_Produc_totl_ton, instr_potRoca_precio, `mineria_ilegal', `intencion_mineria_legal')

* Mostrar cuántas observaciones completas hay por año
tabulate anno

restore
*******************************************************
*******************************************************
*******************************************************
*******************************************************

*******************************************************
** Ejemplo mínimo: dos endógenas y dos instrumentos
* Hago este ejemplo para resolver un problema que tenía con
* la longitud de los nombres de las variables
*******************************************************

* 1. Variables endógenas
local mineria_ilegal mineIleg_oro_nwPrp_SR21_pct
local intencion_mineria_legal log_tituMine_oro_AreaSo_total

local endogenas `mineria_ilegal' `intencion_mineria_legal'

* 2. Instrumentos
local instrumentos instr_potRoca_precio instr_potAluvion_precio

* 3. Controles
* Incluye aquí tus definiciones de:
* local controles_clima ...
* local controles_invariables_tiempo ...

* Copias con nombres cortos
capture drop mi_ilegal
capture drop mi_intlegal

clonevar mi_ilegal = mineIleg_oro_nwPrp_SR21_pct
clonevar mi_intlegal = log_tituMine_oro_AreaSo_total

local endogenas mi_ilegal mi_intlegal
local instrumentos instr_potRoca_precio instr_potAluvion_precio

* Variable dependiente
capture drop log_y
generate double log_y = log(1 + prodAgr_total_Produc_totl_ton)

* Estimar y guardar primeras etapas
ivreghdfe log_y ///
    `controles_clima' `controles_invariables_tiempo' ///
    (`endogenas' = `instrumentos'), ///
    cluster(codigo_dane_municipio) ///
    first savefirst savefprefix(a)

* Guardar segunda etapa
estadd scalar KP_F = e(widstat)
estimates store vi_simple_controles

* Comprobar resultados guardados
display as text "Primeras etapas guardadas: `e(firsteqs)'"
estimates dir

* Mostrar las tres columnas
esttab ami_ilegal ami_intlegal vi_simple_controles, ///
    mtitles("PE: ilegal" "PE: intención legal" "Segunda etapa") ///
    order(`instrumentos' `endogenas') ///
    b(4) se(4) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N KP_F, fmt(0 3) ///
        labels("Observaciones" "Kleibergen-Paap rk Wald F"))

* 11. Limpiar al terminar
drop log_y

*******************************************************
*******************************************************
*******************************************************










*******************************************************
**# 2VI
*      ▄▄▄▄  ▄    ▄ ▄▄▄▄▄ 
*     ▀   ▀█ ▀▄  ▄▀   █   
*         ▄▀  █  █    █   
*       ▄▀    ▀▄▄▀    █   
*     ▄█▄▄▄▄   ██   ▄▄█▄▄ 
*******************************************************

* variables endogendas
* Copias con nombres cortos para guardar las primeras etapas.
* Stata añade el prefijo del modelo y el prefijo interno _est_,
* por lo que los nombres originales excedían el límite permitido.

* Crear copias de las variables mineras con nombres cortos
capture drop mi_ilegal
capture drop mi_intlegal

clonevar mi_ilegal = mineIleg_oro_nwPrp_SR21_pct
clonevar mi_intlegal = log_tituMine_oro_AreaSo_total

* Definir los nombres que usarán las regresiones y las tablas
local mineria_ilegal mi_ilegal
local intencion_mineria_legal mi_intlegal

* Construir la lista de variables endógenas
local endogenas `mineria_ilegal' `intencion_mineria_legal'


* Instrumentos
local instrumentos instr_potRoca_precio instr_potAluvion_precio


foreach y of local resultados_agricolas   {
	
	* Generar logaritmo de la variable de interes
	gen log_y = log(1+`y')
	local y_considerada log_y
	*local y_considerada = `y'
	
	display as text _newline ///
        "Estimando modelos para la variable dependiente: `y'"
	eststo clear

	
	
	** a. VI simple sin controles
	quietly eststo vi_simple: ///
		ivreghdfe `y_considerada'  ///
			(`endogenas' = `instrumentos'), ///
			cluster(codigo_dane_municipio) ///
			first savefirst savefprefix(a)

    quietly estadd scalar KP_F = e(widstat)
	
	
	** b. VI simple controles
	quietly eststo vi_simple_controles: ///
		ivreghdfe `y_considerada' `controles_clima' `controles_invariables_tiempo' ///
			(`endogenas' = `instrumentos'), ///
			cluster(codigo_dane_municipio) ///
			first savefirst savefprefix(b)

    quietly estadd scalar KP_F = e(widstat)

	
	** c. VI con efectos fijos de AÑO
	quietly eststo vi_anno: ///
        ivreghdfe `y_considerada' `controles_clima' `controles_invariables_tiempo' ///
            (`endogenas' = `instrumentos'), ///
            absorb(anno) ///
            cluster(codigo_dane_municipio) ///
            first savefirst savefprefix(c)

    quietly estadd scalar KP_F = e(widstat)
	
	** d. VI con efectos fijos de MUNICIPIO
	*quietly eststo vi_municipio: ///
        ivreghdfe `y_considerada' `controles_clima' ///
            (`endogenas' = `instrumentos'), ///
            absorb(codigo_dane_municipio) ///
            cluster(codigo_dane_municipio) ///
            first savefirst savefprefix(d)

    *quietly estadd scalar KP_F = e(widstat)
	
	
	** e. Efecto fijo de MUNICIPIO y AÑO
	quietly eststo vi_municipio_anno: ///
        ivreghdfe `y_considerada' `controles_clima' ///
            (`endogenas' = `instrumentos'), ///
            absorb(codigo_dane_municipio anno) ///
            cluster(codigo_dane_municipio) ///
            first savefirst savefprefix(e)
	
	quietly estadd scalar KP_F = e(widstat)
	
	** Agregar F condicionales a los resultados de primera etapa

	local modelos ///
		vi_simple vi_simple_controles vi_anno ///
		vi_municipio_anno

	local prefijos a b c e

	forvalues j = 1/4 {

		* Seleccionar modelo y prefijo correspondiente
		local modelo : word `j' of `modelos'
		local prefijo : word `j' of `prefijos'

		* Recuperar los resultados del modelo de VI
		quietly estimates restore `modelo'

		* Copiar la matriz de diagnósticos de sus primeras etapas
		matrix diagnosticos_PE = e(first)

		* Extraer el F condicional de cada variable endógena
		* y agregarlo a su resultado de primera etapa
		foreach x of local endogenas {

			quietly estadd scalar SW_F = ///
				el(diagnosticos_PE, ///
				   rownumb(diagnosticos_PE, "SWF"), ///
				   colnumb(diagnosticos_PE, "`x'")), ///
				replace : `prefijo'`x'
		}
	}

	** Exportar regresiones ********************************************************

	display as text _newline ///
        "Estimando modelos para la variable dependiente: `y'"
	
	* Títulos comunes: segunda etapa y primera etapa de cada variable endógena
	local titulos ///
		"VI simple" ///
		"VI controles" ///
		"EF año" ///
		"EF mun & año"
		
	* Segunda etapa: crea o reemplaza el archivo
	esttab vi_simple vi_simple_controles vi_anno ///
		vi_municipio_anno ///
		using "outputs/regresiones/VI_dobleInstr`y'.md", ///
		replace md ///
		title("Segunda etapa: `y'") ///
		order(`endogenas') ///
		mtitles("VI simple" "VI controles" "EF año" "EF mun + año") ///
		b(4) se(4) ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		stats(N F KP_F, ///
			fmt(0 3 3) ///
			labels("Observaciones" "F del modelo" ///
				   "Kleibergen-Paap rk Wald F"))

	* Primera etapa: minería ilegal
	esttab a`mineria_ilegal' b`mineria_ilegal' ///
		c`mineria_ilegal' e`mineria_ilegal' ///
		using "outputs/regresiones/VI_dobleInstr`y'.md", ///
		append md ///
		title("Primera etapa: minería ilegal") ///
		order(`instrumentos') ///
		mtitles("VI simple" "VI controles" "EF año" "EF mun + año") ///
		b(4) se(4) ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		stats(N SW_F, ///
			fmt(0 3) ///
			labels("Observaciones" "F condicional SW"))

	* Primera etapa: intención de minería legal
	esttab a`intencion_mineria_legal' b`intencion_mineria_legal' ///
		c`intencion_mineria_legal' ///
		e`intencion_mineria_legal' ///
		using "outputs/regresiones/VI_dobleInstr`y'.md", ///
		append md ///
		title("Primera etapa: intención de minería legal") ///
		order(`instrumentos') ///
		mtitles("VI simple" "VI controles" "EF año" "EF mun + año") ///
		b(4) se(4) ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		stats(N SW_F, ///
			fmt(0 3) ///
			labels("Observaciones" "F condicional SW"))


	** Mostrar resultado en STATA ********************************************************
	
	* Segunda etapa
	esttab vi_simple vi_simple_controles vi_anno ///
		vi_municipio_anno, ///
		title("Segunda etapa: `y'") ///
		order(`endogenas') ///
		mtitles("VI simple" "VI controles" "EF año" "EF mun + año") ///
		b(4) se(4) ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		stats(N F KP_F, ///
			fmt(0 3 3) ///
			labels("Observaciones" "F del modelo" ///
				   "Kleibergen-Paap rk Wald F"))

	* Primera etapa: minería ilegal
	esttab a`mineria_ilegal' b`mineria_ilegal' ///
		c`mineria_ilegal' e`mineria_ilegal', ///
		title("Primera etapa: minería ilegal") ///
		order(`instrumentos') ///
		mtitles("VI simple" "VI controles" "EF año" "EF mun + año") ///
		b(4) se(4) ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		stats(N SW_F, ///
			fmt(0 3) ///
			labels("Observaciones" "F condicional SW"))

	* Primera etapa: intención de minería legal
	esttab a`intencion_mineria_legal' b`intencion_mineria_legal' ///
		c`intencion_mineria_legal' ///
		e`intencion_mineria_legal', ///
		title("Primera etapa: intención de minería legal") ///
		order(`instrumentos') ///
		mtitles("VI simple" "VI controles" "EF año" "EF mun + año") ///
		b(4) se(4) ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		stats(N SW_F, ///
			fmt(0 3) ///
			labels("Observaciones" "F condicional SW"))
		
		
	** Eliminar variable de logaritmo
	drop log_y
}



*******************************************************
**# Otras regresiones
*do "$engines/e8502_VI_robustez_y_otros.do"