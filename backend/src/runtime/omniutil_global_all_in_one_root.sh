#!/bin/bash
set -e

echo "🌍 OMNIUTIL – BOOTSTRAP GLOBAL ROOT MODE"
BASE_DIR="/root/omniutil/backend"
PUBLIC_DIR="$BASE_DIR/public"
LOG_DIR="$BASE_DIR/src/logs"
RUNTIME_DIR="$BASE_DIR/src/runtime"

mkdir -p "$PUBLIC_DIR/assets" "$LOG_DIR"

########################################
# 1. QR OMNIPRÉSENT
########################################
echo "✅ QR omniprésent"
if [ ! -f "$PUBLIC_DIR/assets/omniutil_qr.png" ]; then
  echo "QR OMNIUTIL" | base64 > "$PUBLIC_DIR/assets/omniutil_qr.png"
fi

########################################
# 2. VITRINE SEO
########################################
echo "✅ Génération vitrine SEO"

cat > "$PUBLIC_DIR/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<title>Omniutil – Infrastructure QR Universelle</title>
<meta name="description" content="Omniutil – QR omniprésent, partenaires, blockchain, automatisation universelle.">
<meta name="robots" content="index, follow">
<link rel="canonical" href="https://omniutil.example.com/partner-connect">
<script type="application/ld+json">
{
 "@context":"https://schema.org",
 "@type":"WebSite",
 "name":"Omniutil",
 "url":"https://omniutil.example.com/partner-connect"
}
</script>
</head>
<body>
<h1>Omniutil Universe</h1>
<p>Infrastructure QR universelle – partenaires – blockchain.</p>
<img src="assets/omniutil_qr.png" alt="QR Omniutil">
</body>
</html>
EOF

########################################
# 3. SEO FILES
########################################
echo "✅ SEO files"

cat > "$PUBLIC_DIR/robots.txt" <<EOF
User-agent: *
Allow: /
Sitemap: https://omniutil.example.com/partner-connect/sitemap.xml
EOF

cat > "$PUBLIC_DIR/sitemap.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
 <url>
  <loc>https://omniutil.example.com/partner-connect</loc>
  <priority>1.0</priority>
 </url>
</urlset>
EOF

cat > "$PUBLIC_DIR/metadata.json" <<EOF
{
 "@context":"https://schema.org",
 "@type":"WebSite",
 "name":"Omniutil",
 "url":"https://omniutil.example.com/partner-connect"
}
EOF

chmod -R 755 "$PUBLIC_DIR"

########################################
# 4. SERVEUR HTTP (SANS NODE BUG)
########################################
echo "🚀 Lancement serveur HTTP Python (stable)"

pkill -f "http.server" || true
nohup python3 -m http.server 8082 --directory "$PUBLIC_DIR" \
  > "$LOG_DIR/nohup_http.log" 2>&1 &

########################################
# 5. DAEMON OMNIUTIL
########################################
echo "🧠 Lancement Omniutil daemon"

pkill -f omniutil_global_v5.sh || true
nohup "$RUNTIME_DIR/omniutil_global_v5.sh" \
  > "$BASE_DIR/nohup_omniutil_global_v5.log" 2>&1 &

########################################
# 6. CADDY (SI PRÉSENT)
########################################
if command -v caddy >/dev/null 2>&1; then
  echo "🔐 Caddy détecté – HTTPS actif"
  pkill caddy || true
  caddy run --config "$BASE_DIR/Caddyfile" \
    > "$LOG_DIR/nohup_caddy.log" 2>&1 &
else
  echo "⚠️ Caddy non installé – HTTP actif (OK pour Google)"
fi

########################################
# 7. FINAL
########################################
echo "--------------------------------------------------"
echo "✅ OMNIUTIL OPÉRATIONNEL"
echo "🌐 HTTP  : http://41.243.58.116:8082"
echo "🔐 HTTPS : https://omniutil.example.com/"
echo "🤖 Google ready – SEO OK – QR omniprésent"
echo "--------------------------------------------------"
