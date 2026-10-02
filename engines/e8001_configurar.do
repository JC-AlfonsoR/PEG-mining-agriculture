*******************************************************
** e8001_configurar.do
**
** Objetivo:
** Configurar el entorno y las rutas del proyecto.
**
** Esta rutina no carga ni modifica bases de datos.
*******************************************************


set more off
set varabbrev off




*******************************************************
**# Definir rutas
*******************************************************

* Datos
global data_raw          "$proyecto/data/raw"
global data_intermediate "$proyecto/data/intermediate"
global data_final        "$proyecto/data/final"

* Código
global engines           "$proyecto/engines"

* Resultados
global outputs           "$proyecto/outputs"
global out_regresiones   "$outputs/regresiones"
global out_descriptivas  "$outputs/descriptivas"
*global out_figuras       "$outputs/figuras"

* Panel final
global panel_analisis ///
    "$data_final/panel_municipio_anno.dta"

	
* Crear carpetas de destino si no existen
capture mkdir "$data_final"
capture mkdir "$outputs"
capture mkdir "$out_regresiones"
capture mkdir "$out_descriptivas"
*capture mkdir "$out_figuras"

*******************************************************
**# Comprobar paquetes para el análisis
*******************************************************

* Solo comprobar disponibilidad.
* La instalación y actualización se hacen por separado.

local faltantes ""

foreach paquete in ftools reghdfe ivreg2 ranktest ivreghdfe estout {

    capture which `paquete'

    if _rc {
        local faltantes "`faltantes' `paquete'"
    }
}

if "`faltantes'" != "" {
    display as error ///
        "Aviso: faltan paquetes para el análisis:`faltantes'"
    display as text ///
        "Puedes construir el panel, pero debes instalarlos antes de estimar."
}


*******************************************************
**# Mostrar configuración
*******************************************************

display as text "Configuración del proyecto:"
display as text "  Usuario:  " as result c(username)
display as text "  Raíz:     " as result "$proyecto"
display as text "  Panel:    " as result "$panel_analisis"
display as text "  Salidas:  " as result "$outputs"


*       ▄      ▄      ▄      ▄      ▄      ▄      ▄  
*     ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀
*     ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄
*       ▀      ▀      ▀      ▀      ▀      ▀      ▀  