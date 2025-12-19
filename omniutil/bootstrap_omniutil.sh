#!/bin/bash
set -e

echo "🚀 Bootstrapping OMNIUTIL repository..."

# -------------------------
# SMART CONTRACTS
# -------------------------

cat << 'EOF' > contracts/core/UTIL.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract UTIL {
    mapping(address => uint256) private balances;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function balanceOf(address user) external view returns (uint256) {
        return balances[user];
    }

    function _mint(address user, uint256 amount) internal {
        balances[user] += amount;
        emit Transfer(address(0), user, amount);
    }

    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "UTIL: insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }
}
EOF

cat << 'EOF' > contracts/core/MeritEngine.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./UTIL.sol";

contract MeritEngine is UTIL {

    event MeritConverted(address indexed user, uint256 merit, uint256 util);

    function convertMeritToUTIL(
        address user,
        uint256 meritScore,
        uint256 partnerRate
    ) external {
        uint256 utilAmount = meritScore * partnerRate;
        _mint(user, utilAmount);
        emit MeritConverted(user, meritScore, utilAmount);
    }
}
EOF

cat << 'EOF' > contracts/core/PartnerRegistry.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PartnerRegistry {

    struct Partner {
        string name;
        uint256 rewardRate;
        bool active;
    }

    mapping(address => Partner) public partners;

    event PartnerRegistered(address partner, string name, uint256 rate);

    function registerPartner(
        address partner,
        string calldata name,
        uint256 rate
    ) external {
        partners[partner] = Partner(name, rate, true);
        emit PartnerRegistered(partner, name, rate);
    }
}
EOF

cat << 'EOF' > contracts/core/Governance.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Governance {

    mapping(address => bool) public multisig;
    uint256 public threshold;

    constructor(address[] memory admins, uint256 _threshold) {
        threshold = _threshold;
        for (uint i = 0; i < admins.length; i++) {
            multisig[admins[i]] = true;
        }
    }

    function isAdmin(address user) external view returns (bool) {
        return multisig[user];
    }
}
EOF

# -------------------------
# BACKEND API (TS)
# -------------------------

cat << 'EOF' > backend/api/partner.onboard.ts
export function onboardPartner(partner: any) {
  if (partner.score >= 80) {
    return { status: "accepted", partner };
  }
  return { status: "rejected", partner };
}
EOF

cat << 'EOF' > backend/api/reward.compute.ts
export function computeUTIL(usage: number, rate: number) {
  return usage * rate;
}
EOF

cat << 'EOF' > backend/api/util.exchange.ts
export function exchangeUTIL(user: string, service: string, amount: number) {
  return { user, service, amount, status: "exchanged" };
}
EOF

cat << 'EOF' > backend/api/index.ts
export * from "./partner.onboard";
export * from "./reward.compute";
export * from "./util.exchange";
EOF

# -------------------------
# AI C++ CORE
# -------------------------

cat << 'EOF' > backend/ai/partner_validation.cpp
#include <string>
extern "C" int validate_partner(const std::string&) {
    return 85;
}
EOF

cat << 'EOF' > backend/ai/scoring_engine.cpp
extern "C" int compute_merit(int usage, int engagement) {
    return usage + engagement;
}
EOF

cat << 'EOF' > backend/ai/fraud_detection.cpp
extern "C" bool detect_fraud() {
    return false;
}
EOF

# -------------------------
# FRONTEND
# -------------------------

cat << 'EOF' > frontend/landing/index.html
<!DOCTYPE html>
<html>
<head>
  <title>OMNIUTIL</title>
</head>
<body>
  <h1>OMNIUTIL – Universal Utility Infrastructure</h1>
  <p>Demo = Real</p>
</body>
</html>
EOF

cat << 'EOF' > frontend/landing/marketing.md
# OMNIUTIL
Universal loyalty and utility infrastructure.
EOF

cat << 'EOF' > frontend/qr/omniutil_qr.svg
<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120">
  <rect width="120" height="120" fill="black"/>
</svg>
EOF

# -------------------------
# CONFIG DEMO
# -------------------------

cat << 'EOF' > environments/demo/config.demo.json
{
  "mode": "demo",
  "chain": "multichain",
  "ai": true
}
EOF

cat << 'EOF' > environments/demo/demo.partners.json
[
  { "name": "DemoTelco", "rate": 2 }
]
EOF

cat << 'EOF' > environments/demo/demo.users.json
[
  { "id": "user1", "usage": 100 }
]
EOF

echo "✅ OMNIUTIL bootstrap completed successfully."
