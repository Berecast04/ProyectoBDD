from __future__ import annotations

import argparse

from sqlalchemy import create_engine, text

from config import DB_CENTRAL, ENTITY_NODE_1_MAX, database_url
from utils import setup_logger

logger = setup_logger("fragment_data")


def main() -> None:
    parser = argparse.ArgumentParser(description="Crea tablas de fragmentos desde base centralizada")
    parser.add_argument("--db", default=DB_CENTRAL)
    args = parser.parse_args()
    engine = create_engine(database_url(args.db))
    with engine.begin() as conn:
        conn.execute(text("DROP TABLE IF EXISTS fact_ocupacion_nodo_1_fragment"))
        conn.execute(text("DROP TABLE IF EXISTS fact_ocupacion_nodo_2_fragment"))
        conn.execute(text(f"CREATE TABLE fact_ocupacion_nodo_1_fragment AS SELECT * FROM fact_ocupacion WHERE id_entidad BETWEEN 1 AND {ENTITY_NODE_1_MAX}"))
        conn.execute(text(f"CREATE TABLE fact_ocupacion_nodo_2_fragment AS SELECT * FROM fact_ocupacion WHERE id_entidad BETWEEN {ENTITY_NODE_1_MAX + 1} AND 32"))
        row = conn.execute(text("""
            SELECT
              (SELECT COUNT(*) FROM fact_ocupacion) AS total,
              (SELECT COUNT(*) FROM fact_ocupacion_nodo_1_fragment) AS n1,
              (SELECT COUNT(*) FROM fact_ocupacion_nodo_2_fragment) AS n2
        """)).mappings().one()
        logger.info("Total central=%s, nodo1=%s, nodo2=%s", row["total"], row["n1"], row["n2"])
        if row["total"] != row["n1"] + row["n2"]:
            raise ValueError("La fragmentacion no conserva el total de registros")


if __name__ == "__main__":
    main()
