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

# herramientas del sistema
import sys

import warnings
warnings.filterwarnings("ignore")

# revisar avance de ciclos
from tqdm import tqdm

# Paths
from utils.paths import *

# Nombres de las columnas
from utils.nombres_columnas_df import *

# Miscelaneos
from utils.miscellaneous import *

# helper print
print("Environment loaded")