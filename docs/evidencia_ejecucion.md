# Evidencia de ejecucion

## Carga centralizada

La carga centralizada se ejecuto con:

```bash
python src/load_centralized_db.py --db enoe_centralizada
```

El proceso cargo 23 archivos Parquet correspondientes al periodo 2019-2024. El trimestre 2020 T2 no aparece porque la ENOE regular fue suspendida durante la contingencia sanitaria.

## Conteo total centralizado

```sql
SELECT COUNT(*) FROM fact_ocupacion;
```

Resultado:

| total_registros |
|---:|
| 9,319,750 |

## Conteo por anio

```sql
SELECT t.anio, COUNT(*) AS registros
FROM fact_ocupacion f
JOIN dim_tiempo t ON t.id_tiempo = f.id_tiempo
GROUP BY t.anio
ORDER BY t.anio;
```

Resultado:

| anio | registros |
|---:|---:|
| 2019 | 1,621,452 |
| 2020 | 1,071,447 |
| 2021 | 1,595,033 |
| 2022 | 1,604,831 |
| 2023 | 1,730,472 |
| 2024 | 1,696,515 |

Estos resultados confirman que la base centralizada contiene datos reales de INEGI para seis anios, con una excepcion documentada para 2020 T2.
