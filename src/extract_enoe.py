from __future__ import annotations

import argparse
import zipfile
from pathlib import Path

from tqdm import tqdm

from config import EXTRACTED_DIR, RAW_DIR, ensure_directories
from utils import setup_logger

logger = setup_logger("extract_enoe")


def extract_zip(zip_path: Path, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    marker = output_dir / ".extracted"
    if marker.exists():
        logger.info("Ya extraido: %s", zip_path.name)
        return
    if not zipfile.is_zipfile(zip_path):
        logger.error("Se omite archivo no valido como ZIP: %s", zip_path)
        return
    with zipfile.ZipFile(zip_path) as zf:
        bad = zf.testzip()
        if bad:
            raise zipfile.BadZipFile(f"Archivo corrupto dentro del ZIP: {bad}")
        for member in tqdm(zf.infolist(), desc=zip_path.name, leave=False):
            zf.extract(member, output_dir)
    marker.write_text("ok", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description="Extrae ZIP de ENOE a data/extracted")
    parser.add_argument("--start-year", type=int, default=None)
    parser.add_argument("--end-year", type=int, default=None)
    args = parser.parse_args()
    ensure_directories()
    zips = sorted(RAW_DIR.glob("**/*.zip"))
    if args.start_year:
        zips = [p for p in zips if p.parent.name.isdigit() and int(p.parent.name) >= args.start_year]
    if args.end_year:
        zips = [p for p in zips if p.parent.name.isdigit() and int(p.parent.name) <= args.end_year]
    for zip_path in tqdm(zips, desc="ZIPs"):
        try:
            extract_zip(zip_path, EXTRACTED_DIR / zip_path.parent.name / zip_path.stem)
        except Exception as exc:
            logger.error("No se pudo extraer %s: %s", zip_path, exc)


if __name__ == "__main__":
    main()
