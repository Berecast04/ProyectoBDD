# Proyecto ENOE - Bases de Datos Distribuidas

Proyecto académico que procesa datos históricos de la Encuesta Nacional de
Ocupación y Empleo (ENOE) del INEGI y compara una base PostgreSQL centralizada
contra una arquitectura distribuida con dos nodos y un coordinador
`postgres_fdw`.

Fuente oficial:
https://www.inegi.org.mx/programas/enoe/15ymas/#datos_abiertos

## Resultado

- Periodo procesado: 2015-2024.
- Total centralizado: 15,645,061 registros.
- Nodo 1: entidades 1-16, con 8,107,058 registros.
- Nodo 2: entidades 17-32, con 7,538,003 registros.
- Coordinador: integra un nodo local y otro PostgreSQL remoto.
- Comparación: centralizada ganó 6 de 10 pruebas; distribuida ganó 4.

## Requisitos

- Python 3.12 o compatible.
- PostgreSQL 17 y pgAdmin 4.
- Dos computadoras en la misma red para la demostración distribuida.

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
```

Edita `.env` con tus credenciales locales. El archivo `.env` no se publica.

## Flujo de datos

```powershell
python src/download_enoe.py --start-year 2015 --end-year 2024
python src/extract_enoe.py --start-year 2015 --end-year 2024
python src/transform_enoe.py --start-year 2015 --end-year 2024
python src/load_centralized_db.py --db enoe_centralizada
python src/fragment_data.py
python src/load_nodes.py
```

Los datos descargados, DBF, Parquet, logs y respaldos se generan localmente y
están excluidos del repositorio por tamaño y seguridad.

## SQL

1. Crea la base central con `sql/centralizado/`.
2. Crea las bases distribuidas con `sql/distribuido/00_create_databases.sql`.
3. Prepara cada nodo con sus scripts `01_create_tables.sql`.
4. Edita los valores de ejemplo de
   `sql/distribuido/coordinador/01_fdw_config.sql`.
5. Ejecuta en el coordinador los scripts `01`, `02` y `03`.

Las diez pruebas comparativas están en:

- `sql/comparacion/01_consultas_centralizadas.sql`
- `sql/comparacion/02_consultas_distribuidas.sql`

## Documentación

La documentación oficial y vigente está en
[`docs/latex_entrega/proyecto_enoe_bdd.tex`](docs/latex_entrega/proyecto_enoe_bdd.tex).
Incluye instalación desde cero, las 82 evidencias, consultas, tiempos,
validación, respaldos y conclusiones.

## Datos y respaldos

Este repositorio no incluye los datos ENOE ni archivos `.backup`. Se regeneran
con los scripts del proyecto. Esto evita publicar varios gigabytes y mantiene
fuera del historial credenciales y artefactos locales.
