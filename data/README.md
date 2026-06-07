# Datos ENOE

Esta carpeta contiene los datos generados durante la ejecución del proyecto.
Los archivos reales no se publican en GitHub porque ocupan aproximadamente
12 GB y pueden volver a generarse desde la fuente oficial del INEGI.

Estructura:

- `raw/`: archivos ZIP originales descargados del INEGI.
- `extracted/`: archivos DBF extraídos y organizados por año y trimestre.
- `parquet/`: archivos Parquet generados por la transformación.
- `processed/`: espacio reservado para otros resultados procesados.

Desde la raíz del proyecto, con el entorno virtual activo, se generan con:

```powershell
python src/download_enoe.py --start-year 2015 --end-year 2024
python src/extract_enoe.py --start-year 2015 --end-year 2024
python src/transform_enoe.py --start-year 2015 --end-year 2024
```

Fuente oficial:
https://www.inegi.org.mx/programas/enoe/15ymas/#datos_abiertos
