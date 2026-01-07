#!/bin/bash
set -e

echo "🚀 Début de la mise en place complète du frontend OmniUtil..."

FRONTEND_DIR=~/omniutil/frontend
cd $FRONTEND_DIR

# -------------------------------
# 1️⃣ Créer dossiers essentiels
# -------------------------------
[ ! -d "public/icons" ] && mkdir -p public/icons && echo "📁 Dossier public/icons créé"
[ ! -d "src/services" ] && mkdir -p src/services && echo "📁 Dossier src/services créé"
[ ! -d "src/config" ] && mkdir -p src/config && echo "📁 Dossier src/config créé"

# -------------------------------
# 2️⃣ Manifest.json PWA
# -------------------------------
if [ ! -f "public/manifest.json" ]; then
  cat > public/manifest.json <<EOL
{
  "short_name": "OmniUtil",
  "name": "OmniUtil - Blockchain Rewards & Loyalty App",
  "description": "OmniUtil connecte les utilisateurs à des récompenses blockchain, programmes de fidélité et smart contracts sécurisés.",
  "icons": [
    {
      "src": "icons/favicon-192.png",
      "type": "image/png",
      "sizes": "192x192"
    },
    {
      "src": "icons/favicon-512.png",
      "type": "image/png",
      "sizes": "512x512"
    }
  ],
  "start_url": "/",
  "background_color": "#ffffff",
  "display": "standalone",
  "theme_color": "#4caf50"
}
EOL
  echo "📄 public/manifest.json créé"
fi

# -------------------------------
# 3️⃣ Favicon placeholders
# -------------------------------
if [ ! -f "public/icons/favicon-192.png" ]; then
  convert -size 192x192 xc:white -gravity center -pointsize 32 -annotate 0 "OmniUtil" public/icons/favicon-192.png
  echo "🖼️ Favicon 192x192 créé"
fi
if [ ! -f "public/icons/favicon-512.png" ]; then
  convert -size 512x512 xc:white -gravity center -pointsize 64 -annotate 0 "OmniUtil" public/icons/favicon-512.png
  echo "🖼️ Favicon 512x512 créé"
fi

# -------------------------------
# 4️⃣ Injection SEO + manifest dans index.html
# -------------------------------
if ! grep -q 'rel="manifest"' public/index.html; then
  sed -i '/<head>/a \
<link rel="manifest" href="%PUBLIC_URL%/manifest.json" />\
<link rel="icon" href="%PUBLIC_URL%/favicon.ico" />\
<meta name="theme-color" content="#4caf50" />\
<meta name="description" content="OmniUtil - Rewards blockchain et fidélité, smart contracts EVM-friendly, QR codes, loyalty programs." />\
<meta name="keywords" content="OmniUtil, blockchain, rewards, loyalty, smart contracts, crypto, EVM, QR code" />\
<meta name="author" content="OmniUtil Team" />' public/index.html
  echo "📝 SEO + manifest injectés dans index.html"
fi

# -------------------------------
# 5️⃣ Health check frontend
# -------------------------------
if [ ! -f "src/services/health.ts" ]; then
  cat > src/services/health.ts <<EOL
export async function checkHealth() {
  try {
    const response = await fetch(process.env.VITE_API_URL + "/health");
    return await response.json();
  } catch (error) {
    console.error("Health check failed:", error);
    return { status: "error" };
  }
}
EOL
  echo "🩺 src/services/health.ts créé"
fi

# -------------------------------
# 6️⃣ API config
# -------------------------------
if [ ! -f "src/config/api.ts" ]; then
  cat > src/config/api.ts <<EOL
const API_URL = process.env.VITE_API_URL || "https://omniutil-1.onrender.com";
export default API_URL;
EOL
  echo "🔗 src/config/api.ts créé"
fi

# -------------------------------
# 7️⃣ Créer App.tsx ultra-professionnelle si absente
# -------------------------------
if [ ! -f "src/App.tsx" ]; then
  cat > src/App.tsx <<EOL
import React, { useEffect, useState } from "react";
import { checkHealth } from "./services/health";
import API_URL from "./config/api";

function App() {
  const [health, setHealth] = useState<{status: string}>({status: "unknown"});
  useEffect(() => {
    async function fetchHealth() {
      const result = await checkHealth();
      setHealth(result);
    }
    fetchHealth();
  }, []);
  
  return (
    <div style={{ fontFamily: "Arial, sans-serif", padding: "2rem" }}>
      <header>
        <h1>🌕 OmniUtil</h1>
        <p>Blockchain Rewards, Loyalty & Smart Contracts</p>
      </header>
      <main>
        <h2>Backend Health</h2>
        <p>Status: <strong>{health.status}</strong></p>
        <h2>API URL</h2>
        <p>{API_URL}</p>
        <h2>Quick Actions</h2>
        <button onClick={() => window.open(API_URL + "/qr", "_blank")}>View QR Codes</button>
        <button onClick={() => window.open(API_URL + "/rewards", "_blank")}>View Rewards</button>
      </main>
      <footer style={{ marginTop: "2rem", borderTop: "1px solid #ddd", paddingTop: "1rem" }}>
        <p>© 2026 OmniUtil Team</p>
      </footer>
    </div>
  );
}

export default App;
EOL
  echo "💎 src/App.tsx créé avec interface professionnelle"
fi

# -------------------------------
# 8️⃣ Rebuild complet
# -------------------------------
echo "🏗️ Installation npm et build..."
npm install
npm run build

echo "✅ Frontend OmniUtil prêt ! Serve it with: serve -s build -l 4000"
