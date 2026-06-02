from __future__ import annotations

import logging
from pathlib import Path
from typing import Iterable

import pandas as pd
from dbfread import DBF
from sqlalchemy import create_engine, text

from config import LOG_DIR


def setup_logger(name: str) -> logging.Logger:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    if not logger.handlers:
        file_handler = logging.FileHandler(LOG_DIR / f"{name}.log", encoding="utf-8")
        console_handler = logging.StreamHandler()
        formatter = logging.Formatter("%(asctime)s [%(levelname)s] %(message)s")
        file_handler.setFormatter(formatter)
        console_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
        logger.addHandler(console_handler)
    return logger


def normalize_columns(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df.columns = [str(c).strip().lower() for c in df.columns]
    return df


def read_table_file(path: Path) -> pd.DataFrame:
    suffix = path.suffix.lower()
    if suffix in {".csv", ".txt"}:
        for sep in [",", "|", "\t", ";"]:
            try:
                df = pd.read_csv(path, sep=sep, encoding="latin1", low_memory=False)
                if len(df.columns) > 1:
                    return normalize_columns(df)
            except Exception:
                continue
        return normalize_columns(pd.read_csv(path, encoding="latin1", low_memory=False))
    if suffix == ".parquet":
        return normalize_columns(pd.read_parquet(path))
    if suffix in {".xlsx", ".xls"}:
        return normalize_columns(pd.read_excel(path))
    if suffix == ".dbf":
        table = DBF(path, encoding="latin1", load=True, char_decode_errors="ignore")
        return normalize_columns(pd.DataFrame(iter(table)))
    raise ValueError(f"Formato no soportado: {path}")


def run_sql(database_url: str, sql_files: Iterable[Path]) -> None:
    engine = create_engine(database_url)
    with engine.begin() as conn:
        for sql_file in sql_files:
            conn.execute(text(sql_file.read_text(encoding="utf-8")))
