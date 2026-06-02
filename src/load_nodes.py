from __future__ import annotations

import argparse
from io import StringIO

import pandas as pd
from sqlalchemy import create_engine, text

from config import DB_CENTRAL, DB_NODE_1, DB_NODE_2, database_url
from utils import setup_logger

logger = setup_logger("load_nodes")

DIMENSIONS = [
    "dim_tiempo",
    "dim_entidad",
    "dim_municipio",
    "dim_sexo",
    "dim_edad",
    "dim_nivel_educativo",
    "dim_condicion_ocupacion",
    "dim_sector_actividad",
    "dim_posicion_ocupacion",
]


def copy_df(conn, table: str, df: pd.DataFrame) -> None:
    raw = conn.connection.driver_connection
    buffer = StringIO()
    df.to_csv(buffer, index=False, header=False, na_rep="\\N")
    buffer.seek(0)
    with raw.cursor() as cur:
        cur.copy_expert(f"COPY {table} ({', '.join(df.columns)}) FROM STDIN WITH CSV NULL '\\N'", buffer)


def load_node(source_engine, target_db: str, fragment_table: str) -> None:
    target_engine = create_engine(database_url(target_db))
    with source_engine.begin() as src, target_engine.begin() as dst:
        for dim in DIMENSIONS:
            dst.execute(text(f"TRUNCATE {dim} CASCADE"))
            copy_df(dst, dim, pd.read_sql(f"SELECT * FROM {dim}", src))
        dst.execute(text("TRUNCATE fact_ocupacion RESTART IDENTITY"))
        copy_df(dst, "fact_ocupacion", pd.read_sql(f"SELECT * FROM {fragment_table}", src))
    logger.info("Nodo cargado: %s", target_db)


def main() -> None:
    parser = argparse.ArgumentParser(description="Carga dimensiones y fragmentos en nodos")
    parser.add_argument("--central", default=DB_CENTRAL)
    args = parser.parse_args()
    source = create_engine(database_url(args.central))
    load_node(source, DB_NODE_1, "fact_ocupacion_nodo_1_fragment")
    load_node(source, DB_NODE_2, "fact_ocupacion_nodo_2_fragment")


if __name__ == "__main__":
    main()
