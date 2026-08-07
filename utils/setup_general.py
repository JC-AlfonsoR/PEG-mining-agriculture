# utils/setup.py

# imports

# pandas
import pandas as pd
pd.set_option('display.float_format', lambda x: '{:,.2f}'.format(x)) # Configuración para mostrar separador de miles
pd.set_option("display.max_columns", None)
pd.set_option("display.width", 150)

# numpy
import numpy as np

# Graficos
import matplotlib.pyplot as plt
import seaborn as sns

# herramientas del sistema
import sys

import warnings
#warnings.filterwarnings("ignore")

# revisar avance de ciclos
from tqdm import tqdm

# Manejar fechas y medir tiempo
import datetime # Manejar fechas
import time # Medir tiempos de ejecución


# Paths
from utils.paths import *

# Nombres de las columnas
from utils.nombres_columnas_df import *

# Funcion para guardar diagnosticos
from utils.save_diagnostic import*

# Miscelaneos
from utils.miscellaneous import *

# Abreviaciones definidas para generar nombres de variables en STATA
from utils.diccionarios_abreviaciones import *

# helper print
print("Setup general cargado")