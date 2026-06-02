# Diseno de distribucion

| Tabla | Estrategia |
|---|---|
| dim_tiempo | Replicada |
| dim_entidad | Replicada |
| dim_municipio | Replicada |
| dim_sexo | Replicada |
| dim_edad | Replicada |
| dim_nivel_educativo | Replicada |
| dim_condicion_ocupacion | Replicada |
| dim_sector_actividad | Replicada |
| dim_posicion_ocupacion | Replicada |
| fact_ocupacion | Fragmentada horizontalmente |

| Nodo | Fragmento |
|---|---|
| Nodo 1 | Entidades 1 a 16 |
| Nodo 2 | Entidades 17 a 32 |
| Coordinador | Integra con postgres_fdw |
