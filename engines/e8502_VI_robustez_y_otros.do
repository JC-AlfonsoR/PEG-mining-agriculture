*******************************************************
** Estas son pruebas de robustex y otras regresiones que se
** pueden correr dentro del dofile e8501_VI_especificacionPrincipal.do
**
** Identificación con Variables Instrumentales
** Mineral: Oro
**
** Instrumento: Potencial mineral X precio mineral
** X: Minería ilegal
** Y: Producción agrícola
*******************************************************


*******************************************************
**# 2VI-Lags
*      ▄▄▄▄  ▄    ▄ ▄▄▄▄▄         ▄                          
*     ▀   ▀█ ▀▄  ▄▀   █           █       ▄▄▄    ▄▄▄▄   ▄▄▄  
*         ▄▀  █  █    █           █      ▀   █  █▀ ▀█  █   ▀ 
*       ▄▀    ▀▄▄▀    █           █      ▄▀▀▀█  █   █   ▀▀▀▄ 
*     ▄█▄▄▄▄   ██   ▄▄█▄▄         █▄▄▄▄▄ ▀▄▄▀█  ▀█▄▀█  ▀▄▄▄▀ 
*                                                ▄  █        
*                                                 ▀▀         
* VI con instrumentos de precio rezagado: L1, L2 y L3
*******************************************************

* Requiere:
* - Panel declarado.
* - Instrumentos L1, L2 y L3 ya creados.
* - Locals de resultados agrícolas y controles definidos
*   en este mismo do-file.

* Variables endógenas
* Copias con nombres cortos para guardar primeras etapas
capture drop mi_ilegal
capture drop mi_intlegal

clonevar mi_ilegal   = mineIleg_oro_nwPrp_SR21_pct
clonevar mi_intlegal = log_tituMine_oro_AreaSo_total

local mineria_ilegal mi_ilegal
local intencion_mineria_legal mi_intlegal

local endogenas `mineria_ilegal' `intencion_mineria_legal'

* Nombres de modelos y prefijos de primeras etapas
local modelos ///
    vi_simple vi_simple_controles vi_anno ///
    vi_municipio vi_municipio_anno

local prefijos a b c d e

* Formato común de las tablas
local formato ///
    mtitles("VI simple" "VI controles" "EF año" ///
            "EF municipio" "EF mun + año") ///
    b(4) se(4) ///
    star(* 0.10 ** 0.05 *** 0.01)



* Estimación por rezago y resultado agrícola
*******************************************************

foreach rezago in 3 5 {

    * Dos instrumentos con el mismo rezago del precio
    local instrumentos ///
        instr_potRoca_precio_L`rezago' ///
        instr_potAluvion_precio_L`rezago'

    foreach y of local resultados_agricolas {

        * Variable dependiente
        tempvar log_y
        gen double `log_y' = log(1 + `y')
        local y_considerada `log_y'

        display as text _newline ///
            "Estimando: `y' | Rezago del precio: L`rezago'"

        eststo clear

        * Limpiar primeras etapas guardadas en la iteración anterior
        foreach prefijo of local prefijos {
            foreach x of local endogenas {
                capture estimates drop `prefijo'`x'
            }
        }


        ** a. VI simple sin controles
        quietly eststo vi_simple: ///
            ivreghdfe `y_considerada' ///
                (`endogenas' = `instrumentos'), ///
                cluster(codigo_dane_municipio) ///
                first savefirst savefprefix(a)

        quietly estadd scalar KP_F = e(widstat)


        ** b. VI simple con controles
        quietly eststo vi_simple_controles: ///
            ivreghdfe `y_considerada' ///
                `controles_clima' `controles_invariables_tiempo' ///
                (`endogenas' = `instrumentos'), ///
                cluster(codigo_dane_municipio) ///
                first savefirst savefprefix(b)

        quietly estadd scalar KP_F = e(widstat)


        ** c. VI con efectos fijos de AÑO
        quietly eststo vi_anno: ///
            ivreghdfe `y_considerada' ///
                `controles_clima' `controles_invariables_tiempo' ///
                (`endogenas' = `instrumentos'), ///
                absorb(anno) ///
                cluster(codigo_dane_municipio) ///
                first savefirst savefprefix(c)

        quietly estadd scalar KP_F = e(widstat)


        ** d. VI con efectos fijos de MUNICIPIO
        quietly eststo vi_municipio: ///
            ivreghdfe `y_considerada' `controles_clima' ///
                (`endogenas' = `instrumentos'), ///
                absorb(codigo_dane_municipio) ///
                cluster(codigo_dane_municipio) ///
                first savefirst savefprefix(d)

        quietly estadd scalar KP_F = e(widstat)


        ** e. VI con efectos fijos de MUNICIPIO y AÑO
        quietly eststo vi_municipio_anno: ///
            ivreghdfe `y_considerada' `controles_clima' ///
                (`endogenas' = `instrumentos'), ///
                absorb(codigo_dane_municipio anno) ///
                cluster(codigo_dane_municipio) ///
                first savefirst savefprefix(e)

        quietly estadd scalar KP_F = e(widstat)


        *******************************************************
        ** Agregar F condicionales a las primeras etapas
        *******************************************************

        forvalues j = 1/5 {

            local modelo : word `j' of `modelos'
            local prefijo : word `j' of `prefijos'

            quietly estimates restore `modelo'

            matrix diagnosticos_PE = e(first)

            foreach x of local endogenas {

                quietly estadd scalar SW_F = ///
                    el(diagnosticos_PE, ///
                       rownumb(diagnosticos_PE, "SWF"), ///
                       colnumb(diagnosticos_PE, "`x'")), ///
                    replace : `prefijo'`x'
            }
        }


        *******************************************************
        ** Mostrar en Stata y exportar a Markdown
        *******************************************************

        local archivo ///
            "outputs/regresiones/VI_dobleInstr`y'_L`rezago'.md"

        * Ejecutar las mismas tablas para pantalla y archivo
        foreach salida in pantalla archivo {

            local destino ""
            local escritura ""

            if "`salida'" == "archivo" {
                local destino `"using "`archivo'""'
                local escritura "replace md"
            }

            * Segunda etapa
            esttab `modelos' `destino', ///
                `escritura' ///
                title("Segunda etapa: `y' | Precio L`rezago'") ///
                order(`endogenas') ///
                `formato' ///
                stats(N F KP_F, ///
                    fmt(0 3 3) ///
                    labels("Observaciones" "F del modelo" ///
                           "Kleibergen-Paap rk Wald F"))

            * Las primeras etapas se agregan al mismo archivo
            if "`salida'" == "archivo" {
                local escritura "append md"
            }

            * Primera etapa: minería ilegal
            esttab a`mineria_ilegal' b`mineria_ilegal' ///
                c`mineria_ilegal' d`mineria_ilegal' ///
                e`mineria_ilegal' `destino', ///
                `escritura' ///
                title("Primera etapa: minería ilegal | Precio L`rezago'") ///
                order(`instrumentos') ///
                `formato' ///
                stats(N SW_F, ///
                    fmt(0 3) ///
                    labels("Observaciones" "F condicional SW"))

            * Primera etapa: intención de minería legal
            esttab a`intencion_mineria_legal' ///
                b`intencion_mineria_legal' ///
                c`intencion_mineria_legal' ///
                d`intencion_mineria_legal' ///
                e`intencion_mineria_legal' `destino', ///
                `escritura' ///
                title("Primera etapa: intención legal | Precio L`rezago'") ///
                order(`instrumentos') ///
                `formato' ///
                stats(N SW_F, ///
                    fmt(0 3) ///
                    labels("Observaciones" "F condicional SW"))
        }

        * Eliminar variable temporal de logaritmo
        drop `log_y'
    }
}





*******************************************************
**# Vi D=M.Ilegal X=Null
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

	
	** 0. VI simple sin controles
	quietly eststo vi_simple: ///
		ivreghdfe `y_considerada'  ///
			(`mineria_ilegal' = instr_potRoca_precio), ///
			cluster(codigo_dane_municipio) ///
			first

    quietly estadd scalar KP_F = e(widstat)
	
	** 1. VI simple controles
	quietly eststo vi_simple_controles: ///
		ivreghdfe `y_considerada' `controles_clima' `controles_invariables_tiempo' ///
			(`mineria_ilegal' = instr_potRoca_precio), ///
			cluster(codigo_dane_municipio) ///
			first

    quietly estadd scalar KP_F = e(widstat)

	
	** 2. VI con efectos fijos de AÑO
	quietly eststo vi_anno: ///
        ivreghdfe `y_considerada' `controles_clima' `controles_invariables_tiempo' ///
            (`mineria_ilegal' = instr_potRoca_precio), ///
            absorb(anno) ///
            cluster(codigo_dane_municipio) ///
            first

    quietly estadd scalar KP_F = e(widstat)
	
	** 3. VI con efectos fijos de MUNICIPIO
	quietly eststo vi_municipio: ///
        ivreghdfe `y_considerada' `controles_clima' ///
            (`mineria_ilegal' = instr_potRoca_precio), ///
            absorb(codigo_dane_municipio) ///
            cluster(codigo_dane_municipio) ///
            first

    quietly estadd scalar KP_F = e(widstat)
	
	
	** Efecto fijo de MUNICIPIO y AÑO
	quietly eststo vi_municipio_anno: ///
        ivreghdfe `y_considerada' `controles_clima' ///
            (`mineria_ilegal' = instr_potRoca_precio), ///
            absorb(codigo_dane_municipio anno) ///
            cluster(codigo_dane_municipio) ///
            first
	
	
	** Mostrar tabla en Stata
    ********************************************************

	display as text _newline ///
        "Estimando modelos para la variable dependiente: `y'"
		
	esttab vi_simple vi_simple_controles vi_anno vi_municipio vi_municipio_anno ///
		using "outputs/regresiones/VI_`y'.md", ///
		replace md  ///
		order(`mineria_ilegal') ///
		mtitles( ///
			"VI simple" ///
			"VI simple + controles" ///
			"EF año" ///
			"EF municipio" ///
			"EF municipio & año" ///
		) ///
		stats(N F, fmt(0 6) labels("Observaciones" "Estadístico F"))

	* Mostrar resultado en STATA
	esttab vi_simple vi_simple_controles vi_anno vi_municipio vi_municipio_anno, ///
		order(`mineria_ilegal') ///
		mtitles( ///
			"VI simple" ///
			"VI simple + controles" ///
			"EF año" ///
			"EF municipio" ///
			"EF municipio & año" ///
		) ///
		stats(N F, fmt(0 6) labels("Observaciones" "Estadístico F"))

	** Eliminar variable de logaritmo
	drop log_y
}




*******************************************************
**# Vi D=M.Ilegal X=m.Legal
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

	** 0. VI simple SIN controles
	quietly eststo vi_simple: ///
 		ivreghdfe `y_considerada' `intencion_mineria_legal'  ///
			(`mineria_ilegal' = instr_potRoca_precio), ///
			cluster(codigo_dane_municipio) ///
			first

    quietly estadd scalar KP_F = e(widstat)
	
	** 1. VI simple controles
	quietly eststo vi_simple_controles: ///
 		ivreghdfe `y_considerada' `intencion_mineria_legal' `controles_clima' `controles_invariables_tiempo' ///
			(`mineria_ilegal' = instr_potRoca_precio), ///
			cluster(codigo_dane_municipio) ///
			first

    quietly estadd scalar KP_F = e(widstat)

	
	** 2. VI con efectos fijos de AÑO
	quietly eststo vi_anno: ///
        ivreghdfe `y_considerada' `intencion_mineria_legal' `controles_clima' `controles_invariables_tiempo' ///
            (`mineria_ilegal' = instr_potRoca_precio), ///
            absorb(anno) ///
            cluster(codigo_dane_municipio) ///
            first

    quietly estadd scalar KP_F = e(widstat)
	
	** 3. VI con efectos fijos de MUNICIPIO
	quietly eststo vi_municipio: ///
        ivreghdfe `y_considerada' `intencion_mineria_legal' `controles_clima' ///
            (`mineria_ilegal' = instr_potRoca_precio), ///
            absorb(codigo_dane_municipio) ///
            cluster(codigo_dane_municipio) ///
            first

    quietly estadd scalar KP_F = e(widstat)
	
	
	** Efecto fijo de MUNICIPIO y AÑO
	quietly eststo vi_municipio_anno: ///
        ivreghdfe `y_considerada' `intencion_mineria_legal' `controles_clima' ///
            (`mineria_ilegal' = instr_potRoca_precio), ///
            absorb(codigo_dane_municipio anno) ///
            cluster(codigo_dane_municipio) ///
            first
	
	
	** Mostrar tabla en Stata
    ********************************************************

	display as text _newline ///
        "Estimando modelos para la variable dependiente: `y'"
	
	* Exportar resultado
	esttab vi_simple vi_simple_controles vi_anno vi_municipio vi_municipio_anno ///
		using "outputs/regresiones/VI_mLegal_`y'.md", ///
		replace md ///
		mtitles( ///
			"VI simple" ///
			"VI simple + controles" ///
			"EF año" ///
			"EF municipio" ///
			"EF municipio & año" ///
		) ///
		stats(N F, fmt(0 6) labels("Observaciones" "Estadístico F"))
		
	* Mostrar resultado en STATA
	esttab vi_simple vi_simple_controles vi_anno vi_municipio vi_municipio_anno, ///
		order(`mineria_ilegal') ///
		mtitles( ///
			"VI simple" ///
			"VI simple + controles" ///
			"EF año" ///
			"EF municipio" ///
			"EF municipio & año" ///
		) ///
		stats(N F, fmt(0 6) labels("Observaciones" "Estadístico F"))
	

	** Eliminar variable de logaritmo
	drop log_y
}