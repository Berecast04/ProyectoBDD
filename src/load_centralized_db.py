from __future__ import annotations

import argparse
from io import StringIO

import pandas as pd
from sqlalchemy import create_engine, text
from tqdm import tqdm

from config import DB_CENTRAL, PARQUET_DIR, database_url
from utils import setup_logger

logger = setup_logger("load_centralized_db")


def copy_dataframe(conn, table: str, df: pd.DataFrame) -> None:
    raw = conn.connection.driver_connection
    buffer = StringIO()
    df.to_csv(buffer, index=False, header=False, na_rep="\\N")
    buffer.seek(0)
    columns = ", ".join(df.columns)
    with raw.cursor() as cur:
        cur.copy_expert(f"COPY {table} ({columns}) FROM STDIN WITH CSV NULL '\\N'", buffer)


def normalize_fact(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["id_tiempo"] = df["anio"].astype(int) * 10 + df["trimestre"].fillna(0).astype(int)
    df["id_edad"] = df["edad"].fillna(-1).astype(int)
    for col in ["id_entidad", "id_municipio", "sexo_codigo", "nivel_educativo_codigo", "condicion_ocupacion_codigo", "sector_actividad_codigo", "posicion_ocupacion_codigo"]:
        df[col] = pd.to_numeric(df[col], errors="coerce").fillna(-1).astype(int)
    for col in ["factor_expansion", "horas_trabajadas", "ingreso"]:
        df[col] = pd.to_numeric(df[col], errors="coerce")
    return df


def main() -> None:
    parser = argparse.ArgumentParser(description="Carga Parquet a PostgreSQL centralizado")
    parser.add_argument("--db", default=DB_CENTRAL)
    args = parser.parse_args()
    engine = create_engine(database_url(args.db))
    files = sorted(PARQUET_DIR.glob("*.parquet"))
    with engine.begin() as conn:
        for file in tqdm(files, desc="Cargando Parquet"):
            df = normalize_fact(pd.read_parquet(file))
            tiempos = df[["id_tiempo", "anio", "trimestre"]].drop_duplicates()
            copy_dataframe(conn, "dim_tiempo_staging", tiempos)
            conn.execute(text("INSERT INTO dim_tiempo SELECT DISTINCT * FROM dim_tiempo_staging ON CONFLICT DO NOTHING"))
            conn.execute(text("TRUNCATE dim_tiempo_staging"))
            facts = df[[
                "id_tiempo", "id_entidad", "id_municipio", "sexo_codigo", "id_edad",
                "nivel_educativo_codigo", "condicion_ocupacion_codigo", "sector_actividad_codigo",
                "posicion_ocupacion_codigo", "factor_expansion", "horas_trabajadas", "ingreso",
            ]].rename(columns={
                "sexo_codigo": "id_sexo",
                "nivel_educativo_codigo": "id_nivel_educativo",
                "condicion_ocupacion_codigo": "id_condicion_ocupacion",
                "sector_actividad_codigo": "id_sector_actividad",
                "posicion_ocupacion_codigo": "id_posicion_ocupacion",
            })
            copy_dataframe(conn, "fact_ocupacion", facts)
    logger.info("Carga centralizada terminada")


if __name__ == "__main__":
    main()
