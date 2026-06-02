# Fuente de datos

La fuente oficial es el portal de datos abiertos de ENOE, poblacion de 15 anios y mas: https://www.inegi.org.mx/programas/enoe/15ymas/#datos_abiertos

El periodo recomendado es 2015 a 2024 para cubrir diez anios. Si el volumen es demasiado grande, los scripts permiten configurar el rango con `--start-year` y `--end-year`.

Los archivos originales se guardan en `data/raw/`, se extraen en `data/extracted/` y se transforman a Parquet en `data/parquet/` para mejorar velocidad y almacenamiento. Antes de la carga definitiva se debe revisar la estructura real de los archivos descargados y ajustar los catalogos descriptivos con los diccionarios oficiales del periodo seleccionado.
