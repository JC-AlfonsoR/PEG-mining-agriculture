# Data Inventory – PEG Mining Agriculture Thesis

This document tracks all datasets used in the project.

---
## aaa Panel Cede
- **Type:** Raw
- **Folder:** /data/raw/aaa_panel_cede
- **Source institution:** Universidad de los Andes
- **Original source / URL:** https://datoscede.uniandes.edu.co/catalogo-de-datos/
- **Date obtained:** 13-mar-2026
- **Unit of observation** Municipio
- **Processing script:** [engines/e1001_processs_UPRA.py](../engines/e1001_processs_UPRA.py)
- **Notes:**
	- Entre diferentes variables a nivel municipal, el Panel CEDE incluye datos de Area Sembrada, Cosechada y producción de cultivos de interés.

## aab UPRA
- **Type:** Raw
- **Folder:** /data/raw/aab_UPRA
- **Source institution:** Unidad de Planeación Rural Agropecuaria UPRA - Evaluaciones Agropecuarias Municipales EVA
- **Original source / URL (2009-2024):** https://upra.gov.co/es-co/eva/eva-2024
- **Original source / URL (2007-2018):** https://agronet.gov.co/documentacion-estadisticas/agricola/reporte-evaluaciones-agropecuarias-eva-y-anuario-estadistico
- **Date obtained:** 24-abr-2026
- **Unit of observation** Municipio
- **Processing script:** [engines/e1001_processs_UPRA.py](../engines/e1001_processs_UPRA.py)
- **Notes:**
	- Datos de Area Sembrada, Cosechada y producción de cultivos de interés.
	- Existe una base de datos para 2007-2018 y otra para 2019-2024. Las dos bases de datos no tienen las mismas columnas ni la misma taxonomía, por eso tuve que armonizarlas en [engines/e1001_processs_UPRA.py](../engines/e1001_processs_UPRA.py).
 	- Con esta base de datos genero [Panel 1001 cultivos UPRA](#panel-1001-cultivos-upra)

## aac ANM Títulos Mineros
- **Type:** Raw
- **Folder:** /data/raw/aac_ANM_titulos_mineros
- **Source institution:** Agencia Nacional de Minería (ANM)
- **Original source / URL:** https://www.datos.gov.co/Minas-y-Energ-a/ANM-RUCOM-Explotador-Minero-Autorizado-T-tulo-Mine/42ha-fhvj/about_data
- **Date obtained:** 02-jul-2026
- **Unit of observation** Municipio
- **Processing script:** /engines/e2001_descargar_poligonostitulosmineros.py
- **Notes:**
	- En la sección de datos abiertos de la ANM se publica esta lista del histórico de los títulos mineros otorgados en Colombia
	- Uso esta información para descargar todos los títulos mineros de la ANM como se detalla en [engines/e2001_descargar_poligonostitulosmineros.ipynb](../engines/e2001_descargar_poligonostitulosmineros.ipynb) (El script de python [engines/e2001_descargar_poligonostitulosmineros.py](../engines/e2001_descargar_poligonostitulosmineros.py) contiene la versión mínima pra ejcutarlo)
	- Los datos descargados de la ANM quedan en [2001_poligonos_titulosmineros.parquet](#datos-2001-poligonos-titulos-mineros)


## aba SGC Zonas Potenciales Minerales
- **Type:** Raw
- **Folder:** /data/raw/aba_SGC_zonas_potenciales_minerales
- **Source institution:** Servicio Geológico COlombiano
- **Original source / URL:** https://datos.sgc.gov.co/search?tags=Recursos%2520Minerales
- **Date obtained:** 09-jul-2026
- **Unit of observation** Zona de potencial mineral
- **Processing script:** /engines/e2011_armonizar taxonomias_minerales.py
- **Notes:**
	- En la sección de datos abiertos sobre minerales del Servicio GEológico Colombiano existen diferentes polígonos de estructuras geológicas.
	- En este caso descargué los poligonos para todos los grupos minerales que definió el Servicio geológico Colombiano. En total son 7 grupos.
	- Fue necesario hacer una armonización de las clasificaciones de los difenretes grupos minerales en las siguientes bases de datos:
		- [abb Distritos Aluviales](#abb-sgc-distritos-aluviales)
		- [aba SGC Zonas Potenciales Minerales](#aba-sgc-zonas-potenciales-minerales)
		- aca Produccion legal asociada a regalías
		- ada Mineria ilegal
	
## abb SGC Distritos Aluviales
- **Type:** Raw
- **Folder:** /data/raw/abb_abb_SGC_distritos_aluviales
- **Source institution:** Servicio Geológico COlombiano
- **Original source / URL:** https://datos.sgc.gov.co/search?tags=Recursos%2520Minerales
- **Date obtained:** 09-jul-2026
- **Unit of observation** Zona de potencial mineral
- **Processing script:** /engines/e2011_armonizar taxonomias_minerales.py
- **Notes:**
	- En la sección de datos abiertos sobre minerales del Servicio GEológico Colombiano existen diferentes polígonos de estructuras geológicas.
	- En este caso descargué los poligonos de los distritos aluviales. Es importante distinguir entre minería de veta y minería de aluvión porque la actividad en aluvión tiende a ser más informal y a contaminar más.
	- Fue necesario hacer una armonización de las clasificaciones de los difenretes grupos minerales en las siguientes bases de datos:
		- abb Distritos Aluviales
		- aba SGC Zonas Potenciales Minerales
		- aca Produccion legal oro
		- ada Mineria ilegal oro


## Panel 1001 cultivos UPRA
- **Type:** Intermediate
- **Folder:** /data/intermediate/1001_cultivos_UPRA.parquet
- **Source institution:** Unidad de Planeación Rural Agropecuaria UPRA - Evaluaciones Agropecuarias Municipales EVA
- **Unit of observation** Municipio-año
- **Processing script:** [engines/e1001_processs_UPRA.py](../engines/e1001_processs_UPRA.py)
- **Notes:**
	- Son los datos UPRA-EVA 2007-2024 armonizados en la estructura de datos definida para este proyecto
 	- Se crea a partir de los datos [aab UPRA](#aab-upra)


## Datos 2001 Poligonos titulos mineros
- **Type:** Intermediate
- **Folder:** /data/intermediate/2001_poligonos_titulosmineros.parquet
- **Source institution:** Agencia Nacional de Minería (ANM)
- **Unit of observation** Titulo minero
- **Processing script:** [engines/e2001_descargar_poligonostitulosmineros.py](../engines/e2001_descargar_poligonostitulosmineros.py)
- **Notes:**
	- Los poligonos de los titulos mineros se descargan de la ANM como se detalla en [engines/e2001_descargar_poligonostitulosmineros.ipynb](../engines/e2001_descargar_poligonostitulosmineros.ipynb) (El script de python [engines/e2001_descargar_poligonostitulosmineros.py](../engines/e2001_descargar_poligonostitulosmineros.py) contiene la versión mínima pra ejcutarlo)