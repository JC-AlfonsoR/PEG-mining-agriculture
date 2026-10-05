*******************************************************
** e8050_armar_panel.do
**
** Objetivo:
** Armar panel de datos del proyecto
**
** Ejecutar despues de e8001_configurar.do, desde el master.
** Salida: $panel_analisis
*******************************************************


*******************************************************
**# Verificar orden de ejecución de los do-files
*******************************************************
* La configuracion general corresponde a e8001_configurar.do.
if "$data_intermediate" == "" | "$panel_analisis" == "" {
    display as error "Ejecuta e8001_configurar.do antes de armar el panel."
    exit 198
}



*******************************************************
*     ▄    ▄   ▀                           ▄▀         
*     ██  ██ ▄▄▄    ▄ ▄▄    ▄▄▄    ▄ ▄▄  ▄▄▄     ▄▄▄  
*     █ ██ █   █    █▀  █  █▀  █   █▀  ▀   █    ▀   █ 
*     █ ▀▀ █   █    █   █  █▀▀▀▀   █       █    ▄▀▀▀█ 
*     █    █ ▄▄█▄▄  █   █  ▀█▄▄▀   █     ▄▄█▄▄  ▀▄▄▀█ 
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
**# Integrar los datos de potencial con el panel de minería a nivel municipal
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


*******************************************************
**# Minería legal
** Cargar información de Intención minería legal
*******************************************************

* Incorporar datos de titulos mineros
merge 1:1 codigo_dane_municipio anno using "$data_intermediate/e2100_panel_IndicadoresGeoEspaciales_Minerales.dta"

* Revisar el cruce y eliminar su indicador
tabulate _merge
drop _merge



*******************************************************
**# Precio minerales
** Incluir el precio anual de los minerales
*******************************************************

* El panel que tengo es (municipio, año). Los datos en precios_minerales solo estan identificados por año. Entonces, el merge replica el valor del precio anual para cada municipio
merge m:1 anno using "$data_intermediate/e3000_precios_minerales.dta"

* Analizar merge
tab _merge
*br if _merge==2
* Las observaciones de _merge==2 son años desde 1960 hasta 2003.
* En esos años hay datos de precios, pero no hay datos
* mineria legal, minerai ilegal. Por eso se desechan esos datos
keep if _merge==3
drop _merge


*******************************************************
*       ▄▄                       
*       ██    ▄▄▄▄   ▄ ▄▄   ▄▄▄  
*      █  █  █▀ ▀█   █▀  ▀ █▀ ▀█ 
*      █▄▄█  █   █   █     █   █ 
*     █    █ ▀█▄▀█   █     ▀█▄█▀ 
*             ▄  █               
*              ▀▀                
*******************************************************

*******************************************************
**# Agro
** Cargar información agrícola
*******************************************************

* Cargar panel de cultivos
merge 1:1 codigo_dane_municipio anno using "$data_intermediate/e1101_panel_informacionAgricola.dta"

* Revisar el cruce y eliminar su indicador
tabulate _merge
drop _merge


*******************************************************
*     ▄▄▄▄▄                  ▄▄▄  ▄▄▄▄▄▄ ▄▄▄▄   ▄▄▄▄▄▄
*     █   ▀█               ▄▀   ▀ █      █   ▀▄ █     
*     █▄▄▄█▀               █      █▄▄▄▄▄ █    █ █▄▄▄▄▄
*     █                    █      █      █    █ █     
*     █        █            ▀▄▄▄▀ █▄▄▄▄▄ █▄▄▄▀  █▄▄▄▄▄
**# P. CEDE
*******************************************************
local id_cede  codmpio
local anno_cede ano

* Archivos y variables que se incorporarán
local archivo1 "PANEL_CARACTERISTICAS_GENERALES(2024).dta"
local variables1 altura dismdo retro_pobl_rur

local archivo2 "PANEL_SALUD_Y_SERVICIOS.dta"
local variables2 icee_resto

local archivo3 "PANEL_AGRICULTURA_Y_TIERRA(2024).dta"
local variables3 vrf_peq_productor nuf_peq_productor

local archivo4 "PANEL_BUEN_GOBIERNO(2024).dta"
local variables4 inv_agropecuario inv_tranporte

local archivo5 "PANEL_CONFLICTO_Y_VIOLENCIA(2024).dta"
local variables5 hostig_MD desplazados_expulsion H_coca

local archivo6 "PANEL_DE_EDUCACION(2023).dta"
local variables6 anos_est_mun

* Verificar la llave del panel que estamos construyendo
isid codigo_dane_municipio anno

* Archivo temporal reutilizado para cada componente CEDE
tempfile cede_componente

forvalues i = 1/6 {

    * Preparar el componente CEDE sin perder el panel en memoria
    preserve

        use "$data_raw/aaa_panel_cede/microdatos/`archivo`i''", clear

        * Conservar identificadores y variables seleccionadas
        keep `id_cede' `anno_cede' `variables`i''

        * Homologar los nombres de los identificadores
        if "`id_cede'" != "codigo_dane_municipio" {
            rename `id_cede' codigo_dane_municipio
        }

        if "`anno_cede'" != "anno" {
            rename `anno_cede' anno
        }

        * Convertir el código municipal CEDE a texto de cinco dígitos
		tostring codigo_dane_municipio, replace format(%05.0f)

		* Verificar la llave
		isid codigo_dane_municipio anno

        save "`cede_componente'", replace

    restore

    * Incorporar variables sin agregar observaciones al panel
    merge 1:1 codigo_dane_municipio anno ///
        using "`cede_componente'", ///
        keepusing(`variables`i'') ///
        keep(master match)

    * Revisar cuántas observaciones encontraron correspondencia
    display as text "Cruce con: `archivo`i''"
    tabulate _merge

    drop _merge
}

*******************************************************
*     ▄▄▄▄▄▄                               ▄                 
*     █      ▄   ▄  ▄▄▄▄    ▄▄▄    ▄ ▄▄  ▄▄█▄▄   ▄▄▄    ▄ ▄▄ 
*     █▄▄▄▄▄  █▄█   █▀ ▀█  █▀ ▀█   █▀  ▀   █    ▀   █   █▀  ▀
*     █       ▄█▄   █   █  █   █   █       █    ▄▀▀▀█   █    
*     █▄▄▄▄▄ ▄▀ ▀▄  ██▄█▀  ▀█▄█▀   █       ▀▄▄  ▀▄▄▀█   █    
*                   █                                    
*                   ▀                                          
*******************************************************

*******************************************************
**# Exportar
** Cargar información agrícola
*******************************************************
* Verificar la llave del panel antes de exportar
isid codigo_dane_municipio anno

save "$panel_analisis", replace
display as text "Panel guardado en: " as result "$panel_analisis"

*       ▄      ▄      ▄      ▄      ▄      ▄      ▄  
*     ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀  ▀▄█▄▀
*     ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄  ▄▀█▀▄
*       ▀      ▀      ▀      ▀      ▀      ▀      ▀  