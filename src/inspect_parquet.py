from __future__ import annotations

import argparse

import pandas as pd

from config import PARQUET_DIR, ROOT_DIR

REQUIRED_COLUMNS = [
    "anio",
    "trimestre",
    "id_entidad",
    "sexo_codigo",
    "edad",
    "factor_expansion",
]

ANALYSIS_COLUMNS = [
    "id_municipio",
    "nivel_educativo_codigo",
    "condicion_ocupacion_codigo",
    "sector_actividad_codigo",
    "posicion_ocupacion_codigo",
    "horas_trabajadas",
    "ingreso",
]


def main() -> None:
    parser = argparse.ArgumentParser(description="Inspecciona Parquet generados de ENOE")
    parser.add_argument("--start-year", type=int, required=True)
    parser.add_argument("--end-year", type=int, required=True)
    args = parser.parse_args()

    rows = []
    files = sorted(PARQUET_DIR.glob("*.parquet"))
    for file in files:
        df = pd.read_parquet(file)
        if df.empty:
            year = None
        else:
            year = int(df["anio"].dropna().iloc[0]) if df["anio"].notna().any() else None
        if not year or year < args.start_year or year > args.end_year:
            continue

        row = {
            "archivo": file.name,
            "filas": len(df),
            "columnas": len(df.columns),
        }
        for col in REQUIRED_COLUMNS + ANALYSIS_COLUMNS:
            if col not in df.columns:
                row[col] = "NO_EXISTE"
            else:
                null_pct = round(float(df[col].isna().mean() * 100), 2) if len(df) else 100.0
                row[col] = f"{null_pct}% nulos"
        rows.append(row)

    report = pd.DataFrame(rows)
    output = ROOT_DIR / "docs" / "reporte_parquet.md"
    if report.empty:
        output.write_text("# Reporte Parquet\n\nNo se encontraron Parquet para el rango solicitado.", encoding="utf-8")
        print("No se encontraron Parquet para el rango solicitado.")
        return

    try:
        table_text = report.to_markdown(index=False)
    except ImportError:
        table_text = report.to_string(index=False)
    output.write_text("# Reporte Parquet\n\n" + table_text, encoding="utf-8")
    print(report.to_string(index=False))
    print(f"\nReporte guardado en: {output}")


if __name__ == "__main__":
    main()
