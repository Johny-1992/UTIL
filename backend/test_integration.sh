#!/bin/bash

# Variables
API_KEY="votre_cle_api"
USER_ADDRESS="0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
PARTNER_ADDRESS="0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"

# 1. Tester claimReward
echo "=== Test de claimReward ==="
curl -s -X POST http://127.0.0.1:3000/api/rewards/claim \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -d "{
    \"userAddress\": \"$USER_ADDRESS\",
    \"amountSpentUSD\": 100,
    \"privateKey\": \"$PRIVATE_KEY\",
    \"partnerAddress\": \"$PARTNER_ADDRESS\"
  }" | jq

# 2. Tester exchangeForService
echo -e "\n=== Test de exchangeForService ==="
curl -s -X POST http://127.0.0.1:3000/api/exchange/service \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -d "{
    \"userAddress\": \"$USER_ADDRESS\",
    \"amount\": 5,
    \"serviceDescription\": \"1GB Data\",
    \"privateKey\": \"$PRIVATE_KEY\"
  }" | jq

# 3. Tester exchangeForUSDT
echo -e "\n=== Test de exchangeForUSDT ==="
curl -s -X POST http://127.0.0.1:3000/api/exchange/usdt \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -d "{
    \"userAddress\": \"$USER_ADDRESS\",
    \"amount\": 5,
    \"privateKey\": \"$PRIVATE_KEY\"
  }" | jq

# 4. Tester transferInEcosystem
echo -e "\n=== Test de transferInEcosystem ==="
curl -s -X POST http://127.0.0.1:3000/api/transfer/ecosystem \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -d "{
    \"fromPrivateKey\": \"$PRIVATE_KEY\",
    \"toAddress\": \"$USER_ADDRESS\",
    \"amount\": 2
  }" | jq
