# Esquema procesamiento de datos
- Las bases de datos se muestran con recuadros
    - Las resaltadas en rojo tinen están en el fromato panel que se muestra en la siguiente sección y en ```.dta``` para cargarlas en Stata
- Los scripts de Python se muestran con rombos
- Los scripts de Stata se muestran como círculos

```mermaid
flowchart LR

%% Estilos %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classDef base_para_stata stroke:#f00

%% Bases de datos crudas
UPRA_antiguo[UPRA 2007-2018]
UPRA_nuevo[UPRA 2019-2024]
ANM_web[ANM: Servidor ArcGIS]
ANM_titulos_mineros[ANM: títulos mineros]
e2001_poligonos_titulosmineros[data/raw/
e2001_poligonos
titulosmineros]
SGC_zonas_potencial[SGC:
zonas potencial mineral]
SGC_aluviones[SGC:
Aluviones]
UPME_produccion_regalias[UPME:
produccion asociada 
regalias]
SR2021_mineria_ilegal[SR2021
minería ilegal]
DANE_poligonos_municipales[DANE:
poligonos municipales]
WB_pinkSheet_preciosMateriasPrimas[World Bank
Pink Sheet:
Precios Materias Primas]
CHIRPS_precipitacion[CHIRPS precipitación]
CHIRTS_temperatura[CHIRTS Temperatura]

%% Bases de datos intermedias %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
e2011_poligonos_titulosmineros_armonizado[data/intermediate/
e2011_ANM_poligonosTitulosMineros]
e2011_SGC_ZonasPotencialMineral_armonizado[data/intermediate/
e2011_SGC_ZonasPotencialMineral_armonizado]
e2011_SGC_Aluviones_armonizado[data/intermediate/
e2011_SGC_Aluviones_armonizado]
e2011_UPME_produccionRegalias[data/intermediate/
e2011_UPME_produccionRegalias_armonizado]
e2011_SR2021_mineriaIlegal[data/intermediate/
e2011_SR2021_mineriaIlegal_armonizado]
e2011_WbPinkSheet_preciosMinerales_armonizado[data/intermediate/e2011
World Bank - Pink Sheet
Precios Minerales armonizado]
e1001_panel_cultivos_UPRA[data/intermediate/
e1001_panel_cultivos_UPRA]



%% Bases de datos intermedias para STATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
e1101_panel_informacion_agricola[data/intermediate/
e1101_panel_informacionAgricola]:::base_para_stata
e1011_panel_IndicadoresEspaciales_Clima[data/intermediate/
e1011_panel_IndicadoresEspaciales_Clima]:::base_para_stata
e2100_panel_IndicadoresGeoEspaciales_Minerales[data/intermediate/
e2100_panel_IndicadoresGeoEspaciales_Minerales]:::base_para_stata
e2101_panel_InfoAdicional_Minerales[data/intermediate/
e2101_panel_InfoAdicional_Minerales]:::base_para_stata
e3000_preciosMinerales[data/intermediate/
e3000 Precios de minerales]:::base_para_stata
panel_analisis[data/final/
panel_municipio_anno.dta]:::base_para_stata
panel_CEDE[data/raw/
Panel CEDE]:::base_para_stata

%% archivos de configuracion %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
1001_2_crosswalk_armonizado[data/config/
1001_2_crosswalk_armonizado]
2011_crosswalk_minerales_armonizado[data/config/
2011_crosswalk
minerales_armonizado]


%% engines Python %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

e1001_processs_UPRA{e1001
processs_UPRA}

e1010_descargar_precipitacion_temperatura{e1010 descargar
precipitacion y temperatura}

e1011_calcular_indicadoresEspaciales_clima{e1011 calcular
Indicadores Espaciales
 de Clima}

e1101_organizar_info_agricola{e1101
Organizar información
Agrícola}

e2001_descargar_poligonostitulosmineros{e2001
descargar
poligonos titulos mineros}

e2011_armonizar_taxonomias_minerales{e2011
armonizar taxonomias
minerales}

e2100_calcular_indicadoresGeoEspaciales_minerales{e2100
Calcular Indicadores Geoespaciales
de Minerales}

e2101_organizar_informacionAdicional_minerales{e2101
Organizar Información Adicional de Minerales}

e3000_procesarPreciosMinerales{e3000
Procesar Precios de minerales}

%% engines STATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

e8000_master((e8000 master))
e8001_configurar((e8001 configurar))
e8050_armar_panel((e8050 armar panel))
e8051_resumir_panel_seguimiento((e8051 resumir
panel para seguimiento))
e8100_preparar_variables_analisis((e8100 preparar
variables para análisis))
e8501_VI_especificacionPrincipal((8501 VI
Especificación Principal))
e8201_primera_etapa((8201 Primera Etapa))



%% Resumenes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resumen_outputs_variables[outputs/
descriptivas/
panel_variables.csv]
resumen_outputs_resumen[outputs/
descriptivas/
panel_resumen.txt]
resumen_outputs_cobertura_clave[outputs/
descriptivas/
panel_cobertura_clave.csv]

%% Resultados regresiones %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resultados_regresiones@{ shape: docs, label: "Resultados Regresiones"}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% conexiones %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% e1001_processs_UPRA
UPRA_antiguo--->e1001_processs_UPRA
UPRA_nuevo--->e1001_processs_UPRA
e1001_processs_UPRA--->e1001_panel_cultivos_UPRA
e1001_processs_UPRA--->1001_2_crosswalk_armonizado
e1001_panel_cultivos_UPRA--->e1101_organizar_info_agricola
e1101_organizar_info_agricola--->e1101_panel_informacion_agricola

%% e2001_descargar_poligonostitulosmineros
ANM_web--->e2001_descargar_poligonostitulosmineros
ANM_titulos_mineros--->e2001_descargar_poligonostitulosmineros
e2001_descargar_poligonostitulosmineros--->e2001_poligonos_titulosmineros

%% e2011_armonizar_taxonomias_minerales
e2001_poligonos_titulosmineros--->e2011_armonizar_taxonomias_minerales
SGC_zonas_potencial--->e2011_armonizar_taxonomias_minerales
SGC_aluviones--->e2011_armonizar_taxonomias_minerales
UPME_produccion_regalias--->e2011_armonizar_taxonomias_minerales
SR2021_mineria_ilegal--->e2011_armonizar_taxonomias_minerales
WB_pinkSheet_preciosMateriasPrimas--->e2011_armonizar_taxonomias_minerales

e2011_armonizar_taxonomias_minerales--->2011_crosswalk_minerales_armonizado
e2011_armonizar_taxonomias_minerales--->e2011_poligonos_titulosmineros_armonizado
e2011_armonizar_taxonomias_minerales--->e2011_SGC_ZonasPotencialMineral_armonizado
e2011_armonizar_taxonomias_minerales--->e2011_SGC_Aluviones_armonizado
e2011_armonizar_taxonomias_minerales--->e2011_UPME_produccionRegalias
e2011_armonizar_taxonomias_minerales--->e2011_SR2021_mineriaIlegal
e2011_armonizar_taxonomias_minerales--->e2011_WbPinkSheet_preciosMinerales_armonizado

%% e2100_calcular_instrumentos_potencial
e2011_SGC_ZonasPotencialMineral_armonizado--->e2100_calcular_indicadoresGeoEspaciales_minerales
e2011_SGC_Aluviones_armonizado--->e2100_calcular_indicadoresGeoEspaciales_minerales
DANE_poligonos_municipales--->e2100_calcular_indicadoresGeoEspaciales_minerales
e2011_poligonos_titulosmineros_armonizado--->e2100_calcular_indicadoresGeoEspaciales_minerales
e2100_calcular_indicadoresGeoEspaciales_minerales--->e2100_panel_IndicadoresGeoEspaciales_Minerales

%% Controles climáticos
e1010_descargar_precipitacion_temperatura--->CHIRPS_precipitacion
e1010_descargar_precipitacion_temperatura--->CHIRTS_temperatura
CHIRTS_temperatura--->e1011_calcular_indicadoresEspaciales_clima
CHIRPS_precipitacion--->e1011_calcular_indicadoresEspaciales_clima
DANE_poligonos_municipales--->e1011_calcular_indicadoresEspaciales_clima
e1011_calcular_indicadoresEspaciales_clima--->e1011_panel_IndicadoresEspaciales_Clima

%% Organizar información adicional de minerales
e2011_SR2021_mineriaIlegal--->e2101_organizar_informacionAdicional_minerales
e2011_UPME_produccionRegalias--->e2101_organizar_informacionAdicional_minerales
e2101_organizar_informacionAdicional_minerales--->e2101_panel_InfoAdicional_Minerales

%% Precios de minerales
e2011_WbPinkSheet_preciosMinerales_armonizado--->e3000_procesarPreciosMinerales
e3000_procesarPreciosMinerales--->e3000_preciosMinerales

%% Armar panel en STATA
e2100_panel_IndicadoresGeoEspaciales_Minerales--->e8050_armar_panel
e2101_panel_InfoAdicional_Minerales--->e8050_armar_panel
e3000_preciosMinerales-->e8050_armar_panel
e1101_panel_informacion_agricola--->e8050_armar_panel
e1011_panel_IndicadoresEspaciales_Clima--->e8050_armar_panel
panel_CEDE--->e8050_armar_panel

%% STATA
 subgraph STATA

 %% Rutinas globales
 e8000_master
 e8001_configurar

%% Conexiones del main
e8050_armar_panel--->panel_analisis
panel_analisis--->e8051_resumir_panel_seguimiento
panel_analisis--->e8100_preparar_variables_analisis
e8100_preparar_variables_analisis--->e8501_VI_especificacionPrincipal
e8100_preparar_variables_analisis--->e8201_primera_etapa 

%% resumen para seguimiento
e8051_resumir_panel_seguimiento--->resumen_outputs_variables
e8051_resumir_panel_seguimiento--->resumen_outputs_resumen
e8051_resumir_panel_seguimiento--->resumen_outputs_cobertura_clave

%% regresiones de salida
e8201_primera_etapa--->resultados_regresiones
e8501_VI_especificacionPrincipal--->resultados_regresiones

end






```

# Estructura de los paneles de datos
| Columna | Descripción |
|----------|-------------|
| `codigo_dane_municipio` | Código DANE de 5 dígitos del municipio. |
| `anno` | Año de referencia de la observación. |
| `nombre_variable` | Nombre interno de la variable. |
| `variable_sujeto` | Sujeto o producto al que hace referencia la variable (ej. `cafe`). |
| `variable_medicion` | Tipo de medición (ej. `produccion_ton`, `area_sembrada_ha`). |
| `variable_detalle` | Desagregación adicional de la variable, cuando aplica. |
| `variable_descripcion` | Descripción legible de la variable. |
| `valor` | Valor numérico de la observación. |
| `clasificacion_econometria` | Clasificación de la variable según su uso en los modelos econométricos. |