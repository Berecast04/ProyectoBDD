# Conclusiones

El proyecto permite observar la diferencia entre una base centralizada y una distribuida. La base centralizada facilita la carga inicial y la validacion; la distribuida permite separar la tabla de hechos por regiones y consultar los fragmentos desde un coordinador.

El uso de Parquet mejora el procesamiento previo porque reduce espacio y acelera lecturas por columnas. La validacion es indispensable para demostrar que la fragmentacion no duplico ni elimino registros.

Como aprendizaje principal, el proyecto muestra que una base distribuida no solo consiste en separar datos, sino en justificar la separacion, mantener equivalencia logica con el modelo centralizado y comprobar los resultados con consultas de validacion.
