# Definir nombres de las columnas en el DF que agrupa toda la información

COL_ID_MUNICIPIO = "codigo_dane_municipio"
COL_AÑO = "anno"
COL_NOMBRE_DE_VARIABLE = "nombre_variable" # nombre corto de la variable para que se convierta en nombre de la columna cuando el DF se pase a formato long
COL_VARIABLE_SUJETO = "variable_sujeto" # Sujeto del que trata la variable. Por ejemplo mineral (oro, carbón...), cultivo (aguacate, café...)
COL_VARIABLE_MEDICION = "variable_medicion"  # Por ejemplo area sembrada en HA, producción en Ton...
COL_VARIABLE_DETALLE = "variable_detalle" # Detalle adicional a la desagregación. Por ejemplo
COL_VARIABLE_DESCRIPCION = "variable_descripcion" # Texto que describe la variable
COL_VALOR = "valor"
COL_CLASIFICACION_ECONOMETRIA = "clasificacion_econometria" # Resultado, Control, Instrumento

# Definir orden para mostrar el DF
ORDEN_DF = [COL_ID_MUNICIPIO,
COL_AÑO,
COL_NOMBRE_DE_VARIABLE,
COL_VARIABLE_SUJETO,
COL_VARIABLE_MEDICION,
COL_VARIABLE_DETALLE,
COL_VARIABLE_DESCRIPCION,
COL_VALOR,
COL_CLASIFICACION_ECONOMETRIA]