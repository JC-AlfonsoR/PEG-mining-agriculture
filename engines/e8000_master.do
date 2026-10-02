*******************************************************
** e8000_master.do
**
** Objetivo:
** Coordinar la ejecución de las rutinas de Stata.
*******************************************************

*******************************************************
**# Preparar la sesión
*******************************************************

version 19.0
clear all
cls

*******************************************************
**# Ubicar la raíz del proyecto
*******************************************************
local computador = c(username)

if "`computador'" == "jcalf" {
    cd "C:/Users/jcalf/OneDrive - Universidad de los Andes/PEG/PEG-mining-agriculture"
}
else if "`computador'" == "javie" {
    cd "C:/Users/javie/OneDrive - Universidad de los andes/PEG/PEG-mining-agriculture"
}
else {
    display as error ///
        "Usuario no configurado: `computador'."
    display as error ///
        "Agrega la ruta de este computador en e8000_configurar.do."
    exit 198
}

* Guardar la raíz para construir rutas absolutas
global proyecto "`c(pwd)'"


*******************************************************
**# Ejecutar los scripts del proyecto
*******************************************************

* Cargar la configuracion de las rutas y variables globales
do "engines/e8001_configurar.do"

* Armar el panel final
do "$engines/e8050_armar_panel.do"

* Exportar resumen del panel para seguimiento con git
do "$engines/e8051_resumir_panel_para_seguimiento.do"