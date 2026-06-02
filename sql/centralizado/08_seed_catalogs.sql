-- Catalogos base para permitir la carga inicial.
-- Ajusta las descripciones finas con los diccionarios oficiales de ENOE del periodo descargado.
INSERT INTO dim_entidad (id_entidad, nombre_entidad) VALUES
(1,'Aguascalientes'),(2,'Baja California'),(3,'Baja California Sur'),(4,'Campeche'),
(5,'Coahuila'),(6,'Colima'),(7,'Chiapas'),(8,'Chihuahua'),(9,'Ciudad de Mexico'),
(10,'Durango'),(11,'Guanajuato'),(12,'Guerrero'),(13,'Hidalgo'),(14,'Jalisco'),
(15,'Mexico'),(16,'Michoacan'),(17,'Morelos'),(18,'Nayarit'),(19,'Nuevo Leon'),
(20,'Oaxaca'),(21,'Puebla'),(22,'Queretaro'),(23,'Quintana Roo'),(24,'San Luis Potosi'),
(25,'Sinaloa'),(26,'Sonora'),(27,'Tabasco'),(28,'Tamaulipas'),(29,'Tlaxcala'),
(30,'Veracruz'),(31,'Yucatan'),(32,'Zacatecas'),(-1,'No especificado')
ON CONFLICT DO NOTHING;

INSERT INTO dim_sexo VALUES (1,'Hombre'),(2,'Mujer'),(-1,'No especificado')
ON CONFLICT DO NOTHING;

INSERT INTO dim_edad
SELECT edad, CASE
  WHEN edad = -1 THEN 'No especificado'
  WHEN edad BETWEEN 15 AND 24 THEN '15 a 24'
  WHEN edad BETWEEN 25 AND 34 THEN '25 a 34'
  WHEN edad BETWEEN 35 AND 44 THEN '35 a 44'
  WHEN edad BETWEEN 45 AND 54 THEN '45 a 54'
  WHEN edad BETWEEN 55 AND 64 THEN '55 a 64'
  ELSE '65 y mas'
END
FROM generate_series(-1, 100) AS edad
ON CONFLICT DO NOTHING;

INSERT INTO dim_nivel_educativo
SELECT x, 'Codigo ENOE ' || x FROM generate_series(-1, 99) AS x
ON CONFLICT DO NOTHING;

INSERT INTO dim_condicion_ocupacion
SELECT x, 'Codigo ENOE ' || x FROM generate_series(-1, 99) AS x
ON CONFLICT DO NOTHING;

INSERT INTO dim_sector_actividad
SELECT x, 'Codigo ENOE ' || x FROM generate_series(-1, 999) AS x
ON CONFLICT DO NOTHING;

INSERT INTO dim_posicion_ocupacion
SELECT x, 'Codigo ENOE ' || x FROM generate_series(-1, 99) AS x
ON CONFLICT DO NOTHING;

INSERT INTO dim_municipio VALUES (-1, -1, 'No especificado')
ON CONFLICT DO NOTHING;
