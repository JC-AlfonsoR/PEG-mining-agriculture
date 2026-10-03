*******************************************************
** e8100_preparar_variables_analisis.do
**
** Objetivo:
** Cargar el panel y preparar construir las transformaciones
** compartidas en todas las rutinas
*******************************************************

*******************************************************
**# Cargar panel final y preparar variables del analisis
*******************************************************
* Ejecutar desde e8000_master.do despues de e8001, e8050 y e8051.
* Las rutas se definen en e8001. Esta rutina no reconstruye el panel.
if "$panel_analisis" == "" {
    display as error "Ejecuta e8001_configurar.do antes de esta rutina."
    exit 198
}

use "$panel_analisis", clear
isid codigo_dane_municipio anno


********************************************************
**# Transformar variables
********************************************************

* Potencial de oro en cualquier recurso: distancia minima en metros.
gen poteMine_oro_distnc = min(poteMine_oro_distnc_roca_m, poteMine_oro_distnc_aluv_m)

* Transformar distancia en proximidad para facilitar la interpretacion.
* Convertir metros a kilometros; la formula es finita si distancia = 0.
gen proximidad_potencial_gnrl = 1 / (1 + poteMine_oro_distnc/1000)
gen proximidad_potencial_roca = 1 / (1 + poteMine_oro_distnc_roca_m/1000)
gen proximidad_potencial_aluvion = 1 / (1 + poteMine_oro_distnc_aluv_m/1000)

* Transformaciones logaritmicas
gen log_mineLegl_oro_prod_gr = log(1+mineLegl_oro_pRegls_prod_gr)
gen log_mineLegl_oro_valr_COP = log(1+mineLegl_oro_pRegls_valr_COP)

* Calcular flujo total de area SOLICITADA para mineria de oro en cada municipio-año
gen tituMine_oro_AreaSo_total_m2Fx  = tituMine_oro_AreaSo_tGrn_m2Fx + tituMine_oro_AreaSo_tOtr_m2Fx
gen log_tituMine_oro_AreaSo_total = log(1+tituMine_oro_AreaSo_total_m2Fx)

* Calcular flujo total de area TITULADA para mineria de oro en cada municipio-año
gen tituMine_oro_AreaTi_total_m2Fx  = tituMine_oro_AreaTi_tGrn_m2Fx + tituMine_oro_AreaTi_tOtr_m2Fx
gen log_tituMine_oro_AreaTi_total = log(1+tituMine_oro_AreaTi_total_m2Fx)
