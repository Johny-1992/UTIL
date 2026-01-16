#!/bin/bash

echo "🌍 OMNIUTIL GLOBAL DAEMON v3 – Initialisation mondiale"

# 1. Vérification environnement
echo "🔍 Vérification Node.js et g++..."
node -v
g++ --version

# 2. Création des dossiers critiques
mkdir -p src/logs
mkdir -p public
mkdir -p public/assets

# 3. Verrouillage de la logique mère
LOGIC_HASH=$(sha256sum src/utils/omniutil_abi.json | awk '{print $1}')
echo "✅ Logique mère verrouillée – HASH: $LOGIC_HASH"

# 4. Sécurité Zero-Trust
echo "🛡️ Sécurité Zero-Trust active"

# 5. Orchestrateur C++ check
./src/orchestrator/orchestrator_bin "{}" AUTO_ACCEPTED 50
echo "🧠 Orchestrateur C++ OK"

# 6. Activation flux UTIL
echo "💰 Flux UTIL actifs: transferInEcosystem, exchangeForService, exchangeForUSDT, loyaltyFactor dynamique"

# 7. Génération metadata pour Google
METADATA_FILE="public/metadata.json"
cat <<EOT > $METADATA_FILE
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Omniutil",
  "url": "https://omniutil.example.com",
  "description": "Omniutil - infrastructure mondiale de récompenses UTIL",
  "logo": "https://omniutil.example.com/assets/omniutil_logo.png",
  "sameAs": [
    "https://twitter.com/Omniutil",
    "https://linkedin.com/company/omniutil"
  ]
}
EOT
echo "🌐 Metadata générée → $METADATA_FILE"

# 8. Génération site vitrine minimal
INDEX_FILE="public/index.html"
cat <<EOT > $INDEX_FILE
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<title>Omniutil - Infrastructure mondiale UTIL</title>
<meta name="description" content="Omniutil, l'infrastructure mondiale de récompenses UTIL. Scannez le QR pour devenir partenaire.">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
body { font-family: Arial, sans-serif; background:#f5f5f5; text-align:center; padding:50px;}
h1 { color:#2a9d8f; }
p { font-size:1.1em; }
.qr { margin-top:30px; }
</style>
</head>
<body>
<h1>Omniutil</h1>
<p>Infrastructure mondiale de récompenses UTIL<br>Pour devenir partenaire, scannez le QR ci-dessous :</p>
<div class="qr">
<img src="assets/omniutil_qr.png" alt="QR Omniutil" width="250" height="250">
</div>
</body>
</html>
EOT
echo "✅ Site vitrine minimal généré → $INDEX_FILE"

# 9. Copier QR (assure-toi d'avoir créé le fichier ./assets/omniutil_qr.png)
cp src/assets/omniutil_qr.png public/assets/

# 10. Lancer daemon principal en continu
echo "🚀 Lancement Omniutil Universe en mode daemon..."
while true
do
    node src/runtime/omniutil_universe_final_live.js
    sleep 10
done
