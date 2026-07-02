# Funcion para exportar diagnosticos de los paneles
#
def save_diagnostic(
    df, # Data Frame del que voy a guardar información de diagnostico
    df_name, # Nombre del DF
    filepath, # Ruta del archivo de diagnostico
    additional_summary=None # Lista o DF de resumen a guardar
):

    with open(filepath, "w", encoding="utf8") as f:

        f.write("# DataFrame Name\n\n")
        f.write(df_name)
        f.write("\n\n")

        f.write("# DataFrame Info\n\n")
        df.info(buf=f)
        f.write("\n\n")

        f.write("# Describe\n\n")
        f.write(df.describe().to_markdown())
        f.write("\n\n")

        f.write("\n\n# Missing Values\n\n")
        f.write(df.isna().sum().to_markdown())

        f.write("\n\n# Unique Values\n\n")
        f.write(df.nunique().to_markdown())

        if additional_summary is not None:
            i = 0
            if type(additional_summary)==list: # Si paso una lista con varios resumenes para guardar
                for s in additional_summary:
                    f.write("\n\n# Group Summary " + str(i) +"\n\n")
                    f.write(s.to_markdown())
                    i = i+1
            else:
                f.write("\n\n# Group Summary\n\n")
                f.write(additional_summary.to_markdown())