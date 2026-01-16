#!/bin/bash
# omniutil_final_check.sh
# Vérification complète Omniutil – daemon, serveur, SEO, URLs publiques

echo "------------------------------------------------------"
echo "🌍 Vérification finale de l'infrastructure Omniutil"
echo "------------------------------------------------------"

# 1️⃣ Vérifie le daemon Omniutil
DAEMON_PID=$(pgrep -f omniutil_global_final.sh)
if [ -z "$DAEMON_PID" ]; then
    echo "⚠️ Daemon Omniutil NON trouvé"
else
    echo "✅ Daemon Omniutil OK (PID : $DAEMON_PID)"
fi

# 2️⃣ Vérifie le serveur Node.js/HTTPS
SERVER_PID=$(lsof -i :8082 -sTCP:LISTEN -t)
if [ -z "$SERVER_PID" ]; then
    echo "⚠️ Serveur Node.js NON trouvé sur le port 8082"
else
    echo "✅ Serveur Node.js actif sur le port 8082 (PID : $SERVER_PID)"
fi

# 3️⃣ Vérifie les fichiers SEO
for FILE in public/robots.txt public/sitemap.xml public/metadata.json; do
    if [ -f "$FILE" ]; then
        echo "✅ Fichier $FILE trouvé"
    else
        echo "⚠️ Fichier $FILE manquant"
    fi
done

# 4️⃣ Affiche les URLs publiques pour tester
IP=$(curl -s ifconfig.me)
echo "------------------------------------------------------"
echo "🌐 URLs publiques accessibles pour tester Omniutil :"
echo "🔹 Page vitrine HTTP  : http://$IP:8082"
echo "🔹 Page vitrine HTTPS : https://omniutil.example.com/"
echo "🔹 Sitemap           : https://omniutil.example.com/partner-connect/sitemap.xml"
echo "🔹 Metadata          : https://omniutil.example.com/partner-connect/metadata.json"
echo "------------------------------------------------------"

echo "✅ Check final terminé !"
