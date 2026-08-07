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
**# Cargar bases de datos de indicadores mineros
*******************************************************

* Definir la carpeta donde están las bases
local data_intermediate "data/intermediate"


* Cargar la primer base de datos
use ///
    "`data_intermediate'/e2100_panel_IndicadoresGeoEspaciales_Minerales.dta", ///
    clear

* Verificar que municipio-año identifique cada fila
* Si las variables no identifican la observación sale un mensaje de error
isid codigo_dane_municipio anno

* Unir las columnas de la base e2101_InfoAdicional
merge 1:1 codigo_dane_municipio anno using ///
    "`data_intermediate'/e2101_panel_InfoAdicional_Minerales.dta"
		
* Examinar el resultado
tabulate _merge

* Revisar las observaciones (municipio,año) que no estan en ambas bases
list codigo_dane_municipio anno if _merge != 3, ///
    sepby(_merge)



* Revisar consistencia del panel
*******************************************************

* Verificar que municipio-año identifique cada fila
* Si las variables no identifican la observación sale un mensaje de error
isid codigo_dane_municipio anno

* Declarar la estructura del panel
xtset codigo_dane_municipio anno
	
*******************************************************
**# Primera etapa
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
**# Primera etapa: Oro en seccion transversal
*    ┏━┓    ╺┳╸┏━┓┏━┓┏┓╻┏━┓╻ ╻┏━╸┏━┓┏━┓┏━┓╻  
*    ┗━┓     ┃ ┣┳┛┣━┫┃┗┫┗━┓┃┏┛┣╸ ┣┳┛┗━┓┣━┫┃  
*    ┗━┛╹    ╹ ╹┗╸╹ ╹╹ ╹┗━┛┗┛ ┗━╸╹┗╸┗━┛╹ ╹┗━╸
*******************************************************

*******************************************************
* Minería legal
* Busco responder a la pregunta ¿Los municipios con mayor potencial aurífero 
* presentan, en promedio, mayor actividad minera legal?
*******************************************************



* Mineria legal de oro
* mineLegl_oro_pRegls_valr_COP mineLegl_oro_pRegls_prod_gr 

* Mineria ilegal de oro
* mineIleg_oro_area_SR21_km2 mineIleg_oro_nwPrp_SR21_pct mineIleg_oro_prpMun_SR21_pct

* Instrumento de Veta

*******************************************************
**# Primera etapa: Oro en Panel
*    ┏━┓┏━┓┏┓╻┏━╸╻  
*    ┣━┛┣━┫┃┗┫┣╸ ┃  
*    ╹  ╹ ╹╹ ╹┗━╸┗━╸
*******************************************************

* Instrumento de aluvion