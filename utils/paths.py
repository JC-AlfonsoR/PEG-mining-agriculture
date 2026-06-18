# paths.py
from pathlib import Path

# Define project paths
PROJECT_ROOT = Path("..").resolve()
DATA = PROJECT_ROOT / "data"
RAW = DATA / "raw"
INTERMEDIATE = DATA / "intermediate"
FINAL = DATA / "final"
ENGINES = PROJECT_ROOT / "engines"
OUTPUTS = PROJECT_ROOT / "outputs"