# utils/setup.py

# Configurar archivos auxiliares de GDAL (Conda en Windows)
import os
import sys
from pathlib import Path

ruta_gdal = Path(sys.prefix) / "Library" / "share" / "gdal"

if not (ruta_gdal / "header.dxf").is_file():
    raise FileNotFoundError(
        f"No se encontraron los archivos de GDAL en: {ruta_gdal}"
    )

os.environ["GDAL_DATA"] = str(ruta_gdal)

# imports

# Manejar datos espaciales
import geopandas as gpd
from shapely.validation import make_valid

# Convertir Json a geopandas
#pip install arcgis2geojson geopandas shapely
from arcgis2geojson import arcgis2geojson

# herramientas adicionales que uso en mapas
import matplotlib as mpl
from matplotlib.patches import Patch

# Trabajar con rasters
import rasterio
# conda install anaconda::rasterio
# from rasterstats import zonal_stats
# pip install exactextract
from exactextract import exact_extract


print("Setup GIS cargado")