# miscellaneous.py

# Variables que uso frecuentemente y prefiero definir solo una vez
MSC_SEPARADOR = "\n" + "-"*32 # Nueva línea y guiones para separar visualmente los mensajes que imprimo

def MSC_normalizar_texto(texto):
    
    import unicodedata # aplanar caracteres especiales
    import re # Expresiones regulares
    import pandas as pd
    
    if pd.isna(texto):
        return ""

    # convertir todo a minusculas
    texto = str(texto).lower()

    # Eliminar tildes
    texto = unicodedata.normalize("NFKD", texto)
    texto = texto.encode("ascii", "ignore").decode("utf-8")

    # Eliminar signos de puntuación
    texto = re.sub(r"[^\w\s]", " ", texto)

    # Eliminar espacios múltiples
    texto = re.sub(r"\s+", " ", texto).strip()

    return texto