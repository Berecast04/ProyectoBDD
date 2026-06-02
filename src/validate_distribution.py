from __future__ import annotations

import pandas as pd
from sqlalchemy import create_engine

from config import DB_CENTRAL, DB_COORDINATOR, ROOT_DIR, database_url
from utils import setup_logger

logger = setup_logger("validate_distribution")

CHECKS = {
    "conteo_total": "SELECT COUNT(*) AS registros FROM {table}",
    "conteo_por_anio": "SELECT anio, COUNT(*) registros FROM {detail} GROUP BY anio ORDER BY anio",
    "conteo_por_entidad": "SELECT id_entidad, COUNT(*) registros FROM {detail} GROUP BY id_entidad ORDER BY id_entidad",
    "suma_factor": "SELECT ROUND(SUM(COALESCE(factor_expansion,0))::numeric, 2) AS suma_factor FROM {table}",
}


def main() -> None:
    central = create_engine(database_url(DB_CENTRAL))
    coord = create_engine(database_url(DB_COORDINATOR))
    rows = []
    for name, sql in CHECKS.items():
        c_sql = sql.format(table="fact_ocupacion", detail="vw_ocupacion_central_detalle")
        d_sql = sql.format(table="vw_fact_ocupacion_global", detail="vw_ocupacion_global_detalle")
        c = pd.read_sql(c_sql, central)
        d = pd.read_sql(d_sql, coord)
        ok = c.equals(d)
        rows.append({"validacion": name, "resultado": "OK" if ok else "DIFERENCIA"})
        if not ok:
            logger.warning("Diferencia en %s", name)
    report = ROOT_DIR / "docs" / "resultados_validacion.md"
    report.write_text("# Resultados de validacion\n\n" + pd.DataFrame(rows).to_markdown(index=False), encoding="utf-8")
    logger.info("Reporte generado: %s", report)


if __name__ == "__main__":
    main()
