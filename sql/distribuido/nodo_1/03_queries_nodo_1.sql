SELECT id_entidad, COUNT(*) AS registros
FROM fact_ocupacion
GROUP BY id_entidad
ORDER BY id_entidad;
