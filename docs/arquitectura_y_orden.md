# Arquitectura, modelo y orden de ejecucion

## Arquitectura propuesta

Descarga ENOE -> Extraccion ZIP -> Transformacion Parquet -> Carga centralizada PostgreSQL -> Fragmentacion por entidad -> Carga de nodos -> Coordinador FDW -> Consultas distribuidas -> Validacion -> Respaldos.

## Modelo centralizado

Modelo normalizado con dimensiones pequenas y `fact_ocupacion` como tabla principal. Las dimensiones separan catalogos y evitan redundancia. La tabla de hechos almacena llaves foraneas y metricas como factor de expansion, horas trabajadas e ingreso cuando existan en los archivos reales.

## Estrategia de fragmentacion

Fragmentacion horizontal primaria por entidad federativa:

- Nodo 1: entidades 1 a 16.
- Nodo 2: entidades 17 a 32.

Las dimensiones se replican en ambos nodos. El coordinador consulta ambas partes mediante `postgres_fdw` y crea una vista global con `UNION ALL`.

## Orden exacto

1. Instalar dependencias.
2. Crear `.env`.
3. Descargar ENOE.
4. Extraer ZIP.
5. Transformar a Parquet.
6. Crear base centralizada y tablas.
7. Cargar datos centralizados.
8. Ejecutar consultas centralizadas.
9. Crear bases de nodo y coordinador con `sql/distribuido/00_create_databases.sql`.
10. Fragmentar datos.
11. Cargar nodos.
12. Configurar FDW y vistas globales.
13. Ejecutar consultas distribuidas.
14. Validar centralizada vs distribuida.
15. Generar respaldos.
