SELECT COUNT(*) AS total_registros FROM fact_ocupacion;
SELECT t.anio, COUNT(*) FROM fact_ocupacion f JOIN dim_tiempo t ON t.id_tiempo = f.id_tiempo GROUP BY t.anio ORDER BY t.anio;
SELECT id_entidad, COUNT(*) FROM fact_ocupacion GROUP BY id_entidad ORDER BY id_entidad;
