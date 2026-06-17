**# Preámbulo
*******************************************************************
* En este do-file corro las regresiones de variables instrumentales de mi tesis del PEG




**# Preprocesamiento
*******************************************************************	


* Definir variables del modelo
global Y = "LOG_Caf__Producci_n__t_"
global X "LOG_area_cosechada_HA_no_Caf_"
global D = "LOG_Produccion_ORO_GRAMOS"
global Z_porcentajeArea = "Z_pct_municipio_potencial_oro_pr"
global Z_proximidad = "Z_proximidad_geo_oro_precio"
global Z3 "Z_potencial_area_proximidad_prec"
global municipio = "C_digo_Dane_municipio"
global anno = "A_o"


* Cargar datos
clear all
set more off
use "C:/Users/jcalf/OneDrive - Universidad de los Andes/PEG/PEG-mining-agriculture/Efforts/8_estructurar_panel_para_STATA/outputs/panel_IV.dta"
describe

* Conservar solo las variables de interés
*keep $Y $X $D $Z1 $municipio $anno

* Eliminar observaciones de NaN
*egen nmiss = rowmiss(Caf__Producci_n__t_ $D $Z1 $Z2 $Z3 area_cosechada_HA_no_Caf_)
*drop if nmiss > 0
*drop nmiss
drop if missing(C_digo_Dane_municipio, A_o, LOG_Produccion_ORO_GRAMOS, Z_pct_municipio_potencial_oro_pr, Z_potencial_area_proximidad_prec, Z_proximidad_geo_oro_precio, LOG_area_cosechada_HA_no_Caf_)
describe

* Declarar panel
encode $municipio, gen(id_mpio)
xtset id_mpio $anno

*reg $Y $D $X
* En la regresión lineal simple, la producción legal de oro tiene un efecto ambiguo sobre la producción de café

**# Relevancia del instrumento ************************************************
*******************************************************************

* Revisar la primera etapa
reghdfe $D $Z_proximidad $X, absorb(id_mpio $anno)
reghdfe $D $Z_porcentajeArea $X, absorb(id_mpio $anno)


**# MC2e
ivreghdfe $Y $X ($D = $Z_porcentajeArea), ///
	absorb(id_mpio $anno) ///
	cluster(id_mpio) ///
	first