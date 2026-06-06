-- Ejecutar en la base enoe_centralizada.

-- C1. Conteo total global.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT COUNT(*) AS total_registros
FROM fact_ocupacion;

-- C2. Conteo por fragmento logico.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT
    CASE
        WHEN id_entidad BETWEEN 1 AND 16 THEN 1
        WHEN id_entidad BETWEEN 17 AND 32 THEN 2
    END AS nodo_origen,
    COUNT(*) AS total_registros
FROM fact_ocupacion
WHERE id_entidad BETWEEN 1 AND 32
GROUP BY 1
ORDER BY 1;

-- C3. Conteo por entidad federativa.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT id_entidad, COUNT(*) AS total_registros
FROM fact_ocupacion
GROUP BY id_entidad
ORDER BY id_entidad;

-- C4. Conteo por ano.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT t.anio, COUNT(*) AS total_registros
FROM fact_ocupacion f
JOIN dim_tiempo t ON t.id_tiempo = f.id_tiempo
GROUP BY t.anio
ORDER BY t.anio;

-- C5. Poblacion ponderada de 2024 por fragmento logico.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT
    CASE
        WHEN id_entidad BETWEEN 1 AND 16 THEN 1
        WHEN id_entidad BETWEEN 17 AND 32 THEN 2
    END AS nodo_origen,
    SUM(factor_expansion) AS poblacion_ponderada_2024
FROM fact_ocupacion
WHERE id_tiempo BETWEEN 20241 AND 20244
  AND id_entidad BETWEEN 1 AND 32
GROUP BY 1
ORDER BY 1;

-- C6. Registros por condicion de ocupacion y fragmento logico.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT
    CASE
        WHEN id_entidad BETWEEN 1 AND 16 THEN 1
        WHEN id_entidad BETWEEN 17 AND 32 THEN 2
    END AS nodo_origen,
    id_condicion_ocupacion,
    COUNT(*) AS total_registros
FROM fact_ocupacion
WHERE id_entidad BETWEEN 1 AND 32
GROUP BY 1, id_condicion_ocupacion
ORDER BY 1, id_condicion_ocupacion;

-- C7. Registros por sexo y fragmento logico.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT
    CASE
        WHEN id_entidad BETWEEN 1 AND 16 THEN 1
        WHEN id_entidad BETWEEN 17 AND 32 THEN 2
    END AS nodo_origen,
    id_sexo,
    COUNT(*) AS total_registros
FROM fact_ocupacion
WHERE id_entidad BETWEEN 1 AND 32
GROUP BY 1, id_sexo
ORDER BY 1, id_sexo;

-- C8. Promedio de horas trabajadas por fragmento logico.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT
    CASE
        WHEN id_entidad BETWEEN 1 AND 16 THEN 1
        WHEN id_entidad BETWEEN 17 AND 32 THEN 2
    END AS nodo_origen,
    AVG(horas_trabajadas) AS promedio_horas
FROM fact_ocupacion
WHERE id_entidad BETWEEN 1 AND 32
  AND horas_trabajadas IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- C9. Tres entidades con mas registros de 2024 por fragmento logico.
-- ROW_NUMBER obtiene un ranking independiente para cada nodo logico.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
WITH conteos AS (
    SELECT
        CASE
            WHEN id_entidad BETWEEN 1 AND 16 THEN 1
            WHEN id_entidad BETWEEN 17 AND 32 THEN 2
        END AS nodo_origen,
        id_entidad,
        COUNT(*) AS total_registros
    FROM fact_ocupacion
    WHERE id_tiempo BETWEEN 20241 AND 20244
      AND id_entidad BETWEEN 1 AND 32
    GROUP BY 1, id_entidad
),
ranking AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY nodo_origen
               ORDER BY total_registros DESC
           ) AS posicion
    FROM conteos
)
SELECT nodo_origen, posicion, id_entidad, total_registros
FROM ranking
WHERE posicion <= 3
ORDER BY nodo_origen, posicion;

-- C10. Condicion de ocupacion para las entidades 17 y 18.
-- Ambas entidades pertenecen al fragmento logico del nodo 2.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT
    id_entidad,
    id_condicion_ocupacion,
    COUNT(*) AS total_registros
FROM fact_ocupacion
WHERE id_entidad IN (17, 18)
GROUP BY id_entidad, id_condicion_ocupacion
ORDER BY id_entidad, id_condicion_ocupacion;
