CREATE OR REPLACE VIEW vw_fact_ocupacion_global AS
SELECT *, 1 AS nodo_origen FROM fact_ocupacion_nodo_1
UNION ALL
SELECT *, 2 AS nodo_origen FROM fact_ocupacion_nodo_2;

CREATE OR REPLACE VIEW vw_ocupacion_global_detalle AS
SELECT f.*, t.anio, t.trimestre, e.nombre_entidad, s.descripcion AS sexo,
       ed.grupo_edad, ne.descripcion AS nivel_educativo,
       co.descripcion AS condicion_ocupacion, sa.descripcion AS sector_actividad,
       po.descripcion AS posicion_ocupacion
FROM vw_fact_ocupacion_global f
JOIN dim_tiempo t ON t.id_tiempo = f.id_tiempo
JOIN dim_entidad e ON e.id_entidad = f.id_entidad
JOIN dim_sexo s ON s.id_sexo = f.id_sexo
JOIN dim_edad ed ON ed.id_edad = f.id_edad
LEFT JOIN dim_nivel_educativo ne ON ne.id_nivel_educativo = f.id_nivel_educativo
LEFT JOIN dim_condicion_ocupacion co ON co.id_condicion_ocupacion = f.id_condicion_ocupacion
LEFT JOIN dim_sector_actividad sa ON sa.id_sector_actividad = f.id_sector_actividad
LEFT JOIN dim_posicion_ocupacion po ON po.id_posicion_ocupacion = f.id_posicion_ocupacion;
