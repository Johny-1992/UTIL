#!/usr/bin/env python3
import os, json, shutil, requests
from datetime import datetime, UTC
from dotenv import load_dotenv
from web3 import Web3

# Charger les variables d'environnement
load_dotenv()
BSC_RPC_URL = os.getenv("BSC_RPC_URL")
CONTRACT_ADDRESS = os.getenv("CONTRACT_ADDRESS")
BSCSCAN_API_KEY = os.getenv("BSCSCAN_API_KEY")
COINGECKO_API_KEY = os.getenv("COINGECKO_API_KEY")
CMC_API_KEY = os.getenv("CMC_API_KEY")

# Dossiers
ROOT = os.getcwd()
META_DIR = "artifacts/meta"
SEO_SRC = f"{META_DIR}/seo"
CRYPTO_SRC = f"{META_DIR}/crypto_listing_pack"
SEO_PUB = "public/seo_publish"
CRYPTO_PUB = "artifacts/meta/crypto_publish"
SUBMIT_READY = "artifacts/meta/submission_ready"
REPORT = "reports/omniutil_publish_pro_report.json"

def ensure_dirs():
    for d in [SEO_PUB, CRYPTO_PUB, SUBMIT_READY]:
        os.makedirs(d, exist_ok=True)

# ======== CONTRAT & BLOCKCHAIN ========
def verify_contract():
    web3 = Web3(Web3.HTTPProvider(BSC_RPC_URL))
    if not web3.isConnected():
        return {"status": "error", "message": "BSC RPC non connecté"}
    
    code = web3.eth.get_code(Web3.toChecksumAddress(CONTRACT_ADDRESS))
    if code == b'':
        return {"status": "fail", "message": "Contrat non trouvé"}
    else:
        return {"status": "ok", "message": "Contrat déployé et vérifié"}

# ======== SEO ========
def publish_seo():
    for f in ["robots.txt", "schema.json", "opengraph.json"]:
        src = os.path.join(SEO_SRC, f)
        dst = os.path.join(SEO_PUB, f)
        if os.path.isfile(src):
            shutil.copy2(src, dst)
    
    # Sitemap XML
    sitemap_path = os.path.join(SEO_PUB, "sitemap.xml")
    urls = ["https://omniutil.io/", "https://omniutil.io/frontend/"]
    with open(sitemap_path, "w") as f:
        f.write('<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n')
        for url in urls:
            f.write(f"  <url>\n    <loc>{url}</loc>\n  </url>\n")
        f.write("</urlset>")
    
    # Copier prêt pour soumission
    for f in os.listdir(SEO_PUB):
        shutil.copy2(os.path.join(SEO_PUB, f), os.path.join(SUBMIT_READY, f))

# ======== CRYPTO ========
def publish_crypto():
    for f in os.listdir(CRYPTO_SRC):
        src = os.path.join(CRYPTO_SRC, f)
        dst_pub = os.path.join(CRYPTO_PUB, f)
        dst_ready = os.path.join(SUBMIT_READY, f)
        if os.path.isfile(src):
            shutil.copy2(src, dst_pub)
            shutil.copy2(src, dst_ready)

# ======== PING SEO ========
def ping_search_engines():
    sitemap_url = "https://omniutil.io/public/seo_publish/sitemap.xml"
    engines = [
        f"https://www.google.com/ping?sitemap={sitemap_url}",
        f"https://www.bing.com/ping?sitemap={sitemap_url}"
    ]
    status = {}
    for e in engines:
        try:
            r = requests.get(e, timeout=5)
            status[e] = r.status_code
        except Exception as ex:
            status[e] = str(ex)
    return status

# ======== LISTING COINGECKO & CMC ========
def submit_to_coingecko():
    url = "https://api.coingecko.com/api/v3/coins"
    headers = {"X-CG-API-KEY": COINGECKO_API_KEY}
    payload = {
        "id": "omniutil",
        "symbol": "OMNI",
        "name": "OmniUtil",
        "platforms": {"binance-smart-chain": CONTRACT_ADDRESS},
        "public_notice": "Listing automatique via OmniUtil META ENGINE PRO"
    }
    try:
        r = requests.post(url, headers=headers, json=payload, timeout=10)
        return r.status_code
    except Exception as ex:
        return str(ex)

def submit_to_cmc():
    url = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map"
    headers = {"X-CMC_PRO_API_KEY": CMC_API_KEY}
    payload = {
        "symbol": "OMNI",
        "name": "OmniUtil",
        "contract_address": CONTRACT_ADDRESS
    }
    try:
        r = requests.post(url, headers=headers, json=payload, timeout=10)
        return r.status_code
    except Exception as ex:
        return str(ex)

# ======== RAPPORT ========
def generate_report(contract_status, seo_status, search_ping, cg_status, cmc_status):
    report = {
        "timestamp": datetime.now(UTC).isoformat(),
        "contract_status": contract_status,
        "seo_published": os.listdir(SEO_PUB),
        "crypto_published": os.listdir(CRYPTO_PUB),
        "submission_ready": os.listdir(SUBMIT_READY),
        "search_engine_ping": search_ping,
        "coingecko_submission": cg_status,
        "coinmarketcap_submission": cmc_status,
        "mode": "PRO",
        "note": "Tout est automatisé, SAFE et réversible"
    }
    json.dump(report, open(REPORT, "w"), indent=2)
    print(f"✅ Publication PRO terminée. Rapport : {REPORT}")

# ======== MAIN ========
def main():
    print("🧬 OMNIUTIL META PUBLISH — PRO MODE")
    ensure_dirs()
    
    contract_status = verify_contract()
    print(f"🔗 Contrat : {contract_status['message']}")
    
    publish_seo()
    publish_crypto()
    
    search_ping = ping_search_engines()
    cg_status = submit_to_coingecko()
    cmc_status = submit_to_cmc()
    
    generate_report(contract_status, SEO_SRC, search_ping, cg_status, cmc_status)
    print("🐶 Tout est prêt pour soumission SEO et Crypto PRO")

if __name__ == "__main__":
    main()
