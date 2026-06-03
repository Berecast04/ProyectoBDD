# Validacion

La validacion comprueba que:

| Validacion | Resultado esperado |
|---|---|
| Total centralizado | Igual a nodo 1 + nodo 2 |
| Conteo por anio | Igual en ambos esquemas |
| Conteo por entidad | Igual en ambos esquemas |
| Suma de factor de expansion | Igual en ambos esquemas |
| Consultas centralizadas vs distribuidas | Mismo resultado |

El script `src/validate_distribution.py` genera `docs/resultados_validacion.md`.

## Evidencia centralizada obtenida

La base `enoe_centralizada` contiene 9,319,750 registros en `fact_ocupacion`.

| anio | registros |
|---:|---:|
| 2019 | 1,621,452 |
| 2020 | 1,071,447 |
| 2021 | 1,595,033 |
| 2022 | 1,604,831 |
| 2023 | 1,730,472 |
| 2024 | 1,696,515 |
