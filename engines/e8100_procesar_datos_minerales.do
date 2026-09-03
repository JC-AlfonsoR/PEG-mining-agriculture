*******************************************************
** Mineral: Oro
** Primera Etapa
*******************************************************

*******************************************************
**# Preparar una base de potencial mineral por municipio
*******************************************************

* Cargar base de datos
use ///
    "$data_intermediate/e2100_panel_IndicadoresGeoEspaciales_Minerales.dta", ///
    clear

* Los datos de potencial geológico se almacenaron con anno=0
* El potencial geológico precede a cualquier asentamiento y se interpreta 
* que es persistente [Puede ser un supuesto fuerte -> Pendiente de buscar argumentos]
* Para representar la persistencia del potencial geológico, repito el valor observado
* en todos los años para los que tengo observaciones

* El año cero identifica variables invariantes
keep if anno == 0

* Mantener todas las variables de potencial de oro
keep codigo_dane_municipio ///
    poteMine_oro_*
    
* Comprobar que existe una sola fila por municipio
isid codigo_dane_municipio

* Guardar archivo temporal con potencial_oro
tempfile potencial_oro
save "`potencial_oro'"
	

*******************************************************
* 2. Integrar los datos de potencial con el panel de minería a nivel municipal
*******************************************************

* Cargar panel de minería legal e ilegal de oro
use ///
    "$data_intermediate/e2101_panel_InfoAdicional_Minerales.dta", ///
    clear

* Revisar el rango de años de los datos en el panel
tabulate anno

* Incluir el potencial mineral invariante en el municipio
*******************************************************
* El panel que tengo es (municipio, año). Los datos en potencial_oro solo
* estan identificados por municipio. Entonces, el merge replica el valor
* del potencial del municipio en cada año
merge m:1 codigo_dane_municipio using "`potencial_oro'"

* Conservar solo los datos de _merge==3
keep if _merge==3
drop _merge


*******************************************************
**# Transformar variables
*    ╺┳╸┏━┓┏━┓┏┓╻┏━┓┏━╸┏━┓┏━┓┏┳┓┏━┓┏━┓   ╻ ╻┏━┓┏━┓╻┏━┓┏┓ ╻  ┏━╸┏━┓
*     ┃ ┣┳┛┣━┫┃┗┫┗━┓┣╸ ┃ ┃┣┳┛┃┃┃┣━┫┣┳┛   ┃┏┛┣━┫┣┳┛┃┣━┫┣┻┓┃  ┣╸ ┗━┓
*     ╹ ╹┗╸╹ ╹╹ ╹┗━┛╹  ┗━┛╹┗╸╹ ╹╹ ╹╹┗╸   ┗┛ ╹ ╹╹┗╸╹╹ ╹┗━┛┗━╸┗━╸┗━┛
*******************************************************

*******************************************************
* Calcular variable de potencial a cualquier recurso mineral de oro
*******************************************************
* Los resultados han indicado que ambos tipos de potencial mueven tanto minería legal como ilegal
gen poteMine_oro_distnc = min(poteMine_oro_distnc_roca_m, poteMine_oro_distnc_aluv_m)


*******************************************************
* Transformar distancia al potencial mineral en proximidad al potencial mineral
*******************************************************
* Para que la interpretación del indicador de distancia al potencial mineral
* sea más intuitiva, voy a convertir distancia en proximidad
gen proximidad_potencial_gnrl = 1 / (1 + poteMine_oro_distnc/1000)
gen proximidad_potencial_roca = 1 / (1 + poteMine_oro_distnc_roca_m/1000)
gen proximidad_potencial_aluvion = 1 / (1 + poteMine_oro_distnc_aluv_m/1000)


*******************************************************
* Producción legal 
*******************************************************

* Explorar los valores de produccion por año
bysort anno: summarize mineLegl_oro_pRegls_prod_gr mineLegl_oro_pRegls_valr_COP
* Como los valores de cada variable se presentan en diferentes ordenes de 
* magnitud considero aplicar una transformación logaritmica

* Antes de aplicar la transoformacion logaritmica exploro los ceros de
* la variable mineLegl_oro_pRegls_prod_gr
bysort anno: count if mineLegl_oro_pRegls_prod_gr == 0
* El problema de los ceros se analizó al final de e2101_panel_InfoAdicional_Minerales
* Se concluyó que los ceros son errores de registro. Por eso se pueden eliminar.
replace mineLegl_oro_pRegls_prod_gr = . if mineLegl_oro_pRegls_prod_gr == 0


* Transformaciones logaritmicas
gen log_mineLegl_oro_prod_gr = log(1+mineLegl_oro_pRegls_prod_gr)
gen log_mineLegl_oro_valr_COP = log(1+mineLegl_oro_pRegls_valr_COP)

* Volver a Explorar los valores de produccion por año y las variables generadas
bysort anno: summarize mineLegl_oro_pRegls_prod_gr log_mineLegl_oro_prod_gr mineLegl_oro_pRegls_valr_COP log_mineLegl_oro_valr_COP


*******************************************************
**# Cargar información de Intención minería legal
*******************************************************

* Incorporar datos de titulos mineros
merge 1:1 codigo_dane_municipio anno using "$data_intermediate/e2100_panel_IndicadoresGeoEspaciales_Minerales.dta"

* Calcular flujo total de area SOLICITADA para mineria de oro en cada municipio-año
gen tituMine_oro_AreaSo_total_m2Fx  = tituMine_oro_AreaSo_tGrn_m2Fx + tituMine_oro_AreaSo_tOtr_m2Fx
gen log_tituMine_oro_AreaSo_total = log(1+tituMine_oro_AreaSo_total_m2Fx)

* Calcular flujo total de area TITULADA para mineria de oro en cada municipio-año
gen tituMine_oro_AreaTi_total_m2Fx  = tituMine_oro_AreaTi_tGrn_m2Fx + tituMine_oro_AreaTi_tOtr_m2Fx