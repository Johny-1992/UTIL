#!/bin/bash
echo "🚀 Génération QR OmniUtil unique..."

# Crée le dossier QR s'il n'existe pas
mkdir -p assets/qr

# Vérifie si UUID existe déjà
CONFIG_FILE="config/omnutil.json"
if [ ! -f "$CONFIG_FILE" ]; then
  mkdir -p config
  UUID=$(uuidgen)
  echo "{\"omnutil_uuid\":\"$UUID\"}" > $CONFIG_FILE
  echo "🔹 UUID OmniUtil généré : $UUID"
else
  UUID=$(jq -r '.omnutil_uuid' $CONFIG_FILE)
  echo "🔹 UUID OmniUtil existant : $UUID"
fi

# Génération QR code
QR_FILE="assets/qr/omnutil_qr.png"
QR_PAYLOAD="https://omnutil.io/partner-onboard?uuid=$UUID"

# Vérifie si qrencode est installé
if ! command -v qrencode &> /dev/null
then
    echo "⚠️ qrencode non trouvé, installation..."
    apt-get update && apt-get install -y qrencode
fi

qrencode -o $QR_FILE -s 10 "$QR_PAYLOAD"
echo "✅ QR code généré et sauvegardé dans $QR_FILE"
echo "📡 URL Partner Onboarding : $QR_PAYLOAD"
