#!/bin/bash
cd contracts

cat > core/UTIL.sol <<'EOF'
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

contract UTIL {
    mapping(address => uint256) public balance;
    function mint(address to, uint256 amount) external {
        balance[to] += amount;
    }
}
EOF

cat > core/MeritEngine.sol <<'EOF'
pragma solidity ^0.8.20;

contract MeritEngine {
    function score(address user) external pure returns(uint256) {
        return uint256(uint160(user)) % 100;
    }
}
EOF

echo "SMART CONTRACTS READY"
