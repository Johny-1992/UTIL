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
