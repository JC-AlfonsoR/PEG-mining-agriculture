
## Exploración: potencial aurífero, minería legal e ilegal

**Fecha:** 13 de agosto de 2026  
**Estado:** resultados exploratorios de primera etapa

### Pregunta
¿El potencial aurífero de roca predice principalmente la minería legal,
mientras que el potencial de aluvión predice principalmente la minería ilegal?

### Hipótesis
```mermaid
flowchart LR

%%% Nodos
mineria_legal[Minería Legal
Produccion asociadas a regalías]
mineria_ilegal[SR2021
Proporicón del area minada ilegalmente]
instrumento_roca[Proximidad a roca con potencial]
instrumento_aluvion[Proximidad a aluvión]

%%% Relaciones
instrumento_roca--->|Esperada: positiva y fuerte| mineria_legal
instrumento_roca-.->|Esperada: débil| mineria_ilegal
instrumento_aluvion-.->|Esperada: débil| mineria_legal
instrumento_aluvion--->|Esperada: positiva y fuerte|mineria_ilegal
```

### Resultados preliminares
#### Primera etapa: potencial aurífero × precio del oro

##### Panel A. Panel agrupado sin efectos fijos

|  | Minería legal | Minería legal | Minería ilegal | Minería ilegal |
|---|---:|---:|---:|---:|
| **Instrumento** | **Roca × precio** | **Aluvión × precio** | **Roca × precio** | **Aluvión × precio** |
| Coeficiente | 0,000196*** | 0,000481*** | 0,026444*** | 0,023471*** |
| Error estándar | (0,000071) | (0,000063) | (0,000777) | (0,001140) |
| Estadístico t | 2,77 | 7,67 | 34,04 | 20,59 |
| Valor p | 0,006 | <0,001 | <0,001 | <0,001 |
| Estadístico F | 7,68 | 58,87 | 1.158,44 | 423,78 |
| Observaciones | 2.066 | 2.066 | 12.012 | 12.012 |

##### Panel B. Panel con efectos fijos de municipio y año

|  | Minería legal | Minería legal | Minería ilegal | Minería ilegal |
|---|---:|---:|---:|---:|
| **Instrumento** | **Roca × precio** | **Aluvión × precio** | **Roca × precio** | **Aluvión × precio** |
| Coeficiente | 0,000202 | −0,000171 | 0,012061*** | 0,007901*** |
| Error estándar agrupado | (0,000281) | (0,000189) | (0,001774) | (0,002529) |
| Estadístico t | 0,72 | −0,90 | 6,80 | 3,12 |
| Valor p | 0,474 | 0,368 | <0,001 | 0,002 |
| Estadístico F | 0,52 | 0,81 | 46,23 | 9,76 |
| Observaciones | 2.014 | 2.014 | 12.012 | 12.012 |


> En el Panel A se reportan errores estándar convencionales. En el Panel B,
> los errores estándar se encuentran agrupados por municipio. Las regresiones
> del Panel B absorben efectos fijos de municipio y año.

### Análisis
Las regresiones de panel agrupado y sección transversal año-año (que no se muestran) muestran asociaciones positivas y estadísticamente significativas entre los dos candidatos a instrumento y ambas medidas de minería.

Sin embargo, al incorporar efectos fijos de municipio y año, las relaciones minería legal - roca y minería legal-aluvión se diluyen. Solo las dos relaciones de minería ilegal se mantienen.

Las bases de datos de minería legal (producción asociada a reglías) tiene entre 80-150 observaciones por año en 2012 y 2026; mientras que la base de datos de mienría ilegal (proporción del area minera minada ilegalmente) tiene 1092 observaciones por año entre 2004-2014
