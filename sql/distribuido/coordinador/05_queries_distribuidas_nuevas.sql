-- Nueva 1: Comparar poblacion estimada entre Nodo 1 y Nodo 2.
SELECT nodo_origen, SUM(COALESCE(factor_expansion,1)) AS poblacion_estimada
FROM vw_fact_ocupacion_global
GROUP BY nodo_origen
ORDER BY nodo_origen;

-- Nueva 2: Ranking de entidades con mayor poblacion desocupada.
SELECT nombre_entidad, SUM(COALESCE(factor_expansion,1)) AS poblacion_desocupada
FROM vw_ocupacion_global_detalle
WHERE condicion_ocupacion ILIKE '%desocup%'
GROUP BY nombre_entidad
ORDER BY poblacion_desocupada DESC
LIMIT 10;

-- Nueva 3: Evolucion del empleo por region/nodo y anio.
SELECT nodo_origen, anio, SUM(COALESCE(factor_expansion,1)) AS poblacion_estimada
FROM vw_ocupacion_global_detalle
GROUP BY nodo_origen, anio
ORDER BY nodo_origen, anio;

-- Nueva 4: Sectores con mas ocupacion por nodo.
SELECT nodo_origen, sector_actividad, SUM(COALESCE(factor_expansion,1)) AS poblacion_estimada
FROM vw_ocupacion_global_detalle
GROUP BY nodo_origen, sector_actividad
ORDER BY nodo_origen, poblacion_estimada DESC;

-- Nueva 5: Comparacion de horas trabajadas promedio entre regiones.
SELECT nodo_origen, AVG(horas_trabajadas) AS promedio_horas
FROM vw_ocupacion_global_detalle
WHERE horas_trabajadas IS NOT NULL
GROUP BY nodo_origen
ORDER BY nodo_origen;
