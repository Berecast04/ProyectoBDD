# Analisis distribuido

La ENOE puede generar un volumen historico grande. Por eso tiene sentido distribuir la tabla principal de hechos. Se propone fragmentacion horizontal primaria por entidad federativa: nodo 1 con entidades 1 a 16 y nodo 2 con entidades 17 a 32.

Las dimensiones se replican porque son pequenas y de consulta frecuente. La tabla `fact_ocupacion` se fragmenta porque concentra la mayor cantidad de registros.

Ventajas:

- Consultas regionales mas simples.
- Validacion clara de pertenencia por entidad.
- Menor volumen por nodo.
- Uso de `UNION ALL` porque los fragmentos no se traslapan.

Desventajas:

- Requiere administrar mas de una base.
- El coordinador depende de la disponibilidad de los nodos.
- Las dimensiones replicadas deben mantenerse consistentes.
