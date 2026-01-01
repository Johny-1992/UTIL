#!/bin/bash
set -e

echo "📡 Activation couche AUDIT OmniUtil..."

mkdir -p src/audit

cat << 'EOF' > src/audit/auditLogger.ts
import fs from "fs";
import crypto from "crypto";

export const audit = (action: string, payload: any) => {
  const timestamp = new Date().toISOString();
  const data = JSON.stringify({ action, payload, timestamp });
  const hash = crypto.createHash("sha256").update(data).digest("hex");

  const record = {
    action,
    timestamp,
    hash,
    payload
  };

  fs.appendFileSync(
    "audit.log",
    JSON.stringify(record) + "\n"
  );
};
EOF

echo "🔗 Injection audit dans rewardsService..."

sed -i '1i import { audit } from "../audit/auditLogger";' src/services/rewardsService.ts

sed -i 's/return { utilEarned/audit("REWARD_CALCULATED", { partnerId, userId, amountSpent });\n  return { utilEarned/' src/services/rewardsService.ts

sed -i 's/return { success: true/audit("TRANSFER_UTIL", { fromUserId, toUserId, amount });\n  return { success: true/' src/services/rewardsService.ts

sed -i 's/return { usdtReceived/audit("CONVERT_TO_USDT", { userId, amount });\n  return { usdtReceived/' src/services/rewardsService.ts

echo "🧪 Vérification TypeScript..."
npx tsc --noEmit

echo "✅ POINT 3 TERMINÉ — AUDIT & TRAÇABILITÉ ACTIVÉS"
