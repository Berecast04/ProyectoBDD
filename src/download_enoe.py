from __future__ import annotations

import argparse
import json
import re
import time
import zipfile
from pathlib import Path
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup
from tqdm import tqdm

from config import CONFIG_DIR, INEGI_ENOE_URL, RAW_DIR, ensure_directories
from utils import setup_logger

logger = setup_logger("download_enoe")


def discover_zip_links(start_year: int, end_year: int) -> list[dict]:
    """Detecta enlaces ZIP publicados en la pagina oficial de ENOE."""
    response = requests.get(INEGI_ENOE_URL, timeout=30)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")
    links: list[dict] = []
    for a in soup.find_all("a", href=True):
        href = a["href"]
        text = " ".join(a.get_text(" ").split())
        absolute = urljoin(INEGI_ENOE_URL, href)
        if ".zip" not in absolute.lower() and "zip" not in text.lower():
            continue
        years = [int(y) for y in re.findall(r"20\d{2}", text + " " + absolute)]
        if not years:
            continue
        year = max(years)
        if start_year <= year <= end_year:
            links.append({"year": year, "quarter": None, "url": absolute, "description": text or Path(urlparse(absolute).path).name})
    unique = {item["url"]: item for item in links}
    return sorted(unique.values(), key=lambda x: (x["year"], x["url"]))


def manual_links(start_year: int, end_year: int) -> list[dict]:
    path = CONFIG_DIR / "enoe_urls.json"
    if not path.exists():
        return []
    data = json.loads(path.read_text(encoding="utf-8"))
    links = []
    for item in data.get("urls", []):
        if not item.get("url"):
            continue
        year = int(item["year"])
        if start_year <= year <= end_year:
            links.append(item)
    return links


def generated_microdata_links(start_year: int, end_year: int) -> list[dict]:
    """Genera URLs oficiales de microdatos trimestrales ENOE.

    INEGI publica los microdatos con una ruta estable. Este fallback evita que
    el proyecto se quede atorado cuando el portal carga los botones con JS.
    """
    base = "https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos"
    links = []
    for year in range(start_year, end_year + 1):
        for quarter in range(1, 5):
            if year < 2020 or (year == 2020 and quarter == 1):
                filename = f"{year}trim{quarter}_dbf.zip"
            elif year in {2021, 2022} or (year == 2020 and quarter in {3, 4}):
                filename = f"enoe_n_{year}_trim{quarter}_dbf.zip"
            elif year == 2020 and quarter == 2:
                logger.warning("Se omite 2020 T2: INEGI suspendio ENOE por contingencia sanitaria; ese periodo corresponde a ETOE.")
                continue
            else:
                filename = f"enoe_{year}_trim{quarter}_dbf.zip"
            links.append(
                {
                    "year": year,
                    "quarter": quarter,
                    "url": f"{base}/{filename}",
                    "description": f"Microdatos ENOE {year} trimestre {quarter}",
                }
            )
    return links


def filename_for(item: dict) -> str:
    parsed = Path(urlparse(item["url"]).path).name
    if parsed and parsed.lower().endswith(".zip"):
        return parsed
    q = f"_T{item['quarter']}" if item.get("quarter") else ""
    return f"enoe_{item['year']}{q}.zip"


def download_file(url: str, destination: Path, retries: int = 3) -> None:
    if destination.exists() and destination.stat().st_size > 0:
        if zipfile.is_zipfile(destination):
            logger.info("Ya existe, se omite: %s", destination.name)
            return
        logger.warning("Archivo existente invalido; se descargara otra vez: %s", destination.name)
        destination.unlink()
    temp = destination.with_suffix(destination.suffix + ".part")
    for attempt in range(1, retries + 1):
        try:
            with requests.get(url, stream=True, timeout=60) as response:
                response.raise_for_status()
                total = int(response.headers.get("content-length", 0))
                with temp.open("wb") as fh, tqdm(total=total, unit="B", unit_scale=True, desc=destination.name) as bar:
                    for chunk in response.iter_content(chunk_size=1024 * 512):
                        if chunk:
                            fh.write(chunk)
                            bar.update(len(chunk))
            if temp.stat().st_size == 0:
                raise ValueError("archivo descargado vacio")
            if not zipfile.is_zipfile(temp):
                preview = temp.read_text(encoding="latin1", errors="ignore")[:120].replace("\n", " ")
                temp.unlink(missing_ok=True)
                raise ValueError(f"la respuesta no es ZIP valido: {preview}")
            temp.replace(destination)
            logger.info("Descargado: %s", destination)
            return
        except Exception as exc:
            logger.error("Fallo descarga intento %s/%s %s: %s", attempt, retries, url, exc)
            time.sleep(2 * attempt)
    raise RuntimeError(f"No se pudo descargar {url}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Descarga archivos ZIP oficiales de ENOE")
    parser.add_argument("--start-year", type=int, required=True)
    parser.add_argument("--end-year", type=int, required=True)
    parser.add_argument("--manual-only", action="store_true")
    args = parser.parse_args()
    ensure_directories()
    links = manual_links(args.start_year, args.end_year)
    if not args.manual_only:
        try:
            links = discover_zip_links(args.start_year, args.end_year) + links
        except Exception as exc:
            logger.warning("No se pudo scrapear INEGI; se usara lista manual: %s", exc)
    if not links:
        logger.warning("No se detectaron enlaces en HTML; se generaran URLs oficiales de microdatos.")
        links = generated_microdata_links(args.start_year, args.end_year)
    links = list({item["url"]: item for item in links if item.get("url")}.values())
    if not links:
        logger.warning("No hay URLs. Agrega enlaces oficiales en config/enoe_urls.json")
        return
    for item in tqdm(links, desc="Archivos ENOE"):
        year_dir = RAW_DIR / str(item["year"])
        year_dir.mkdir(parents=True, exist_ok=True)
        download_file(item["url"], year_dir / filename_for(item))


if __name__ == "__main__":
    main()
