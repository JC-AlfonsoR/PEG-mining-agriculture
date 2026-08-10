*******************************************************
** Mineral: Oro
** Primera Etapa
*******************************************************

*******************************************************
**# Primera Etapa en oro
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

* Definir la carpeta donde están las bases
local data_intermediate "data/intermediate"


*******************************************************
**# Preparar una base de potencial mineral por municipio
*******************************************************

* Cargar base de datos
use ///
    "`data_intermediate'/e2100_panel_IndicadoresGeoEspaciales_Minerales.dta", ///
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
    "`data_intermediate'/e2101_panel_InfoAdicional_Minerales.dta", ///
    clear

* Revisar el rango de años de los datos en el panel
tabulate anno

* Incluir el potencial mineral invariante
*******************************************************
* El panel que tengo es (municipio, año). Los datos en potencial_oro solo
* estan identificados por municipio. Entonces, el merge replica el valor
* del potencial del municipio en cada año
merge m:1 codigo_dane_municipio using "`potencial_oro'"

* Convervar solo los datos de _merge==3
keep if _merge==3


*******************************************************
**# Convertir datos
*    ╺┳╸┏━┓┏━┓┏┓╻┏━┓┏━╸┏━┓┏━┓┏┳┓┏━┓┏━┓   ╻ ╻┏━┓┏━┓╻┏━┓┏┓ ╻  ┏━╸┏━┓
*     ┃ ┣┳┛┣━┫┃┗┫┗━┓┣╸ ┃ ┃┣┳┛┃┃┃┣━┫┣┳┛   ┃┏┛┣━┫┣┳┛┃┣━┫┣┻┓┃  ┣╸ ┗━┓
*     ╹ ╹┗╸╹ ╹╹ ╹┗━┛╹  ┗━┛╹┗╸╹ ╹╹ ╹╹┗╸   ┗┛ ╹ ╹╹┗╸╹╹ ╹┗━┛┗━╸┗━╸┗━┛
*******************************************************


*******************************************************
* Transformar distancia al potencial mineral en proximidad al potencial mineral
*******************************************************
* Para que la interpretación del indicador de distancia al potencial mineral
* sea más intuitiva, voy a convertir distancia en proximidad
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
**# Definir especificaciones principal
*    ┏━╸┏━┓┏━┓┏━╸┏━╸    ┏━┓┏━┓╻┏┓╻┏━╸╻┏━┓┏━┓╻  
*    ┣╸ ┗━┓┣━┛┣╸ ┃      ┣━┛┣┳┛┃┃┗┫┃  ┃┣━┛┣━┫┃  
*    ┗━╸┗━┛╹  ┗━╸┗━╸╹   ╹  ╹┗╸╹╹ ╹┗━╸╹╹  ╹ ╹┗━╸
*******************************************************

* Definir las variables del modelo

* Potencial mineral en roca
local potencial_mineral_roca proximidad_potencial_roca 

* Minería legal
local mineria_legal log_mineLegl_oro_prod_gr

* Potencial mineral en aluvion
local potencial_mineral_aluvion proximidad_potencial_aluvion

* Minería ilegal:
* mineIleg_oro_area_SR21_km2 mineIleg_oro_nwPrp_SR21_pct mineIleg_oro_prpMun_SR21_pct
local mineria_ilegal mineIleg_oro_nwPrp_SR21_pct


*******************************************************
**# Sección Transversal
*      ▄▄▄▄               ▄▄▄▄▄▄▄                                          
*     █▀   ▀                 █     ▄ ▄▄   ▄▄▄   ▄ ▄▄    ▄▄▄   ▄   ▄        
*     ▀█▄▄▄                  █     █▀  ▀ ▀   █  █▀  █  █   ▀  ▀▄ ▄▀        
*         ▀█                 █     █     ▄▀▀▀█  █   █   ▀▀▀▄   █▄█         
*     ▀▄▄▄█▀   █             █     █     ▀▄▄▀█  █   █  ▀▄▄▄▀    █      █   
*******************************************************
* Voy a probar la primera etapa en cada uno de los años disponibles
* Busco responder a la pregunta ¿Los municipios con mayor potencial aurífero 
* presentan, en promedio, mayor actividad minera legal?

*******************************************************
**## Minería Legal
*    ┏┳┓╻┏┓╻┏━╸┏━┓╻┏━┓   ╻  ┏━╸┏━╸┏━┓╻  
*    ┃┃┃┃┃┗┫┣╸ ┣┳┛┃┣━┫   ┃  ┣╸ ┃╺┓┣━┫┃  
*    ╹ ╹╹╹ ╹┗━╸╹┗╸╹╹ ╹   ┗━╸┗━╸┗━┛╹ ╹┗━╸
*******************************************************
* La especificacion principal es con 
* Potencial: proximidad_potencial_roca 
* Produccion legal: log_mineLegl_oro_prod_gr


*******************************************************
**### Roca
*******************************************************
* Explorar los cortes transversales de cada año
* Minería legal explicada por Potencial de roca
preserve
	
	* Eliminar datos faltantes
	drop if missing(codigo_dane_municipio, `mineria_legal')

	* Estimar una regresión transversal por año
	statsby ///
		b_roca  = _b[`potencial_mineral_roca'] ///
		se_roca    = _se[`potencial_mineral_roca'] ///
		n     = e(N) ///
		f_stat = e(F) ///
		r2    = e(r2) ///
		df_r  = e(df_r), ///
		by(anno) clear: ///
		regress `mineria_legal' ///
			`potencial_mineral_roca', ///
			vce(robust)

	* Valor p de H0: b_roca = 0
	gen pv_roca = 2 * ttail(df_r, abs(b_roca / se_roca))

	* Eliminar variable auxiliar
	drop df_r

	* Formato y presentación
	format b_roca se_roca f_stat r2 pv_roca %9.4f

	display "=========================================="
    display "Sección transversal para cada año"
	display "X: Potencial mineral en roca medido como: `potencial_mineral_roca'"
	display "Y: Minería legal medida como: `mineria_legal'"
    display "=========================================="
	
	* Mostrar valores
	list anno n b_roca se pv_roca f_stat r2, noobs

restore

*******************************************************
**### Aluvion + Roca
*******************************************************
* Explorar los cortes transversales de cada año
* Minería legal explicada por Potencial de roca y potencial de aluvion
preserve
	
	* Eliminar datos faltantes
	drop if missing(codigo_dane_municipio, `mineria_legal')

	* Estimar una regresión transversal por año
	statsby ///
		b_roca  = _b[`potencial_mineral_roca'] ///
		se_roca    = _se[`potencial_mineral_roca'] ///
		b_aluv = _b[`potencial_mineral_aluvion'] ///
		se_aluv = _se[`potencial_mineral_aluvion'] ///
		n     = e(N) ///
		f_stat = e(F) ///
		r2    = e(r2) ///
		df_r  = e(df_r), ///
		by(anno) clear: ///
		regress `mineria_legal' ///
			`potencial_mineral_roca' `potencial_mineral_aluvion', ///
			vce(robust)

	* Valor p de H0: beta = 0
	gen pv_roca = 2 * ttail(df_r, abs(b_roca / se_roca))
	gen pv_aluv = 2 * ttail(df_r, abs(b_aluv / se_aluv))

	* Eliminar variable auxiliar
	drop df_r

	* Formato y presentación
	format b_roca se_roca pv_roca f_stat r2  b_aluv pv_aluv se_aluv %9.4f

	display "=========================================="
    display "Sección transversal para cada año"
	display "X: Potencial mineral en roca medido como: `potencial_mineral_roca'"
	display "Y: Minería legal medida como: `mineria_legal'"
    display "=========================================="
	
	* Mostrar valores
	list anno n b_roca se_roca pv_roca b_aluv se_aluv pv_aluv  f_stat r2, noobs

restore




*******************************************************
**## Minería Ilegal
*    ┏┳┓╻┏┓╻┏━╸┏━┓╻┏━┓   ╻   ╻  ┏━╸┏━╸┏━┓╻  
*    ┃┃┃┃┃┗┫┣╸ ┣┳┛┃┣━┫   ┃╺━╸┃  ┣╸ ┃╺┓┣━┫┃  
*    ╹ ╹╹╹ ╹┗━╸╹┗╸╹╹ ╹   ╹   ┗━╸┗━╸┗━┛╹ ╹┗━╸
*******************************************************

* La especificacion principal es con 
* Potencial: proximidad_potencial_aluvion
* Produccion ilegal: mineIleg_oro_nwPrp_SR21_pct

*******************************************************
**### Aluvion
*******************************************************

* Explorar los cortes transversales de cada año
preserve
	
	* Eliminar datos faltantes
	drop if missing(codigo_dane_municipio, `mineria_ilegal')

	* Estimar una regresión transversal por año
	statsby ///
		b_aluv = _b[`potencial_mineral_aluvion'] ///
		se_aluv = _se[`potencial_mineral_aluvion'] ///
		n     = e(N) ///
		f_stat = e(F) ///
		r2    = e(r2) ///
		df_r  = e(df_r), ///
		by(anno) clear: ///
		regress `mineria_ilegal' ///
			`potencial_mineral_aluvion', ///
			vce(robust)

	* Valor p de H0: beta = 0
	gen pv_aluv = 2 * ttail(df_r, abs(b_aluv / se_aluv))

	* Eliminar variable auxiliar
	drop df_r

	* Formato y presentación
	format f_stat r2  b_aluv pv_aluv se_aluv %9.4f

	display "=========================================="
    display "Sección transversal para cada año"
	display "X: Potencial mineral en roca medido como: `potencial_mineral_aluvion'"
	display "Y: Minería legal medida como: `mineria_ilegal'"
    display "=========================================="
	
	* Mostrar valores
	list anno n b_aluv se_aluv pv_aluv  f_stat r2, noobs

restore


*******************************************************
**### Aluvion + Roca
*******************************************************

* Explorar los cortes transversales de cada año
* Minería ilegal explicada por Potencial de roca y potencial de aluvion
preserve
	
	* Eliminar datos faltantes
	drop if missing(codigo_dane_municipio, `mineria_ilegal')

	* Estimar una regresión transversal por año
	statsby ///
		b_roca  = _b[`potencial_mineral_roca'] ///
		se_roca    = _se[`potencial_mineral_roca'] ///
		b_aluv = _b[`potencial_mineral_aluvion'] ///
		se_aluv = _se[`potencial_mineral_aluvion'] ///
		n     = e(N) ///
		f_stat = e(F) ///
		r2    = e(r2) ///
		df_r  = e(df_r), ///
		by(anno) clear: ///
		regress `mineria_ilegal' ///
			`potencial_mineral_roca' `potencial_mineral_aluvion', ///
			vce(robust)

	* Valor p de H0: beta = 0
	gen pv_roca = 2 * ttail(df_r, abs(b_roca / se_roca))
	gen pv_aluv = 2 * ttail(df_r, abs(b_aluv / se_aluv))

	* Eliminar variable auxiliar
	drop df_r

	* Formato y presentación
	format b_roca se_roca pv_roca f_stat r2  b_aluv pv_aluv se_aluv %9.4f

	display "=========================================="
    display "Sección transversal para cada año"
	display "X: Potencial mineral en roca medido como: `potencial_mineral_aluvion'"
	display "Y: Minería legal medida como: `mineria_ilegal'"
    display "=========================================="
	
	* Mostrar valores
	list anno n b_roca se_roca pv_roca b_aluv se_aluv pv_aluv  f_stat r2, noobs

restore




*******************************************************
**# Panel
*     ▄▄▄▄▄                       ▀▀█   
*     █   ▀█  ▄▄▄   ▄ ▄▄    ▄▄▄     █   
*     █▄▄▄█▀ ▀   █  █▀  █  █▀  █    █   
*     █      ▄▀▀▀█  █   █  █▀▀▀▀    █   
*     █      ▀▄▄▀█  █   █  ▀█▄▄▀    ▀▄▄ 
*******************************************************




*******************************************************
* Minería legal

*******************************************************
