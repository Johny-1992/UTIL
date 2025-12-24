#!/bin/bash
# Test du calcul de récompenses
echo "Test 1 : Calcul des récompenses pour l'utilisateur u1 (partenaire p1, 100 USD dépensés)"
curl -X POST http://localhost:3000/api/rewards/calculate \
  -H "Content-Type: application/json" \
  -d '{"partnerId": "p1", "userId": "u1", "amountSpent": 100, "currency": "USD", "utilPrice": 0.5}'

echo -e "\nTest 2 : Transfert de 10 UTIL de u1 à u2"
curl -X POST http://localhost:3000/api/rewards/transfer \
  -H "Content-Type: application/json" \
  -d '{"fromUserId": "u1", "toUserId": "u2", "amount": 10}'

echo -e "\nTest 3 : Conversion de 5 UTIL en USDT pour u1"
curl -X POST http://localhost:3000/api/rewards/convert \
  -H "Content-Type: application/json" \
  -d '{"userId": "u1", "amount": 5}'
