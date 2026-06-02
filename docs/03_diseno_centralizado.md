# Diseno centralizado

El modelo centralizado usa una tabla de hechos, `fact_ocupacion`, y dimensiones para tiempo, entidad, sexo, edad, nivel educativo, condicion de ocupacion, sector y posicion en la ocupacion. Este diseno evita repetir descripciones textuales en millones de filas y permite explicar normalizacion hasta 3FN.

```mermaid
erDiagram
  dim_tiempo ||--o{ fact_ocupacion : clasifica
  dim_entidad ||--o{ fact_ocupacion : ubica
  dim_sexo ||--o{ fact_ocupacion : clasifica
  dim_edad ||--o{ fact_ocupacion : clasifica
  dim_nivel_educativo ||--o{ fact_ocupacion : clasifica
  dim_condicion_ocupacion ||--o{ fact_ocupacion : clasifica
  dim_sector_actividad ||--o{ fact_ocupacion : clasifica
  dim_posicion_ocupacion ||--o{ fact_ocupacion : clasifica
```

La tabla `fact_ocupacion` conserva las llaves foraneas y las metricas numericas. Las dimensiones representan catalogos o atributos que se repiten, por lo que su separacion reduce redundancia.
