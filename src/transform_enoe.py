from __future__ import annotations

import argparse
import re
from pathlib import Path

import pandas as pd
from dbfread import DBF
from tqdm import tqdm

from config import EXTRACTED_DIR, PARQUET_DIR, ensure_directories
from utils import read_table_file, setup_logger

logger = setup_logger("transform_enoe")

COLUMN_CANDIDATES = {
    "id_entidad": ["ent", "entidad", "cd_a", "c_ent"],
    "id_municipio": ["mun", "municipio", "c_mun"],
    "sexo_codigo": ["sex", "sexo"],
    "edad": ["eda", "edad"],
    "nivel_educativo_codigo": ["cs_p13_1", "niv_ins", "anios_esc"],
    "condicion_ocupacion_codigo": ["clase1", "clase2", "clase3", "cond_act"],
    "sector_actividad_codigo": ["rama", "rama_est1", "scian"],
    "posicion_ocupacion_codigo": ["pos_ocu", "posicion"],
    "factor_expansion": ["fac", "fac_tri", "fac_men"],
    "horas_trabajadas": ["hrsocup", "hrs_ocu", "htrab"],
    "ingreso": ["ingocup", "ing_ocu", "ingreso"],
}


def pick_column(df: pd.DataFrame, candidates: list[str]) -> str | None:
    columns = set(df.columns)
    for candidate in candidates:
        if candidate in columns:
            return candidate
    return None


def year_quarter_from_path(path: Path) -> tuple[int | None, int | None]:
    text = str(path).lower()
    years = re.findall(r"20\d{2}", text)
    quarter = None
    qmatch = re.search(r"trim([1-4])|(?:^|[^a-z])t([1-4])(?:[^0-9]|$)", text)
    if qmatch:
        quarter = int(qmatch.group(1) or qmatch.group(2))
    return (int(years[-1]) if years else None, quarter)


def transform_file(path: Path) -> pd.DataFrame:
    if path.suffix.lower() == ".dbf":
        return transform_dbf_file(path)
    df = read_table_file(path)
    selected = pd.DataFrame()
    year, quarter = year_quarter_from_path(path)
    anio_col = pick_column(df, ["anio", "year"])
    trim_col = pick_column(df, ["trim", "trimestre", "t"])
    selected["anio"] = df[anio_col] if anio_col else year
    selected["trimestre"] = df[trim_col] if trim_col else quarter
    for output, candidates in COLUMN_CANDIDATES.items():
        column = pick_column(df, candidates)
        selected[output] = df[column] if column else pd.NA
    selected = selected.dropna(subset=["anio", "id_entidad", "sexo_codigo", "edad"], how="any")
    for col in selected.columns:
        converted = pd.to_numeric(selected[col], errors="coerce")
        selected[col] = converted if converted.notna().any() else selected[col]
    return selected


def transform_dbf_file(path: Path) -> pd.DataFrame:
    table = DBF(path, encoding="latin1", load=False, char_decode_errors="ignore")
    field_names = [field.name.lower() for field in table.fields]
    field_lookup = {name: name for name in field_names}
    year, quarter = year_quarter_from_path(path)

    selected_fields: dict[str, str | None] = {}
    for output, candidates in COLUMN_CANDIDATES.items():
        selected_fields[output] = next((candidate for candidate in candidates if candidate in field_lookup), None)

    anio_col = next((candidate for candidate in ["anio", "year"] if candidate in field_lookup), None)
    trim_col = next((candidate for candidate in ["trim", "trimestre", "t"] if candidate in field_lookup), None)

    rows = []
    total_rows = len(table)
    logger.info("Leyendo %s con %s registros", path.name, f"{total_rows:,}")
    for record in tqdm(table, total=total_rows, desc=f"Registros {path.name}", unit="reg", leave=False):
        normalized = {str(k).lower(): v for k, v in record.items()}
        row = {
            "anio": normalized.get(anio_col, year) if anio_col else year,
            "trimestre": normalized.get(trim_col, quarter) if trim_col else quarter,
        }
        for output, source in selected_fields.items():
            row[output] = normalized.get(source) if source else pd.NA
        rows.append(row)

    selected = pd.DataFrame(rows)
    if selected.empty:
        return selected
    selected = selected.dropna(subset=["anio", "id_entidad", "sexo_codigo", "edad"], how="any")
    for col in selected.columns:
        converted = pd.to_numeric(selected[col], errors="coerce")
        selected[col] = converted if converted.notna().any() else selected[col]
    return selected


def main() -> None:
    parser = argparse.ArgumentParser(description="Transforma datos ENOE extraidos a Parquet")
    parser.add_argument("--start-year", type=int, required=True)
    parser.add_argument("--end-year", type=int, required=True)
    args = parser.parse_args()
    ensure_directories()
    files = [p for p in EXTRACTED_DIR.glob("**/*") if p.suffix.lower() == ".dbf" and "sdemt" in p.name.lower()]
    if not files:
        logger.warning("No se encontraron archivos SDEMT DBF en data/extracted")
        return
    for path in tqdm(files, desc="Transformando"):
        year, quarter = year_quarter_from_path(path)
        if not year or year < args.start_year or year > args.end_year:
            continue
        try:
            df = transform_file(path)
            if df.empty:
                continue
            q = int(df["trimestre"].dropna().iloc[0]) if df["trimestre"].notna().any() else (quarter or 0)
            output = PARQUET_DIR / f"enoe_{year}_T{q}.parquet"
            logger.info("Escribiendo %s con %s registros", output.name, f"{len(df):,}")
            df.to_parquet(output, index=False, engine="pyarrow")
        except Exception as exc:
            logger.error("No se pudo transformar %s: %s", path, exc)


if __name__ == "__main__":
    main()
