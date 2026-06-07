# Datos Parquet

Aquí se guardan los archivos Parquet producidos por el proceso de
transformación.

Para generarlos desde la raíz del proyecto:

```powershell
python src/transform_enoe.py --start-year 2015 --end-year 2024
```

Los archivos Parquet están excluidos de Git por su tamaño. Estos archivos se
utilizan posteriormente para cargar PostgreSQL.
