*******************************************************
** Unir paneles de indicadores mineros
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
cd "C:/Users/jcalf/OneDrive - Universidad de los Andes/PEG/PEG-mining-agriculture"

* Verificación
pwd

*******************************************************
**# Anexar bases de datos de indicadores mineros
*******************************************************

* 1. Definir la carpeta donde están las bases
local data_intermediate "data/intermediate"

* 2. Crear el nombre de un archivo temporal
tempfile info_adicional

* 3. Cargar temporalmente la segunda base
use ///
    "`data_intermediate'/e2101_panel_InfoAdicional_Minerales.dta", ///
    clear
