-- Ejecutar en la base enoe_coordinador con ambas computadoras conectadas.
-- Las agregaciones se hacen por nodo y solo se integran resultados pequenos.

-- D1. Conteo total global.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT SUM(total_registros) AS total_registros
FROM (
    SELECT COUNT(*) AS total_registros FROM fact_ocupacion_nodo_1
    UNION ALL
    SELECT COUNT(*) AS total_registros FROM fact_ocupacion_nodo_2
) q;

-- D2. Conteo por nodo fisico.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT 1 AS nodo_origen, COUNT(*) AS total_registros
FROM fact_ocupacion_nodo_1
UNION ALL
SELECT 2 AS nodo_origen, COUNT(*) AS total_registros
FROM fact_ocupacion_nodo_2
ORDER BY nodo_origen;

-- D3. Conteo por entidad federativa.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT id_entidad, SUM(total_registros) AS total_registros
FROM (
    SELECT id_entidad, COUNT(*) AS total_registros
    FROM fact_ocupacion_nodo_1
    GROUP BY id_entidad
    UNION ALL
    SELECT id_entidad, COUNT(*) AS total_registros
    FROM fact_ocupacion_nodo_2
    GROUP BY id_entidad
) q
GROUP BY id_entidad
ORDER BY id_entidad;

-- D4. Conteo por ano. Primero se agrega por id_tiempo en cada nodo.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT t.anio, SUM(q.total_registros) AS total_registros
FROM (
    SELECT id_tiempo, COUNT(*) AS total_registros
    FROM fact_ocupacion_nodo_1
    GROUP BY id_tiempo
    UNION ALL
    SELECT id_tiempo, COUNT(*) AS total_registros
    FROM fact_ocupacion_nodo_2
    GROUP BY id_tiempo
) q
JOIN dim_tiempo t ON t.id_tiempo = q.id_tiempo
GROUP BY t.anio
ORDER BY t.anio;

-- D5. Poblacion ponderada de 2024 por nodo.
-- El filtro permite usar el indice de id_tiempo y evita recorrer diez anos.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT 1 AS nodo_origen,
       SUM(factor_expansion) AS poblacion_ponderada_2024
FROM fact_ocupacion_nodo_1
WHERE id_tiempo BETWEEN 20241 AND 20244
UNION ALL
SELECT 2 AS nodo_origen,
       SUM(factor_expansion) AS poblacion_ponderada_2024
FROM fact_ocupacion_nodo_2
WHERE id_tiempo BETWEEN 20241 AND 20244
ORDER BY nodo_origen;

-- D6. Registros por condicion de ocupacion y nodo.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT nodo_origen, id_condicion_ocupacion,
       SUM(total_registros) AS total_registros
FROM (
    SELECT 1 AS nodo_origen, id_condicion_ocupacion,
           COUNT(*) AS total_registros
    FROM fact_ocupacion_nodo_1
    GROUP BY id_condicion_ocupacion
    UNION ALL
    SELECT 2 AS nodo_origen, id_condicion_ocupacion,
           COUNT(*) AS total_registros
    FROM fact_ocupacion_nodo_2
    GROUP BY id_condicion_ocupacion
) q
GROUP BY nodo_origen, id_condicion_ocupacion
ORDER BY nodo_origen, id_condicion_ocupacion;

-- D7. Registros por sexo y nodo.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT nodo_origen, id_sexo, SUM(total_registros) AS total_registros
FROM (
    SELECT 1 AS nodo_origen, id_sexo, COUNT(*) AS total_registros
    FROM fact_ocupacion_nodo_1
    GROUP BY id_sexo
    UNION ALL
    SELECT 2 AS nodo_origen, id_sexo, COUNT(*) AS total_registros
    FROM fact_ocupacion_nodo_2
    GROUP BY id_sexo
) q
GROUP BY nodo_origen, id_sexo
ORDER BY nodo_origen, id_sexo;

-- D8. Promedio correcto de horas por nodo.
-- Se usa SUM/COUNT para no promediar promedios parciales.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT nodo_origen,
       suma_horas / NULLIF(cantidad, 0) AS promedio_horas
FROM (
    SELECT 1 AS nodo_origen,
           SUM(horas_trabajadas) AS suma_horas,
           COUNT(horas_trabajadas) AS cantidad
    FROM fact_ocupacion_nodo_1
    UNION ALL
    SELECT 2 AS nodo_origen,
           SUM(horas_trabajadas) AS suma_horas,
           COUNT(horas_trabajadas) AS cantidad
    FROM fact_ocupacion_nodo_2
) q
ORDER BY nodo_origen;

-- D9. Tres entidades con mas registros de 2024 en cada nodo.
-- Cada nodo filtra, agrupa, ordena y devuelve solamente sus tres resultados.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT *
FROM (
    SELECT 1 AS nodo_origen,
           id_entidad,
           COUNT(*) AS total_registros
    FROM fact_ocupacion_nodo_1
    WHERE id_tiempo BETWEEN 20241 AND 20244
    GROUP BY id_entidad
    ORDER BY total_registros DESC
    LIMIT 3
) nodo_1

UNION ALL

SELECT *
FROM (
    SELECT 2 AS nodo_origen,
           id_entidad,
           COUNT(*) AS total_registros
    FROM fact_ocupacion_nodo_2
    WHERE id_tiempo BETWEEN 20241 AND 20244
    GROUP BY id_entidad
    ORDER BY total_registros DESC
    LIMIT 3
) nodo_2
ORDER BY nodo_origen, total_registros DESC;

-- D10. Condicion de ocupacion para las entidades 17 y 18.
-- Ambas entidades viven en el nodo 2, por lo que el coordinador consulta
-- solamente la maquina remota y evita acceder al nodo 1.
EXPLAIN (ANALYZE, BUFFERS, SUMMARY)
SELECT 2 AS nodo_origen,
       id_entidad,
       id_condicion_ocupacion,
       COUNT(*) AS total_registros
FROM fact_ocupacion_nodo_2
WHERE id_entidad IN (17, 18)
GROUP BY id_entidad, id_condicion_ocupacion
ORDER BY id_entidad, id_condicion_ocupacion;
