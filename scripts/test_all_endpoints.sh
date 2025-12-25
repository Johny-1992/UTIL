#!/bin/bash

# URL de base de l'application
BASE_URL="https://omniutil.onrender.com"
API_KEY="622a26b0d6a0ad49c3d689250c2043fffdebbbd768303b75043f61a90181b428"

# Tester la route racine
echo "=== Test de la route racine ==="
curl -X GET "$BASE_URL/"

# Tester l'endpoint de santé
echo -e "\n=== Test de l'endpoint de santé ==="
curl -X GET "$BASE_URL/health"

# Tester la génération du QR code
echo -e "\n=== Test de la génération du QR code ==="
curl -X GET "$BASE_URL/api/qr/generate-omniutil-qr" \
  -H "x-api-key: $API_KEY"

# Tester l'endpoint de validation des partenaires
echo -e "\n=== Test de l'endpoint de validation des partenaires ==="
curl -X POST "$BASE_URL/api/partner/request" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -d '{"ecosystemId": "airtel"}'

# Tester l'endpoint des récompenses
echo -e "\n=== Test de l'endpoint des récompenses ==="
curl -X GET "$BASE_URL/api/rewards" \
  -H "x-api-key: $API_KEY"
