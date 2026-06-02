# Consultas distribuidas

Las consultas equivalentes estan en `sql/distribuido/coordinador/04_queries_equivalentes.sql` y usan `vw_ocupacion_global_detalle`. Son equivalentes porque consultan la union de los dos fragmentos de `fact_ocupacion`.

Las consultas nuevas estan en `sql/distribuido/coordinador/05_queries_distribuidas_nuevas.sql`. Aprovechan `nodo_origen` para comparar regiones, medir poblacion estimada por nodo y revisar horas promedio entre fragmentos.
