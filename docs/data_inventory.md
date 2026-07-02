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
- **Processing script:** /engines/e1001_processs_UPRA.py
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
- **Processing script:** /engines/e1001_processs_UPRA.py
- **Notes:**
	- Datos de Area Sembrada, Cosechada y producción de cultivos de interés.
	- Existe una base de datos para 2007-2018 y otra para 2019-2024. Las dos bases de datos no tienen las mismas columnas ni la misma taxonomía, por eso tuve que armonizarlas en /engines/e1001_processs_UPRA.py.

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