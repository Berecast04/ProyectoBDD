from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv

ROOT_DIR = Path(__file__).resolve().parents[1]
load_dotenv(ROOT_DIR / ".env")

DATA_DIR = ROOT_DIR / "data"
RAW_DIR = DATA_DIR / "raw"
EXTRACTED_DIR = DATA_DIR / "extracted"
PROCESSED_DIR = DATA_DIR / "processed"
PARQUET_DIR = DATA_DIR / "parquet"
LOG_DIR = ROOT_DIR / "logs"
CONFIG_DIR = ROOT_DIR / "config"

INEGI_ENOE_URL = os.getenv(
    "INEGI_ENOE_URL",
    "https://www.inegi.org.mx/programas/enoe/15ymas/#datos_abiertos",
)

DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "tu_password")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_CENTRAL = os.getenv("DB_CENTRAL", "enoe_centralizada")
DB_NODE_1 = os.getenv("DB_NODE_1", "enoe_nodo_1")
DB_NODE_2 = os.getenv("DB_NODE_2", "enoe_nodo_2")
DB_COORDINATOR = os.getenv("DB_COORDINATOR", "enoe_coordinador")
START_YEAR = int(os.getenv("START_YEAR", "2015"))
END_YEAR = int(os.getenv("END_YEAR", "2024"))

ENTITY_NODE_1_MAX = 16


def ensure_directories() -> None:
    for path in [RAW_DIR, EXTRACTED_DIR, PROCESSED_DIR, PARQUET_DIR, LOG_DIR, CONFIG_DIR]:
        path.mkdir(parents=True, exist_ok=True)


def database_url(database: str) -> str:
    return f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{database}"
