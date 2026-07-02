# define root path of project 
from pathlib import Path
import sys

ROOT = Path("..").resolve()
sys.path.append(str(ROOT))

# load general setup
from utils.setup_general import *


# Load functions
from engines.e1001_processs_UPRA import run as run_1001_processs_UPRA

# Run functions
run_1001_processs_UPRA()