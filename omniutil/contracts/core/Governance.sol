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
