#!/bin/bash
# ==============================
# OmniUtil – Bootstrap Site (Étape 1)
# Non destructif – SEO ready
# ==============================

set -e

echo "🚀 OmniUtil – Initialisation du site public (Étape 1)"

# Sécurité : backup
if [ -f index.html ] && [ ! -f explorer.html ]; then
  echo "📦 Sauvegarde de l'explorer actuel → explorer.html"
  cp index.html explorer.html
fi

# Créer la landing page SEO
echo "🧱 Création de la landing page index.html"

cat > index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>OmniUtil — On-Chain Transparency & Smart Contract Explorer</title>

  <meta name="description" content="OmniUtil is an on-chain contract explorer and transparency platform for Ethereum. Built for developers, auditors, investors and Web3 ecosystems." />
  <meta name="keywords" content="OmniUtil, Ethereum, Smart Contract Explorer, Web3 Transparency, Blockchain Audit, On-chain Data" />
  <meta name="author" content="OmniUtil" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <style>
    body {
      font-family: Arial, sans-serif;
      background: #0d1117;
      color: #e6edf3;
      margin: 0;
      padding: 40px;
      line-height: 1.6;
    }
    h1 { color: #58a6ff; }
    a {
      color: #58a6ff;
      text-decoration: none;
      font-weight: bold;
    }
    .container {
      max-width: 900px;
      margin: auto;
    }
    .card {
      background: #161b22;
      padding: 24px;
      border-radius: 8px;
      margin-top: 30px;
    }
    footer {
      margin-top: 60px;
      font-size: 0.9em;
      opacity: 0.7;
    }
  </style>
</head>

<body>
  <div class="container">
    <h1>OmniUtil</h1>
    <p><strong>On-Chain Transparency & Smart Contract Intelligence</strong></p>

    <div class="card">
      <p>
        OmniUtil is a Web3 infrastructure tool designed to explore, analyze and
        understand smart contracts directly on-chain.
      </p>

      <ul>
        <li>🔍 Ethereum Smart Contract Explorer</li>
        <li>🧠 ABI & function introspection</li>
        <li>🔗 Live RPC connection (Infura)</li>
        <li>⚙️ Built for developers, auditors & investors</li>
      </ul>

      <p>
        👉 <a href="./explorer.html">Launch the Contract Explorer</a>
      </p>
    </div>

    <footer>
      © OmniUtil — Transparency by design
    </footer>
  </div>
</body>
</html>
EOF

echo "✅ Étape 1 terminée avec succès"
echo "➡️ Page publique : http://localhost:PORT/index.html"
echo "➡️ Explorer : http://localhost:PORT/explorer.html"
