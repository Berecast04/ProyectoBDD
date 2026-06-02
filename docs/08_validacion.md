# Validacion

La validacion comprueba que:

| Validacion | Resultado esperado |
|---|---|
| Total centralizado | Igual a nodo 1 + nodo 2 |
| Conteo por anio | Igual en ambos esquemas |
| Conteo por entidad | Igual en ambos esquemas |
| Suma de factor de expansion | Igual en ambos esquemas |
| Consultas centralizadas vs distribuidas | Mismo resultado |

El script `src/validate_distribution.py` genera `docs/resultados_validacion.md`.
