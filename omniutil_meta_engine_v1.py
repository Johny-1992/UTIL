#!/usr/bin/env python3
import os, json, argparse, hashlib
from datetime import datetime, UTC

ROOT = os.getcwd()
META_DIR = "artifacts/meta"
SEO_DIR = f"{META_DIR}/seo"
CRYPTO_DIR = f"{META_DIR}/crypto_listing_pack"
REPORT = "reports/omniutil_meta_report_v1.json"

SAFE_DIRS = [META_DIR, SEO_DIR, CRYPTO_DIR, "reports"]

def ensure_dirs():
    for d in SAFE_DIRS:
        os.makedirs(d, exist_ok=True)

def scan_files():
    files = []
    for root, _, fs in os.walk(ROOT):
        if any(x in root for x in ["/.git", "/node_modules", "/venv"]):
            continue
        for f in fs:
            path = os.path.join(root, f)
            files.append(path.replace(ROOT, "."))
    return files

def classify(path):
    if path.startswith("./backend"):
        return "backend"
    if path.startswith("./frontend"):
        return "frontend"
    if path.startswith("./contracts"):
        return "contracts"
    if path.startswith("./public"):
        return "public"
    if path.startswith("./scripts"):
        return "scripts"
    if path.startswith("./docs"):
        return "docs"
    return "core"

def build_project_brain(files):
    brain = {}
    for f in files:
        domain = classify(f)
        brain.setdefault(domain, {
            "files": 0,
            "exposed": domain in ["frontend", "public"],
            "crypto": domain == "contracts",
            "critical": domain in ["backend", "contracts"]
        })
        brain[domain]["files"] += 1
    return brain

def map_env(files):
    envs = {}
    for f in files:
        if "/.env" in f:
            envs.setdefault(f, {
                "scope": classify(f),
                "risk": "high" if "contracts" in f else "medium"
            })
    return envs

def generate_seo():
    with open(f"{SEO_DIR}/robots.txt", "w") as f:
        f.write("User-agent: *\nAllow: /\n")

    schema = {
        "@context": "https://schema.org",
        "@type": "SoftwareApplication",
        "name": "Omniutil",
        "applicationCategory": "BlockchainApplication",
        "operatingSystem": "Linux",
        "description": "Omniutil — Universal Web3 & AI Utility Engine"
    }
    json.dump(schema, open(f"{SEO_DIR}/schema.json", "w"), indent=2)

    og = {
        "og:title": "Omniutil",
        "og:type": "website",
        "og:description": "Universal AI & Web3 Utility Engine"
    }
    json.dump(og, open(f"{SEO_DIR}/opengraph.json", "w"), indent=2)

def generate_crypto(brain):
    project = {
        "name": "Omniutil",
        "type": "Web3 Utility Platform",
        "contracts": brain.get("contracts", {}).get("files", 0),
        "wallet_detected": os.path.isfile("USER_WALLET.json")
    }
    json.dump(project, open(f"{CRYPTO_DIR}/project.json", "w"), indent=2)

    open(f"{CRYPTO_DIR}/whitepaper.md", "w").write(
        "# Omniutil\n\nUniversal AI & Web3 Utility Engine.\n"
    )

    tokenomics = {
        "supply": "TBD",
        "utility": "Access, automation, orchestration"
    }
    json.dump(tokenomics, open(f"{CRYPTO_DIR}/tokenomics.json", "w"), indent=2)

    open(f"{CRYPTO_DIR}/verification.md", "w").write(
        "Contracts detected. Wallet present. Ready for manual verification."
    )

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--safe", action="store_true")
    args = parser.parse_args()

    if not args.safe:
        print("❌ Mode SAFE requis")
        return

    print("🧬 OMNIUTIL META ENGINE V1 — SAFE MODE")
    ensure_dirs()

    files = scan_files()
    brain = build_project_brain(files)
    env_map = map_env(files)

    generate_seo()
    generate_crypto(brain)

    report = {
        "timestamp": datetime.now(UTC).isoformat(),
        "files_scanned": len(files),
        "project_brain": brain,
        "env_map": env_map,
        "seo_generated": True,
        "crypto_pack_generated": True,
        "mode": "SAFE"
    }

    json.dump(report, open(REPORT, "w"), indent=2)

    print("✅ Artefacts générés sans modification du core")
    print(f"📄 Rapport : {REPORT}")
    print("🐶 En attente prochaine activation")

if __name__ == "__main__":
    main()
