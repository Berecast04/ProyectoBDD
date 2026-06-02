-- Modelo centralizado normalizado para ENOE.
CREATE TABLE IF NOT EXISTS dim_tiempo (
    id_tiempo INT PRIMARY KEY,
    anio INT NOT NULL,
    trimestre INT,
    CONSTRAINT uq_dim_tiempo UNIQUE (anio, trimestre)
);

CREATE UNLOGGED TABLE IF NOT EXISTS dim_tiempo_staging (
    id_tiempo INT,
    anio INT,
    trimestre INT
);

CREATE TABLE IF NOT EXISTS dim_entidad (
    id_entidad INT PRIMARY KEY,
    nombre_entidad TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_municipio (
    id_municipio INT PRIMARY KEY,
    id_entidad INT REFERENCES dim_entidad(id_entidad),
    nombre_municipio TEXT
);

CREATE TABLE IF NOT EXISTS dim_sexo (
    id_sexo INT PRIMARY KEY,
    descripcion TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_edad (
    id_edad INT PRIMARY KEY,
    grupo_edad TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_nivel_educativo (
    id_nivel_educativo INT PRIMARY KEY,
    descripcion TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_condicion_ocupacion (
    id_condicion_ocupacion INT PRIMARY KEY,
    descripcion TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_sector_actividad (
    id_sector_actividad INT PRIMARY KEY,
    descripcion TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_posicion_ocupacion (
    id_posicion_ocupacion INT PRIMARY KEY,
    descripcion TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS fact_ocupacion (
    id_fact BIGSERIAL PRIMARY KEY,
    id_tiempo INT NOT NULL REFERENCES dim_tiempo(id_tiempo),
    id_entidad INT NOT NULL REFERENCES dim_entidad(id_entidad),
    id_municipio INT,
    id_sexo INT NOT NULL REFERENCES dim_sexo(id_sexo),
    id_edad INT NOT NULL REFERENCES dim_edad(id_edad),
    id_nivel_educativo INT REFERENCES dim_nivel_educativo(id_nivel_educativo),
    id_condicion_ocupacion INT REFERENCES dim_condicion_ocupacion(id_condicion_ocupacion),
    id_sector_actividad INT REFERENCES dim_sector_actividad(id_sector_actividad),
    id_posicion_ocupacion INT REFERENCES dim_posicion_ocupacion(id_posicion_ocupacion),
    factor_expansion NUMERIC,
    horas_trabajadas NUMERIC,
    ingreso NUMERIC
);

COMMENT ON TABLE fact_ocupacion IS 'Tabla de hechos con observaciones ENOE seleccionadas y metricas ponderables.';
