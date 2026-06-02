-- Consulta 1: Poblacion ocupada y desocupada por anio.
SELECT anio, condicion_ocupacion, SUM(COALESCE(factor_expansion,1)) AS poblacion_estimada
FROM vw_ocupacion_central_detalle
GROUP BY anio, condicion_ocupacion
ORDER BY anio, condicion_ocupacion;

-- Consulta 2: Distribucion de ocupacion por entidad federativa.
SELECT nombre_entidad, condicion_ocupacion, SUM(COALESCE(factor_expansion,1)) AS poblacion_estimada
FROM vw_ocupacion_central_detalle
GROUP BY nombre_entidad, condicion_ocupacion
ORDER BY nombre_entidad, poblacion_estimada DESC;

-- Consulta 3: Comparacion de ocupacion por sexo y anio.
SELECT anio, sexo, condicion_ocupacion, SUM(COALESCE(factor_expansion,1)) AS poblacion_estimada
FROM vw_ocupacion_central_detalle
GROUP BY anio, sexo, condicion_ocupacion
ORDER BY anio, sexo;

-- Consulta 4: Promedio de horas trabajadas por sector de actividad.
SELECT sector_actividad, AVG(horas_trabajadas) AS promedio_horas
FROM vw_ocupacion_central_detalle
WHERE horas_trabajadas IS NOT NULL
GROUP BY sector_actividad
ORDER BY promedio_horas DESC;

-- Consulta 5: Nivel educativo predominante por condicion de ocupacion.
WITH base AS (
  SELECT condicion_ocupacion, nivel_educativo, SUM(COALESCE(factor_expansion,1)) AS poblacion_estimada
  FROM vw_ocupacion_central_detalle
  GROUP BY condicion_ocupacion, nivel_educativo
), ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY condicion_ocupacion ORDER BY poblacion_estimada DESC) AS rn
  FROM base
)
SELECT condicion_ocupacion, nivel_educativo, poblacion_estimada
FROM ranked
WHERE rn = 1;
