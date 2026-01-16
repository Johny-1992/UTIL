#!/bin/bash
# ==============================================
# OMNIUTIL VITRINE – Serveur statique + QR + Daemon
# ==============================================

# 1. Vérifications préliminaires
echo "🌍 OMNIUTIL VITRINE – Vérification environnement..."
NODE_VERSION=$(node -v)
PYTHON_VERSION=$(python3 --version 2>/dev/null || echo "Python3 non installé")
echo "Node.js : $NODE_VERSION"
echo "Python3 : $PYTHON_VERSION"

# 2. Vérification / création dossiers
mkdir -p public/assets
mkdir -p src/logs

# 3. Copier QR si manquant
if [ ! -f "public/assets/omniutil_qr.png" ]; then
    echo "📌 QR code manquant → création..."
    qrencode -o src/assets/omniutil_qr.png "https://omniutil.example.com/partner-connect" -s 10
    cp src/assets/omniutil_qr.png public/assets/
fi

# 4. Servir le site statique
# On privilégie http-server pour éviter l’erreur Node sur uv_interface_addresses
echo "🚀 Lancement serveur vitrine sur http://0.0.0.0:8082"
if ! command -v http-server &> /dev/null; then
    echo "📦 Installation http-server..."
    npm install -g http-server
fi

# Lancer le serveur en arrière-plan
nohup http-server public -p 8082 -a 0.0.0.0 > nohup_vitrine.out 2>&1 &

# 5. Vérifier le daemon Omniutil Global v3
echo "🟢 Vérification Omniutil Global Daemon v3..."
DAEMON_PID=$(pgrep -f omniutil_global_daemon_v3.sh)
if [ -z "$DAEMON_PID" ]; then
    echo "⚠️ Daemon non trouvé → lancement..."
    nohup ./src/runtime/omniutil_global_daemon_v3.sh > nohup_daemon.out 2>&1 &
else
    echo "✅ Daemon actif PID: $DAEMON_PID"
fi

# 6. Message final
echo "🌐 Omniutil Vitrine + Daemon actifs !"
echo "🖥️ Accès vitrine : http://<IP_DE_VOTRE_SERVEUR>:8082/"
echo "🔗 QR Code disponible : public/assets/omniutil_qr.png"
echo "🔎 Google pourra indexer le site dès qu'il sera accessible publiquement."
