#!/usr/bin/env python3
import os, json, shutil
from datetime import datetime, UTC

ROOT = os.getcwd()
META_DIR = "artifacts/meta"
SEO_SRC = f"{META_DIR}/seo"
CRYPTO_SRC = f"{META_DIR}/crypto_listing_pack"
SEO_PUB = "public/seo_publish"
CRYPTO_PUB = "artifacts/meta/crypto_publish"
REPORT = "reports/omniutil_publish_report.json"

def ensure_dirs():
    os.makedirs(SEO_PUB, exist_ok=True)
    os.makedirs(CRYPTO_PUB, exist_ok=True)

def publish_seo():
    for f in ["robots.txt", "schema.json", "opengraph.json"]:
        src = os.path.join(SEO_SRC, f)
        dst = os.path.join(SEO_PUB, f)
        if os.path.isfile(src):
            shutil.copy2(src, dst)

    # Génération simple sitemap.xml
    sitemap_path = os.path.join(SEO_PUB, "sitemap.xml")
    urls = ["./index.html", "./frontend/index.html"]
    with open(sitemap_path, "w") as f:
        f.write('<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n')
        for url in urls:
            f.write(f"  <url>\n    <loc>{url}</loc>\n  </url>\n")
        f.write("</urlset>")

def publish_crypto():
    for f in os.listdir(CRYPTO_SRC):
        src = os.path.join(CRYPTO_SRC, f)
        dst = os.path.join(CRYPTO_PUB, f)
        if os.path.isfile(src):
            shutil.copy2(src, dst)

def generate_report():
    report = {
        "timestamp": datetime.now(UTC).isoformat(),
        "seo_published": os.listdir(SEO_PUB),
        "crypto_published": os.listdir(CRYPTO_PUB),
        "mode": "SAFE",
        "note": "Tous les fichiers publiés peuvent être supprimés pour revenir à l'état antérieur."
    }
    json.dump(report, open(REPORT, "w"), indent=2)
    print(f"✅ Publication SAFE terminée. Rapport : {REPORT}")

def main():
    print("🧬 OMNIUTIL META PUBLISH — SAFE MODE")
    ensure_dirs()
    publish_seo()
    publish_crypto()
    generate_report()
    print("🐶 En attente de prochaine activation (soumission réelle si désirée)")

if __name__ == "__main__":
    main()
