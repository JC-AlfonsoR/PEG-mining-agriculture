# define root path of project 
from pathlib import Path
import sys

ROOT = Path("..").resolve()
sys.path.append(str(ROOT))

# load general setup
from utils.setup_general import *

def run():
        
    # Función principal para procesar los datos EVA-UPRA
    print(MSC_SEPARADOR*10, "\n1001 Procesar UPRA-EVA", MSC_SEPARADOR*10)
    
    #######################################################
    #######################################################
    # Cargar datos UPRA 2019-2024
    UPRA = pd.read_excel(
        io= RAW/'aab_UPRA/20250617_BaseAgricola20192024.xlsx',
        sheet_name='BasePagina',
        skiprows=7,
        dtype={'Código Dane municipio':str, 'Año':int})
    print(MSC_SEPARADOR, "UPRA 2019-2024")
    print(UPRA.head(3))
    
    #######################################################
    #######################################################
    # Cargar datos UPRA 2007-2018
    UPRAantiguo = pd.read_excel(
        io= RAW/'aab_UPRA/Base Agrícola EVA 2007-2018_MADR.xlsx',
        sheet_name='FINAL',
        skiprows=1,
        dtype={'CÓD. MUN.':str, 'AÑO':int})
    print(MSC_SEPARADOR, "UPRA 2007-2018")
    print(UPRAantiguo.head(3))
    
    #######################################################
    #######################################################
    # Exportar clasificaciones 2007-2018 y 2019-2024 para armonizarlas
    # Revisar area sembrada registrada en todos los años del Upra antiguo y de UPRA nuevo
    # para crear el crosswalk y armonizar las taxonomías
    # Lo hago por registro de area sembrada para poder garantizar la trazabilidad de los
    # registros más importantes por area sembrada en Colombia
    
    UPRAantiguo_crosswalk = UPRAantiguo.groupby(
        ['CICLO DE CULTIVO', 'GRUPO \nDE CULTIVO', 'CULTIVO'])['Área Sembrada\n(ha)'].sum().reset_index()
    UPRAantiguo_crosswalk = UPRAantiguo_crosswalk.rename(columns={
            'CICLO DE CULTIVO': 'ciclo_original',
            'GRUPO \nDE CULTIVO': 'grupo_original',
            'CULTIVO': 'cultivo_original',
            'Área Sembrada\n(ha)': 'area_sembrada_ha'
        })
    UPRAantiguo_crosswalk['año'] = "2007-2018"
    UPRAantiguo_crosswalk['fuente_taxonomia'] = 'Eva antiguo'
    
    
    UPRA_crosswalk = UPRA.groupby(
        ['Ciclo del cultivo', 'Grupo cultivo', 'Cultivo'])['Área sembrada (ha)'].sum().reset_index()
    UPRA_crosswalk = UPRA_crosswalk.rename(columns={
            'Ciclo del cultivo': 'ciclo_original',
            'Grupo cultivo': 'grupo_original',
            'Cultivo': 'cultivo_original',
            'Área sembrada (ha)': 'area_sembrada_ha'
        })
    UPRA_crosswalk['año'] = "2019-2024"
    UPRA_crosswalk['fuente_taxonomia'] = 'Eva nuevo'
    
    
    # Definir plantilla para diligenciar manualmente
    plantilla = (
        pd.concat([UPRAantiguo_crosswalk, UPRA_crosswalk], ignore_index=True)
        .sort_values(['area_sembrada_ha'], ascending=False)
    )
    # Columnas para definir taxonomías armonizadas
    plantilla[['ciclo_armonizado',
               'grupo_armonizado',
               'cultivo_armonizado',
              'notas']] = ""
    
    # Exporto los datos para revisarlos manualmente y definir la armonización de las categorías
    plantilla.to_excel(DATA/ 'config/1001_1_plantilla_crosswalk.xlsx', index=False)
    
    #######################################################
    #######################################################
    # Armonizar Taxonomías
    # Cargar clasificación que fue armonizada a mano
    clasificacion_armonizada = pd.read_excel(DATA/"config/1001_2_crosswalk_armonizado.xlsx",
                                            sheet_name="Sheet1")
    print(MSC_SEPARADOR, "\nArchivo de clasificación armonizada")
    print(clasificacion_armonizada.head(2))
    
    # En la armonización de la taxonomía, se logró armonizar más del 98% de los datos de area sembrada
    # del EVA 2007-2018 y del EVA 2019-2024
    print(MSC_SEPARADOR, "\nPorcentaje de area sembrada que se logró armonizar")
    print(
        clasificacion_armonizada[['porcentaje acumulado armonizado  2018', 'porcentaje acumulado armonizado  2019']]
            .max().to_frame()*100)
    
    # Conservar únicamente los cultivos que fueron armonizados
    clasificacion_armonizada = clasificacion_armonizada[clasificacion_armonizada['Armonizado']==True]
    
    # Idea general:
    # En las columnas ['ciclo_original', grupo_original', 'cultivo_original'] están los nombres originales
    # en las bases de datos EVA. 
    # Los nombres armonizados quedaron en las columnas ['ciclo_armonizado',	'grupo_armonizado',	'cultivo_armonizado']
    clasificacion_armonizada_2007_2018 = clasificacion_armonizada[clasificacion_armonizada['año']=='2007-2018']
    clasificacion_armonizada_2019_2024  = clasificacion_armonizada[clasificacion_armonizada['año']=='2019-2024']
    
    # Preparar DF para el merge con la lsita armonziada
    UPRAantiguo = UPRAantiguo.rename(columns={'CULTIVO':'cultivo_original'})
    UPRA = UPRA.rename(columns={'Cultivo':'cultivo_original'})
    
    # en la lista armonizada, conservar solo las columnas necesarias
    clasificacion_armonizada_2007_2018 = clasificacion_armonizada_2007_2018[[
        'cultivo_original','ciclo_armonizado','grupo_armonizado','cultivo_armonizado']]
    clasificacion_armonizada_2019_2024 = clasificacion_armonizada_2019_2024[[
        'cultivo_original','ciclo_armonizado','grupo_armonizado','cultivo_armonizado']]
    
    
    #######################################################
    #######################################################
    # Revisar duplicados por el valor en "cultivo_original"
    # Cualquier duplicado debería tener los mismos valores en todas las filas
    print(MSC_SEPARADOR, "UPRA-2007-2018",
          "\nExplorar duplicados por cultivo_original en la lista armonizada. En los siguientes datos, las filas duplicadas deben ser idénticas en todas las columnas")
    print(clasificacion_armonizada_2007_2018[clasificacion_armonizada_2007_2018.
        duplicated(keep=False, subset='cultivo_original')].sort_values(by='cultivo_original')
           )
    # En la inspección de los duplicados no se encuentran problemas
    
    print(MSC_SEPARADOR, "UPRA-2019-2024",
          "\nExplorar duplicados por cultivo_original en la lista armonizada. En los siguientes datos, las filas duplicadas deben ser idénticas en todas las columnas",
          "\nEste arreglo debería estar vacío.")    
    print(clasificacion_armonizada_2019_2024[clasificacion_armonizada_2019_2024.
        duplicated(keep=False, subset='cultivo_original')].sort_values(by='cultivo_original')
           )
    # En la lista armonizada para 2019_2024 no hay repetidos

    #######################################################
    #######################################################
    # Eliminar duplicados
    clasificacion_armonizada_2007_2018 = clasificacion_armonizada_2007_2018.drop_duplicates(subset='cultivo_original')
    clasificacion_armonizada_2019_2024 = clasificacion_armonizada_2019_2024.drop_duplicates(subset='cultivo_original')
    
    #######################################################
    #######################################################
    # Revisar suma de valores de los indicadores antes y después del merge: 2007-2018
    print(MSC_SEPARADOR, "UPRA 2007-2018: Resumen de todos los valores ANTES de armonizar")
    antes = UPRAantiguo[['Área Sembrada\n(ha)',	'Área Cosechada\n(ha)',	'Producción\n(t)', 'Rendimiento\n(t/ha)']].aggregate(['sum', 'count'])
    print(antes)
    
    # Agregar columnas de datos armonizados
    UPRAantiguo_armonizado = UPRAantiguo.merge(
        clasificacion_armonizada_2007_2018,
        on='cultivo_original',
        how='right', # Mantener solo los cultivos que existen en la lista armonizada
        validate='m:1'
    )
    print(MSC_SEPARADOR, "UPRA 2007-2018: Resumen de todos los valores DESPUES de armonizar")
    despues = UPRAantiguo_armonizado[['Área Sembrada\n(ha)',	'Área Cosechada\n(ha)',	'Producción\n(t)', 'Rendimiento\n(t/ha)']].aggregate(['sum', 'count'])
    print(despues)
    
    print(MSC_SEPARADOR, "UPRA 2007-2018: Porcentaje de magnitudes que se conservan: despues / antes")
    print(100*despues/antes)
    
    #######################################################
    #######################################################
    # Revisar suma de valores de los indicadores antes y después del merge: 2019-2024
    print(MSC_SEPARADOR, "UPRA 2019-2024: Resumen de todos los valores ANTES de armonizar")
    antes = UPRA[['Área sembrada (ha)',	'Área cosechada (ha)',	'Producción (t)', 'Rendimiento (t/ha)']].aggregate(['sum', 'count'])
    print(antes)
    
    # Agregar columnas de datos armonizados
    UPRA_armonizado = UPRA.merge(
        clasificacion_armonizada_2019_2024,
        on='cultivo_original',
        how='right', # Mantener solo los cultivos que existen en la lista armonizada
        validate='m:1'
    )
    print(MSC_SEPARADOR, "UPRA 2019-2024: Resumen de todos los valores DESPUES de armonizar")
    despues = UPRA_armonizado[['Área sembrada (ha)',	'Área cosechada (ha)',	'Producción (t)', 'Rendimiento (t/ha)']].aggregate(['sum', 'count'])
    print(despues)
    
    print(MSC_SEPARADOR, "UPRA 2019-2024: Porcentaje de magnitudes que se conservan: despues / antes")
    print(100*despues/antes)
    
    #######################################################
    #######################################################
    # Unir los dataframes armonizados de 2007_2018 con 2019_2024

    # Definir nombres unificados para las columnas
    COL_area_sembrada = 'area_sembrada_ha'
    COL_area_cosechada = 'area_cosechada_ha'
    COL_produccion = 'produccion_t'
    COL_rendimiento = 'rendimiento_t_ha'
    
    # Unificar nombres de las columnas en UPRA 2019-2024
    UPRA_armonizado = UPRA_armonizado.rename(columns={
        'Código Dane municipio':COL_ID_MUNICIPIO,
        'Año': COL_ANNO,
        'Área sembrada (ha)': COL_area_sembrada,
        'Área cosechada (ha)': COL_area_cosechada,
        'Producción (t)': COL_produccion,
        'Rendimiento (t/ha)': COL_rendimiento
    })
    
    # Unificar nombres de las columnas en UPRA 2007-2018
    UPRAantiguo_armonizado = UPRAantiguo_armonizado.rename(columns={
        'CÓD. MUN.':COL_ID_MUNICIPIO,
        'AÑO': COL_ANNO,
        'Área Sembrada\n(ha)': COL_area_sembrada,
        'Área Cosechada\n(ha)': COL_area_cosechada,
        'Producción\n(t)': COL_produccion,
        'Rendimiento\n(t/ha)': COL_rendimiento
    })
    
    
    # Definir columnas a conservar
    columnas_df_final = [COL_ID_MUNICIPIO,
                        COL_ANNO,
                        COL_area_sembrada,
                        COL_area_cosechada,
                        COL_produccion,
                        COL_rendimiento,
                         'ciclo_armonizado',
                         'grupo_armonizado',
                         'cultivo_armonizado']
    
    # Unir DF
    UPRA_2007_2024 = pd.concat([
        UPRAantiguo_armonizado[columnas_df_final],
        UPRA_armonizado[columnas_df_final]
    ])
    
    # Asegurarse que el tipo de cada columna es el adecuado
    UPRA_2007_2024["codigo_dane_municipio"] = (
        UPRA_2007_2024["codigo_dane_municipio"]
        .astype(str)
        .str.zfill(5) # El código de municipio es un string de 5 caracteres
    )
    UPRA_2007_2024[COL_ANNO] = UPRA_2007_2024[COL_ANNO].astype(int) # el año es un int
    
    columnas_numericas = [COL_area_sembrada, COL_area_cosechada, COL_produccion, COL_rendimiento]
    UPRA_2007_2024[columnas_numericas] = UPRA_2007_2024[columnas_numericas].astype(float) # Las columnas numericas son floats
    
    columnas_taxonomia_cultivos = ['ciclo_armonizado', 'grupo_armonizado', 'cultivo_armonizado']
    UPRA_2007_2024[columnas_taxonomia_cultivos] = UPRA_2007_2024[columnas_taxonomia_cultivos].astype(str) # Las columnas de la taxonomía de los cultivos son strings
    
    # Revisar la información del DF
    print(MSC_SEPARADOR, " Tipo de datos en cada columna")
    print(UPRA_2007_2024.info())
    print(MSC_SEPARADOR, " Estadísticas descriptivas de las columnas")
    print(UPRA_2007_2024.describe())
    
    
    #######################################################
    #######################################################
    # Explorar para cuales cultivos existen series largas
    # Extraer lista de cultivos disponibles
    cultivos_disponibles = sorted(UPRA_2007_2024['cultivo_armonizado'].unique())
    
    # Mostrar número de observaciones municipio-año disponibles de cada cultivo
    conteo_registros = (
        UPRA_2007_2024.groupby(['cultivo_armonizado'])[columnas_numericas].count()
            .reset_index()
            .sort_values(by='area_sembrada_ha', ascending=False)
            .reset_index(drop=True)
    )
    
    suma_registros = (
        UPRA_2007_2024.groupby(['cultivo_armonizado'])[columnas_numericas].sum()
            .reset_index()
            .sort_values(by='area_sembrada_ha', ascending=False)
            .reset_index(drop=True)
    )
    
    # Mostrar resumen de registros
    print(MSC_SEPARADOR, "Conteo de registros municipio-año por cultivo (20 primeros)")
    print(conteo_registros.head(20))
    suma_conteo_20primeros = conteo_registros.head(20)[columnas_numericas].sum().to_frame().transpose()
    suma_conteo_todos = conteo_registros[columnas_numericas].sum().to_frame().transpose()
    print("Los 20 primeros representan este porcentaje del total de registros")
    print(suma_conteo_20primeros/suma_conteo_todos)
    
    print(MSC_SEPARADOR, "Suma de magnitudes por cultivo (20 primeros)")
    print(suma_registros.head(20))
    suma_suma_20primeros = suma_registros.head(20)[columnas_numericas].sum().to_frame().transpose()
    suma_suma_todos = suma_registros[columnas_numericas].sum().to_frame().transpose()
    print("Los 20 primeros representan este porcentaje del total de registros")
    print(suma_suma_20primeros/suma_suma_todos)
    # Para rendimiento, el resultado de esta suma no tiene sentido económico. Solo se incluyó por el procesamiento de datos
    
    
    #######################################################
    #######################################################
    # Definir la lista de cultivos principales
    
    # Calculo las variables de interés para los 20 cultivos con más registros (por conteo y por suma)
    lista_de_cultivos_conteo = (
        conteo_registros
            .sort_values(by='area_sembrada_ha', ascending=False)
            .reset_index(drop=True)
            .loc[:20,'cultivo_armonizado']
            .to_list()
        )
    
    lista_de_cultivos_suma = (
        suma_registros
            .sort_values(by='area_sembrada_ha', ascending=False)
            .reset_index(drop=True)
            .loc[:20,'cultivo_armonizado']
            .to_list()
        )
    
    print(MSC_SEPARADOR, "20 cultivos con más observaciones de area sembrada:\n", lista_de_cultivos_conteo)
    print(MSC_SEPARADOR, "20 cultivos con mayor magnitud de area sembrada:\n", lista_de_cultivos_suma)
    
    # Encontrar la lista de los cultivos principales entre los de más registros y los de mayor area sembrada
    lista_de_cultivos_principales = list(
        dict.fromkeys(lista_de_cultivos_suma + lista_de_cultivos_conteo)
    )
    
    print(MSC_SEPARADOR, f"Cultivos principales por número de registros y area sembrada. N = {len(lista_de_cultivos_principales)}\n",
          lista_de_cultivos_principales)
    
    #######################################################
    #######################################################
    # Extraer información de los cultivos de interés
    # Lista con el nombre de los cultivos de interés
    cultivos_disponibles = lista_de_cultivos_principales.copy()
    
    # Lista de las variables de interés
    vbles_resultado = [COL_area_sembrada, COL_area_cosechada, COL_produccion] # NO incluyo rendimiento porque no se puede agregar igual que las otras columnas
    
    # DataFrame vacio para almacenar resultados
    panel_cultivos = pd.DataFrame()
    
    for cultivo_interes in tqdm(cultivos_disponibles):
        print(MSC_SEPARADOR, " Procesando: ", cultivo_interes)
        
        # Extraer datos del cultivo de interés ---------------------------------------------------------------------
        filas_cultivo_interes = UPRA_2007_2024['cultivo_armonizado']==cultivo_interes
        UPRA_cultivo_interes = UPRA_2007_2024.loc[filas_cultivo_interes]
    
        # Dar estructura al DF
        UPRA_cultivo_interes = UPRA_cultivo_interes.melt(
            id_vars=[COL_ID_MUNICIPIO, COL_ANNO, 'cultivo_armonizado'],
            value_vars=vbles_resultado,
            var_name=COL_VARIABLE_MEDICION,
            value_name=COL_VALOR
        )
    
        # organizar información del Panel
        UPRA_cultivo_interes[COL_CLASIFICACION_ECONOMETRIA] = 'Resultado' # Identificar el tipo de variable en el planteamiento econometrico
        UPRA_cultivo_interes = UPRA_cultivo_interes.rename(columns={'cultivo_armonizado':COL_VARIABLE_SUJETO})
        UPRA_cultivo_interes[COL_VARIABLE_DETALLE] = ''
        UPRA_cultivo_interes[COL_NOMBRE_DE_VARIABLE] = ''
        UPRA_cultivo_interes[COL_VARIABLE_DESCRIPCION] = (UPRA_cultivo_interes[COL_VARIABLE_SUJETO] + ': ' +
                                                         UPRA_cultivo_interes[COL_VARIABLE_MEDICION] + ' de todos los tipos de ' + 
                                                         UPRA_cultivo_interes[COL_VARIABLE_SUJETO])
    
        # Extraer datos de los cultivos diferentes al cultivo de interés ------------------------------------------
        # Calcular la suma del Area sembrada, Area cosechada y Producción para los demás cultivos dentro del municipio-año
    
        # Organizar información de los demás cultivos por grupo_de_cultivo i.e 'grupo_armonizado' ---------------------------------
        UPRA_diferente_a_cultivo_interes_porgrupocultivo = UPRA_2007_2024.loc[~filas_cultivo_interes].groupby(
            [COL_ID_MUNICIPIO, COL_ANNO, 'grupo_armonizado', ])[vbles_resultado].sum()
        UPRA_diferente_a_cultivo_interes_porgrupocultivo = UPRA_diferente_a_cultivo_interes_porgrupocultivo.reset_index() 
        UPRA_diferente_a_cultivo_interes_porgrupocultivo[COL_CLASIFICACION_ECONOMETRIA] = 'Control' # Identificar el tipo de variable en el planteamiento econometrico
    
        # Dar estructura al DF
        UPRA_diferente_a_cultivo_interes_porgrupocultivo = UPRA_diferente_a_cultivo_interes_porgrupocultivo.melt(
            id_vars=[COL_ID_MUNICIPIO, COL_ANNO, 'grupo_armonizado'],
            value_vars=vbles_resultado,
            var_name=COL_VARIABLE_MEDICION,
            value_name=COL_VALOR
        )
    
        # organizar información del Panel
        UPRA_diferente_a_cultivo_interes_porgrupocultivo[COL_VARIABLE_SUJETO] = cultivo_interes
        UPRA_diferente_a_cultivo_interes_porgrupocultivo[COL_CLASIFICACION_ECONOMETRIA] = 'Control'
        UPRA_diferente_a_cultivo_interes_porgrupocultivo[COL_VARIABLE_DETALLE] = 'Grupo cultivo:' + UPRA_diferente_a_cultivo_interes_porgrupocultivo['grupo_armonizado']
        UPRA_diferente_a_cultivo_interes_porgrupocultivo[COL_NOMBRE_DE_VARIABLE] = ''
        UPRA_diferente_a_cultivo_interes_porgrupocultivo[COL_VARIABLE_DESCRIPCION] = (UPRA_diferente_a_cultivo_interes_porgrupocultivo[COL_VARIABLE_SUJETO] + ': ' +
                                                                        UPRA_diferente_a_cultivo_interes_porgrupocultivo[COL_VARIABLE_MEDICION] + ' de los demás cultivos - grupo de cultivos ' +
                                                                        UPRA_diferente_a_cultivo_interes_porgrupocultivo['grupo_armonizado'])
    
    
        # Extraer datos de los cultivos diferentes al cultivo de interés ------------------------------------------
        # Calcular la suma del Area sembrada, Area cosechada y Producción para los demás cultivos dentro del municipio-año
    
        # Organizar información de los demás cultivos por grupo_de_cultivo i.e 'ciclo_armonizado' ---------------------------------
        UPRA_diferente_a_cultivo_interes_porciclocultivo = UPRA_2007_2024.loc[~filas_cultivo_interes].groupby(
            [COL_ID_MUNICIPIO, COL_ANNO, 'ciclo_armonizado', ])[vbles_resultado].sum()
        UPRA_diferente_a_cultivo_interes_porciclocultivo = UPRA_diferente_a_cultivo_interes_porciclocultivo.reset_index()
        UPRA_diferente_a_cultivo_interes_porciclocultivo[COL_CLASIFICACION_ECONOMETRIA] = 'Control' # Identificar el tipo de variable en el planteamiento econometrico
    
        # Dar estructura al DF
        UPRA_diferente_a_cultivo_interes_porciclocultivo = UPRA_diferente_a_cultivo_interes_porciclocultivo.melt(
            id_vars=[COL_ID_MUNICIPIO, COL_ANNO, 'ciclo_armonizado'],
            value_vars=vbles_resultado,
            var_name=COL_VARIABLE_MEDICION,
            value_name=COL_VALOR
        )
    
        # organizar información del Panel
        UPRA_diferente_a_cultivo_interes_porciclocultivo[COL_VARIABLE_SUJETO] = cultivo_interes
        UPRA_diferente_a_cultivo_interes_porciclocultivo[COL_CLASIFICACION_ECONOMETRIA] = 'Control'
        UPRA_diferente_a_cultivo_interes_porciclocultivo[COL_VARIABLE_DETALLE] = 'Ciclo cultivo:' + UPRA_diferente_a_cultivo_interes_porciclocultivo['ciclo_armonizado']
        UPRA_diferente_a_cultivo_interes_porciclocultivo[COL_NOMBRE_DE_VARIABLE] = ''
        UPRA_diferente_a_cultivo_interes_porciclocultivo[COL_VARIABLE_DESCRIPCION] = (UPRA_diferente_a_cultivo_interes_porciclocultivo[COL_VARIABLE_SUJETO] + ': ' +
                                                                        UPRA_diferente_a_cultivo_interes_porciclocultivo[COL_VARIABLE_MEDICION] + ' de los demás cultivos - cultivos de ciclo ' +
                                                                        UPRA_diferente_a_cultivo_interes_porciclocultivo['ciclo_armonizado'])
    
        # Unir bases de datos
        panel_cultivos = pd.concat([
            panel_cultivos,
            UPRA_cultivo_interes[ORDEN_DF],
            UPRA_diferente_a_cultivo_interes_porgrupocultivo[ORDEN_DF],
            UPRA_diferente_a_cultivo_interes_porciclocultivo[ORDEN_DF]
        ])
        
    
    
    
    #######################################################
    #######################################################
    # Mostrar estructura del panel
    print(MSC_SEPARADOR, "Estructura del panel final")
    print(panel_cultivos)
    
    #######################################################
    #######################################################
    # Mostrar mediciones disponibles
    print(MSC_SEPARADOR, 'Mostrar mediciones disponibles')
    print(panel_cultivos['variable_descripcion'].unique())
    
    
    #######################################################
    #######################################################
    # Exportar datos intermedios


    #######################################################
    ### Exportar datos de diagnóstico
    # Crear resumenes de datos para exportar
    resumen_por_cultivo = panel_cultivos.groupby([COL_VARIABLE_SUJETO, COL_VARIABLE_MEDICION])[COL_VALOR].agg(['count', 'sum']).unstack()
    resumen_por_anno = panel_cultivos.groupby([COL_ANNO, COL_VARIABLE_MEDICION])[COL_VALOR].agg(['count', 'sum']).unstack()

    # Guardar diagnosticos
    save_diagnostic(df=panel_cultivos,
                    df_name = "panel_cultivos",
                    filepath=DIAGNOSTICS / f"e1001_process_UPRA_panel_cultivos.md",
                    additional_summary=[resumen_por_cultivo, resumen_por_anno]
                   )

    print(MSC_SEPARADOR, "Resumen por cultivo")
    print(resumen_por_cultivo)

    print(MSC_SEPARADOR, "Resumen por anno")
    print(resumen_por_anno)


    #######################################################
    ### Exportar Panel
    panel_cultivos.to_parquet(DATA/'intermediate/1001_panel_cultivos_UPRA.parquet')