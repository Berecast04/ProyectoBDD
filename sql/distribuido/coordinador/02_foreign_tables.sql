CREATE FOREIGN TABLE IF NOT EXISTS fact_ocupacion_nodo_1 (
    id_fact BIGINT,
    id_tiempo INT,
    id_entidad INT,
    id_municipio INT,
    id_sexo INT,
    id_edad INT,
    id_nivel_educativo INT,
    id_condicion_ocupacion INT,
    id_sector_actividad INT,
    id_posicion_ocupacion INT,
    factor_expansion NUMERIC,
    horas_trabajadas NUMERIC,
    ingreso NUMERIC
) SERVER enoe_nodo_1_srv OPTIONS (schema_name 'public', table_name 'fact_ocupacion');

CREATE FOREIGN TABLE IF NOT EXISTS fact_ocupacion_nodo_2 (
    id_fact BIGINT,
    id_tiempo INT,
    id_entidad INT,
    id_municipio INT,
    id_sexo INT,
    id_edad INT,
    id_nivel_educativo INT,
    id_condicion_ocupacion INT,
    id_sector_actividad INT,
    id_posicion_ocupacion INT,
    factor_expansion NUMERIC,
    horas_trabajadas NUMERIC,
    ingreso NUMERIC
) SERVER enoe_nodo_2_srv OPTIONS (schema_name 'public', table_name 'fact_ocupacion');

IMPORT FOREIGN SCHEMA public
LIMIT TO (dim_tiempo, dim_entidad, dim_sexo, dim_edad, dim_nivel_educativo, dim_condicion_ocupacion, dim_sector_actividad, dim_posicion_ocupacion)
FROM SERVER enoe_nodo_1_srv INTO public;
