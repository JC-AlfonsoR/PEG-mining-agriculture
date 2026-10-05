*******************************************************
** e8051_resumir_panel_para_seguimiento.do
**
** Objetivo:
** Crear 3 resumenes del panel para hacer seguimiento con git
**   1. Resumen general: $out_descriptivas\panel_resumen.txt
**   2. Inventario de variables: $out_descriptivas\panel_variables.csv
**   3. Cobertura variables clave: $out_descriptivas\panel_cobertura_clave.csv
**
** Ejecutar despues de e8001_configurar.do
** y de e8050_armar_panel.do, desde el master.
** Salidas quedan en $out_descriptivas
*******************************************************

*******************************************************
*      ▄▄▄▄                         ▀                    ▄          
*     █▀   ▀  ▄▄▄    ▄▄▄▄  ▄   ▄  ▄▄▄    ▄▄▄▄▄  ▄ ▄▄   ▄▄█▄▄   ▄▄▄  
*     ▀█▄▄▄  █▀  █  █▀ ▀█  █   █    █    █ █ █  █▀  █    █    █▀ ▀█ 
*         ▀█ █▀▀▀▀  █   █  █   █    █    █ █ █  █   █    █    █   █ 
*     ▀▄▄▄█▀ ▀█▄▄▀  ▀█▄▀█  ▀▄▄▀█  ▄▄█▄▄  █ █ █  █   █    ▀▄▄  ▀█▄█▀ 
*                    ▄  █                                           
*                     ▀▀                                            
*******************************************************

**# Seguimiento
** Resúmenes del panel para seguimiento en Git
*******************************************************
* Verificar la configuración y las llaves
if "$out_descriptivas" == "" {
    display as error "Define out_descriptivas en e8001_configurar.do."
    exit 198
}

confirm variable codigo_dane_municipio
confirm numeric variable anno

capture mkdir "$out_descriptivas"
* Conservar el panel original en memoria
preserve

* Registrar dimensiones y variables antes de crear auxiliares
local n_observaciones = _N
local n_variables = c(k)

unab variables : _all
*local variables : list sort variables

*******************************************************
**## Resumen general
*******************************************************

* Contar municipios distintos, excluyendo identificadores faltantes
tempvar tag_municipio tag_anno tag_mpio_anno
tempvar duplicada exceso annos_por_mpio tag_mpio_valido

egen byte `tag_municipio' = tag(codigo_dane_municipio)

quietly count if `tag_municipio' == 1 ///
    & !missing(codigo_dane_municipio)
local n_municipios = r(N)

* Contar años distintos
egen byte `tag_anno' = tag(anno)

quietly count if `tag_anno' == 1 & !missing(anno)
local n_annos = r(N)

quietly summarize anno, meanonly
local anno_min = r(min)
local anno_max = r(max)

* Identificar llaves faltantes
quietly count if missing(codigo_dane_municipio)
local falta_municipio = r(N)

quietly count if missing(anno)
local falta_anno = r(N)

quietly count if missing(codigo_dane_municipio) | missing(anno)
local falta_llave = r(N)

* Identificar duplicados entre las llaves completas
* "Filas involucradas" cuenta todas las filas de grupos duplicados.
* "Filas excedentes" cuenta las que sobran para tener una fila por llave.
bysort codigo_dane_municipio anno: ///
    gen byte `duplicada' = (_N > 1) ///
    if !missing(codigo_dane_municipio) & !missing(anno)

by codigo_dane_municipio anno: ///
    gen long `exceso' = _N - 1 if _n == 1 ///
    & !missing(codigo_dane_municipio) & !missing(anno)

quietly count if `duplicada' == 1
local filas_duplicadas = r(N)

quietly summarize `exceso', meanonly
local filas_excedentes = r(sum)

* Número de años distintos observados por municipio
* Los duplicados no incrementan este conteo.
egen byte `tag_mpio_anno' = tag(codigo_dane_municipio anno)

bysort codigo_dane_municipio: ///
    egen long `annos_por_mpio' = total(`tag_mpio_anno')

egen byte `tag_mpio_valido' = tag(codigo_dane_municipio) ///
    if !missing(codigo_dane_municipio) & !missing(anno)

quietly summarize `annos_por_mpio' if `tag_mpio_valido' == 1, detail
local annos_min = r(min)
local annos_mediana = r(p50)
local annos_max = r(max)

* Lista de años en orden ascendente
local annos ""
if `n_annos' > 0 {
    quietly levelsof anno if !missing(anno), local(annos)
}

* Escribir un resumen sin fechas ni rutas personales
tempname resumen

file open `resumen' using ///
    "$out_descriptivas/panel_resumen.txt", ///
    write text replace

file write `resumen' "RESUMEN GENERAL DEL PANEL" _n
file write `resumen' "Unidad: municipio-anno" _n _n

file write `resumen' "Observaciones: " ///
    %12.0f (`n_observaciones') _n

file write `resumen' "Variables: " ///
    %12.0f (`n_variables') _n

file write `resumen' "Municipios distintos: " ///
    %12.0f (`n_municipios') _n

file write `resumen' "Annos distintos: " ///
    %12.0f (`n_annos') _n

file write `resumen' "Anno inicial: " ///
    %12.0f (`anno_min') _n

file write `resumen' "Anno final: " ///
    %12.0f (`anno_max') _n _n

file write `resumen' "VALIDACION DE LLAVES" _n

file write `resumen' "Filas sin municipio: " ///
    %12.0f (`falta_municipio') _n

file write `resumen' "Filas sin anno: " ///
    %12.0f (`falta_anno') _n

file write `resumen' "Filas con llave incompleta: " ///
    %12.0f (`falta_llave') _n

file write `resumen' "Filas involucradas en llaves duplicadas: " ///
    %12.0f (`filas_duplicadas') _n

file write `resumen' "Filas excedentes por duplicacion: " ///
    %12.0f (`filas_excedentes') _n _n

file write `resumen' ///
    "ANNOS DISTINTOS POR MUNICIPIO CON LLAVES COMPLETAS" _n

file write `resumen' "Minimo: " ///
    %12.0f (`annos_min') _n

file write `resumen' "Mediana: " ///
    %12.1f (`annos_mediana') _n

file write `resumen' "Maximo: " ///
    %12.0f (`annos_max') _n _n

file write `resumen' "OBSERVACIONES POR ANNO" _n
file write `resumen' "anno,observaciones" _n

foreach a of local annos {

    quietly count if anno == `a'

    file write `resumen' ///
        %9.0f (`a') "," %12.0f (r(N)) _n
}

file write `resumen' ///
    "anno_faltante," %12.0f (`falta_anno') _n

file close `resumen'


*******************************************************
**## Inventario variables
** Inventario de todas las variables
*******************************************************

* Crear una tabla temporal: una fila por variable
tempfile inventario
tempname tabla_variables

postfile `tabla_variables' ///
    str32 variable ///
    str244 etiqueta ///
    str12 tipo ///
    double n_validos n_faltantes pct_faltantes n_ceros ///
    media desv_est minimo maximo ///
    using "`inventario'", replace

foreach v of local variables {

    local etiqueta : variable label `v'
    local tipo : type `v'

    * missing() funciona con variables numéricas y de texto.
    * En numéricas incluye ., .a, ..., .z.
    quietly count if missing(`v')
    local n_faltantes = r(N)

    local n_validos = `n_observaciones' - `n_faltantes'
    local pct_faltantes = ///
        100 * `n_faltantes' / `n_observaciones'

    * Inicializar estadísticas no aplicables como faltantes
    local n_ceros = .
    local media = .
    local desv_est = .
    local minimo = .
    local maximo = .

    capture confirm numeric variable `v'

    if _rc == 0 {

        quietly count if `v' == 0
        local n_ceros = r(N)

        * No calcular estadísticas económicas de identificadores
        if !inlist("`v'", "codigo_dane_municipio", ///
            "id_municipio", "anno", "_merge") {

            quietly summarize `v'

            local media = r(mean)
            local desv_est = r(sd)
            local minimo = r(min)
            local maximo = r(max)
        }
    }

    post `tabla_variables' ///
        ("`v'") ///
        (`"`etiqueta'"') ///
        ("`tipo'") ///
        (`n_validos') (`n_faltantes') (`pct_faltantes') ///
        (`n_ceros') (`media') (`desv_est') (`minimo') (`maximo')
}

postclose `tabla_variables'

*******************************************************
**## Cobertura anual de variables centrales
*******************************************************

* Editar esta lista cuando cambien las variables de interés.
* Si una variable no existe, se registra como ausente.
local variables_clave ///
    mineIleg_oro_nwPrp_SR21_pct ///
    mineLegl_oro_pRegls_prod_gr ///
    tituMine_oro_AreaSo_tGrn_m2Fx ///
    tituMine_oro_AreaSo_tOtr_m2Fx ///
    tituMine_oro_AreaTi_tGrn_m2Fx ///
    tituMine_oro_AreaTi_tOtr_m2Fx ///
    poteMine_oro_distnc_roca_m ///
    poteMine_oro_distnc_aluv_m ///
    precMine_oro_prmdio_oro_USoz ///
    prodAgr_total_ACosch_totl_ha ///
    prodAgr_total_ASembr_totl_ha ///
    prodAgr_total_Produc_totl_ton

local variables_clave : list sort variables_clave

tempfile cobertura
tempname tabla_cobertura

postfile `tabla_cobertura' ///
    double anno ///
    str32 variable ///
    byte existe ///
    double n_total n_validos n_faltantes pct_faltantes n_ceros ///
    using "`cobertura'", replace

foreach a of local annos {

    quietly count if anno == `a'
    local n_total = r(N)

    foreach v of local variables_clave {

        capture confirm variable `v'

        if _rc != 0 {

            * No confundir una columna ausente con valores faltantes
            post `tabla_cobertura' ///
                (`a') ("`v'") (0) (`n_total') (.) (.) (.) (.)
        }
        else {

            quietly count if anno == `a' & missing(`v')
            local n_faltantes = r(N)

            local n_validos = `n_total' - `n_faltantes'
            local pct_faltantes = ///
                100 * `n_faltantes' / `n_total'

            local n_ceros = .

            capture confirm numeric variable `v'

            if _rc == 0 {
                quietly count if anno == `a' & `v' == 0
                local n_ceros = r(N)
            }

            post `tabla_cobertura' ///
                (`a') ("`v'") (1) ///
                (`n_total') (`n_validos') (`n_faltantes') ///
                (`pct_faltantes') (`n_ceros')
        }
    }
}

postclose `tabla_cobertura'


*******************************************************
**## Exportar las tablas con orden y formatos fijos
*******************************************************

use "`inventario'", clear
*sort variable

format n_validos n_faltantes n_ceros %12.0f
format pct_faltantes %9.4f
format media desv_est minimo maximo %24.12g

export delimited using ///
    "$out_descriptivas/panel_variables.csv", ///
    replace datafmt

use "`cobertura'", clear
sort anno variable

format anno %9.0f
format n_total n_validos n_faltantes n_ceros %12.0f
format pct_faltantes %9.4f

export delimited using ///
    "$out_descriptivas/panel_cobertura_clave.csv", ///
    replace datafmt

* Recuperar el panel sin las variables auxiliares del resumen
restore

display as text "Resúmenes exportados a: $out_descriptivas"

*       ▄      ▄      ▄      ▄      ▄      ▄      ▄  
*     ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀
*     ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄
*       ▀      ▀      ▀      ▀      ▀      ▀      ▀  