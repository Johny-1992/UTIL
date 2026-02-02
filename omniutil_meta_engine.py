#!/usr/bin/env python3
import os
import json
import argparse
import hashlib
from datetime import datetime

ROOT_DIR = os.getcwd()
SAFE_OUTPUT_DIRS = [
    "artifacts/meta",
    "reports"
]

def ensure_dirs():
    for d in SAFE_OUTPUT_DIRS:
        os.makedirs(d, exist_ok=True)

def hash_file(path):
    try:
        with open(path, "rb") as f:
            return hashlib.sha256(f.read()).hexdigest()
    except:
        return None

def scan_project():
    scan = []
    for root, dirs, files in os.walk(ROOT_DIR):
        if any(x in root for x in ["/.git", "/node_modules", "/venv"]):
            continue
        for file in files:
            path = os.path.join(root, file)
            scan.append({
                "path": path.replace(ROOT_DIR, "."),
                "name": file,
                "ext": os.path.splitext(file)[1],
                "size": os.path.getsize(path),
                "hash": hash_file(path)
            })
    return scan

def detect_envs(scan):
    envs = []
    for f in scan:
        if f["name"].startswith(".env"):
            envs.append(f["path"])
    return envs

def build_project_brain(scan):
    brain = {}
    for f in scan:
        domain = f["path"].split("/")[1] if "/" in f["path"] else "root"
        brain.setdefault(domain, {
            "files": 0,
            "types": set()
        })
        brain[domain]["files"] += 1
        brain[domain]["types"].add(f["ext"])
    for d in brain:
        brain[d]["types"] = list(brain[d]["types"])
    return brain

def seo_preview():
    return {
        "robots": "User-agent: *\nAllow: /",
        "schema": "SoftwareApplication + BlockchainProject",
        "status": "generated (dry-run)"
    }

def crypto_preview():
    return {
        "contracts_detected": os.path.isdir("contracts"),
        "wallet_present": os.path.isfile("USER_WALLET.json"),
        "listing_pack": "ready (dry-run)"
    }

def score_system(brain, envs):
    score = 0
    if brain: score += 40
    if envs: score += 20
    if os.path.isdir("contracts"): score += 20
    if os.path.isdir("frontend"): score += 10
    if os.path.isdir("backend"): score += 10
    return min(score, 100)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    if not args.dry_run:
        print("❌ Ce script est DRY-RUN ONLY.")
        return

    print("🧬 OMNIUTIL META ENGINE — DRY RUN")
    print("🔒 MODE LECTURE SEULE")
    ensure_dirs()

    scan = scan_project()
    envs = detect_envs(scan)
    brain = build_project_brain(scan)

    seo = seo_preview()
    crypto = crypto_preview()
    score = score_system(brain, envs)

    report = {
        "timestamp": datetime.utcnow().isoformat(),
        "root": ROOT_DIR,
        "files_scanned": len(scan),
        "env_files": envs,
        "domains": brain,
        "seo": seo,
        "crypto": crypto,
        "system_score": score,
        "mode": "DRY-RUN"
    }

    with open("reports/omniutil_meta_report.json", "w") as f:
        json.dump(report, f, indent=2)

    print("✅ Scan terminé")
    print(f"📊 SYSTEM SCORE: {score}/100")
    print("📄 Rapport généré : reports/omniutil_meta_report.json")
    print("🐶 En attente décision humaine")

if __name__ == "__main__":
    main()
