# utils/setup.py

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

print("Setup GIS cargado")