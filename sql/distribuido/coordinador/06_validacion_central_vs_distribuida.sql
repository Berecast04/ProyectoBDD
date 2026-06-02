-- Ejecutar desde el coordinador. Para comparar con centralizada usa src/validate_distribution.py.
SELECT COUNT(*) AS total_distribuido FROM vw_fact_ocupacion_global;

SELECT nodo_origen, COUNT(*) AS registros
FROM vw_fact_ocupacion_global
GROUP BY nodo_origen
ORDER BY nodo_origen;

SELECT id_entidad, COUNT(*) AS registros
FROM vw_fact_ocupacion_global
GROUP BY id_entidad
ORDER BY id_entidad;

SELECT COUNT(*) AS interseccion_ids
FROM fact_ocupacion_nodo_1 n1
JOIN fact_ocupacion_nodo_2 n2 USING (id_fact);
