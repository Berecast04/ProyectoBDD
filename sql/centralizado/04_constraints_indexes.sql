CREATE INDEX IF NOT EXISTS idx_fact_tiempo ON fact_ocupacion(id_tiempo);
CREATE INDEX IF NOT EXISTS idx_fact_entidad ON fact_ocupacion(id_entidad);
CREATE INDEX IF NOT EXISTS idx_fact_sexo ON fact_ocupacion(id_sexo);
CREATE INDEX IF NOT EXISTS idx_fact_condicion ON fact_ocupacion(id_condicion_ocupacion);
CREATE INDEX IF NOT EXISTS idx_fact_sector ON fact_ocupacion(id_sector_actividad);
CREATE INDEX IF NOT EXISTS idx_fact_entidad_tiempo ON fact_ocupacion(id_entidad, id_tiempo);
CREATE INDEX IF NOT EXISTS idx_dim_tiempo_anio ON dim_tiempo(anio);
