# Proyecto ENOE - Bases de Datos Distribuidas

Sistema para descargar, transformar, cargar y validar datos historicos de la Encuesta Nacional de Ocupacion y Empleo (ENOE) del INEGI en una base centralizada PostgreSQL y despues en un esquema distribuido con dos nodos y un coordinador `postgres_fdw`.

Fuente oficial: https://www.inegi.org.mx/programas/enoe/15ymas/#datos_abiertos

## Arquitectura

1. Descarga de ZIP oficiales a `data/raw/`.
2. Extraccion a `data/extracted/`.
3. Transformacion a Parquet por anio/trimestre en `data/parquet/`.
4. Carga OLTP centralizada en `enoe_centralizada`.
5. Fragmentacion horizontal de `fact_ocupacion` por entidad federativa.
6. Carga de `enoe_nodo_1` y `enoe_nodo_2`.
7. Coordinacion con `enoe_coordinador` usando `postgres_fdw`.
8. Validacion centralizada vs distribuida.

## Instalacion

```bash
pip install -r requirements.txt
copy .env.example .env
```

Edita `.env` con tu usuario y password de PostgreSQL.

## Orden de ejecucion

```bash
python src/download_enoe.py --start-year 2015 --end-year 2024
python src/extract_enoe.py --start-year 2015 --end-year 2024
python src/transform_enoe.py --start-year 2015 --end-year 2024
```

En pgAdmin o `psql`, crea y prepara la base centralizada:

```sql
\i sql/centralizado/01_create_database.sql
\c enoe_centralizada
\i sql/centralizado/02_create_schema.sql
\i sql/centralizado/03_create_tables.sql
\i sql/centralizado/04_constraints_indexes.sql
\i sql/centralizado/08_seed_catalogs.sql
\i sql/centralizado/05_views.sql
```

Despues:

```bash
python src/load_centralized_db.py --db enoe_centralizada
python src/fragment_data.py
python src/load_nodes.py
python src/validate_distribution.py
```

Para el esquema distribuido, crea las bases con `sql/distribuido/00_create_databases.sql`, ejecuta `sql/distribuido/nodo_1/01_create_tables.sql` en `enoe_nodo_1`, `sql/distribuido/nodo_2/01_create_tables.sql` en `enoe_nodo_2`, y en `enoe_coordinador` ejecuta:

```sql
\i sql/distribuido/coordinador/01_fdw_config.sql
\i sql/distribuido/coordinador/02_foreign_tables.sql
\i sql/distribuido/coordinador/03_views_globales.sql
```

## Evidencia sugerida

Captura la descarga con barras de progreso, archivos Parquet generados, tablas en pgAdmin, conteos centralizados, conteos por nodo, vistas globales del coordinador, consultas centralizadas y distribuidas con el mismo resultado, y archivos de respaldo.

La evidencia de carga centralizada ya documentada esta en `docs/evidencia_ejecucion.md`.

## Problemas comunes

- Si INEGI cambia el HTML, agrega URLs ZIP oficiales a `config/enoe_urls.json` y ejecuta con `--manual-only`.
- Si una columna no aparece, `transform_enoe.py` la deja como nula y el modelo conserva la carga.
- Ajusta los catalogos de dimensiones cuando revises los diccionarios oficiales del periodo descargado.
