# utils/setup.py

# imports

# pandas
import pandas as pd
pd.set_option('display.float_format', lambda x: '{:,.2f}'.format(x)) # Configuración para mostrar separador de miles


import numpy as np
import matplotlib.pyplot as plt


import sys
import warnings

warnings.filterwarnings("ignore")

pd.set_option("display.max_columns", None)
pd.set_option("display.width", 150)

# Paths
from utils.paths import *

# helper print
print("Environment loaded")