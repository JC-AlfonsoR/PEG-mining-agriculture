# define root path of project 
from pathlib import Path
import sys

ROOT = Path("..").resolve()
sys.path.append(str(ROOT))

# load general setup
from utils.setup_general import *

# load GIS setup
from utils.setup_gis_python import *

# Hacer queries a servidores
import requests 


"""
# Problema general
- La ANM publica la base de datos de títulos mineros identificando el municipio correspondiente y el mineral que se explota https://www.datos.gov.co/Minas-y-Energ-a/ANM-RUCOM-Explotador-Minero-Autorizado-T-tulo-Mine/42ha-fhvj/about_data
- El problema es que no publica directamente el área de cada título minero ni los polígonos
- Sin embargo, si se conoce el número del expediente del título minero, los polígonos se pueden descargar del visor de la ANM https://annamineria.anm.gov.co/Html5Viewer/index.html?viewer=SIGMExt&locale=es-CO&appAcronym=sigm
- El video de esta página es una guía de la ANM de cómo hacerlo https://www.anm.gov.co/ventanilla-minera
- El problema es que descargarlos manualmente es demasiado extenso y suceptible a errores porque es un alto número de polígonos. Sólo para el oro son alrededor de 270 polígonos.
- Encontré una forma de importar los políginos con un punto de acceso al servidor de arcgis. 
- La idea es replicar queries como este que devulven una respuesta en json https://annamineria.anm.gov.co/annageo/rest/services/SIGM/TenureLayers/MapServer/4/query?f=json&where=LOWER(CODIGO_EXPEDIENTE)%20LIKE%20%27%25abq-101%25%27&returnGeometry=true&spatialRel=esriSpatialRelIntersects&outFields=*&outSR=102100https://annamineria.anm.gov.co/annageo/rest/services/SIGM/TenureLayers/MapServer/4/query?f=json&where=LOWER(CODIGO_EXPEDIENTE)%20LIKE%20%27%25abq-101%25%27&returnGeometry=true&spatialRel=esriSpatialRelIntersects&outFields=*&outSR=102100
- Esa respuesta después se puede convertir en un geodataframe
- En este cuaderno hago el query respectivo para cada titulo minero de oro en la base de títulos mineros de la ANM
"""

def run():

    # Función principal para procesar los datos EVA-UPRA
    print(MSC_SEPARADOR*10, "\n1001 Descargar poligonos de titulos mineros", MSC_SEPARADOR*10)

    #######################################################
    #######################################################
    # Cargar lista de todos los titulos mineros
    # Cargar información de títutlos mineros
    titulos_mineros = pd.read_excel(
        io = DATA/'raw/aac_ANM_titulos_mineros/ANM_RUCOM_Explotador_Minero_Autorizado-Título_Minero_20260702.xlsx'
    )

    # Extraer únicamente titulos mineros de minerales de oro
    titulos_mineros_oro = titulos_mineros[titulos_mineros['MINERAL'].str.contains('ORO')]

    # Extraer identificadores de los expedientes de titulos mineros
    expedientes_titulosMineros = list(titulos_mineros['CODIGO_EXPEDIENTE'].unique())

    # Extraer identificadores de los expedientes de titulos oro
    expedientes_oro = list(titulos_mineros_oro['CODIGO_EXPEDIENTE'].unique())

    # Mostrar conteo de títulos mineros totales y de oro
    print(f'Expendientes Totales: {len(expedientes_titulosMineros)}')
    print(f'Expendientes de Oro: {len(expedientes_oro)}')


    #######################################################
    #######################################################
    # Obtener poligonos de todos los expedientes
    # ruta de acceso
    url = "https://annamineria.anm.gov.co/annageo/rest/services/SIGM/TenureLayers/MapServer/4/query"

    # Lista para almacenar poligonos
    gdfs = []

    # El servidor puede romper la conexion despues de algun tiempo. 
    # Por eso es posible que se necesite correr el codigo por partes.
    # Como los datos ya estan descargados, en este script solo queda 
    # como ejemplo y por eso se limita la descarga de datos a 10 expedientes
    # El archivo producto de este script se exporta como ejemplo.

    # Para cada expediente
    for exp in tqdm(expedientes_titulosMineros[:10]):
        
        # Definir parametros de query
        params = {
            "f": "json",
            "where": f"CODIGO_EXPEDIENTE = '{exp}'",
            "returnGeometry": "true",
            "outFields": "*",
            "outSR": "102100" # En la versión del query original sale con 102100, pero esa no es una forma estandar de especficarlo
        }
        
        # Obtener respuesta
        response = requests.get(url, params=params, timeout=30)
        response.raise_for_status()
        data = response.json()
        
        if data.get("features"): # Si la respuesta existe
            geojson_dict = arcgis2geojson(data)
            gdf_temp = gpd.GeoDataFrame.from_features(geojson_dict["features"])
            gdf_temp = gdf_temp.set_crs(epsg=102100, allow_override=True)
            gdfs.append(gdf_temp)

    #######################################################
    #######################################################
    # Organizar resultados
    gdf_final = gpd.GeoDataFrame(pd.concat(gdfs, ignore_index=True), crs="EPSG:102100")

    # mostrar informacion de los gdfs
    print(gdf_final.info())

    #######################################################
    #######################################################
    # Exportar resultado
    gdf_final.to_parquet(DATA/"intermediate/2001_poligonos_titulosmineros.parquet")
    gdf_final.to_excel(DATA/"intermediate/2001_poligonos_titulosmineros_ejemploN10.xlsx")
